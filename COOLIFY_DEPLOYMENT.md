# AnythingLLM Deployment Guide for Coolify

This guide helps you deploy AnythingLLM on Coolify, addressing common issues that arise from the standard Docker configuration.

## Prerequisites

- A Coolify instance (v4 or later)
- Access to Coolify's dashboard
- An LLM provider API key (OpenAI, Anthropic, Ollama, etc.)

## Deployment Methods

### Method 1: Docker Compose (Recommended)

#### 1. Create a New Service in Coolify

1. Log into your Coolify dashboard
2. Navigate to your project/environment
3. Click "Add Resource" → "Docker Compose"
4. Name your service (e.g., "anythingllm")

#### 2. Configure the Docker Compose

**Important**: Make sure to set the compose file path correctly in Coolify:
- **Compose File**: `docker-compose.coolify.yml` (in repository root)
- OR use `docker/docker-compose.coolify.yml` if you prefer

Use the official Docker Hub image (no building required):

```yaml
name: anythingllm-coolify

networks:
  anything-llm:
    driver: bridge

volumes:
  anythingllm_storage:
    driver: local
  anythingllm_hotdir:
    driver: local
  anythingllm_outputs:
    driver: local

services:
  anything-llm:
    container_name: anythingllm
    image: mintplexlabs/anythingllm:latest
    volumes:
      - anythingllm_storage:/app/server/storage
      - anythingllm_hotdir:/app/collector/hotdir
      - anythingllm_outputs:/app/collector/outputs
    ports:
      - "3001:3001"
    environment:
      - SERVER_PORT=3001
      - STORAGE_DIR=/app/server/storage
      - VECTOR_DB=lancedb
      - DISABLE_TELEMETRY=true
    networks:
      - anything-llm
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3001/api/ping"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
```

#### 3. Configure Environment Variables

In Coolify's environment variables section, add the following REQUIRED variables:

#### Security Keys (REQUIRED)
```bash
SIG_KEY=<generate-random-32-char-string>
SIG_SALT=<generate-random-32-char-string>
JWT_SECRET=<generate-random-12-char-string>
```

**Important**: Generate secure random strings for these values. You can use:
```bash
# Generate 32-character string
openssl rand -hex 16

# Generate 12-character string
openssl rand -hex 6
```

#### LLM Configuration (Choose One)

**For OpenAI:**
```bash
LLM_PROVIDER=openai
OPEN_AI_KEY=sk-your-api-key-here
OPEN_MODEL_PREF=gpt-4o
```

**For Anthropic Claude:**
```bash
LLM_PROVIDER=anthropic
ANTHROPIC_API_KEY=sk-ant-your-api-key-here
ANTHROPIC_MODEL_PREF=claude-3-sonnet-20240229
```

**For Ollama (Local):**
```bash
LLM_PROVIDER=ollama
OLLAMA_BASE_PATH=http://your-ollama-server:11434
OLLAMA_MODEL_PREF=llama2
```

**For Google Gemini:**
```bash
LLM_PROVIDER=gemini
GEMINI_API_KEY=your-api-key-here
GEMINI_LLM_MODEL_PREF=gemini-2.0-flash-lite
```

#### Optional Configuration

**Enable Authentication:**
```bash
AUTH_TOKEN=your-secure-access-token
```

**Configure Embeddings (if needed):**
```bash
EMBEDDING_ENGINE=openai
OPEN_AI_KEY=sk-your-api-key-here
EMBEDDING_MODEL_PREF=text-embedding-ada-002
```

### 4. Deploy the Application

1. Click "Save" to save your configuration
2. Click "Deploy" to start the deployment
3. Monitor the deployment logs for any errors

### 5. Access Your Instance

Once deployed:
- Access AnythingLLM at: `https://your-coolify-domain:3001`
- Or use the URL provided by Coolify if you've configured a custom domain

### Method 2: Dockerfile Build (For Custom Forks)

If you need to build from your fork with custom modifications:

#### 1. Create a New Service

1. In Coolify, click "Add Resource" → "Public Repository"
2. Enter your fork URL: `https://github.com/YOUR_USERNAME/anything-llm`
3. Select branch: `master` (or your branch)

#### 2. Configure Build Settings

1. **Build Pack**: Select "Dockerfile"
2. **Base Directory**: `/docker`
3. **Dockerfile Location**: `./Dockerfile`
4. **Port**: `3001`

#### 3. Add Build Arguments

In the build arguments section:
```
ARG_UID=1000
ARG_GID=1000
```

#### 4. Configure Environment Variables

Add the same environment variables as Method 1 (see above).

#### 5. Deploy

Click "Deploy" and monitor the build logs.

## Troubleshooting

### Common Issues and Solutions

#### 1. "resolve : lstat /artifacts/docker: no such file or directory"
- **Issue**: Coolify can't find the Docker build context
- **Solution**: Use the pre-built image configuration (no build section in compose file)
- **Alternative**: Use `docker-compose.coolify.yml` from repository root

#### 2. Container Fails to Start
- **Check logs**: Look for missing environment variables
- **Solution**: Ensure all REQUIRED environment variables are set

#### 3. "SYS_ADMIN capability" Error
- **Issue**: The Coolify-specific compose file removes this capability
- **Solution**: Use `docker-compose.coolify.yml` instead of the standard compose file

#### 4. Permission Errors
- **Issue**: User permission conflicts
- **Solution**: The Coolify configuration removes user directives to let Coolify handle permissions

#### 5. Data Loss on Restart
- **Issue**: Volumes not properly configured
- **Solution**: Ensure named volumes are used (as in the Coolify compose file)

#### 6. Cannot Connect to LLM
- **Issue**: API keys or endpoints not properly set
- **Solution**: Double-check your LLM provider configuration in environment variables

### Verification Steps

1. **Check Health Status**:
   ```bash
   curl https://your-domain:3001/api/ping
   ```

2. **Verify Storage**:
   - Upload a document
   - Restart the container
   - Check if the document persists

3. **Test LLM Connection**:
   - Create a workspace
   - Try to chat with the LLM

## Advanced Configuration

### Using External Vector Databases

If you want to use Pinecone, Weaviate, or other vector databases:

```bash
# Pinecone
VECTOR_DB=pinecone
PINECONE_API_KEY=your-key
PINECONE_INDEX=your-index

# PostgreSQL with pgvector
VECTOR_DB=pgvector
PGVECTOR_CONNECTION_STRING=postgresql://user:pass@host:5432/db
```

### Enabling Agent Capabilities

For web browsing and search capabilities:

```bash
# Google Search
AGENT_GSE_KEY=your-key
AGENT_GSE_CTX=your-context

# Serper.dev
AGENT_SERPER_DEV_KEY=your-key
```

## Security Recommendations

1. **Always set strong security tokens** for `SIG_KEY`, `SIG_SALT`, and `JWT_SECRET`
2. **Enable AUTH_TOKEN** for production deployments
3. **Use HTTPS** through Coolify's reverse proxy
4. **Regularly update** the container image
5. **Monitor logs** for suspicious activity

## Support

- **AnythingLLM Documentation**: https://docs.anythingllm.com
- **GitHub Issues**: https://github.com/Mintplex-Labs/anything-llm/issues
- **Discord Community**: Check the official AnythingLLM Discord

## Notes

- This configuration is optimized for Coolify v4+
- The setup uses named volumes for data persistence
- Telemetry is disabled by default for privacy
- The configuration assumes a single-container deployment