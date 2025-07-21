#!/bin/bash
set -e

echo "🔄 Post-start setup..."

# Wait a bit for all services to be fully ready
sleep 5

# Check service connectivity
echo "🔍 Checking service connectivity..."

# Check SQL Server connectivity
echo "📊 Testing SQL Server connection..."
timeout 30 bash -c 'until sqlcmd -S db -U sa -P P@ssw0rd! -Q "SELECT 1" > /dev/null 2>&1; do sleep 2; done'
echo "✅ SQL Server is accessible"

# Check Azurite connectivity
echo "☁️ Testing Azurite connection..."
timeout 30 bash -c 'until curl -s http://azurite:10000 > /dev/null 2>&1; do sleep 2; done'
echo "✅ Azurite is accessible"

echo "✅ Post-start setup completed!"