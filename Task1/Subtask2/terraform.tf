provider "aws" {
region     = "ap-south-1"
}


# ---  Create a VPC ------


resource "aws_vpc" "rkp1" {
  cidr_block       = "10.10.0.0/16"
  tags = {
    Name = "rkp1"
  }
}



#--- Create Internet Gateway 


resource "aws_internet_gateway" "rkp1_igw" {
 vpc_id = "${aws_vpc.rkp1.id}"
 tags = {
    Name = "rkp1-igw"
 }
}


# - Create Elastic IP


resource "aws_eip" "eip" {
  vpc=true
}

# -- Create Subnet 


data "aws_availability_zones" "azs" {
  state = "available"
}



        #  create public subnet

         
resource "aws_subnet" "public-subnet-1a" {
  availability_zone = "${data.aws_availability_zones.azs.names[0]}"
  cidr_block        = "10.10.20.0/24"
  vpc_id            = "${aws_vpc.rkp1.id}"
  map_public_ip_on_launch = "true"
  tags = {
   Name = "public-subnet-1a"
   }
}

resource "aws_subnet" "public-subnet-1b" {
  availability_zone = "${data.aws_availability_zones.azs.names[1]}"
  cidr_block        = "10.10.21.0/24"
  vpc_id            = "${aws_vpc.rkp1.id}"
  map_public_ip_on_launch = "true"
  tags = {
   Name = "public-subnet-1b"
   }
}


        #  Create private subnet


resource "aws_subnet" "private-subnet-1a" {
  availability_zone = "${data.aws_availability_zones.azs.names[0]}"
  cidr_block        = "10.10.30.0/24"
  vpc_id            = "${aws_vpc.rkp1.id}"
  tags = {
   Name = "private-subnet-1a"
   }
}


resource "aws_subnet" "private-subnet-1b" {
  availability_zone = "${data.aws_availability_zones.azs.names[1]}"
  cidr_block        = "10.10.31.0/24"
  vpc_id            = "${aws_vpc.rkp1.id}"
  tags = {
   Name = "private-subnet-1b"
   }
}





# --------------  NAT Gateway

resource "aws_nat_gateway" "rkp1-ngw" {
  allocation_id = "${aws_eip.eip.id}"
  subnet_id = "${aws_subnet.public-subnet-1b.id}"
  tags = {
      Name = "rkp1 Nat Gateway"
  }
}




# ------------------- Routing ----------


resource "aws_route_table" "rkp1-public-route" {
  vpc_id =  "${aws_vpc.rkp1.id}"
  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = "${aws_internet_gateway.rkp1_igw.id}"
  }

   tags = {
       Name = "rkp1-public-route"
   }
}


resource "aws_default_route_table" "rkp1-default-route" {
  default_route_table_id = "${aws_vpc.rkp1.default_route_table_id}"
  tags = {
      Name = "rkp1-default-route"
  }
}



#--- Subnet Association -----

resource "aws_route_table_association" "arts1a" {
  subnet_id = "${aws_subnet.public-subnet-1a.id}"
  route_table_id = "${aws_route_table.rkp1-public-route.id}"
}


resource "aws_route_table_association" "arts1b" {
  subnet_id = "${aws_subnet.public-subnet-1b.id}"
  route_table_id = "${aws_route_table.rkp1-public-route.id}"
}


resource "aws_route_table_association" "arts-p-1a" {
  subnet_id = "${aws_subnet.private-subnet-1a.id}"
  route_table_id = "${aws_vpc.rkp1.default_route_table_id}"
}

resource "aws_route_table_association" "arts-p-1b" {
  subnet_id = "${aws_subnet.private-subnet-1b.id}"
  route_table_id = "${aws_vpc.rkp1.default_route_table_id}"
}