-- deploy runci:initial to pg

begin;

create table abc (a int);

CREATE OR REPLACE FUNCTION test_scalability (n INT)
 RETURNS VOID AS
$$
BEGIN
  FOR iter IN 0..(n-1) LOOP

      EXECUTE 'create table abc_'|| iter || ' (a int, b text, c text)';

      FOR sec IN 0..100 LOOP
          EXECUTE 'INSERT INTO abc_'|| iter || ' VALUES ('|| sec ||', md5(random()::text), md5(random()::text))';
      END LOOP;

      FOR sec IN 0..2 LOOP
          EXECUTE 'create index idx_abc_'|| iter || '_' || sec ||'_a on abc_' || iter || ' (a)';
          EXECUTE 'create index idx_abc_'|| iter || '_' || sec ||'_b on abc_' || iter || ' (b)';
          EXECUTE 'create index idx_abc_'|| iter || '_' || sec ||'_c on abc_' || iter || ' (c)';
        END LOOP;

  END LOOP;
END;
$$ LANGUAGE plpgsql;

select test_scalability(100);

commit;
