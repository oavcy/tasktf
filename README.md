This Terraform module deploys an EKS cluster with Karpenter in an existing VPC.

## Usage
1. Update `subnet_ids` in `terraform.tfvars` with the existing subnet IDs.
2. Run the following commands:
   ```sh
   terraform init
   terraform apply -auto-approve
   ```

## Running a Pod on Specific Architecture
To deploy a pod on a specific architecture, add the following nodeSelector to your pod specification:

- For x86:
  ```yaml
  nodeSelector:
    kubernetes.io/arch: amd64
  ```

- For ARM (Graviton):
  ```yaml
  nodeSelector:
    kubernetes.io/arch: arm64
  ```
