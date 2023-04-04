output "containers" {
  description = "containers"
  value = {
    for name, config in local.docker_containers:
      name => {
        "ip" = docker_container.map[name].network_data.0.ip_address,
        "memory" = docker_container.map[name].memory,
        "image" = docker_image.map[config.image].name,
      }
  }
}
