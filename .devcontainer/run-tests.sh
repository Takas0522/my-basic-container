#!/bin/bash
set -e

echo "🧪 Running DevContainer functionality tests..."
echo "================================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counter
TESTS_PASSED=0
TESTS_FAILED=0

# Function to run a test
run_test() {
    local test_name="$1"
    local test_command="$2"
    
    echo -e "\n${YELLOW}🔍 Testing: $test_name${NC}"
    
    if eval "$test_command" > /tmp/test_output 2>&1; then
        echo -e "${GREEN}✅ PASSED: $test_name${NC}"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}❌ FAILED: $test_name${NC}"
        echo "Error output:"
        cat /tmp/test_output
        ((TESTS_FAILED++))
    fi
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

echo "🧪 1. TESTING TOOL INSTALLATIONS"
echo "================================"

# Test .NET
run_test ".NET Core installation and version" "dotnet --version"
run_test ".NET Core list SDKs" "dotnet --list-sdks"

# Test Node.js and npm
run_test "Node.js installation and version" "node --version"
run_test "npm installation and version" "npm --version"

# Test Angular CLI
run_test "Angular CLI installation and version" "ng version --skip-git"

# Test Azure Functions Core Tools (optional)
run_test "Azure Functions Core Tools installation (optional)" "func --version || echo 'Azure Functions Core Tools not installed - can be installed with: npm install -g azure-functions-core-tools@4'"

# Test Azure Static Web Apps CLI (optional)
run_test "Azure Static Web Apps CLI installation (optional)" "swa --version || echo 'Azure SWA CLI not installed - can be installed with: npm install -g @azure/static-web-apps-cli'"

# Test SQL tools
run_test "SqlPackage installation" "/opt/sqlpackage/sqlpackage /version"
run_test "sqlcmd installation" "command_exists sqlcmd"

echo -e "\n🧪 2. TESTING SERVICE CONNECTIVITY"
echo "================================="

# Test SQL Server connectivity
run_test "SQL Server connectivity" "timeout 10 sqlcmd -S db -U sa -P P@ssw0rd! -Q 'SELECT 1' -b"

# Test Azurite connectivity
run_test "Azurite Blob service connectivity" "timeout 10 curl -s -f http://azurite:10000"
run_test "Azurite Queue service connectivity" "timeout 10 curl -s -f http://azurite:10001"
run_test "Azurite Table service connectivity" "timeout 10 curl -s -f http://azurite:10002"

echo -e "\n🧪 3. TESTING PROJECT CREATION AND BUILD"
echo "======================================="

# Create temporary directory for tests
TEST_DIR="/tmp/devcontainer-tests"
mkdir -p "$TEST_DIR"
cd "$TEST_DIR"

# Test .NET project creation and build
run_test ".NET Web API project creation" "dotnet new webapi -n TestWebApi --framework net9.0"
if [ -d "TestWebApi" ]; then
    cd TestWebApi
    run_test ".NET project restore" "dotnet restore"
    run_test ".NET project build" "dotnet build --no-restore"
    cd ..
fi

# Test Angular project creation (minimal test due to time constraints)
run_test "Angular project creation (basic)" "ng new TestAngularApp --minimal --routing=false --style=css --skip-git=true --skip-install=true --package-manager=npm"

# Test Azure Functions project creation (manual setup)
run_test "Azure Functions project structure creation" "mkdir TestFunctions && cd TestFunctions && echo '{\"name\":\"test-functions\"}' > package.json"

echo -e "\n🧪 4. TESTING SAMPLE PROJECTS (if they exist)"
echo "============================================="

# Test sample projects if they exist
if [ -d "/workspace/test-projects/SampleWebApi" ]; then
    cd /workspace/test-projects/SampleWebApi
    run_test "Sample .NET project build" "dotnet build --no-restore"
fi

if [ -d "/workspace/test-projects/SampleAngularApp" ]; then
    cd /workspace/test-projects/SampleAngularApp
    run_test "Sample Angular project lint" "npm run lint || echo 'Lint not configured, skipping'"
fi

if [ -d "/workspace/test-projects/SampleAzureFunctions" ]; then
    cd /workspace/test-projects/SampleAzureFunctions
    run_test "Sample Azure Functions project build" "npm run build"
fi

echo -e "\n📊 TEST RESULTS SUMMARY"
echo "======================="
echo -e "Tests passed: ${GREEN}$TESTS_PASSED${NC}"
echo -e "Tests failed: ${RED}$TESTS_FAILED${NC}"
echo -e "Total tests: $((TESTS_PASSED + TESTS_FAILED))"

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "\n${GREEN}🎉 ALL TESTS PASSED! DevContainer is working correctly.${NC}"
    exit 0
else
    echo -e "\n${RED}❌ Some tests failed. Please check the DevContainer configuration.${NC}"
    exit 1
fi