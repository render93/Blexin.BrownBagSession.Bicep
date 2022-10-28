param resourceName string
param location string

resource appi 'Microsoft.Insights/components@2015-05-01' = {
  name: resourceName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
  }
}

output instrumentationKey string = appi.properties.InstrumentationKey
output connectionString string = appi.properties.ConnectionString
