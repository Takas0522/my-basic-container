# [Choice] .NET version: 9.0-bookworm, 9.0-jammy, 9.0-bullseye
FROM mcr.microsoft.com/devcontainers/dotnet:1-9.0-bookworm

# Add .NET global tools path
ENV PATH="$PATH:/home/vscode/.dotnet:/home/vscode/.dotnet/tools"

# [Optional] Uncomment this section to install additional OS packages.
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends software-properties-common curl unzip libicu72

# Install Node.js (using NodeSource repository for latest LTS) and core packages
RUN curl -k -fsSL https://deb.nodesource.com/setup_lts.x | bash - \
    && apt-get install -y nodejs pkg-config libsecret-1-dev \
    && npm config set strict-ssl false \
    && npm install -g @angular/cli@latest --force \
    && npm install -g azure-functions-core-tools@4 --unsafe-perm true \
    && npm install -g @azure/static-web-apps-cli \
    && npm config set strict-ssl true

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