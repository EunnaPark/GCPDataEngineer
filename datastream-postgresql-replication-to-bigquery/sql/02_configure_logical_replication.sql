CREATE PUBLICATION test_publication FOR ALL TABLES;

ALTER USER postgres WITH REPLICATION;

SELECT pg_create_logical_replication_slot('test_replication', 'pgoutput');
