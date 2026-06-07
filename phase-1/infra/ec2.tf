# resource "aws_eip" "app" {
#   domain = "vpc"
#
#   lifecycle {
#     prevent_destroy = true
#   }
# }
#
# resource "aws_eip_association" "app" {
#   instance_id   = aws_instance.app.id
#   allocation_id = aws_eip.app.id
# }

resource "aws_instance" "app" {
  # the ami must use t3.nano at least
  ami = "ami-0367763820bb4f68b"
  # ami                    = "ami-091138d0f0d41ff90"
  instance_type          = "t3.nano"
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name
  subnet_id              = aws_subnet.public_subnet_1.id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  key_name               = "learn-infra"
  # key_name = "learn-infra-us-east-1"

  tags = {
    Name = "fastapi-app"
  }
}

