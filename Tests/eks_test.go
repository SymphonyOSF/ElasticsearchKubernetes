package test

import (
	"os"
	"io/ioutil"
	"strings"
	"testing"

	"k8s.io/client-go/tools/clientcmd"
	"github.com/stretchr/testify/require"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/awserr"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/eks"
	"github.com/gruntwork-io/terratest/modules/k8s"
	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
)


func TestEKSCluster(t *testing.T) {
	t.Parallel()

	// The folder where we have our Terraform code
	workingDir := "../Terraform/examples/using-existing-vpc/"

	// Get the cluster number from environment variables
	clusterName := os.Getenv("EKS_CLUSTER_NAME")

	// Set the aws region in which the EKS cluster is deployed
	awsRegion := "us-east-1"

	// At the end of the test, undeploy the terraform infrastructure
	defer test_structure.RunTestStage(t, "cleanup_terraform", func() {
		undeployUsingTerraform(t, workingDir)
	})

	// Cleanup the kubernetes resources
	defer test_structure.RunTestStage(t, "cleanup_k8s_cluster", func() {
		cleanupKubernetesCluster(t, workingDir)
	})

	// Destroy the Elasticsearch cluster
	defer test_structure.RunTestStage(t, "destroy_es_cluster", func() {})

	// Deploy the EKS Cluster on AWS using Terraform
	test_structure.RunTestStage(t, "deploy_terraform", func() {
		deployUsingTerraform(t, workingDir, clusterName, awsRegion)
	})

	// Bootstrap the Kubernetes Cluster
	test_structure.RunTestStage(t, "bootstrap_k8s_cluster", func() {
		// Update the current context to the newly created EKS Cluster with user details
		updateKubernetesContext(t, workingDir, clusterName, awsRegion)

		// Bootstrap EKS cluster with appropriate k8s resources
		bootstrapKubernetesCluster(t, workingDir)
	})

	// Create an Elasticsearch Cluster
	test_structure.RunTestStage(t, "create_elastic_cluster", func() {
		//createElasticsearchCluster(t)
	})
}


func deployUsingTerraform(t *testing.T, workingDir string, clusterName string, awsRegion string) {
	terraformOptions := &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: workingDir,

		BackendConfig: map[string]interface{}{
		"bucket": clusterName,
		"key"   : "directory.tfstate",
		"region": awsRegion,
		},

		// Variables to pass to our Terraform code using -var options
		Vars: map[string]interface{}{
			"region"      : awsRegion,
			"cluster_name": clusterName,
		},

	}

	// Store terraform options for undeployment
	test_structure.SaveTerraformOptions(t, workingDir, terraformOptions)

	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	terraform.InitAndApply(t, terraformOptions)
}


// Undeploy the EKS terraform infrastructure
func undeployUsingTerraform(t *testing.T, workingDir string) {
	//Load the Terraform Options saved by the earlier deploy_terraform stage
	terraformOptions := test_structure.LoadTerraformOptions(t, workingDir)

	terraform.Destroy(t, terraformOptions)
}


// This updates the current K8s context to point to the newly created EKS Cluster with given user credentials
func updateKubernetesContext(t *testing.T, workingDir string, clusterName string, awsRegion string) {
	sess, serr := session.NewSession(&aws.Config{
		Region: aws.String(awsRegion),
	})

	if serr != nil {
		logger.Log(t, serr.Error())
	}

	svc := eks.New(sess)

	output, err := svc.DescribeCluster(&eks.DescribeClusterInput{
		Name: aws.String(clusterName),
	})

	if err != nil {
		if aerr, ok := err.(awserr.Error); ok {
			switch aerr.Code() {
			case eks.ErrCodeResourceNotFoundException:
				logger.Log(t, eks.ErrCodeResourceNotFoundException, aerr.Error())
			case eks.ErrCodeClientException:
				logger.Log(t, eks.ErrCodeClientException, aerr.Error())
			case eks.ErrCodeServerException:
				logger.Log(t, eks.ErrCodeServerException, aerr.Error())
			case eks.ErrCodeServiceUnavailableException:
				logger.Log(t, eks.ErrCodeServiceUnavailableException, aerr.Error())
			default:
				logger.Log(t, aerr.Error())
			}
		} else {
			// Print the error, cast err to awserr.Error to get the Code and
			// Message from an error.
			logger.Log(t, err.Error())
		}
		return
	}

	// Get Kubeconfig file location
	configPath, err := k8s.GetKubeConfigPathE(t)
	require.NoError(t, err)

	// Load kubeconfig from file
	clientConfig := k8s.LoadConfigFromPath(configPath)

	rawConfig, err := clientConfig.RawConfig()
	require.NoError(t, err)

	// Update the kubeconfig with new context
	k8s.UpsertConfigContext(&rawConfig, *output.Cluster.Arn, *output.Cluster.Arn, *output.Cluster.Arn)
	clientcmd.ModifyConfig(clientConfig.ConfigAccess(), rawConfig, false)

	// Save the cluster_arn for later
	test_structure.SaveString(t, workingDir, "cluster_arn", *output.Cluster.Arn)
}

