# Data Pipeline Setup

To optimize my data pipeline, I made the following choices:

1. **Selecting BigQuery as the Data Warehouse**: I opted for BQ due to its cost-effectiveness and the fact that I already had it configured and ready to use.

2. **Loading Data into BQ**: I successfully loaded the relevant data into BQ.

3. **Setting up dbt**: To enhance the data transformation process, I structured dbt with the following layers: *staging, intermediate, and marts*.

##  [Staging Layer](https://github.com/maggie-yo/accounts_daily_balance/tree/main/models/staging)
- This layer serves as the initial preparation phase for the data. Additionally, it includes the setup of an incremental strategy called [*"insert_overwrite"*](https://docs.getdbt.com/reference/resource-configs/bigquery-configs#the-insert_overwrite-strategy). This strategy ensures that the latest data extract of the day always becomes the source of truth, even when multiple extracts are available.

     The steps involved in the staging layer are as follows:

     1. **Parsing Table Suffix as Date**: Since multiple extracts may occur on a single day, I partitioned the tables based on a suffix representing the extraction date.
     2. **Delta Hash Creation**: I generated a unique key, known as a delta hash, for each row. Although this key is not used for the incremental strategy mentioned earlier, it can be valuable for other purposes.
     3. **Configuring Incremental Load**: I set up the incremental loading of data for both the [accounts](https://github.com/maggie-yo/accounts_daily_balance/blob/main/models/staging/stg_appdb__accounts.sql#L1-L8) and [balance](https://github.com/maggie-yo/accounts_daily_balance/blob/main/models/staging/stg_appdb__balance.sql#L1C1-L8) tables.

By implementing this data pipeline structure, I aimed to streamline data processing and ensure the latest and most accurate information is readily available for analysis.

Lastly, I employ a macro to facilitate incremental setup verification (again for both [accounts](https://github.com/maggie-yo/accounts_daily_balance/blob/main/models/staging/stg_appdb__accounts.sql#L24-L27) and [balance](https://github.com/maggie-yo/accounts_daily_balance/blob/main/models/staging/stg_appdb__balance.sql#L26-L29) tables). This macro plays a crucial role in minimizing data scanning for "new data" updates. It instructs dbt to capture the latest data by comparing the date suffix of the new table with the previously loaded data's maximum partition (`_dbt_max_partition`). And to account for late arriving data, a lookback window of 1 day is set up.

In the account table, I noticed a potential faulty data. As I’m not sure which one is an actual record of account D, or if it’s a typo and one of the records is related for *Account C*, I have [excluded both records](https://github.com/maggie-yo/accounts_daily_balance/blob/main/models/staging/stg_appdb__accounts.sql#L29-L30).

##  [Intermediate Level](https://github.com/maggie-yo/accounts_daily_balance/tree/main/models/intermediate)

  - At this stage, models are created based on their respective business areas, involving grouping and pivoting of the staging models at different granularities.

    - [*Int_appdb__accounts_daily_balance*](https://github.com/maggie-yo/accounts_daily_balance/blob/main/models/intermediate/int_appdb__accounts_daily_balance.sql)
      - The purpose of this table is to generate a daily spread for accounts.
      - A `date_array` is utilized to create a sequence of days, ensuring we have information on the balance of accounts even during periods of inactivity.
      - To construct the `date_array`, [the earliest and latest available balance days](https://github.com/maggie-yo/accounts_daily_balance/blob/main/models/intermediate/int_appdb__accounts_daily_balance.sql#L11-L12) are used, partitioned by account ID.
      - Subsequently, this date range, spanning from the minimum to the maximum balance day, is combined with each distinct account using a [cross join](https://github.com/maggie-yo/accounts_daily_balance/blob/main/models/intermediate/int_appdb__accounts_daily_balance.sql#L26) on the activity day (`balance_day`).

    - [*Int_appdb__accounts_overview*](https://github.com/maggie-yo/accounts_daily_balance/blob/main/models/intermediate/int_appdb__accounts_overview.sql)
      - In this table, the balance information is enriched with additional account details (*accounts_created_at*).

## [Marts](https://github.com/maggie-yo/accounts_daily_balance/tree/main/models/marts)

  - This layer involves the creation of business-defined entities that address specific business inquiries and requirements.
    - I have developed two marts based on the available information:
      1. [*Accounts_balance_change*](https://github.com/maggie-yo/accounts_daily_balance/blob/main/models/marts/accounts_balance_change.sql)
         - This mart focuses solely on the balance change between the latest and previous states.
         - It utilizes the table from the intermediate level, which provides a [daily overview](https://github.com/maggie-yo/accounts_daily_balance/blob/main/models/marts/accounts_balance_change.sql#L17) of the accounts.
         - The table specifically examines balance changes, which can be either [positive or negative](https://github.com/maggie-yo/accounts_daily_balance/blob/main/models/marts/accounts_balance_change.sql#L30).

      2. [*Accounts_last_known_balance*](https://github.com/maggie-yo/accounts_daily_balance/blob/main/models/marts/accounts_last_known_balance.sql)
         - The goal of this table is to get the [last known balance](https://github.com/maggie-yo/accounts_daily_balance/blob/main/models/marts/accounts_last_known_balance.sql#L15) per account.



## Future Enhancements

To further improve the data pipeline, I suggest considering the following practices:

- **Anomaly Tests**: Including tests to identify anomalies in the data, ensuring its integrity and quality.
- **Sqlfluff**: Implementing Sqlfluff to enforce consistent code formatting and adhere to best practices.
- **Git Actions**: Setting up Git actions to validate that the code compiles successfully, passes all tests, and meets quality standards.
- **dbt Pre-Commits**: Utilizing dbt pre-commits to automatically check and validate code changes before committing them.
