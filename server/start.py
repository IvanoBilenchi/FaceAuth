from face_auth import server
from face_auth.config import API, DEBUG

if __name__ == '__main__':
    server.app.run(host=API.Server.HOST,
                   port=API.Server.PORT,
                   debug=DEBUG,
                   ssl_context=API.Server.HTTPS_CONFIG if API.Server.HTTPS_ENABLED else None)
