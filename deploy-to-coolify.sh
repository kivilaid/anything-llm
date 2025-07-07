#!/bin/bash

# Coolify API Deployment Script for AnythingLLM
# This script helps deploy AnythingLLM to your Coolify instance

set -e

echo "AnythingLLM Coolify Deployment Script"
echo "===================================="

# Configuration
COOLIFY_API_URL="${COOLIFY_API_URL:-https://your-coolify-instance.com}"
COOLIFY_API_TOKEN="${COOLIFY_API_TOKEN:-your-api-token}"
PROJECT_NAME="${PROJECT_NAME:-anythingllm}"
PORT="${PORT:-3222}"

# Check if required environment variables are set
if [ "$COOLIFY_API_URL" = "https://your-coolify-instance.com" ] || [ "$COOLIFY_API_TOKEN" = "your-api-token" ]; then
    echo "Error: Please set COOLIFY_API_URL and COOLIFY_API_TOKEN environment variables"
    echo "Example:"
    echo "  export COOLIFY_API_URL=https://your-coolify-instance.com"
    echo "  export COOLIFY_API_TOKEN=your-api-token"
    exit 1
fi

# Function to make API calls
coolify_api() {
    local method=$1
    local endpoint=$2
    local data=$3
    
    curl -s -X "$method" \
        -H "Authorization: Bearer $COOLIFY_API_TOKEN" \
        -H "Content-Type: application/json" \
        ${data:+-d "$data"} \
        "$COOLIFY_API_URL/api/v1/$endpoint"
}

echo "Creating Docker Compose deployment configuration..."

# Create the deployment JSON
DEPLOYMENT_CONFIG=$(cat <<EOF
{
  "name": "$PROJECT_NAME",
  "type": "docker-compose",
  "source": {
    "type": "github",
    "repository": "kivilaid/anything-llm",
    "branch": "master",
    "compose_file": "docker-compose.coolify.yml"
  },
  "environment": {
    "PORT": "$PORT",
    "SIG_KEY": "$(openssl rand -hex 16)",
    "SIG_SALT": "$(openssl rand -hex 16)",
    "JWT_SECRET": "$(openssl rand -hex 6)",
    "DISABLE_TELEMETRY": "true",
    "VECTOR_DB": "lancedb",
    "SERVER_PORT": "3001",
    "STORAGE_DIR": "/app/server/storage"
  },
  "ports": [
    {
      "published": "$PORT",
      "target": "3001"
    }
  ]
}
EOF
)

echo "Deploying to Coolify..."
RESPONSE=$(coolify_api POST "applications" "$DEPLOYMENT_CONFIG")

if echo "$RESPONSE" | grep -q "error"; then
    echo "Error creating deployment:"
    echo "$RESPONSE" | jq .
    exit 1
fi

APP_ID=$(echo "$RESPONSE" | jq -r '.id')
echo "Application created with ID: $APP_ID"

echo ""
echo "Deployment initiated successfully!"
echo ""
echo "Next steps:"
echo "1. Go to your Coolify dashboard"
echo "2. Navigate to the $PROJECT_NAME application"
echo "3. Add your LLM provider configuration:"
echo "   - LLM_PROVIDER=openai"
echo "   - OPEN_AI_KEY=sk-your-api-key"
echo "   - OPEN_MODEL_PREF=gpt-4o"
echo "4. Click 'Deploy' to start the application"
echo ""
echo "Your AnythingLLM instance will be available at:"
echo "  http://your-coolify-domain:$PORT"