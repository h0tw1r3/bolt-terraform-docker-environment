resource "docker_network" "btde" {
  name = "${var.domain}"
  ipam_config {
    subnet = "${var.subnet}"
  }
}
