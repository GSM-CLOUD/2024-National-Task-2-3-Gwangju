resource "aws_instance" "bastion" {
  ami = var.ami_id
  instance_type = "t3.small"

  subnet_id = var.public_subnets[0]
  vpc_security_group_ids = [aws_security_group.bastion-sg.id]
  key_name = aws_key_pair.bastion-key-pair.key_name
  iam_instance_profile = aws_iam_instance_profile.bastion_instance_profile.name

  user_data = <<-EOF
#!/bin/bash
sudo su
set -e
set -x

echo "complete"
yum install -y docker
systemctl enable docker
systemctl restart docker

mkdir -p service-a
mkdir -p service-b
mkdir -p service-c

echo "complete"
aws s3 cp s3://${var.file_bucket_name}/service-a/ ./service-a --recursive
aws s3 cp s3://${var.file_bucket_name}/service-b/ ./service-b --recursive
aws s3 cp s3://${var.file_bucket_name}/service-c/ ./service-c --recursive

echo "complete"
cd service-a
unzip ./*.zip -d .
rm -rf *.zip

echo "complete"
aws ecr get-login-password --region ${var.region} | docker login --username AWS --password-stdin ${var.account_id}.dkr.ecr.${var.region}.amazonaws.com
docker build -t ${var.ecr_service_a_name} .
docker tag ${var.ecr_service_a_name}:latest ${var.account_id}.dkr.ecr.${var.region}.amazonaws.com/${var.ecr_service_a_name}:latest
docker push ${var.account_id}.dkr.ecr.${var.region}.amazonaws.com/${var.ecr_service_a_name}:latest

echo "complete"
cd ..

cd service-b
unzip ./*.zip -d .
rm -rf *.zip
cd service-b

echo "complete"
aws ecr get-login-password --region ${var.region} | docker login --username AWS --password-stdin ${var.account_id}.dkr.ecr.${var.region}.amazonaws.com
docker build -t ${var.ecr_service_b_name} .
docker tag ${var.ecr_service_b_name}:latest ${var.account_id}.dkr.ecr.${var.region}.amazonaws.com/${var.ecr_service_b_name}:latest
docker push ${var.account_id}.dkr.ecr.${var.region}.amazonaws.com/${var.ecr_service_b_name}:latest

echo "complete"
cd ..
cd ..
cd service-c
unzip ./*.zip -d .
rm -rf *.zip
cd service-c

echo "complete"
aws ecr get-login-password --region ${var.region} | docker login --username AWS --password-stdin ${var.account_id}.dkr.ecr.${var.region}.amazonaws.com
docker build -t ${var.ecr_service_c_name} .
docker tag ${var.ecr_service_c_name}:latest ${var.account_id}.dkr.ecr.${var.region}.amazonaws.com/${var.ecr_service_c_name}:latest
docker push ${var.account_id}.dkr.ecr.${var.region}.amazonaws.com/${var.ecr_service_c_name}:latest
EOF

  tags = {
    "Name" = "${var.prefix}-bastion"
  }
}

