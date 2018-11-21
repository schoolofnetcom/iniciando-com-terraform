provider "aws" {
    access_key = ""
    secret_key = ""
    region = "us-east-2"
}
resource "aws_s3_bucket" "bucket-iac-terraform" {
    bucket = "bucket-iac-terraform"
    acl = "private"
  
}
resource "aws_security_group" "fw-terraform" {
  name        = "fw-terraform"
  description = "firewall terraform"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}
resource "aws_eip" "ip_publico" {
  instance   = "${aws_instance.teste_terraform.id}"
}
resource "aws_key_pair" "acesso_ssh" {
  key_name   = "acesso_ssh"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC/XSDONYjIa7UoIQwNs53aKB8V/R3dlkjwSr8FeEmWVsV/+aKivQ1RtpuwikzoZGD1HZXZ3mxML/2bLhbA8jtE1fBxFlwXOO0zg6hoXk/gMy7p1ouC+Qm9+3H8gBBkdOZjcE2H/ghiwx1ouI28Lqvt5qFvILx6mEH3b7KsZRMBJkSqsAb1/mjc7RgE6YHmU0PxrdJ9/vCizVSjnGWzb82yolukFy3yPZJmiUuftYx0Me4MN/vbZd62QmcuHOUIqSwPzj7TxkFlnHHejkvZCtT8m8Om5oC4zlhB8j8AUNNqf8GhIHY7rRxYzqOyEbEU5fLLNw5bMZ5CHTGIS377hvGF Jackson@LAPTOP-ULMI5ORS"
}
resource "aws_instance" "teste_terraform" {
    ami = "ami-0782e9ee97725263d"
    instance_type = "t2.micro"
    key_name = "${aws_key_pair.acesso_ssh.key_name}"
    security_groups = ["${aws_security_group.fw-terraform.name}"]
    
    depends_on = ["aws_s3_bucket.bucket-iac-terraform"]
provisioner "file" {
    source      = "install_nginx.sh"
    destination = "/tmp/install_nginx.sh"
  }
provisioner "remote-exec" {
  inline      = [
      "sudo chmod +x /tmp/install_nginx.sh",
      "/tmp/install_nginx.sh"
    ]
    }
connection {
    type     = "ssh"
    user     = "ubuntu"
    private_key = "${file("son_terraform_pvt")}"
    agent = "false"
  }
}