from flask import request

from . import factory
from .authenticator import Authenticator
from .config import API
from .request import LoginRequest, RegistrationRequest

# App instance
app = factory.shared_app()


@app.route('/')
def hello():
    return 'Hello, world!\n'


@app.route(API.Path.REGISTRATION, methods=['POST'])
def register():
    reg_request = RegistrationRequest(request)

    if not reg_request.is_valid():
        return 'Invalid request.\n', 400

    db = factory.database()

    if db.get_user(reg_request.email):
        return 'User already registered.\n', 400

    pwd_hash = Authenticator.hash_password(reg_request.password)
    user = db.insert_user(reg_request.email, pwd_hash, reg_request.name, reg_request.description)

    if not user:
        return 'Could not add user "{}".\n'.format(reg_request.email), 500

    reg_request.save_file(user.face_model_path)

    return 'Registered user "{}" with id: {}.\n'.format(user.name, user.uid)


@app.route(API.Path.LOGIN, methods=['POST'])
def login():
    login_request = LoginRequest(request)

    if not login_request.is_valid():
        return 'Invalid request.\n', 400

    auth: Authenticator = factory.authenticator(login_request.email)

    if not auth.verify_password(factory.database(), login_request.password):
        return 'Invalid username/password combination.\n', 401

    login_request.save_file(auth.user.face_path)

    if not auth.verify_face():
        return 'Unrecognized face.\n', 401

    return 'Welcome, {}.\n'.format(auth.user.name)
