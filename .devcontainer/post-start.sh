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
    local max_attempts=60  # 試行回数を増やす
    local attempt=1
    
    echo "⏳ Waiting for $service_name to be ready..."
    
    # DNS解決テスト
    echo "🔍 Testing DNS resolution for $host..."
    if nslookup "$host" >/dev/null 2>&1; then
        echo "✅ DNS resolution OK for $host"
    else
        echo "❌ DNS resolution failed for $host"
    fi
    
    while [ $attempt -le $max_attempts ]; do
        echo "   Attempt $attempt/$max_attempts: Testing $host:$port..."
        
        # 複数の接続方法を試す
        if timeout 5 bash -c "</dev/tcp/$host/$port" 2>/dev/null; then
            echo "✅ $service_name is ready!"
            # 接続安定性の確認
            sleep 2
            if timeout 5 bash -c "</dev/tcp/$host/$port" 2>/dev/null; then
                return 0
            else
                echo "   Connection unstable, retrying..."
            fi
        elif command -v nc >/dev/null 2>&1 && nc -z -w5 "$host" "$port" 2>/dev/null; then
            echo "✅ $service_name is ready (via nc)!"
            return 0
        else
            echo "   Connection failed to $host:$port"
        fi
        
        sleep 5  # 待機時間を延長
        attempt=$((attempt + 1))
    done
    echo "⚠️  Warning: $service_name did not become ready after ${max_attempts} attempts"
    
    # 失敗時の診断情報
    echo "🔍 Diagnostic information:"
    if command -v docker >/dev/null 2>&1; then
        echo "📋 Docker containers related to $service_name:"
        docker ps -a | grep -i "$host\|sql\|db" || echo "No related containers found"
    fi
    
    return 1
}

# サービス接続確認
echo "🔍 Checking service connectivity..."

# SQL Server
wait_for_service "SQL Server" "db" "1433"

# Azurite Blob
wait_for_service "Azurite Blob" "azurite" "10000"

echo "✅ Post-start setup completed!"