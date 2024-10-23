locals {
  endpoint_policies = {
    s3 = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Sid       = "AllowS3Access"
          Effect    = "Allow"
          Principal = "*"
          Action = [
            "s3:GetObject",
            "s3:ListBucket",
            "s3:PutObject"
          ]
          Resource = [
            "arn:aws:s3:::*",
            "arn:aws:s3:::*/*"
          ]
        }
      ]
    })

    dynamodb = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Sid       = "AllowDynamoDBAccess"
          Effect    = "Allow"
          Principal = "*"
          Action = [
            "dynamodb:GetItem",
            "dynamodb:PutItem",
            "dynamodb:DeleteItem",
            "dynamodb:Scan",
            "dynamodb:Query",
            "dynamodb:UpdateItem"
          ]
          Resource = [
            "*"
          ]
        }
      ]
    })

    ec2 = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect    = "Allow"
          Principal = "*"
          Action = [
            "ec2:DescribeInstances",
            "ec2:DescribeImages",
            "ec2:DescribeTags",
            "ec2:DescribeInstanceAttribute",
            "ec2:DescribeVpcAttribute",
            "ec2:DescribeInstanceStatus",
            "ec2:DescribeSecurityGroups",
            "ec2:DescribeNetworkInterfaces",
            "ec2:DescribeKeyPairs",
            "ec2:DescribeVpcEndpoints",
            "ec2:DescribeRouteTables",
            "ec2:CreateRoute",
            "ec2:DeleteRoute",
            "ec2:ModifyInstanceAttribute",
            "ec2:ModifyVpcEndpoint",
            "ec2:AttachNetworkInterface",
            "ec2:DetachNetworkInterface",
            "ec2:CreateSecurityGroup",
            "ec2:DeleteSecurityGroup",
            "ec2:AuthorizeSecurityGroupIngress",
            "ec2:AuthorizeSecurityGroupEgress",
            "ec2:RevokeSecurityGroupIngress",
            "ec2:RevokeSecurityGroupEgress",
            "ec2:CreateNetworkInterface",
            "ec2:DeleteNetworkInterface",
            "ec2:AssignPrivateIpAddresses",
            "ec2:UnassignPrivateIpAddresses",
          ]
          Resource = ["*"]
        }
      ]
    })

    kms = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect    = "Allow"
          Principal = "*"
          Action = [
            "kms:Encrypt*",
            "kms:Decrypt*",
            "kms:ReEncrypt*",
            "kms:GenerateDataKey*",
            "kms:Describe*"
          ]
          Resource = ["*"]
        }
      ]
    })

    elasticloadbalancing = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "elasticloadbalancing:*"
          ]
          Effect    = "Allow"
          Resource  = "*"
          Principal = "*"
        }
      ]
    })

    logs = jsonencode({
      Version = "2012-10-17",
      Statement = [
        {
          Effect    = "Allow",
          Principal = "*",
          Action = [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents",
          ],
          Resource = "*",
        },
      ],
    })

    sns = jsonencode({
      Version = "2012-10-17",
      Statement = [
        {
          Effect    = "Allow",
          Principal = "*",
          Action = [
            "sns:Publish",
            "sns:Subscribe",
            "sns:Receive",
          ],
          Resource = "*",
        },
      ],
    })

    sqs = jsonencode({
      Version = "2012-10-17",
      Statement = [
        {
          Effect    = "Allow",
          Principal = "*",
          Action = [
            "sqs:GetQueueAttributes",
            "sqs:GetQueueUrl",
            "sqs:ListQueues",
            "sqs:SendMessage",
            "sqs:ReceiveMessage",
            "sqs:DeleteMessage",
          ],
          Resource = "*",
        },
      ],
    })

    rds = jsonencode({
      Version = "2012-10-17",
      Statement = [
        {
          Effect    = "Allow",
          Principal = "*",
          Action = [
            "rds:*",
          ],
          Resource = "*",
        },
      ],
    })

    ecs = jsonencode({
      Version = "2012-10-17",
      Statement = [
        {
          Effect    = "Allow",
          Principal = "*",
          Action = [
            "ecs:*",
          ],
          Resource = "*",
        },
      ],
    })
  }
}
