#!/bin/sh
set -e

DOMAIN="${DOMAIN:-localhost}"
CERT_FILE="/certs/${DOMAIN}.pem"
KEY_FILE="/certs/${DOMAIN}.key.pem"
CA_FILE="/certs/${DOMAIN}.rootCA.pem"

if [ ! -f "$CERT_FILE" ]; then
    echo "Generating SSL certificate for ${DOMAIN}..."
    mkcert -install
    mkcert -cert-file "$CERT_FILE" \
           -key-file "$KEY_FILE" \
           "$DOMAIN"
    cp "$(mkcert -CAROOT)/rootCA.pem" "$CA_FILE"
    echo "=== Certificate generated ==="
else
    echo "Certificate already exists for ${DOMAIN}, skipping generation."
fi

echo "Install CA on macOS:"
echo "  sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain ./certs/${DOMAIN}.rootCA.pem"
