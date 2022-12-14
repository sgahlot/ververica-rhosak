-- For using Kafka PlainLoginModule in OpenShift
-- https://ververica.zendesk.com/hc/en-us/articles/4416135903634-How-to-Secure-User-Credentials-in-Ververica-Platform-when-Connecting-to-SASL-Secured-Kafka-Cluster
-- For Ververica on OpenShift, use following Class:
    -- org.apache.flink.kafka.shaded.org.apache.kafka.common.security.plain.PlainLoginModule


-- Create table for "customers" topic 
create table customers (
   customerId String,
   name String
) with (
    'connector' = 'kafka',
    'topic' = 'customers',
    'scan.startup.mode' = 'earliest-offset',
    'properties.group.id' = 'customers-consumers',
    'format' = 'json',
    'properties.bootstrap.servers' = 'REPLACE_WITH_BOOTSTRAP_SERVER',
    'properties.security.protocol' = 'SASL_SSL',
    'properties.sasl.mechanism' = 'PLAIN',
    'properties.sasl.jaas.config' = 'org.apache.flink.kafka.shaded.org.apache.kafka.common.security.plain.PlainLoginModule required
username="REPLACE_WITH_CLIENT_ID" password="REPLACE_WITH_CLIENT_SECRET";'
);

-- Create table for "items" topic
create table items (
   itemId String,
   item String
) with (
    'connector' = 'kafka',
    'topic' = 'items',
    'scan.startup.mode' = 'earliest-offset',
    'properties.group.id' = 'items-consumers',
    'format' = 'json',
    'properties.bootstrap.servers' = 'REPLACE_WITH_BOOTSTRAP_SERVER',
    'properties.security.protocol' = 'SASL_SSL',
    'properties.sasl.mechanism' = 'PLAIN',
    'properties.sasl.jaas.config' = 'org.apache.flink.kafka.shaded.org.apache.kafka.common.security.plain.PlainLoginModule required
username="REPLACE_WITH_CLIENT_ID" password="REPLACE_WITH_CLIENT_SECRET";'
);

-- Create table for "orders" topic
create table orders (
   itemId String,
   customerId String,
   price Decimal(10,2)
) with (
    'connector' = 'kafka',
    'topic' = 'orders',
    'scan.startup.mode' = 'earliest-offset',
    'properties.group.id' = 'orders-consumers',
    'format' = 'json',
    'properties.bootstrap.servers' = 'REPLACE_WITH_BOOTSTRAP_SERVER',
    'properties.security.protocol' = 'SASL_SSL',
    'properties.sasl.mechanism' = 'PLAIN',
    'properties.sasl.jaas.config' = 'org.apache.flink.kafka.shaded.org.apache.kafka.common.security.plain.PlainLoginModule required
username="REPLACE_WITH_CLIENT_ID" password="REPLACE_WITH_CLIENT_SECRET";'
);

--show tables;

-- Insert data for various tables/topics
insert into customers (customerId, name) values
    ('C1','Joe Black'),
    ('C2','Bill Smith'),
    ('C3','Mary Cane'),
    ('C4','Cassandra Erickson'),
    ('C5','Uma Kelley'),
    ('C6', 'Deanna Jordan'),
    ('C7', 'Flynn Mcclure'),
    ('C8', 'Karyn Pearson'),
    ('C9', 'Faith Gamble'),
    ('C10', 'Derek Gould');

insert into items (itemId, item) values
    ('A1','ball'),
    ('A2','shoes'),
    ('A3','racket'),
    ('A4','Citizen watch'),
    ('A5','Dog bone');

insert into orders (itemId, customerId, price) values
    ('A1', 'C1', 5.80),
    ('A1', 'C2', 6.00),
    ('A1', 'C3', 5.00),
    ('A2', 'C1', 123.30),
    ('A2', 'C1', 120.30);

-- Ververica:
-- No support for temporary view - normal view is fine
create view full_orders as
  SELECT C.customerId as customerId,
         C.name,
         I.itemId,
         I.item,
         O.price
    FROM orders O
    JOIN customers C ON O.customerId = C.customerId
    JOIN items I ON I.itemId = O.itemId;

create view aggregated_orders as
  SELECT customerId,
         count(*) as noOfItems,
         sum(price) as totalPrice
    FROM full_orders
    GROUP BY customerId;
