@@?/rdbms/admin/sqlsessstart.sql
var no_vm_ddl_status varchar2(10)
var no_vm_drop_status varchar2(10)
declare
  function getTriggerStatus(trig_owner varchar2, trig_name varchar2) return varchar2 is
    s varchar2(8) ;
  begin
    select status into s
    from dba_triggers
    where owner = trig_owner and
          trigger_name = trig_name ;

    return s ;

  exception when no_data_found then return null ;
  end ;
begin
  :no_vm_ddl_status   := getTriggerStatus('WMSYS', 'NO_VM_DDL') ;
  :no_vm_drop_status  := getTriggerStatus('WMSYS', 'NO_VM_DROP_A') ;
end;
/
create or replace trigger wmsys.no_vm_ddl before alter or create or drop or rename or truncate on database
  when ((ora_sysevent in ('ALTER', 'RENAME', 'TRUNCATE') and ora_dict_obj_type in ('INDEX','TABLE')) or
        (ora_sysevent = 'CREATE' and ora_dict_obj_type in ('INDEX', 'PROCEDURE', 'TRIGGER', 'VIEW')) or
        (ora_sysevent = 'DROP' and ora_dict_obj_type in ('INDEX', 'PROCEDURE', 'ROLE', 'TABLE', 'TRIGGER', 'TYPE', 'USER', 'VIEW')))
declare
  validStack  integer ;
begin
  if (sys_context('lt_ctx', 'allowDDLOperation')='true') then
    return ;
  end if ;

  if (sys_context('lt_ctx', 'validStack') is null or sys_context('lt_ctx', 'validStack') != 'YES') then
    validStack := 0 ;
  else
    validStack := 1 ;
  end if ;

  if (ora_sysevent='CREATE') then
    wmsys.owm_dynsql_access.no_vm_create_proc(ora_dict_obj_type, ora_dict_obj_name, ora_dict_obj_owner, validStack) ;
  elsif (ora_sysevent='DROP') then
    wmsys.owm_dynsql_access.no_vm_drop_proc(ora_dict_obj_type, ora_dict_obj_name, ora_dict_obj_owner, validStack) ;
  elsif (ora_sysevent in ('ALTER', 'RENAME', 'TRUNCATE')) then
    wmsys.owm_dynsql_access.no_vm_alter_proc(ora_dict_obj_type, ora_dict_obj_name, ora_dict_obj_owner, validStack) ;
  end if ;
end;
/
create or replace trigger wmsys.no_vm_drop_a after drop on database when (ora_dict_obj_type in ('USER'))
begin
  wmsys.owm_dynsql_access.allowDDLOperation('false') ;

  
  
end;
/
begin
  if (:no_vm_ddl_status is null or :no_vm_ddl_status = 'DISABLED') then
    execute immediate 'alter trigger wmsys.no_vm_ddl disable';
  end if ;

  if (:no_vm_drop_status is null or :no_vm_drop_status = 'DISABLED') then
    execute immediate 'alter trigger wmsys.no_vm_drop_a disable';
  end if ;
end;
/
begin
  execute immediate 'drop procedure wmsys.owm_validate' ;

exception when wmsys.ltUtil.no_object then null;
end;
/
create or replace procedure wmsys.validate_owm wrapped 
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
7
48c 2c9
tbThGgkiMDhqe56lPQ77a47M1ggwg/DDLm0FfC/NMZ3gy5lh2eCDHB4bDlS3MBgiXxTGE7eT
ESgCp4fy+P7a8QvGSJ9rrKk7CDRCThlZexf9ie2EznPkcwWcwQ8Pxk+qP44r+ghf/7cquG/i
3gL4aax9hAzTFBz6Dh2biGcL4UcHWd22WyK5j6R3dtI3IYfWCLNba5iO9wdELDnNlrwJayga
5TUkyKI5AcgwYiiD0MuuXdaYw8uUntAMSJCkV5EEfIYspDhqbnoE/d3S8o0vo1+afz7UEeFa
87iKmLe28Uc+wMS2mtKzs5OQ/HJjLCWBUGYMPUvn2oXNDscvYMltpnA2eDH0Ob++gMZ6m7SK
RX4LErYYxEPDyD0SY3Z7F1XlybgabRp0pL1MOp43E5f4CpIyVtBgYDL8k2N9qxOgCWwpdqQO
uCarCtoJV5Lo6WIYeq2JJBXPlomDzdDmQlZJR7Xe0LdgEs5HD0JLCv+KLwf0BVjl5OsveLYj
KE8zyE8CZkKwV/1frthYluKOGWRRCrdXWYxvF1+APYhSC6KWF0w+K4Kh5Vc4bhlhorlKOxuK
f8uV8asPl6Dht0n9DDP+p1aMrhuBDxSx2TYO5Ay2nZAzYoWk2yfRktHi2y5mIcH3vyTRvsbd
qh3l0Hlo33gTQ77fBDjBtDzoPpwAcTsQVnJOGj6l705NmuREnJPzgQ==

/
create or replace procedure sys.validate_owm wrapped 
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
7
7b ba
zL/azQbvltDKyKJF2bLjx2BzMO4wgy5HO8sVZ3SmcNIA6WyC54rDk5n2JYFauxc1TKd0NeGv
LzAQrGo/BtoSdnUYgjSc+HlMh7Ez5HphzCZcMxSzDlEo75Ic49BUIdaUPctLXcx9B+CKyj52
zhRvpos+TCXiUZ44i2/BKbUeDih+dyC8xphmhw==

/
@@?/rdbms/admin/sqlsessend.sql
