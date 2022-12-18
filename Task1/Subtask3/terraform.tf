provider "aws" {
region     = "ap-south-1"
}

data "http" "myip" {
          url = "http://ipv4.icanhazip.com"
      }



resource "aws_instance" "bastion" {
  ami           = "ami-07ffb2f4d65357b42"       #Amazon Linux AMI
  instance_type = "t2.micro"
  security_groups = [aws_security_group.Bastion_host_SG.name]

  tags = {
    Name = "bastion"
  }
}

resource "aws_instance" "Jenkins" {
  ami           = "ami-07ffb2f4d65357b42"       #Amazon Linux AMI
  instance_type = "t2.micro"
  security_groups = [aws_security_group.Private_Instances_SG.name]

  tags = {
    Name = "Jenkins"
  }
}



resource "aws_instance" "app" {
  ami           = "ami-07ffb2f4d65357b42"       #Amazon Linux AMI
  instance_type = "t2.micro"
  security_groups = [aws_security_group.Public_Web_SG.name]

  tags = {
    Name = "app"
  }
}

#securitygroup using Terraform

resource "aws_security_group" "Bastion_host_SG" {
  name        = "Bastion_host_SG"
  description = "security group using Terraform"
  vpc_id      = "vpc-0bf65b26d3e0e03d0"

  ingress {
    description      = "TCP"
    from_port        = 22
    to_port          = 22
    protocol         = "TCP"
    cidr_blocks = ["${chomp(data.http.myip.body)}/32"]
    ipv6_cidr_blocks = ["::/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "Bastion_host_SG"
  }
}



resource "aws_security_group" "Private_Instances_SG" {
  name        = "Private_Instances_SG"
  description = "security group using Terraform"
  vpc_id      = "vpc-0bf65b26d3e0e03d0"

  ingress {
    description      = "TCP"
    from_port        = 22
    to_port          = 22
    protocol         = "SSH"
    cidr_blocks =["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "Private_Instances_SG"
  }
}


resource "aws_security_group" "Public_Web_SG" {
  name        = "Public_Web_SG"
  description = "security group using Terraform"
  vpc_id      = "vpc-0bf65b26d3e0e03d0"

  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "HTTP"
    cidr_blocks = ["${chomp(data.http.myip.body)}/32"]
    ipv6_cidr_blocks = ["::/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "Public_Web_SG"
  }
}
