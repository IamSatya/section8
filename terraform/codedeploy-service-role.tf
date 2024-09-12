# create a service role for codedeploy
resource "aws_iam_role" "codedeploy_service" {
  name = "codedeploy-service-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "codedeploy.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# attach AWS managed policy called AWSCodeDeployRole
# required for deployments which are to an EC2 compute platform
resource "aws_iam_role_policy_attachment" "codedeploy_service" {
  role       = "${aws_iam_role.codedeploy_service.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
}