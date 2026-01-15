# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

A Caddy-based reverse proxy for local development with automatic SSL certificate generation.

## Architecture

- **mkcert container**: Generates SSL certificates on first run, stores in `./certs/`
- **Caddy container**: Reverse proxy with HTTPS, depends on mkcert completing first
- **Bind mount**: Certs stored locally in `./certs/` for easy access

## Key Commands

```bash
# Generate certificates (first time only)
docker-compose --profile setup run --rm mkcert

# Start the proxy
docker-compose up -d --build

# View logs
docker-compose logs -f caddy

# Stop the proxy
docker-compose down

# Regenerate certificates
rm -rf certs/* && docker-compose --profile setup run --rm mkcert

# Install CA on macOS
sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain ./certs/${DOMAIN}.rootCA.pem
```

## Configuration

Environment variables (set in `.env`):
- `DOMAIN` - Domain name for SSL cert (default: `localhost`)
- `UPSTREAM_URL` - URL for your local app (default: `http://host.docker.internal:3000`)

## Files

- **config/Caddyfile**: Proxy rules, TLS config, CSP header removal
- **scripts/mkcert/entrypoint.sh**: Script that generates certs if they don't exist
- **docker-compose.yml**: Service definitions with mkcert → caddy dependency
- **Dockerfile.mkcert**: Alpine image with mkcert for cert generation
- **Dockerfile.caddy**: Minimal Caddy image

## Ports

- `8080` → HTTP (redirects to HTTPS on 8443)
- `8443` → HTTPS (proxies to `${UPSTREAM_URL}`)
