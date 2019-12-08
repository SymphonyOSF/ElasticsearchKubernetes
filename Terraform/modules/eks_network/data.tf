locals {
//  If no VPC was defined, create one
  vpc_resource_count = var.existing_vpc_id == null ? 1 : 0

  //  If no VPC was defined, create var.num_subnets subnets
  subnect_count = var.existing_vpc_id == null ? var.num_subnets : 0

//  VPC id to return
  vpc_id = var.existing_vpc_id == null ? aws_vpc.sym_search_vpc[0].id : var.existing_vpc_id

//  Subnet id list to return
  subnet_id_list = var.existing_vpc_id == null ? aws_subnet.sym_search_subnet.*.id : var.subnet_id_list

}