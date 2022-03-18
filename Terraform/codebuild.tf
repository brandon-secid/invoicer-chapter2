# Create CODEBUILD Project to replace CircleCI - See Section 2.3 in the book
variable "GITHUB_TOKEN" {
  type        = string
  description = "This env variables set by direnv in .envrc ."
}

variable "DOCKER_USER" {
  type        = string
  description = "This env variables set by direnv in .envrc ."
}

variable "DOCKER_KEY" {
  type        = string
  description = "This env variables set by direnv in .envrc ."
}

data "aws_caller_identity" "current" {}

locals {
    account_id = data.aws_caller_identity.current.account_id
}

resource "aws_codebuild_source_credential" "codebuild_gh_creds" {
  auth_type   = "PERSONAL_ACCESS_TOKEN"
  server_type = "GITHUB"
  token       = var.GITHUB_TOKEN
}

resource "aws_s3_bucket" "cbbucket" {
  bucket_prefix = "securedeveopsbook-"
  acl = "private"
}

resource "aws_iam_role" "cb_iam_role" {
  name = "codebuild_iam_role_securingdevops"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "cb_iam_policy" {
  role = aws_iam_role.cb_iam_role.name

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Resource": [
        "*"
      ],
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:CreateNetworkInterface",
        "ec2:DescribeDhcpOptions",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DeleteNetworkInterface",
        "ec2:DescribeSubnets",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeVpcs"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:CreateNetworkInterfacePermission"
      ],
      "Resource": [
        "arn:aws:ec2:us-east-1:${local.account_id}:network-interface/*"
      ],
      "Condition": {
        "StringEquals": {
          "ec2:Subnet": [
            "${aws_subnet.publicsubnets.arn}",
            "${aws_subnet.privatesubnets.arn}"
          ],
          "ec2:AuthorizedService": "codebuild.amazonaws.com"
        }
      }
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:*"
      ],
      "Resource": [
        "${aws_s3_bucket.cbbucket.arn}",
        "${aws_s3_bucket.cbbucket.arn}/*"
      ]
    }
  ]
}
POLICY
}

resource "aws_codebuild_project" "cb_project" {
  name          = "securingdevops-codebuild"
  description   = "build_project_for_securingdevopsbook"
  build_timeout = "5"
  service_role  = aws_iam_role.cb_iam_role.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  cache {
    type     = "S3"
    location = aws_s3_bucket.cbbucket.bucket
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:5.0"
    privileged_mode             = true
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "DOCKER_USER"
      value = var.DOCKER_USER
      type  = "PLAINTEXT"
    }

    environment_variable {
      name  = "DOCKER_PASS"
      value = var.DOCKER_KEY
      type  = "PLAINTEXT"
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "log-group"
      stream_name = "log-stream"
    }

    s3_logs {
      status   = "ENABLED"
      location = "${aws_s3_bucket.cbbucket.id}/build-log"
    }
  }

  source {
    type            = "GITHUB_ENTERPRISE"
    location        = "https://github.com/brandon-secid/invoicer-chapter2.git"
    git_clone_depth = 1

    git_submodules_config {
      fetch_submodules = true
    }
  }

  source_version = "master"

  vpc_config {
    vpc_id = aws_vpc.securedevops.id

    subnets = [
      aws_subnet.publicsubnets.id,
      aws_subnet.privatesubnets.id
    ]

    security_group_ids = [
      aws_security_group.allow_all.id
    ]
  }

  tags = {
    Environment = "Learning"
  }
}