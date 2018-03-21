import os
from contextlib import suppress
from flask import Request as FlaskRequest
from typing import Optional
from werkzeug.datastructures import FileStorage


class Request:
    """Base request class."""

    # Public fields

    email: Optional[str]
    password: Optional[str]

    # Private fields

    _file: Optional[FileStorage]

    # Public methods

    def is_valid(self) -> bool:
        return True if self.email and self.password and self._file else False

    def save_file(self, file_path: str) -> None:
        with suppress(FileNotFoundError):
            os.unlink(file_path)
        os.makedirs(os.path.dirname(file_path), exist_ok=True)
        self._file.save(file_path)


class LoginRequest(Request):
    """Login request."""

    # Lifecycle

    def __init__(self, request: FlaskRequest) -> None:
        self.email = request.form.get('user')
        self.password = request.form.get('pass')

        face_file = request.files.get('face')

        if face_file and face_file.filename.endswith('.png'):
            self._file = face_file


class RegistrationRequest(Request):
    """Registration request."""

    # Public fields

    name: Optional[str]
    description: Optional[str]

    def __init__(self, request: FlaskRequest) -> None:
        self.email = request.form.get('user')
        self.password = request.form.get('pass')
        self.name = request.form.get('name')
        self.description = request.form.get('desc')

        model_file = request.files.get('model')

        if model_file and model_file.filename.endswith('.yml'):
            self._file = model_file

    def is_valid(self):
        return super(RegistrationRequest, self).is_valid() and self.name
