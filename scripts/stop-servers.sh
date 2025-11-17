#!/bin/bash

# ==============================================
# Kaizen 3D Printing - Stop Servers Script
# ==============================================

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_info() {
    echo -e "${YELLOW}ℹ $1${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

echo ""
echo "🛑 Stopping Kaizen servers..."
echo ""

# Read PIDs from file if exists
if [ -f /tmp/kaizen_servers.pid ]; then
    PIDS=$(cat /tmp/kaizen_servers.pid)
    for PID in $PIDS; do
        if kill -0 $PID 2>/dev/null; then
            kill $PID
            print_success "Stopped server (PID: $PID)"
        fi
    done
    rm /tmp/kaizen_servers.pid
fi

# Also kill any remaining PHP/Python servers on those ports
print_info "Checking for remaining servers..."

# Kill PHP server on port 8000
PHP_PID=$(lsof -ti:8000 2>/dev/null)
if [ ! -z "$PHP_PID" ]; then
    kill $PHP_PID 2>/dev/null
    print_success "Stopped Backend server on port 8000"
fi

# Kill Python server on port 3000
PYTHON_PID=$(lsof -ti:3000 2>/dev/null)
if [ ! -z "$PYTHON_PID" ]; then
    kill $PYTHON_PID 2>/dev/null
    print_success "Stopped Frontend server on port 3000"
fi

echo ""
print_success "All servers stopped!"
echo ""
