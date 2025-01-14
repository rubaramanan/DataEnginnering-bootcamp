select *
from players;


with
  unnested as(
    select
      player_name,
      UNNEST(seasons):: season_stats as seasons,
      current_season
    from
      players
    where
      current_season = 2001
      and player_name = 'Michael Jordan'
  )
select
  player_name,
  (seasons:: season_stats).*
from
  unnested;