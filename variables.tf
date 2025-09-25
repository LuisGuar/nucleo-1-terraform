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

# RabbitMQ image with management plugin enabled
variable "image_rabbitmq" {
  type    = string
  default = "rabbitmq:3.13-management"
}

# Host ports mapped to RabbitMQ container ports
variable "rabbitmq_management_host_port" {
  type    = number
  default = 15673
}

variable "rabbitmq_amqp_host_port" {
  type    = number
  default = 5673
}

variable "rabbitmq_mqtt_host_port" {
  type    = number
  default = 1885
}

variable "rabbitmq_mqtt_tls_host_port" {
  type    = number
  default = 8891
}

variable "rabbitmq_default_user" {
  type    = string
  default = "guest"
}

variable "rabbitmq_default_pass" {
  type      = string
  sensitive = true
  default   = "guest"
}

# Telegraf image tag
variable "image_telegraf" {
  type    = string
  default = "telegraf:1.30"
}

# TimescaleDB image
variable "image_timescaledb" {
  type    = string
  default = "timescale/timescaledb-ha:pg17"
}

# TimescaleDB credentials and database
variable "timescaledb_user" {
  type    = string
  default = "nucleus"
}

variable "timescaledb_password" {
  type      = string
  sensitive = true
  default   = "password"
}

variable "timescaledb_database" {
  type    = string
  default = "nucleus"
}

variable "timescaledb_host_port" {
  type    = number
  default = 5435
}
