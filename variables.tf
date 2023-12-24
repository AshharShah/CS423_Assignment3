variable "aws_reg"{
  description = "Region for the AWS Server"
  default     = "us-east-1"
}

variable "vpc_cidr_block" {
  description = "Details for the VPC"
  type    = list(string)
  default     = ["11.0.0.0/16", "devops-assignment-4"]
}

variable "public_sub_1" {
  description = "Details for the first public subnet"
  type    = list(string)
  default     = ["11.0.1.0/24", "us-east-1a", "cs423-devops-public-1"]
}

variable "public_sub_2" {
  description = "Details for the second public subnet"
  type    = list(string)
  default     = ["11.0.2.0/24", "us-east-1b", "cs423-devops-public-2"]
}

variable "private_sub_1" {
  description = "Details for the first private subnet"
  type    = list(string)
  default     = ["11.0.3.0/24", "us-east-1a", "cs423-devops-private-1"]
}

variable "private_sub_2" {
  description = "Details for the second private subnet"
  type    = list(string)
  default     = ["11.0.4.0/24", "us-east-1b", "cs423-devops-private-2"]
}