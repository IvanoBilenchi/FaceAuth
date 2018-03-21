from enum import Enum, auto
from passlib.hash import bcrypt_sha256

from . import config
from .database import Database
from .face_recognizer import FaceRecognizer
from .user import User


class Authenticator:
    """Authenticates users."""

    class State(Enum):
        """Authentication state."""
        NOT_AUTHENTICATED = auto()
        WAITING_FOR_FACE = auto()
        AUTHENTICATED = auto()

    # Public properties

    @property
    def state(self) -> State:
        """The current authentication state."""
        return self.__state

    @property
    def user(self) -> User:
        """The user this authenticator refers to."""
        return self.__user

    # Private fields

    __state = State.NOT_AUTHENTICATED
    __email: str
    __user: User = None

    # Lifecycle

    def __init__(self, email: str) -> None:
        """Initializes a new authenticator."""
        self.__email = email

    # Public methods

    @classmethod
    def hash_password(cls, password: str) -> str:
        """Returns a hashed and salted password."""
        return bcrypt_sha256.hash(password)

    def verify_password(self, database: Database, password: str) -> bool:
        """Verifies that the given password matches that of the registered user."""
        user = database.get_user(self.__email)

        if not (user and bcrypt_sha256.verify(password, database.get_password(user))):
            self.__state = Authenticator.State.NOT_AUTHENTICATED
            self.__user = None
            return False

        self.__state = Authenticator.State.WAITING_FOR_FACE
        self.__user = user
        return True

    def verify_face(self) -> bool:
        """Verifies that the user's photo is recognized by the biometric model."""
        recognizer = FaceRecognizer(self.__user.face_model_path, config.FACE_RECOGNITION_THRESHOLD)
        if self.__state != Authenticator.State.WAITING_FOR_FACE or not recognizer.predict(self.__user.face_path):
            return False

        self.__state = Authenticator.State.AUTHENTICATED
        return True
