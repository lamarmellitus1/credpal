This is a simple  node api application with postgreSQL and redis that checks the health of the api and returns the status of the api and the status of the database and the status of the redis. also it has a cache mechanism that caches the response of the api for 60 seconds.

# requirements
To run tests on Docker locally

1. Docker and Docker Compose v2
2. run npm install to install dependencies and package-lock.json 
3. docker compose up --build 

note: you can set your passwords in .env file

The app waits for Postgres and Redis health checks to pass before accepting traffic.

To stop and clean up:

4. docker compose down -v





To run tests without Docker:

5. npm install
6. npm test

Tests mock all external services, so nothing else needs to be running.





==Accessing the app==

The API runs at http://localhost:3000.

/health - Liveness probe — always returns { "status": "ok" }     
/status - Checks Postgres and Redis, reports service health        
/process - Send { "data": "..." }, result is cached for 60 sec   


curl http://localhost:3000/health



curl http://localhost:3000/status




curl -X POST http://localhost:3000/process \
  -H "Content-Type: application/json" \
  -d '{"data": "hello mellitus"}'






=====Deploying on Production=====

A ci/cd pipeline is already set up to deploy the application to AWS ECS Fargate.

CI/CD (GitHub Actions)

The pipeline (ci-cd.yml) runs on every push to main ( production branch)

Production uses rolling update deployments with automatic rollback on health check failure.

The stages in the pipeline are:

1. Lint & Test — ESLint + Jest with coverage
2. Build & Push — Docker image → aws ecr
3. Production — manual approval, then rolling update deploy


==Add these secrets under (Settings > Secrets > Actions)==

 Secret                  Description                          
 AWS_ACCESS_KEY_ID       IAM key for deployments              
 AWS_SECRET_ACCESS_KEY   IAM secret key                       
 AWS_REGION              eu-west-1                            
 AWS_ROLE_ARN_PRODUCTION   IAM role ARN for production deployments

GITHUB_TOKEN is automatic.

==Design decisions==
==Security== 

The container runs as a non-root user. Secrets are never stored in code; they are injected from AWS Secrets Manager at runtime. The ALB enforces HTTPS (TLS 1.3) and all backend services sit in private subnets with no public IPs. IAM roles follow least privilege separate execution and task roles.






========Infrastructure========

The infrastructure is built using Terraform, which is a tool that lets us create and manage AWS resources using code instead of clicking buttons in the AWS Console.

What we built:

 Networking: A private and secure "virtual room" (VPC) where our application lives.
 Security groups: Digital "bouncers" (Security Groups) that only let in the right traffic.
 Load Balancer: A "traffic controller" that receives requests from the internet and sends them to our application.
 Logging: A central "diary" (CloudWatch) where the application writes down everything it does, so we can troubleshoot if something goes wrong.
 Registry: A "storage locker" (ECR) for our Docker images.






Architectural Plan

This setup is built to be reliable and secure. If one part of AWS availability zone has a problem, the application stays online.

1. High Availability (Two Data Centers)
We use two different physical data centers (called Availability Zones) in the same region. (eu-west-1a, eu-west-1b)
We run copies of the application in both locations.
If one availability zone has a power outage or a problem, the other one keeps the application running without any interruption for our users.

2. Traffic Flow (How users reach our application)
Step 1: Users connect to the Application Load Balancer through the internet.
Step 2: The Load Balancer acts as a traffic controller. It checks which copy of the application is healthy and ready to handle traffic.
Step 3: The Load Balancer sends the user to the application running on ECS Fargate. The application is hidden in a private network (Private Subnet) so it cannot be reached directly from the internet, which keeps it safe from hackers.

3. Outbound Security
When the application needs to talk to the internet (for example, to pull updates), it uses a NAT Gateway. This acts like a one-way door: the application can send messages out, but the internet cannot send messages in unless they are invited.

Why AWS ECS Fargate?

I chose ECS Fargate to run this application because:
1. No Servers to Manage: I don't have to worry about patching or updating servers. AWS handles all the "hard part."
2. Self-Healing: If the application crashes, ECS automatically notices and starts a fresh copy.
3. Scales with You: If the application gets busy, it automatically adds more copies to handle the extra users.
4. Pay for what you use: I only pay for the CPU and Memory the application actually uses while it's running.








How to run the infrastructure:

1. cd infra-terraform
2. Set up your AWS credentials.
3. Initialize Terraform:
   terraform init
4. Run terraform validate to check if the code is valid.
5. Run terraform plan to see what resources will be created.
6. Run terraform apply to create the resources.

We can customize the settings (like the region or environment name) in the terraform.tfvars file.