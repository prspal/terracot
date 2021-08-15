provider "aws" {
    region = "eu-central-1"
    access_key = var.ACCESS_KEY
    secret_key = var.SECRET_KEY
}

variable "ACCESS_KEY" {
  type = string
  default = ""
  description = "AWS accesskey as defined by Environment var TF_VAR_ACCESS_KEY"
}

variable "SECRET_KEY" {
    type = string
    default = ""
    description = "AWS secret as defined by Environment var TF_VAR_SECRET_KEY"
}

# output "PrintVar" {
#      value = "${data.aws_ami.latest-ubuntu.description}\n${var.ACCESS_KEY}\n${var.SECRET_KEY}"
#  }

data "aws_ami" "latest-ubuntu" {
    most_recent = true
    owners = ["099720109477",] # Canonical

    filter {
        name   = "name"
        values = ["*ubuntu-*-amd64-server-*"]
    }

    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }
}


resource "aws_instance" "my_first_instance" {
    ami           = "${data.aws_ami.latest-ubuntu.id}"
    instance_type = "t3.micro"

    tags = {
       Name = split("/", "${data.aws_ami.latest-ubuntu.name}")[0]
    }
}
