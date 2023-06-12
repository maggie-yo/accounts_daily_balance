select
balance_day
, account_id
, cast(account_created_at as date) as account_created_date
, balance_dkk as last_known_balance
from {{ref ( 'int_appdb__accounts_with_balance' )}}

-- to get the last known balance per account
qualify max(balance_day) over(partition by account_id)=balance_day
