INSERT INTO vertices
select 
    game_id as identifier,
    'game':: vertex_type as type,
    json_build_object(
        'pts_home', pts_home,
        'pts_away', pts_away,
        'winning_team', case when home_team_wins = 1 then home_team_id else visitor_team_id end
    )
from games;

select * 
from games limit 10;

select * from vertices limit 10;

select * from game_details limit 10;

INSERT INTO vertices
with
  player_agg as(
    select
      player_id as identifier,
      max(player_name) as player_name,
      count(1) as number_of_games,
      sum(pts) as total_points, -- count the first column values
      ARRAY_AGG(distinct team_id) as teams
    from
      game_details
    group by
      player_id
  )

select
    identifier,
    'player':: vertex_type,
    json_build_object(
        'player_name', player_name,
        'number_of_games', number_of_games,
        'total_points', total_points,
        'teams', teams
    ) as properties
from player_agg;

INSERT INTO vertices
with team_dediped as(
    select *,
    ROW_NUMBER() over(partition by team_id) as row_number
    from teams
)
select 
    team_id as identifier,
    'team':: vertex_type as type,
    json_build_object(
        'abbreviation', abbreviation,
        'nickname', nickname,
        'city', city,
        'arena', arena,
        'year_founded', yearfounded
    ) as properties
from team_dediped
where row_number = 1;


-- -- equivalent code for above comment one using qualify


-- qualify keyword not working in postgresql 
-- INSERT INTO vertices
-- select 
--     team_id as identifier,
--     'team':: vertex_type as type,
--     json_build_object(
--         'abbreviation', abbreviation,
--         'nickname', nickname,
--         'city', city,
--         'arena', arena,
--         'year_founded', yearfounded
--     ) as properties,
--     QUALIFY ROW_NUMBER() over (partition by team_id) = 1
-- from teams;

select * from vertices where type='team';