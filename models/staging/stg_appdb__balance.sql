{{
    config (
        materialized='incremental',
        unique_key= 'delta_hash',
        partition_by = {'field': 'table_suffix_date', 'data_type': 'date'},
        incremental_strategy = 'insert_overwrite' 
    )
}}

select
account_id
, balance_dkk
, balance_day
, load_day
, parse_date("%Y%m%d", _TABLE_SUFFIX) as table_suffix_date

-- creating unique_key for each event row in the table
, to_hex(sha256(TO_JSON_STRING(STRUCT(
            account_id,
            balance_day,
            balance_dkk,
            load_day
            )))) AS delta_hash
from {{ source('appdb', 'balance_*') }}

{% if is_incremental() %}
where
   parse_date("%Y%m%d", _TABLE_SUFFIX) >  date_sub(date(_dbt_max_partition), interval 1 day)--  lookback window 
{% endif %}