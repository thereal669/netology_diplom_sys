variable "cloud_id" {
  description = "Yandex Cloud ID"
  type        = string
}

variable "folder_id" {
  description = "Yandex Cloud Folder ID"
  type        = string
}

variable "sa_key_file" {
  description = "Path to SA key JSON (НЕ класть в git)"
  type        = string
}

variable "default_zone" {
  description = "Default availability zone"
  type        = string
  default     = "ru-central1-a"
}

variable "zone_a" {
  description = "First zone"
  type        = string
  default     = "ru-central1-a"
}

variable "zone_b" {
  description = "Second zone"
  type        = string
  default     = "ru-central1-b"
}

variable "network_cidr" {
  description = "VPC CIDR"
  type        = string
  default     = "10.10.0.0/16"
}

variable "public_subnet_cidr" {
  type    = string
  default = "10.10.1.0/24"
}

variable "private_subnet_a_cidr" {
  type    = string
  default = "10.10.2.0/24"
}

variable "private_subnet_b_cidr" {
  type    = string
  default = "10.10.3.0/24"
}

variable "vm_username" {
  description = "Linux username on VMs"
  type        = string
  default     = "yc-user"
}

variable "public_ssh_key_path" {
  description = "Path to your public SSH key"
  type        = string
}

variable "environment" {
  description = "Environment tag"
  type        = string
  default     = "prod"
}

# IP, с которого ты будешь подключаться по SSH к bastion
variable "my_ip" {
  description = "Your IP for SSH access to bastion"
  type        = string
  default     = "158.160.119.221/32" # ОБЯЗАТЕЛЬНО ИЗМЕНИТЬ на свой_IP/32
}
