# JudgeBox Deployment

This repository manages the infrastructure and deployment of the JudgeBox platform using Terraform for infrastructure provisioning and Kubernetes for application deployment.

## Architecture Overview

The infrastructure consists of:
- VPC with public and private subnets
- Bastion host for secure access
- NGINX load balancer
- K3s (lightweight Kubernetes) cluster
- NAT Gateway for private subnet internet access

## Repository Structure
```
judgebox-deployment/
├── .github/
│   └── workflows/
│       ├── deploy.yaml     # Deployment workflow
│       └── destroy.yaml    # Infrastructure cleanup workflow
├── manifests/
│   ├── applications.yaml   # Application deployments
│   ├── config.yaml        # ConfigMaps and Secrets
│   ├── databases.yaml     # Database deployments
│   ├── namespace.yaml     # Kubernetes namespace
│   └── nginx-config.yaml  # NGINX configuration
├── terraform/
│   ├── main.tf           # Main infrastructure
│   ├── variables.tf      # Variable definitions
│   ├── outputs.tf        # Output definitions
│   └── versions.tf       # Provider versions
└── README.md
```

## Infrastructure Components

### AWS Resources
- **VPC**: `10.0.0.0/16`
  - Public Subnet: `10.0.1.0/24`
  - Private Subnet: `10.0.2.0/24`

### EC2 Instances
- **Bastion Host**: t2.micro in public subnet
- **NGINX Load Balancer**: t2.micro in public subnet
- **K3s Server**: t2.medium in private subnet

### Security Groups
- Bastion: Allow SSH from specified IPs
- NGINX: Allow HTTP/HTTPS from anywhere
- K3s: Allow traffic from NGINX and Bastion

## Kubernetes Components

### Applications
- NestJS Backend: Port 30000
- Flask Judge Service: Port 30001

### Databases
- PostgreSQL
- MongoDB
- Redis

## Deployment Process

### Prerequisites
1. AWS Account with proper permissions
2. GitHub repository secrets configured:
   ```
   AWS_ACCESS_KEY_ID
   AWS_SECRET_ACCESS_KEY
   SSH_PRIVATE_KEY
   SSH_PUBLIC_KEY
   KNOWN_HOSTS
   ```

### Deployment Steps

1. **Infrastructure Deployment**:
   ```bash
   # Triggered via GitHub Actions
   # Manual trigger: Navigate to Actions → Deploy Infrastructure and Application → Run workflow
   ```

2. **Application Deployment**:
   ```bash
   # Automatically runs after infrastructure deployment
   # Deploys Kubernetes manifests in this order:
   # 1. Namespace
   # 2. ConfigMaps and Secrets
   # 3. Databases
   # 4. Applications
   ```

### Destroying Infrastructure
```bash
# Navigate to Actions → Destroy Infrastructure → Run workflow
```

## Security Considerations

1. **Network Security**:
   - Private subnet for sensitive components
   - Bastion host for secure access
   - Security groups with minimum required access

2. **Access Control**:
   - SSH access only through bastion
   - NGINX as reverse proxy
   - Kubernetes RBAC enabled

3. **Secrets Management**:
   - Sensitive data stored in Kubernetes secrets
   - GitHub secrets for credentials
   - No hardcoded credentials

### Logs
```bash
# Application logs
kubectl logs -n judgebox deployment/nestjs-backend
kubectl logs -n judgebox deployment/flask-judge

# Database logs
kubectl logs -n judgebox deployment/postgres
kubectl logs -n judgebox deployment/mongodb
kubectl logs -n judgebox deployment/redis
```
## License

This project is licensed under the MIT License.