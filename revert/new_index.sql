-- Revert runci:new_index from pg

BEGIN;

drop index demo_idx;
drop table demo_table;

COMMIT;
