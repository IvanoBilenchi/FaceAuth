from face_auth import server
from face_auth.config import API, DEBUG, Path
from ssl import SSLContext
from _ssl import PROTOCOL_TLS

if __name__ == '__main__':
    if API.Server.HTTPS_ENABLED:
        tls_context = SSLContext(PROTOCOL_TLS)
        tls_context.load_cert_chain(Path.HTTPS_CERT_FILE, Path.HTTPS_KEY_FILE)
    else:
        tls_context = None

    server.app.run(host=API.Server.HOST,
                   port=API.Server.PORT,
                   debug=DEBUG,
                   ssl_context=tls_context)
