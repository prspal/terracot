resource "aws_vpc" "vpc0" {
  cidr_block = "10.0.0.0/16"

  tags = {
    "Name" = "VPC0"
  }

}

resource "aws_subnet" "subnet1" {
  vpc_id     = aws_vpc.vpc0.id
  cidr_block = "10.0.1.0/24"
  availability_zone = var.REGION

  tags = {
    "Name" = "VPC0-SUBNET0"
  }

}

resource "aws_subnet" "subnet2" {
  vpc_id            = aws_vpc.vpc0.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = var.REGION

  tags = {
    "Name" = "VPC0-SUBNET1"
  }
}


##. Create Internet Gateway
resource "aws_internet_gateway" "vpc0_gw" {
  vpc_id = aws_vpc.vpc0.id

  tags = {
    "Name" = "TF_Gateway"
  }

}

##
resource "aws_route_table" "vpc0_route_table" {
  vpc_id = aws_vpc.vpc0.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vpc0_gw.id
  }
  route {
    ipv6_cidr_block        = "::/0"
    gateway_id = aws_internet_gateway.vpc0_gw.id
  }

  tags = {
    "Name" = "VPC0_Route_Table"
  }

}

##Associate Subnet1 with Subnet1 via route table
resource "aws_route_table_association" "route_link" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.vpc0_route_table.id
}

##Create Security group to port 22,80,443
resource "aws_security_group" "open_ports" {
  name        = "allow_ssh"
  description = "Allow all ssh/http/https traffic"
  vpc_id      = aws_vpc.vpc0.id

  ingress {
    ##allow all IPs
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH ports"
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
  }
  ingress {
    ##allow all IPs
    cidr_blocks = ["0.0.0.0/0"]
    description = "Web ports "
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
  }
  ingress {
    ##allow all IPs
    cidr_blocks = ["0.0.0.0/0"]
    description = "Web ports "
    from_port   = 443
    protocol    = "tcp"
    to_port     = 443
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name" = "sec_ports"
  }

}


##Create an ethernet interface
resource "aws_network_interface" "terra_net0" {
  subnet_id       = aws_subnet.subnet1.id
  private_ips     = ["10.0.1.10" ]
  security_groups = [aws_security_group.open_ports.id]
}

##Assign elastic IP
resource "aws_eip" "public_ip0" {
  vpc                       = true
  network_interface         = aws_network_interface.terra_net0.id
  associate_with_private_ip = aws_network_interface.terra_net0.private_ip
  depends_on = [
    aws_internet_gateway.vpc0_gw
  ]

}