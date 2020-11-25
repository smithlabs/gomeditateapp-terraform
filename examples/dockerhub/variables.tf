# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters have reasonable defaults
# ---------------------------------------------------------------------------------------------------------------------

variable "domain_name" {
  description = "The domain name you have in Route53"
  type        = string
  default     = "gomeditateapp.com"
}
variable "name" {
  description = "The name of the ASG and all its resources"
  type        = string
  default     = "gma-dockerhub-example"
}

variable "environment" {
  description = "The environment name of the ASG and all its resources"
  type        = string
  default     = "test"
}

variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type        = number
  default     = 8080
}
