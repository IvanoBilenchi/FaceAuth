from os import path

# Paths
ROOT_DIR = path.dirname(path.dirname(path.realpath(__file__)))
RES_DIR = path.join(ROOT_DIR, 'res')
USERS_DIR = path.join(RES_DIR, 'users')
UPLOAD_DIR = path.join(RES_DIR, 'upload')
DB_FILE_PATH = path.join(USERS_DIR, 'users.db')
DB_SCHEMA_PATH = path.join(USERS_DIR, 'schema.sql')

# Flask
DEBUG = True
SECRET_KEY = b'\x08\x12\xddR\x1e\xaf\x91\x7f\xd2\xa3\r\x16\x8ex\\\xe9\xaeMQ\x02\xc4W\xd4\xeb'

SESSION_TYPE = 'filesystem'
SESSION_PERMANENT = False
SESSION_FILE_DIR = path.join(RES_DIR, 'session')

# Authentication
FACE_RECOGNITION_THRESHOLD = 15.0
