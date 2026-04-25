var builder = WebApplication.CreateBuilder(args);

builder.AddServiceDefaults();

var app = builder.Build();

app.MapGet("/", () => TypedResults.Ok(new
{
    service = "api",
    status = "ok"
}));

app.MapDefaultEndpoints();

app.Run();
