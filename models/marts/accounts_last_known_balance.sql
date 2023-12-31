{{
    config (
        partition_by = {'field': 'balance_day', 'data_type': 'date'},
        cluster_by=['account_id']
    )
}}
select
balance_day
, account_id
, cast(account_created_at as date) as account_created_date
, balance_dkk as last_known_balance
from {{ref ( 'int_appdb__accounts_overview' )}}

-- to get the last known balance per account
qualify max(balance_day) over(partition by account_id)=balance_day
