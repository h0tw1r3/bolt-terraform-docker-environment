variable "host_path" {
  type = string
  default = "../../"
}

variable "container_path" {
  type = string
  default = "/bolt"
}

variable "domain" {
  type = string
  default = "at.local"
}

variable "subnet" {
  type = string
  default = "172.18.1.0/24"
}
