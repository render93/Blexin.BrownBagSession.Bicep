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

resource st 'Microsoft.Storage/storageAccounts@2021-08-01' = {
  name: storageResourceName
  location: location
  sku: {
    name:  storageSku
  }
  kind: 'Storage'
}

resource plan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: planResourceName
  location: location
  sku: {
    name: 'F1'
    tier: 'Free'
  }
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
}

resource sqlServer 'Microsoft.Sql/servers@2022-02-01-preview' = {
  name: sqlResourceName
  location: location
  properties:{
    administratorLogin: sqlAdministratorLogin
    administratorLoginPassword: sqlAdministratorPassword
  }  
}

resource sqlDb 'Microsoft.Sql/servers/databases@2022-02-01-preview' = {
  name: sqldbResourceName
  location: location
  parent: sqlServer
}

resource appi 'Microsoft.Insights/components@2015-05-01' = { 
  name: appiResourceName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
  }
}
