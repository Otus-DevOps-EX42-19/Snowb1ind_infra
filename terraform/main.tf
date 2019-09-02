# Требуемая версия Terraform
terraform { 
    required_version = "~> 0.12"
}

# Выбираем провайдера
provider "google" {   
    version = "2.5.0"
    project = var.project # Здесь название проекта в GCP
    region = var.region
}

# 
resource "google_compute_project_metadata_item" "ssh-keys" {
  key   = "ssh-keys"
  value = "sarmirim:${file(var.public_key_path)}appuser:${file(var.public_key_path)}appuser1:${file(var.public_key_path)}"
}

# Определяем параметры инстанса
resource "google_compute_instance" "app" {
  name         = "reddit-app-tf"
  machine_type = "g1-small"
  zone         = var.zone
  tags         = ["reddit-app"]

  # Выбираем созданный в Packer
  boot_disk {
    initialize_params {
      image = var.disk_image
    }
  }

  # Настройка интерфейса на инстансе
  network_interface {
    network = "default"
    access_config {}
  }

  # Добавляем ssh-ключ для подключения провижионеров
  metadata = {
    ssh-keys = "sarmirim:${file(var.public_key_path)}"
  }

  # Настройка подключения для провижионеров
  connection {
      host = self.network_interface.0.access_config.0.nat_ip
      type = "ssh"  
      user = "sarmirim"
      agent = false 
      private_key = file(var.private_key_path)
  }
  
  # Сами провижионеры
  provisioner "file" {
    source      = "files/puma.service"
    destination = "/tmp/puma.service"
  }

  provisioner "remote-exec" {
    script = "files/deploy.sh"
  }
}

# Описываем правило для фаервола
resource "google_compute_firewall" "firewall_puma" {
  name = "allow-puma-default" 
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["9292"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags = ["reddit-app"]
}
