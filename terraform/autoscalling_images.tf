# Create a Target Group for Images
resource "aws_lb_target_group" "images-tg" {
  name        = "images-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.my_vpc.id

  health_check {
    path                = "/images/index.html"
    protocol            = "HTTP"
    port                = "traffic-port"
    interval            = 30
    timeout             = 10
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}

# Create an Auto Scaling Group
resource "aws_autoscaling_group" "images" {
  name                 = "images"
  desired_capacity     = 1
  min_size             = 1
  max_size             = 2
  vpc_zone_identifier  = [
    aws_subnet.private_subnet_1.id,
    aws_subnet.private_subnet_2.id
  ]

  launch_configuration = aws_launch_configuration.images_lc.name

  target_group_arns = [
    aws_lb_target_group.images-tg.arn
  ]

  tag {
    key                 = "Name"
    value               = "www_images"
    propagate_at_launch = true
  }
}

# Create a Launch Configuration
resource "aws_launch_configuration" "images_lc" {
  name          = "images-lc"
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
    mkdir /var/www/html/images
    echo "<!DOCTYPE html><html><head><title>Image Portal</title><style>body{font-family:Arial,sans-serif;text-align:center}h1{color:#0066cc}.image{display:inline-block;margin:10px}.image img{width:200px;height:auto}</style></head><body><h1>Welcome to the Image Portal</h1><div class=\"image\"><img src=\"https://americandeposits.com/wp-content/uploads/what-is-fintech-square.jpg\" alt=\"Image 1\"></div><div class=\"image\"><img src=\"https://img.etimg.com/thumb/width-420,height-315,imgsize-886390,resizemode-75,msid-98570721/tech/startups/as-silicon-valley-bank-crash-hits-home-investors-fintechs-help-cash-crunched-indian-startups/fintech-firms.jpg\" alt=\"Image 2\"></div><div class=\"image\"><img src=\"https://thefinancialtechnologyreport.com/wp-content/uploads/2021/06/fintech.jpg\" alt=\"Image 3\"></div></body></html>" > /var/www/html/images/index.html
    
  EOF
}
