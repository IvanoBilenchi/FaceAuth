from os import unlink
from passlib.hash import bcrypt_sha256
from pyAesCrypt import crypto
from typing import Optional

from . import config
from .database import Database
from .face_recognizer import FaceRecognizer
from .user import User


class Authenticator:
    """Authenticates users."""

    # Public properties

    @property
    def user(self) -> User:
        """The user this authenticator refers to."""
        return self.__user

    # Lifecycle

    def __init__(self, email: str) -> None:
        """Initializes a new authenticator."""
        self.__email: str = email
        self.__user: Optional[User] = None

    # Public methods

    @classmethod
    def hash_password(cls, password: str) -> str:
        """Returns a hashed and salted password."""
        return bcrypt_sha256.hash(password)

    @classmethod
    def encrypt_file(cls, path: str, out_path: str, password: str):
        """Encrypts a file (AES265)."""
        crypto.encryptFile(path, out_path, password, 64 * 1024)
        unlink(path)

    def verify_password(self, database: Database, password: str) -> bool:
        """Verifies that the given password matches that of the registered user."""
        user = database.get_user(self.__email)

        if not (user and bcrypt_sha256.verify(password, database.get_password(user))):
            self.__user = None
            return False

        self.__user = user
        return True

    def verify_face(self, password: str) -> bool:
        """Verifies that the user's photo is recognized by the biometric model."""
        crypto.decryptFile(self.__user.encrypted_model_path, self.__user.face_model_path, password, 64 * 1024)

        try:
            recognizer = FaceRecognizer(self.__user.face_model_path, config.FACE_RECOGNITION_THRESHOLD)
            return recognizer.predict(self.__user.face_path)
        finally:
            unlink(self.__user.face_model_path)
            unlink(self.__user.face_path)
