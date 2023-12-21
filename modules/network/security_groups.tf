resource "aws_security_group" "ses" {
  name        = "ses-email"
  description = "Allow emails to be sent"
  vpc_id      = aws_vpc.main.id

  egress {
    description     = "SES SMTP port for VPCE"
    from_port       = 587
    to_port         = 587
    protocol        = "tcp"
    cidr_blocks     = [var.cidr]
  }

  egress {
    description     = "S3 port for VPCE"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}
