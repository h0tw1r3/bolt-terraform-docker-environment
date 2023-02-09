resource "docker_container" "map" {
  for_each = {
    for key, value in local.docker_containers:
    key => value
  }

  name = each.key
  image = try(lookup(local.images, each.value.image).name, docker_image.ubuntu_2004.name)
  hostname = each.key
  domainname = "${var.domain}"

  privileged = true
  must_run = true
  start = true
  memory = 2048
  tty = true
  stdin_open = true

  tmpfs = {
    "/tmp" = "exec"
  }

  mounts {
    target = "/run"
    type = "tmpfs"
  }

  mounts {
    target = "/run/lock"
    type = "tmpfs"
  }

  dynamic "ports" {
    for_each = try(each.value.port_forwards, {})
    content {
      external = ports.key
      internal = try(ports.value[0], ports.value)
      protocol = try(ports.value[1], "tcp")
    }
  }

  upload {
    content = tls_private_key.ssh.public_key_openssh
    file    = "/root/.ssh/authorized_keys"
  }

  dynamic "upload" {
    for_each = try(each.value.uploads, {})

    content {
      file = upload.key
      executable = try(upload.value.executable, false)
      source = try((substr(upload.value.source,0,1) != "/") ? "../../${upload.value.source}" : upload.value.source, null)
      source_hash = try(filemd5((substr(upload.value.source,0,1) != "/") ? "../../${upload.value.source}" : upload.value.source), null)
      content = try(upload.value.content, null)
      content_base64 = try(upload.value.content_base64, null)
    }
  }

  dynamic "volumes" {
    for_each = try(each.value.volumes, {})
    content {
      container_path = volumes.key
      host_path = abspath((substr(volumes.value.path, 0, 1) != "/") ? "../../${volumes.value.path}" : volumes.value.path)
    }
  }

  volumes {
    container_path = "/sys/fs/cgroup"
    host_path = "/sys/fs/cgroup"
    read_only = true
  }

  # insecure, but it's a test environment
  volumes {
    container_path = "/run/.docker.sock"
    host_path = "/run/docker.sock"
  }

  networks_advanced {
    name = docker_network.test.name
    aliases = try(each.value.host_aliases, [])
  }

  lifecycle {
    ignore_changes = [ ulimit, memory_swap ]
  }
}
