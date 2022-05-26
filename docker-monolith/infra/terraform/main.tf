terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
    local = {
      source = "hashicorp/local"
    }
  }
}

provider "yandex" {
  service_account_key_file = var.service_acc_key
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
  zone                     = var.zone_id
}

resource "yandex_compute_instance" "docker-app" {
  name        = "dockerhost-${count.index}"
  platform_id = "standard-v3"
  count       = var.inst_count
  labels = {
    "tags" = "docker_host"
  }


  resources {
    cores         = 2
    memory        = 4
    core_fraction = 20

  }
  scheduling_policy {
    preemptible = true
  }

  boot_disk {
    initialize_params {
      image_id = var.app_disk_image
    }
  }
  network_interface {
    nat       = true
    subnet_id = var.subnet_id
  }

  metadata = {
    ssh-keys = "ubuntu:${file(var.public_key_path)}"
  }

}

locals {

  instance_ips_app_st = yandex_compute_instance.docker-app[*].network_interface.0.nat_ip_address
  instance_na_app_st  = yandex_compute_instance.docker-app[*].name
}

resource "local_file" "get_inst_data_stage" {

  content = templatefile("instapp.tpl", {

    instance_names_app_st = local.instance_na_app_st,
    ips_app_st            = local.instance_ips_app_st,
    envt                  = var.env_type


  })

  filename = "inventory_${var.env_type}"

  depends_on = [
    yandex_compute_instance.docker-app
  ]


}

resource "null_resource" "templates" {

  triggers = {

    env_type = var.env_type
  }


  provisioner "local-exec" {

    when       = destroy
    command    = "mv inventory_${self.triggers.env_type} inventory_${self.triggers.env_type}.back"
    on_failure = continue

  }

  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u ubuntu -i inventory_${self.triggers.env_type} -e pub_key=${var.public_key_path} /home/eugene/lerning/prod/microservices/docker-monolith/infra/ansible/start_docker.yml"
  }
  depends_on = [
    local_file.get_inst_data_stage
  ]
}
