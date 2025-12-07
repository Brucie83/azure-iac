@description('Nombre de la vnet')
param vnetName string

@description('Prefijo de la vnet')
param vnetAddress string

@description('Prefijo de la subnet principal')
param subnetAddress string

@description('Ubicacion donde se desplefara la VNet')
param location string


resource vnet 'Microsoft.Network/virtualNetworks@2023-05-01' = {
    name: vnetName
    location: location
    properties: {
        addressSpace: {
            addressPrefixes: [
                vnetAddress
            ]
        }
        subnets: [
            {
                name: 'default'
                properties: {
                    addressPrefix: subnetAddress
                }
            }
        ]
    }
}


output subnetId string = vnet.properties.subnets[0].id
