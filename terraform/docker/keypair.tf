resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits = 4096
}

resource "local_sensitive_file" "ssh_private_key" {
  filename = "../../keys/ssh.pem"
  content  = tls_private_key.ssh.private_key_pem
}

resource "local_file" "ssh_public_key" {
  filename = "../../keys/ssh.pub"
  content  = tls_private_key.ssh.public_key_openssh
}
