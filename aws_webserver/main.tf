provider "aws" {
  region = var.region
  shared_credentials_files = ["/etc/.aws/credentials"]
  profile = "default"
}

resource "aws_key_pair" "webserver-kp" {
  key_name   = "{var.name}-kp"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_security_group" "webserver-sg" {
  name = "{var.name}-sg"
}

resource "aws_instance" "webserver" {
  ami           = var.ami
  instance_type = var.instance_type
  key_name = "{var.name}-kp"

  tags = {
    Name = var.name
  }

  vpc_security_group_ids = [aws_security_group.webserver-sg.id]
  user_data = file("web.sh")
}

resource "aws_security_group_rule" "allow_all_outbound" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.webserver-sg.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow_ssh_inbound" {
  type              = "ingress"
  from_port         = "22"
  to_port           = "22"
  protocol          = "TCP"
  security_group_id = aws_security_group.webserver-sg.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow_http_inbound" {
  type              = "ingress"
  from_port         = "80"
  to_port           = "80"
  protocol          = "TCP"
  security_group_id = aws_security_group.webserver-sg.id
  cidr_blocks       = ["0.0.0.0/0"]
}
