variable "cloud_id" {
  default = "b1g8fd7t7ngogsno9orj"
}

variable "folder_id" {
  default = "b1gjs8uoo12oe6e1hh5v"
}

variable "zone_id" {
  default = "ru-central1-a"
}

variable "public_key_path" {
  default = "~/ssh/admin.pub"

}
variable "service_acc_key" {
  default = "key.json"
}
variable "image_id" {
  default = "fd8ard8uvd1mrhrqi3fo"
}

variable "subnet_id" {
  default = "e9bq2oe6jsaapniab33p"
}

variable "inst_count" {
  default = "1"
}
variable "app_disk_image" {
  description = "Disk image for installing reddit app"
  default     = "e9bq2oe6jsaapniab33p"
}
variable "db_disk_image" {
  description = "Disk image for installing reddit db"
  default     = "e9bq2oe6jsaapniab33p"
}
variable "env_type" {
  description = "Env type for instance"
  default     = "prod"
}

variable "db_ip" {
  description = "db ip"
  default     = "localhost"
}

variable "run_prv" {
  description = "Run provisionong"
  default     = "0"
}


variable "app_inst_name" {
  description = "Name for VM INstance"
  default     = "reddis-app"
}
