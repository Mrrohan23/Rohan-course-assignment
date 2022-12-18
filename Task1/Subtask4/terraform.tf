provider "aws" {
region     = "ap-south-1"
}

# Create 3 ec2 instancce bastion,jenkins,app
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


# Create key pair for this instance 

resource "aws_key_pair" "TF_key" {
  key_name   = "TF_key"
  public_key = tls_private_key.rsa.public_key_openssh
}

resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "TF-key" {
    content  = tls_private_key.rsa.private_key_pem
    filename = "tfkey"
}