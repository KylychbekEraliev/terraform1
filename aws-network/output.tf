output "vpc_id" {
    value = aws_vpc.vpc_aws.id
  
}

output "vpc_cidr" {
    value = aws_vpc.vpc_aws.cidr_block
  
}

output "public_subnet_ids" {
    value = aws_subnet.public_subnet[*].id
  
}

output "private_subnet_ids" {
  value = aws_subnet.private_subnets[*].id
}