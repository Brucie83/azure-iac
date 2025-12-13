# Azure Infrastructure Deployment using Bicep (Modular Architecture)

This repository contains an **enterprise-grade modular Infrastructure-as-Code (IaC)** project built using **Azure Bicep**.
It provisions a complete environment including:

* Virtual Network & Subnet
* Network Security Group (NSG)
* Public IP Address
* Network Interface (NIC)
* Storage Account
* Azure Key Vault + Secret injection
* Windows Server 2022 Virtual Machine
* Custom Script Extension (`init.ps1`) for post-provisioning configuration
* Managed Identity for the VM
* Boot Diagnostics

This project demonstrates **best practices in ARM/Bicep modularization, secure secret handling, dependency chaining, reusable IaC patterns, and enterprise CI/CD workflows**.

---

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

This modular structure ensures **loose coupling, clarity, and long-term maintainability**, following cloud-native IaC standards.

---

## CI/CD Workflow Overview (Enterprise Pattern)

This repository implements a **clear separation between Continuous Integration (CI) and Continuous Deployment (CD)** using GitHub Actions and protected environments.

### CI/CD Flow Diagram

```text
┌────────────┐
│   Push /   │
│ Pull Req   │
└─────┬──────┘
      │
      ▼
┌────────────┐
│  Validate  │
│  (Bicep)   │
│            │
│ - build    │
│ - format   │
│ - lint     │
└─────┬──────┘
      │
      ▼
┌────────────┐
│  What-If   │
│  (Azure)   │
│            │
│ - preview  │
│ - non-blk  │
└─────┬──────┘
      │
      │  (Manual trigger only)
      ▼
┌────────────┐
│ Deploy Dev │◄─────────────── Run workflow (deploy=true)
│            │
│ Env: dev   │
│ Approval   │
└────────────┘
```

### Key Characteristics

* **CI runs automatically** on `push` and `pull_request`
* **CD is manual only** via `workflow_dispatch`
* Deployment requires:

  * Explicit input: `deploy=true`
  * Manual approval via GitHub Environment (`dev`)
* Azure What-If is **informational and non-blocking**, allowing flexibility in constrained subscriptions

This design mirrors **real enterprise delivery pipelines**, where CI is automated and CD is gated by human approval.

---

## Repository Structure

```bash
azure-iac/
│
├── main.bicep                # Root orchestrator
├── main.parameters.json      # Deployment parameters
├── bootstrap.bicep           # Bootstrap resources (Key Vault, initial secrets)
├── bootstrap.parameters.json
│
├── modules/
│   ├── network.bicep         # VNet + Subnet
│   ├── nsg.bicep             # NSG
│   ├── publicip.bicep        # Public IP
│   ├── nic.bicep             # NIC
│   ├── storage.bicep         # Storage Account
│   ├── keyvault.bicep        # Key Vault
│   └── vm.bicep              # Windows Server 2022 VM
│
├── scripts/
│   └── init.ps1              # Custom Script Extension
│
└── .github/
    └── workflows/
        └── ci.yml            # Enterprise CI/CD pipeline
```

---

## Secret Handling (Secure by Design)

Instead of passing the VM admin password directly to the VM module, this architecture follows **Azure security best practices**:

* Password is provided only once via parameters
* It is securely stored in **Azure Key Vault**
* The VM retrieves the password at deployment time using a **Key Vault reference**
* The password is never stored in templates, logs, or pipeline output

This pattern prevents credential leakage and aligns with enterprise security policies.

---

## Custom Script Extension (`init.ps1`)

The VM includes a Custom Script Extension that downloads and runs a PowerShell script hosted in this repository:

```bash
fileUris: [
  'https://raw.githubusercontent.com/brucie83/azure-iac/main/scripts/init.ps1'
]
commandToExecute: 'powershell.exe -ExecutionPolicy Unrestricted -File init.ps1'
```

This script can be extended to:

* Install IIS or other roles
* Configure services
* Apply security baselines
* Register monitoring agents
* Perform post-provisioning automation

---

## Deployment Instructions

Before deploying, ensure you are logged into your Azure subscription:

```bash
az login
az account set --subscription "<SUBSCRIPTION-ID>"
```

### 1. Create a resource group

```bash
az group create \
  --name rg-devops-lab \
  --location eastus
```

### 2. Generate the parameters file

```bash
az bicep generate-params -f main.bicep --out-file main.parameters.json
```

### 3. Deploy the infrastructure

```bash
az deployment group create \
  --resource-group rg-devops-lab \
  --template-file main.bicep \
  --parameters @main.parameters.json
```

---

## Validation & What-If

Validate and compile the Bicep templates:

```bash
az bicep build -f main.bicep
```

Preview infrastructure changes without creating resources:

```bash
az deployment group what-if \
  --resource-group rg-devops-lab \
  --template-file main.bicep \
  --parameters @main.parameters.json
```

---

## GitHub Actions CI Pipeline (Multistage)

The repository includes a **multistage GitHub Actions pipeline** designed to follow enterprise CI/CD practices.

### Implemented Stages

**Stage 1 – Validate (CI)**

* Bicep formatting
* Bicep linting
* Template compilation
* No Azure authentication required

**Stage 2 – Azure What-If (CI)**

* Runs after validation
* Authenticates using a Service Principal
* Executes Azure What-If
* Does not create resources
* Non-blocking for environment or subscription constraints

**Stage 3 – Deploy (CD)**

* Triggered manually only
* Requires explicit input (`deploy=true`)
* Protected by GitHub Environment approval (`dev`)

---

---

## Security & Identity Notes (Enterprise Context)

This project currently authenticates to Azure using a Service Principal stored as a GitHub Secret.
This approach was chosen due to limited access to the Azure tenant (borrowed subscription), where identity configuration
(App Registrations, Federated Credentials) is not available.

In a full enterprise Azure environment, this authentication model would be replaced with
**GitHub Actions OIDC (Workload Identity Federation)** to eliminate long-lived credentials and enforce
the principle of least privilege.

Planned enterprise improvements include:

- Replace static Service Principal secrets with OIDC-based authentication
- Scope permissions at Resource Group level instead of subscription-wide access
- Remove long-lived credentials from GitHub Secrets
- Use per-environment identities (dev / prod) for improved auditability
- Preserve the existing CI/CD flow while strengthening security posture

The current pipeline structure is intentionally designed to support this transition
without requiring changes to the overall CI/CD workflow.

---

## Best Practices Implemented

✔ Modular Bicep architecture
✔ Secure secret handling with Key Vault
✔ Separation of bootstrap and workload deployments
✔ Dependency chaining via module outputs
✔ Managed Identity usage
✔ Boot Diagnostics enabled
✔ Custom Script Extension automation
✔ Enterprise CI/CD with CI vs CD separation
✔ Manual deployment approval gates
✔ Environment-agnostic pipeline design

---

## Deployment Notes & Azure Subscription Constraints

This project was validated using Azure What-If and ARM template validation.

When tested in **personal or low-usage Azure subscriptions**, VM deployment may fail due to **SKU capacity restrictions** in certain regions.

Key points:

* Infrastructure components deploy and validate correctly
* Templates compile successfully
* What-If completes without dependency errors
* VM creation may fail only due to unavailable compute SKUs

The pipeline and templates are designed to operate correctly in **standard enterprise Azure environments** where capacity is available.

---

## Author

**Bruno Mijail Díaz Barba**
Cloud & DevOps Engineer — Azure | Bicep | Terraform | CI/CD
GitHub: [https://github.com/brucie83]

⭐ Give this repo a star if it helped you
