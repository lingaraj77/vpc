resource "aws_vpc" "nmain" {
    cidr_block = "10.0.0.0/16"
  tags ={
    Name = "Roboshop"
    Environment = "DEV"
    terraform = "true"
  }
}

resource "aws_subnet" "public" {
    vpc_id = aws_vpc.nmain.id
    cidr_block = "10.0.1.0/24"
  tags = {
    Name = "Roboshop-Public"
  }
}

resource "aws_subnet" "private" {
    vpc_id = aws_vpc.nmain.id
    cidr_block = "10.0.2.0/24"
  tags = {
    Name = "Roboshop-Private"
  }
}

resource "aws_internet_gateway" "gw" {

    vpc_id = aws_vpc.nmain.id
    tags = {
      Name = "Roboshop"
    }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.nmain.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "roboshop-public"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.nmain.id

  tags = {
    Name = "roboshop-private"
  }
}
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

resource "aws_security_group" "allow_http_ssh" {
  name        = "allow_http_ssh"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.nmain.id

  ingress {
    description      = "HTTPS from internet"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "SSH from My Laptop"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["50.172.27.242/32"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_http_ssh"
  }
}

resource "aws_instance" "web" {
    ami = "ami-03265a0778a880afb"
    instance_type = "t2.micro"
    subnet_id = aws_subnet.public.id
    vpc_security_group_ids = [aws_security_group.allow_http_ssh.id]
    associate_public_ip_address = "true"
    tags = {
      Name = "web"
    }
  
}