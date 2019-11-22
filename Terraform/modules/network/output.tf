output "vpc_id" {
  value = aws_vpc.sym-search-vpc.id
}

output "subnet_list" {
  value = aws_subnet.sym-search-subnet
}