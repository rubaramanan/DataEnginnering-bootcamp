CREATE TYPE season_stats AS (
  season INTEGER,
  pts REAL,
  ast REAL,
  reb real,
  weight INTEGER
);


CREATE TYPE scoring_class as ENUM('star', 'good', 'average', 'bad');


CREATE TABLE
  players (
    player_name TEXT,
    height TEXT,
    college TEXT,
    country TEXT,
    draft_year TEXT,
    draft_round TEXT,
    draft_number TEXT,
    seasons season_stats [],
    scoring_class scoring_class,
    year_since_last_season INTEGER,
    is_active BOOLEAN,
    current_season INTEGER,
    PRIMARY KEY(player_name, current_season)
  );