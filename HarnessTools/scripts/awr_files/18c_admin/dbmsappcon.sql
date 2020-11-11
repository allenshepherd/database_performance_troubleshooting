Rem
Rem $Header: rdbms/admin/dbmsappcon.sql /main/8 2017/08/22 14:05:41 thbaby Exp $
Rem
Rem dbmsappcon.sql
Rem
Rem Copyright (c) 2015, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbmsappcon.sql - dbms application container utility package
Rem
Rem    DESCRIPTION
Rem      This package contains procedures to alter sharing attribute of 
Rem      common objects
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/dbmsappcon.sql 
Rem    SQL_SHIPPED_FILE: rdbms/admin/dbmsappcon.sql 
Rem    SQL_PHASE: DBMSAPPCON
Rem    SQL_STARTUP_MODE: NORMAL 
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: rdbms/admin/catpdbms.sql
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    thbaby      08/21/17 - Bug 26654326: add SYNC_RETRY and SYNC_ERROR_* 
Rem    tianlli     06/21/17 - Bug 26242432: remove remove_link
Rem    thbaby      05/04/17 - Bug 26002723: add set_sharing_none
Rem    pjulsaks    04/25/17 - Bug 25773902: rename file and 
Rem                                         add get_application_diff function
Rem    thbaby      05/10/16 - Bug 23254735: add SET_USER_EXPLICIT()
Rem    jaeblee     02/05/16 - Bug 22524245: mark package as invoker's rights
Rem    akruglik    01/26/16 - (22132084) declare set_ext_data_linked procedure
Rem    akruglik    12/02/15 - Bug 21953121: define package
Rem                           DBMS_PDB_ALTER_SHARING
Rem    akruglik    12/02/15 - Created
Rem

SET ECHO ON
SET FEEDBACK 1
SET NUMWIDTH 10
SET LINESIZE 80
SET TRIMSPOOL ON
SET TAB OFF
SET PAGESIZE 100

@@?/rdbms/admin/sqlsessstart.sql

create or replace package dbms_pdb_alter_sharing authid current_user is

  procedure set_metadata_linked(schema_name  IN varchar2, 
                                object_name  IN varchar2,
                                namespace    IN number,
                                edition_name IN varchar2 DEFAULT NULL);

  -- This procedure should be used to mark an object as Metadata linked in 
  -- an App Root. It is intended to be used in migration cases where an 
  -- application was already installed in a PDB or a non-CDB, where there was 
  -- no support for application containers.

  procedure set_data_linked(schema_name  IN varchar2, 
                            object_name  IN varchar2,
                            namespace    IN number,
                            edition_name IN varchar2 DEFAULT NULL);
  -- This procedure should be used to mark an object as Data linked in 
  -- an App Root. It is intended to be used in migration cases where an 
  -- application was already installed in a PDB or a non-CDB, where there was 
  -- no support for application containers.

  procedure set_ext_data_linked(schema_name  IN varchar2, 
                                object_name  IN varchar2,
                                namespace    IN number,
                                edition_name IN varchar2 DEFAULT NULL);
  -- This procedure should be used to mark an object as Extended Data linked in
  -- an App Root. It is intended to be used in migration cases where an 
  -- application was already installed in a PDB or a non-CDB, where there was 
  -- no support for Application Containers.

  procedure set_sharing_none(schema_name  IN varchar2, 
                             object_name  IN varchar2,
                             namespace    IN number,
                             edition_name IN varchar2 DEFAULT NULL);
  -- This procedure should be used to set sharing=none status on an 
  -- object in an App Root. It is intended to be used in migration 
  -- cases where an application was already installed in a PDB or a 
  -- non-CDB, where there was no support for application containers.

  procedure set_user_explicit(user_name IN varchar2);
  -- This procedure should be used to mark a user as an explicit 
  -- Application Common user. It is intended to be used in migration 
  -- cases where an application was already installed in a PDB or a 
  -- non-CDB, where there was no support for application containers.
  -- When such a PDB or non-CDB is converted into an Application Root
  -- via clone or plugin, the users would have been marked as implicit 
  -- Application Common users. This procedure should be invoked within
  -- an Application Begin/End block.

  procedure set_role_explicit(role_name IN varchar2);
  -- This procedure should be used to mark a role as an explicit 
  -- Application Common role. It is intended to be used in migration 
  -- cases where an application was already installed in a PDB or a 
  -- non-CDB, where there was no support for application containers.
  -- When such a PDB or non-CDB is converted into an Application Root
  -- via clone or plugin, the roles would have been marked as implicit 
  -- Application Common roles. This procedure should be invoked within
  -- an Application Begin/End block.

  procedure set_profile_explicit(profile_name IN varchar2);
  -- This procedure should be used to mark a profile as an explicit 
  -- Application Common profile. It is intended to be used in migration 
  -- cases where an application was already installed in a PDB or a 
  -- non-CDB, where there was no support for application containers.
  -- When such a PDB or non-CDB is converted into an Application Root
  -- via clone or plugin, the profiles would have been marked as implicit 
  -- Application Common profiles. This procedure should be invoked within
  -- an Application Begin/End block.