// Bootstrap EKS cluster with the required K8s resources
func bootstrapKubernetesCluster(t *testing.T, workingDir string) {
	// Load terraform options
	terraformOptions := test_structure.LoadTerraformOptions(t, workingDir)
	// Retrieve the EKS cluster configuration
	eksClusterOutput := terraform.OutputAll(t, terraformOptions)["eks_cluster_output"].(map[string]interface{})

	// Load cluster_arn for creating k8s options
	clusterArn := test_structure.LoadString(t, workingDir, "cluster_arn")

	// Get path to kubeconfig file
	configPath, _ := k8s.GetKubeConfigPathE(t)

	// Initialize k8s options
	kubectlOptions := k8s.NewKubectlOptions(clusterArn, configPath, "")

	// Apply config_map file to K8S, this will allow the control plane discover worker nodes
	k8s.KubectlApplyFromString(t, kubectlOptions, eksClusterOutput["config_map_aws_auth"].(string))

	// Save auto-scaler config map for cleaning up later
	test_structure.SaveString(t, workingDir, "config_map_aws_auth", eksClusterOutput["config_map_aws_auth"].(string))

	// Install AWS auto-scaler. Replace cluster_name and service_instance_type
	autoScalerFile, err := ioutil.ReadFile("../Kubernetes/cluster-autoscaler-autodiscover.yaml")
	require.NoError(t, err)

	autoScalerFileContent := strings.ReplaceAll(string(autoScalerFile), "NEW_CLUSTER_NAME", eksClusterOutput["cluster_name"].(string))
	autoScalerFileContent = strings.ReplaceAll(autoScalerFileContent, "SERVICE_INSTANCE_TYPE", eksClusterOutput["service_instance_type"].(string))

	k8s.KubectlApplyFromString(t, kubectlOptions, autoScalerFileContent)

	// Save auto-scaler config file for cleaning up later
	test_structure.SaveString(t, workingDir, "auto_scaler", autoScalerFileContent)

	// Prevent from automatically taking down the node holding the auto-scaler pod
	k8s.RunKubectl(t, kubectlOptions, "--namespace", "kube-system", "annotate", "--overwrite", "deployment.apps/cluster-autoscaler", "cluster-autoscaler.kubernetes.io/safe-to-evict=\"false\"")

	// Set the image to match the running K8S version
	k8s.RunKubectl(t, kubectlOptions, "--namespace", "kube-system", "set", "image", "deployment.apps/cluster-autoscaler", "cluster-autoscaler=k8s.gcr.io/cluster-autoscaler:v1.14.6")
}


func cleanupKubernetesCluster(t *testing.T, workingDir string)  {
	// Load cluster_arn for creating k8s options
	clusterArn := test_structure.LoadString(t, workingDir, "cluster_arn")

	// Get path to kubeconfig file
	configPath, _ := k8s.GetKubeConfigPathE(t)

	// Initialize k8s options
	kubectlOptions := k8s.NewKubectlOptions(clusterArn, configPath, "")

	// Delete AWS Auth resource
	configMapAWSAuth := test_structure.LoadString(t, workingDir, "config_map_aws_auth")
	k8s.KubectlDeleteFromString(t, kubectlOptions, configMapAWSAuth)

	// Delete AutoScaler
	autoScalerFileContent := test_structure.LoadString(t, workingDir, "auto_scaler")
	k8s.KubectlDeleteFromString(t, kubectlOptions, autoScalerFileContent)
}
