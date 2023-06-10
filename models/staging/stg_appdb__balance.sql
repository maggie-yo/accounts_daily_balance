select
*
from {{ source('appdb', 'balance_*') }}