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

# Function to install sqlcmd for all architectures
install_sqlcmd() {
    echo "Installing sqlcmd (Go) for $ARCH ..."
    
    # Get OS info for Microsoft repository
    . /etc/os-release
    
    echo "Using Microsoft package repository for sqlcmd installation..."
    
    # Add Microsoft package repository and install sqlcmd
    curl -sSL https://packages.microsoft.com/keys/microsoft.asc | sudo tee /etc/apt/trusted.gpg.d/microsoft.asc
    sudo add-apt-repository "$(wget -qO- https://packages.microsoft.com/config/ubuntu/20.04/prod.list)"
    sudo apt-get update
    
    if sudo apt-get install -y sqlcmd; then
        echo "✅ sqlcmd successfully installed from Microsoft package repository for $ARCH"
    else
        echo "❌ Failed to install sqlcmd from package repository"
        echo "This may indicate that the package is not available for $ARCH architecture"
        echo "or there's a network/repository issue"
        return 1
    fi
}

# Function to install SqlPackage for all architectures
install_sqlpackage() {
    echo "Installing SqlPackage for $ARCH ..."
    
    # First try installing via dotnet tool (recommended method)
    if command -v dotnet >/dev/null 2>&1; then
        echo "Installing SqlPackage via dotnet tool..."
        if dotnet tool install -g microsoft.sqlpackage; then
            echo "✅ SqlPackage successfully installed via dotnet tool for $ARCH"
            return
        else
            echo "⚠️ Failed to install SqlPackage via dotnet tool, trying zip download..."
        fi
    else
        echo "dotnet CLI not found, trying zip download..."
    fi
    
    # Fallback to zip download method
    echo "Installing SqlPackage from zip download..."
    curl -sSL -o sqlpackage.zip "https://aka.ms/sqlpackage-linux"
    
    if [ $? -eq 0 ] && [ -f sqlpackage.zip ]; then
        mkdir -p /opt/sqlpackage
        unzip sqlpackage.zip -d /opt/sqlpackage && rm sqlpackage.zip
        chmod a+x /opt/sqlpackage/sqlpackage
        echo "✅ SqlPackage successfully installed from zip download for $ARCH"
    else
        echo "❌ Failed to download SqlPackage zip file"
        echo "This may indicate a network issue or the package is not available for $ARCH architecture"
        return 1
    fi
}

# Install both tools
install_sqlcmd
echo "sqlcmd installation completed."

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
# Check if sqlpackage is available in PATH (dotnet tool)
if command -v sqlpackage >/dev/null 2>&1; then
    sqlpackage /? | head -1 || echo "sqlpackage found in PATH but version check failed"
elif dotnet tool list -g | grep -q microsoft.sqlpackage; then
    echo "SqlPackage installed as dotnet tool but not in PATH"
    echo "Available via: $(dotnet tool list -g | grep microsoft.sqlpackage)"
else
    echo "SqlPackage not found in expected locations"
fi