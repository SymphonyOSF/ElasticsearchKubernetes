package test

import (
	"testing"

	//"github.com/aws/aws-sdk-go/service/eks"
	//"github.com/gruntwork-io/terratest/modules/aws"
	//"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
)


func TestEKSCluster(t *testing.T) {
	t.Parallel()

	// The folder where we have our Terraform code
	workingDir := "../Terraform/examples/using-existing-vpc/"

	// At the end of the test, undeploy the terraform infrastructure
	defer test_structure.RunTestStage(t, "cleanup_terraform", func() {
		undeployUsingTerraform(t, workingDir)
	})

	// Cleanup the kubernetes resources
	defer test_structure.RunTestStage(t, "cleanup_k8s_cluster", func() {})

	// Destroy the Elasticsearch cluster
	defer test_structure.RunTestStage(t, "destroy_es_cluster", func() {})

	// Deploy the EKS Cluster on AWS using Terraform
	test_structure.RunTestStage(t, "deploy_terraform", func() {
		awsRegion := "us-east-1"
		test_structure.SaveString(t, workingDir, "awsRegion", awsRegion)
		deployUsingTerraform(t, awsRegion, workingDir)
	})

	// Bootstrap the Kubernetes Cluster
	test_structure.RunTestStage(t, "bootstrap_k8s_cluster", func() {})

	// Create an Elasticsearch Cluster
	test_structure.RunTestStage(t, "create_elastic_cluster", func() {})
}


func deployUsingTerraform(t *testing.T, awsRegion string, workingDir string) {
	terraformOptions := &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: workingDir,

		BackendConfig: map[string]interface{}{
		"bucket": "sym-search-elasticsearch-test",
		"key"   : "directory.tfstate",
		"region": awsRegion,
		},

		// Variables to pass to our Terraform code using -var options
		Vars: map[string]interface{}{
			"region"      : awsRegion,
			"cluster_name": "sym-search-elasticsearch-test",
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
