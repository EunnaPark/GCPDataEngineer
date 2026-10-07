CREATE SCHEMA IF NOT EXISTS test;

CREATE TABLE IF NOT EXISTS test.example_table (
    id SERIAL PRIMARY KEY,
    text_col VARCHAR(50),
    int_col INT,
    date_col TIMESTAMP
);

ALTER TABLE test.example_table REPLICA IDENTITY DEFAULT;

INSERT INTO test.example_table (text_col, int_col, date_col) VALUES
    ('hello', 0, '2020-01-01 00:00:00'),
    ('goodbye', 1, NULL),
    ('name', -987, NOW()),
    ('other', 2786, '2021-01-01 00:00:00');
