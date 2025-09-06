#!/bin/bash

echo "🔍 SQL Server Connection Test"
echo "=============================="

# 環境変数
DB_HOST="db"
DB_PORT="1433"
DB_USER="sa"
DB_PASSWORD="P@ssw0rd!"

echo "📋 Connection Details:"
echo "  Host: $DB_HOST"
echo "  Port: $DB_PORT"
echo "  User: $DB_USER"
echo ""

# 基本的な接続テスト
echo "🔌 Testing basic connectivity..."
if timeout 5 bash -c "</dev/tcp/$DB_HOST/$DB_PORT" 2>/dev/null; then
    echo "✅ Port $DB_PORT is accessible on $DB_HOST"
else
    echo "❌ Cannot connect to $DB_HOST:$DB_PORT"
    exit 1
fi

# DNS解決テスト
echo ""
echo "🌐 Testing DNS resolution..."
DB_IP=$(getent hosts $DB_HOST | awk '{print $1}')
if [ -n "$DB_IP" ]; then
    echo "✅ $DB_HOST resolves to $DB_IP"
else
    echo "❌ Cannot resolve $DB_HOST"
fi

# sqlcmdがあるかチェック
echo ""
echo "🔧 Checking for SQL tools..."
if command -v sqlcmd >/dev/null 2>&1; then
    echo "✅ sqlcmd is available"
    echo ""
    echo "🔍 Testing SQL Server connection with sqlcmd..."
    
    # SQL Server接続テスト
    if timeout 10 sqlcmd -S "$DB_HOST,$DB_PORT" -U "$DB_USER" -P "$DB_PASSWORD" -Q "SELECT 1 as Test" -l 5 2>/dev/null; then
        echo "✅ SQL Server connection successful!"
    else
        echo "❌ SQL Server connection failed"
        echo ""
        echo "💡 Try these steps:"
        echo "   1. Verify the password in .env file"
        echo "   2. Check if SQL Server container is running"
        echo "   3. Wait a bit longer for SQL Server to fully start"
    fi
else
    echo "⚠️  sqlcmd not available - install SQL Server tools to test database connectivity"
    echo ""
    echo "💡 For VS Code MSSQL extension, use these connection settings:"
    echo "   Server: $DB_HOST,$DB_PORT"
    echo "   Authentication: SQL Login"
    echo "   User: $DB_USER"
    echo "   Password: $DB_PASSWORD"
    echo "   Encrypt: Optional"
    echo "   Trust Server Certificate: Yes"
fi

echo ""
echo "🏁 Connection test completed!"
