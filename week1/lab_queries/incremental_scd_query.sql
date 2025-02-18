with last_season_scd as (
    select *
    from player_scd
    where current_season = 2021  -- we hard code the 2021 as last season for our convinience.
    and end_season = 2021
),

historical_scd as(
    select 
        player_name,
        is_active,
        scoring_class,
        start_season,
        end_season
    from player_scd
    where current_season = 2021  -- we hard code the 2021 as last season for our convinience.
    and end_season < 2021  -- we collecting the data for before current year(history)
),

this_season_data as(
    select *
    from players
    where current_season = 2022
),

unchanged_records as (
    select 
        ts.player_name,
        ts.is_active,
        ts.scoring_class,
        ls.start_season,
        ts.current_season as end_season
    from this_season_data ts
    join last_season_scd ls
    on ls.player_name = ts.player_name
    and ls.is_active = ts.is_active
    and ls.scoring_class = ts.scoring_class
),

changed_records as (
    select 
        ts.player_name,
        
        unnest(
            ARRAY[
            ROW(
                ls.is_active,
                ls.scoring_class,
                ls.start_season,
                ls.end_season
            )::scd_type,
            ROW(
                ts.is_active,
                ts.scoring_class,
                ts.current_season,
                ts.current_season
            )::scd_type
        ]) as records
    from this_season_data ts
    left join last_season_scd ls
    on ls.player_name = ts.player_name
    where (ls.is_active <> ts.is_active
    or ls.scoring_class <> ts.scoring_class)
),

unnested_change_records as (
    select 
        player_name,
        (records::scd_type).*
    from changed_records
),

new_records as (
    select 
        ts.player_name,
        ts.is_active,
        ts.scoring_class,
        ts.current_season as start_season,
        ts.current_season as end_season
    from this_season_data ts
    left join last_season_scd ls
    on ls.player_name = ts.player_name
    where ls.player_name is null
)

select *, 2022 as current_season from(
    select * from historical_scd

    union all

    select * from unchanged_records

    union all

    select * from unnested_change_records

    union all

    select * from new_records
) a
