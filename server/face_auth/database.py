import sqlite3 as sql
from typing import Optional

from .user import User


class Database:
    """Models a database session."""

    # Private fields

    __path: str
    __connection: sql.Connection = None

    # Lifecycle

    def __init__(self, path: str) -> None:
        self.__path = path

    # Public methods

    def connect(self) -> None:
        """Connects to the database."""
        if not self.__connection:
            self.__connection = sql.connect(self.__path)
            self.__connection.row_factory = sql.Row

    def disconnect(self) -> None:
        """Disconnects from the database."""
        if self.__connection:
            self.__connection.close()
            self.__connection = None

    def insert_user(self, email: str, pwd_hash: str, name: str, description: Optional[str] = None) -> Optional[User]:
        """Inserts a new user with the specified details."""
        try:
            cur = self.__connection.cursor()
            cur.execute('INSERT INTO users (email, password, name, description) VALUES (?,?,?,?)',
                        [email, pwd_hash, name, description])
            self.__connection.commit()
        except sql.Error:
            return None

        return User(uid=cur.lastrowid, email=email, name=name, description=description)

    def delete_user(self, user: User) -> bool:
        """Deletes an existing user."""
        try:
            cur = self.__connection.cursor()
            cur.execute('DELETE FROM users WHERE uid=?', [user.uid])
            self.__connection.commit()
        except sql.Error:
            return False

        return True

    def get_user(self, email: str) -> Optional[User]:
        """Retrieves info about an existing user."""
        try:
            cur = self.__connection.cursor()
            cur.execute('SELECT uid, name, description FROM users WHERE email=?', [email])
            usr = cur.fetchone()
        except sql.Error:
            return None

        return User(uid=usr[0], email=email, name=usr[1], description=usr[2]) if usr else None

    def get_password(self, user: User) -> Optional[str]:
        """Retrieves the hashed password of an existing user."""
        try:
            cur = self.__connection.cursor()
            cur.execute('SELECT password FROM users WHERE uid=?', [user.uid])
            usr = cur.fetchone()
        except sql.Error:
            return None

        return usr[0] if usr else None
