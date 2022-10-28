param location string
param kvResourceName string

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

resource kv 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: kvResourceName
}

resource connectionStringSecret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: 'sqlconnectionstring'
  properties: {
    value: 'Server=tcp:${sqlServer.properties.fullyQualifiedDomainName},1433;Initial Catalog=${sqlDb.name};Persist Security Info=False;User ID=${sqlAdministratorLogin};Password=${sqlAdministratorPassword};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;'
    attributes: {
      enabled: true
    }
  }
  parent: kv
}

output storageAccountId string = st.id
output dbConnectionStringSecretUri string = connectionStringSecret.properties.secretUri
