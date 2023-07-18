provider "aws" {
  region = "ap-south-1"
}

resource "aws_instance" "demo-server" {
    ami = "ami-0d13e3e640877b0b9"
    instance_type = "t2.micro"
    key_name = "dpp"
    //security_groups = [ "demo-sg" ]
    vpc_security_group_ids = [aws_security_group.demo-sg.id]
    subnet_id = aws_subnet.my-subnet-public-01.id
}

resource "aws_security_group" "demo-sg" {
  name        = "demo-sg"
  description = "SSH Access"
  vpc_id = aws_vpc.my-vpc.id

  ingress {
    description      = "SSH Access"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "ssh-port"
  }
}

resource "aws_vpc" "my-vpc" {
  cidr_block = "10.1.0.0/16"
  tags = {
    Name = "my-vpc"
  }
  
}

resource "aws_subnet" "my-subnet-public-01" {
  vpc_id     = aws_vpc.my-vpc.id
  cidr_block = "10.1.1.0/24"

  tags = {
    Name = "my-subnet-public-01"
  }
}

resource "aws_subnet" "my-subnet-public-02" {
  vpc_id     = aws_vpc.my-vpc.id
  cidr_block = "10.1.2.0/24"

  tags = {
    Name = "my-subnet-public-02"
  }
}

resource "aws_internet_gateway" "my-igw" {
  vpc_id = aws_vpc.my-vpc.id

  tags = {
    Name = "my-igw"
  }
}

resource "aws_route_table" "my-public-rt" {
  vpc_id = aws_vpc.my-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my-igw.id
  }

  tags = {
    Name = "my-public-rt"
  }
}

resource "aws_route_table_association" "my-rta-public-subnet-01" {
  subnet_id      = aws_subnet.my-subnet-public-01.id
  route_table_id = aws_route_table.my-public-rt.id
}
resource "aws_route_table_association" "my-rta-public-subnet-02" {
  subnet_id      = aws_subnet.my-subnet-public-02.id
  route_table_id = aws_route_table.my-public-rt.id
}


