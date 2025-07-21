#!/bin/bash
set -e

echo "🔄 Post-start setup..."

# Wait a bit for all services to be fully ready
sleep 5

# wait_for_service関数定義
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

# サービス接続確認
echo "🔍 Checking service connectivity..."

# SQL Server
wait_for_service "SQL Server" "db" "1433"

# Azurite Blob
wait_for_service "Azurite Blob" "azurite" "10000"

echo "✅ Post-start setup completed!"