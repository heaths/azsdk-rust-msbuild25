// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using './main.bicep'

param environmentName = readEnvironmentVariable('AZURE_ENV_NAME', 'dev')
param location = readEnvironmentVariable('AZURE_LOCATION', 'westus')
param principalId = readEnvironmentVariable('AZURE_PRINCIPAL_ID', '')
