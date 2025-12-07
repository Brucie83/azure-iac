param storageName string
param location string

resource sa 'Microsoft.Storage/storageAccounts@023-01-01' = {
  name: storageName
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}

output storageid string = sa.id
output storageNameOut string = sa.name
