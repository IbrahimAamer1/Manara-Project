# Scalable Web Application with ALB and Auto Scaling - Terraform Implementation

This Terraform project deploys a highly available and scalable web application architecture on AWS, featuring EC2 instances, an Application Load Balancer (ALB), and Auto Scaling Groups (ASG).

## Architecture Overview

The architecture consists of:

-   **VPC**: A custom Virtual Private Cloud with public and private subnets across multiple Availability Zones.
-   **Networking**: Internet Gateway for public subnets, NAT Gateways for private subnets to allow outbound internet access.
-   **Security**: Security Groups configured for ALB, EC2 instances, and optionally RDS, following the principle of least privilege.
-   **Compute**: EC2 instances launched via an Auto Scaling Group using a Launch Template. A simple web server (httpd) is installed via user data for demonstration.
-   **Load Balancing**: An Application Load Balancer distributes traffic across the EC2 instances in the ASG.
-   **Database (Optional)**: An Amazon RDS instance (MySQL/PostgreSQL) deployed in private subnets with Multi-AZ enabled for high availability.
-   **Monitoring**: A CloudWatch Dashboard and basic CloudWatch Alarms (High CPU, ALB 5XX errors) with SNS notifications.

Refer to the `../architecture.md` file for a detailed description and diagram.

## Terraform Structure

The Terraform code is organized into modules for better reusability and maintainability:

```
terraform/
├── main.tf             # Root module configuration
├── variables.tf        # Root module variables
├── outputs.tf          # Root module outputs
├── providers.tf        # Provider configuration (AWS)
├── modules/
│   ├── vpc/            # VPC, Subnets, IGW, NAT Gateways, Route Tables
│   ├── security/       # Security Groups (ALB, EC2, RDS)
│   ├── compute/        # IAM Role, Launch Template, ALB, Target Group, ASG
│   ├── database/       # RDS Instance, DB Subnet Group (Optional)
│   └── monitoring/     # CloudWatch Dashboard, Alarms, SNS Topic
└── terraform.tfvars    # (Optional) File to specify variable values
```

## Prerequisites

1.  **Terraform**: Install Terraform (version 1.0 or later recommended).
2.  **AWS Account**: An active AWS account.
3.  **AWS Credentials**: Configure AWS credentials for Terraform (e.g., via environment variables, AWS credentials file, or IAM role).
4.  **EC2 Key Pair**: An existing EC2 Key Pair in the target AWS region. You need to provide its name in the `key_name` variable.

## Usage

1.  **Clone the Repository**: Clone this project repository to your local machine.
2.  **Navigate to Terraform Directory**: `cd scalable-web-app-project/terraform`
3.  **Create `terraform.tfvars` (Optional but Recommended)**: Create a file named `terraform.tfvars` in this directory to specify variable values, especially sensitive ones like `db_username`, `db_password`, and required ones like `key_name`. You can also override defaults like `aws_region` or `allowed_ssh_cidr`.

    Example `terraform.tfvars`:
    ```hcl
    aws_region       = "us-east-1"
    key_name         = "your-ec2-key-pair-name" # Replace with your key pair name
    allowed_ssh_cidr = "YOUR_IP_ADDRESS/32" # Replace with your IP address for SSH access

    # Only required if create_database = true
    # db_username      = "adminuser"
    # db_password      = "yoursecurepassword"
    ```

4.  **Initialize Terraform**: Run `terraform init` to download necessary providers and modules.
5.  **Plan Deployment**: Run `terraform plan` (optionally use `-var-file=terraform.tfvars` if you created the file) to review the resources that will be created.
6.  **Apply Deployment**: Run `terraform apply` (optionally use `-var-file=terraform.tfvars`) and confirm with `yes` to create the infrastructure.
7.  **Access Application**: Once applied, Terraform will output the DNS name of the ALB (`alb_dns_name`). Access this URL in your web browser.
8.  **Destroy Infrastructure**: When finished, run `terraform destroy` (optionally use `-var-file=terraform.tfvars`) to remove all created resources. **Warning**: This will delete all resources managed by this Terraform configuration.

## Customization

-   **Region**: Change the `aws_region` variable.
-   **Instance Type/AMI**: Modify `instance_type` and `ami_id` (or rely on the data source for latest Amazon Linux 2) in the compute module variables or root `variables.tf`.
-   **Database**: Set `create_database` to `false` to skip RDS creation. Adjust DB engine, version, credentials, etc., via variables.
-   **Networking**: Modify CIDR blocks (`vpc_cidr`, subnet CIDRs) in `variables.tf`.
-   **Security**: Update `allowed_ssh_cidr` to restrict SSH access. Adjust security group rules as needed within the security module.
-   **Scaling**: Tune ASG parameters (`asg_min_size`, `asg_max_size`, `asg_desired_capacity`, `cpu_target_value`) in `variables.tf`.
-   **Application Code**: Modify the `user_data` script in `modules/compute/main.tf` to deploy your specific web application instead of the simple "Hello World" page.
-   **Tags**: Update `common_tags` in `variables.tf`.

## Outputs

The following outputs are provided after a successful `terraform apply`:

-   `alb_dns_name`: The public DNS name to access the web application.
-   `vpc_id`: The ID of the created VPC.
-   `public_subnet_ids`: IDs of the public subnets.
-   `private_app_subnet_ids`: IDs of the private application subnets.
-   `db_instance_address` / `db_instance_endpoint`: RDS instance address/endpoint (if created).
-   `cloudwatch_dashboard_name`: Name of the CloudWatch dashboard.
-   `sns_topic_arn`: ARN of the SNS topic for alarms.

