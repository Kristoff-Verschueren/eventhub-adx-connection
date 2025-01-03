targetScope = 'resourceGroup'

// MARK: Parameters
param environmentName string
param locationShort string
param appName string
param eventHubNamespaceSku string
param eventHubInstance string
param eventHubInstanceAdxConsumerName string
param adxSkuName string
param adxSkuTier string
param adxDatabaseName string

param deploymentId string = take(newGuid(), 8)

// MARK: Variables
var eventHubNamespaceName = 'evhns-${appName}-${locationShort}-${environmentName}'
var adxName = 'adx-${appName}-${locationShort}-${environmentName}'

// MARK: Resources
// MARK: EventHub
module eventHub 'modules/eventHub.bicep' = {
  name: '${eventHubNamespaceName}-${deploymentId}'
  params: {
    eventHubNamespaceName: eventHubNamespaceName
    eventHubName: eventHubInstance
    consumerGroupName: eventHubInstanceAdxConsumerName
    sku: eventHubNamespaceSku
  }
}

// MARK: ADX
module adx 'modules/adx.bicep' = {
  name: '${adxName}-${deploymentId}'
  params: {
    clusterName: adxName
    eventHubResourceId: eventHub.outputs.eventHubResourceId
    eventHubConsumerGroupName: eventHubInstanceAdxConsumerName
    databaseName: adxDatabaseName
    skuCapacity: 1
    skuName: adxSkuName
    skuTier: adxSkuTier
  }
}
