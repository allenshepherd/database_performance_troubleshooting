Rem
Rem $Header: rdbms/admin/catnoexf.sql /main/8 2017/05/28 22:46:02 stanaya Exp $
Rem
Rem catnoexf.sql
Rem
Rem Copyright (c) 2002, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catnoexf.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/catnoexf.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/catnoexf.sql
Rem    SQL_PHASE: UTILITY
Rem    SQL_STARTUP_MODE: NORMAL
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    END SQL_FILE_METADATA
Rem    
Rem    MODIFIED   (MM/DD/YY)
Rem    pyam        01/12/16 - RTI 18548742: drop validate_exf, validate_rul
Rem    sdas        05/07/14 - add EXCEPTION to synonym drop loop
Rem    jerrede     01/02/13 - Add the Removal of Rules Manager
Rem    ayalaman    02/25/08 - cleanup public synonyms
Rem    ayalaman    04/19/04 - cleanup export dependeny actions 
Rem    ayalaman    11/19/02 - registry entries
Rem    ayalaman    09/26/02 - ayalaman_expression_filter_support
Rem    ayalaman    09/06/02 - 
Rem    ayalaman    09/06/02 - Created
Rem

REM
REM Drop Rules Manager if present.  Rules Manager must be
REM done first before we drop Expression Filter.
REM
COLUMN  :rul_name NEW_VALUE rul_file NOPRINT;
VARIABLE rul_name VARCHAR2(30)
BEGIN

   IF (dbms_registry.is_loaded('RUL') IS NOT NULL) THEN
       :rul_name := '@catnorul.sql';                -- RUL exists in DB
   ELSE
       :rul_name := dbms_registry.nothing_script;   -- No RUL
   END IF;

END;
/

SELECT :rul_name FROM DUAL;
@&rul_file 


REM 
REM Drop the Expression Filter user with cascade option 
REM 
EXECUTE dbms_registry.removing('EXF');
drop user exfsys cascade;

REM Drop objects owned by SYS
drop package sys.exf$dbms_expfil_syspack;
drop procedure sys.validate_rul;
drop procedure sys.validate_exf;
begin
  -- since this is a fresh install, delete any actions left behind --
  -- from past installations --
  delete from sys.expdepact$ where schema = 'EXFSYS'
    and package = 'DBMS_EXPFIL_DEPASEXP';
  delete from sys.exppkgact$ where package = 'DBMS_EXPFIL_DEPASEXP'
    and schema = 'EXFSYS';
end;
/

-- drop public synonyms -- 
column synonym_name format a30
column object_name format a30
column status format a10

select synonym_name from all_synonyms where owner = 'PUBLIC' and table_owner = 'EXFSYS' order by 1; 

select object_name, status from all_objects 
 where object_type='SYNONYM' and owner='PUBLIC' 
   and (object_name LIKE 'EXF$%' or object_name LIKE 'RLM$%' or object_name like '%_EXPFIL%' or object_name='EVALUATE' or
        object_name LIKE '%_RLMGR%' or object_name LIKE '_%RLM4J%')
 order by 1;

--set serverout on

declare
  cursor cur1 is 
select object_name, status from all_objects 
 where object_type='SYNONYM' and owner='PUBLIC' 
   and (object_name LIKE 'EXF$%' or 
        object_name LIKE 'RLM$%' or 
        object_name like '%\_EXPFIL%' escape '\' or 
        object_name='EVALUATE' or
        object_name LIKE '%\_RLMGR%' escape '\' or 
        object_name LIKE '%\_RLM4J%' escape '\');
  info_msg     varchar2(32767);
  error_msg    varchar2(32767);
begin
  for c1 in cur1 loop
  begin
     info_msg := 'EXFSYS SYNONYM DROP: ' || c1.object_name || ' status=' || c1.status;
     EXECUTE IMMEDIATE 'drop public synonym '||dbms_assert.enquote_name(c1.object_name, false);
     sys.dbms_output.put_line('done: ' || info_msg);
  EXCEPTION
    WHEN OTHERS THEN 
      error_msg := 'catnoexf.sql: FAILED: ' || info_msg || ' SQLERRM=' || SQLERRM;
      SYS.DBMS_SYSTEM.KSDWRT(SYS.DBMS_SYSTEM.TRACE_FILE, error_msg);
      sys.dbms_output.put_line(error_msg);
  end;
  end loop; 
end;
/

--set serverout off

execute sys.dbms_java.dropjava('-s rdbms/jlib/ExprFilter.jar');

begin
  dbms_registry.removed('EXF');
exception 
  when others then null;
end;
/

