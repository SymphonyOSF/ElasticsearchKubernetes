data "aws_availability_zones" "available" {}

resource "aws_vpc" "sym_search_vpc" {
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

//Creates var.num_availability_zones subnets
//used for spawning the cluster accross multiple AZs
resource "aws_subnet" "sym_search_subnet" {
  count = var.num_availability_zones

  availability_zone = data.aws_availability_zones.available.names[count.index]
//  Each subnet gets a total of 4094 IP addresses (K8S is ip intensive, better to have more than enough)
  cidr_block        = "10.0.${count.index * 16}.0/20"
  vpc_id            = aws_vpc.sym_search_vpc.id

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
  vpc_id = aws_vpc.sym_search_vpc.id

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
  vpc_id      = aws_vpc.sym_search_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.sym_search_gateway.id
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
  route_table_id  = aws_route_table.sym_search_route_table.id
}
