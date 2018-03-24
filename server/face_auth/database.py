import sqlite3 as sql
from os import path
from typing import Optional

from .user import User


class Database:
    """Models a database session."""

    # Lifecycle

    def __init__(self, db_path: str, schema_path: str) -> None:
        self.__db_path: str = db_path
        self.__schema_path: str = schema_path
        self.__connection: sql.Connection = None

    # Public methods

    def connect(self) -> None:
        """Connects to the database."""
        if not self.__connection:
            should_init = not path.exists(self.__db_path)

            self.__connection = sql.connect(self.__db_path)
            self.__connection.row_factory = sql.Row

            if should_init:
                self.__initialize()

    def disconnect(self) -> None:
        """Disconnects from the database."""
        if self.__connection:
            self.__connection.close()
            self.__connection = None

    def insert_user(self, user_name: str, pwd_hash: str) -> Optional[User]:
        """Inserts a new user with the specified details."""
        try:
            cur = self.__cursor()
            cur.execute('INSERT INTO users (user_name, password) VALUES (?,?)',
                        [user_name, pwd_hash])
            self.__commit()
        except sql.Error:
            return None

        return User(uid=cur.lastrowid, user_name=user_name)

    def update_user(self, user: User) -> bool:
        """Updates details for the specified user."""
        try:
            cur = self.__cursor()
            cur.execute('UPDATE users SET user_name=?, name=?, description=? WHERE uid=?',
                        [user.user_name, user.name, user.description, user.uid])
            self.__commit()
        except sql.Error:
            return False

        return True

    def delete_user(self, user: User) -> bool:
        """Deletes an existing user."""
        try:
            self.__cursor().execute('DELETE FROM users WHERE uid=?', [user.uid])
            self.__commit()
        except sql.Error:
            return False

        return True

    def get_user(self, user_name: str) -> Optional[User]:
        """Retrieves info about an existing user."""
        try:
            cur = self.__cursor()
            cur.execute('SELECT uid, name, description FROM users WHERE user_name=?', [user_name])
            usr = cur.fetchone()
        except sql.Error:
            return None

        return User(uid=usr[0], user_name=user_name, name=usr[1], description=usr[2]) if usr else None

    def get_password(self, user: User) -> Optional[str]:
        """Retrieves the hashed password of an existing user."""
        try:
            cur = self.__cursor()
            cur.execute('SELECT password FROM users WHERE uid=?', [user.uid])
            usr = cur.fetchone()
        except sql.Error:
            return None

        return usr[0] if usr else None

    # Private methods

    def __initialize(self) -> None:
        """Initializes the database."""
        with open(self.__schema_path) as schema:
            self.__cursor().executescript(schema.read())
        self.__commit()

    def __cursor(self) -> sql.Cursor:
        """Returns a new cursor."""
        return self.__connection.cursor()

    def __commit(self) -> None:
        """Commits changes."""
        self.__connection.commit()
