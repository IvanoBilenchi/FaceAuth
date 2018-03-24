import os
from contextlib import suppress
from flask import Request as FlaskRequest
from typing import Optional
from werkzeug.datastructures import FileStorage

from .config import API


class Request:
    """Base request class."""

    def __init__(self, request: FlaskRequest) -> None:
        self.user_name: Optional[str] = request.form.get(API.Request.KEY_USER_NAME)
        self.password: Optional[str] = request.form.get(API.Request.KEY_PASSWORD)
        self._file: Optional[FileStorage] = None

    def is_valid(self) -> bool:
        return True if self.user_name and self.password and self._file else False

    def save_file(self, file_path: str) -> None:
        with suppress(FileNotFoundError):
            os.unlink(file_path)
        os.makedirs(os.path.dirname(file_path), exist_ok=True)
        self._file.save(file_path)


class LoginRequest(Request):
    """Login request."""

    def __init__(self, request: FlaskRequest) -> None:
        super(LoginRequest, self).__init__(request)

        face_config = API.Request.Face
        face_file = request.files.get(face_config.KEY)
        if face_file and face_file.filename == face_config.FILE_NAME and face_file.mimetype == face_config.MIME:
            self._file = face_file


class RegistrationRequest(Request):
    """Registration request."""

    def __init__(self, request: FlaskRequest) -> None:
        super(RegistrationRequest, self).__init__(request)

        model_config = API.Request.Model
        model_file = request.files.get(model_config.KEY)

        if model_file and model_file.filename == model_config.FILE_NAME and model_file.mimetype == model_config.MIME:
            self._file = model_file


class UpdateRequest(LoginRequest):
    """Update request."""

    def __init__(self, request: FlaskRequest) -> None:
        super(UpdateRequest, self).__init__(request)
        self.name: Optional[str] = request.form.get(API.Request.KEY_NAME)
        self.description: Optional[str] = request.form.get(API.Request.KEY_DESCRIPTION)
