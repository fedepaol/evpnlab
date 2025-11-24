#!/bin/bash
set -e

# Configuration
PORT="${1:-8080}"
BIND_IP="${2:-10.200.0.1}"

echo "=== Starting HTTP Server on Storage VM ==="
echo "Bind IP: $BIND_IP"
echo "Port: $PORT"
echo ""

# Create a simple index.html if it doesn't exist
if [ ! -f /tmp/index.html ]; then
    cat > /tmp/index.html <<'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Storage VM</title>
</head>
<body>
    <h1>Storage VM HTTP Server</h1>
    <p>This server is running on the storage VM and is reachable via BGP-advertised IP.</p>
    <p>Server IP: 10.200.0.1</p>
    <p>Hostname: storage</p>
</body>
</html>
EOF
    echo "Created /tmp/index.html"
fi

# Start Python HTTP server on the loopback IP
cd /tmp
echo "Starting HTTP server..."
echo "Access the server at: http://$BIND_IP:$PORT"
echo ""
echo "Press Ctrl+C to stop the server"
echo ""

# Use Python 3's http.server module
python3 -m http.server $PORT --bind $BIND_IP
