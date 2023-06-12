
select
b.balance_day
, b.account_id
, b.balance_dkk
, a.account_created_at
from {{ ref( 'stg_appdb__balance' ) }} as b

inner join {{ ref( 'stg_appdb__accounts' ) }} as a
using (account_id)