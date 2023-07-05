# Define provider
provider "aws" {
  region = var.region
}

# Create a VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = var.cidr_block
}

# Create two public subnets
resource "aws_subnet" "public_subnet_1" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.pub_subnet_1
  availability_zone = var.az_1
  
  tags = {
    Name = "public_subnet_1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.pub_subnet_2
  availability_zone = var.az_2
  
  tags = {
    Name = "public_subnet_2"
  }
}

# Create two private subnets
resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.priv_subnet_1
  availability_zone = var.az_1
  
  tags = {
    Name = "private_subnet_1"
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.priv_subnet_2
  availability_zone = var.az_2
  
  tags = {
    Name = "private_subnet_2"
  }
}

# Create an Internet Gateway
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "main_igw"
  }
}

# Create a route table for public subnets
resource "aws_route_table" "public_subnet_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "public_subnet_route_table"
  }
}

# Associate the first public subnet with the route table
resource "aws_route_table_association" "public_subnet_association_1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_subnet_route_table.id
}

# Associate the second public subnet with the route table
resource "aws_route_table_association" "public_subnet_association_2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_subnet_route_table.id
}

# Create a route in the public subnet route table
resource "aws_route" "public_subnet_route" {
  route_table_id         = aws_route_table.public_subnet_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.my_igw.id
}

# Create a NAT gateway
resource "aws_nat_gateway" "my_nat_gateway" {
  allocation_id = aws_eip.my_eip.id
  subnet_id     = aws_subnet.public_subnet_1.id
}

# Create an Elastic IP for the NAT gateway
resource "aws_eip" "my_eip" {
  vpc = true
}

# Create a route table for private subnets
resource "aws_route_table" "private_subnet_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "private_subnet_route_table"
  }
}

# Create a route in the private subnet route table
resource "aws_route" "private_subnet_route" {
  route_table_id         = aws_route_table.private_subnet_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.my_nat_gateway.id
}

# Associate the first private subnet with the route table
resource "aws_route_table_association" "private_subnet_association_1" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private_subnet_route_table.id
}

# Associate the second private subnet with the route table
resource "aws_route_table_association" "private_subnet_association_2" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private_subnet_route_table.id
}
