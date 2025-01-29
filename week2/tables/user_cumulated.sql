create table user_cumulated(
    user_id TEXT,
    -- the list of the dates in the past which the users were active.
    dates_active DATE[],
    -- current date for user.
    updated_date date,
    PRIMARY KEY(user_id, updated_date)
);