-- Revert runci:new_index from pg

BEGIN;

-- XXX Add DDLs here.
drop index new_idx;

COMMIT;
