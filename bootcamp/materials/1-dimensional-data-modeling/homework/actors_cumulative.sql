INSERT INTO actors
WITH

last_year AS (
    SELECT *
    FROM actors
    WHERE current_year = 1981
),

this_year AS (
    SELECT
        year,
        actorid AS actor_id,
        actor,
        array_agg(ROW(
                film,
                votes,
                rating,
                filmid)::film_stats)
        as film_stat,
        AVG(rating) AS avg_rating
    FROM actor_films
    WHERE year = 1982
    GROUP BY year, actor_id, actor
)

SELECT 
    COALESCE(ly.actor_id, ty.actor_id) AS actor_id,
    COALESCE(ly.actor, ty.actor) AS actor,
    COALESCE(ly.films, ARRAY[]::film_stats[]) || CASE 
        WHEN ty.year IS NOT NULL THEN film_stat
            ELSE ARRAY[]::film_stats[] END
    as films,
    CASE WHEN ty.year IS NOT NULL
        THEN (
            CASE 
                WHEN avg_rating > 8 THEN 'star'
                WHEN avg_rating > 7 AND avg_rating <= 8 THEN 'good'
                WHEN avg_rating > 6 AND avg_rating <= 7 THEN 'average'
                ELSE 'bad'
            END
        )
    ELSE ly.quality_class
    END AS quality_class,
    ty.year IS NOT NULL AS is_active,
    1982 as current_year
FROM last_year AS ly
FULL OUTER JOIN this_year AS ty
ON ly.actor_id = ty.actor_id;