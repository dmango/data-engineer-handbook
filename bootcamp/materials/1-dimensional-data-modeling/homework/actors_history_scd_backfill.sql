INSERT INTO actors_history_scd
WITH

streak_started AS (
    SELECT
        actor_id,
        actor,
        current_year,
        quality_class,
        is_active,
        LAG(quality_class, 1) OVER (PARTITION BY actor_id ORDER BY current_year) <> quality_class
            OR LAG(quality_class, 1) OVER (PARTITION BY actor_id ORDER BY current_year) IS NULL
        AS quality_class_did_change,
        LAG(is_active, 1) OVER (PARTITION BY actor_id ORDER BY current_year) <> is_active
            OR LAG(is_active, 1) OVER (PARTITION BY actor_id ORDER BY current_year) IS NULL
        AS is_active_did_change
    FROM actors
),

streak_identified AS (
    SELECT
        actor_id,
        actor,
        quality_class,
        is_active,
        current_year,
        SUM(CASE WHEN quality_class_did_change OR is_active_did_change THEN 1 ELSE 0 END)
            OVER (PARTITION BY actor_id ORDER BY current_year)
        AS streak_identifier
    FROM streak_started
),

aggregated AS (
    SELECT
        actor_id,
        actor,
        quality_class,
        is_active,
        streak_identifier,
        MIN(current_year) AS start_date,
        MAX(current_year) AS end_date
    FROM streak_identified
    GROUP BY actor_id, actor, quality_class, is_active, streak_identifier
)

SELECT 
    actor_id,
    actor,
    quality_class,
    is_active,
    start_date,
    end_date,
    1981 as current_year
FROM aggregated;