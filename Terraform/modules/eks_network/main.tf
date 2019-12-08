data "aws_availability_zones" "available" {}

resource "aws_vpc" "sym_search_vpc" {
  count = local.vpc_resource_count
  cidr_block            = "10.0.0.0/16"
  enable_dns_hostnames  = true
  enable_dns_support    = true

  tags = {
    Name                                        = "elasticEksCluster"
    "Owner:team"                                = "search"
    Org                                         = "engineering"
    Customer                                    = "symphony"
    CreatedBy                                   = "terraform"
    Environment                                 = var.environment_tag
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

//Creates N subnets
//used for spawning the cluster accross multiple AZs
resource "aws_subnet" "sym_search_subnet" {
  count = local.subnect_count

//  Will generate an error if trying to create more subnets than available AZs in the region
  availability_zone = data.aws_availability_zones.available.names[count.index]
//  Each subnet gets a total of 4094 IP addresses (K8S is ip intensive, better to have more than enough)
  cidr_block        = "10.0.${count.index * 16}.0/20"
  vpc_id            = local.vpc_id

  tags = {
    Name                                        = "elasticEksCluster"
    "Owner:team"                                = "search"
    Org                                         = "engineering"
    Customer                                    = "symphony"
    CreatedBy                                   = "terraform"
    "kubernetes.io/role/elb"                    = 1
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }

}

resource "aws_internet_gateway" "sym_search_gateway" {
  count  = local.vpc_resource_count
  vpc_id = local.vpc_id

  tags = {
    Name                                        = "elasticEksCluster"
    "Owner:team"                                = "search"
    Org                                         = "engineering"
    Customer                                    = "symphony"
    CreatedBy                                   = "terraform"
    Environment                                 = var.environment_tag
  }
}

resource "aws_route_table" "sym_search_route_table" {
  count       = local.vpc_resource_count
  vpc_id      = local.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.sym_search_gateway[0].id
  }

  tags = {
    Name                                        = "elasticEksCluster"
    "Owner:team"                                = "search"
    Org                                         = "engineering"
    Customer                                    = "symphony"
    CreatedBy                                   = "terraform"
    Environment                                 = var.environment_tag
  }
}

resource "aws_route_table_association" "sym_internet_asso" {
  count           = length(aws_subnet.sym_search_subnet)
  subnet_id       = aws_subnet.sym_search_subnet.*.id[count.index]
  route_table_id  = aws_route_table.sym_search_route_table[0].id
}
