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

### 2. Microservices (`/services`)
- `upload_service`: Accepts files and stores them in S3
- `results_service`: Reads analysis results from RDS and serves via API

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

## Setup Instructions

### 1. Clone & Initialize

```bash
git clone https://github.com/yourusername/SmartMediaInsights.git
cd SmartMediaInsights

2. Initialize Terraform
cd infra
terraform init
terraform apply
3. Build and Push Microservice Containers
# Example: Upload Service
cd services/upload_service
docker build -t upload_service:latest .
docker tag upload_service:latest <your-ecr-url>/upload_service:latest
docker push <your-ecr-url>/upload_service:latest
Repeat for results_service.

4. Deploy to EKS with Helm
helm upgrade --install upload-service services/upload_service/helm --namespace production --create-namespace
helm upgrade --install results-service services/results_service/helm --namespace production
5. Update Lambda Code (if changed)
aws lambda update-function-code \
  --function-name dev-process-stream \
  --zip-file fileb://infra/modules/lambda/process_stream.zip
How It Works
/upload → Upload Service saves file to S3

S3 event → Triggers analyze_image Lambda → Rekognition → metadata → Kinesis

Kinesis → Triggers process_stream Lambda → Comprehend → RDS

/results/{file} → Results Service reads from RDS and returns insights

Testing
kubectl port-forward svc/upload-service 9090:5000 -n production
curl -X POST http://localhost:9090/upload -F file=@/path/to/image.jpg

kubectl port-forward svc/results-service 9091:5000 -n production
curl http://localhost:9091/results/image.jpg
Security & Best Practices
IAM roles with least-privilege

VPC subnet isolation

All storage encrypted (S3, RDS, Kinesis)

ALB protected by WAF

TLS-ready Ingress support

📁 Project Structure
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
├── services/                          # Microservices deployed to EKS
│   ├── upload_service/                # Accepts files and uploads to S3
│   │   ├── app.py                     # Flask application logic
│   │   ├── Dockerfile                 # Builds Docker image
│   │   └── helm/                      # Helm chart for Kubernetes deployment
│   │       ├── Chart.yaml
│   │       ├── values.yaml
│   │       └── templates/
│   │           ├── deployment.yaml
│   │           ├── service.yaml
│   │           └── secret.yaml
│   ├── results_service/              # Reads RDS and returns analysis
│   │   ├── app.py                     # Flask app with /results/<id>
│   │   ├── Dockerfile
│   │   └── helm/
│   │       ├── Chart.yaml
│   │       ├── values.yaml
│   │       └── templates/
│   │           ├── deployment.yaml
│   │           ├── service.yaml
│   │           └── secret.yaml
│
├── scripts/                           # Optional: helper scripts (e.g. zip/test/deploy)
│   └── port-forward.sh                # Port forward commands for local curl
│
└── README.md                          # Overview, architecture, deployment steps

