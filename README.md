# SSL Proxy

A Dockerized Caddy reverse proxy with automatic SSL certificate generation for local development.

## Features

- Automatic SSL certificate generation via mkcert
- Strips Content-Security-Policy headers
- HTTP to HTTPS redirect
- Configurable domain and upstream URL

## Quick Start

1. Configure your domain in `.env`:

   ```
   DOMAIN=local.example.com
   UPSTREAM_URL=http://host.docker.internal:3000
   ```

   `UPSTREAM_URL` must include the scheme and port.

2. Add to `/etc/hosts`:

   ```
   127.0.0.1 local.example.com
   ```

3. Generate certificates (first time only):

   ```bash
   docker-compose --profile setup run --rm mkcert
   ```

4. Install the CA certificate (one-time):

   ```bash
   sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain ./certs/local.example.com.rootCA.pem
   ```

5. Start the proxy:

   ```bash
   docker-compose up -d
   ```

6. Visit: `https://local.example.com:8443`

Note (Linux): Requires Docker Engine 20.10+ for `host-gateway` support.

## Configuration

| Variable        | Default     | Description            |
| --------------- | ----------- | ---------------------- |
| `DOMAIN`        | `localhost` | Domain for SSL cert    |
| `UPSTREAM_URL`  | `http://host.docker.internal:3000` | URL for your local app |

## Ports

- `8080` - HTTP (redirects to HTTPS)
- `8443` - HTTPS

## Layout

```
├── config/Caddyfile              # Caddy configuration
├── scripts/mkcert/entrypoint.sh  # Cert generation script
├── docker-compose.yml            # Service definitions
├── Dockerfile.caddy              # Caddy image
├── Dockerfile.mkcert             # Certificate generator
└── .env                          # Your configuration
```
