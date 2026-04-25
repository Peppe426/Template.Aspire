---
applyTo: "src/Tests/**/*.cs,src/Tests/**/*.csproj"
---
# Test instructions

Use [Test structure](../../docs/Test%20structure.md) as the source of truth for test shape and naming.

- Structure every test with `// Given`, `// When`, and `// Then` sections.
- Name tests `Should_[ExpectedBehavior]_When_[Condition]`.
- Prefer `FluentAssertions` for assertions and keep assertion messages meaningful when they clarify intent.
- Defer execution when testing exceptions: use `Action` for sync void methods and `Func<Task>` for async methods, then assert with `Throw<T>()` or `ThrowAsync<T>()`.
- Keep one logical assertion per test. Split unrelated behaviors into separate tests.
- Use clear test variable names such as `sut`, `expected`, `outcome`, and `act`.
- Keep `FluentAssertions` pinned only in `src/Tests/Tests.Core/Tests.Core.csproj` at version `[7.0.0]`.
- New test projects should reference `src/Tests/Tests.Core/Tests.Core.csproj` to use the shared `FluentAssertions` dependency instead of adding a direct `FluentAssertions` package reference.
- When creating a new test project, mirror the current NUnit test stack from `Tests.Core` for test discovery and execution, but keep the shared assertion package centralized in `Tests.Core`.
