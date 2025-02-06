INSERT INTO array_metrics
with daily_aggregate as(
    SELECT 
        user_id,
        DATE(event_time) as date,
        count(1) num_site_hits 
    from events
    where DATE(event_time) = DATE('2023-01-03')
    and user_id is not null
    group by user_id, DATE(event_time)
),
yesterday_ag as(
    select *
    from array_metrics
    where month_start = DATE('2023-01-01')
)

select
    coalesce(da.user_id, ya.user_id) as user_id,
    coalesce(ya.month_start, DATE(DATE_TRUNC('month', da.date))) as month_start,
    'site_hits' as metric_name,
    case 
        when ya.metric_array is not null
            THEN ya.metric_array || ARRAY[coalesce(da.num_site_hits, 0)]
        when ya.metric_array is null
            THEN ARRAY_FILL(0, ARRAY[coalesce((date - DATE(DATE_TRUNC('month', date))), 0)]) || ARRAY[coalesce(da.num_site_hits, 0)]
    end as metric_array  
from daily_aggregate as da
FULL OUTER JOIN yesterday_ag as ya
on da.user_id = ya.user_id
on conflict (user_id, month_start, metric_name)
DO
    update set metric_array = EXCLUDED.metric_array;


select cardinality(metric_array), count(1)
from array_metrics
group by 1
limit 200