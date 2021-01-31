output "controlplane-nodes-name" {
  value = aws_instance.controlplane.*.tags.Name
}
output "controlplane-nodes-private-ip" {
  value = aws_instance.controlplane.*.private_ip
}
output "controlplane-nodes-public-ip" {
  value = aws_instance.controlplane.*.public_ip
}

output "worker-nodes-name" {
  value = aws_instance.worker.*.tags.Name
}
output "worker-nodes-private-ip" {
  value = aws_instance.worker.*.private_ip
}
output "worker-nodes-public-ip" {
  value = aws_instance.worker.*.public_ip
}
