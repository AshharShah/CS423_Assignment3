output "ec2_instance_ips" {
  value = {
    web_server_public_ip  = aws_instance.web_server.public_ip
    web_server_private_ip = aws_instance.web_server.private_ip
    db_or_ml_public_ip    = aws_instance.database_or_ml.public_ip
    db_or_ml_private_ip   = aws_instance.database_or_ml.private_ip
  }
}

output "iam_user_details" {
  value = aws_iam_user.terraform_user
}