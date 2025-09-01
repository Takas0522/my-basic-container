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
if dotnet --version >/dev/null 2>&1; then
    echo "✅ .NET is working"
else
    echo "⚠️  .NET not available"
fi

# Test Node.js and npm
echo "🧪 Testing Node.js and npm installation..."
if node --version >/dev/null 2>&1 && npm --version >/dev/null 2>&1; then
    echo "✅ Node.js and npm are working"
else
    echo "⚠️  Node.js or npm not available"
fi

# Test Angular CLI
echo "🧪 Testing Angular CLI installation..."
# Disable Angular CLI analytics and autocompletion globally
export NG_CLI_ANALYTICS=false
ng config --global cli.analytics false 2>/dev/null || true
ng config --global cli.completion.prompted true 2>/dev/null || true
# Ensure we have the latest Angular CLI
echo "🔄 Updating Angular CLI to latest version..."
sudo npm update -g @angular/cli 2>/dev/null || echo "Angular CLI update skipped"
if ng version >/dev/null 2>&1; then
    echo "✅ Angular CLI is working"
else
    echo "⚠️  Angular CLI not available"
fi

# Test Azure Functions Core Tools
echo "🧪 Testing Azure Functions Core Tools..."
ARCH=$(uname -m)
if [ "$ARCH" = "x86_64" ] || [ "$ARCH" = "amd64" ]; then
    func --version
    echo "✅ Azure Functions Core Tools are working"
else
    echo "⚠️ Azure Functions Core Tools is not available for ARM64 architecture"
    echo "   Placeholder script created. Run 'func' to see alternatives."
    echo "✅ Azure Functions Core Tools placeholder configured"
fi

# Test Azure Static Web Apps CLI
echo "🧪 Testing Azure Static Web Apps CLI..."
if swa --version >/dev/null 2>&1; then
    echo "✅ Azure Static Web Apps CLI is working"
else
    echo "⚠️  Azure Static Web Apps CLI not available"
fi

# Test SQL tools
echo "🧪 Testing SQL tools..."
if /opt/sqlpackage/sqlpackage /version >/dev/null 2>&1; then
    echo "✅ SqlPackage is working"
else
    echo "⚠️  SqlPackage not available (this is expected on ARM64 architecture)"
fi

# Create sample .NET project
echo "📦 Creating sample .NET Web API project..."
if command -v dotnet >/dev/null 2>&1; then
    cd /workspace/test-projects
    rm -rf SampleWebApi
    if dotnet new webapi -n SampleWebApi --framework net9.0 --force; then
        cd SampleWebApi
        dotnet restore
        dotnet build
        echo "✅ Sample .NET project created and built successfully"
    else
        echo "⚠️  Failed to create .NET project"
    fi
else
    echo "⚠️  .NET CLI not available, skipping .NET project creation"
fi

# Create sample Angular project
echo "📦 Creating sample Angular project..."
if command -v ng >/dev/null 2>&1; then
    cd /workspace/test-projects
    rm -rf SampleAngularApp
    # Disable Angular CLI analytics and autocompletion prompts
    export NG_CLI_ANALYTICS=false
    export NG_CLI_COMPLETION=false
    # Create Angular project with all prompts answered automatically
    if ng new SampleAngularApp --routing=true --style=css --package-manager=npm --skip-git --interactive=false; then
        cd SampleAngularApp
        npm install
        echo "✅ Sample Angular project created successfully"
    else
        echo "⚠️  Failed to create Angular project"
    fi
else
    echo "⚠️  Angular CLI not available, skipping Angular project creation"
fi

# Create sample Azure Functions project (manual setup)
echo "📦 Creating sample Azure Functions project (manual setup)..."
if command -v npm >/dev/null 2>&1; then
    cd /workspace/test-projects
    rm -rf SampleAzureFunctions
    mkdir SampleAzureFunctions
    cd SampleAzureFunctions
    echo '{"name": "sample-azure-functions","version": "1.0.0","scripts": {"build": "tsc","prestart": "npm run build","start": "func start","test": "echo \"No tests configured\""},"devDependencies": {"typescript": "^4.0.0","@types/node": "^18.0.0","@azure/functions": "^3.0.0"},"dependencies": {}}' > package.json
    echo '{"compilerOptions": {"target": "ES2018","module": "commonjs","lib": ["ES2018"],"outDir": "./dist","rootDir": "./src","strict": true,"noImplicitReturns": true,"noFallthroughCasesInSwitch": true,"noImplicitAny": true,"noImplicitThis": true,"alwaysStrict": true,"esModuleInterop": true,"skipLibCheck": true,"forceConsistentCasingInFileNames": true},"include": ["src/**/*"],"exclude": ["node_modules","**/*.spec.ts"]}' > tsconfig.json
    mkdir src
    echo 'import { AzureFunction, Context, HttpRequest } from "@azure/functions"; const httpTrigger: AzureFunction = async function (context: Context, req: HttpRequest): Promise<void> { context.log("HTTP trigger function processed a request."); context.res = { status: 200, body: "Hello from Azure Functions!" }; }; export default httpTrigger;' > src/SampleHttpTrigger.ts
    if npm install; then
        echo "✅ Sample Azure Functions project structure created"
    else
        echo "⚠️  Failed to install npm dependencies for Azure Functions project"
    fi
else
    echo "⚠️  npm not available, skipping Azure Functions project creation"
fi

echo "🎉 DevContainer setup completed successfully!"
echo ""
ARCH=$(uname -m)
echo "Running on architecture: $ARCH"
echo ""
echo "Available test projects in /workspace/test-projects/:"
if [ -d "/workspace/test-projects/SampleWebApi" ]; then
    echo "  - SampleWebApi (ASP.NET Core Web API)"
fi
if [ -d "/workspace/test-projects/SampleAngularApp" ]; then
    echo "  - SampleAngularApp (Angular application)"
fi
if [ -d "/workspace/test-projects/SampleAzureFunctions" ]; then
    echo "  - SampleAzureFunctions (Azure Functions TypeScript)"
fi
echo ""
if [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then
    echo "⚠️  Note: Some tools may have limited functionality on ARM64."
    echo "   Check tool-specific messages above for details."
    echo ""
fi
echo "You can run tests anytime with: /workspace/.devcontainer/run-tests.sh"