##############################################
# Latest Amazon Linux 2023 AMI
##############################################

data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-kernel-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

##############################################
# Jenkins Master EC2 Instance
##############################################

resource "aws_instance" "jenkins_master" {
  ami           = data.aws_ami.amazon_linux_2023.id
  instance_type = var.jenkins_instance_type
  key_name      = var.jenkins_key_name

  subnet_id                   = aws_subnet.public[0].id
  vpc_security_group_ids      = [aws_security_group.jenkins.id]
  associate_public_ip_address = true

  user_data = <<-EOF
    #!/bin/bash
    set -eux

    dnf update -y

    # Install Java, Git, Docker, and other utilities
    dnf install -y \
      java-17-amazon-corretto \
      git \
      docker \
      wget

    # Add Jenkins repository and key
    wget -O /etc/yum.repos.d/jenkins.repo \
      https://pkg.jenkins.io/redhat-stable/jenkins.repo

    rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key

    # Install Jenkins
    dnf install -y jenkins

    # Start and enable Docker
    systemctl enable docker
    systemctl start docker

    # Allow Jenkins to execute Docker commands
    usermod -aG docker jenkins

    # Start and enable Jenkins
    systemctl enable jenkins
    systemctl start jenkins
  EOF

  user_data_replace_on_change = true

  root_block_device {
    volume_size = var.jenkins_volume_size
    volume_type = "gp3"
    encrypted   = true
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  tags = {
    Name        = "${var.project_name}-jenkins-master"
    Environment = var.environment
    Project     = var.project_name
  }

  depends_on = [aws_internet_gateway.main]
}

##############################################
# Elastic IP for Jenkins Master
##############################################

resource "aws_eip" "jenkins_master" {
  domain = "vpc"

  tags = {
    Name        = "${var.project_name}-jenkins-master-eip"
    Environment = var.environment
  }
}

##############################################
# Associate Elastic IP with Jenkins
##############################################

resource "aws_eip_association" "jenkins_master" {
  instance_id   = aws_instance.jenkins_master.id
  allocation_id = aws_eip.jenkins_master.id
}
