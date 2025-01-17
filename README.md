
# Supply Bridge Infrastructure

This repository contains the infrastructure as code (IaC) for the Supply Bridge project using Terraform.

## Prerequisites

- Terraform >= 1.0.0
- Azure CLI
- Docker Desktop
- PostgreSQL client (psql)

## Project Structure

supply-bridge-infrastructure/
├── environments/ # Environment-specific configurations
│ ├── test/
│ ├── preprod/
│ └── prod/
├── modules/ # Reusable Terraform modules
└── docker/ # Local development setup

## Local Development Setup

1. Clone the repository:
git clone https://github.com/your-org/supply-bridge-infrastructure.git
cd supply-bridge-infrastructure


2. Set up environment variables:
cp .env.example .env
Edit .env with your values
source .env

3. Start local PostgreSQL:
cd docker
docker-compose up -d

4. Test the connection:
psql -h localhost -U $POSTGRES_USER -d $POSTGRES_DB

## Azure Deployment

1. Login to Azure:
az login
az account set --subscription $ARM_SUBSCRIPTION_ID

2. Initialize Terraform:
cd environments/test
terraform init

3. Plan the changes:
terraform plan \
-var-file=terraform.tfvars \
-var-file=secrets.tfvars

4. Apply the changes:
terraform apply \
-var-file=terraform.tfvars \
-var-file=secrets.tfvars


## Environment Deployment

### Test Environment
cd environments/test
terraform init
terraform plan -var-file=terraform.tfvars -var-file=secrets.tfvars
terraform apply -var-file=terraform.tfvars -var-file=secrets.tfvars

### Preprod Environment
cd environments/preprod
terraform init
terraform plan -var-file=terraform.tfvars -var-file=secrets.tfvars
terraform apply -var-file=terraform.tfvars -var-file=secrets.tfvars


### Production Environment
cd environments/prod
terraform init
terraform plan -var-file=terraform.tfvars -var-file=secrets.tfvars
terraform apply -var-file=terraform.tfvars -var-file=secrets.tfvars


## Security Notes

- Never commit secrets.tfvars files
- Use Azure Key Vault for secret management
- Rotate credentials regularly
- Use managed identities where possible
- Keep your .env file secure and never commit it

## Maintenance

- Regularly update provider versions
- Monitor resource usage
- Review access policies
- Backup Terraform state



# 1. Initial Azure Setup
az login
az account set --subscription "74758fb5-8634-421f-959b-e6a6b0a66c84"

# 2. Create Service Principal for Terraform
az ad sp create-for-rbac --name "supply-bridge-terraform" --role Contributor --scopes /subscriptions/74758fb5-8634-421f-959b-e6a6b0a66c84

# 3. Create Storage Account for Terraform State
az group create --name supply-bridge-tfstate-rg --location westeurope

az storage account create \
--name supplybridgetfstate \
--resource-group supply-bridge-tfstate-rg \
--location westeurope \
--sku Standard_LRS \
--encryption-services blob

# Get storage account key
ACCOUNT_KEY=$(az storage account keys list \
--resource-group supply-bridge-tfstate-rg \
--account-name supplybridgetfstate \
--query '[0].value' -o tsv)

# Create container
az storage container create \
--name tfstate \
--account-name supplybridgetfstate \
--account-key $ACCOUNT_KEY

# 4. Set up environment variables
cp .env.example .env
# Edit .env with your values from service principal output
source .env

# 5. Create secrets.tfvars for your environment
cd environments/test  # or preprod/prod
cp secrets.tfvars.example secrets.tfvars
# Edit secrets.tfvars with your actual values

# 6. Initialize Terraform
terraform init

# 7. Validate the configuration
terraform validate

# 8. Plan the deployment
terraform plan \
-var-file=terraform.tfvars \
-var-file=secrets.tfvars \
-out=tfplan

# 9. Apply the configuration
terraform apply tfplan