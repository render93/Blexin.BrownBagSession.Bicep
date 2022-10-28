param location string

param storageResourceName string
param storageSku string

param sqlServerResourceName string
param sqldbResourceName string
param sqlAdministratorLogin string
@secure()
param sqlAdministratorPassword string

resource st 'Microsoft.Storage/storageAccounts@2021-08-01' = {
  name: storageResourceName
  location: location
  sku: {
    name: storageSku
  }
  kind: 'Storage'
}

resource sqlServer 'Microsoft.Sql/servers@2022-02-01-preview' = {
  name: sqlServerResourceName
  location: location
  properties: {
    administratorLogin: sqlAdministratorLogin
    administratorLoginPassword: sqlAdministratorPassword
  }
}

resource sqlDb 'Microsoft.Sql/servers/databases@2022-02-01-preview' = {
  name: sqldbResourceName
  location: location
  parent: sqlServer
}

output storageAccountId string = st.id
output sqlConnectionString string = 'Server=tcp:${sqlServer.properties.fullyQualifiedDomainName},1433;Initial Catalog=${sqlDb.name};Persist Security Info=False;User ID=${sqlAdministratorLogin};Password=${sqlAdministratorPassword};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;'

