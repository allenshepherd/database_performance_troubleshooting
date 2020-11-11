Rem
Rem $Header: rdbms/admin/dbmsdbv.sql /main/4 2014/02/20 12:45:41 surman Exp $
Rem
Rem dbmsdbv.sql
Rem
Rem Copyright (c) 2002, 2014, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbmsdbv.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/dbmsdbv.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/dbmsdbv.sql
Rem SQL_PHASE: DBMSDBV
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catpdbms.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    bemeng      12/19/03 - make this a fixed package
Rem    bemeng      10/30/02 - bemeng_dbv_support_osm
Rem    amganesh    10/14/02 - 
Rem    amganesh    10/12/02 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

create or replace PACKAGE dbms_dbverify authid current_user IS

-- DE-HEAD     <- tell SED where to cut when generating fixed package

  PROCEDURE dbv2(fname       IN   varchar2
                ,start_blk   IN   binary_integer
                ,end_blk     IN   binary_integer
                ,blocksize   IN   binary_integer
                ,output      IN OUT  varchar2
                ,error       IN OUT  varchar2
                ,stats       IN OUT  varchar2);

  -- Verify blocks in datafile
  --
  --   Input parameters
  --     fname - Datafile to scan 
  --     start - Start block address
  --     end - End block address
  --     blocksize - Logical block size
  --     outout - Output message buffer
  --     error - Error message buffer
  --     stats - Stats message buffer

-------------------------------------------------------------------------------
  pragma TIMESTAMP('2004-03-29:18:43:00');
-------------------------------------------------------------------------------

END;

-- CUT_HERE    <- tell sed where to chop off the rest

/

@?/rdbms/admin/sqlsessend.sql
