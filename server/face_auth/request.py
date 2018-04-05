import os
from contextlib import suppress
from flask import Request as FlaskRequest
from typing import Optional
from werkzeug.datastructures import FileStorage

from .config import API, Validation
from .face_recognizer import FaceRecognizer


class Request:
    """Base request class."""

    def __init__(self, request: FlaskRequest) -> None:
        self.user_name: Optional[str] = request.form.get(API.Request.KEY_USER_NAME)
        self.password: Optional[str] = request.form.get(API.Request.KEY_PASSWORD)
        self._file: Optional[FileStorage] = None

    def is_valid(self) -> bool:
        """Perform very basic field validation."""
        if not (self.user_name and len(self.user_name) in Validation.USER_LENGTH_RANGE):
            return False

        if not (self.password and len(self.password) in Validation.PASS_LENGTH_RANGE):
            return False

        return True

    def file_size(self) -> int:
        """Gets the size of the uploaded file."""
        if not self._file:
            return 0

        self._file.stream.seek(0, os.SEEK_END)
        size = self._file.stream.tell()
        self._file.stream.seek(0)
        return size

    def save_file(self, file_path: str) -> bool:
        """Saves the uploaded file.

        :return: True on success, False on error.
        """
        with suppress(FileNotFoundError):
            os.unlink(file_path)
        os.makedirs(os.path.dirname(file_path), exist_ok=True)
        self._file.save(file_path)
        return True


class LoginRequest(Request):
    """Login request."""

    def __init__(self, request: FlaskRequest) -> None:
        super(LoginRequest, self).__init__(request)

        face_config = API.Request.Face
        face_file = request.files.get(face_config.KEY)
        if face_file and face_file.filename == face_config.FILE_NAME and face_file.mimetype == face_config.MIME:
            self._file = face_file

    def is_valid(self) -> bool:
        if not super(LoginRequest, self).is_valid():
            return False
        return self.file_size() in Validation.PHOTO_SIZE_RANGE


class RegistrationRequest(Request):
    """Registration request."""

    def __init__(self, request: FlaskRequest) -> None:
        super(RegistrationRequest, self).__init__(request)

        model_config = API.Request.Model
        model_file = request.files.get(model_config.KEY)

        if model_file and model_file.filename == model_config.FILE_NAME and model_file.mimetype == model_config.MIME:
            self._file = model_file

    def is_valid(self) -> bool:
        if not super(RegistrationRequest, self).is_valid():
            return False
        return self.file_size() in Validation.MODEL_SIZE_RANGE

    def save_file(self, file_path: str) -> bool:
        if not super(RegistrationRequest, self).save_file(file_path):
            return False

        if FaceRecognizer(file_path).number_of_samples < Validation.MODEL_MIN_SAMPLES:
            os.unlink(file_path)
            return False

        return True


class UpdateRequest(LoginRequest):
    """Update request."""

    def __init__(self, request: FlaskRequest) -> None:
        super(UpdateRequest, self).__init__(request)
        self.name: Optional[str] = request.form.get(API.Request.KEY_NAME)
        self.description: Optional[str] = request.form.get(API.Request.KEY_DESCRIPTION)

    def is_valid(self) -> bool:
        if not super(UpdateRequest, self).is_valid():
            return False

        if self.name and len(self.name) not in Validation.NAME_LENGTH_RANGE:
            return False

        if self.description and len(self.description) not in Validation.DESC_LENGTH_RANGE:
            return False

        return True
