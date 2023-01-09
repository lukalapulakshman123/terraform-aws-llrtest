terraform {
  required_version = ">= 0.12.21"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.50.0"
    }
  }
}

resource "aws_iam_role" "role" {
  name = "${var.resource_prefix}-IntegrationRole"
  path = "/"

  inline_policy {
    name = "llrtestReadOnlyPolicy"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "apigateway:GET",
            "codebuild:BatchGetProjects",
            "codebuild:ListProjects",
            "codecommit:GetBranch",
            "codecommit:GetCommit",
            "codecommit:GetRepository",
            "codepipeline:GetPipeline",
            "codepipeline:ListTagsForResource",
            "ds:ListTagsForResource",
            "ec2:DescribeAccountAttributes",
            "ec2:GetEbsEncryptionByDefault",
            "eks:DescribeAddon"
          ]
          Effect   = "Allow"
          Resource = "*"
        },
      ]
    })
  }
  assume_role_policy = <<EOF
{
	"Version": "2012-10-17",
	"Statement": [{
		"Action": "sts:AssumeRole",
		"Principal": {
			"AWS": "${var.aws_account_id}"
		},
		"Condition": {
			"StringEquals": {
				"sts:ExternalId": "${var.external_id}"
			}
		},
		"Effect": "Allow",
		"Sid": ""
	}]
}
EOF

}

resource "aws_iam_role_policy_attachment" "viewaccesspolicy_attach" {
  policy_arn = "arn:aws:iam::aws:policy/job-function/ViewOnlyAccess"
  role       = aws_iam_role.role.name

}

variable "resource_prefix" {
  description = "Prefix to be used for naming new resources"
  type        = string
  default     = "cloudquery"
}

variable "aws_account_id" {
  description = "llr AWS account ID"
  type        = string
}

variable "external_id" {
  description = "Role external ID provided by llr"
  type        = string
}
