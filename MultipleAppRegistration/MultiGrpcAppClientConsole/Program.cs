using Grpc.Core;
using Grpc.Net.Client;
using Microsoft.Extensions.Configuration;
using Microsoft.Identity.Client;
using MultiGrpcAzureAppServiceAppAuth;

var builder = new ConfigurationBuilder()
    .SetBasePath(Directory.GetCurrentDirectory())
    .AddUserSecrets("86ed0066-89d8-4d2d-982a-b74e6cfb880e")
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

    var callOptions = new CallOptions(metadata);

    var client = new Greeter.GreeterClient(channel);

    var reply = await client.SayHelloAsync(
        new HelloRequest { Name = "GreeterClient" }, callOptions);

    Console.WriteLine("Greeting: " + reply.Message);

    Console.WriteLine("Press any key to exit...");
    Console.ReadKey();
}