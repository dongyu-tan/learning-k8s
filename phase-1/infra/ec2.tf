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

output "ec2_public_ip" {
  value = aws_instance.app.public_ip
}
