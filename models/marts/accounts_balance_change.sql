with balance_base as (
select
day_range
, account_id
, balance_dkk as current_balance_dkk
, LAG(balance_dkk) OVER (PARTITION BY account_id ORDER BY day_range) as prev_day_balance_dkk
, ifnull(
    (balance_dkk - LAG(balance_dkk) OVER (PARTITION BY account_id ORDER BY day_range))
    , 0) AS balance_change_dkk
from {{ ref('int_appdb__accounts_daily_balance') }}
order by account_id, day_range
)

select
day_range
, account_id
, current_balance_dkk
, prev_day_balance_dkk
, balance_change_dkk
from balance_base

-- to catch both negative and positive deviations
where balance_change_dkk != 0