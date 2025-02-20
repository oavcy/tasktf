This Terraform module deploys an EKS cluster with Karpenter in an existing VPC.

## Usage
1. Update `subnet_ids` in `terraform.tfvars` with the existing subnet IDs.
2. Run the following commands:
   ```sh
   terraform init
   terraform apply -auto-approve
   ```

