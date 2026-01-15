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

echo ""
echo "=== Install CA certificate ==="
echo ""
echo "macOS:"
echo "  sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain ./certs/${DOMAIN}.rootCA.pem"
echo ""
echo "Linux (Debian/Ubuntu):"
echo "  sudo cp ./certs/${DOMAIN}.rootCA.pem /usr/local/share/ca-certificates/${DOMAIN}.crt && sudo update-ca-certificates"
echo ""
echo "Linux (Fedora/RHEL):"
echo "  sudo cp ./certs/${DOMAIN}.rootCA.pem /etc/pki/ca-trust/source/anchors/${DOMAIN}.pem && sudo update-ca-trust"
echo ""
echo "Linux (Arch):"
echo "  sudo trust anchor ./certs/${DOMAIN}.rootCA.pem"
echo ""
echo "Windows (PowerShell as Admin):"
echo "  Import-Certificate -FilePath .\\certs\\${DOMAIN}.rootCA.pem -CertStoreLocation Cert:\\LocalMachine\\Root"
echo "  If .pem import fails, convert to .cer first:"
echo "  openssl x509 -in .\\certs\\${DOMAIN}.rootCA.pem -out .\\certs\\${DOMAIN}.rootCA.cer"
echo "  Import-Certificate -FilePath .\\certs\\${DOMAIN}.rootCA.cer -CertStoreLocation Cert:\\LocalMachine\\Root"
