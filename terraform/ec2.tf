provider "aws" {
  region                   = "us-east-1"
  shared_credentials_files = [pathexpand("csv-aws.txt")]
}

variable "dev" {
  type    = list(string)
  default = ["dev_server_one", "dev_server_two"]
}


variable "prod" {
  type    = list(string)
  default = ["prod_server_one", "prod_server_two"]
}

resource "aws_instance" "web" {
  ami           = "ami-0182f373e66f89c85"
  instance_type = "t3.micro"
  count = length(var.dev)
  key_name = "mlops"
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
  iam_instance_profile = aws_iam_instance_profile.s3readprofile.id
  user_data = "${file("code_deploy.sh")}"

  tags = {
    Name = var.dev[count.index]
    ENV = "DEV"
  }
}

resource "aws_instance" "prod" {
  ami           = "ami-0182f373e66f89c85"
  instance_type = "t3.micro"
  count = length(var.prod)
  key_name = "mlops"
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
  iam_instance_profile = aws_iam_instance_profile.s3readprofile.id
  user_data = "${file("code_deploy.sh")}"

  tags = {
    Name = var.prod[count.index]
    ENV = "PROD"
  }
}

# Create the role
resource "aws_iam_role" "s3-read-role" {
  name = "s3-read-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}


# Attach the policy to the role
resource "aws_iam_role_policy_attachment" "attach-s3" {
  role       = aws_iam_role.s3-read-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "attach-codedeploy" {
  role       = aws_iam_role.s3-read-role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeDeployFullAccess"
}

resource "aws_iam_role_policy_attachment" "attach-admin" {
  role       = aws_iam_role.s3-read-role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_instance_profile" "s3readprofile" {
  name = "s3readpolicy"
  role  = aws_iam_role.s3-read-role.name
}

