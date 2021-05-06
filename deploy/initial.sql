-- deploy runci:initial to pg

begin;

create table abc (a int);

create or replace function test_scalability(n int)
  returns void as
$$
begin
  for iter in 0..(n - 1)
    loop
      execute 'create table abc_' || iter || ' (a int, b text, c text)';

      for sec in 0..100
        loop
          execute 'insert into abc_' || iter || ' values (' || sec || ', md5(random()::text), md5(random()::text))';
        end loop;

      for sec in 0..2
        loop
          execute 'create index idx_abc_' || iter || '_' || sec || '_a on abc_' || iter || ' (a)';
          execute 'create index idx_abc_' || iter || '_' || sec || '_b on abc_' || iter || ' (b)';
          execute 'create index idx_abc_' || iter || '_' || sec || '_c on abc_' || iter || ' (c)';
        end loop;

    end loop;
end;
$$ language plpgsql;

select test_scalability(100);

commit;
