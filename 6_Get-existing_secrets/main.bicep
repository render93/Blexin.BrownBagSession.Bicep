param location string = resourceGroup().location // default parameter

@allowed([
  'dev'
  'test'
  'prod'
])
param environment string // parameter

param sqlAdministratorLogin string
@secure()
param sqlAdministratorPassword string

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
var kvResourceName = 'kv-bicepsession-main'

module monitoring 'modules/monitoring.bicep' = {
  name: 'monitoring'
  params: {
    location: location
    resourceName: appiResourceName
  }
}

module data 'modules/data.bicep' = {
  name: 'data'
  params: {
    location: location
    kvResourceName: kvResourceName
    sqlAdministratorLogin: sqlAdministratorLogin
    sqlAdministratorPassword: sqlAdministratorPassword
    sqlServerResourceName: sqlResourceName
    sqldbResourceName: sqldbResourceName
    storageResourceName: storageResourceName
    storageSku: storageSku
  }
}

module backend 'modules/backend.bicep' = {
  name: 'backend'
  params: {
    location: location
    kvResourceName: kvResourceName
    appInsightsConnectionString: monitoring.outputs.connectionString
    appInsightsInstrumentationKey: monitoring.outputs.instrumentationKey
    dbConnectionStringSecretUri: data.outputs.dbConnectionStringSecretUri
    environment: environment
    funcResourceName: funcResourceName
    planResourceName: planResourceName
    storageAccountId: data.outputs.storageAccountId 
    storageAccountName: storageResourceName
  }
}
