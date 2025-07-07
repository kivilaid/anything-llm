# Quick Deploy Guide for Coolify

Since you already have a deployment in Coolify, follow these steps to fix it:

## 1. Update Your Existing Deployment

In your Coolify dashboard for the `kivilaid/anything-llm` application:

### General Tab:
- **Build Pack**: Docker Compose
- **Base Directory**: Leave empty (or `/`)
- **Docker Compose Location**: `docker-compose.coolify.yml`
- **Port Exposes**: `3222:3001`

### Environment Variables Tab:
Add these variables:

```bash
# REQUIRED - Generate secure random values
SIG_KEY=use_32_random_chars_here
SIG_SALT=use_32_random_chars_here  
JWT_SECRET=use_12_random_chars_here

# Port configuration
PORT=3222
SERVER_PORT=3001
STORAGE_DIR=/app/server/storage

# LLM Provider (choose one)
LLM_PROVIDER=openai
OPEN_AI_KEY=sk-your-openai-key-here
OPEN_MODEL_PREF=gpt-4o

# OR for Anthropic:
# LLM_PROVIDER=anthropic
# ANTHROPIC_API_KEY=sk-ant-your-key-here
# ANTHROPIC_MODEL_PREF=claude-3-sonnet-20240229

# Optional
AUTH_TOKEN=your-access-password
DISABLE_TELEMETRY=true
VECTOR_DB=lancedb
```

### Advanced Tab:
- **Custom Docker Options**: Leave empty (no SYS_ADMIN needed)
- **Health Check Path**: `/api/ping`

## 2. Generate Secure Keys

Run these commands to generate secure keys:

```bash
# Generate SIG_KEY (32 chars)
openssl rand -hex 16

# Generate SIG_SALT (32 chars)  
openssl rand -hex 16

# Generate JWT_SECRET (12 chars)
openssl rand -hex 6
```

## 3. Deploy

1. Click "Save" to save all settings
2. Click "Deploy" to start deployment
3. Monitor the deployment logs

## 4. Verify Deployment

Once deployed, check:
- Health status at: `http://your-domain:3222/api/ping`
- Access the UI at: `http://your-domain:3222`

## Troubleshooting

If deployment fails:

1. Check the deployment logs for specific errors
2. Ensure all required environment variables are set
3. Verify the compose file path is correct
4. Check that port 3222 is not already in use

The key difference from your previous attempts:
- We're using `docker-compose.coolify.yml` which uses the pre-built image
- No building from source (avoids the Dockerfile path issue)
- All configuration through environment variables