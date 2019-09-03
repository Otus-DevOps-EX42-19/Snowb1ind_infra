resource "google_compute_instance" "app" {
  name         = "reddit-app"
  machine_type = "g1-small"
  zone         = var.zone
  tags         = ["reddit-app"]
  boot_disk {
    initialize_params {
      image = var.app_disk_image
    }
  }

  network_interface {
    network = "default"
    access_config {
      nat_ip = google_compute_address.app_ip.address
    }
  }
  metadata = {
    ssh-keys = "sarmirim:${file(var.public_key_path)}"
  }

  connection {
    host        = self.network_interface.0.access_config.0.nat_ip
    type        = "ssh"
    user        = "sarmirim"
    agent       = false
    private_key = file(var.private_key_path)
  }

  provisioner "file" {
    source      = "${path.module}/files/puma.service"
    destination = "/tmp/puma.service"
  }

  provisioner "remote-exec" {
    script = "${path.module}/files/deploy.sh"
  }
  provisioner "remote-exec" {
    inline = [ "echo 'export DATABASE_URL=${var.db_ip}' > /home/sarmirim/.bash_profile",
    "chown sarmirim:sarmirim /home/sarmirim/.bash_profile"]
  }
}

resource "google_compute_address" "app_ip" {
  name = "reddit-app-ip"
}
