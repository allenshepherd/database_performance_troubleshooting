Rem
Rem $Header: rdbms/admin/bugfix16173764.sql /main/1 2014/05/15 18:19:32 sdas Exp $
Rem
Rem bugfix16173764.sql
Rem
Rem Copyright (c) 2014, Oracle and/or its affiliates. All rights reserved.
Rem
Rem    NAME
Rem      bugfix16173764.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/bugfix16173764.sql 
Rem    SQL_SHIPPED_FILE: rdbms/admin/bugfix16173764.sql 
Rem    SQL_PHASE: INSTALL
Rem    SQL_STARTUP_MODE: NORMAL 
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: NONE
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    sdas        05/03/14 - fix for bug 16173764
Rem    sdas        05/03/14 - Created
Rem

SET ECHO ON
SET FEEDBACK 1
SET NUMWIDTH 10
SET LINESIZE 80
SET TRIMSPOOL ON
SET TAB OFF
SET PAGESIZE 100

@@?/rdbms/admin/sqlsessstart.sql

column rset_owner format a20
column rset_name format a25
column rset_pack format a30

column owner format a20
column object_name format a25

--
-- detect RSET packagaes (if INVALID, possibly) containing the ADD_RULE procedure
--

set serverout on

-- bad RSETs listed in EXFSYS.RLM$RULESET
 select rset_owner, rset_name, rset_pack 
   from EXFSYS.RLM$RULESET 
  where RSET_PACK IN (
   select object_name 
     from DBA_PROCEDURES 
    where procedure_name='ADD_RULE'
      and owner != 'SYS'
      and object_type = 'PACKAGE'
      and object_name like 'RLM$RULECLS\_PACK\_%' escape '\'
 );

-- VALID RSET packages containing the bad procedure
 select owner, object_name 
   from DBA_PROCEDURES
  where procedure_name='ADD_RULE'
    and owner != 'SYS'
    and object_name like 'RLM$RULECLS\_PACK\_%' escape '\'
    and object_type= 'PACKAGE';

-- INVALID RSET packages (that may contain the bad procedure)
 select owner, object_name 
   from DBA_OBJECTS
  where status = 'INVALID'
    and owner != 'SYS'
    and object_name like 'RLM$RULECLS\_PACK\_%' escape '\'
    and object_type= 'PACKAGE';

--
-- fix
--

create or replace
PROCEDURE SYS.fix_bug_16173764 as
  EXFSYS_RSET_TAB_exists     number;

  c_pau                      INTEGER; -- parse_as_user cursor
  dummy                      number;

  dyn_sql_stmt               varchar2(32767);
  dss                        varchar2(32767);

  TYPE rcursor_type is       REF CURSOR;
  c                          rcursor_type; -- cursor for finding the relevant rule_sets
  rs_owner                   varchar2(4000);
  rs_name                    varchar2(4000);
  rs_pack                    varchar2(4000);
  rs_owner_id                number;

  q_rset_pack_name           varchar2(4000);

  RSET_NAME_PLACEHOLDER      constant varchar2(100) := '<RSET_NAME>';
  NL                         constant char(1) := chr(10);
BEGIN
  sys.dbms_output.put_line('Rules Manager: starting processing of RSETs');

  -- check if EXFSYS.RLM$RULESET table exists
  select count(*) into EXFSYS_RSET_TAB_exists 
    from DBA_OBJECTS
   where owner = 'EXFSYS' and object_name='RLM$RULESET' and object_type='TABLE';

  -- if table EXFSYS.RLM$RULESET exists ... re-create the bad RSETs to replace the bad procedure with a good one
  IF (EXFSYS_RSET_TAB_exists > 0) THEN
    dyn_sql_stmt := '
BEGIN 
  exfsys.dbms_rlmgr_utl.set_parameter(''RLM$RECRTRULECLSPACK'', ' || RSET_NAME_PLACEHOLDER || '); 
  sys.dbms_output.put_line(''PROCESSING as user='' || sys_context(''USERENV'', ''CURRENT_USER'') || '': rset_name='' || ' || RSET_NAME_PLACEHOLDER || ');
  sys.dbms_output.put_line(''DONE: '' || sys_context(''USERENV'', ''CURRENT_USER'') || '' rset_name='' || ' || RSET_NAME_PLACEHOLDER || ');
  EXCEPTION when others then
    sys.dbms_output.put_line(''ERROR: processing as user='' || sys_context(''USERENV'', ''CURRENT_USER'') || '': rset_name='' || ' || RSET_NAME_PLACEHOLDER || ' || ''['' || dbms_utility.format_error_backtrace || '']'');
END;
' ;

    OPEN c for
