data "aws_availability_zones" "available" {}

resource "aws_vpc" "sym-search-vpc" {
  cidr_block            = "10.0.0.0/16"
  enable_dns_hostnames  = true
  enable_dns_support    = true

  tags = {
    Name                                        = "elasticEksCluster"
    "Owner:team"                                = "search"
    Org                                         = "engineering"
    Customer                                    = "symphony"
    CreatedBy                                   = "terraform"
    Environment                                 = var.environment-tag
    "kubernetes.io/cluster/${var.cluster-name}" = "shared"
  }
}

//Creates var.num_availability_zones subnets
//used for spawning the cluster accross multiple AZs
resource "aws_subnet" "sym-search-subnet" {
  count = var.num_availability_zones

  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = "10.0.${count.index * 16}.0/20"
  vpc_id            = aws_vpc.sym-search-vpc.id

  tags = {
    Name                                        = "elasticEksCluster"
    "Owner:team"                                = "search"
    Org                                         = "engineering"
    Customer                                    = "symphony"
    CreatedBy                                   = "terraform"
    "kubernetes.io/role/elb"                    = 1
    "kubernetes.io/cluster/${var.cluster-name}" = "shared"
  }

}

resource "aws_internet_gateway" "sym-search-gateway" {
  vpc_id = aws_vpc.sym-search-vpc.id

  tags = {
    Name                                        = "elasticEksCluster"
    "Owner:team"                                = "search"
    Org                                         = "engineering"
    Customer                                    = "symphony"
    CreatedBy                                   = "terraform"
    Environment                                 = var.environment-tag
  }
}

resource "aws_route_table" "sym-search-route-table" {
  vpc_id      = aws_vpc.sym-search-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.sym-search-gateway.id
  }

  tags = {
    Name                                        = "elasticEksCluster"
    "Owner:team"                                = "search"
    Org                                         = "engineering"
    Customer                                    = "symphony"
    CreatedBy                                   = "terraform"
    Environment                                 = var.environment-tag
  }
}

resource "aws_route_table_association" "sym-search-route-table-asso" {
  count           = var.num_availability_zones
  subnet_id       = aws_subnet.sym-search-subnet.*.id[count.index]
  route_table_id  = aws_route_table.sym-search-route-table.id
}
