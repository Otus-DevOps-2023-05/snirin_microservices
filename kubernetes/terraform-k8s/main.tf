terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  service_account_key_file = pathexpand("secrets/authorized_key.json")
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
  zone                     = var.zone
}

resource "yandex_vpc_network" "my_network" {
  name = "my_network"
}

resource "yandex_vpc_subnet" "my_subnet" {
  v4_cidr_blocks = ["10.5.0.0/16"]
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.my_network.id
}

resource "yandex_kubernetes_cluster" "k8s" {
  name = "otus-k8s"
  network_id = yandex_vpc_network.my_network.id
  master {
    version = "1.28"
    zonal {
      zone      = yandex_vpc_subnet.my_subnet.zone
      subnet_id = yandex_vpc_subnet.my_subnet.id
    }
    public_ip = true
  }

  release_channel = "RAPID"
  network_policy_provider = "CALICO"

  service_account_id      = var.service_account_id
  node_service_account_id = var.service_account_id
}

resource "yandex_kubernetes_node_group" "my_node_group" {
  cluster_id  = yandex_kubernetes_cluster.k8s.id
  name        = "m-node-group"
  version     = "1.28"

  instance_template {
    platform_id = "standard-v2"
    network_interface {
      nat                = true
      subnet_ids         = [yandex_vpc_subnet.my_subnet.id]
    }

    resources {
      memory = 8
      cores  = 4
      core_fraction = 20
    }

    boot_disk {
      type = "network-ssd"
      size = 64
    }
    metadata = {
      ssh-keys = "ubuntu:${file(var.public_key_path)}"
    }

    scheduling_policy {
      preemptible = false
    }
  }

  scale_policy {
    fixed_scale {
      size = 2
    }
  }

  allocation_policy {
    location {
      zone = var.zone
    }
  }
}
