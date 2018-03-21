from os import path
from typing import Optional

from . import config


class User:
    """Models users."""

    # Public fields

    uid: int
    email: str
    name: str
    description: str

    @property
    def user_dir(self) -> str:
        """The user directory."""
        return path.join(config.USERS_DIR, str(self.uid))

    @property
    def face_model_path(self) -> str:
        """Path to the face model."""
        return path.join(self.user_dir, 'model.yml')

    @property
    def face_path(self) -> str:
        """Path to the last photo."""
        return path.join(self.user_dir, 'last_face.png')

    # Lifecycle

    def __init__(self, uid: int, email: str, name: str, description: Optional[str] = None) -> None:
        """Initializes a new user."""
        self.uid = uid
        self.email = email
        self.name = name
        self.description = description
