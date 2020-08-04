provider "aws" {
    region="us-east-1"
}

variable "instance_type" {
  description = "AWS instance type"
  default     = "t2.nano"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "main" {
  availability_zone = "us-east-1a"
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.0.0/24"
  tags = {
    Name = "Main"
  }
}

resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}

resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.volume1.id
  instance_id = aws_instance.machine1.id
}
resource "aws_ebs_volume" "volume1" {
  availability_zone = "us-east-1a"
  size              = 1
}

resource "aws_network_interface_attachment" "net_att" {
  instance_id          = aws_instance.machine1.id
  network_interface_id = aws_network_interface.network1.id
  device_index         = 1
}

resource "aws_network_interface" "network1" {
  subnet_id       = aws_subnet.main.id
  private_ips     = ["10.0.0.15"]
  security_groups = [aws_security_group.allow_tls.id]
}

resource "aws_instance" "machine1" {
    ami           = "ami-04b9e92b5572fa0d1"
    instance_type = "t2.micro"
    availability_zone = "us-east-1a"
    subnet_id = aws_subnet.main.id
}
