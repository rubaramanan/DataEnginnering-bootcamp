INSERT INTO edges 
-- plays_in category
with
  plays_in_deduped as(
    select *,
    ROW_NUMBER() over(partition by player_id order by game_id) as row_number
    from
      game_details)

select player_id as subject_identifier,
      'player':: vertex_type as subject_type,
      game_id as object_identifier,
      'game':: vertex_type as object_type,
      'plays_in':: edge_type as edge_type,
      json_build_object(
        'start_position', start_position,
        'pts', pts,
        'team_id', team_id,
        'team_abbreviation', team_abbreviation
      ) as properties
from plays_in_deduped
where row_number = 1;

INSERT INTO edges
with
  plays_ag_deduped as(
    select
      *,
      ROW_NUMBER() over(
        partition by player_id
        order by
          game_id
      ) as row_number
    from
      game_details
  ),
  filtered as(
    select
      *
    from
      plays_ag_deduped
    where
      row_number = 1
  ),
  aggregated as(
    select
      f1.player_id as subject_player_id,
      f2.player_id as object_player_id,
      f1.player_name as subject_player_name,
      f2.player_name as object_player_name,
      case
        when f1.team_abbreviation = f2.team_abbreviation then 'shares_team':: edge_type
        else 'plays_against':: edge_type
      end as edge_type,
      count(1) as number_of_games,
      -- which counts the column f1.playr_id,
      sum(f1.pts) as subject_points,
      sum(f2.pts) as object_points
    from
      filtered f1
      join filtered f2 on f1.game_id = f2.game_id
      and f1.player_name <> f2.player_name
    where
      f1.player_id > f2.player_id
    group by
      f1.player_id,
      f2.player_id,
      f2.player_name,
      f1.player_name,
      edge_type
  )

select 
    subject_player_id as subject_identifier,
    'player':: vertex_type as subject_type,
    object_player_id as object_identifier,
    'player':: vertex_type as object_type,
    edge_type:: edge_type,
    json_build_object(
        'num_games', number_of_games,
        'subject_points', subject_points,
        'object_points', object_points
    ) as properties
from aggregated


select v.properties ->> 'player_name', -- use to extract the json field
    max(cast(e.properties ->> 'pts' as INTEGER))
from vertices v
join edges e
on v.identifier = e.subject_identifier
and e.subject_type = v.type
group by 1 --Group by the first column, which is 'player_name'
order by 2 DESC; --Order by the second column, which is 'max_points'

select v.properties ->> 'player_name',
    cast(e.properties ->> 'number_of_games' as REAL) / 
    case 
        when cast(e.properties ->> 'total_points' as REAL) = 0 then 1
        else  cast(e.properties ->> 'total_points' as REAL)
    end
from vertices v
join edges e
on v.identifier = e.subject_identifier
and e.subject_type = v.type
where object_type = 'player'