output "vpc" {
  value = aws_vpc.main
}

output "public_subnets" {
  value = aws_subnet.public
}