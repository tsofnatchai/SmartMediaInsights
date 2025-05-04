# Smart Media Insights Platform

This repository contains:
- Terraform modules to provision AWS infrastructure
- Containerized microservices (`upload_service`, `results_service`)
- Serverless functions (Lambda) in `lambda/`
- CI/CD pipeline configurations

## Prerequisites
- Python 3.8+
- Terraform 1.3+
- Docker & kubectl & Helm
- AWS credentials configured

## Usage
1. Run `python create_structure.py` to scaffold files.
2. Fill in Terraform code under `infra/`.
3. Build and push Docker images for services.
4. Deploy Terraform, then Helm charts into EKS.
5. Configure CI/CD in `ci-cd/`.
###############################################################

Project structure and flow:

1.Infrastructure-as-Code (infra/)

backend.tf/provider.tf/variables.tf set up remote state (S3 + DynamoDB lock) and AWS provider.

modules/ each subfolder stands up one slice of   AWS estate:

vpc: a multi-AZ VPC with public/private subnets, IGW, NAT gateways

iam: Roles for   EKS nodes, Lambdas, Terraform, CI agents

kms: A customer-managed key for encryption-at-rest

eks: The EKS control plane and managed node groups running in   VPC

rds: A Multi-AZ, encrypted PostgreSQL instance in private subnets

dynamodb: A serverless lookup table for low-latency key/value data

s3: An encrypted bucket for user uploads (and later, Firehose)

kinesis: A streaming channel for real-time events (orders, image tags)

lambda: Two functions—one to analyze images via Rekognition, another to process Kinesis batches into Comprehend + DB writes

waf: A regional Web ACL protecting   ALB from common attacks

infra/main.tf ties all of those modules together in the right order, passing outputs (e.g. VPC IDs, subnets, role ARNs) into the next module.

2.Microservices (services/…)

upload_service:

A small Flask app that accepts file uploads and writes them to   S3 bucket.

Containerized via Dockerfile and pushed to ECR.

Deployed into   EKS cluster via a Helm chart (Chart.yaml + values.yaml + Kubernetes manifests).

results_service:

A companion Flask app that reads order status (from RDS) and returns it over HTTP.

Also Dockerized and deployed via its own Helm chart.

3.Serverless Glue (lambda/…)

analyze_image: Triggered by S3 “object created” events, calls Rekognition to extract labels/metadata.

process_stream: Subscribed to Kinesis, processes batches through Comprehend and writes results back into DynamoDB or RDS.

4.CI/CD (ci-cd/…)

Jenkinsfile or azure-pipelines.yml automate the entire flow:

terraform init/apply to stand up or update infra

docker build + docker push for each microservice

helm upgrade --install to roll out new container versions into EKS

################################################################################

Overall Data & Request Flow

1.Upload Path:

A client calls Upload Service (/upload) with a file.

The service saves the file into the encrypted S3 bucket.

S3 automatically emits an ObjectCreated event, which triggers the analyze_image Lambda.

The Lambda calls AWS Rekognition to extract labels/metadata, then writes those results into RDS

2.Order Events:

When an end user places an order (out of scope of these microservices),  application emits a record into the Kinesis Data Stream.

The process_stream Lambda is subscribed to that stream; it processes each record by calling AWS Comprehend (for natural‑language analysis) or other services, 
then persists the enriched event back into   database.

3.Results Path:

A client calls Results Service (/results/{order_id}) to retrieve status or analysis.

The service reads from RDS, returning the latest metadata or order state.

4.Kubernetes & CI/CD:

All microservices are packaged into Docker containers and stored in ECR.

Terraform provisions the VPC, EKS cluster, RDS, DynamoDB, Kinesis, Lambdas, IAM roles, KMS keys, and WAF rules.

Helm charts deploy Upload and Results services into EKS with ConfigMaps, Secrets, and Horizontal Pod Autoscalers.

  CI/CD pipelines (Jenkins or Azure Pipelines) orchestrate: Terraform → Docker build/push → Helm deploy → end‑to‑end smoke tests.

5.Security & Monitoring:

VPC isolates public (ingress) from private (compute & data) subnets.

IAM roles follow least‑privilege for EKS nodes, Lambdas, and CI.

