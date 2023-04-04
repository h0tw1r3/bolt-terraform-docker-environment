locals {
  os = {
    "ubuntu-20.04" = { image = "ubuntu-20.04" }
    "ubuntu-18.04" = { image = "ubuntu-18.04" }
    "ubuntu-16.10" = { image = "ubuntu-16.10", privileged = true }
    "ubuntu-14.04" = { image = "ubuntu-14.04", cgroupns = "private" }
  }

  images = {
    "ubuntu-20.04" = {
      name = "btde.local/ubuntu:20.04"
      dockerfile = "Dockerfile"
      repo = "library/ubuntu"
      tag = "20.04"
    }
    "ubuntu-18.04" = {
      name = "btde.local/ubuntu:18.04"
      dockerfile = "Dockerfile"
      repo = "library/ubuntu"
      tag = "18.04"
    }
    "ubuntu-16.10" = {
      name = "btde.local/ubuntu:16.10"
      dockerfile = "Dockerfile"
      repo = "library/ubuntu"
      tag = "16.10"
    }
    "ubuntu-14.04" = {
      name = "btde.local/ubuntu:14.04"
      dockerfile = "Dockerfile.upstart"
      repo = "library/ubuntu"
      tag = "14.04"
    }
  }

  need_images = distinct(flatten([
    for name, config in local.docker_containers: [ (config.image) ]
  ]))

  cgroup_parent = var.cgroup_parent != "" ? var.cgroup_parent : try(jsondecode(file("/etc/docker/daemon.json"))["cgroup-parent"], "")

  cgroup_volume = local.cgroup_parent != "" ? {
    "/sys/fs/cgroup/${local.cgroup_parent}" = {
      path = "/sys/fs/cgroup/${local.cgroup_parent}"
      read_only = false
    }
  } : { }

  docker_containers = yamldecode(file("${path.root}/../../containers.yaml"))
}
