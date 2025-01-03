// Parameters
@description('Name of the cluster')
param clusterName string = 'kusto${uniqueString(resourceGroup().id)}'

@description('Name of the sku')
param skuName string = 'Dev(No SLA)_Standard_E2a_v4'
@description('Tier of the sku')
param skuTier string = 'Basic'

@description('# of nodes')
@minValue(1)
@maxValue(1000)
param skuCapacity int = 1

@description('Name of the database')
param databaseName string = ''

param eventHubResourceId string
param eventHubConsumerGroupName string

param deploymentId string = take(newGuid(), 8)

resource cluster 'Microsoft.Kusto/clusters@2024-04-13' = {
  name: clusterName
  location: resourceGroup().location
  sku: {
    name: skuName
    tier: skuTier
    capacity: skuCapacity
  }
  identity: {
    type: 'SystemAssigned'
  }
  
  properties: {
    enablePurge: true
  }

  resource kustoDb 'databases' = {
    name: databaseName
    location: resourceGroup().location
    kind: 'ReadWrite'

    resource kustoScript 'scripts' = {
      name: 'db-script'
      properties: {
        scriptContent: loadTextContent('../scripts/adx_table_creation.kql')
        continueOnErrors: false
      }
    }

    resource eventConnection 'dataConnections' = {
      name: 'eventConnection'
      location: resourceGroup().location
      dependsOn: [
        //  We need the table to be present in the database
        kustoScript
        //  We need the cluster to be receiver on the Event Hub
        eventHubRbac
      ]
      kind: 'EventHub'
      properties: {
        compression: 'None'
        consumerGroup: eventHubConsumerGroupName
        dataFormat: 'MULTIJSON'
        eventHubResourceId: eventHubResourceId
        eventSystemProperties: [
          'x-opt-enqueued-time'
          'x-opt-offset'
        ]
        managedIdentityResourceId: cluster.id
        mappingRuleName: 'ExampleEventJson'
        tableName: 'ExampleEvents'
      }
    }
  }
}

module eventHubRbac 'rbac.bicep' = {
  name: '${clusterName}-rbac-${deploymentId}'
  params: {
    roleAssignments: [
      {
        resourceId: eventHubResourceId
        principalId: cluster.identity.principalId
        principalType: 'ServicePrincipal'
        roleDefinitionId: 'a638d3c7-ab3a-418d-83e6-5f17a39d4fde' // Azure Event Hubs Data Receiver
      }
    ]
  }
}
