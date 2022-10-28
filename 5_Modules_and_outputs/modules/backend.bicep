param location string
param environment string

param planResourceName string
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

param funcResourceName string
param storageAccountName string
param storageAccountId string
param appInsightsInstrumentationKey string
@secure()
param appInsightsConnectionString string
@secure()
param dbConnectionString string

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
      DbConnectionString: dbConnectionString
      APPINSIGHTS_INSTRUMENTATIONKEY: (environment == 'prod') ? appInsightsInstrumentationKey : ''
      APPLICATION_INSIGHTS_CONNECTION_STRING: (environment == 'prod') ? appInsightsConnectionString : ''
      ApplicationInsightsAgent_EXTENSION_VERSION: (environment == 'prod') ? '~3' : ''
      APPSERVICEAPPLOGS_TRACE_LEVEL: (environment == 'prod') ? 'Info' : ''
    }
  }
}

output id string = plan.id
