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

```bash
Resource Group
│
├── Virtual Network (VNet)
│   ├── Subnet
│   └── NSG association
│
├── Public IP
│
├── Network Security Group (NSG)
│
├── NIC
│   ├── Subnet association
│   └── Public IP association
│
├── Storage Account (Boot Diagnostics)
│
├── Key Vault
│   └── Secret: vmAdminPassword
│
├── Virtual Machine (Windows Server 2022)
│   ├── Managed Identity
│   ├── Boot Diagnostics
│   └── Custom Script Extension
│       └── init.ps1 (downloaded from GitHub)
```



This modular structure ensures loose coupling, clarity, and maintainability, following cloud-native IaC standards.

## Repository Structure
```bash

azure-iac/
│
├── main.bicep                # Root orchestrator
├── parameters.json           # Deployment parameters
│
├── modules/
│   ├── network.bicep         # VNet + Subnet
│   ├── nsg.bicep             # NSG
│   ├── publicip.bicep        # Public IP
│   ├── nic.bicep             # NIC
│   ├── storage.bicep         # Storage Account
│   ├── keyvault.bicep        # Key Vault + Secret
│   └── vm.bicep              # Windows Server 2022 VM
│
├── scripts/
│   └── init.ps1              # Custom Script Extension
│
└── .github/
    └── workflows/
        └── ci.yml            # CI pipeline: validate, format, lint, build, what-if
```


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
```bash
az login
az account set --subscription "<SUBSCRIPTION-ID>"
```

1 Create a resource group
```bash
az group create \
  --name rg-devops-lab \
  --location eastus
```

2 Generate the parameters file
```bash
az bicep generate-params -f main.bicep --out-file main.parameters.json
```

Fill in your admin password:
```json
{
  "parameters": {
    "adminPassword": {
      "value": "YourStrongPassword123!"
    }
  }
}
```

3 Deploy the infrastructure
```bash
az deployment group create \
  --resource-group rg-devops-lab \
  --template-file main.bicep \
  --parameters @main.parameters.json
```
## Validation & What-If
Build and validate Bicep
```bash
az bicep build -f main.bicep
```

What-If (Preview changes)
```bash
az deployment group what-if \
  --resource-group rg-devops-lab \
  --template-file main.bicep \
  --parameters @parameters.json
```

## GitHub Actions CI Pipeline (Already Implemented)

The repository includes a CI workflow (ci.yml) that performs:

✔ Bicep formatting
✔ Bicep linting
✔ Template compilation to ARM JSON
✔ Azure What-If with support for an empty secret {}
✔ Conditional execution when AZURE_CREDENTIALS is not defined

This allows the project to be developed and validated even without an Azure subscription, avoiding pipeline failures.

## Best Practices Implemented

✔ Modular Bicep architecture
✔ Secret handling with Key Vault
✔ Strong separation of modules and parameters
✔ Dependency chaining through module outputs
✔ Reusable VM automation with Custom Script Extension
✔ Managed Identity enabled
✔ Production-ready naming conventions
✔ Boot Diagnostics configured
✔ CI pipeline with formatting/linting/what-if

## Next Improvements (optional)

Add optional deployment workflow (workflow_dispatch)

Multi-environment parameters (dev/stage/prod)

Environment-driven NSG rules

Load Balancer / App Gateway modules

Automated application bootstrap

Integration with Terraform / GitHub Environments

## Author

Bruno Mijail Díaz Barba
Cloud & DevOps Engineer — Azure | Bicep | Terraform | CI/CD
GitHub: github.com/brucie83

## Give this repo a star if it helped you!
