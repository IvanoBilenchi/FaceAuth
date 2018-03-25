from face_auth import server
from face_auth.config import Path

if __name__ == '__main__':
    server.app.run(host='0.0.0.0',
                   port=5000,
                   debug=False,
                   ssl_context=(Path.HTTPS_CERT_FILE, Path.HTTPS_KEY_FILE))
