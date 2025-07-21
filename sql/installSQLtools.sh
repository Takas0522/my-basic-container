#!/bin/bash

# Detect architecture
ARCH=$(uname -m)
echo "Detected architecture: $ARCH"

# Check if we're running in Docker/container
if [ -f /.dockerenv ]; then
    echo "Running in Docker container environment"
else
    echo "Running in host environment"
fi

# On ARM64, explicitly ensure qemu-user-static is not causing issues
if [[ "$ARCH" == "aarch64" || "$ARCH" == "arm64" ]]; then
    echo "ARM64 architecture detected - ensuring qemu emulation is not causing issues"
    # Optionally remove qemu-user-static if it's causing problems
    if dpkg -l | grep -q qemu-user-static; then
        echo "qemu-user-static is installed. This may cause x64 emulation issues."
        echo "Consider removing it if you experience x64 emulation errors."
    fi
fi

# Function to install sqlcmd based on architecture
install_sqlcmd() {
    echo "Installing Go-SQLCmd for $ARCH ..."
    
    # Get OS info for Microsoft repository
    . /etc/os-release
    
    case $ARCH in
        x86_64|amd64)
            echo "Installing sqlcmd for x64 architecture..."
            curl -sSL https://packages.microsoft.com/keys/microsoft.asc | sudo tee /etc/apt/trusted.gpg.d/microsoft.asc
            sudo add-apt-repository "$(wget -qO- https://packages.microsoft.com/config/ubuntu/20.04/prod.list)"
            sudo apt-get update
            sudo apt-get install -y sqlcmd
            ;;
        aarch64|arm64)
            echo "Installing sqlcmd for ARM64 architecture..."
            # For ARM64, we use the go-sqlcmd binary directly from releases
            SQLCMD_VERSION="v1.9.0"
            echo "Downloading sqlcmd ${SQLCMD_VERSION} for ARM64..."
            curl -sSL -o sqlcmd-linux-arm64.tar.bz2 "https://github.com/microsoft/go-sqlcmd/releases/download/${SQLCMD_VERSION}/sqlcmd-linux-arm64.tar.bz2"
            if [ $? -eq 0 ] && [ -f sqlcmd-linux-arm64.tar.bz2 ]; then
                echo "Extracting sqlcmd binary..."
                tar -xjf sqlcmd-linux-arm64.tar.bz2
                if [ -f sqlcmd ]; then
                    sudo mv sqlcmd /usr/local/bin/
                    sudo chmod +x /usr/local/bin/sqlcmd
                    # /usr/local/bin が PATH に含まれていることを確認
                    if ! echo $PATH | grep -q "/usr/local/bin"; then
                        echo 'export PATH="/usr/local/bin:$PATH"' | sudo tee -a /etc/profile
                        echo "Added /usr/local/bin to PATH in /etc/profile"
                    fi
                    echo "✅ sqlcmd successfully installed to /usr/local/bin/ for ARM64"
                    # Verify installation
                    /usr/local/bin/sqlcmd -? | head -1 || echo "Warning: sqlcmd verification failed"
                else
                    echo "❌ Failed to extract sqlcmd binary from archive"
                    ls -la
                    return 1
                fi
                rm -f sqlcmd-linux-arm64.tar.bz2
            else
                echo "❌ Failed to download ARM64 sqlcmd, falling back to package manager..."
                curl -sSL https://packages.microsoft.com/keys/microsoft.asc | sudo tee /etc/apt/trusted.gpg.d/microsoft.asc >/dev/null
                sudo add-apt-repository "$(wget -qO- https://packages.microsoft.com/config/ubuntu/20.04/prod.list)" >/dev/null
                sudo apt-get update >/dev/null
                sudo apt-get install -y sqlcmd || echo "Package manager installation also failed"
            fi
            ;;
        *)
            echo "Unsupported architecture: $ARCH"
            echo "Trying to install from package manager anyway..."
            curl -sSL https://packages.microsoft.com/keys/microsoft.asc | sudo tee /etc/apt/trusted.gpg.d/microsoft.asc
            sudo add-apt-repository "$(wget -qO- https://packages.microsoft.com/config/ubuntu/20.04/prod.list)"
            sudo apt-get update
            sudo apt-get install -y sqlcmd || echo "Failed to install sqlcmd from package manager"
            ;;
    esac
}

