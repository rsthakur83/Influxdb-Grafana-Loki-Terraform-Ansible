variable "project" {
default = "web-newappproject-sandpit"
}

variable "customer" {
default = "test"
}


variable "pub_key" {
  default = "/root/.ssh/id_rsa.pub"
}


variable "pvt_key" {
  default = "/root/.ssh/id_rsa"
}

variable "ssh_username" {
  default = "ubuntu"
}

variable "zone" {
default = "us-central1-c"
}

variable "region" {
default = "us-central1"
}

variable "firewall" {
default = "firewall"
}

variable "monitoring" {
default = "custmoer-firewall-rule"
}