KMS encrypts data at rest in S3, RDS, and Kinesis encryption.

WAF protects the ALB fronting   services from common web attacks.

This flow ensures a fully automated, secure, and scalable event‑driven pipeline for media insights and order processing.
6.A bastion host (sometimes called a “jump box”) is simply a small, well-hardened VM that sits out in your public subnet 
and acts as the sole gateway into everything that lives in your private subnets.
An EC2 instance with a public IP and a very locked-down security group (typically only SSH from your office or home network).
It runs only the minimal services you need (e.g. SSH) and nothing else—so it’s a very low-surface attack target.
In our Smart Media Insights Platform, the bastion is how operators and devs securely administer the EKS cluster’s worker 
nodes, debug live services, or even perform one-off database fixes, while still keeping the bulk of the infrastructure completely locked down from the Internet.
########################################################################################################################
Prerequisite:

on AWS CLI:

I created S3 bucket in AWS:
aws s3api create-bucket --bucket terraform-state-bucket-tsofnat --region us-east-1
and added it permission->policy:
{
"Version": "2012-10-17",
"Statement": [
{
"Sid": "AllowELBAccessLogs",
"Effect": "Allow",
"Principal": {
"Service": "elasticloadbalancing.amazonaws.com"
},
"Action": [
"s3:ListBucket",
"s3:GetObject",
"s3:PutObject"
],
"Resource": [
"arn:aws:s3:::terraform-state-bucket-tsofnat",
"arn:aws:s3:::terraform-state-bucket-tsofnat/*"
]
}
]
}

create dynamo db table in AWS:
aws dynamodb create-table --table-name terraform-locking-user-tsofnat --attribute-definitions AttributeName=LockID,AttributeType=S --key-schema AttributeName=LockID,KeyType=HASH --provisioned-throughput ReadCapacityUnits=1,WriteCapacityUnits=1


Order of Steps
Prepare Remote State:
Ensure your DynamoDB table (terraform-locking-user-tsofnat) and the S3 state bucket (terraform-state-bucket-tsofnat) exist. Configure your backend.tf accordingly.

Provision AWS Infrastructure with Terraform:
Run in your project root:

bash
1.
terraform init
terraform plan
terraform apply
This will create your VPC, EKS cluster, RDS, S3 bucket for Firehose, IAM roles, Kinesis stream & Firehose delivery stream, security groups, etc.
got:
Outputs:
cluster_endpoint = "https://D019E9D7D4B8A9C9ABCA5A6EF9E5D742.gr7.us-east-1.eks.amazonaws.com"
eks_cluster_ca_data = "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURCVENDQWUyZ0F3SUJBZ0lJR1pZdkN2TWNLQU13RFFZSktvWklodmNOQVFFTEJRQXdGVEVUTUJFR0ExVUUKQXhNS2EzVmlaWEp1WlhSbGN6QWVGdzB5TlRBME1qZ3dOVFU0TXpKYUZ3MHpOVEEwTWpZd05qQXpNekphTUJVe
ApFekFSQmdOVkJBTVRDbXQxWW1WeWJtVjBaWE13Z2dFaU1BMEdDU3FHU0liM0RRRUJBUVVBQTRJQkR3QXdnZ0VLCkFvSUJBUUM3VFdXZTRGVzl3ck9SZmZwb3pnYVZCK2tGT1k1MU9CaHkzU1RmTHU0RWJ5blF5cUtySzEyQTZMK2gKN2kzTzdtL1kxc09TYWc4eEQ5ajhPdTZGS3grWUlEcXloL0dkc0gyRTBFV
DlDUDFrb2lMNG1SY0cwdVNzbGRjWApYTGRPRjlOc1pCYktuUXl0NEE5ZXFNbjZObW1vaWZFUDBwOUhqNVFicWFqNGNPeG9oTjBQWHFsdTZVYXN1RHM2CkV5TDZBM3ZSNHFCeHNBVzBZeWlodVFHVmxOcTBid0F0RDBwd3lzSzBkNEQ2c3Bpb1NKd1prRkJzVmFXSlNDaTcKMHNETXpzZmVaTlR5ZmZvZnRXdGJJc
E9nTWYwZTVUVW9PY0Z3Zi9zeTZ2SlhTOWN5MUVxSmtuT1pkVzBGQVlabApmQTF6ZmdVaVE2SjVhaXpLekdza2Q3dnJtOVFoQWdNQkFBR2pXVEJYTUE0R0ExVWREd0VCL3dRRUF3SUNwREFQCkJnTlZIUk1CQWY4RUJUQURBUUgvTUIwR0ExVWREZ1FXQkJUZUFrdHNHWTEwMDBva3NMZ3NmTWhKMTdSQ0JqQVYKQ
mdOVkhSRUVEakFNZ2dwcmRXSmxjbTVsZEdWek1BMEdDU3FHU0liM0RRRUJDd1VBQTRJQkFRQS9pMWV5Q0NGVwp4Zm5DN3gvT1NyTitBUVlnL09oNmZjR0NJUnRibVM5dStTa3VnbXhVckx5anpWN0J0cEZjKytqejVOVXgrdXY0CkZpSUFjQkFPWFI3aVBnM0xva040N1BtZUNzTVBzSXI3SHZRMjk0M1JKV0QxZ
EJMSmxqakpNbkZnY25lT1dmSkoKc0o1bWNXUC80L1pQTXE3bzZxYWVvU2ZpSGF1SWdFUmxPd3ZheHo3OHlhNjE1ZjQ3WWh0bW05M053a01CMnZUMAo5TDZ0NHhpcFE2eEdNaml3VWYxbkZzdUxmRVZ1bFRielpJeEs5Ri82clFuUFU3MnlWeGw3Tkh6RG15NjQwc3ZJCnlaUmhtVXJaV1U3b0JheTlVemx5dTdPN2VzZFNKR2RPa0RWYkZZZm53SnBkd1JrRW9sSS9DV2lJd1FLb3RudnkKR2N4Q2R2enZ0QlhpCi0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K"
eks_cluster_endpoint = "https://D019E9D7D4B8A9C9ABCA5A6EF9E5D742.gr7.us-east-1.eks.amazonaws.com"
eks_cluster_name = "my-eks-cluster-smart"
kinesis_stream_name = "dev-events"
uploads_bucket_name = "dev-uploads-d4834098"



