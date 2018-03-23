from os import path


class Path:
    """Paths config namespace."""
    ROOT_DIR = path.dirname(path.dirname(path.realpath(__file__)))
    RES_DIR = path.join(ROOT_DIR, 'res')
    USERS_DIR = path.join(RES_DIR, 'users')
    UPLOAD_DIR = path.join(RES_DIR, 'upload')
    DB_FILE = path.join(USERS_DIR, 'users.db')
    DB_SCHEMA_FILE = path.join(USERS_DIR, 'schema.sql')


class API:
    """API config namespace."""

    class Path:
        LOGIN = '/login'
        REGISTRATION = '/register'

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

        VAL_ALREADY_REGISTERED = 'already_registered'
        VAL_COULD_NOT_ADD_USER = 'could_not_add_user'

        VAL_INVALID_USER_PASS = 'invalid_user_pass'
        VAL_UNRECOGNIZED_FACE = 'unrecognized_face'


# Flask
DEBUG = True
SECRET_KEY = b'\x08\x12\xddR\x1e\xaf\x91\x7f\xd2\xa3\r\x16\x8ex\\\xe9\xaeMQ\x02\xc4W\xd4\xeb'

SESSION_TYPE = 'filesystem'
SESSION_PERMANENT = False
SESSION_FILE_DIR = path.join(Path.RES_DIR, 'session')

# Authentication
FACE_RECOGNITION_THRESHOLD = 15.0