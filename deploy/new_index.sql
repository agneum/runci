-- Deploy runci:new_index to pg

BEGIN;

create table demo_table(a int);
create index demo_idx on demo_table3 (a);

COMMIT;
