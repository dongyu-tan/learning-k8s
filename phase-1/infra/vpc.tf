resource "aws_vpc" "main" {
  # resource "resource type" "local name"
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "public_subnet_1" {
  # the ".main" follows the local name that is custom define
  # if the resource is defined as "production", then the value would be:
  # aws_vpc.production.id
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-southeast-5a"
  # availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name                                   = "public-subnet-1"
    "kubernetes.io/role/elb"               = "1" # tells ALB controller this is for public ALBs
    "kubernetes.io/cluster/my-eks-cluster" = "shared"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "ap-southeast-5b"
  # availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name                                   = "public-subnet-2"
    "kubernetes.io/role/elb"               = "1" # tells ALB controller this is for public ALBs
    "kubernetes.io/cluster/my-eks-cluster" = "shared"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id = aws_vpc.main.id
  # subnet cidr should be unique, will throw error if overlaps within the same vpc
  cidr_block        = "10.0.10.0/24"
  availability_zone = "ap-southeast-5a"
  # availability_zone = "us-east-1a"

  tags = {
    Name                              = "private-subnet-1"
    "kubernetes.io/role/internal-elb" = "1" # tells ALB controller this is for public ALBs
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-igw"
  }
}

resource "aws_eip" "nat" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_subnet_1.id
  tags = {
    Name = "main-nat-gw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
}

resource "aws_route_table_association" "public_1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private.id
}

