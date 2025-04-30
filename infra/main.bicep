// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

targetScope = 'subscription'

@minLength(1)
@maxLength(64)
@description('Name of the environment that can be used as part of naming resource convention')
param environmentName string

@minLength(1)
@description('Primary location for all resources')
param location string

@description('User principal ID')
param principalId string

var roleDefStorageContributor = subscriptionResourceId(
  'Microsoft.Authorization/roleDefinitions',
  'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
)
var roleDefEventHubsReceiver = subscriptionResourceId(
  'Microsoft.Authorization/roleDefinitions',
  'a638d3c7-ab3a-418d-83e6-5f17a39d4fde'
)
var roleDefEventHubsSender = subscriptionResourceId(
  'Microsoft.Authorization/roleDefinitions',
  '2b629674-e913-4c01-ae53-ef4638d8f975'
)
var tags = {
  'azd-env-name': environmentName
}

resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: 'rg-rustify-${environmentName}'
  location: location
  tags: tags
}

module resources 'resources.bicep' = {
  name: 'resources'
  scope: rg
  params: {
    environmentName: environmentName
    location: location
    principalId: principalId
  }
}

resource roleStorageContributor 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(rg.id, environmentName, principalId, roleDefStorageContributor)
  properties: {
    roleDefinitionId: roleDefStorageContributor
    principalId: principalId
  }
}

resource roleEventHubsReceiver 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(rg.id, environmentName, principalId, roleDefEventHubsReceiver)
  properties: {
    roleDefinitionId: roleDefEventHubsReceiver
    principalId: principalId
  }
}

resource roleEventHubsSender 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(rg.id, environmentName, principalId, roleDefEventHubsSender)
  properties: {
    roleDefinitionId: roleDefEventHubsSender
    principalId: principalId
  }
}

output AZURE_RESOURCE_GROUP string = rg.name
output AZURE_PRINCIPAL_ID string = resources.outputs.AZURE_PRINCIPAL_ID
output AZURE_EVENTHUBS_URL string = resources.outputs.AZURE_EVENTHUBS_URL
output AZURE_EVENTHUBS_NAME string = resources.outputs.AZURE_EVENTHUBS_NAME
output AZURE_STORAGE_URL string = resources.outputs.AZURE_STORAGE_URL
