/* @description('Nombre del Resourse Group destino')
param rgName string */


@description('Ubicacion de los recursos')
param location string = resourceGroup().location

@description('Nombre de la vNet')
param vnetName string = 'dev-vnet'

@description('Prefijo de direcciones de la VNet')
param vnetAddress string = '10.0.0.0/16'

@description('Prefijo de la subnet principal')
param subnetAddress string = '10.0.1.0/24'

@description('Nombre de la vm')
param vmName string = 'dev-vm-01'

@description('Tamaño de la vm')
param vmSize string = 'Standard_D2s_v3'

@description('Nombre del admin de la vm')
param adminUsername string = 'azureuser'

@secure()
@description('Password del admin de la vm')
param adminPassword string

module network './modules/network.bicep' = {
  name: 'networkModule'
  params: {
    vnetName: vnetName
    vnetAddress: vnetAddress
    subnetAddress: subnetAddress
    location: location
  }
}

module nsg './modules/nsg.bicep' = {
  name: 'nsgModule'
  params: {
    nsgName:  '${vmName}-nsg'
    location: location
  }
}

module publicIp './modules/publicip.bicep' = {
  name: 'publicIpModule'
  params: {
    vmName: vmName
    location: location
  }
}

module nic './modules/nic.bicep' = {
  name: 'nicModule'
  params: {
    vmName: vmName
    location: location
    subnetId: network.outputs.subnetId
    publicIpId: publicIp.outputs.publicIpId
    nsgId: nsg.outputs.nsgId
  }
}

module keyvault './modules/keyvault.bicep' = {
  name: 'deploy-kv'
  params: {
    keyVaultName: '${vmName}-kv'
    location: location
    adminPassword: adminPassword
    secretName: 'vmAdminPassword'
  }
}

module storage './modules/storage.bicep' = {
  name: 'deploy-sa'
  params: {
    storageName: 'devvmsa01'
    location: location
  }
}


module vm './modules/vm.bicep' = {
  name: 'vmModule'
  params: {
    vmName: vmName
    vmSize: vmSize
    adminUsername: adminUsername
    adminPassword: adminPassword
    location: location
    nicId: nic.outputs.nicId
    storageNameOut: storage.outputs.storageNameOut
  }
}
