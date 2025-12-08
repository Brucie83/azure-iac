@description('Nombre de la VM para componer el nombre de la NIC')
param vmName string

@description('ID de la subnet donde se conectara la NIC')
param subnetId string

@description('ID de la Public IP para asociarla a la NIC')
param publicIpId string

@description('Ubicacion donde se desplegara la NIC')
param location string

@description('ID del NSG')
param nsgId string

resource nic 'Microsoft.Network/networkInterfaces@2023-05-01' = {
  name: '${vmName}-nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: subnetId
          }
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIpId
          }
        }
      }
    ]
    networkSecurityGroup: {
      id: nsgId
    }
  }
}

output nicId string = nic.id
