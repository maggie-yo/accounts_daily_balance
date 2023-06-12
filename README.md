### Data Pipeline Setup

To optimize my data pipeline, I made the following choices:

1. **Selecting BQ as the Data Warehouse**: I opted for BQ (BigQuery) due to its cost-effectiveness and the fact that I already had it configured and ready to use.

2. **Loading Data into BQ**: I successfully loaded the relevant data into BQ.

3. **Setting up dbt**: To enhance the data transformation process, I structured dbt (data build tool) with the following layers: *staging, intermediate, and marts*.

   - **Staging Layer**: This layer serves as the initial preparation phase for the data. Additionally, it includes the setup of an incremental strategy called "insert_overwrite." This strategy ensures that the latest data extract of the day always becomes the source of truth (SOT), even when multiple extracts are available.

     The steps involved in the staging layer are as follows:

     1. **Materializing Destination Tables**: I created destination tables to store the transformed data.
     2. **Parsing Table Suffix as Date**: Since multiple extracts may occur on a single day, I partitioned the tables based on a suffix representing the extraction date.
     3. **Delta Hash Creation**: I generated a unique key, known as a delta hash, for each row. Although this key is not used for the incremental strategy mentioned earlier, it can be valuable for other purposes.
     4. **Configuring Incremental Load**: I set up the incremental loading of data for both the accounts and balance tables.

By implementing this data pipeline structure, I aimed to streamline data processing and ensure the latest and most accurate information is readily available for analysis.
