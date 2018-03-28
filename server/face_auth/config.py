from os import path


class Path:
    """Paths config namespace."""
    ROOT_DIR = path.dirname(path.dirname(path.realpath(__file__)))
    RES_DIR = path.join(ROOT_DIR, 'res')
    USERS_DIR = path.join(RES_DIR, 'users')
    UPLOAD_DIR = path.join(RES_DIR, 'upload')
    HTTPS_DIR = path.join(RES_DIR, 'certs')

    DB_FILE = path.join(USERS_DIR, 'users.db')
    DB_SCHEMA_FILE = path.join(USERS_DIR, 'schema.sql')
    HTTPS_CERT_FILE = path.join(HTTPS_DIR, 'cert.pem')
    HTTPS_KEY_FILE = path.join(HTTPS_DIR, 'key.pem')


class Validation:
    """Validation config namespace."""
    USER_LENGTH_RANGE = range(8, 41)
    PASS_LENGTH_RANGE = range(8, 41)
    NAME_LENGTH_RANGE = range(0, 101)
    DESC_LENGTH_RANGE = range(0, 101)
    PHOTO_SIZE_RANGE = range(1, 1024 * 1024)
    MODEL_SIZE_RANGE = range(1, 10 * 1024 * 1024)


class API:
    """API config namespace."""

    class Server:
        HOST = '0.0.0.0'
        PORT = 5000
        HTTPS_ENABLED = True

    class Path:
        LOGIN = '/login'
        REGISTRATION = '/register'
        UPDATE = '/update'
        DELETE = '/delete'

    class Request:
        KEY_USER_NAME = 'user'
        KEY_PASSWORD = 'pass'
        KEY_NAME = 'name'
        KEY_DESCRIPTION = 'desc'

        class Face:
            KEY = 'face'
            MIME = 'image/png'
            FILE_NAME = 'face.png'

        class Model:
            KEY = 'model'
            MIME = 'application/x-yaml'
            FILE_NAME = 'model.yml'

    class Response:
        KEY_USER_NAME = 'user'
        KEY_NAME = 'name'
        KEY_DESCRIPTION = 'desc'
        KEY_INFO = 'info'

        VAL_SUCCESS = 'ok'
        VAL_INVALID_REQUEST = 'invalid_request'
        VAL_INTERNAL_ERROR = 'internal_error'

        VAL_ALREADY_REGISTERED = 'already_registered'

        VAL_INVALID_USER_PASS = 'invalid_user_pass'
        VAL_UNRECOGNIZED_FACE = 'unrecognized_face'


# Flask
DEBUG = False
SECRET_KEY = b'\x08\x12\xddR\x1e\xaf\x91\x7f\xd2\xa3\r\x16\x8ex\\\xe9\xaeMQ\x02\xc4W\xd4\xeb'
MAX_CONTENT_LENGTH = 20 * 1024 * 1024

# Authentication
FACE_RECOGNITION_THRESHOLD = 15.0
