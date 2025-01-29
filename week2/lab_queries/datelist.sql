with users as(
    select *
    from user_cumulated
    where updated_date = DATE('2023-01-31')
),

series as (
    select *
    from generate_series(DATE('2023-01-01'), DATE('2023-01-31'), INTERVAL '1 day') as series_date
),
place_holder as (
    select 
        case 
            when dates_active @> ARRAY[DATE(series_date)] 
                then cast (pow(2, 32 - (updated_date - DATE(series_date))) as BIGINT)
            else 0
        end as placeholder_int,
        *
    
    from users cross join series
)

select 
    user_id,
    cast(cast(sum(placeholder_int) as BIGINT) as BIT(32)),
    bit_count(cast(cast(sum(placeholder_int) as BIGINT) as BIT(32))) > 0 as dim_is_monthly_active,
    bit_count(cast('11111110000000000000000000000000' as BIT(32)) &
    cast(cast(sum(placeholder_int) as BIGINT) as BIT(32))) as dim_is_weekly_active
from place_holder
group by user_id
limit 100;