end;
/

grant execute on dbms_pdb_alter_sharing to execute_catalog_role
/

create or replace public synonym dbms_pdb_alter_sharing 
  for sys.dbms_pdb_alter_sharing
/

create or replace package dbms_pdb_app_con authid current_user is

  -- Return Codes from Sync Error Handler should be one of these values:
  -- 
  -- SYNC_ERROR_NOT_OK
  -- SYNC_ERROR_OK_ALWAYS
  -- SYNC_ERROR_OK_ON_RETRY
  -- 
  -- The above constants have to be kept in sync with KPDBFD_ERROR macros.
  -- 
  -- KPDBFD_ERROR_NOT_OK
  -- KPDBFD_ERROR_OK
  -- KPDBFD_ERROR_OK_RETRY

  -- Error encountered by Application Sync is NOT acceptable
  SYNC_ERROR_NOT_OK      CONSTANT NUMBER := 1;

  -- Error encountered by Application Sync is acceptable whether resync or not
  SYNC_ERROR_OK_ALWAYS   CONSTANT NUMBER := 2;

  -- Error encountered by Application Sync is acceptable during resync
  SYNC_ERROR_OK_ON_RETRY CONSTANT NUMBER := 3;

  -- Sync Error Handler can check the value of parameter RESYNC against 
  -- this constant to know if the handler is being invoked as part of a
  -- retry of Application Sync.
  SYNC_RETRY CONSTANT NUMBER := 1;

end;
/

grant execute on dbms_pdb_app_con to execute_catalog_role
/

create or replace public synonym dbms_pdb_app_con 
  for sys.dbms_pdb_app_con
/

-- This function return JSON describing the difference of two APPROOT
-- (Local and Remote). JSON format is as followed
-- {
--   "Application Name" : "<APPLICATION_NAME>", 
--   "Status"           : "<STATUS>", 
--   "Version"          : {
--                          "Status" : "<STATUS>",
--                          "Local"  : {["<STMT1>","<STMT2>",...,""]}, 
--                          "Remote" : {["<STMT1>","<STMT2>",...,""]}
--                        }, 
--   "Patch"            : {
--                          "Status" : "<STATUS>",
--                          "Local"  : {["<STMT1>","<STMT2>",...,""]}, 
--                          "Remote" : {["<STMT1>","<STMT2>",...,""]}
--                        }
-- }
-- <STATUS> - SAME | DIFF | Local is subset | Remote is subset
--   NOTE: For Patch's case it can also be 'DIFF ORDER'
-- Each <STMT> in "Local" or "Remote" tag is an application statement 
-- from DBA_APP_STATEMENTS that doesn't appear in opposing instance.
create or replace function get_application_diff(app_name IN VARCHAR2, 
                                            dblink   IN VARCHAR2)
  RETURN CLOB as
  json                             clob;
  ver_loc_minus_rem                clob;
  ver_rem_minus_loc                clob;
  ver_loc_is_subset                boolean := TRUE;
  ver_rem_is_subset                boolean := TRUE;
  ver_json                         clob;
  patch_loc_minus_rem              clob;
  patch_rem_minus_loc              clob;
  patch_loc_is_subset              boolean := TRUE;
  patch_rem_is_subset              boolean := TRUE;
  patch_json                       clob;
  sqlstmt                          varchar2(4000);
  cur                              SYS_REFCURSOR;
  app_stmt                         clob;
  c_count                          number;
  dblink_c                         varchar2(128);

