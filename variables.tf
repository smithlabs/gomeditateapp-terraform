# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters have reasonable defaults
# ---------------------------------------------------------------------------------------------------------------------

variable "name" {
  description = "The name to prepend to the auto scaling group and ELB resources"
  type        = string
  default     = "gma-dockerhub"
}

variable "environment" {
  description = "The environment name to add to the auto scaling group and ELB resources"
  type        = string
  default     = "prod"
}

variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type        = number
  default     = 8080
}
