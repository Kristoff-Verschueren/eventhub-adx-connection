using Azure.Identity;
using Azure.Messaging.EventHubs;
using Azure.Messaging.EventHubs.Producer;
using System.Text;

namespace EventHubSender;

internal static class EventDataSender
{
    private const string eventHubNamespace = "evhns-example-weu-dev.servicebus.windows.net";
    private const string hubName = "example-events";

    public static async Task SendEventAsync()
    {
        string filePath = Path.Combine(Directory.GetCurrentDirectory(), "Files", "test.json");
        string jsonData = await File.ReadAllTextAsync(filePath);

        await SendEventToEventHubAsync(jsonData);
    }

    private static async Task SendEventToEventHubAsync(string jsonData)
    {
        await using var producerClient = new EventHubProducerClient(eventHubNamespace, hubName, new ChainedTokenCredential(
                        new AzureCliCredential()
                    ));

        // If you get an Unauthorized access Exception, give yourself RBAC roles: Azure Event Hubs
        // Data Sender
        using EventDataBatch eventBatch = await producerClient.CreateBatchAsync();

        var eventDataToSend = new EventData(Encoding.UTF8.GetBytes(jsonData));
        eventBatch.TryAdd(eventDataToSend);

        Console.WriteLine("Send event to Event Hub.");

        await producerClient.SendAsync(eventBatch);

        Console.WriteLine("Event sent to Event Hub.");
    }
}