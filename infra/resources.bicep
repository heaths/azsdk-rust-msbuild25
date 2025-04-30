// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

@minLength(1)
@maxLength(64)
@description('Name of the environment that can be used as part of naming resource convention')
param environmentName string

@minLength(1)
@description('Primary location for all resources')
param location string

@description('User principal ID')
param principalId string

resource stg 'Microsoft.Storage/storageAccounts@2024-01-01' = {
  name: 'stg${uniqueString(resourceGroup().id, environmentName)}'
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    allowSharedKeyAccess: false
  }
}

resource eh 'Microsoft.EventHub/namespaces@2024-01-01' = {
  name: 'eh${uniqueString(resourceGroup().id, environmentName)}'
  location: location
  sku: {
    name: 'Standard'
    tier: 'Standard'
    capacity: 1
  }
  properties: {
    disableLocalAuth: true
  }
}

resource hub 'Microsoft.EventHub/namespaces/eventhubs@2024-01-01' = {
  name: 'hub${uniqueString(resourceGroup().id, environmentName)}'
  parent: eh
  properties: {
    messageRetentionInDays: 1
    partitionCount: 1
  }
}

output AZURE_PRINCIPAL_ID string = principalId
output AZURE_EVENTHUBS_URL string = eh.properties.serviceBusEndpoint
output AZURE_EVENTHUBS_NAME string = hub.name
output AZURE_STORAGE_URL string = stg.properties.primaryEndpoints.blob
