locals {
  ssh_key = file(var.public_ssh_key_path)
}

# Образ Ubuntu 22.04
data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2204-lts"
}

# Бастион (публичный IP, доступ только по SSH)
resource "yandex_compute_instance" "bastion" {
  name        = "bastion-1"
  hostname    = "bastion-1"
  zone        = var.zone_a
  platform_id = "standard-v3"

  resources {
    cores         = 2
    core_fraction = 20
    memory        = 2
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size     = 10
      type     = "network-hdd"
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.public.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.bastion.id]
  }

  scheduling_policy {
    preemptible = true
  }

  metadata = {
    ssh-keys = "${var.vm_username}:${local.ssh_key}"
  }

  labels = {
    role        = "bastion"
    environment = var.environment
  }
}

# Zabbix server (публичная подсеть, внешний IP)
resource "yandex_compute_instance" "zabbix" {
  name        = "zabbix-1"
  hostname    = "zabbix-1"
  zone        = var.zone_a
  platform_id = "standard-v3"

  resources {
    cores         = 2
    core_fraction = 20
    memory        = 2
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size     = 10
      type     = "network-hdd"
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.public.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.zabbix.id]
  }

  scheduling_policy {
    preemptible = true
  }

  metadata = {
    ssh-keys = "${var.vm_username}:${local.ssh_key}"
  }

  labels = {
    role        = "zabbix"
    environment = var.environment
  }
}

# Kibana (публичная подсеть, внешний IP)
resource "yandex_compute_instance" "kibana" {
  name        = "kibana-1"
  hostname    = "kibana-1"
  zone        = var.zone_a
  platform_id = "standard-v3"

  resources {
    cores         = 2
    core_fraction = 20
    memory        = 2
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size     = 10
      type     = "network-hdd"
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.public.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.kibana.id]
  }

  scheduling_policy {
    preemptible = true
  }

  metadata = {
    ssh-keys = "${var.vm_username}:${local.ssh_key}"
  }

  labels = {
    role        = "kibana"
    environment = var.environment
  }
}

# Elasticsearch (приватная подсеть, без внешнего IP)
resource "yandex_compute_instance" "elastic" {
  name        = "elastic-1"
  hostname    = "elastic-1"
  zone        = var.zone_a
  platform_id = "standard-v3"

  resources {
    cores         = 2
    core_fraction = 20
    memory        = 4
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size     = 20
      type     = "network-hdd"
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.private_a.id
    nat                = false
    security_group_ids = [yandex_vpc_security_group.elastic.id]
  }

  scheduling_policy {
    preemptible = true
  }

  metadata = {
    ssh-keys = "${var.vm_username}:${local.ssh_key}"
  }

  labels = {
    role        = "elasticsearch"
    environment = var.environment
  }
}

# Web-servers (две ВМ, разные зоны, без внешнего IP)
resource "yandex_compute_instance" "web1" {
  name        = "web-1"
  hostname    = "web-1"
  zone        = var.zone_a
  platform_id = "standard-v3"

  resources {
    cores         = 2
    core_fraction = 20
    memory        = 2
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size     = 10
      type     = "network-hdd"
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.private_a.id
    nat                = false
    security_group_ids = [yandex_vpc_security_group.web.id]
  }

  scheduling_policy {
    preemptible = true
  }

  metadata = {
    ssh-keys = "${var.vm_username}:${local.ssh_key}"
  }

  labels = {
    role        = "web"
    environment = var.environment
  }
}

resource "yandex_compute_instance" "web2" {
  name        = "web-2"
  hostname    = "web-2"
  zone        = var.zone_b
  platform_id = "standard-v3"

  resources {
    cores         = 2
    core_fraction = 20
    memory        = 2
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size     = 10
      type     = "network-hdd"
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.private_b.id
    nat                = false
    security_group_ids = [yandex_vpc_security_group.web.id]
  }

  scheduling_policy {
    preemptible = true
  }

  metadata = {
    ssh-keys = "${var.vm_username}:${local.ssh_key}"
  }

  labels = {
    role        = "web"
    environment = var.environment
  }
}
