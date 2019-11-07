data "aws_availability_zones" "available" {}

resource "aws_vpc" "sym-search-vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    "Name" = "sym-eks-node"
    "kubernetes.io/cluster/${var.cluster-name}" = "shared"
  }
}

//Creates 2 subnets, used for testing multiple AZs
resource "aws_subnet" "sym-search-subnet" {
  count = 2

  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = "10.0.${count.index * 16}.0/20"
  vpc_id            = aws_vpc.sym-search-vpc.id
//  map_public_ip_on_launch = true

tags = {
    "Name"                                      = "sym-eks-node"
    "kubernetes.io/role/elb"                    = 1
    "kubernetes.io/cluster/${var.cluster-name}" = "shared"
  }
}

resource "aws_internet_gateway" "sym-search-gateway" {
  vpc_id = aws_vpc.sym-search-vpc.id

  tags = {
    Name = "sym-eks"
  }
}

resource "aws_route_table" "sym-search-route-table" {
  vpc_id      = aws_vpc.sym-search-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.sym-search-gateway.id
  }
}

resource "aws_route_table_association" "sym-search-route-table-asso" {
  count           = 2
  subnet_id       = aws_subnet.sym-search-subnet.*.id[count.index]
  route_table_id  = aws_route_table.sym-search-route-table.id
}
