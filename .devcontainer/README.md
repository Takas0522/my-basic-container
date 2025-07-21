# DevContainer Test Documentation

This DevContainer provides a complete development environment for full-stack development with .NET, Angular, Azure Functions, SQL Server, and Azure Storage.

## What's Included

### Development Tools
- .NET 9.0 SDK
- Node.js (LTS) with npm
- Angular CLI
- Azure Functions Core Tools
- Azure Static Web Apps CLI
- SQL Server tools (sqlcmd, SqlPackage)

### Services
- **SQL Server** (Azure SQL Edge) - Available at `db:1433`
- **Azurite** (Azure Storage Emulator) - Blob/Queue/Table services
  - Blob: `http://azurite:10000`
  - Queue: `http://azurite:10001`
  - Table: `http://azurite:10002`

## Testing the DevContainer

### Automatic Testing
The DevContainer includes automated setup and testing:

1. **Post-creation setup** - Runs automatically when the container is created
   - Creates sample projects for each technology
   - Validates all tool installations
   - Tests service connectivity

2. **Manual testing** - Run comprehensive tests anytime:
   ```bash
   ./.devcontainer/run-tests.sh
   ```

### What Gets Tested

1. **Tool Installations**
   - .NET SDK version and functionality
   - Node.js and npm versions
   - Angular CLI functionality
   - Azure Functions Core Tools
   - Azure Static Web Apps CLI
   - SQL Server tools

2. **Service Connectivity**
   - SQL Server connection and basic queries
   - Azurite storage services availability

3. **Project Creation and Building**
   - .NET Web API project creation and build
   - Angular project setup
   - Azure Functions project initialization

4. **Sample Projects** (created during setup)
   - `/workspace/test-projects/SampleWebApi` - ASP.NET Core Web API
   - `/workspace/test-projects/SampleAngularApp` - Angular application
   - `/workspace/test-projects/SampleAzureFunctions` - Azure Functions (TypeScript)

## Port Forwarding

The following ports are automatically forwarded:
- `5000` - ASP.NET Core applications
- `4200` - Angular development server
- `7071` - Azure Functions runtime
- `1433` - SQL Server
- `10000-10002` - Azurite storage services

## Environment Variables

Pre-configured environment variables for development:
- `ASPNETCORE_ENVIRONMENT=Development`
- `AZURITE_CONNECTIONSTRING` - Connection string for Azurite
- `SQL_CONNECTION_STRING` - Connection string for SQL Server

## Usage

1. Open this repository in VS Code
2. When prompted, click "Reopen in Container"
3. Wait for the automatic setup to complete
4. Start developing with the sample projects in `/workspace/test-projects/`
5. Run tests anytime with `./.devcontainer/run-tests.sh`

## Troubleshooting

If you encounter issues:
1. Check the container logs in VS Code
2. Run the test script to identify specific problems
3. Ensure Docker has enough resources allocated
4. Try rebuilding the container if services fail to start