variable "project" {
  type    = string
  default = "nucleo-1-terraform"
}

# Image (pin recommended)
variable "image_nodered" {
  type    = string
  default = "nodered/node-red:3.1.9"
}

# Host port (avoid clashes with your 1881)
variable "nodered_host_port" {
  type    = number
  default = 8082
}
