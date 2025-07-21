#!/bin/bash

# Detect architecture
ARCH=$(uname -m)
echo "Detected architecture: $ARCH"

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
                    echo "sqlcmd successfully installed to /usr/local/bin/"
                else
                    echo "Failed to extract sqlcmd binary from archive"
                    ls -la
                fi
                rm -f sqlcmd-linux-arm64.tar.bz2
            else
                echo "Failed to download ARM64 sqlcmd, falling back to package manager..."
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
            echo "Warning: SqlPackage does not have native ARM64 support yet."
            echo "Attempting to install x64 version (requires emulation)..."
            curl -sSL -o sqlpackage.zip "https://aka.ms/sqlpackage-linux" || {
                echo "Failed to download SqlPackage. Creating placeholder..."
                mkdir -p /opt/sqlpackage
                cat > /opt/sqlpackage/sqlpackage << 'EOF'
#!/bin/bash
echo "SqlPackage is not available for ARM64 architecture."
echo "Please use an x64 machine or consider using alternative tools like:"
echo "- Azure Data Studio with SQL Database Projects extension"
echo "- dotnet CLI with SqlPackage NuGet package"
echo "- SSDT in Visual Studio or Azure Data Studio"
exit 1
EOF
                chmod +x /opt/sqlpackage/sqlpackage
                return
            }
            ;;
        *)
            echo "Trying x64 version for unsupported architecture: $ARCH"
            curl -sSL -o sqlpackage.zip "https://aka.ms/sqlpackage-linux"
            ;;
    esac
    
    mkdir -p /opt/sqlpackage
    unzip sqlpackage.zip -d /opt/sqlpackage && rm sqlpackage.zip
    chmod a+x /opt/sqlpackage/sqlpackage
}

# Install both tools
install_sqlcmd
echo "Go-SQLCmd installation completed."

install_sqlpackage
echo "Sqlpackage installation completed."

# Verify installations
echo "Verifying installations..."
echo "sqlcmd version:"
sqlcmd -? | head -1 || echo "sqlcmd verification failed"

echo "sqlpackage version:"
/opt/sqlpackage/sqlpackage /version || echo "sqlpackage verification failed"