# Terraform WordPress Demo

**Author:** Geoffrey Edmund Moraes

**GitHub:** https://github.com/eddietorial/terraform-wordpress-demo

---

A portfolio project demonstrating Infrastructure as Code (IaC) with Terraform on AWS. This configuration provisions a fully functional WordPress site on an EC2 instance backed by a managed MySQL database on RDS, all within an isolated VPC.


---


## What This Project Demonstrates

- Writing modular, reusable Terraform configuration across multiple `.tf` files
- Provisioning a Virtual Private Cloud (VPC) with public subnets, an internet gateway, and route tables
- Using the `terraform-aws-modules/rds` community module to provision a managed MySQL 8.0 database on RDS
- Deploying an EC2 instance with a dynamically rendered `user_data` bootstrap script using the built-in `templatefile()` function
- Controlling network access with AWS security groups (least-privilege ingress rules per resource)
- Querying the latest Ubuntu 22.04 AMI at plan time using a `data` source
- Exposing useful post-deploy values (public IP, instance ARN) with output variables

---

## Project Structure

```
terraform-wordpress-demo/
├── main.tf                        # All AWS resources and the RDS module
├── locals.tf                      # Shared local values (tags, db name, db user)
├── variables.tf                   # Input variables (SSH public key path)
├── outputs.tf                     # Output values displayed after apply
├── files/
│   └── install_wordpress.sh       # Bootstrap script run on EC2 at first launch
└── .gitignore                     # Standard Terraform gitignore
```

---

## System Requirements

| Tool      | Version          |
|-----------|------------------|
| Terraform | >= 1.3           |
| AWS CLI   | >= 2.x           |
| An SSH key pair | `~/.ssh/id_rsa` / `id_rsa.pub` (or specify your own path) |

---

## AWS Credentials Setup

You need an IAM user with programmatic access and the following policies attached:

- `AmazonEC2FullAccess`
- `AmazonRDSFullAccess`
- `AmazonVPCFullAccess`

**Option 1: AWS CLI (recommended)**

```bash
aws configure
```

You will be prompted for your Access Key ID, Secret Access Key, region (`us-east-1`), and output format.

**Option 2: Environment variables**

```bash
export AWS_ACCESS_KEY_ID="your_access_key_id"
export AWS_SECRET_ACCESS_KEY="your_secret_access_key"
export AWS_DEFAULT_REGION="us-east-1"
```

---

## Setup and Usage

**1. Clone the repository**

```bash
git clone git@github.com:eddietorial/terraform-wordpress-demo.git
cd terraform-wordpress-demo
```

**2. Confirm your SSH public key path**

By default, the configuration reads `~/.ssh/id_rsa.pub`. If your key is in a different location, override the variable:

```bash
# Option A: pass it on the command line
terraform plan -var="ssh_public_key_path=/path/to/your/key.pub"

# Option B: create a terraform.tfvars file
echo 'ssh_public_key_path = "/path/to/your/key.pub"' > terraform.tfvars
```

**3. Initialize Terraform**

```bash
terraform init
```

This downloads the AWS provider and the `terraform-aws-modules/rds` module.

**4. Preview the execution plan**

```bash
terraform plan
```

**5. Deploy**

```bash
terraform apply
```

Enter `yes` when prompted. Provisioning takes approximately 10 minutes (RDS takes the longest).

On completion, Terraform prints the public IP of the instance:

```
Outputs:

instance_public_ip = "x.x.x.x"
instance_id        = "arn:aws:ec2:us-east-1:..."
```

**6. Access your WordPress site**

Open a browser and navigate to:

```
http://<instance_public_ip>
```

WordPress's installation wizard will load. You can also SSH into the instance:

```bash
ssh ubuntu@<instance_public_ip>
```

**7. Destroy all resources when done**

```bash
terraform destroy
```

This removes every resource this configuration created. Run this immediately after exploring to stay within free tier limits.

---

## Expected Outcome

After a successful `terraform apply` and allowing a few minutes for the `user_data` script to complete on the instance, visiting `http://<instance_public_ip>` loads the WordPress setup wizard. Completing the wizard produces a working WordPress site connected to the RDS MySQL database.

---

## AWS Free Tier Considerations

Both instance types used fall within the AWS Free Tier for the first 12 months of a new account:

| Resource    | Type           | Free Tier Limit              |
|-------------|----------------|------------------------------|
| EC2         | t3.micro       | 750 hrs/month                |
| RDS         | db.t3.micro    | 750 hrs/month, 20 GB storage |

Running `terraform destroy` immediately after the demo keeps costs at or near zero. Leaving the RDS instance running for a full month will incur charges if you exceed the free tier hours.

---

## Customizing and Scaling for Production

This demo is intentionally minimal. The following changes would be required before using this configuration in production:

**Security**

- Restrict SSH ingress (`port 22`) to a specific IP range rather than `0.0.0.0/0`
- Store the RDS password in AWS Secrets Manager or SSM Parameter Store and reference it via a `data` source rather than relying on the auto-generated value
- Enable HTTPS by adding an Application Load Balancer with an ACM certificate and redirecting port 80 to 443

**Scalability**

- Replace the single EC2 instance with an Auto Scaling Group behind a Load Balancer
- Move WordPress media uploads to an S3 bucket (using a plugin such as WP Offload Media) so instances remain stateless
- Enable RDS Multi-AZ for high availability and automated failover

**State Management**

- Configure a remote Terraform backend (S3 + DynamoDB state locking) so state is shared across team members and not stored locally

**Variables**

- Extract the AWS region, instance types, CIDR blocks, and availability zones into `variables.tf` with sensible defaults so the configuration is reusable across environments without editing source files

**Tagging**

- Expand the `locals.tags` map to include environment (`dev`, `staging`, `prod`), owner, and cost-center tags to support billing visibility and resource governance
