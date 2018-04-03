from flask import jsonify, request
from functools import wraps
from shutil import rmtree
from typing import Any, Callable, Tuple, Union

from . import factory
from .authenticator import Authenticator
from .config import API
from .request import LoginRequest, RegistrationRequest, UpdateRequest
from .user import User

# App instance

app = factory.shared_app()


# Common responses

def success() -> Tuple[Any, int]:
    """Success API response."""
    return jsonify({API.Response.KEY_INFO: API.Response.VAL_SUCCESS}), 200


def invalid_request() -> Tuple[Any, int]:
    """Invalid request API response."""
    return jsonify({API.Response.KEY_INFO: API.Response.VAL_INVALID_REQUEST}), 400


def internal_error() -> Tuple[Any, int]:
    """Internal error API response."""
    return jsonify({API.Response.KEY_INFO: API.Response.VAL_INTERNAL_ERROR}), 500


# Login

def require_login(f: Callable[[User], Tuple[Any, int]]):
    @wraps(f)
    def authenticate() -> Union[User, Tuple[Any, int]]:
        """Authenticates a login request."""
        login_request = LoginRequest(request)

        if not login_request.is_valid():
            return invalid_request()

        auth: Authenticator = factory.authenticator(login_request.user_name)

        if not auth.verify_password(factory.database(), login_request.password):
            return jsonify({API.Response.KEY_INFO: API.Response.VAL_INVALID_USER_PASS}), 401

        user = auth.user
        login_request.save_file(user.face_path)

        if not auth.verify_face(login_request.password):
            return jsonify({API.Response.KEY_INFO: API.Response.VAL_UNRECOGNIZED_FACE}), 401

        return f(user)

    return authenticate


# Routes

@app.route(API.Path.REGISTRATION, methods=['POST'])
def register():
    reg_request = RegistrationRequest(request)

    if not reg_request.is_valid():
        return invalid_request()

    db = factory.database()

    if db.get_user(reg_request.user_name):
        return jsonify({API.Response.KEY_INFO: API.Response.VAL_ALREADY_REGISTERED})

    pwd_hash = Authenticator.hash_password(reg_request.password)
    user = db.insert_user(reg_request.user_name, pwd_hash)

    if not user:
        return internal_error()

    reg_request.save_file(user.face_model_path)
    Authenticator.encrypt_file(user.face_model_path, user.encrypted_model_path, reg_request.password)

    return success()


@app.route(API.Path.LOGIN, methods=['POST'])
@require_login
def login(user: User):
    return jsonify({
        API.Response.KEY_INFO: API.Response.VAL_SUCCESS,
        API.Response.KEY_USER_NAME: user.user_name,
        API.Response.KEY_NAME: user.name,
        API.Response.KEY_DESCRIPTION: user.description
    })


@app.route(API.Path.UPDATE, methods=['POST'])
@require_login
def update(user: User):
    update_request = UpdateRequest(request)
    user.name = update_request.name
    user.description = update_request.description

    if not factory.database().update_user(user):
        return internal_error()

    return success()


@app.route(API.Path.DELETE, methods=['POST'])
@require_login
def delete(user: User):
    if not factory.database().delete_user(user):
        return internal_error()

    rmtree(user.user_dir, ignore_errors=True)

    return success()
