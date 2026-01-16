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

> [!WARNING]  
> `UPSTREAM_URL` must include the scheme and port.

2. Add your domain to the hosts file:

   **macOS/Linux:**
   Edit `/etc/hosts`

   ```bash
   sudo sh -c 'echo "127.0.0.1 local.example.com" >> /etc/hosts'
   ```

   **Windows (PowerShell as Administrator):**
   Edit `C:\Windows\System32\drivers\etc\hosts`

   ```powershell
   Add-Content -Path C:\Windows\System32\drivers\etc\hosts -Value "127.0.0.1 local.example.com"
   ```

3. Generate certificates (first time only):

   ```bash
   docker compose --profile setup run --rm mkcert
   ```

4. Install the CA certificate (one-time):

   Replace `local.example.com` with your configured domain.

   **macOS:**

   ```bash
   sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain ./certs/local.example.com.rootCA.pem
   ```

   **Linux (Debian/Ubuntu):**

   ```bash
   sudo cp ./certs/local.example.com.rootCA.pem /usr/local/share/ca-certificates/local.example.com.crt
   sudo update-ca-certificates
   ```

   **Linux (Fedora/RHEL):**

   ```bash
   sudo cp ./certs/local.example.com.rootCA.pem /etc/pki/ca-trust/source/anchors/local.example.com.pem
   sudo update-ca-trust
   ```

   **Linux (Arch):**

   ```bash
   sudo trust anchor ./certs/local.example.com.rootCA.pem
   ```

   **Windows (PowerShell as Administrator):**

   ```powershell
   Import-Certificate -FilePath .\certs\local.example.com.rootCA.pem -CertStoreLocation Cert:\LocalMachine\Root
   ```

   If `.pem` import fails, convert to `.cer` first:

   ```powershell
   openssl x509 -in .\certs\local.example.com.rootCA.pem -out .\certs\local.example.com.rootCA.cer
   Import-Certificate -FilePath .\certs\local.example.com.rootCA.cer -CertStoreLocation Cert:\LocalMachine\Root
   ```

5. Start the proxy:

   ```bash
   docker compose up -d
   ```

6. Visit: `https://local.example.com:8443`

Note (Linux): Requires Docker Engine 20.10+ for `host-gateway` support.

## Configuration

| Variable       | Default                            | Description            |
| -------------- | ---------------------------------- | ---------------------- |
| `DOMAIN`       | `localhost`                        | Domain for SSL cert    |
| `UPSTREAM_URL` | `http://host.docker.internal:3000` | URL for your local app |

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
