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

variable "memory" {
  type = number
  default = 2048
}

variable "start" {
  type = bool
  default = true
}

variable "privileged" {
  type = bool
  default = false
}

variable "cgroupns" {
  type = string
  default = "host"
}

variable "cgroup_parent" {
  type = string
  default = ""
}
