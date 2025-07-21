#!/bin/bash
set -e

echo "🚀 Setting up DevContainer environment..."

# Create test projects directory
mkdir -p /workspace/test-projects

# Wait for services to be ready
echo "⏳ Waiting for services to be ready..."

# Function to wait for a service to be ready
wait_for_service() {
    local service_name=$1
    local host=$2
    local port=$3
    local max_attempts=30
    local attempt=1
    
    echo "⏳ Waiting for $service_name to be ready..."
    
    while [ $attempt -le $max_attempts ]; do
        if timeout 3 bash -c "</dev/tcp/$host/$port" 2>/dev/null; then
            echo "✅ $service_name is ready!"
            return 0
        fi
        echo "   Attempt $attempt/$max_attempts: $service_name not ready yet..."
        sleep 2
        attempt=$((attempt + 1))
    done
    
    echo "⚠️  Warning: $service_name did not become ready after ${max_attempts} attempts"
    return 1
}

# Wait for SQL Server
wait_for_service "SQL Server" "db" "1433"

# Wait for Azurite services
wait_for_service "Azurite Blob" "azurite" "10000"
wait_for_service "Azurite Queue" "azurite" "10001"
wait_for_service "Azurite Table" "azurite" "10002"

echo "⏳ Additional startup delay for service initialization..."
sleep 5

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
# Disable Angular CLI analytics and autocompletion globally
export NG_CLI_ANALYTICS=false
ng config --global cli.analytics false 2>/dev/null || true
ng config --global cli.completion.prompted true 2>/dev/null || true
# Ensure we have the latest Angular CLI
echo "🔄 Updating Angular CLI to latest version..."
sudo npm update -g @angular/cli 2>/dev/null || echo "Angular CLI update skipped"
ng version
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
rm -rf SampleWebApi
dotnet new webapi -n SampleWebApi --framework net9.0 --force
cd SampleWebApi
dotnet restore
dotnet build
echo "✅ Sample .NET project created and built successfully"

# Create sample Angular project
echo "📦 Creating sample Angular project..."
cd /workspace/test-projects
rm -rf SampleAngularApp
# Disable Angular CLI analytics and autocompletion prompts
export NG_CLI_ANALYTICS=false
export NG_CLI_COMPLETION=false
# Create Angular project with all prompts answered automatically
ng new SampleAngularApp --routing=true --style=css --package-manager=npm --skip-git --interactive=false
cd SampleAngularApp
npm install
echo "✅ Sample Angular project created successfully"

# Create sample Azure Functions project (manual setup)
echo "📦 Creating sample Azure Functions project (manual setup)..."
cd /workspace/test-projects
rm -rf SampleAzureFunctions
mkdir SampleAzureFunctions
cd SampleAzureFunctions
echo '{"name": "sample-azure-functions","version": "1.0.0","scripts": {"build": "tsc","prestart": "npm run build","start": "func start","test": "echo \"No tests configured\""},"devDependencies": {"typescript": "^4.0.0","@types/node": "^18.0.0","@azure/functions": "^3.0.0"},"dependencies": {}}' > package.json
echo '{"compilerOptions": {"target": "ES2018","module": "commonjs","lib": ["ES2018"],"outDir": "./dist","rootDir": "./src","strict": true,"noImplicitReturns": true,"noFallthroughCasesInSwitch": true,"noImplicitAny": true,"noImplicitThis": true,"alwaysStrict": true,"esModuleInterop": true,"skipLibCheck": true,"forceConsistentCasingInFileNames": true},"include": ["src/**/*"],"exclude": ["node_modules","**/*.spec.ts"]}' > tsconfig.json
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