# variables.tf

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