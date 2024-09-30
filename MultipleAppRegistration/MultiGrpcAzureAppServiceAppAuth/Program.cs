using GrpcAzureAppServiceAppAuth;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.Identity.Web;
using Microsoft.IdentityModel.Logging;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddMicrosoftIdentityWebApi(builder.Configuration.GetSection("AzureAd"));

builder.Services.AddAuthorization(options =>
{
    options.AddPolicy("ValidateAccessTokenPolicy", validateAccessTokenPolicy =>
    {
        // Validate id of application for which the token was created
        // In this case the CC client application 
        validateAccessTokenPolicy.RequireClaim("azp", "19893e32-3f4d-4c5a-b5ca-27891cf75666");

        // only allow tokens which used "Private key JWT Client authentication"
        // // https://docs.microsoft.com/en-us/azure/active-directory/develop/access-tokens
        // Indicates how the client was authenticated. For a public client, the value is "0". 
        // If client ID and client secret are used, the value is "1". 
        // If a client certificate was used for authentication, the value is "2".
        validateAccessTokenPolicy.RequireClaim("azpacr", "1");
    });
});

builder.Services.AddGrpc();

// Configure Kestrel to listen on a specific HTTP port 
builder.WebHost.ConfigureKestrel(options =>
{
    options.ListenAnyIP(8080);
    options.ListenAnyIP(7179, listenOptions =>
    {
        listenOptions.UseHttps(); // required for local debugging, not for the Azure deployment
        listenOptions.Protocols = Microsoft.AspNetCore.Server.Kestrel.Core.HttpProtocols.Http2;
    });
});

IdentityModelEventSource.ShowPII = true;

var app = builder.Build();

app.UseHttpsRedirection();

app.UseRouting();
app.UseAuthentication();
app.UseAuthorization();

app.MapGrpcService<GreeterService>();
app.MapGet("/", async context =>
{
    await context.Response.WriteAsync("GRPC service running...");
});

app.Run();
