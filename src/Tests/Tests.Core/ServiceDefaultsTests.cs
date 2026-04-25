using FluentAssertions;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Routing;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Diagnostics.HealthChecks;
using Microsoft.Extensions.Hosting;

namespace Tests.Core;

[TestFixture]
public class ServiceDefaultsTests
{
    [Test]
    public async Task Should_ReportHealthyLivenessCheck_When_DefaultHealthChecksAreRegistered()
    {
        // Given
        var builder = Host.CreateApplicationBuilder();
        builder.AddDefaultHealthChecks();
        await using var serviceProvider = builder.Services.BuildServiceProvider();
        var sut = serviceProvider.GetRequiredService<HealthCheckService>();

        // When
        var outcome = await sut.CheckHealthAsync(registration => registration.Tags.Contains("live"));

        // Then
        outcome.Status.Should().Be(HealthStatus.Healthy, "because the default self-check should satisfy liveness probes");
    }

    [Test]
    public void Should_MapHealthEndpoints_When_EnvironmentIsDevelopment()
    {
        // Given
        var builder = WebApplication.CreateBuilder(new WebApplicationOptions
        {
            EnvironmentName = Environments.Development
        });
        builder.AddServiceDefaults();
        var app = builder.Build();
        IEndpointRouteBuilder sut = app;

        // When
        app.MapDefaultEndpoints();
        var outcome = sut.DataSources
            .SelectMany(source => source.Endpoints)
            .OfType<RouteEndpoint>()
            .Select(endpoint => endpoint.RoutePattern.RawText)
            .ToArray();

        // Then
        outcome.Should().Contain("/health", "because development environments should expose the readiness endpoint")
            .And.Contain("/alive", "because development environments should expose the liveness endpoint");
    }

    [Test]
    public void Should_NotMapHealthEndpoints_When_EnvironmentIsNotDevelopment()
    {
        // Given
        var builder = WebApplication.CreateBuilder(new WebApplicationOptions
        {
            EnvironmentName = Environments.Production
        });
        builder.AddServiceDefaults();
        var app = builder.Build();
        IEndpointRouteBuilder sut = app;

        // When
        app.MapDefaultEndpoints();
        var outcome = sut.DataSources
            .SelectMany(source => source.Endpoints)
            .OfType<RouteEndpoint>()
            .Select(endpoint => endpoint.RoutePattern.RawText)
            .ToArray();

        // Then
        outcome.Should().NotContain("/health", "because health endpoints stay development-only by default")
            .And.NotContain("/alive", "because liveness endpoints stay development-only by default");
    }
}
