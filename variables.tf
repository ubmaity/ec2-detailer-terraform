variable "region" {
  description = "The AWS region to create the resources in"
  type        = string
}

variable "ami_id" {
  description = "The AMI ID of the instance to launch"
  type        = string
}

variable "instance_type" {
  description = "The instance type to launch"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "The name of the key pair to use for SSH access"
  type        = string
}

variable "subnet_id" {
  description = "The ID of the subnet to launch the instance in"
  type        = string
}

variable "lb_subnet_ids" {
  description = "The ID of the subnets of loadbalancer the instance in"
  type        = list(string)
}

variable "security_group_ids" {
  description = "The IDs of the security groups to attach to the instance"
  type        = list(string)
}

variable "private_key_path" {
  description = "Path to the private key used to connect to the EC2 instance."
  type        = string
}

variable "local_code_path" {
  description = "Path of the ec2 detailer codebase"
  type        = string
}

variable "app_name" {
  description = "name of the ec2 detailer directory"
  type        = string
}

variable "vpc_id" {
    description = "select the vpc where you want to configure ec2s"
    type = string
}

variable "email_alerts" {
    description = "select the vpc where you want to configure ec2s"
    type = string
}