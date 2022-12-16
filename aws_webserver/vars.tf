variable "region" {
  description = "Region of AWS Account."
  default     = "ap-south-1"
}

variable "ami" {
  description = "AMI for AWS Instance."
  default     = "ami-03d3eec31be6ef6f9"
}

variable "instance_type" {
  description = "Default Instance Type"
  default = "t2.micro"
}

variable "name" {
  description = "The name for the EC2 Instance and all other resources in this module."
  default     = "webserver"
}
