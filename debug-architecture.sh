#!/bin/bash

echo "=== Architecture Debug Information ==="
echo "uname -m: $(uname -m)"
echo "uname -a: $(uname -a)"
echo "dpkg --print-architecture: $(dpkg --print-architecture)"
echo ""

echo "=== SQL Tools Status ==="
echo "sqlcmd location: $(which sqlcmd || echo 'Not found in PATH')"
echo "sqlcmd version test:"
sqlcmd -? | head -1 2>/dev/null || echo "sqlcmd command failed"
echo ""

echo "sqlpackage location: $(which sqlpackage 2>/dev/null || echo 'Not in PATH')"
echo "sqlpackage version test:"
sqlpackage /? 2>/dev/null | head -1 || echo "sqlpackage command failed"
echo "dotnet tool list:"
dotnet tool list -g | grep sqlpackage || echo "No sqlpackage found in dotnet tools"
echo ""

echo "=== Environment Variables ==="
echo "PATH: $PATH"
echo ""

echo "=== Available binaries in /usr/local/bin ==="
ls -la /usr/local/bin/ | grep -E "(sqlcmd|sqlpackage)" || echo "No SQL tools found in /usr/local/bin"
