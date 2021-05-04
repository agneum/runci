-- Deploy runci:new_index to pg

BEGIN;

-- XXX Add DDLs here.
create index new_idx on abc (a);

COMMIT;
