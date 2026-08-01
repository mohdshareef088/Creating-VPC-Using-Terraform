resource "aws_vpc" "mytestvpc" {
  cidr_block = var.cidr
}

resource "aws_subnet" "sub1" {
  vpc_id     = aws_vpc.mytestvpc.id
  cidr_block = "10.0.0.0/24"
  availability_zone   = "ap-south-1a"
  map_public_ip_on_launch = "true"
  }
resource "aws_subnet" "sub2" {
  vpc_id     = aws_vpc.mytestvpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone   = "ap-south-1b"
  map_public_ip_on_launch = "true"
  }

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.mytestvpc.id
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.mytestvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
 }
}
resource "aws_route_table_association" "rtas1" {
  subnet_id      = aws_subnet.sub1.id
  route_table_id = aws_route_table.rt.id
}
resource "aws_route_table_association" "rtas2" {
  subnet_id      = aws_subnet.sub2.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_security_group" "mysg" {
  vpc_id = aws_vpc.mytestvpc.id

  ingress {
    protocol  = "tcp"
    from_port = 80
    to_port   = 80
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    protocol  = "tcp"
    from_port = 22
    to_port   = 22
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_s3_bucket" "example" {
  bucket = "testing-4-vpc"
}

terraform {
  backend "s3" {
    bucket = "testing-4-vpc"
    key    = "terraform/state.tfstate"
    region = "ap-south-1"
  }
}

resource "aws_instance" "vpc-webserver" {
  ami           = "ami-01a00762f46d584a1"
  instance_type = "t3.micro"
  vpc_security_group_ids = [aws_security_group.mysg.id]
  subnet_id =    aws_subnet.sub1.id
  user_data_base64 = base64encode(file("userdata.sh"))
}
resource "aws_instance" "vpc-webserver2" {
  ami           = "ami-01a00762f46d584a1"
  instance_type = "t3.micro"
  vpc_security_group_ids = [aws_security_group.mysg.id]
  subnet_id =  aws_subnet.sub2.id
  user_data_base64 = base64encode(file("userdata2.sh"))
}
resource "aws_lb" "test-lb-tf" {
  name               = "test-lb-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.mysg.id]
  subnets            = [aws_subnet.sub1.id,aws_subnet.sub2.id]

  tags = {
    Environment = "production"
  }
}
resource "aws_lb_target_group" "test-tg" {
  name     = "test-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.mytestvpc.id
}

resource "aws_lb_target_group_attachment" "test-tg-attach" {
  target_group_arn = aws_lb_target_group.test-tg.arn
  target_id        = aws_instance.vpc-webserver.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "test-tg-attach1" {
  target_group_arn = aws_lb_target_group.test-tg.arn
  target_id        = aws_instance.vpc-webserver2.id
  port             = 80
}

resource "aws_lb_listener" "listener" {
 load_balancer_arn = aws_lb.test-lb-tf.arn
 port = 80
 protocol = "HTTP"
 default_action {
   target_group_arn = aws_lb_target_group.test-tg.arn
   type = "forward"
 }
}
