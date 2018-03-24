from os import path
from typing import Optional

from . import config


class User:
    """Models users."""

    @property
    def user_dir(self) -> str:
        """The user directory."""
        return path.join(config.Path.USERS_DIR, str(self.uid))

    @property
    def face_model_path(self) -> str:
        """Path to the face model."""
        return path.join(self.user_dir, 'model.yml')

    @property
    def face_path(self) -> str:
        """Path to the last photo."""
        return path.join(self.user_dir, 'last_face.png')

    def __init__(self, uid: int, user_name: str, name: Optional[str] = None, description: Optional[str] = None) -> None:
        """Initializes a new user."""
        self.uid: int = uid
        self.user_name: str = user_name
        self.name: str = name if name is not None else ""
        self.description: str = description if description is not None else ""
