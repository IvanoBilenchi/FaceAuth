BEGIN;
DROP TABLE IF EXISTS users;

CREATE TABLE users (
  uid INTEGER PRIMARY KEY AUTOINCREMENT,
  user_name VARCHAR(40) NOT NULL UNIQUE,
  password CHAR(60) NOT NULL,
  name TEXT,
  description TEXT
);

CREATE UNIQUE INDEX users_user_name_idx ON users (user_name);
COMMIT;
