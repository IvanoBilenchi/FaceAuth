#!/usr/bin/env bash
cd "$(dirname "${0}")"

# Ensure certs are available
CERT_DIR=res/certs
CERT_PEM="${CERT_DIR}/cert.pem"
CERT_DER="${CERT_DIR}/cert.der"
KEY_PEM="${CERT_DIR}/key.pem"

if ! { [ -f "${CERT_PEM}" ] && [ -f "${KEY_PEM}" ]; }; then
	rm -f "${CERT_PEM}" "${CERT_DER}" "${KEY_PEM}"
	openssl req -x509 -newkey rsa:4096 -nodes -out "${CERT_PEM}" -keyout "${KEY_PEM}" -days 365 -subj '/CN=MacBook-Pro-di-Ivano.local/O=IvanoBilenchi/C=IT'
fi

if [ ! -f "{CERT_DER}" ]; then
	openssl x509 -outform der -in "${CERT_PEM}" -out "${CERT_DER}"
fi

# Launch server
source venv/bin/activate
python3 start.py
