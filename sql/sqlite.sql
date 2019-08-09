CREATE TABLE IF NOT EXISTS user (
    id          INTEGER NOT NULL PRIMARY KEY,
    user_id     INTEGER NOT NULL,      -- twitter
    screen_name VARCHAR(255) NOT NULL, -- twitter
    score       UNSIGNED INT NOT NULL DEFAULT 0,
    solves      UNSIGNED INT NOT NULL DEFAULT 0,
    struct      BLOB
);

CREATE TABLE IF NOT EXISTS event (
    id              INTEGER NOT NULL PRIMARY KEY,
    event_source_id INTEGER NOT NULL,
    name            VARCHAR(255) NOT NULL,
    year            UNSIGNED INT, -- 開催年度または常設
    struct          BLOB,
    UNIQUE (name)
);

CREATE TABLE IF NOT EXISTS event_source (
    id     INTEGER NOT NULL PRIMARY KEY,
    name   VARCHAR(255) NOT NULL,
    ctf_id INTEGER, -- ctftime
    struct BLOB,
    UNIQUE (name)
);

CREATE TABLE IF NOT EXISTS difficulty (
    id    INTEGER NOT NULL PRIMARY KEY,
    name  VARCHAR(255) NOT NULL,
    point UNSIGNED INT NOT NULL,
    UNIQUE (name)
);

CREATE TABLE IF NOT EXISTS genre (
    id          INTEGER NOT NULL PRIMARY KEY,
    name        VARCHAR(255) NOT NULL,
    UNIQUE (name)
);

CREATE TABLE IF NOT EXISTS chall (
    id            INTEGER NOT NULL PRIMARY KEY,
    genre_id      INTEGER NOT NULL,
    difficulty_id INTEGER NOT NULL,
    event_id      INTEGER NOT NULL,
    name          VARCHAR(255) NOT NULL,
    solves        UNSIGNED INT NOT NULL DEFAULT 0,
    struct        BLOB
);

CREATE TABLE IF NOT EXISTS tag (
    id   INTEGER NOT NULL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    UNIQUE (name)
);

CREATE TABLE IF NOT EXISTS chall_tag (
    id       INTEGER NOT NULL PRIMARY KEY,
    chall_id INTEGER NOT NULL,
    tag_id   INTEGER NOT NULL
);

CREATE TABLE IF NOT EXISTS solution (
    id         INTEGER NOT NULL PRIMARY KEY,
    user_id    INTEGER NOT NULL,
    chall_id   INTEGER NOT NULL,
    updated_at TIMESTAMP NOT NULL
);

CREATE TABLE IF NOT EXISTS writeup (
    id         INTEGER NOT NULL PRIMARY KEY,
    chall_id   INTEGER NOT NULL,
    user_id    INTEGER NOT NULL,
    body       TEXT,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL
);