2.
docker build + docker push for each microservice
create ECR repositories for each service (upload-service and results-service):
aws ecr create-repository \
--repository-name upload_service \
--region $AWS_REGION

aws ecr create-repository \
--repository-name results_service \
--region $AWS_REGION

Docker installed and running locally.
export AWS_ACCOUNT_ID=741448960679
export AWS_REGION=us-east-1

# Optional prefix for all your repos
export ECR_REGISTRY=${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 741448960679.dkr.ecr.us-east-1.amazonaws.com

# Build
cd services/upload_service
docker build -t upload_service:latest .

# Tag
docker tag upload_service:latest \
$ECR_REGISTRY/upload_service:latest

# Push
docker push $ECR_REGISTRY/upload_service:latest

do the same for results_service
# Rebuild the image
cd services/results_service
docker build -t results_service:latest .

# Tag and push to ECR
docker tag results_service:latest $ECR_REGISTRY/results_service:latest
docker push $ECR_REGISTRY/results_service:latest

# Redeploy via Helm
cd to SmartMediaInsights(cd .. cd ..)
helm upgrade results-service ./services/results_service/helm --namespace production --install


3.
Deploy Terraform, then Helm charts into EKS.

Configure kubectl to talk to EKS
export AWS_REGION=us-east-1
export CLUSTER_NAME=$(terraform output -raw eks_cluster_name)
aws eks update-kubeconfig --region $AWS_REGION --name   $CLUSTER_NAME
kubectl get nodes should show  new EKS worker nodes in the Ready state.
kubectl get nodes
NAME                           STATUS   ROLES    AGE     VERSION
ip-10-0-101-246.ec2.internal   Ready    <none>   4h54m   v1.31.5-eks-5d632ec
Helm
a values.yaml pointing at ECR image
/PycharmProjects/SmartMediaInsights
$ helm upgrade --install upload-service services/upload_service/helm --namespace production --set image.repository=741448960679.dkr.ecr.us-east-1.amazonaws.com/upload_service --set image.tag=latest
helm upgrade --install results-service services/results_service/helm --namespace production --set image.repository=741448960679.dkr.ecr.us-east-1.amazonaws.com/results_service --set image.tag=latest

helm upgrade --install upload-service services/upload_service/helm --namespace production --create-namespace

verify with:
$ helm list --namespace production
NAME            NAMESPACE       REVISION        UPDATED                                 STATUS          CHART                   APP VERSION
results-service production      1               2025-04-28 14:31:48.822393 +0300 IDT    deployed        results-service-0.1.0   1.0
upload-service  production      1               2025-04-28 14:29:34.9934546 +0300 IDT   deployed        upload-service-0.1.0    1.0

kubectl get pods,svc,deploy -n production
NAME                                   READY   STATUS    RESTARTS   AGE
pod/results-service-7dbb469dc6-mt8xk   1/1     Running   0          73s
pod/upload-service-685f799d78-flwxg    1/1     Running   0          3m23s

NAME                      TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)   AGE
service/results-service   ClusterIP   172.20.163.203   <none>        80/TCP    73s
service/upload-service    ClusterIP   172.20.115.71    <none>        80/TCP    3m23s

