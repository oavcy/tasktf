# deploy an EKS cluster with Karpenter

provider "aws" {
  region = "us-east-1"
}

# Fetch latest EKS version
data "aws_eks_cluster_version" "latest" {}

# Create EKS cluster in an existing VPC
resource "aws_eks_cluster" "main" {
  name     = "ao-cluster"
  role_arn = aws_iam_role.eks.arn
  version  = data.aws_eks_cluster_version.latest.version

  vpc_config {
    subnet_ids = var.subnet_ids
  }
}

# IAM Role for EKS
resource "aws_iam_role" "eks" {
  name = "eks-cluster-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks" {
  role       = aws_iam_role.eks.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# Deploy Karpenter
resource "aws_iam_role" "karpenter" {
  name = "karpenter-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "karpenter.k8s.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "karpenter" {
  role       = aws_iam_role.karpenter.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

# Karpenter provisioners for x86 and arm64
resource "kubectl_manifest" "karpenter_provisioners" {
  yaml_body = <<YAML
apiVersion: karpenter.k8s.aws/v1alpha5
kind: Provisioner
metadata:
  name: default
spec:
  requirements:
    - key: "node.kubernetes.io/instance-type"
      operator: In
      values: ["m6i.large", "c6g.large"]
    - key: "topology.kubernetes.io/zone"
      operator: In
      values: ["us-east-1a", "us-east-1b"]
  limits:
    resources:
      cpu: "100"
      memory: "500Gi"
  providerRef:
    name: default
  ttlSecondsAfterEmpty: 30
YAML
}

# Readme file content
data "local_file" "readme" {
  filename = "README.md"
  content = <<EOT
# Terraform EKS with Karpenter

