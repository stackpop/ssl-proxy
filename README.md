# SSL Proxy

A Dockerized Caddy reverse proxy with automatic SSL certificate generation for local development.

## Features

- Automatic SSL certificate generation via mkcert
- Strips Content-Security-Policy headers
- HTTP to HTTPS redirect
- Configurable domain and upstream URL

## Quick Start

1. Create an env file for your domain (e.g., `.env.local.example.com`):

   ```
   DOMAIN=local.example.com
   UPSTREAM_URL=http://host.docker.internal:3000
   HTTP_PORT=8080
   HTTPS_PORT=8443
   ```

   > [!WARNING]
   > `UPSTREAM_URL` must include the scheme and port.

2. Add your domain to hosts file:

   ```bash
   # macOS/Linux
   sudo sh -c 'echo "127.0.0.1 local.example.com" >> /etc/hosts'

   # Windows (PowerShell as Admin)
   Add-Content -Path C:\Windows\System32\drivers\etc\hosts -Value "127.0.0.1 local.example.com"
   ```

3. Generate certificates:

   ```bash
   docker compose --env-file .env.local.example.com --profile setup run --rm mkcert
   ```

4. Install CA certificate (one-time per domain):

   ```bash
   # macOS
   sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain ./certs/local.example.com.rootCA.pem

   # Linux (Debian/Ubuntu)
   sudo cp ./certs/local.example.com.rootCA.pem /usr/local/share/ca-certificates/local.example.com.crt && sudo update-ca-certificates

   # Linux (Fedora/RHEL)
   sudo cp ./certs/local.example.com.rootCA.pem /etc/pki/ca-trust/source/anchors/local.example.com.pem && sudo update-ca-trust

   # Linux (Arch)
   sudo trust anchor ./certs/local.example.com.rootCA.pem

   # Windows (PowerShell as Admin)
   Import-Certificate -FilePath .\certs\local.example.com.rootCA.pem -CertStoreLocation Cert:\LocalMachine\Root
   ```

5. Start the proxy:

   ```bash
   docker compose --env-file .env.local.example.com up -d
   ```

6. Visit: `https://local.example.com:8443`

> [!NOTE]
> Linux requires Docker Engine 20.10+ for `host-gateway` support.

## Running Multiple Domains

Run multiple instances by creating separate env files with different ports:

```bash
docker compose --env-file .env.local.example.com up -d
docker compose --env-file .env.local.another.com up -d
```

Each instance runs in its own project namespace based on the domain name.

## Configuration

| Variable       | Default                            | Description            |
| -------------- | ---------------------------------- | ---------------------- |
| `DOMAIN`       | `localhost`                        | Domain for SSL cert    |
| `HTTP_PORT`    | `8080`                             | HTTP port (redirects)  |
| `HTTPS_PORT`   | `8443`                             | HTTPS port (proxy)     |
| `UPSTREAM_URL` | `http://host.docker.internal:3000` | URL for your local app |

## Layout

```
├── config/Caddyfile              # Caddy configuration
├── scripts/mkcert/entrypoint.sh  # Cert generation script
├── docker-compose.yml            # Service definitions
├── Dockerfile.caddy              # Caddy image
├── Dockerfile.mkcert             # Certificate generator
└── .env                          # Your configuration
```