'select rset_owner, rset_name, rset_pack 
   from EXFSYS.RLM$RULESET
  where RSET_PACK IN (
         select object_name 
           from DBA_PROCEDURES 
          where procedure_name=''ADD_RULE''
            and owner != ''SYS''
            and object_type = ''PACKAGE''
            and object_name like ''RLM$RULECLS\_PACK\_%'' escape ''\''
       )';

    LOOP
      FETCH c INTO rs_owner, rs_name, rs_pack;
      EXIT WHEN c%NOTFOUND;

      sys.dbms_output.put_line('Start processing: Owner=' || rs_owner || ' Name=' || rs_name || ' Package=' || rs_pack);

      begin
        select user_id into rs_owner_id from all_users where username = rs_owner;
        exception 
          when no_data_found then
            sys.dbms_output.put_line('NO_DATA_FOUND: cannot find username=' || rs_owner);
            continue; -- skip the current iteration
          when others then
            sys.dbms_output.put_line('Error getting info: owner=' || rs_owner || ' name=' || rs_name ||
              NL || SQLERRM || ' [' || 
              NL || dbms_utility.format_error_backtrace || 
              NL || ']');
            continue; -- skip the current iteration
      end;
      sys.dbms_output.put_line('... Owner=' || rs_owner || ' (user_id=' || rs_owner_id || ')');

      -- use replace to get the pl/sql block for parse_as_user and execute
      dss := replace(dyn_sql_stmt,RSET_NAME_PLACEHOLDER,sys.dbms_assert.enquote_literal(rs_name));
      sys.dbms_output.put_line('dss=' || dss);

      -- do parse_as_user and execute
      begin
        c_pau := sys.dbms_sys_sql.open_cursor;
        sys.dbms_sys_sql.parse_as_user(c_pau, dss, dbms_sql.NATIVE, rs_owner_id);
        dummy := dbms_sql.execute(c_pau);
        sys.dbms_sys_sql.close_cursor(c_pau);

        EXCEPTION when others then
          sys.dbms_output.put_line('Error processing: owner=' || rs_owner || ' name=' || rs_name ||
            NL || SQLERRM || ' [' || 
            NL || dbms_utility.format_error_backtrace || 
            NL || ']');
          sys.dbms_sys_sql.close_cursor(c_pau);
          continue; -- skip the current iteration
      end;
    END LOOP;
  END IF;

  -- finally, close the cursor (if open)
  if c%ISOPEN then CLOSE c; end if;

  -- at this time, all bad RSETs in the list have been re-created

  -- Next, purge packages for any unlisted (orphan), or could-not-be-fixed, RSETs
  -- drop all VALID RSET packages having an ADD_RULE procedure, if any
  for idx in (
    select owner, object_name 
      from DBA_PROCEDURES
     where procedure_name='ADD_RULE'
       and owner != 'SYS'
       and object_name like 'RLM$RULECLS\_PACK\_%' escape '\'
       and object_type= 'PACKAGE' )
  LOOP
    q_rset_pack_name := 
      sys.dbms_assert.enquote_name(idx.owner,FALSE) || 
      '.' ||
      sys.dbms_assert.enquote_name(idx.object_name,FALSE);
    begin
      sys.dbms_output.put_line('dropping bad PACKAGE: ' || q_rset_pack_name);
      execute immediate 'DROP PACKAGE ' || q_rset_pack_name;
      sys.dbms_output.put_line('... DONE => DROPPED bad PACKAGE: ' || q_rset_pack_name);
      EXCEPTION when others then
        sys.dbms_output.put_line('Failed to DROP bad PACKAGE ' || q_rset_pack_name || NL || SQLERRM);
        continue; -- skip current bad package
    end;
  END LOOP;

  -- drop all the INVALID RSET packages (procedure names are not available for INVALID objects)
  -- dropping the package is enough for the bugfix, other INVALID objects may be dropped manually, if necessary
  for idx in (
    select owner, object_name 
      from DBA_OBJECTS
     where status = 'INVALID'
       and owner != 'SYS'
       and object_name like 'RLM$RULECLS\_PACK\_%' escape '\'
       and object_type= 'PACKAGE' )
  LOOP
    q_rset_pack_name := 
      sys.dbms_assert.enquote_name(idx.owner,FALSE) ||
      '.' ||
      sys.dbms_assert.enquote_name(idx.object_name,FALSE);
    begin
      sys.dbms_output.put_line('dropping INVALID PACKAGE: ' || q_rset_pack_name);
      execute immediate 'DROP PACKAGE ' || q_rset_pack_name;
      EXCEPTION when others then
        sys.dbms_output.put_line('Failed to DROP INVALID PACKAGE ' || q_rset_pack_name || NL || SQLERRM);
        continue; -- skip current INVALID package
    end;
    sys.dbms_output.put_line('... DONE=> DROPPED INVALID PACKAGE: ' || q_rset_pack_name);
  END LOOP;

  EXCEPTION when others then
    if c%ISOPEN then CLOSE c; end if;

    sys.dbms_output.put_line('Rules Manager: Error processing RSETs' ||
      NL || SQLERRM || ' [' || 
      NL || dbms_utility.format_error_backtrace || 
      NL || ']');
END;
/
show errors

-- Apply the fix
set serverout on
exec SYS.fix_bug_16173764;

--
-- verify status after applying the fix: no rows should be returned by the queries below
--

set serverout on

-- bad RSETs listed in EXFSYS.RLM$RULESET
 select rset_owner, rset_name, rset_pack 
   from EXFSYS.RLM$RULESET 
  where RSET_PACK IN (
   select object_name 
     from DBA_PROCEDURES 
    where procedure_name='ADD_RULE'
      and owner != 'SYS'
      and object_type = 'PACKAGE'
      and object_name like 'RLM$RULECLS\_PACK\_%' escape '\'
 );

-- VALID RSET packages containing the bad procedure
 select owner, object_name 
   from DBA_PROCEDURES
  where procedure_name='ADD_RULE'
    and owner != 'SYS'
    and object_name like 'RLM$RULECLS\_PACK\_%' escape '\'
    and object_type= 'PACKAGE';

-- INVALID RSET packages (that may contain the bad procedure)
 select owner, object_name 
   from DBA_OBJECTS
  where status = 'INVALID'
    and owner != 'SYS'
    and object_name like 'RLM$RULECLS\_PACK\_%' escape '\'
    and object_type= 'PACKAGE';

@?/rdbms/admin/sqlsessend.sql
