 terraform {
   required_providers {
     yandex = {
       source = "yandex-cloud/yandex"
     }
   }
   required_version = ">= 0.13"
 }

provider "yandex" {
  service_account_key_file = pathexpand(var.service_account_key)
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
  zone                     = var.zone
}

resource "yandex_compute_instance" "kubenode" {
  count = 2
  name = count.index == 1 ? "kubemaster" : "kubeworker"

  metadata = {
    ssh-keys = "ubuntu:${file(var.public_key_path)}"
  }

  resources {
    cores  = 2
    memory = 8
  }

  boot_disk {
    initialize_params {
      image_id = var.image_id
      size = 40
    }
  }

  network_interface {
    subnet_id = var.subnet_id
    nat       = true
  }

  connection {
    type  = "ssh"
    host  = self.network_interface.0.nat_ip_address
    user  = "ubuntu"
    agent = false
    private_key = file(var.private_key_path)
  }
}
