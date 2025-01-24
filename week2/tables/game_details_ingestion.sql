INSERT INTO fct_game_details
with
  deduped as (
    select
      g.game_date_est,
      g.home_team_id,
      g.season,
      gd.*,
      row_number() over (
        partition by gd.game_id,
        gd.team_id,
        gd.player_id
        order by
          g.game_date_est
      ) as row_number
    from
      game_details gd
      join games g on g.game_id = gd.game_id
  )
select
  game_date_est as dim_game_date,
  season as dim_season,
  team_id as dim_team_id,
  player_id as dim_player_id,
  player_name as dim_player_name,
  start_position as dim_start_position,
  team_id = home_team_id as dim_is_playing_at_home,
  coalesce(position('DNP' in comment), 0) > 0 as dim_did_not_play,
  coalesce(position('DND' in comment), 0) > 0 as dim_did_not_dressed,
  coalesce(position('NWT' in comment), 0) > 0 as dim_not_with_team,
  cast(split_part(min, ':', 1) as real) + cast(split_part(min, ':', 2) as real) / 60 as m_minutes,
  fgm as m_fgm,
  fga as m_fga,
  fg3m as m_fg3m,
  fg3a as m_fg3a,
  ftm as m_ftm,
  fta as m_fta,
  oreb as m_oreb,
  dreb as m_dreb,
  reb as m_reb,
  ast as m_ast,
  stl as m_stl,
  blk as m_blk,
  "TO" as m_turnovers,
  pf as m_pf,
  pts as m_pts,
  plus_minus as m_plus_minus
from
  deduped
where
  row_number = 1;



select *
from fct_game_details
limit 100;

select
  dim_player_name,
  count(1) as num_games,
  count(case when dim_not_with_team then 1 end) as bailed_num,
  cast(count(case when dim_not_with_team then 1 end) as REAL) / count(1) * 100 as bailed_out_pct
from fct_game_details
group by dim_player_name
order by 4 desc;


select
  game_id,
  player_id,
  team_id,
  count(1)
from
  game_details
group by
  1,
  2,
  3
having
  count(1) > 1