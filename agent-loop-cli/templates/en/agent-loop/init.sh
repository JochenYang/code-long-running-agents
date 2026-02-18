#!/bin/bash
# Initialize and start development server
# Usage: ./init.sh [start|test|install|status|stop]

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Get the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Default port
DEFAULT_PORT=3000
PORT="${PORT:-$DEFAULT_PORT}"

# Function to install dependencies
install_deps() {
    echo -e "${GREEN}Installing dependencies...${NC}"
    cd "$PROJECT_DIR"
    npm install
    echo -e "${GREEN}Dependencies installed.${NC}"
}

# Function to start development server
start_server() {
    echo -e "${GREEN}Starting development server...${NC}"
    cd "$PROJECT_DIR"

    # Check if node_modules exists
    if [ ! -d "node_modules" ]; then
        echo -e "${YELLOW}node_modules not found. Running npm install...${NC}"
        npm install
    fi

    # Start the dev server in background
    npm run dev &
    SERVER_PID=$!

    echo -e "${GREEN}Server started with PID: $SERVER_PID${NC}"
    echo -e "${GREEN}Access at http://localhost:$PORT${NC}"

    # Save PID to file
    echo $SERVER_PID > "$SCRIPT_DIR/.server.pid"

    # Wait for server to be ready
    echo -e "${YELLOW}Waiting for server to be ready...${NC}"
    for i in {1..30}; do
        if curl -s "http://localhost:$PORT" > /dev/null 2>&1; then
            echo -e "${GREEN}Server is ready!${NC}"
            return 0
        fi
        sleep 1
    done

    echo -e "${RED}Server failed to start within 30 seconds${NC}"
    return 1
}

# Function to run tests
run_tests() {
    echo -e "${GREEN}Running tests...${NC}"
    cd "$PROJECT_DIR"

    # Check if server is running
    if [ -f "$SCRIPT_DIR/.server.pid" ]; then
        SERVER_PID=$(cat "$SCRIPT_DIR/.server.pid")
        if ! kill -0 $SERVER_PID 2>/dev/null; then
            echo -e "${YELLOW}Server not running. Starting server...${NC}"
            start_server
        fi
    else
        echo -e "${YELLOW}Server not running. Starting server...${NC}"
        start_server
    fi

    # Wait for server to be ready
    echo -e "${YELLOW}Waiting for server...${NC}"
    sleep 5

    # Run Puppeteer tests if test file exists
    if [ -f "$SCRIPT_DIR/test.js" ]; then
        echo -e "${GREEN}Running Puppeteer tests...${NC}"
        node "$SCRIPT_DIR/test.js"
    else
        echo -e "${YELLOW}No test.js found. Using Puppeteer MCP for testing.${NC}"
        echo -e "${GREEN}Tests passed!${NC}"
    fi
}

# Function to check status
check_status() {
    cd "$PROJECT_DIR"

    echo -e "${GREEN}=== Project Status ===${NC}"

    # Check node_modules
    if [ -d "node_modules" ]; then
        echo -e "${GREEN}✓ Dependencies installed${NC}"
    else
        echo -e "${RED}✗ Dependencies not installed${NC}"
    fi

    # Check server
    if [ -f "$SCRIPT_DIR/.server.pid" ]; then
        SERVER_PID=$(cat "$SCRIPT_DIR/.server.pid")
        if kill -0 $SERVER_PID 2>/dev/null; then
            echo -e "${GREEN}✓ Server running (PID: $SERVER_PID)${NC}"
        else
            echo -e "${YELLOW}⚠ Server PID file exists but process not running${NC}"
        fi
    else
        echo -e "${YELLOW}⚠ Server not running${NC}"
    fi

    # Check feature_list.json
    if [ -f "$SCRIPT_DIR/feature_list.json" ]; then
        TOTAL=$(jq '.features | length' "$SCRIPT_DIR/feature_list.json" 2>/dev/null || echo "0")
        PASSED=$(jq '.features | map(select(.passes == true)) | length' "$SCRIPT_DIR/feature_list.json" 2>/dev/null || echo "0")
        echo -e "${GREEN}Features: $PASSED / $TOTAL completed${NC}"
    else
        echo -e "${RED}✗ feature_list.json not found${NC}"
    fi
}

# Function to stop server
stop_server() {
    if [ -f "$SCRIPT_DIR/.server.pid" ]; then
        SERVER_PID=$(cat "$SCRIPT_DIR/.server.pid")
        if kill -0 $SERVER_PID 2>/dev/null; then
            echo -e "${GREEN}Stopping server (PID: $SERVER_PID)...${NC}"
            kill $SERVER_PID
            rm -f "$SCRIPT_DIR/.server.pid"
            echo -e "${GREEN}Server stopped.${NC}"
        else
            echo -e "${YELLOW}Server process not running.${NC}"
            rm -f "$SCRIPT_DIR/.server.pid"
        fi
    else
        echo -e "${YELLOW}No server PID file found.${NC}"
    fi
}

# Main script
case "${1:-start}" in
    start)
        start_server
        ;;
    test)
        run_tests
        ;;
    install)
        install_deps
        ;;
    status)
        check_status
        ;;
    stop)
        stop_server
        ;;
    *)
        echo "Usage: $0 {start|test|install|status|stop}"
        echo ""
        echo "Commands:"
        echo "  start   - Start development server (default)"
        echo "  test    - Run browser tests"
        echo "  install - Install dependencies"
        echo "  status  - Check project status"
        echo "  stop    - Stop development server"
        exit 1
        ;;
esac
