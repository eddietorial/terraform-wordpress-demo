variable "ssh_public_key_path" {
  description = "Absolute path to your SSH public key. Used to create an AWS key pair for EC2 instance access."
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}
