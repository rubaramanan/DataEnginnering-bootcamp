DO $$
DECLARE 
  year_start INTEGER := 1995; -- Starting year
  year_end INTEGER := 2023; -- Ending year

BEGIN 
  FOR i IN year_start..(year_end) LOOP
    INSERT INTO
      players
    WITH
      last_season AS (
        SELECT
          *
        FROM
          players p
        where
          p.current_season = i
      ),
      current_season AS (
        SELECT
          *
        FROM
          player_seasons ps
        where
          ps.season = i + 1
      )
    select
      COALESCE(l.player_name, c.player_name) as player_name,
      COALESCE(l.height, c.height) as height,
      COALESCE(l.college, c.college) as college,
      COALESCE(l.country, c.country) as country,
      COALESCE(l.draft_number, c.draft_number) as draft_number,
      COALESCE(l.draft_round, c.draft_round) as draft_round,
      COALESCE(l.draft_year, c.draft_year) as draft_year,
      case
        when l.seasons is null then ARRAY [ROW(c.season, c.pts, c.ast, c.reb, c.weight):: season_stats]
        when c.season is not null then l.seasons || ARRAY [ROW(c.season, c.pts, c.ast, c.reb, c.weight):: season_stats]
        ELSE l.seasons
      END as seasons,
      case
        when c.season is not null then case
          when c.pts > 20 then 'star'
          when c.pts > 15 then 'good'
          when c.pts > 10 then 'average'
          when c.pts > 5 then 'bad'
        end:: scoring_class
        else l.scoring_class
      end,
      case
        when c.season is not null then 0
        else l.year_since_last_season + 1
      end as year_since_last_season,
      c.season IS NOT NULL as is_active,
      COALESCE(c.season, l.current_season + 1) as current_season
    from
      last_season as l
      FULL OUTER JOIN current_season as c on c.player_name = l.player_name;


END LOOP;


END $$;