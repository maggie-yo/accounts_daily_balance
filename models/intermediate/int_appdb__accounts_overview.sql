{{
    config (
        partition_by = {'field': 'balance_day', 'data_type': 'date'},
        cluster_by=['account_id']
    )
}}
select
b.balance_day
, b.account_id
, b.balance_dkk
, a.account_created_at
from {{ ref( 'stg_appdb__balance' ) }} as b

inner join {{ ref( 'stg_appdb__accounts' ) }} as a
using (account_id)