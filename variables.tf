variable "region" {
  description = "The region in which the resources will be deployed"
  default     = "ap-south-1"
  type = string
}

variable "security_group_name" {
  description = "The name of the security group"
  default     = "APP_SG"
  type = string
}

variable "ami" {
  description = "The AMI ID for the instance"
  default     = "ami-023a307f3d27ea427"
  type = string 
}

variable "key_name" {
  description = "The key pair name to use for the instance"
  default     = "Santhu"
  type = string
}
