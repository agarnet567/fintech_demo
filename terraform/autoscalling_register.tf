# Create a Target Group
resource "aws_lb_target_group" "register-tg" {
  name        = "register-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.my_vpc.id

  health_check {
    path                = "/register/index.html"
    protocol            = "HTTP"
    port                = "traffic-port"
    interval            = 10
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

# Create an Auto Scaling Group
resource "aws_autoscaling_group" "register" {
  name                 = "register"
  desired_capacity     = 1
  min_size             = 1
  max_size             = 2
  vpc_zone_identifier  = [
    aws_subnet.private_subnet_1.id,
    aws_subnet.private_subnet_2.id
  ]

  launch_configuration = aws_launch_configuration.register_lc.name

  target_group_arns = [
    aws_lb_target_group.register-tg.arn
  ]

  tag {
    key                 = "Name"
    value               = "www_register"
    propagate_at_launch = true
  }
}

# Create a Launch Configuration
resource "aws_launch_configuration" "register_lc" {
  name          = "register-lc"
  image_id      = data.aws_ami.amazon_linux.id 
  instance_type = "t2.micro"
  key_name      = "garnet_key"

  security_groups = [aws_security_group.asg_www_security_group.id]
  
  user_data = <<-EOF
    #!/bin/bash
    yum update -y                           # Update all packages
    yum install -y yum-cron                 # Install yum-cron for automatic updates

    # Configure automatic security updates
    sed -i 's/update_cmd = default/update_cmd = security/g' /etc/yum/yum-cron.conf
    service yum-cron start
    chkconfig yum-cron on


    # Configure SSH hardening
    sed -i 's/#PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
    service sshd restart

    # Configure password policies
    sed -i 's/PASS_MAX_DAYS.*$/PASS_MAX_DAYS   90/g' /etc/login.defs
    sed -i 's/PASS_MIN_DAYS.*$/PASS_MIN_DAYS   1/g' /etc/login.defs
    sed -i 's/PASS_WARN_AGE.*$/PASS_WARN_AGE   7/g' /etc/login.defs

    # Install and configure httpd
    yum install httpd -y
    service httpd start
    chkconfig httpd on
    mkdir /var/www/html/register
    echo "<!DOCTYPE html><html><head><title>Fintech Startup</title><style>body { font-family: Arial, sans-serif; background-color: #f2f2f2; text-align: center; } h1 { color: #0066cc; } p { color: #333333; }</style></head><body><h1>Welcome to Our Fintech Startup!</h1><p>We are dedicated to providing innovative financial solutions to our customers. With our cutting-edge technology and expert team, we aim to transform the way people manage their finances.</p></body></html>" > /var/www/html/register/index.html
    
  EOF
}
