output "vpc_id" {
  value = aws_vpc.sym_search_vpc.id
}

output "subnet_list" {
  value = aws_subnet.sym_search_subnet
}