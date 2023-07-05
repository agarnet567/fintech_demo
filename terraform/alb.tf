# Create an ALB security group
resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  description = "ALB security group"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create an ALB
resource "aws_lb" "my_alb" {
  name               = "my-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [
    aws_subnet.public_subnet_1.id,
    aws_subnet.public_subnet_2.id
  ]

  tags = {
    Name = "my-alb"
  }
}

# Create an ALB listener
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.my_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.register-tg.arn
  }
}

resource "aws_lb_listener_rule" "register" {
  listener_arn = aws_lb_listener.http_listener.arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.register-tg.arn
  }

  condition {
    path_pattern {
      values = ["/register*"]
    }
  }
}

resource "aws_lb_listener_rule" "images" {
  listener_arn = aws_lb_listener.http_listener.arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.images-tg.arn
  }

  condition {
    path_pattern {
      values = ["/images*"]
    }
  }
}
