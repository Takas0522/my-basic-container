# Multi-architecture build support
ARG BUILDPLATFORM
ARG TARGETPLATFORM

# [Choice] .NET version: 9.0-bookworm, 9.0-jammy, 9.0-bullseye
FROM mcr.microsoft.com/devcontainers/dotnet:1-9.0-bookworm

# Display platform information for debugging
RUN echo "Build platform: ${BUILDPLATFORM:-not-set}" && \
    echo "Target platform: ${TARGETPLATFORM:-not-set}" && \
    echo "Container architecture: $(uname -m)" && \
    echo "============================="

# Add .NET global tools path
ENV PATH="$PATH:/home/vscode/.dotnet:/home/vscode/.dotnet/tools"

# [Optional] Uncomment this section to install additional OS packages.
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends software-properties-common curl unzip libicu72

# Install Node.js (using NodeSource repository for latest LTS) and core packages
RUN curl -k -fsSL https://deb.nodesource.com/setup_lts.x | bash - \
    && apt-get install -y nodejs pkg-config libsecret-1-dev \
    && node --version \
    && npm --version \
    && npm config set strict-ssl false \
    && npm install -g @angular/cli@latest --force \
    && npm install -g @azure/static-web-apps-cli \
    && npm config set strict-ssl true

# Install Azure Functions Core Tools with architecture detection
RUN ARCH=$(uname -m) && \
    if [ "$ARCH" = "x86_64" ] || [ "$ARCH" = "amd64" ]; then \
        echo "Installing Azure Functions Core Tools for x86_64..."; \
        npm install -g azure-functions-core-tools@4 --unsafe-perm true; \
    else \
        echo "Azure Functions Core Tools is not natively available for ARM64 architecture."; \
        echo "Attempting to install with x86_64 emulation..."; \
        # Try npm install with x86_64 emulation (may not work reliably)
        npm install -g azure-functions-core-tools@4 --unsafe-perm true || { \
            echo "Failed to install with emulation. Creating placeholder script..."; \
            mkdir -p /usr/local/bin; \
            echo '#!/bin/bash' > /usr/local/bin/func; \
            echo 'echo "🚫 Azure Functions Core Tools is not available for ARM64 architecture."' >> /usr/local/bin/func; \
            echo 'echo ""' >> /usr/local/bin/func; \
            echo 'echo "💡 Alternative options for Azure Functions development on ARM64:"' >> /usr/local/bin/func; \
            echo 'echo "   1. Use Visual Studio Code with Azure Functions extension"' >> /usr/local/bin/func; \
            echo 'echo "   2. Develop on x64 environment for Azure Functions"' >> /usr/local/bin/func; \
            echo 'echo "   3. Use Azure Portal for function development"' >> /usr/local/bin/func; \
            echo 'echo "   4. Use Azure Functions through Azure Static Web Apps CLI (available)"' >> /usr/local/bin/func; \
            echo 'echo ""' >> /usr/local/bin/func; \
            echo 'echo "🔧 For this DevContainer, consider:"' >> /usr/local/bin/func; \
            echo 'echo "   - Using swa (Static Web Apps CLI) for local development"' >> /usr/local/bin/func; \
            echo 'echo "   - Deploying directly to Azure for testing"' >> /usr/local/bin/func; \
            echo 'exit 1' >> /usr/local/bin/func; \
            chmod +x /usr/local/bin/func; \
            echo "✅ Azure Functions Core Tools placeholder script created for ARM64"; \
        }; \
    fi

# Note: Additional tools can be installed post-creation:
# - Azure Functions Core Tools: npm install -g azure-functions-core-tools@4
# - Azure SWA CLI: npm install -g @azure/static-web-apps-cli

# Install SQL Tools: SQLPackage and sqlcmd (with architecture detection)
COPY sql/installSQLtools.sh installSQLtools.sh
RUN chmod +x installSQLtools.sh \
    && bash ./installSQLtools.sh \
    && rm installSQLtools.sh \
    && apt-get clean -y && rm -rf /var/lib/apt/lists/* /tmp/library-scripts

# Ensure /usr/local/bin is in PATH (for ARM64 sqlcmd installations)
ENV PATH="/usr/local/bin:$PATH"

# Set environment variable to indicate we've handled architecture appropriately
ENV SQL_TOOLS_ARCH_CONFIGURED=true

# Display final architecture information
RUN echo "===== Final Architecture Information =====" && \
    echo "Container architecture: $(uname -m)" && \
    echo "TARGETPLATFORM: ${TARGETPLATFORM:-not-set}" && \
    echo "sqlcmd location: $(which sqlcmd 2>/dev/null || echo 'Not in PATH')" && \
    echo "sqlcmd in /usr/local/bin: $(ls -la /usr/local/bin/sqlcmd 2>/dev/null || echo 'Not found')" && \
    echo "PATH: $PATH" && \
    echo "============================================="