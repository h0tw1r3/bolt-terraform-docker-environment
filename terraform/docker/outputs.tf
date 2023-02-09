output "primary_ip" {
    description = "primary public ip address"
    value = values(docker_container.map)[*].network_data.0.ip_address
}
