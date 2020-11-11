Rem
Rem $Header: rdbms/admin/dbfs_drop_filesystem.sql /main/8 2017/05/28 22:46:04 stanaya Exp $
Rem
Rem dbfs_drop_filesystem.sql
Rem
Rem Copyright (c) 2009, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbfs_drop_filesystem.sql - DBFS drop filesystem
Rem
Rem    DESCRIPTION
Rem      DBFS drop filesystem script
Rem      Usage: sqlplus <dbfs_user> @dbfs_drop_filesystem.sql [ -all | <store__name> ]
Rem            
Rem    NOTES
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/dbfs_drop_filesystem.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/dbfs_drop_filesystem.sql
Rem    SQL_PHASE: UTILITY
Rem    SQL_STARTUP_MODE: NORMAL
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    END SQL_FILE_METADATA
Rem    
Rem    MODIFIED   (MM/DD/YY)
Rem    siteotia    06/02/15 - Bug 21143599: Rewrote the script
Rem    weizhang    09/24/12 - bug 14666696: fix sql injection security bug
Rem    xihua       10/11/10 - Bug 10104462: improved method for dropping all
Rem                           file systems
Rem    weizhang    03/11/10 - bug 9220947: tidy up
Rem    weizhang    11/19/09 - Support default fsDrop FORCE
Rem    weizhang    06/12/09 - Package name change
Rem    weizhang    04/06/09 - Created
Rem

SET ECHO OFF
SET VERIFY OFF
SET FEEDBACK OFF
SET TAB OFF
SET SERVEROUTPUT ON

-- abstract store name
define store_name = &1


declare

  type dbfs_curstype is ref cursor;

  css         dbfs_curstype;
  csm         dbfs_curstype;
  fs_name     varchar2(32);
  
begin

  if('&&1' != '-all') then

    --store name to be dropped is explicitly provided
    
    dbms_dbfs_sfs.dropFilesystem('&&1');
    
    commit;

  else

    -- "-all" option is used

    open css for
      select store_name from table(dbms_dbfs_sfs.listFilesystems);
    
    loop

      fetch css into fs_name;
      EXIT WHEN css%NOTFOUND;
      
      dbms_dbfs_sfs.dropFilesystem(fs_name); 
    
      commit;

    end loop;
    
    close css;

  end if;

exception

  when others then
    rollback;
    dbms_output.put_line('ERROR: ' || sqlcode || ' msg: ' || sqlerrm);
    raise;

end;
/

show errors;

undefine store_name
