CREATE TABLE IF NOT EXISTS c4u_user (
    id          BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    user_id     BIGINT NOT NULL,       -- twitter
    screen_name VARCHAR(255) NOT NULL, -- twitter
    score       INT UNSIGNED NOT NULL DEFAULT 0,
    solves      INT UNSIGNED NOT NULL DEFAULT 0,
    struct      BLOB,
    UNIQUE (user_id, screen_name),
    INDEX(user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS c4u_chall (
    id            BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    genre_id      BIGINT NOT NULL,
    difficulty_id BIGINT NOT NULL,
    event_id      BIGINT NOT NULL,
    name          VARCHAR(255) NOT NULL,
    solves        INT UNSIGNED NOT NULL DEFAULT 0,
    struct        BLOB
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS c4u_solution (
    id         BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    user_id    BIGINT NOT NULL,
    chall_id   BIGINT NOT NULL,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX(chall_id, user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS c4u_writeup (
    id         BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    chall_id   BIGINT NOT NULL,
    user_id    BIGINT NOT NULL,
    body       TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS c4u_event (
    id              BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    event_source_id BIGINT NOT NULL,
    name            VARCHAR(255) NOT NULL,
    year            INT UNSIGNED, -- 開催年度または常設
    struct          BLOB,
    UNIQUE (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS c4u_event_source (
    id     BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    name   VARCHAR(255) NOT NULL,
    ctf_id BIGINT, -- ctftime
    struct BLOB,
    UNIQUE (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS c4u_difficulty (
    id    BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    name  VARCHAR(255) NOT NULL,
    point INT UNSIGNED NOT NULL,
    UNIQUE (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS c4u_genre (
    id   BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    UNIQUE (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- akictf
CREATE TABLE IF NOT EXISTS sessions (
    id           CHAR(72) PRIMARY KEY,
    session_data TEXT
) ENGINE=InnoDB DEFAULT CHARSET='utf8';
