# Azure Infrastructure Deployment using Bicep (Modular Architecture)

This repository contains an enterprise-grade modular Infrastructure-as-Code (IaC) project built using Azure Bicep.
It provisions a complete environment including:

Virtual Network & Subnet

Network Security Group (NSG)

Public IP Address

Network Interface (NIC)

Storage Account

Azure Key Vault + Secret injection

Windows Server 2022 Virtual Machine

Custom Script Extension (init.ps1) for post-provisioning configuration

Managed Identity for the VM

Boot Diagnostics

This project demonstrates best practices in ARM/Bicep modularization, secret handling, dependency chaining, and reusable IaC patterns.

## Architecture Overview
┌Resource Group
│
├── Virtual Network (VNet)
│      └── Subnet
│
├── Network Security Group (NSG)
│
├── Public IP
│
├── NIC
│      ├── NSG association
│      ├── Subnet association
│      └── Public IP association
│
├── Storage Account (Boot Diagnostics)
│
├── Key Vault
│      └── Secret: vmAdminPassword
│
└── Virtual Machine (Windows Server 2022)
       ├── Managed Identity
       ├── Boot Diagnostics
       ├── Custom Script Extension
       │      └── init.ps1 (from GitHub)




This modular structure ensures loose coupling, clarity, and maintainability, following cloud-native IaC standards.

## Repository Structure
azure-iac/
│
├── main.bicep                    # Root orchestrator template
│
├── modules/
│   ├── network.bicep             # VNet + Subnet module
│   ├── nsg.bicep                 # NSG module
│   ├── publicip.bicep            # Public IP module
│   ├── nic.bicep                 # NIC module
│   ├── storage.bicep             # Storage Account module
│   ├── keyvault.bicep            # Key Vault + Secret module
│   └── vm.bicep                  # Virtual Machine module
│
└── scripts/
    └── init.ps1                  # Custom script executed on the VM

## Secret Handling (Secure by Design)

Instead of passing the VM admin password directly to the VM module, this architecture follows Azure security best-practices:

Password is provided only once in main.parameters.json

It is securely sent to the Key Vault module

The Key Vault creates a Secret

The VM retrieves the password securely at deployment time

The VM never stores the password in the template or logs

This pattern prevents credential leakage and aligns with enterprise security policies.

## Custom Script Extension (init.ps1)

The VM includes an extension that downloads and runs a PowerShell script hosted in this repository:

fileUris: [
  'https://raw.githubusercontent.com/brucie83/azure-iac/main/scripts/init.ps1'
]
commandToExecute: 'powershell.exe -ExecutionPolicy Unrestricted -File init.ps1'


You can use this script to install packages, configure services, join domains, deploy apps, etc.

Example behavior (modify as needed):

Install IIS

Write logs to Storage

Apply security baselines

Register monitoring agents

## Deployment Instructions

Before deploying, ensure you are logged into your Azure subscription:

az login
az account set --subscription "<SUBSCRIPTION-ID>"

1 Create a resource group
az group create \
  --name rg-devops-lab \
  --location eastus

2 Generate the parameters file
az bicep generate-params -f main.bicep --out-file main.parameters.json


Fill in your admin password:

{
  "parameters": {
    "adminPassword": {
      "value": "YourStrongPassword123!"
    }
  }
}

3 Deploy the infrastructure
az deployment group create \
  --resource-group rg-devops-lab \
  --template-file main.bicep \
  --parameters @main.parameters.json

## Validation & Linting (Recommended)

Validate syntax:

az bicep build -f main.bicep


Validate deployment without creating resources:

az deployment group what-if \
  --resource-group rg-devops-lab \
  --template-file main.bicep \
  --parameters @main.parameters.json

## Best Practices Implemented

✔ Modular Bicep Architecture
✔ Secure secret handling via Key Vault
✔ Dependency chaining using outputs
✔ Custom Script Extension for post-deploy automation
✔ Managed Identity enabled on the VM
✔ Reusable components for future projects
✔ Clear separation between IaC, parameters, and scripts
✔ Boot Diagnostics with Storage Account
✔ Production-grade naming conventions

## Next Improvements (optional)

You can enhance this project by adding:

Azure DevOps pipeline YAML

GitHub Actions CI workflow (build + lint + what-if)

Domain join automation

Automated NSG rules based on environment (dev/stage/prod)

Modules for Load Balancer, App Gateway, AKS, Bastion, etc.

## Author

Bruno Mijail Díaz Barba
Cloud & DevOps Engineer — Azure | Bicep | Terraform | CI/CD
GitHub: github.com/brucie83

## Give this repo a star if it helped you!
