# My Basic Container - DevContainer for Full-Stack Development

A comprehensive DevContainer setup for full-stack development with .NET, Angular, Azure services, and SQL Server.

## 🚀 Quick Start

1. **Prerequisites**
   - Docker Desktop with containers support
   - Visual Studio Code with Dev Containers extension

2. **Launch DevContainer**
   ```bash
   # Clone the repository
   git clone https://github.com/Takas0522/my-basic-container.git
   cd my-basic-container
   
   # Open in VS Code
   code .
   
   # Click "Reopen in Container" when prompted
   ```

3. **Automatic Setup**
   - The container will automatically set up sample projects
   - All development tools will be pre-installed and configured
   - Services (SQL Server, Azurite) will be ready for use

## 🛠️ What's Included

### Development Tools
- **.NET 9.0 SDK** - Latest .NET for backend development
- **Node.js LTS + npm** - JavaScript/TypeScript development
- **Angular CLI v18** - Modern Angular development
- **SQL Server Tools** - Database management tools

### Services
- **Azure SQL Edge** - Full SQL Server compatibility for development
- **Azurite** - Local Azure Storage emulator (Blob, Queue, Table)

### Sample Projects
- **SampleWebApi** - ASP.NET Core Web API with .NET 9.0
- **SampleAngularApp** - Angular 18 application
- **SampleAzureFunctions** - TypeScript-based Azure Functions

## 🧪 Testing Your Setup

Run the comprehensive test suite:
```bash
./.devcontainer/run-tests.sh
```

Or test individual tools:
```bash
# Check versions
dotnet --version
node --version
ng version

# Test project creation
dotnet new webapi -n MyApi
ng new MyApp --routing --style=css
```

## 🔌 Port Configuration

The following ports are automatically forwarded:
- **5000** - ASP.NET Core applications
- **4200** - Angular dev server
- **7071** - Azure Functions runtime
- **1433** - SQL Server
- **10000** - Azurite Blob service
- **10001** - Azurite Queue service
- **10002** - Azurite Table service

## 🏗️ Development Workflow

### Architecture Support
This DevContainer supports both **x64** and **ARM64** architectures:

**x64 (Intel/AMD)**
- Full SQL Server Tools support (SqlPackage, sqlcmd)
- All Azure development tools
- Complete feature parity

**ARM64 (Apple Silicon, ARM-based processors)**
- Native sqlcmd support via go-sqlcmd
- SqlPackage: placeholder script (ARM64 native version not yet available)
- All other tools work natively
- Automatic architecture detection and tool selection

### Backend Development (.NET)
```bash
cd /workspace/test-projects/SampleWebApi
dotnet run
# API available at http://localhost:5000
```

### Frontend Development (Angular)
```bash
cd /workspace/test-projects/SampleAngularApp
npm start
# App available at http://localhost:4200
```

### Database Operations
```bash
# Connect to SQL Server
sqlcmd -S db -U sa -P 'P@ssw0rd!'

# Or use VS Code SQL Server extension
# Server: db,1433
# Username: sa
# Password: P@ssw0rd!
```

### Azure Storage Development
```bash
# Azurite connection string (pre-configured in environment)
echo $AZURITE_CONNECTIONSTRING
```

## 🔄 CI/CD Integration

This repository includes GitHub Actions workflow that:
1. **Builds** the DevContainer
2. **Tests** all functionality automatically  
3. **Publishes** the container image on successful tests
4. **Validates** pull requests before merging

## 📚 Documentation

- [DevContainer Configuration Details](.devcontainer/README.md)
- [Test Results and Validation](.devcontainer/TEST_RESULTS.md)
- [Troubleshooting Guide](#troubleshooting)

## 🔧 Troubleshooting

### Container won't start
- Ensure Docker Desktop is running
- Check available disk space (>10GB recommended)
- Restart Docker Desktop if needed

### Services not accessible
- Wait 30-60 seconds after container startup
- Check service status: `docker compose ps`
- Restart services: `docker compose restart`

### Tool installation issues
- Some Azure tools may need post-installation
- Check network connectivity
- Run setup script manually: `./.devcontainer/setup.sh`

### ARM64 Architecture Issues
- **SqlPackage**: Not natively supported on ARM64. Consider alternatives:
  - Azure Data Studio with SQL Database Projects extension
  - dotnet CLI with SqlPackage NuGet package
  - Use x64 development environment for database projects
- **sqlcmd**: Uses go-sqlcmd for ARM64 compatibility

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch
3. Test your changes thoroughly
4. Submit a pull request

The automated testing will validate your changes.

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

## 🏷️ Tags

`devcontainer` `dotnet` `angular` `azure` `sql-server` `development-environment` `docker` `vscode`