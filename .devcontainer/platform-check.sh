#!/bin/bash

echo "==============================================="
echo "DevContainer Platform Verification Script"
echo "==============================================="
echo ""

echo "🔍 Host Architecture Information:"
echo "   uname -m: $(uname -m)"
echo "   uname -a: $(uname -a)"
if command -v dpkg >/dev/null 2>&1; then
    echo "   dpkg architecture: $(dpkg --print-architecture)"
fi
echo ""

echo "🐳 Docker Platform Information:"
if [ -n "$BUILDPLATFORM" ]; then
    echo "   Build Platform: $BUILDPLATFORM"
else
    echo "   Build Platform: Not set"
fi

if [ -n "$TARGETPLATFORM" ]; then
    echo "   Target Platform: $TARGETPLATFORM"
else
    echo "   Target Platform: Not set"
fi
echo ""

echo "🛠️ SQL Tools Status:"
echo "   sqlcmd availability:"
if command -v sqlcmd >/dev/null 2>&1; then
    echo "   ✅ sqlcmd found in PATH: $(which sqlcmd)"
    sqlcmd_version=$(sqlcmd -? 2>/dev/null | head -1 | tr -d '\r' || echo "Version check failed")
    echo "      Version info: $sqlcmd_version"
elif [ -f /usr/local/bin/sqlcmd ]; then
    echo "   ✅ sqlcmd found in /usr/local/bin/"
    sqlcmd_version=$(/usr/local/bin/sqlcmd -? 2>/dev/null | head -1 | tr -d '\r' || echo "Version check failed")
    echo "      Version info: $sqlcmd_version"
else
    echo "   ❌ sqlcmd not found"
fi
echo ""

echo "   sqlpackage availability:"
if [ -f /opt/sqlpackage/sqlpackage ]; then
    echo "   ℹ️ sqlpackage found at /opt/sqlpackage/sqlpackage"
    case $(uname -m) in
        x86_64|amd64)
            sqlpackage_version=$(/opt/sqlpackage/sqlpackage /version 2>/dev/null | head -1 | tr -d '\r' || echo "Version check failed")
            echo "      Version info: $sqlpackage_version"
            echo "   ✅ Native x64 sqlpackage available"
            ;;
        aarch64|arm64)
            echo "   ⚠️ ARM64 platform detected - sqlpackage is a placeholder script"
            echo "      Run '/opt/sqlpackage/sqlpackage' to see alternatives"
            ;;
        *)
            echo "   ⚠️ Unsupported architecture - sqlpackage is a placeholder script"
            ;;
    esac
else
    echo "   ❌ sqlpackage not found"
fi
echo ""

echo "🌐 Network Services Status:"
echo "   Checking database connectivity..."
if command -v sqlcmd >/dev/null 2>&1; then
    if sqlcmd -S db,1433 -U sa -P "P@ssw0rd!" -Q "SELECT @@VERSION" -t 5 >/dev/null 2>&1; then
        echo "   ✅ Database connection successful"
    else
        echo "   ⚠️ Database connection failed (may need startup time)"
    fi
elif [ -f /usr/local/bin/sqlcmd ]; then
    if /usr/local/bin/sqlcmd -S db,1433 -U sa -P "P@ssw0rd!" -Q "SELECT @@VERSION" -t 5 >/dev/null 2>&1; then
        echo "   ✅ Database connection successful"
    else
        echo "   ⚠️ Database connection failed (may need startup time)"
    fi
else
    echo "   ❌ Cannot test database connection - sqlcmd not available"
fi

echo "   Checking Azurite connectivity..."
if curl -s http://azurite:10000/devstoreaccount1?comp=list&timeout=5 >/dev/null 2>&1; then
    echo "   ✅ Azurite blob service accessible"
else
    echo "   ⚠️ Azurite blob service not accessible (may need startup time)"
fi
echo ""

echo "📊 Container Environment Variables:"
echo "   ASPNETCORE_ENVIRONMENT: ${ASPNETCORE_ENVIRONMENT:-Not set}"
echo "   SQL_TOOLS_ARCH_CONFIGURED: ${SQL_TOOLS_ARCH_CONFIGURED:-Not set}"
echo "   PATH includes /usr/local/bin: $(echo $PATH | grep -q '/usr/local/bin' && echo 'Yes' || echo 'No')"
echo ""

echo "🎯 Architecture Compatibility Summary:"
arch=$(uname -m)
case $arch in
    x86_64|amd64)
        echo "   ✅ AMD64/x64 architecture detected"
        echo "   ✅ Full compatibility with all tools"
        echo "   ✅ Native performance expected"
        ;;
    aarch64|arm64)
        echo "   ✅ ARM64 architecture detected"
        echo "   ✅ DevContainer should work without platform warnings"
        echo "   ✅ sqlcmd available natively for ARM64"
        echo "   ⚠️ sqlpackage requires alternatives (see placeholder script)"
        echo "   💡 Consider using dotnet tool install -g microsoft.sqlpackage"
        ;;
    *)
        echo "   ⚠️ Unsupported architecture: $arch"
        echo "   ⚠️ Limited tool support available"
        ;;
esac
echo ""

echo "==============================================="
echo "Platform verification completed"
echo "==============================================="