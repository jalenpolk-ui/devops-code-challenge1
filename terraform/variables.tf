##############################################
# AWS Configuration
##############################################

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

##############################################
# Project Configuration
##############################################

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "devops-challenge"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "production"
}

##############################################
# Networking
##############################################

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

##############################################
# Container Ports
##############################################

variable "frontend_port" {
  description = "Frontend container port"
  type        = number
  default     = 3000
}

variable "backend_port" {
  description = "Backend container port"
  type        = number
  default     = 8080
}

##############################################
# Container Images
##############################################

variable "frontend_image" {
  description = "Frontend ECR image URI"
  type        = string
  default     = ""
}

variable "backend_image" {
  description = "Backend ECR image URI"
  type        = string
  default     = ""
}

##############################################
# ECS Task Resources
##############################################

variable "frontend_cpu" {
  description = "CPU units for frontend task"
  type        = number
  default     = 512
}

variable "frontend_memory" {
  description = "Memory (MiB) for frontend task"
  type        = number
  default     = 1024
}

variable "backend_cpu" {
  description = "CPU units for backend task"
  type        = number
  default     = 512
}

variable "backend_memory" {
  description = "Memory (MiB) for backend task"
  type        = number
  default     = 1024
}

##############################################
# ECS Service Scaling
##############################################

variable "min_tasks" {
  description = "Minimum number of ECS tasks"
  type        = number
  default     = 1
}

variable "desired_tasks" {
  description = "Desired number of ECS tasks"
  type        = number
  default     = 1
}

variable "max_tasks" {
  description = "Maximum number of ECS tasks"
  type        = number
  default     = 4
}

variable "cpu_threshold" {
  description = "Target CPU utilization percentage"
  type        = number
  default     = 50
}

##############################################
# Jenkins
##############################################

variable "jenkins_instance_type" {
  description = "EC2 instance type for Jenkins"
  type        = string
  default     = "t3.small"
}

variable "jenkins_key_name" {
  description = "Existing EC2 Key Pair name"
  type        = string
  default     = "project-key"
}

variable "jenkins_volume_size" {
  description = "Root EBS volume size (GiB)"
  type        = number
  default     = 30
}

##############################################
# Security
##############################################

variable "allowed_admin_cidr" {
  description = "Public IP (CIDR notation) allowed to access Jenkins"
  type        = string

  # Replace with your public IP before production
  default = "0.0.0.0/0"
}
