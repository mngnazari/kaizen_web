#!/bin/bash

# ==============================================
# Kaizen 3D Printing - Start Servers Script
# ==============================================

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

clear

echo -e "${GREEN}"
echo "╔════════════════════════════════════════╗"
echo "║   Kaizen 3D Printing Platform          ║"
echo "║   Starting Development Servers...      ║"
echo "╚════════════════════════════════════════╝"
echo -e "${NC}"
echo ""

# Change to project root
cd "$(dirname "$0")/.."

# Start Backend Server
print_info "Starting Backend API Server on port 8000..."
cd backend
php -S localhost:8000 -t public > /dev/null 2>&1 &
BACKEND_PID=$!
cd ..

sleep 2

# Check if backend started successfully
if kill -0 $BACKEND_PID 2>/dev/null; then
    print_success "Backend API Server started successfully (PID: $BACKEND_PID)"
else
    echo "❌ Failed to start Backend server"
    exit 1
fi

# Start Frontend Server
print_info "Starting Frontend Server on port 3000..."
cd frontend/public
python3 -m http.server 3000 > /dev/null 2>&1 &
FRONTEND_PID=$!
cd ../..

sleep 2

# Check if frontend started successfully
if kill -0 $FRONTEND_PID 2>/dev/null; then
    print_success "Frontend Server started successfully (PID: $FRONTEND_PID)"
else
    echo "❌ Failed to start Frontend server"
    kill $BACKEND_PID 2>/dev/null
    exit 1
fi

echo ""
echo -e "${GREEN}════════════════════════════════════════${NC}"
echo -e "${GREEN}   🎉 Servers are running!${NC}"
echo -e "${GREEN}════════════════════════════════════════${NC}"
echo ""
echo -e "${BLUE}📡 Backend API:${NC}  http://localhost:8000"
echo -e "${BLUE}🌐 Frontend:${NC}     http://localhost:3000"
echo ""
echo -e "${YELLOW}📝 Quick Links:${NC}"
echo "   • API Health:  http://localhost:8000/api/health"
echo "   • API Info:    http://localhost:8000/api"
echo ""
echo -e "${YELLOW}🛑 To stop servers:${NC}"
echo "   kill $BACKEND_PID $FRONTEND_PID"
echo ""
echo -e "   Or run: ${BLUE}./scripts/stop-servers.sh${NC}"
echo ""
echo "Press Ctrl+C to view logs (servers will keep running in background)"
echo ""

# Save PIDs to file
echo "$BACKEND_PID $FRONTEND_PID" > /tmp/kaizen_servers.pid

# Wait for user interrupt
trap "echo ''; echo 'Servers are still running in background'; exit 0" INT

echo "Monitoring servers... (Press Ctrl+C to exit this script)"
echo ""

# Monitor servers
while true; do
    if ! kill -0 $BACKEND_PID 2>/dev/null; then
        echo "❌ Backend server stopped unexpectedly"
        break
    fi

    if ! kill -0 $FRONTEND_PID 2>/dev/null; then
        echo "❌ Frontend server stopped unexpectedly"
        break
    fi

    sleep 5
done
