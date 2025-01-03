using 'main.bicep'

param environmentName = 'dev'
param locationShort = 'weu'
param appName = 'example'

param eventHubNamespaceSku = 'Standard'
param eventHubInstance = 'example-events'
param eventHubInstanceAdxConsumerName = 'adx-consumer'

param adxSkuName = 'Dev(No SLA)_Standard_E2a_v4'
param adxSkuTier = 'Basic'
param adxDatabaseName = 'examples-database'
