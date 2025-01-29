INSERT INTO user_cumulated
with yesterday as(
    select *
    from user_cumulated
    where updated_date = DATE('2023-01-30')
),
today as(
    select 
        cast(user_id as text) as user_id,
        DATE(event_time) as date_active
    from events
    where DATE(event_time) = DATE('2023-01-31')
    and user_id is not null
    group by user_id, DATE(event_time)
)

select 
    coalesce(t.user_id, y.user_id) as user_id,
    case 
        when t.date_active is not null then y.dates_active || ARRAY[t.date_active]
        when y.dates_active is null then ARRAY[t.date_active]
        else y.dates_active
    end as dates_active,
    coalesce(t.date_active, y.updated_date + INTERVAL '1 day') as updated_date
from today t
full outer join yesterday y
on y.user_id = t.user_id;

select *
from user_cumulated
where updated_date = DATE('2023-01-31');
-- limit 100;