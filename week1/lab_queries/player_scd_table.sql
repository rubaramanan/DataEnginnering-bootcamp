create table player_scd(
    player_name TEXT,
    scoring_class scoring_class,
    is_active BOOLEAN,
    start_season INTEGER,
    end_season INTEGER,
    current_season INTEGER,
    PRIMARY KEY(player_name, start_season, end_season)
);


create type scd_type as(
    is_acitve boolean,
    scoring_class scoring_class,
    start_season integer,
    end_season integer
);