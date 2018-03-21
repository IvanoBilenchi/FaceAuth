#!/bin/bash
cd "$(dirname "${0}")"

# Configuration
SRC_DIR='./face_auth'

# Launch server
source venv/bin/activate
export FLASK_APP="${SRC_DIR}/server.py"
python3 -m flask run
