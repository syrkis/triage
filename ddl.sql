-- drop table answers
PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS applications (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS windows (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  application_id INTEGER NOT NULL,
  UNIQUE(title, application_id),
  FOREIGN KEY (application_id) REFERENCES applications(id)
);

CREATE TABLE IF NOT EXISTS logs (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
  window_id INTEGER NOT NULL,
  consecutive INTEGER NOT NULL DEFAULT 1,
  FOREIGN KEY (window_id) REFERENCES windows(id)
);

CREATE TABLE IF NOT EXISTS questions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  question TEXT NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS answers (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
  answer TEXT NOT NULL,
  question_id INTEGER NOT NULL,
  FOREIGN KEY (question_id) REFERENCES questions(id)
);

-- Removed the surveys table due to the foreign key issue with logs(timestamp)
-- and because it's not directly related to the logging functionality we are focusing on.

CREATE INDEX IF NOT EXISTS idx_logs_app_window ON logs (window_id);
CREATE INDEX IF NOT EXISTS idx_logs_timestamp ON logs (timestamp);
