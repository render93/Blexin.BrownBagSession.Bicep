param location string
param environment string
param kvResourceName string

param planResourceName string
param funcResourceName string
param storageAccountName string
param storageAccountId string
param appInsightsInstrumentationKey string
@secure()
param appInsightsConnectionString string

param dbConnectionStringSecretUri string
var appPlanConfigurationMap = {
  dev: {
    appServicePlan: {
      sku: {
        name: 'F1'
        tier: 'Free'
      }
    }
  }
  test: {
    appServicePlan: {
      sku: {
        name: 'F1'
        tier: 'Free'
      }
    }
  }
  prod: {
    appServicePlan: {
      sku: {
        name: 'P1'
        tier: 'Premium'
      }
    }
  }
}

resource kv 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: kvResourceName
}

resource accessPolicy 'Microsoft.KeyVault/vaults/accessPolicies@2022-07-01' = {
  name: 'add'
  properties: {
    accessPolicies: [
      {
        objectId: func.identity.principalId
        tenantId: subscription().tenantId
        permissions: {
          secrets:[
            'get'
            'list'
          ]
        }
      }
    ]
  }
  parent: kv
}

resource plan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: planResourceName
  location: location
  sku: appPlanConfigurationMap[environment].appServicePlan.sku
  properties: {}
}

resource func 'Microsoft.Web/sites@2022-03-01' = {
  name: funcResourceName
  kind: 'functionapp'
  location: location
  identity:{
    type: 'SystemAssigned' // enable system assigned manage identity
  }
  properties: {
    serverFarmId: plan.id
    httpsOnly: true
  }

  resource funcSettingsAppiProd 'config@2022-03-01' = {
    name: 'appsettings'
    properties: {
      AzureWebJobsStorage: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};AccountKey=${listKeys(storageAccountId,'2019-04-01').keys[0].value}'
      FUNCTIONS_EXTENSION_VERSION: '~4'
      FUNCTIONS_WORKER_RUNTIME: 'dotnet'
      DbConnectionString: '@Microsoft.KeyVault(SecretUri=${dbConnectionStringSecretUri})' // Key Vault reference
      APPINSIGHTS_INSTRUMENTATIONKEY: (environment == 'prod') ? appInsightsInstrumentationKey : ''
      APPLICATION_INSIGHTS_CONNECTION_STRING: (environment == 'prod') ? appInsightsConnectionString : ''
      ApplicationInsightsAgent_EXTENSION_VERSION: (environment == 'prod') ? '~3' : ''
      APPSERVICEAPPLOGS_TRACE_LEVEL: (environment == 'prod') ? 'Info' : ''
    }
  }
}

output id string = plan.id
