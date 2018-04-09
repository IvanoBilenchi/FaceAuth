#!/usr/bin/env bash
cd "$(dirname "${0}")"

# Generate certs if missing
./cert_gen.sh

# Launch server
source venv/bin/activate
python3 start.py
