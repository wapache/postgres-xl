
-- try a special column name 
create table xltest_type ("primary" integer, b integer);
insert into xltest_type values(1, 11);
insert into xltest_type values(2, 12);
insert into xltest_type values(3, 13);

select count(*) from xltest_type;
set enable_fast_query_shipping to false;
select count(*) from xltest_type;
select * from xltest_type order by "primary";

drop table xltest_type;


-- repeat with a temp table
set enable_fast_query_shipping to default;
create temp table xltest_type ("primary" integer, b integer);
insert into xltest_type values(1, 11);
insert into xltest_type values(2, 12);
insert into xltest_type values(3, 13);

select count(*) from xltest_type;
set enable_fast_query_shipping to false;
select count(*) from xltest_type;
select * from xltest_type order by "primary";

drop table xltest_type;


-- try a special table name
set enable_fast_query_shipping to default;
create table "XLTEST_type" ("primary" integer, b integer);
-- fail
insert into xltest_type values(1, 11);
-- fail
insert into XLTEST_type values(1, 11);
-- ok
insert into "XLTEST_type" values(1, 11);
insert into "XLTEST_type" values(2, 12);
insert into "XLTEST_type" values(3, 13);

-- fail
select count(*) from XLTEST_type;
-- ok
select count(*) from "XLTEST_type";
select array_agg(c.*) from "XLTEST_type" c where c.primary = 1;

set enable_fast_query_shipping to false;
-- fail
select count(*) from XLTEST_type;
-- ok
select count(*) from "XLTEST_type";

select array_agg(c.*) from "XLTEST_type" c where c.primary = 1;

-- fail
drop table xltest_type;
-- fail
drop table XLTEST_type;
-- fail
drop table "XLTEST_TYPE";
-- ok
drop table "XLTEST_type";

-- try schema qualification for simple schema name
set enable_fast_query_shipping to default;
create schema xltypeschema;
create table xltypeschema."XLTEST_type" ("primary" integer, b integer);
insert into xltypeschema."XLTEST_type" values(1, 11);
insert into xltypeschema."XLTEST_type" values(2, 12);
insert into xltypeschema."XLTEST_type" values(3, 13);

select array_agg(c.*) from "XLTEST_type" c where c.primary = 1;
select array_agg(c.*) from xltypeschema."XLTEST_type" c where c.primary = 1;

drop table xltypeschema."XLTEST_type";

-- try schema qualification for special schema name
create schema "XL.Schema";
create table "XL.Schema"."XLTEST_type" ("primary" integer, b integer);
insert into "XL.Schema"."XLTEST_type" values(1, 11);
insert into "XL.Schema"."XLTEST_type" values(2, 12);
insert into "XL.Schema"."XLTEST_type" values(3, 13);

select array_agg(c.*) from "XL.Schema"."XLTEST_type" c where c.primary = 1;

-- without schema, fail
select array_agg(c.*) from "XLTEST_type" c;
set search_path = "XL.Schema";
-- should work
select array_agg(c.*) from "XLTEST_type" c where c.primary = 1;

drop table "XL.Schema"."XLTEST_type";

-- test ANALYZE
set search_path to default;
create table test_a1 (a int, b int);
insert into test_a1 values (1, 10);
analyze test_a1;

-- check temp table handling
create temp table test_a2 (a int, b int);
insert into test_a2 values (1, 10);
analyze test_a2;

-- check schema qualification
create schema analyze_s1;
create table analyze_s1.test_a1 (a int, b int);
create table analyze_s1.test_a3 (a int, b int);
insert into analyze_s1.test_a1 values (1, 10);
insert into analyze_s1.test_a3 values (1, 10);
analyze analyze_s1.test_a1;
analyze test_a3;				-- error
set search_path = 'analyze_s1';
analyze test_a3;				-- ok

-- schema names requiring quoating
create schema "ANALYZE S2";
set search_path = 'ANALYZE S2';
create table "TEST A4" (a int, b int);
insert into "TEST A4" values (1, 10);
set search_path to default;
analyze "TEST A4";				-- error
analyze "ANALYZE S2"."TEST A4";
set search_path = 'ANALYZE S2';
analyze "TEST A4";

-- check materialised view
set search_path to default;
create materialized view analyze_mv1 as select * from test_a1;
analyze analyze_mv1;

drop table test_a1 cascade;
drop table test_a2;
drop schema analyze_s1 cascade;
drop schema "ANALYZE S2" cascade;

-- size functions
create table tabsize (a int);
insert into tabsize values (1);
select pg_relation_size('tabsize');			-- only one node should have one heap page
select pg_total_relation_size('tabsize');	-- no indexes or toast
insert into tabsize values (2), (3);
select pg_relation_size('tabsize');			-- both nodes should have one heap page each
select pg_total_relation_size('tabsize');	-- no indexes or toast

create index testindx ON tabsize(a);
select pg_total_relation_size('tabsize');	-- index size gets added

alter table tabsize add column b text default 'x';		-- toast table
select pg_total_relation_size('tabsize');	-- toast table size gets added
create index testindx_b ON tabsize(b);
select pg_total_relation_size('tabsize');	-- another index on the table

-- check materialized view
create materialized view tabsize_mv1 as select a from tabsize;
select pg_total_relation_size('tabsize_mv1');
create materialized view tabsize_mv2 as select a, b from tabsize;
select pg_total_relation_size('tabsize_mv2');

drop table tabsize cascade;

-- check temp table
create temp table tabsize (a int);
insert into tabsize values (1), (2), (3);
select pg_relation_size('tabsize');			-- both nodes should have one heap page each
select pg_total_relation_size('tabsize');	-- no indexes or toast

create index testindx ON tabsize(a);
select pg_total_relation_size('tabsize');	-- index size gets added
drop table tabsize;

-- check replicated tables
create table tabsize (a int) distribute by replication;
insert into tabsize values (1), (2), (3);
select pg_relation_size('tabsize');
select pg_total_relation_size('tabsize');
drop table tabsize;

-- check schema qualified, special names etc
create schema "schema_SIZE";
create table "schema_SIZE"."tab_SIZE" (a int);
insert into "schema_SIZE"."tab_SIZE" values (1), (2), (3);
select pg_relation_size('"schema_SIZE"."tab_SIZE"');
set search_path to "schema_SIZE";
select pg_relation_size('"tab_SIZE"');
drop table "schema_SIZE"."tab_SIZE";

-- a test known to crash (before it was fixed)
CREATE TEMPORARY TABLE empsalary (
    depname varchar,
    empno bigint,
    salary int,
    enroll_date date
);

INSERT INTO empsalary VALUES
('develop', 10, 5200, '2007-08-01'),
('sales', 1, 5000, '2006-10-01'),
('personnel', 5, 3500, '2007-12-10'),
('sales', 4, 4800, '2007-08-08'),
('personnel', 2, 3900, '2006-12-23'),
('develop', 7, 4200, '2008-01-01'),
('develop', 9, 4500, '2008-01-01'),
('sales', 3, 4800, '2007-08-01'),
('develop', 8, 6000, '2006-10-01'),
('develop', 11, 5200, '2007-08-15');

CREATE TEMPORARY TABLE t1_tmp (depname text, empno int, salary int, sum int);
INSERT INTO t1_tmp SELECT depname, empno, salary, sum(salary) OVER (PARTITION BY depname) FROM empsalary;
SELECT * FROM t1_tmp ORDER BY empno;
