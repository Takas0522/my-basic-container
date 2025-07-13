# [Choice] .NET version: 8.0-bookworm, 8.0-jammy, 8.0-bullseye
FROM mcr.microsoft.com/devcontainers/dotnet:1-8.0-bookworm

# Add .NET global tools path
ENV PATH $PATH:/home/vscode/.dotnet:/home/vscode/.dotnet/tools

# [Optional] Uncomment this section to install additional OS packages.
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends software-properties-common curl unzip libicu72

# Install Node.js (using NodeSource repository for latest LTS)
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - \
    && apt-get install -y nodejs

# Install Angular CLI globally
RUN npm install -g @angular/cli

# Install Azure Functions Core Tools (ARM64 compatible for Apple Silicon/ARM PCs)
RUN npm install -g azure-functions-core-tools@4.0.7332-preview1

RUN npm install -g @azure/static-web-apps-cli

# Install SQL Tools: SQLPackage and sqlcmd
COPY sql/installSQLtools.sh installSQLtools.sh
RUN bash ./installSQLtools.sh \
     && apt-get clean -y && rm -rf /var/lib/apt/lists/* /tmp/library-scripts