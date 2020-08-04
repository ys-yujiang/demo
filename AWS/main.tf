provider "aws" {
    region="us-east-1"
}

variable "instance_type" {
  description = "AWS instance type"
  default     = "t2.micro"
}

variable "department" {
  description = "Department tag"
}

resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.example.id
  instance_id = aws_instance.web.id
}

resource "aws_instance" "web" {
  ami               = "ami-21f78e11"
  availability_zone = "us-east-1"
  instance_type     = "t1.micro"

  tags = {
    Name = "HelloWorld"
  }
}

resource "aws_ebs_volume" "example" {
  availability_zone = "us-east-1"
  size              = 1
}

resource "aws_network_interface" "test" {
  subnet_id       = "${aws_subnet.public_a.id}"
  private_ips     = ["10.0.0.50"]
  security_groups = ["${aws_security_group.web.id}"]

  attachment {
    instance     = "${aws_instance.test.id}"
    device_index = 1
  }
}

#resource "aws_instance" "machine2" {
#    ami           = "ami-04b9e92b5572fa0d1"
#    instance_type = "t2.micro"
#    availability_zone = "us-east-1b" 
#    adding commit

#
#}
