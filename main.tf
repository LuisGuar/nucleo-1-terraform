terraform {
  required_version = ">= 1.6.0"
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {}

locals {
  name_prefix          = var.project
  net_name             = "${var.project}-net"
  nr_name              = "${var.project}-nodered"
  rabbitmq_name        = "${var.project}-rabbitmq"
  rabbitmq_volume_name = "${var.project}-rabbitmq-data"
}

# Network (shared for later services)
resource "docker_network" "net" {
  name = local.net_name

  labels {
    label = "com.docker.compose.project"
    value = var.project
  }

  labels {
    label = "com.nucleo.project"
    value = var.project
  }
}

# Node-RED volume
resource "docker_volume" "nodered_data" {
  name = "${var.project}-nodered-data"

  labels {
    label = "com.docker.compose.project"
    value = var.project
  }

  labels {
    label = "com.docker.compose.service"
    value = "nodered"
  }

  labels {
    label = "com.nucleo.project"
    value = var.project
  }

  labels {
    label = "com.nucleo.service"
    value = "nodered"
  }
}

# RabbitMQ volume
resource "docker_volume" "rabbitmq_data" {
  name = local.rabbitmq_volume_name

  labels {
    label = "com.docker.compose.project"
    value = var.project
  }

  labels {
    label = "com.docker.compose.service"
    value = "rabbitmq"
  }

  labels {
    label = "com.nucleo.project"
    value = var.project
  }

  labels {
    label = "com.nucleo.service"
    value = "rabbitmq"
  }
}

# Pull Node-RED image
resource "docker_image" "nodered" {
  name = var.image_nodered
}

# Pull RabbitMQ image
resource "docker_image" "rabbitmq" {
  name = var.image_rabbitmq
}

# Node-RED container
resource "docker_container" "nodered" {
  name    = local.nr_name
  image   = docker_image.nodered.image_id
  restart = "unless-stopped"

  labels {
    label = "com.docker.compose.project"
    value = var.project
  }

  labels {
    label = "com.docker.compose.service"
    value = "nodered"
  }

  labels {
    label = "com.nucleo.project"
    value = var.project
  }

  labels {
    label = "com.nucleo.service"
    value = "nodered"
  }

  networks_advanced {
    name = docker_network.net.name
  }

  # Host 8082 -> container 1880
  ports {
    internal = 1880
    external = var.nodered_host_port
  }

  mounts {
    target = "/data"
    type   = "volume"
    source = docker_volume.nodered_data.name
  }
}

# RabbitMQ container with MQTT & management ports
resource "docker_container" "rabbitmq" {
  name    = local.rabbitmq_name
  image   = docker_image.rabbitmq.image_id
  restart = "always"

  labels {
    label = "com.docker.compose.project"
    value = var.project
  }

  labels {
    label = "com.docker.compose.service"
    value = "rabbitmq"
  }

  labels {
    label = "com.nucleo.project"
    value = var.project
  }

  labels {
    label = "com.nucleo.service"
    value = "rabbitmq"
  }

  networks_advanced {
    name = docker_network.net.name
  }

  # Host 15673 -> container 15672 (management UI)
  ports {
    internal = 15672
    external = var.rabbitmq_management_host_port
    protocol = "tcp"
  }

  # Host 5673 -> container 5672 (AMQP)
  ports {
    internal = 5672
    external = var.rabbitmq_amqp_host_port
    protocol = "tcp"
  }

  # Host 1885 -> container 1883 (MQTT)
  ports {
    internal = 1883
    external = var.rabbitmq_mqtt_host_port
    protocol = "tcp"
  }

  # Host 8889 -> container 8883 (MQTT over TLS)
  ports {
    internal = 8883
    external = var.rabbitmq_mqtt_tls_host_port
    protocol = "tcp"
  }

  env = [
    "RABBITMQ_DEFAULT_USER=${var.rabbitmq_default_user}",
    "RABBITMQ_DEFAULT_PASS=${var.rabbitmq_default_pass}"
  ]

  entrypoint = ["/bin/bash", "/entrypoint.sh"]
  command    = ["rabbitmq-server"]

  mounts {
    target = "/var/lib/rabbitmq"
    type   = "volume"
    source = docker_volume.rabbitmq_data.name
  }

  mounts {
    target    = "/entrypoint.sh"
    type      = "bind"
    source    = "${path.cwd}/rabbitmq/entrypoint.sh"
    read_only = true
  }
}

output "nodered_url" {
  value = "http://localhost:${var.nodered_host_port}"
}

output "rabbitmq_management_url" {
  value = "http://localhost:${var.rabbitmq_management_host_port}"
}
