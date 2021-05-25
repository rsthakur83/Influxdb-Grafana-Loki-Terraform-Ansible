# Steps required to setup Monitoring server on GCP to monitor On-Premise Kubernetes Cluster, Postgres Database, RabbitMQ

1) Download the terraform version v0.14.0 <https://releases.hashicorp.com/terraform/0.14.0/terraform_0.14.0_linux_amd64.zip>
2) You should have the keys ( `.ssh/id_rsa.pub` and `.ssh/id_rsa`) under your home directory and if you have different user other than **root** then update correct path for the variable `pub_key` & `pvt_key` in the `vars.tf` file.

3) Update the following values in the `vars.tf` as per the project and region etc..

```sh
variable "project" {
default = "web-newappproject-sandpit"
}

variable "customer" {
default = "customer-name"
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
default = "custmoer-name-firewall-rule"
}
```

4) Change the variable `influxdb_user_password` password  in the file `group_vars/all.yml`

5) Make sure you update the source range (line no 24 source_ranges = ["0.0.0.0/0"]) in main.tf file and it has to be the public ip of customer network where kubernetes is running so that the **only** promtail pods, telegraf agent running on customer kubernetes can reach the monitoring server

6) Run below command to initialize the terraform deployment. Terraform will create instance with required firewall setting.

```sh
terraform init  # Initialize the plugins 
terraform plan  # To see the resources it will create on GCP
terraform apply # To deploy the K8S resources on GCP
```

7) Create the DNS entry in new-app project for the public ip address of vm created above. DNS entry will look like something like this customer_name.test.cloud

