#!/bin/bash
cd "$(dirname "${0}")"

# Configuration
SRC_DIR='./face_auth'
USERS_DIR='./res/users'
DB_FILE="${USERS_DIR}/users.db"
SCHEMA_FILE="${USERS_DIR}/schema.sql"

# Create database if missing
if [ ! -f "${DB_FILE}" ]; then
	sqlite3 "${DB_FILE}" < "${SCHEMA_FILE}"
fi

# Launch server
source venv/bin/activate
export FLASK_APP="${SRC_DIR}/server.py"
python3 -m flask run
