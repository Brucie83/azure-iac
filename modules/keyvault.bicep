@description('Nombre del Key Vault')
param keyVaultName string

@description('Ubicacion del Key Vault')
param location string

@description('Contraseña del admin para guardar en secrets')
@secure()
param adminpassword string

@description('Nombre del secret para guardar la contraseña del admin')
param secretName string = 'vmAdminPassword'

resourse keyVault 'Microsoft.KeyVault/vaults@2023-02-01' = {
  name: keyVault
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    enableSoftdelete: true
    enabledForDeployment: true
    enabledForTemplateDeployment: true
    enabledForDiskEncryption: true
    accessPolicies: [
      {
        tenantId: subscription().tenantId
        objectId: tenant().objectId
        permissions: {
          secrets: [
            'get'
            'list'
            'set'
          ]
        }
      }
    ]
  }
}

resource secret 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = {
  parent: keyVault
  name: secretName
  properties: {
    value: adminpassword
  }
}

output keyVaultId string = keyVault.id
output secretId string = secret.id
