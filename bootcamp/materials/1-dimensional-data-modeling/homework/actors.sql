CREATE TYPE film_stats AS (
    film TEXT,
    votes INTEGER,
    rating REAL,
    filmid TEXT
);

CREATE TABLE actors (
    actor_id TEXT,
    actor TEXT,
    films film_stats[],
    quality_class TEXT,
    is_active BOOLEAN,
    current_year INTEGER,
    PRIMARY KEY (actor_id, current_year)
);