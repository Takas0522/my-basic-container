#!/bin/bash
set -e

echo "🚀 Setting up DevContainer environment..."

# Create test projects directory
mkdir -p /workspace/test-projects

# Wait for services to be ready
echo "⏳ Waiting for services to be ready..."
sleep 10

# Test .NET installation
echo "🧪 Testing .NET installation..."
dotnet --version
echo "✅ .NET is working"

# Test Node.js and npm
echo "🧪 Testing Node.js and npm installation..."
node --version
npm --version
echo "✅ Node.js and npm are working"

# Test Angular CLI
echo "🧪 Testing Angular CLI installation..."
ng version --skip-git
echo "✅ Angular CLI is working"

# Test Azure Functions Core Tools
echo "🧪 Testing Azure Functions Core Tools..."
func --version
echo "✅ Azure Functions Core Tools are working"

# Test Azure Static Web Apps CLI
echo "🧪 Testing Azure Static Web Apps CLI..."
swa --version
echo "✅ Azure Static Web Apps CLI is working"

# Test SQL tools
echo "🧪 Testing SQL tools..."
/opt/sqlpackage/sqlpackage /version
echo "✅ SqlPackage is working"

# Create sample .NET project
echo "📦 Creating sample .NET Web API project..."
cd /workspace/test-projects
dotnet new webapi -n SampleWebApi --framework net9.0
cd SampleWebApi
dotnet restore
dotnet build
echo "✅ Sample .NET project created and built successfully"

# Create sample Angular project
echo "📦 Creating sample Angular project..."
cd /workspace/test-projects
ng new SampleAngularApp --routing=true --style=css --skip-git=true --package-manager=npm
cd SampleAngularApp
npm install
echo "✅ Sample Angular project created successfully"

# Create sample Azure Functions project (manual setup)
echo "📦 Creating sample Azure Functions project (manual setup)..."
cd /workspace/test-projects
mkdir SampleAzureFunctions
cd SampleAzureFunctions
echo '{"name": "sample-azure-functions","version": "1.0.0","scripts": {"build": "tsc","prestart": "npm run build","start": "func start","test": "echo \"No tests configured\""},"devDependencies": {"typescript": "^4.0.0","@types/node": "^18.0.0"},"dependencies": {}}' > package.json
mkdir src
echo 'import { AzureFunction, Context, HttpRequest } from "@azure/functions"; const httpTrigger: AzureFunction = async function (context: Context, req: HttpRequest): Promise<void> { context.log("HTTP trigger function processed a request."); context.res = { status: 200, body: "Hello from Azure Functions!" }; }; export default httpTrigger;' > src/SampleHttpTrigger.ts
npm install
echo "✅ Sample Azure Functions project structure created"

echo "🎉 DevContainer setup completed successfully!"
echo ""
echo "Available test projects in /workspace/test-projects/:"
echo "  - SampleWebApi (ASP.NET Core Web API)"
echo "  - SampleAngularApp (Angular application)"
echo "  - SampleAzureFunctions (Azure Functions TypeScript)"
echo ""
echo "You can run tests anytime with: /workspace/.devcontainer/run-tests.sh"