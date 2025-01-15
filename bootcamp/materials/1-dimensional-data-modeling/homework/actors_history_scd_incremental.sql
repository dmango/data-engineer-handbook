create type scd_type as (
    quality_class text,
    is_active boolean,
    start_date integer,
    end_date integer
);

insert into actors_history_scd
with

last_year_scd as (
    select *
    from actors_history_scd
    where current_year = 1981
    and end_date = 1981
),

historical_scd as (
    select
        actor_id,
        actor,
        quality_class,
        is_active,
        start_date,
        end_date
    from actors_history_scd
    where current_year = 1981
    and end_date < 1981
),

this_year as (
    select *
    from actors
    where current_year = 1982
),

unchanged_records as (
    select
        ty.actor_id,
        ty.actor,
        ty.quality_class,
        ty.is_active,
        ly.start_date,
        ty.current_year as end_date
    from this_year as ty
    inner join last_year_scd as ly
    on ty.actor_id = ly.actor_id
    where ty.quality_class = ly.quality_class
    and ty.is_active = ly.is_active
),

changed_records as (
    select
        ty.actor_id,
        ty.actor,
        unnest(array[
            row(
                ly.quality_class,
                ly.is_active,
                ly.start_date,
                ly.end_date
            )::scd_type,
            row(
                ty.quality_class,
                ty.is_active,
                ty.current_year,
                ty.current_year
            )::scd_type
        ]) as records
    from this_year as ty
    left join last_year_scd as ly
    on ty.actor_id = ly.actor_id
    where (
        ty.quality_class <> ly.quality_class
        or ty.is_active <> ly.is_active
    )
),

unnested_changed_records as (
    select
        actor_id,
        actor,
        (records::scd_type).quality_class,
        (records::scd_type).is_active,
        (records::scd_type).start_date,
        (records::scd_type).end_date
    from changed_records
),

new_records as (
    select
        ty.actor_id,
        ty.actor,
        ty.quality_class,
        ty.is_active,
        ty.current_year as start_date,
        ty.current_year as end_date
    from this_year as ty
    left join last_year_scd as ly
    on ty.actor_id = ly.actor_id
    where ly.actor_id is null
),

uninoned as (
    select *
    from historical_scd

    union all

    select *
    from unchanged_records

    union all

    select *
    from unnested_changed_records

    union all

    select *
    from new_records
)

select 
    *, 
    1982 as current_year
from uninoned;