# Streambased <> Dattum Demo

## What does this demo do?

This demo simulates a simple restial case. 3 Datasets are included:

1. Transactions - events containing information about customer purchases
2. Inventory - events showing new stock arriving at our retailer
3. CustomerCases - records of customer contacts

## Step 1: Setup and review the environment

First run the setup script, this will configure and start resources for the demo.

```bash
./bin/setup.sh
```

Our environment consists of the following components:

1. A single node Kafka cluster (containers kafka1 and zookeeper) - for data storage
2. A Schema Registry - for governance
3. Streambased Indexer - to create the indexes Streambased uses to be fast
4. Streambased Server - to make the Kafka data available via JDBC
5. Superset - a popular and easy to use database client

## Step 2: Start the environment

To bring up the environment run:

```bash
docker-compose up -d
```

## Step 3: Open superset

Now we can query the collected data and demonstrate the Streambased effect. 

From a web browser navigate to `localhost:8088`.

Log in with credentials `admin:admin`

## Step 4: Query with Streambased

Next from the menu at the top select `SQL -> SQL Lab`, you will see a familiar SQL query interface. In the query entry 
area add the following:

```
use kafka.streambased;
set session use_streambased=true;
select * from transactions t join inventory i on t.stockCode = i.productId;
```

and click `RUN`

## Step 5: Explore!

Feel free to run other queries against this dataset with or without Streambased acceleration enabled

## Step 6: Tear down

To complete the demo run the following. This will stop and remove all demo resources:

```bash
docker-compose stop
docker-compsoe rm
```

## Notes for model training

A few pointers on the data provided. 

1. A few columns have been replaced with random values to enable them to be used together. 
   This will make the values appear much more evenly distributed than they actually are.
2. We are looking for 4 categories, these are not mutually exclusive:
  * Indexed Column - A column likely to be used in query predicates
  * Grouping key (must be paired with one or more aggregate columns) - A column likely to be used as the part of the grouping key in a GROUP BY clause.
  * Aggregate Column (must be paired with one or more grouping keys) - A column likely to be aggregated. Streambased currently support aggregation 
    acceleration for numerical columns only and records Min/Max/Sum/Count for these columns.
  * Unindexed Column - Indexing is expensive so we should identify all columns that are unlikely to
    be involved in the above.
3. I've included the source data in json format in the /data directory. I've also included the 
   schemas for the data, these will be present for all datasets we index and can be provided to any 
   API created.
4. Date support is not fully here yet in Streambased, let's drop any date columns for the MVP

Expected results:

Transactions:

* invoiceNo - this should be indexed as it is likely to be used for point lookups
* stockCode - unindexed column
* quantity - aggregate column paired with customerID/country
* invoiceDate -  unindexed column 
* unitPrice - aggregate column paired with customerID/country
* unitTax - aggregate column paired with customerID/country
* customerID - indexed column and grouping key column
* country - indexed column and grouping key column

Inventory:

* ItemId - indexed column
* category - indexed column and grouping key column
* leadTime - unindexed column
* configuration - unindexed column
* description - unindexed column
* channelId - indexed column and grouping key column
* productId - indexed column
* productName - unindexed column
* demandWeekStartDate - unindexed column
* versionWeekStartDate - unindexed column
* forecastQuantity - aggregate column paired with category/channelId/productId/supplyChainType
* supplyChainType - indexed column and grouping key column

Customer Cases:

* caseId - indexed column
* initiationTime - unindexed column
* customerId - indexed column
* channel - grouping key column
* reason - unindexed column
* agentMins - aggregate column paired with channel
* customerMins - aggregate column paired with channel