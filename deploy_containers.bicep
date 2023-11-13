@description('Location for all resources.')
param location string = resourceGroup().location

param containers array

param imageRegistryCredentials array
param ipAddress array

// use container registry module to create an instance of container instances
// resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-07-01' existing = {
//   name: 'crfishchain'
// }

param containerCount int = length(containers)

resource containerGroup 'Microsoft.ContainerInstance/containerGroups@2021-09-01' = [for i in range(0, containerCount): {
  name: containers[i][0].name
  location: location
  properties: {
    containers: containers[i]
    osType: 'Linux'
    imageRegistryCredentials: imageRegistryCredentials
    ipAddress: ipAddress[i]
  }

}]
