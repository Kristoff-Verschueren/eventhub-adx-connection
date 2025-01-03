// Parameters
param eventHubNamespaceName string
param eventHubName string
param consumerGroupName string
@allowed([ 'Basic', 'Standard', 'Premium' ])
param sku string

resource eventHubNamespace 'Microsoft.EventHub/namespaces@2024-01-01' = {
  name: eventHubNamespaceName
  location: resourceGroup().location
  sku: {
    capacity: 1
    name: sku
    tier: sku
  }
  properties: {
    zoneRedundant: true
  }

  resource eventHub 'eventhubs' = {
    name: eventHubName
    properties: {
      messageRetentionInDays: 2
      partitionCount: 2
    }

    resource consumerGroup 'consumergroups' = {
      name: consumerGroupName
      properties: {}
    }
  }
}

output resourceId string = eventHubNamespace.id
output eventHubResourceId string = eventHubNamespace::eventHub.id
