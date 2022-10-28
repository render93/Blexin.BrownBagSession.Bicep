param location string = resourceGroup().location // default parameter

@allowed([
  'dev'
  'test'
  'prod'
])
param environment string // parameter

param sqlAdministratorLogin string
@secure()
param sqlAdministratorPassword string // secure parameter

@allowed([
  'Standard_LRS'
  'Standard_GRS'
])
param storageSku string = 'Standard_LRS'

// variables
var storageResourceName = 'stbicepsession${environment}'
var planResourceName = 'plan-bicepsession-${environment}'
var funcResourceName = 'func-bicepsession-${environment}'
var sqlResourceName = 'sql-bicepsession-${environment}'
var sqldbResourceName = 'sqldb-bicepsession-${environment}'
var appiResourceName = 'appi-bicepsession-${environment}'
// configuration map
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

resource st 'Microsoft.Storage/storageAccounts@2021-08-01' = {
  name: storageResourceName
  location: location
  sku: {
    name: storageSku
  }
  kind: 'Storage'
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
  properties: {
    serverFarmId: plan.id
    httpsOnly: true  
  }

  resource funcSettingsAppiProd 'config@2022-03-01' = {
    name: 'appsettings'
    properties: {
      AzureWebJobsStorage: 'DefaultEndpointsProtocol=https;AccountName=${st.name};AccountKey=${st.listKeys().keys[0].value}}'
      FUNCTIONS_EXTENSION_VERSION: '~4'
      FUNCTIONS_WORKER_RUNTIME: 'dotnet'
      APPINSIGHTS_INSTRUMENTATIONKEY: (environment == 'prod') ? appi.properties.InstrumentationKey : ''
      APPLICATION_INSIGHTS_CONNECTION_STRING: (environment == 'prod') ? appi.properties.ConnectionString : ''
      ApplicationInsightsAgent_EXTENSION_VERSION: (environment == 'prod') ? '~3' : ''
      APPSERVICEAPPLOGS_TRACE_LEVEL: (environment == 'prod') ? 'Info' : ''
    }
  }
}

resource sqlServer 'Microsoft.Sql/servers@2022-02-01-preview' = {
  name: sqlResourceName
  location: location
  properties: {
    administratorLogin: sqlAdministratorLogin
    administratorLoginPassword: sqlAdministratorPassword
  }

  resource sqlDb 'databases@2022-02-01-preview' = { //'Microsoft.Sql/servers/databases@2022-02-01-preview'
    name: sqldbResourceName
    location: location
    //parent: sqlServer
  }
}

resource appi 'Microsoft.Insights/components@2015-05-01' = if(environment == 'prod') {
  name: appiResourceName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
  }
}
