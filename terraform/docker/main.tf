resource "docker_container" "map" {
  for_each = {
    for key, value in local.docker_containers:
    key => value
  }

  cgroupns_mode = try(each.value.cgroupns, try(local.os[each.value.image].cgroupns, var.cgroupns))
  name = each.key
  image = docker_image.map[each.value.image].image_id
  hostname = each.key
  # domainname = "${var.domain}"

  privileged = try(each.value.privileged, try(local.os[each.value.image].privileged, var.privileged))
  must_run = true
  start = try(each.value.start, var.start)
  memory = try(each.value.memory, var.memory)
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

  dynamic "volumes" {
    for_each = merge(try(each.value.volumes, {}), local.cgroup_volume)
    content {
      container_path = volumes.key
      host_path = abspath((substr(volumes.value.path, 0, 1) != "/") ? "../../${volumes.value.path}" : volumes.value.path)
      read_only = try(volumes.value.read_only, true)
    }
  }

  networks_advanced {
    name = docker_network.btde.name
    aliases = try(each.value.host_aliases, [])
  }

  lifecycle {
    ignore_changes = [ ulimit, memory_swap ]
  }

  depends_on = [docker_image.map]
}
