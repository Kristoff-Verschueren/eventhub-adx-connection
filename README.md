# EventHub to Azure Data Explorer (ADX) Deployment

This setup configures an Azure EventHub and an Azure Data Explorer (ADX) cluster. 
EventHub automatically forwards messages to the ADX database for storage and analysis.


## Table of Contents
- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Structure](#structure)
- [Deployment](#deployment)
- [Verification](#verification)
- [Cleanup](#cleanup)


## Overview

This solution includes:
1. **EventHub Namespace**: To receive messages.
2. **Azure Data Explorer (ADX)**: To store and process the data sent through EventHub.
3. **EventHubSender Console App**: A sample application to send events to the EventHub for ADX ingestion.

Messages are automatically processed via an EventHub Consumer Group and stored in the specified ADX database.


## Prerequisites
- **Azure CLI** installed ([Installation Guide](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli))
- Access to an Azure account with permissions to deploy resources. And optional: permissions to create a ResourceGroup.


## Structure

The setup consists of the following files:
- **bicep/**: All bicep files to deploy the resources to Azure.
- **EventHubSender/**: Contains the console application to send events to the EventHub.


## Deployment

### Step 1: Create a Resource Group
This step can be skipped if you already have a Resource Group.
Ensure you have a Resource Group where the deployment will be executed:
```bash
az group create --name eventhub-adx --location westeurope
```

### Step 2: Execute the Deployment
Run the following command to deploy the infrastructure:
```bash
az deployment group create \
  --resource-group eventhub-adx \
  --template-file main.bicep \
  --parameters dev.bicepparam
```

### Step 3: Verify the Deployment
Check the deployment through the Azure Portal or using the CLI:
```bash
az resource list --resource-group eventhub-adx
```


## Verification

The **EventHubSender** is a simple console application included in this repository to send sample events to the EventHub.

### Send Events
1. Open the `EventHubSender` project in Visual Studio.
2. Update `EventDataSender.cs` and change the eventHubNamespace and hubName:
   ```csharp
   private const string eventHubNamespace = "<Your EventHub Namespace Name>.servicebus.windows.net";
   private const string hubName = "<Your EventHub Name>";
   ```
3. Build and run the application.

After running the application, the events will be available in the ADX database for querying and analysis.

### ADX Query
Query the `ExampleEvents` table to see the added records.


## Cleanup
> [!CAUTION]
> Be carefull with this section!

### Delete the resource in the Resource Group
```bash
az kusto cluster delete --name "<Your ADX Name>" --resource-group "eventhub-adx" --yes --no-wait
az eventhubs namespace delete --name "<Your EventHub Namespace Name>" --resource-group "eventhub-adx" --no-wait
```

### Delete the Resource Group
To delete all resources:
```bash
az group delete --name eventhub-adx --yes --no-wait
```

## Note
Adjust the values in `dev.bicepparam` to tailor this deployment to specific environments.
