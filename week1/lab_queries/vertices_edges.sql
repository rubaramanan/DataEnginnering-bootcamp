create type vertex_type as ENUM(
    'player', 'game', 'team'
);

create type edge_type as ENUM(
    'plays_against',
    'plays_in',
    'plays_on',
    'shares_team'
);

create table vertices(
    identifier TEXT,
    type vertex_type,
    properties JSON,
    primary key (identifier, type)
);

create table edges(
    subject_identifier TEXT,
    subject_type vertex_type,
    object_identifier TEXT,
    object_type vertex_type,
    edge_type edge_type,
    properties JSON,
    primary key(subject_identifier,
    object_identifier,
    subject_type,
    object_type,
    edge_type)

);