# My terraform
# Provision
# VPC
# Internen Gateway
# XX public subnet
# XX private subnet
# XX Nat Gateway in public subnet to give an access to Internet from private subnets


# provider "aws" {
#     region = "ap-southeast-1"
  
# }

#========================================================
data "aws_availability_zones" "available" {

}

resource "aws_vpc" "vpc_aws" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = "${var.env}-vpc"
  }                  
}
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc_aws.id

  tags = {
    Name = "${var.env}-IG"
  }
}


#===============================================
resource "aws_subnet" "public_subnet" {
  count = length(var.public_subnet_cidrs)
  vpc_id     = aws_vpc.vpc_aws.id
  cidr_block = element(var.public_subnet_cidrs,count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.env}-public-${count.index +1}"
  }
}


#====================================================
resource "aws_route_table" "public_route" {
  vpc_id = aws_vpc.vpc_aws.id


  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "${var.env}-route_public_subnet"
  }
}

resource "aws_route_table_association" "public_routes" {
  count = length(aws_subnet.public_subnet[*].id)
  route_table_id = aws_route_table.public_route.id
  subnet_id = element(aws_subnet.public_subnet[*].id, count.index)
  
}
#===========================================================


resource "aws_eip" "nat" {
    count = length(var.private_subnet_cidrs)
    vpc = true
    tags = {
        Name = "${var.env}-nat-gw-${count.index +1}"
    }
  
}
resource "aws_nat_gateway" "nat" {
    count = length(var.private_subnet_cidrs)
    allocation_id = aws_eip.nat[count.index].id
    subnet_id = element(aws_subnet.public_subnet[*].id, count.index)

  tags = {
        Name = "${var.env}-nat-gw-${count.index +1}"
    }

}

resource "aws_subnet" "private_subnets" {
  count = length(var.private_subnet_cidrs)
  vpc_id = aws_vpc.vpc_aws.id
  cidr_block = element(var.private_subnet_cidrs,count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  
  tags = {
        Name = "${var.env}-route-private-subnet-${count.index +1}"
    }

}
resource "aws_route_table" "private_route" {
    count = length(var.private_subnet_cidrs)
  vpc_id = aws_vpc.vpc_aws.id


  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat[count.index].id
  }

  tags = {
    Name = "${var.env}-route_public_subnet -${count.index + 1}"
  }
}




#================================
resource "aws_route_table_association" "private_routes" {
  count = length(aws_subnet.private_subnets[*].id)
  route_table_id = aws_route_table.private_route[count.index].id
  subnet_id = element(aws_subnet.private_subnets[*].id, count.index)
  
}




