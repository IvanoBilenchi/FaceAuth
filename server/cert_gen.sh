#!/usr/bin/env bash
cd "$(dirname "${0}")"

# Configuration: replace these with the desired info
COMMON_NAME='MacBook-Pro-di-Ivano.local'
ORGANIZATION='IvanoBilenchi'
COUNTRY='IT'

# Eventually generate certs
CERT_DIR=res/certs
CERT_PEM="${CERT_DIR}/cert.pem"
CERT_DER="${CERT_DIR}/cert.der"
KEY_PEM="${CERT_DIR}/key.pem"

if ! { [ -f "${CERT_PEM}" ] && [ -f "${KEY_PEM}" ]; }; then
	rm -f "${CERT_PEM}" "${CERT_DER}" "${KEY_PEM}"
	SUBJ="/CN=${COMMON_NAME}/O=${ORGANIZATION}/C=${COUNTRY}"
	openssl req -x509 -newkey rsa:4096 -nodes -out "${CERT_PEM}" -keyout "${KEY_PEM}" -days 365 -subj "${SUBJ}"
fi

if [ ! -f "{CERT_DER}" ]; then
	openssl x509 -outform der -in "${CERT_PEM}" -out "${CERT_DER}"
fi
