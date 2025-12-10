@description('Nombre del Keyvault')
param keyVaultName string

@description('Ubicacion del Keyvault')
param location string

@description('Password inicial de admin')
@secure()
param adminPassword string

@description('Nombre del secret para guardar la contraseña del admin')
param secretName string = 'vmAdminPassword'

resource keyVault 'Microsoft.KeyVault/vaults@2023-02-01' = {
  name: keyVaultName
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    enableSoftDelete: true
    enabledForDeployment: true
    enabledForTemplateDeployment: true
    enabledForDiskEncryption: true
    accessPolicies: [
      {
        tenantId: subscription().tenantId
        objectId: subscription().subscriptionId
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

resource secret 'Microsoft.Keyvault/vaults/secrets@2023-02-01' = {
  name: secretName
  parent: keyVault
  properties: {
    value: adminPassword
  }
}

output keyVaultId string = keyVault.id
