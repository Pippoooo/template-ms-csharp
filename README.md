# Microservice Template for C#

A production-ready .NET microservice template designed for enterprise development.

## Features

-   **Docker-first development** — single command to start developing
-   **Integrated debugging** — VS Code debugger attached out of the box
-   **Containerized testing** — unit and integration tests run in Docker
-   **CI/CD ready** — GitHub Actions workflows included
-   **Enterprise code quality** — static analysis, code style enforcement, and centralized package management
-   **Automated dependency updates** — Dependabot configured for NuGet, Docker, and GitHub Actions

## Prerequisites

-   [Docker](https://docs.docker.com/get-docker/) (required)
-   [.NET 10 SDK](https://dotnet.microsoft.com/download) (optional, for IDE support)
-   [VS Code](https://code.visualstudio.com/) (optional, for debugging)

## Use this template

### Install the template

```bash
dotnet new install .
```

### Create a new project

```bash
dotnet new microservice -n MyService -o MyService
```

This creates a new microservice with:

-   `src/app/MyService.Api` — API application
-   `src/test/MyService.Unit` — Unit tests
-   `src/test/MyService.Integration` — Integration tests

## Development

### Start the application

```bash
docker compose up --build
```

This builds and runs the application with hot reload enabled. Code changes are reflected immediately without restarting the container.

### Adding dependencies

To add services like databases or message queues, extend `compose.yaml`:

```yaml
services:
    api:
        # existing config...
        depends_on:
            - postgres

    postgres:
        image: postgres:17
        environment:
            POSTGRES_USER: dev
            POSTGRES_PASSWORD: dev
            POSTGRES_DB: myservice
        ports:
            - "5432:5432"
```

## Debugging

### VS Code

1. Start the application: `docker compose up --build`
2. Open the Run and Debug panel (Ctrl+Shift+D)
3. Select "Attach to Container"
4. Press F5

The debugger attaches to the running container. Breakpoints, step-through, and variable inspection work as expected.

### Other IDEs

The container includes `vsdbg` at `/vsdbg`. Configure your IDE to attach to the container process using the Debug Adapter Protocol.

## Testing

### Unit tests

Run unit tests locally:

```bash
dotnet test src/test/MS_NAME.Unit
```

Or via Docker (as in CI):

```bash
docker build --target unit-test .
```

### Integration tests

Integration tests run against containerized dependencies matching production:

```bash
docker compose -f compose.integration.yaml up --build --abort-on-container-exit --exit-code-from integration
```

This spins up all required services, runs the tests, and exits with the test result code.

## CI/CD

### Included workflows

| Workflow              | Trigger            | Actions                                         |
| --------------------- | ------------------ | ----------------------------------------------- |
| `ci.yml`              | All pushes and PRs | Build, unit tests, integration tests (PRs only) |
| `release-staging.yml` | Push to main       | Integration tests, deploy to staging            |
| `release-prod.yml`    | Release published  | Deploy to production                            |

### Setup

1. Configure GitHub environments (`staging`, `production`) in repository settings
2. Add required secrets for your deployment target
3. Optionally add environment protection rules for production

### Container registry

To push images to github container registry, add this secrets to your repository:

-   `GITHUB_TOKEN` — your github token to push to container registry

## Project Structure

```
.
├── src/
│   ├── app/
│   │   └── MS_NAME.Api/        # API application
│   └── test/
│       ├── MS_NAME.Unit/        # Unit tests
│       └── MS_NAME.Integration/ # Integration tests
├── .github/
│   └── workflows/               # CI/CD pipelines
├── .vscode/
│   └── launch.json              # Debugger configuration
├── compose.yaml                 # Development environment
├── compose.integration.yaml     # Integration test environment
├── Dockerfile                   # Multi-stage build
├── Directory.Build.props        # Shared build configuration
├── Directory.Packages.props     # Centralized package versions
├── global.json                  # SDK version pinning
├── .editorconfig                # Code style rules
└── .env.example                 # Environment variable template
```

## Code Quality

### Static analysis

The template enforces strict code quality through:

-   **Roslyn analyzers** — all warnings treated as errors
-   **SonarAnalyzer** — additional code smell detection
-   **EditorConfig** — consistent formatting across IDEs
-   **NuGet audit** — fails build on vulnerable dependencies

### Package management

All package versions are centralized in `Directory.Packages.props`. To add a new package:

1. Add the version to `Directory.Packages.props`:

    ```xml
    <PackageVersion Include="Newtonsoft.Json" Version="13.0.3" />
    ```

2. Reference it in your `.csproj` without a version:
    ```xml
    <PackageReference Include="Newtonsoft.Json" />
    ```

### Dependabot

Automated updates are configured for:

-   NuGet packages (weekly)
-   Docker base images (weekly)
-   GitHub Actions (weekly)

Review and merge Dependabot PRs to keep dependencies current.

## Build Artifacts

Build outputs are centralized in the `.build/` directory (not in individual `bin/`/`obj/` folders). This directory is git-ignored and excluded from Docker builds.
