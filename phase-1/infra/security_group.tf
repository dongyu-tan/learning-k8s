resource "aws_security_group" "allow_all" {
  name        = "allow_all_traffic"
  description = "Temporary allow all traffic security group"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Ingress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = "0.0.0.0/0"
  }

  egress {
    description = "Egress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = "0.0.0.0/0"
  }
}
