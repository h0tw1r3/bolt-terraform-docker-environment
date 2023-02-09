locals {
  images = {
    "ubuntu-20.04" = docker_image.ubuntu_2004
    "ubuntu-18.04" = docker_image.ubuntu_1804
    "ubuntu-16.04" = docker_image.ubuntu_1604
  }

  docker_containers = yamldecode(file("${path.root}/../../docker.yaml"))["containers"]
}
