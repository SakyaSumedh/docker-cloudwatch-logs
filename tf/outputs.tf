output "public_ip" {
  value = aws_instance.ec2.public_ip
}

output "ansible_inventory" {
  value = templatefile("${path.module}/ansible_host.tpl",
  {
    host_name = local.name
    ip = aws_instance.ec2.public_ip
  })
}