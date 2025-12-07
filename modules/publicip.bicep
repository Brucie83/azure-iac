@description('Nombre base de la VM usado para nombrar la IP')
param vmName string

@description('Ubicacion donde se creara la Public IP')
param location string


resource publicIp 'Microsoft.Network/publicIPAddresses@2023-05-01' = {
  name: '${vmName}-pip'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
  }
}

output publicIpId string = publicIp.id
