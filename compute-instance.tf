resource "google_compute_instance" "vm_instance" {
  name         = "terraform-instance"
  machine_type = var.machine_size

  boot_disk {
    initialize_params {
      image = var.image_name
    }
  }

  network_interface {
    network       = "default"

    access_config {
      nat_ip = google_compute_address.static.address
    }
  }
  metadata = {
    sshKeys = "${var.username}:${file(var.public_key_path)}"
  }

  provisioner "remote-exec" {
    script = var.script_path

    connection {
      type        = "ssh"
      host        = google_compute_address.static.address
      user        = var.username
      private_key = file(var.private_key_path)
    }
  }
}
