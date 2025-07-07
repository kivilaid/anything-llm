# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

AnythingLLM is a full-stack AI application that enables users to transform documents into chat contexts for LLM conversations. It's architected as a microservices monorepo with three main components:

- **Server** (`/server/`) - Node.js/Express backend with LLM integrations and vector database management
- **Frontend** (`/frontend/`) - React 18 + Vite frontend with real-time chat interface  
- **Collector** (`/collector/`) - Document processing microservice for parsing and extracting content

## Development Commands

### Setup and Development
```bash
# Initial setup - creates .env files and sets up database
yarn setup

# Development (run in separate terminals)
yarn dev:server    # Backend server on :3001
yarn dev:frontend  # Frontend on :3000  
yarn dev:collector # Document processor on :8888

# Run all services concurrently
yarn dev:all

# Production builds
yarn prod:server
yarn prod:frontend
```

### Database Management
```bash
# Generate Prisma client
yarn prisma:generate

# Run migrations
yarn prisma:migrate

# Seed database
yarn prisma:seed

# Reset database (clears all data)
yarn prisma:reset
```

### Code Quality
```bash
# Lint all components
yarn lint

# Test suite
yarn test
```

### Specialized Commands
```bash
# Translation management
yarn verify:translations
yarn normalize:translations

# Cloud deployment generation
yarn generate:cloudformation
yarn generate::gcp_deployment
```

## Architecture Overview

### Core Components

**Server Architecture** (`/server/`):
- Express.js with WebSocket support for real-time chat
- Prisma ORM with SQLite (default) or PostgreSQL
- Multi-user authentication with JWT tokens
- Provider abstraction layer for 25+ LLM services
- Vector database integration (LanceDB, Pinecone, Chroma, etc.)
- Agent workflow system with web browsing capabilities

**Frontend Architecture** (`/frontend/`):
- React 18 with modern hooks and context patterns
- Vite build system with HMR
- Tailwind CSS for styling
- i18next for internationalization (15+ languages)
- Real-time chat with WebSocket integration
- Workspace-based document management

**Collector Architecture** (`/collector/`):
- Standalone document processing service
- Supports PDF, DOCX, TXT, EPUB, images (OCR), audio, video
- Web scraping with Puppeteer
- Data connectors for Confluence, GitHub, YouTube, etc.
- Text chunking and embedding preparation

### Key Database Models

**Core Entities** (Prisma schema):
- `users` - User management with roles and permissions
- `workspaces` - Document containers/chat contexts  
- `workspace_documents` - Document metadata and relationships
- `workspace_chats` - Chat history and conversations
- `workspace_threads` - Threaded conversations
- `system_settings` - Application configuration
- `embed_configs` - Embeddable widget configurations

### API Structure

**Main API Endpoints** (`/server/endpoints/`):
- `/api/auth/` - Authentication and user management
- `/api/workspaces/` - Workspace CRUD operations
- `/api/documents/` - Document management and processing
- `/api/chat/` - LLM chat interactions
- `/api/admin/` - Administrative functions
- `/api/embed/` - Embeddable widget API
- `/api/agents/` - AI agent management
- `/api/system/` - System settings and health checks

**Developer API** (`/server/endpoints/api/`):
- OpenAI compatibility layer at `/api/openai/`
- Swagger documentation auto-generated
- Comprehensive JSDoc coverage for all endpoints

### Provider System

**LLM Providers** (`/server/utils/AiProviders/`):
Abstracted interface supporting OpenAI, Anthropic, AWS Bedrock, Google Gemini, Ollama, LM Studio, and 20+ other providers.

**Vector Databases** (`/server/utils/vectorDbProviders/`):
Support for LanceDB (default), Pinecone, Chroma, Weaviate, Qdrant, Milvus, and others.

**Embedding Engines** (`/server/utils/EmbeddingEngines/`):
Multiple embedding providers including native embedder, OpenAI, Azure OpenAI, and Cohere.

## Important Configuration

### Environment Files
- `server/.env.development` - Backend configuration with LLM API keys, database settings
- `frontend/.env` - Frontend development server configuration  
- `collector/.env` - Document processing service configuration
- `docker/.env` - Docker deployment environment variables

### Key Configuration Areas
- **LLM Provider Settings**: API keys, model configurations, rate limits
- **Vector Database**: Connection strings, collection names, index settings
- **Authentication**: JWT secrets, session management
- **Document Processing**: File type handlers, OCR settings, chunking parameters
- **Agent Services**: External API keys for web browsing, etc.

## Development Patterns

### Code Organization
- **Models** (`/server/models/`) - Database entities and business logic
- **Utils** (`/server/utils/`) - Shared utilities and provider integrations
- **Endpoints** (`/server/endpoints/`) - API route handlers
- **Frontend Components** (`/frontend/src/components/`) - React components organized by feature
- **Localization** (`/frontend/src/locales/`) - i18n translation files

### Testing
- Jest test framework with minimal current coverage
- ESLint with Prettier for code formatting
- Hermes parser for JavaScript parsing
- Flow type checking support

### Multi-User Support
- Role-based access control (admin, user)
- Workspace-level permissions
- API key management system
- Embedded widget configurations per workspace

## Deployment

### Docker Deployment
Multi-stage Docker builds supporting ARM64 and AMD64 architectures. Use `docker-compose.yml` for local development or production deployment.

### Cloud Deployment  
Pre-built templates for AWS CloudFormation, GCP Deployment Manager, and various cloud platforms (Railway, Render, DigitalOcean).

## Security Considerations

- JWT-based authentication with refresh tokens
- API key rotation and secure storage
- Input validation with Joi schemas
- Built-in encryption manager for sensitive data
- Optional telemetry (can be disabled with `DISABLE_TELEMETRY=true`)