# Networking Variables
variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "az_1" {
  description = "Availability Zone 1"
  type        = string
  default     = "us-east-1a"
}

variable "az_2" {
  description = "Availability Zone 2"
  type        = string
  default     = "us-east-1b"
}

variable "cidr_block" {
  description = "CIDR block for the network"
  type        = string
  default     = "10.0.0.0/16"
}

variable "pub_subnet_1" {
  description = "CIDR block for Public Subnet 1"
  type        = string
  default     = "10.0.1.0/24"
}

variable "pub_subnet_2" {
  description = "CIDR block for Public Subnet 2"
  type        = string
  default     = "10.0.2.0/24"
}

variable "priv_subnet_1" {
  description = "CIDR block for Private Subnet 1"
  type        = string
  default     = "10.0.3.0/24"
}

variable "priv_subnet_2" {
  description = "CIDR block for Private Subnet 2"
  type        = string
  default     = "10.0.4.0/24"
}

# Ec2 Variables

variable "key_name" {
  description = "Name of the key"
  type        = string
  default     = "garnet_key"
}

variable "instance_type" {
  description = "ASG Instance type"
  type        = string
  default     = "t2.micro"
}