insert into player_scd

with previous as(
select 
    player_name, 
    current_season,
    scoring_class, 
    is_active,
    LAG(scoring_class, 1) OVER (PARTITION BY player_name ORDER BY current_season) as pre_scoring_class,
    LAG(is_active, 1) OVER (PARTITION BY player_name ORDER BY current_season) as pre_is_active
from players
where current_season <= 2021
),

change_ind as(
    select 
    *,
    CASE 
        WHEN pre_scoring_class <> scoring_class then 0
        when pre_is_active <> is_active then 0
        else 1
    end as change_indicator
from previous
),

streak_indicator as (
    select
        *,
        sum(change_indicator) over (PARTITION by player_name order by current_season) as streak_indicator
    from change_ind
)

select
    player_name,
    scoring_class,
    is_active,
    -- streak_indicator,
    min(current_season) as start_season,
    max(current_season) as end_season,
    2021 as current_season
from streak_indicator
group by player_name, streak_indicator, is_active, scoring_class
order by player_name, streak_indicator;