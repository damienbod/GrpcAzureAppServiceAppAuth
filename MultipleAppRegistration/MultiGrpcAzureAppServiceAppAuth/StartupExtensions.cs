using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.Identity.Web;
using Serilog;
using System.Security.Claims;

namespace MultiGrpcAzureAppServiceAppAuth;

internal static class StartupExtensions
{
    public static WebApplication ConfigureServices(this WebApplicationBuilder builder)
    {
        var services = builder.Services;
        var configuration = builder.Configuration;

        builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
            .AddMicrosoftIdentityWebApi(builder.Configuration.GetSection("AzureAd"));

        builder.Services.AddAuthorization(options =>
        {
            options.AddPolicy("ValidateAccessTokenPolicy", validateAccessTokenPolicy =>
            {
                // Validate id of application for which the token was created
                // In this case the CC client application 
                // Works with multi-tenant App registrations
                validateAccessTokenPolicy.RequireClaim("azp", configuration["AzureAd:ClientId"]!);

                // Value of Microsoft Entra App registration where role is defined (resource)
                validateAccessTokenPolicy.RequireClaim("aud", configuration["AzureAd:Audience"]!);

                // Single tenant Enterprise application object ID
                // Only validate if locking down to a single Enterprise application.
                // oid or "http://schemas.microsoft.com/identity/claims/objectidentifier" depending on your mappings
                validateAccessTokenPolicy.RequireClaim("http://schemas.microsoft.com/identity/claims/objectidentifier", configuration["AzureAd:Oid"]!);

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
            options.ListenAnyIP(7180, listenOptions =>
            {
                listenOptions.UseHttps(); // required for local debugging, not for the Azure deployment
                listenOptions.Protocols = Microsoft.AspNetCore.Server.Kestrel.Core.HttpProtocols.Http2;
            });
        });

        return builder.Build();
    }

    public static WebApplication Configure(this WebApplication app)
    {
        //IdentityModelEventSource.ShowPII = true;
        //JsonWebTokenHandler.DefaultInboundClaimTypeMap.Clear();

        app.UseSerilogRequestLogging();

        app.UseHttpsRedirection();

        app.UseRouting();
        app.UseAuthentication();
        app.UseAuthorization();

        app.MapGrpcService<GreeterService>();
        app.MapGet("/", async context =>
        {
            await context.Response.WriteAsync("GRPC service running...");
        });

        return app;
    }
}