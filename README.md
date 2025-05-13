# Smart Media Insights Platform

A cloud-native, event-driven architecture for media upload, processing, and insights using AWS, Kubernetes, Terraform, and serverless tools.

---

## Overview

This project automates a platform that allows users to upload media files, trigger image analysis using Rekognition and natural-language processing using Comprehend, and retrieve results via a scalable API—all built with microservices, Lambdas, and managed Kubernetes (EKS).

---

## Architecture
![image](https://github.com/user-attachments/assets/1027b0a2-42bd-4cc5-8911-4259184b7a30)
- **VPC**: Multi-AZ public/private subnets, NAT gateways, and secure routing
- **IAM & KMS**: Fine-grained roles and a customer-managed encryption key
- **Storage**: Encrypted S3 buckets for uploads, DynamoDB for lookups, RDS for structured metadata
- **Streaming**: Kinesis Data Stream triggers event processing
- **Serverless**: Lambda functions connected to S3 and Kinesis
- **Containers**: Flask-based microservices containerized and deployed to EKS via Helm
- **Ingress**: Application Load Balancer (ALB) with AWS WAF and optional TLS termination

---

## Components

### 1. Infrastructure-as-Code (Terraform in `/infra`)
- Modules for:
  - VPC, EKS, RDS, IAM, Kinesis, S3, Lambda, WAF, KMS
- Uses remote backend via S3 and DynamoDB for state management

### 2. service (`/services`)
- `media_service`: Accepts files and stores them in S3, Reads analysis results from RDS and serves via API

### 3. Serverless Functions (`/lambda`)
- `analyze_image`: S3-triggered Lambda that calls Rekognition
- `process_stream`: Kinesis-triggered Lambda that calls Comprehend and writes to RDS

---

## Prerequisites

| Tool           | Minimum Version |
|----------------|------------------|
| Python         | 3.8+             |
| Terraform      | 1.3+             |
| AWS CLI        | configured       |
| Docker         | latest           |
| kubectl & Helm | latest           |

AWS Resources required beforehand:
- S3 bucket for Terraform backend
- DynamoDB table for Terraform locking

---

## Deployment steps

# 1. Provision Infrastructure
      cd infra
      terraform init
      terraform apply
      This sets up:
      
      VPC, subnets, NAT gateway
      
      EKS cluster and node group
      
      RDS MySQL instance
      
      S3 bucket for uploads
      
      IAM roles and policies for Lambda

# 2. Build & Push Docker Image
      cd services/media_service
      docker build -t media_service .
      docker tag media_service:latest 741448960679.dkr.ecr.us-east-1.amazonaws.com/media_service:latest
      docker push 741448960679.dkr.ecr.us-east-1.amazonaws.com/media_service:latest
# 3. Deploy Flask App via Helm
      helm upgrade --install media-service ./helm --namespace default
# 4. Package and Deploy Lambda Functions
      cd lambda
      ./build.ps1  # Creates analyze_image.zip and process_stream.zip

# Apply changes using Terraform
cd ../infra
terraform apply
5. Test the Platform

# Upload image
curl -X POST -F "file=@cat.jpg" http://<ingress-ELB>/upload

# Get analysis result
curl "http://<ingress-ELB>/result?id=cat.jpg"


# Project Structure
📁 Project Structure
<pre> ```
SmartMediaInsights/
├── infra/                             # Terraform root module and configuration
│   ├── main.tf                        # Orchestrates all modules
│   ├── provider.tf                    # AWS provider and region setup
│   ├── backend.tf                     # Backend state (S3 + DynamoDB lock)
│   ├── variables.tf                   # Input variables
│   ├── outputs.tf                     # Output values for use elsewhere
│   ├── terraform.tfvars               # Variable values (e.g. passwords, names)
│   └── modules/                       # Reusable Terraform modules
│       ├── vpc/                       # VPC, public/private subnets, IGW, NAT
│       ├── bastion/                   # Bastion EC2 instance in public subnet
│       ├── eks/                       # EKS cluster and managed node groups
│       ├── rds/                       # RDS MySQL instance + subnet group + SG
│       ├── s3/                        # Encrypted upload bucket with event triggers
│       ├── kinesis/                   # Kinesis stream for async events
│       ├── dynamodb/                  # Lookup table for sentiment tags (optional)
│       ├── iam/                       # Roles and policies for EKS, Lambda, S3
│       ├── lambda/                    # Lambda deployments (Rekognition + Comprehend)
│       └── security/                  # Security groups for RDS, Lambda, bastion, EKS
│
├── lambda/                            # Source for serverless functions
│   ├── analyze_image/                 # Triggered by S3 object creation
│   │   └── handler.py                 # Uses Rekognition and sends to Kinesis
│   ├── process_stream/               # Triggered by Kinesis stream
│   │   └── handler.py                 # Uses Comprehend and writes to RDS
│   ├── build.ps1                      # PowerShell script to zip and deploy both Lambdas
│   └── package/                       # Temporary build directory for dependencies
│
├── services/
│   └── media_service/              # Flask service (upload + result)
│       ├── app.py
│       ├── Dockerfile
│       ├── requirements.txt
│       └── helm/                   # Helm chart
│           ├── values.yaml
│           ├── Chart.yaml
│           └── templates/
│               ├── deployment.yaml
│               ├── service.yaml
│               ├── ingress.yaml
│               ├── secret.yaml
│               ├── configmap.yaml
│               ├── hpa.yaml
│               ├── _helpers.tpl
|                
│
├── scripts/                           # Optional: helper scripts (e.g. zip/test/deploy)
│   └── port-forward.sh                # Port forward commands for local curl
│
└── README.md                          # Overview, architecture, deployment steps``` </pre>

