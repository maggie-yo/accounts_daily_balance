{{
    config (
        partition_by = {'field': 'day_range', 'data_type': 'date'},
        cluster_by=['account_id']
    )
}}
with base as (
select
account_id
, balance_day
, min(balance_day) over (partition by account_id) as min_balance_day  -- earleist day of the account balance records
, max(balance_day) over (partition by account_id) as max_balance_day  -- latest day of the account balance records
, lead(balance_day) over (partition by account_id order by balance_day) as next_balance_day 
, sum(balance_dkk)  over (partition by account_id order by balance_day) as balance_dkk -- total balance
, load_day
from {{ ref('stg_appdb__balance') }}
)

, daterange as (
    select
    distinct  -- to avoid duplicates; only looking into unique accounds and existing days
    b.account_id,
    day_range
    from base as b
     -- creating date range, by day interval, from the earliest until the latest balance day we have record for
    CROSS JOIN UNNEST(GENERATE_DATE_ARRAY( B.min_balance_day, B.max_balance_day , INTERVAL 1 DAY)) AS day_range 
)

select
d.day_range
, d.account_id
, b.balance_dkk
, load_day
from daterange as d
inner join base as b
 ON D.day_range >= B.balance_day 
    AND (D.day_range < B.next_balance_day OR next_balance_day IS NULL)
    AND D.account_id = B.account_id
