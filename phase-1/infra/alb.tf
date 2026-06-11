# resource "aws_iam_policy" "alb_controller" {
#   name   = "AWSLoadBalancerControllerIAMPolicy"
#   policy = file("${path.module}/iam-policy.json")
# }
#
module "alb_controller_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name = "alb-controller"

  attach_load_balancer_controller_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }
}

# resource "aws_alb" "application-lb" {
#   name               = "test-alb"
#   internal           = false
#   load_balancer_type = "application"
#   security_groups    = [aws_security_group.ec2_sg.id]
#   subnets = [
#     aws_subnet.public_subnet_1.id,
#     aws_subnet.public_subnet_2.id
#   ]
#   tags = {
#     Name = "test-alb"
#   }
# }
