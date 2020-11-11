SET ECHO ON
SET FEEDBACK 1
SET NUMWIDTH 10
SET LINESIZE 80
SET TRIMSPOOL ON
SET TAB OFF
SET PAGESIZE 100
declare
  cnt1 NUMBER;
  cnt2 NUMBER;
begin
  select count(*) into cnt1 from user_objects where object_name=UPPER('dbms_optim_bugValObType');
  select count(*) into cnt2 from user_objects where object_name=UPPER('dbms_optim_fcTabType');

  if cnt1 = 0 then
    execute immediate 'create or replace TYPE dbms_optim_bugValObType as object(fix number, val number)';
  end if;

  if cnt2 = 0 then
    execute immediate 'create or replace TYPE dbms_optim_fcTabType as table of dbms_optim_bugValObType';
  end if;

exception
   when others then
     RAISE_APPLICATION_ERROR(-20002, sqlerrm || ' INITIAL TYPE creation failed ');
end;
/
CREATE OR REPLACE PACKAGE BODY dbms_optim_bundle wrapped 
a000000
1
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
b
ac8d 2a17
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

/
show errors;
