provider "aws" {
  region     = "eu-central-1"
  access_key = var.ACCESS_KEY
  secret_key = var.SECRET_KEY
}

# output "PrintVar" {
#      value = "${data.aws_ami.latest-ubuntu.description}\n${var.ACCESS_KEY}\n${var.SECRET_KEY}"
#  }

data "aws_ami" "latest-ubuntu" {
  most_recent = true
  owners      = ["099720109477", ] # Canonical

  filter {
    name   = "name"
    values = ["*ubuntu-hirsute-21.04-amd64-server*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_key_pair" "deployer" {
  key_name   = "aws-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAx/vAbSzftC99lSx/Eg4Tbew97KolcgMHf/uUAzZ4XQoN2/I6cKLWr8iZkY07FyZBYyigWuMSDx1LHwY3gEr/dA7nn9b/cQGHRLiT58/s4V5bhENDmEzS/zig0VjcOB2K4mwTLGc1tnw9KZ6cmBlXL4swcXFgaxpk5wEkb+K+gVt8Kdua+i2IZ0wRYh6gw15XcT0CWUVsPnqXDxIRlfjzmA0wo0+25DOiVbkfa79qbUNJpkLyf/DLD/vNtgJf0ttp7IP7DxP/UgcQ3Wz9SWOq2J221VON3ozA1/spRUfukgYwtyuyBNZS1tyNAtE71tATPs3Saw4SPoe1t+qz9gOlIw== rsa-key-20210815"
}

resource "aws_instance" "my_first_instance" {
  ami               = data.aws_ami.latest-ubuntu.id
  # ami               = "ami-0e4edb3648cd12c6b"
  instance_type     = "t3.micro"
  availability_zone = var.REGION

  key_name = aws_key_pair.deployer.key_name
  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.terra_net0.id
  }

  user_data = <<-EOF
            #!/bin/bash
            sudo apt update -y
            sudo apt install apache2 -y
            sudo systemctl start apache2
            sudo bash -c 'echo my terraformed web server > /var/www/html/index.html'
            EOF

  tags = {
    Name = split("/", "${data.aws_ami.latest-ubuntu.name}")[0]
    Name = "TerraWebServer"
  }

  depends_on = [
    aws_key_pair.deployer
  ]
}


