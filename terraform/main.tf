terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

variable "do_token" {}

provider "digitalocean" {
  token = var.do_token
}

data "digitalocean_ssh_key" "primeframe_ssh_key" {
  name = "primeframe-ssh-key"
}

data "digitalocean_project" "primeframe_project" {
  name = "primeframe_project"
}

resource "digitalocean_vpc" "primeframe_vpc" {
  name     = "primeframe-vpc"
  region   = "nyc3"
  ip_range = "10.10.10.0/24"
}

resource "digitalocean_kubernetes_cluster" "primeframe_kubernetes_cluster" {
  name   = "primeframe-kubernetes-cluster"
  region = "nyc3"
  vpc_uuid = digitalocean_vpc.primeframe_vpc.id
  version = "1.21.9-do.0"

  auto_upgrade = false
  ha = false

  node_pool {
    name       = "node-pool-1"
    size       = "s-2vcpu-2gb"
    node_count = 3
  }
}

resource "digitalocean_project_resources" "primeframe_resource" {
  project = data.digitalocean_project.primeframe_project.id
  resources = [
  digitalocean_kubernetes_cluster.primeframe_kubernetes_cluster.urn
  ]
}
