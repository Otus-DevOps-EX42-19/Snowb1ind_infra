# Требуемая версия Terraform
terraform { 
    required_version = "~> 0.12"
}

# Выбираем провайдера
provider "google" {   
    version = "2.5.0"
    project = "logical-veld-251210" # Здесь названия проекта в GCP
    region = "europe-west-1"
}

# Определяем параметры инстанса
resource "google_compute_instance" "app" {
  name         = "reddit-app"
  machine_type = "g1-small"
  zone         = "europe-west1-b"
  tags         = ["reddit-app"]

  # Выбираем созданный в Packer
  boot_disk {
    initialize_params {
      image = "reddit-base-1567085858"
    }
  }

  # Настройка интерфейса на инстансе
  network_interface {
    network = "default"
    access_config {}
  }

  # Добавляем ssh-ключ для подключения провижионеров
  metadata = {
    ssh-keys = "sarmirim:${file("~/.ssh/id_rsa.pub")}"
  }

  # Настройка подключения для провижионеров
  connection {
      host = self.network_interface.0.access_config.0.nat_ip
      type = "ssh"  
      user = "sarmirim"
      agent = false 
      private_key = file("~/.ssh/id_rsa")
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
