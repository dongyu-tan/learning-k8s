resource "aws_vpc" "main" {
  # resource "resource type" "local name"
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "public_subnet" {
  # the ".main" follows the local name that is custom define
  # if the resource is defined as "production", then the value would be:
  # aws_vpc.production.id
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-southeast-5a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-5a"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id = aws_vpc.main.id
  # subnet cidr should be unique, will throw error if overlaps within the same vpc
  cidr_block        = "10.0.2.0/24"
  availability_zone = "ap-southeast-5a"

  tags = {
    Name = "private-subnet-5a"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-igw"
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

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public.id
}
