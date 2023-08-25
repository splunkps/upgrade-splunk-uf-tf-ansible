variable "linux_server_count" {
  description = "Number of EC2 instances to create for splunk uf upgrade"
  # it would be 1 ideally
  default     = 5
}

resource "aws_instance" "linux_server" {
  count         = var.linux_server_count
  ami           = "ami-09f67f6dc966a7829"  # Replace with the desired AMI ID
  instance_type = "t2.micro"      # Replace with the desired instance type
  subnet_id     = "subnet-0ff1abf16757c0f27"  # Replace with the desired subnet ID
  key_name      = "" #key_name 

  root_block_device {
    volume_size = 50
  }

tags = {
    Name = "linuxserver-${count.index+1}"
    Role = "linux"
  }
 vpc_security_group_ids = [aws_security_group.ec2_sg.id]
}

resource "aws_security_group" "ec2_sg" {
  name        = "splunk-sg"
  description = "Security Group for EC2 instances created for splunk using tf"

    
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

}


resource "null_resource" "write_public_ips_linux_server" {
  count = var.linux_server_count

  provisioner "local-exec" {
    command = <<-EOT
      echo 'linuxserver' >> public_ips.txt
      echo '${aws_instance.linux_server.*.public_ip[count.index]}' >> public_ips.txt
    EOT
  }
}
