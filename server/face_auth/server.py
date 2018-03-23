from flask import jsonify, request

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
        return jsonify({API.Response.KEY_INFO: API.Response.VAL_INVALID_REQUEST}), 400

    db = factory.database()

    if db.get_user(reg_request.email):
        return jsonify({API.Response.KEY_INFO: API.Response.VAL_ALREADY_REGISTERED})

    pwd_hash = Authenticator.hash_password(reg_request.password)
    user = db.insert_user(reg_request.email, pwd_hash, reg_request.name, reg_request.description)

    if not user:
        return jsonify({API.Response.KEY_INFO: API.Response.VAL_COULD_NOT_ADD_USER}), 500

    reg_request.save_file(user.face_model_path)

    return jsonify({API.Response.KEY_INFO: API.Response.VAL_SUCCESS})


@app.route(API.Path.LOGIN, methods=['POST'])
def login():
    login_request = LoginRequest(request)

    if not login_request.is_valid():
        return jsonify({API.Response.KEY_INFO: API.Response.VAL_INVALID_REQUEST}), 400

    auth: Authenticator = factory.authenticator(login_request.email)

    if not auth.verify_password(factory.database(), login_request.password):
        return jsonify({API.Response.KEY_INFO: API.Response.VAL_INVALID_USER_PASS}), 401

    user = auth.user
    login_request.save_file(user.face_path)

    if not auth.verify_face():
        return jsonify({API.Response.KEY_INFO: API.Response.VAL_UNRECOGNIZED_FACE}), 401

    return jsonify({
        API.Response.KEY_INFO: API.Response.VAL_SUCCESS,
        API.Response.KEY_USER_NAME: user.email,
        API.Response.KEY_NAME: user.name,
        API.Response.KEY_DESCRIPTION: user.description
    })
