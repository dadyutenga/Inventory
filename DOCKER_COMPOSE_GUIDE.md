# Docker Compose Deployment Guide

Production deployment using Docker Compose for the Inventory Management System.

---

## Quick Start

```bash
# 1. Generate production secrets
cp .env.production.example .env.production

# Generate SECRET_KEY_BASE
docker run --rm ruby:3.3-alpine ruby -rsecurerandom -e 'puts SecureRandom.hex(64)'
# Copy output to .env.production

# 2. Build and start
docker compose --env-file .env.production up -d --build

# 3. Verify
docker compose ps
curl http://localhost:7000/up
```

---

## Files Overview

| File | Purpose |
|------|---------|
| `docker-compose.yml` | Main orchestration (app, db, redis) |
| `docker-compose.override.yml.example` | Template for local customization |
| `.env.production.example` | Template for secrets/config |
| `Dockerfile` | Multi-stage Alpine build |

---

## Services

### App (Rails + Puma)
- **Port**: 7000
- **Memory**: 512MB limit
- **Health check**: `GET /up`

### Database (PostgreSQL 16)
- **Port**: 5432 (internal only by default)
- **Volume**: `postgres_data`

### Redis
- **Port**: 6379 (internal only by default)
- **Memory**: 64MB limit with LRU eviction

---

## Commands Reference

### Lifecycle

```bash
# Start all services (detached)
docker compose --env-file .env.production up -d

# Start with build
docker compose --env-file .env.production up -d --build

# Stop services (preserves volumes)
docker compose down

# Stop and remove volumes (DATA LOSS)
docker compose down -v

# Restart single service
docker compose restart app
```

### Logs

```bash
# All services
docker compose logs -f

# App only
docker compose logs -f app

# Last 100 lines
docker compose logs --tail=100 app

# Since timestamp
docker compose logs --since 2025-12-23T10:00:00 app
```

### Database

```bash
# Rails console
docker compose exec app bundle exec rails console

# Database console
docker compose exec db psql -U postgres -d inventory_production

# Run migrations
docker compose exec app bundle exec rails db:migrate

# Database backup
docker compose exec db pg_dump -U postgres inventory_production > backup.sql

# Database restore
docker compose exec -T db psql -U postgres inventory_production < backup.sql
```

### Debugging

```bash
# Shell into app container
docker compose exec app sh

# Check container stats
docker compose stats

# Inspect container
docker compose exec app bundle exec rails runner "puts Rails.env"

# View environment variables
docker compose exec app env | grep RAILS
```

---

## Configuration

### Environment Variables

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `SECRET_KEY_BASE` | ✅ | - | Rails secret (128 hex chars) |
| `POSTGRES_PASSWORD` | ✅ | `postgres` | Database password |
| `POSTGRES_DB` | ❌ | `inventory_production` | Database name |
| `WEB_CONCURRENCY` | ❌ | `2` | Puma workers |
| `RAILS_MAX_THREADS` | ❌ | `3` | Threads per worker |
| `SOLID_QUEUE_IN_PUMA` | ❌ | `false` | Run queue in Puma |

### Memory Tuning

| Container Memory | WEB_CONCURRENCY | RAILS_MAX_THREADS | DB Pool |
|-----------------|-----------------|-------------------|---------|
| 512MB | 1 | 3 | 5 |
| 1GB | 2 | 3 | 10 |
| 2GB | 4 | 3 | 15 |

> Formula: `DB_POOL = WEB_CONCURRENCY × RAILS_MAX_THREADS + 2`

---

## Production Checklist

### Before Deploy

- [ ] Generate unique `SECRET_KEY_BASE`
- [ ] Set strong `POSTGRES_PASSWORD`
- [ ] Review memory limits in `docker-compose.yml`
- [ ] Configure external volumes/backups
- [ ] Set up log aggregation

### Security

- [ ] Remove exposed ports from db/redis in production
- [ ] Use Docker secrets or external vault for credentials
- [ ] Enable TLS with reverse proxy (nginx/traefik)
- [ ] Restrict network access

### Monitoring

```bash
# Resource usage
docker compose stats

# Health status
docker compose ps

# Check app health endpoint
curl -f http://localhost:7000/up
```

---

## Reverse Proxy (Production)

Add nginx for TLS termination:

```yaml
# Add to docker-compose.yml services:
  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
      - ./certs:/etc/nginx/certs:ro
    depends_on:
      - app
    networks:
      - inventory_network
```

---

## Troubleshooting

### App won't start

```bash
# Check logs
docker compose logs app

# Verify database connection
docker compose exec app bundle exec rails db:version

# Check environment
docker compose exec app env
```

### Database connection refused

```bash
# Ensure db is healthy
docker compose ps db

# Check database logs
docker compose logs db

# Test connection manually
docker compose exec db pg_isready -U postgres
```

### Out of memory

```bash
# Check current usage
docker compose stats

# Reduce workers
# Edit .env.production: WEB_CONCURRENCY=1

# Restart
docker compose restart app
```

---

## Upgrade Process

```bash
# 1. Pull latest code
git pull origin main

# 2. Rebuild image
docker compose build app

# 3. Run migrations (zero-downtime)
docker compose exec app bundle exec rails db:migrate

# 4. Rolling restart
docker compose up -d --no-deps app

# 5. Verify
curl http://localhost:7000/up
```