NAME                              READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/results-service   1/1     1            1           73s
deployment.apps/upload-service    1/1     1            1           3m23s

test:
kubectl port-forward svc/upload-service 9090:5000 -n production
and on other bash terminal:
curl -v   -X POST http://127.0.0.1:9090/upload   -F file=@/c/Users/TsofnatChai/Documents/mytextfile.txt
Ingress DNS:
kubectl get ingress results-service -n production
NAME              CLASS   HOSTS                      ADDRESS   PORTS   AGE
results-service   alb     results.smartmedia.local             80      112m

EKS node security group:
sg-03b6b3caa439423c8

on rds sg: sg-00135d25e308139af
I added on inbound-> MYSQL/Aurora, port TCP 3306 source sg-03b6b3caa439423c8
so EKS Ec2 can connect to RDS
Only instances that are part of rds-sg can connect to this RDS on port 3306
EKS nodes are in SG sg-03b6b3caa439423c8, results-service pods

Full Flow Overview
User uploads a file via /upload

File goes into S3 bucket

S3 event triggers Lambda 1: analyze_image

Lambda calls Rekognition, gets labels, and sends result to Kinesis stream

Lambda 2: process_stream reads from Kinesis, runs Comprehend, and stores result into RDS

User retrieves analysis from results_service via /results/<file-name>

kubectl port-forward svc/results-service 9091:5000 -n production

kubectl port-forward svc/upload-service 9090:5000 -n production

to update lambda create zip file
SmartMediaInsights/lambda/process_stream
$ python3 -c "import zipfile; z = zipfile.ZipFile('process_stream.zip', 'w'); z.write('handler.py'); z.close()"
SmartMediaInsights/lambda/analyze_image
$ python3 -c "import zipfile; z = zipfile.ZipFile('analyze_stream.zip', 'w'); z.write('handler.py'); z.close()"

import the existing Lambda function into Terraform so it becomes managed
From the terraform root:
terraform import module.lambda.aws_lambda_function.process_stream dev-process-stream
terraform apply
Terraform will now:
See that dev-process-stream already exists
Update it (e.g., with env vars, zip file, etc.)
Create the Kinesis mapping if needed

check if the dev-process-stream Lambda executed:
$start = [math]::Round((Get-Date).AddMinutes(-10).ToUniversalTime().Subtract((Get-Date "1/1/1970")).TotalMilliseconds)
aws logs filter-log-events --log-group-name "/aws/lambda/dev-process-stream" --start-time $start

subnets used by lambda:
$ aws lambda get-function-configuration --function-name dev-process-stream --query 'VpcConfig.SubnetIds'
[                                                                                                                                                                                                                                      
"subnet-0df0592ed27b0d820",
"subnet-0af883c2d1f1d3b90"
]

deployment package with pymysql included:
mkdir -p lambda/process_stream/package
cd lambda/process_stream/package
pip install pymysql -t .
cp ../../handler.py .
in powershell: Compress-Archive -Path * -DestinationPath ..\..\..\..\infra\modules\lambda\process_stream.zip
Update the Lambda function:
aws lambda update-function-code \
--function-name dev-process-stream \
--zip-file fileb://infra/modules/lambda/process_stream.zip
