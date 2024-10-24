data "aws_subnets" "private" {
  filter {
    name = "tag:Name"

    values = [
      "*private*",
    ]
  }

  depends_on = [aws_subnet.this]
}

data "aws_subnets" "public" {
  filter {
    name = "tag:Name"

    values = [
      "*public*",
    ]
  }
  depends_on = [aws_subnet.this]
}