begin
  dblink_c := DBMS_ASSERT.QUALIFIED_SQL_NAME(dblink);

  sqlstmt := 'create table tmp_app_stmt as (select APP_NAME, ' ||
  'cast(APP_STATEMENT as varchar2(4000)) APP_STATEMENT, STATEMENT_ID, ' ||
  'VERSION_NUMBER, PATCH_NUMBER from DBA_APP_STATEMENTS@' || dblink_c || ')';

  execute immediate sqlstmt;

  -- APPLICATION_VERSIONS
  sqlstmt := 'select cast(APP_STATEMENT as varchar2(4000)) from ' ||
  'DBA_APP_STATEMENTS where cast(APP_STATEMENT as varchar2(4000)) not in ' ||
  '(select APP_STATEMENT from tmp_app_stmt where APP_NAME=:1 and ' ||
  'PATCH_NUMBER = 0) and APP_NAME=:1 and PATCH_NUMBER=0 order by STATEMENT_ID';
  --dbms_output.put_line(sqlstmt);

  ver_loc_minus_rem := '{[';
  open cur for sqlstmt using app_name, app_name;
  loop
    fetch cur into app_stmt;
    exit when cur%NOTFOUND;

    ver_loc_minus_rem := ver_loc_minus_rem || '"' || app_stmt || '", ';
    ver_loc_is_subset := FALSE;
  end loop;
  close cur;

  ver_loc_minus_rem := ver_loc_minus_rem || '""]}';

  sqlstmt := 'select APP_STATEMENT from tmp_app_stmt ' ||
  'where cast(APP_STATEMENT as varchar2(4000)) not in (select ' ||
  'cast(APP_STATEMENT as varchar2(4000)) from DBA_APP_STATEMENTS ' || 
  'where APP_NAME=:1 and PATCH_NUMBER = 0) and APP_NAME=:1 and ' ||
  'PATCH_NUMBER=0 order by STATEMENT_ID';
  --dbms_output.put_line(sqlstmt);

  ver_rem_minus_loc := '{[';
  open cur for sqlstmt using app_name, app_name;
  loop
    fetch cur into app_stmt;
    exit when cur%NOTFOUND;

    ver_rem_minus_loc := ver_rem_minus_loc || '"' || app_stmt || '", ';
    ver_rem_is_subset := FALSE;
  end loop;
  close cur;

  ver_rem_minus_loc := ver_rem_minus_loc || '""]}';

  if (ver_loc_is_subset and ver_rem_is_subset) then
    ver_json := '{"Status" : "SAME", ';
  elsif (ver_loc_is_subset) then
    ver_json := '{"Status" : "Local is subset", ';
  elsif (ver_rem_is_subset) then
    ver_json := '{"Status" : "Remote is subset", ';
  else
    ver_json := '{"Status" : "DIFF", ';
  end if;

  ver_json := ver_json || '"Local" : '  || ver_loc_minus_rem || ', ' || 
                          '"Remote" : ' || ver_rem_minus_loc || '}';

  --dbms_output.put_line(ver_json);

  -- APPLICATION PATCHES
  sqlstmt := 'select stmt from (select cast(APP_STATEMENT as ' ||
  'varchar2(4000)) stmt, row_number() over (order by STATEMENT_ID) r, ' ||
  'APP_NAME, PATCH_NUMBER from DBA_APP_STATEMENTS where APP_NAME=:1 and ' ||
  'PATCH_NUMBER>0) where (stmt, r) not in (select APP_STATEMENT, ' ||
  'row_number() over (order by STATEMENT_ID) from '||
  'tmp_app_stmt where APP_NAME=:1 and PATCH_NUMBER>0)  order by r';
  --dbms_output.put_line(sqlstmt);

  patch_loc_minus_rem := '{[';
  open cur for sqlstmt using app_name, app_name;
  loop
    fetch cur into app_stmt;
    exit when cur%NOTFOUND;

    patch_loc_minus_rem := patch_loc_minus_rem || '"' || app_stmt || '", ';
    patch_loc_is_subset := FALSE;
  end loop;
  close cur;

  patch_loc_minus_rem := patch_loc_minus_rem || '""]}';

  sqlstmt := 'select stmt from (select APP_STATEMENT stmt, row_number() ' ||
  'over (order by STATEMENT_ID) r, APP_NAME, PATCH_NUMBER from tmp_app_stmt '||
  'where APP_NAME=:1 and PATCH_NUMBER>0) where (stmt, r) not in (select ' ||
  'cast(APP_STATEMENT as varchar2(4000)),  row_number() over (order by ' ||
  'STATEMENT_ID) from DBA_APP_STATEMENTS where APP_NAME=:1 and ' ||
  'PATCH_NUMBER>0) order by r';
  --dbms_output.put_line(sqlstmt);

  patch_rem_minus_loc := '{[';
  open cur for sqlstmt using app_name, app_name;
  loop
    fetch cur into app_stmt;
    exit when cur%NOTFOUND;

    patch_rem_minus_loc := patch_rem_minus_loc || '"' || app_stmt || '", ';
    patch_rem_is_subset := FALSE;
  end loop;
  close cur;

  patch_rem_minus_loc := patch_rem_minus_loc || '""]}';

  if (patch_loc_is_subset and patch_rem_is_subset) then
    patch_json := '{"Status" : "SAME",';
  elsif (patch_loc_is_subset) then
    patch_json := '{"Status" : "Local is subset",';
  elsif (patch_rem_is_subset) then
    patch_json := '{"Status" : "Remote is subset",';
  else
    -- Can be DIFF ORDER
    sqlstmt := 'select count(*) from DBA_APP_STATEMENTS where ' ||
    'cast(APP_STATEMENT as varchar2(4000)) not in (select APP_STATEMENT ' ||
    'from tmp_app_stmt where APP_NAME=:1 and PATCH_NUMBER>0) and ' ||
    'APP_NAME=:1 and PATCH_NUMBER>0 order by STATEMENT_ID';

    execute immediate sqlstmt into c_count using app_name, app_name;

    if (c_count > 0) then
      patch_json := '{"Status" : "DIFF",';
    else
      patch_json := '{"Status" : "DIFF ORDER",';
    end if;
  end if;

  patch_json := patch_json || '"Local" : '  || patch_loc_minus_rem || ', ' || 
                          '"Remote" : ' || patch_rem_minus_loc || '}';

  --dbms_output.put_line(patch_json);

  -- Create the JSON result
  json := '{"Application Name" : "' || app_name || '", "Status" : ';
  if (ver_loc_is_subset and ver_rem_is_subset and 
      patch_loc_is_subset and patch_rem_is_subset) then
    json := json || '"SAME", ';
  elsif (ver_loc_is_subset and patch_loc_is_subset) then
    json := json || '"Local is subset", ';
  elsif (ver_rem_is_subset and patch_rem_is_subset) then
    json := json || '"Remote is subset", ';
  else
    json := json || '"DIFF", ';
  end if;

  json := json || '"Version" : ' || ver_json || ', "Patch" : ' || patch_json || '}';

  execute immediate 'drop table tmp_app_stmt';

  return json;

end;
/

@?/rdbms/admin/sqlsessend.sql
