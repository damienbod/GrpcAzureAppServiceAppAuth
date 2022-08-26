using Grpc.Net.Client;
using System.Net.Http.Headers;
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

    // 3. Use access token to access token
    var client = new HttpClient
    {
        BaseAddress = new Uri(configuration["AzureADServiceApi:ApiBaseAddress"])
    };

    client.DefaultRequestHeaders.Authorization
        = new AuthenticationHeaderValue("Bearer", authResult.AccessToken);
    client.DefaultRequestHeaders.Accept
        .Add(new MediaTypeWithQualityHeaderValue("application/json"));

    var response = await client.GetAsync("ApiForServiceData");

    if (response.IsSuccessStatusCode)
    {
        Console.WriteLine(await response.Content.ReadAsStringAsync());
    }
}


//var handler = new HttpClientHandler();

//var channel = GrpcChannel.ForAddress("https://localhost:44379", new GrpcChannelOptions
//{
//    HttpClient = new HttpClient(handler)
//});

//var client = new Greeter.GreeterClient(channel);
//var reply = await client.SayHelloAsync(new HelloRequest { Name = "GreeterClient" });
//Console.WriteLine("Greeting: " + reply.Message);
//Console.WriteLine("Press any key to exit...");
//Console.ReadKey();