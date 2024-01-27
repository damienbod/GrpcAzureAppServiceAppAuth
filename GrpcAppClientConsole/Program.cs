using Grpc.Core;
using Grpc.Net.Client;
using GrpcAzureAppServiceAppAuth;
using Microsoft.Extensions.Configuration;
using Microsoft.Identity.Client;

var builder = new ConfigurationBuilder()
    .SetBasePath(Directory.GetCurrentDirectory())
    .AddUserSecrets("0464abbd-c57d-4048-873d-d16355586e50")
    .AddJsonFile("appsettings.json");

var configuration = builder.Build();

// 1. Client client credentials client
var app = ConfidentialClientApplicationBuilder
    .Create(configuration["AzureADServiceApi:ClientId"])
    .WithClientSecret(configuration["AzureADServiceApi:ClientSecret"])
    .WithAuthority(configuration["AzureADServiceApi:Authority"])
    .Build();

var scopes = new[] { configuration["AzureADServiceApi:Scope"] };

// 2. Get access token
var authResult = await app.AcquireTokenForClient(scopes)
    .ExecuteAsync();

if (authResult == null)
{
    Console.WriteLine("no auth result... ");
}
else
{
    Console.WriteLine(authResult.AccessToken);

    var tokenValue = "Bearer " + authResult.AccessToken;
    var metadata = new Metadata
    {
        { "Authorization", tokenValue }
    };

    var handler = new HttpClientHandler();

    var channel = GrpcChannel.ForAddress(configuration["AzureADServiceApi:ApiBaseAddress"]!,
        new GrpcChannelOptions
        {
            HttpClient = new HttpClient(handler)
        });

    CallOptions callOptions = new CallOptions(metadata);

    var client = new Greeter.GreeterClient(channel);

    var reply = await client.SayHelloAsync(
        new HelloRequest { Name = "GreeterClient" }, callOptions);

    Console.WriteLine("Greeting: " + reply.Message);

    Console.WriteLine("Press any key to exit...");
    Console.ReadKey();
}