# Function to install SqlPackage based on architecture
install_sqlpackage() {
    echo "Installing Sqlpackage for $ARCH ..."
    
    case $ARCH in
        x86_64|amd64)
            echo "Installing SqlPackage for x64 architecture..."
            curl -sSL -o sqlpackage.zip "https://aka.ms/sqlpackage-linux"
            ;;
        aarch64|arm64)
            echo "Installing SqlPackage for ARM64 architecture..."
            # SqlPackageはまだARM64ネイティブバイナリがないため、エミュレーションが必要
            # または代替手段を使用する必要があります
            echo "⚠️ Warning: SqlPackage does not have native ARM64 support yet."
            echo "Creating informational placeholder script..."
            mkdir -p /opt/sqlpackage
            cat > /opt/sqlpackage/sqlpackage << 'EOF'
#!/bin/bash
echo "🚫 SqlPackage is not natively available for ARM64 architecture."
echo ""
echo "💡 Alternative options for database operations on ARM64:"
echo "   1. Use Azure Data Studio with SQL Database Projects extension"
echo "   2. Use dotnet CLI with SqlPackage NuGet package:"
echo "      dotnet tool install -g microsoft.sqlpackage"
echo "   3. Use SSDT in Visual Studio or Azure Data Studio"
echo "   4. Use x64 development environment for database projects"
echo ""
echo "🔧 For this DevContainer, consider:"
echo "   - Using sqlcmd for basic database operations"
echo "   - Entity Framework migrations for schema changes"
echo "   - Azure Data Studio for advanced database management"
exit 1
EOF
            chmod +x /opt/sqlpackage/sqlpackage
            echo "✅ SqlPackage placeholder script created for ARM64"
            return
            ;;
        *)
            echo "Unsupported architecture: $ARCH"
            echo "Creating SqlPackage placeholder for unsupported architecture..."
            mkdir -p /opt/sqlpackage
            cat > /opt/sqlpackage/sqlpackage << 'EOF'
#!/bin/bash
echo "🚫 SqlPackage is not available for this architecture."
echo ""
echo "💡 Detected architecture: $(uname -m)"
echo "💡 SqlPackage currently supports only x64 (amd64) architecture natively."
echo ""
echo "Alternative options:"
echo "   1. Use Azure Data Studio with SQL Database Projects extension"
echo "   2. Use dotnet CLI with SqlPackage NuGet package:"
echo "      dotnet tool install -g microsoft.sqlpackage"
echo "   3. Use x64 development environment for database projects"
exit 1
EOF
            chmod +x /opt/sqlpackage/sqlpackage
            echo "✅ SqlPackage placeholder script created for unsupported architecture"
            return
            ;;
    esac
    
    # Only extract and install if we actually downloaded the zip (x64 only)
    if [ -f sqlpackage.zip ]; then
        mkdir -p /opt/sqlpackage
        unzip sqlpackage.zip -d /opt/sqlpackage && rm sqlpackage.zip
        chmod a+x /opt/sqlpackage/sqlpackage
    fi
}

# Install both tools
install_sqlcmd
echo "Go-SQLCmd installation completed."

install_sqlpackage
echo "Sqlpackage installation completed."

# Verify installations
echo "Verifying installations..."
echo "sqlcmd version:"
# さまざまな場所のsqlcmdを試行
if command -v sqlcmd >/dev/null 2>&1; then
    sqlcmd -? | head -1 || echo "sqlcmd found but verification failed"
elif [ -f /usr/local/bin/sqlcmd ]; then
    /usr/local/bin/sqlcmd -? | head -1 || echo "/usr/local/bin/sqlcmd found but verification failed"
else
    echo "sqlcmd not found in expected locations"
fi

echo "sqlpackage version:"
# Check architecture before attempting to run sqlpackage
case $ARCH in
    x86_64|amd64)
        if [ -f /opt/sqlpackage/sqlpackage ]; then
            /opt/sqlpackage/sqlpackage /version || echo "sqlpackage verification failed"
        else
            echo "SqlPackage not installed correctly for x64"
        fi
        ;;
    *)
        echo "SqlPackage placeholder script created for $ARCH architecture"
        echo "Run /opt/sqlpackage/sqlpackage to see available alternatives"
        echo "No attempt will be made to run x64 binary on $ARCH architecture"
        ;;
esac