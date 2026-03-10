# Node DevOps App

A Node.js API with PostgreSQL and Redis, running on Docker locally and AWS ECS Fargate in production.

=====Running locally======

1. You need Docker and Docker Compose v2.

2. run npm install to install dependencies and package-lock.json 

3. docker compose up --build 

note: you can set your passwords in .env file

The app waits for Postgres and Redis health checks to pass before accepting traffic.

To stop and clean up:


5. docker compose down -v

To run tests without Docker:

6. npm install
7. npm test

Tests mock all external services, so nothing else needs to be running.

==Accessing the app==

The API runs at http://localhost:3000.

/health  | Liveness probe — always returns { "status": "ok" }     
/status  | Checks Postgres and Redis, reports service health        
/process | Send { "data": "..." }, result is cached for 60 sec   


curl http://localhost:3000/health

curl http://localhost:3000/status

curl -X POST http://localhost:3000/process \
  -H "Content-Type: application/json" \
  -d '{"data": "hello mellitus"}'



=====Deploying on Production=====

A ci/cd pipeline is already set up to deploy the application to AWS ECS Fargate.

CI/CD (GitHub Actions)

The pipeline (ci-cd.yml) runs on every push to main ( production branch) and develop (staging branch)

One pipeline run per branch. Staging deploys automatically; production requires manual approval. Production uses rolling update deployments with automatic rollback on health check failure.

The stages in the pipeline are:

1. Lint & Test — ESLint + Jest with coverage
2. Build & Push — Docker image → GitHub Container Registry
3. Staging — rolling ECS deploy + smoke test
4. Production — manual approval, then rolling update deploy via CodeDeploy

Add these secrets under (Settings > Secrets > Actions):

 Secret                  Description                          
 AWS_ACCESS_KEY_ID       IAM key for deployments              
 AWS_SECRET_ACCESS_KEY   IAM secret key                       
 AWS_REGION              e.g. us-west-1                    

GITHUB_TOKEN is automatic.

==Design decisions==
==Security== 

The container runs as a non-root user. Secrets are never stored in code; they are injected from AWS Secrets Manager at runtime. The ALB enforces HTTPS (TLS 1.3) and all backend services sit in private subnets with no public IPs. IAM roles follow least privilege separate execution and task roles.


========Infrastructure========

The infrastructure is built using Terraform. The code is in the infra-terraform folder.

To run the infrastructure:

1. cd infra-terraform
2. Set up your AWS credentials.
3. Initialize Terraform:
terraform init
4. terraform validate to check if the code is valid
5. terraform plan to see what resources will be created
6. terraform apply to create the resources.

note: you can set your variables in the variables.tf file or in a .tfvars file.