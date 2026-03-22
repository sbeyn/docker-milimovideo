#!/bin/bash
# Convenience script to run the Milimo Video Frontend
# Usage: ./run_frontend.sh

# Ensure we are in the project root
cd "$(dirname "$0")"

cd web-app

# Changed real server host fqdn
grep -rw "localhost" src/* | awk '{print $1}' | sort | uniq | sed "s/:const//g" | sed "s/:export//g" | sed "s/://g" | uniq | xargs sed -i "s/localhost/${SERVER_HOST}/g" \

# Check if node_modules exists
if [ ! -d "node_modules" ]; then
    echo "Installing dependencies..."
    npm audit fix --force 
    npm install
fi

echo "Starting Web Interface..."
npm run dev -- --host 0.0.0.0
