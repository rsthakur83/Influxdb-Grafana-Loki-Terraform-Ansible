provider "google" {
  project     = var.project
  region      = var.region
  zone        = var.zone
}

resource "google_compute_address" "static" {
  name = var.monitoring
}

resource "google_compute_firewall" "default" {
 name    = var.customer
 network = "default"

 allow {
   protocol = "icmp"
 }

 allow {
   protocol = "tcp"
   ports    = ["80", "3000", "8086", "3100", "443"]
 }
// Note: Update the source range only from the customer public ip and remove 0.0.0.0/0 , check with their IT team.
 source_ranges = ["0.0.0.0/0"]
 source_tags = ["monitoring"]

}

// Define VM resource
resource "google_compute_instance" "instance_with_ip" {
    provider = google-beta
    project  = "web-newappproject-sandpit"
    name         = var.customer
    machine_type = "f1-micro"
    zone         = var.zone

    boot_disk {
        initialize_params{
            image = "centos-cloud/centos-7"
            size  = 50
        }
    }

    metadata = {
        ssh-keys = "${var.ssh_username}:${file(var.pub_key)}"
    }

 provisioner "remote-exec" {
    inline = ["yum -y install epel-release", "sudo yum install ansible python3 -y", "chmod 600 /home/ubuntu/.ssh/authorized_keys" , "echo Done!", "sudo ssh-keygen -b 2048 -t rsa -f /home/ubuntu/.ssh/id_rsa -q -N ''", "sudo cat /home/ubuntu/.ssh/id_rsa.pub >> /home/ubuntu/.ssh/authorized_keys"]

    connection {
      host        = self.network_interface[0].access_config[0].nat_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.pvt_key)
    }
  }


  provisioner "file" {
    source      = "monitoring"
    destination = "/tmp"

    connection {
      host        = self.network_interface[0].access_config[0].nat_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.pvt_key)
  }

  }

  provisioner "remote-exec" {
    inline = ["export ANSIBLE_HOST_KEY_CHECKING=False", "ansible-playbook -c local -i /tmp/monitoring/hosts /tmp/monitoring/site.yml"]
    connection {
      host        = self.network_interface[0].access_config[0].nat_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.pvt_key)
  }
}



    network_interface {
        network = "default"
        access_config {
            nat_ip = google_compute_address.static.address
        }
    }
}



// Expose IP of VM
output "ip" {
 value = google_compute_instance.instance_with_ip.network_interface.0.access_config.0.nat_ip
}

