#!/bin/bash
# Initialize and start development server

echo "Starting development environment..."

# Check if node_modules exists
if [ ! -d "node_modules" ]; then
    echo "Installing dependencies..."
    npm install
fi

# Start development server
echo "Starting server..."
npm run dev

echo "Server started. Access at http://localhost:3000"
