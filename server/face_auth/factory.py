from flask import Flask, g
from flask_session import Session

from . import config
from .authenticator import Authenticator
from .database import Database
from .decorators import memoized


@memoized
def shared_app() -> Flask:

    flask_app = Flask('face_auth')
    flask_app.config.from_object('face_auth.config')
    Session(flask_app)

    @flask_app.teardown_appcontext
    def teardown(exception: Exception):
        del exception  # unused
        db: Database = getattr(g, '_database', None)
        if db:
            db.disconnect()

    return flask_app


def database() -> Database:
    db: Database = getattr(g, '_database', None)
    if not db:
        db = g._database = Database(config.Path.DB_FILE, config.Path.DB_SCHEMA_FILE)
        db.connect()
    return db


def authenticator(email: str) -> Authenticator:
    return Authenticator(email)
