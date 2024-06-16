variable "AWS_REGION" {
  default = "ap-south-1"
}

variable "public_ssh_key" {}
variable "VPC_ID" {}

variable "VPC_PUBLIC_SUBNETS" {
  type = list(string)
}