# resource "aws_security_group" "allow_all" {
#   name        = "allow_all_traffic"
#   description = "Temporary allow all traffic security group"
#   vpc_id      = aws_vpc.main.id
#
#   ingress {
#     description = "Ingress"
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#
#   egress {
#     description = "Egress"
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }
#
# resource "aws_security_group" "alb_sg" {
#   name   = "alb-security-group"
#   vpc_id = aws_vpc.main.id
#
#   ingress {
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"] # Anyone can hit ALB on HTTP
#   }
#
#   egress {
#     description = "Egress"
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }

resource "aws_security_group" "ec2_sg" {
  name   = "ec2-security-group"
  vpc_id = aws_vpc.main.id

  ingress {
    description = "FastAPI port"
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Only allow traffic from ALB
  }

  ingress {
    description = "FastAPI"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # Only allow traffic from ALB
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # Allow outbound internet via NAT 
  }
}
