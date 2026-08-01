
This project provisions a complete AWS infrastructure using Terraform, including:
	• Custom VPC
	• Public subnets across two AZs
	• Internet Gateway
	• Route tables
	• Modified default security group
	• Two EC2 instances with user‑data
	• Application Load Balancer (ALB)
	• Target group + health checks
	• Listener on port 80
	• Output of ALB DNS name
This setup mirrors real‑world production architectures.

🚀 Architecture Overview
Internet
   |
Application Load Balancer
   |
Target Group
   |
-------------------------------------
|               |                   |
EC2 Instance 1  EC2 Instance 2      (Auto‑scaling ready)
Subnet A        Subnet B
   |               |
Public Route Table + Internet Gateway
   |
VPC (10.0.0.0/16)

📁 Project Structure
main.tf
variables.tf
outputs.tf
userdata.sh
userdata1.sh
diagrams/
  architecture.png

🧩 Key Terraform Resources
VPC
Creates the main network environment.
Subnets
Two public subnets in different AZs for high availability.
Internet Gateway
Enables outbound internet access.
Route Table
Routes 0.0.0.0/0 traffic to the IGW.
Security Group
Allows HTTP (80) and SSH (22).
EC2 Instances
Two web servers deployed across subnets.
Application Load Balancer
Distributes traffic across EC2 instances.
Target Group + Health Checks
Ensures only healthy instances receive traffic.
Listener
Listens on port 80 and forwards to the target group.

🛠️ How to Deploy
Initialize Terraform
terraform init
Validate configuration
terraform validate
Preview changes
terraform plan
Apply infrastructure
terraform apply -auto-approve

🌐 Access the Application
After deployment, Terraform outputs:
loadbalancerdns = myalb-1234567890.us-east-2.elb.amazonaws.com
Access it in your browser:
http://<ALB-DNS-NAME>
You should see responses from both EC2 instances.

🧪 Testing




