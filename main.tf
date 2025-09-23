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
  name_prefix = var.project
  net_name    = "${var.project}-net"
  nr_name     = "${var.project}-nodered"
}

# Network (shared for later services)
resource "docker_network" "net" {
  name = local.net_name
}

# Node-RED volume
resource "docker_volume" "nodered_data" {
  name = "${var.project}-nodered-data"
}

# Pull Node-RED image
resource "docker_image" "nodered" {
  name = var.image_nodered
}

# Node-RED container
resource "docker_container" "nodered" {
  name    = local.nr_name
  image   = docker_image.nodered.image_id
  restart = "unless-stopped"

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

output "nodered_url" {
  value = "http://localhost:${var.nodered_host_port}"
}
