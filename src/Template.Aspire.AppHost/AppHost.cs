var builder = DistributedApplication.CreateBuilder(args);

builder.AddProject<Projects.Template_ApiService>("api");

builder.Build().Run();
