resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  tags = merge(
    var.additional_tags,
    {
      Name = "main"
    },
  )
}

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id
  count      = length(var.aws_zones)
  availability_zone = var.aws_zones[count.index]
  map_public_ip_on_launch = true #for simplicity
  cidr_block = cidrsubnet(var.vpc_cidr, var.subnet_mask_length - parseint(split("/", var.vpc_cidr)[1], 10)  , count.index)

  tags = merge(
    var.additional_tags,
    {
      Name = "public-${count.index}"
    },
  )
}
