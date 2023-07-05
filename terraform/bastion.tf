# Fetch the latest Amazon Linux AMI ID
data "aws_ami" "amazon_linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
}

# Create a security group for the bastion host
resource "aws_security_group" "bastion_security_group" {
  name        = "bastion-security-group"
  description = "Security group for the bastion host"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "bastion-security-group"
  }
}

# Create an EC2 instance for the bastion host
resource "aws_instance" "bastion_host" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  key_name      = var.key_name

  vpc_security_group_ids = [aws_security_group.bastion_security_group.id]
  subnet_id              = aws_subnet.public_subnet_1.id
  associate_public_ip_address = true

  tags = {
    Name = "bastion-host"
  }

  user_data = <<-EOF
    #!/bin/bash
    yum update -y                           # Update all packages
    yum install -y yum-cron                 # Install yum-cron for automatic updates

    # Configure automatic security updates
    sed -i 's/update_cmd = default/update_cmd = security/g' /etc/yum/yum-cron.conf
    service yum-cron start
    chkconfig yum-cron on

    # Disable unused services
    service rpcbind stop
    chkconfig rpcbind off
    service nfslock stop
    chkconfig nfslock off
    service autofs stop
    chkconfig autofs off

    # Configure SSH hardening
    sed -i 's/#PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
    service sshd restart

    # Configure password policies
    sed -i 's/PASS_MAX_DAYS.*$/PASS_MAX_DAYS   90/g' /etc/login.defs
    sed -i 's/PASS_MIN_DAYS.*$/PASS_MIN_DAYS   1/g' /etc/login.defs
    sed -i 's/PASS_WARN_AGE.*$/PASS_WARN_AGE   7/g' /etc/login.defs

    # Enable auditing
    sed -i 's/active.*$/active = yes/g' /etc/audit/auditd.conf
    service auditd restart
    chkconfig auditd on

    # Enable and configure log rotation
    sed -i 's/weekly/daily/g' /etc/logrotate.conf
    sed -i 's/rotate 4/rotate 30/g' /etc/logrotate.conf
  EOF
}
