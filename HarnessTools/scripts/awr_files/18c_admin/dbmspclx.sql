Rem
Rem $Header: rdbms/admin/dbmspclx.sql /main/4 2016/08/11 11:26:41 drosash Exp $
Rem
Rem dbmspclx.sql
Rem
Rem Copyright (c) 2005, 2016, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbmspclx.sql - DBMS_PCLXUTIL
Rem
Rem    DESCRIPTION
Rem    dbms_pclxutil         - intra-partition parallelism for creating 
Rem                            partition-wise local index.
Rem
Rem    NOTES
Rem      DBMS_PCXLUTIL was originally located in dbmsutil.sql
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/dbmspclx.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/dbmspclx.sql
Rem SQL_PHASE: DBMSPCLX
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catpdbms.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    drosash     06/29/16 - 23598713: Wrapper for original dbms_pclxutil
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    lvbcheng    08/17/05 - lvbcheng_split_dbms_util
Rem    lvbcheng    07/29/05 - moved here from dbmsutil.sql
Rem    pamor       12/04/02 - pclxutil: remove private interfaces from public
Rem    rsujitha    10/15/98 -  Add dbms_pclxutil package
Rem

@@?/rdbms/admin/sqlsessstart.sql

Rem ********************************************************************
Rem THESE PACKAGES MUST NOT BE MODIFIED BY THE CUSTOMER.  DOING SO
Rem COULD CAUSE INTERNAL ERRORS AND SECURITY VIOLATIONS IN THE
Rem RDBMS.  SPECIFICALLY, THE PSD* AND EXECUTE_SQL ROUTINES MUST NOT BE
Rem CALLED DIRECTLY BY ANY CLIENT AND MUST REMAIN PRIVATE TO THE PACKAGE BODY.
Rem ********************************************************************

create or replace package dbms_pclxutil authid current_user as
  ------------
  --  OVERVIEW
  --  
  --  a package that provides intra-partition parallelism for creating 
  --  partition-wise local index.
  --
  --  SECURITY
  --
  --  The execution privilege is granted to PUBLIC. The procedure
  --  build_part_index in this package run under the caller security. 
  --

  ----------------------------

  ----------------------------

  procedure build_part_index (
     jobs_per_batch in number default 1,
     procs_per_job  in number default 1,
     tab_name       in varchar2 default null,
     idx_name       in varchar2 default null,
     force_opt      in boolean default FALSE); 
  --
  -- jobs_per_batch: #jobs to be created (1 <= job_count <= #partitions)
  --
  -- procs_per_job:  #slaves per job (1 <= degree <= max_slaves)
  --
  -- tab_name:       name of the partitioned table (an exception is 
  --                 raised if the table does not exist or not 
  --                 partitioned)
  --
  -- idx_name:       name given to the local index (an exception is 
  --                 raised if a local index is not created on the 
  --                 table tab_name)
  --
  -- force_opt:      if TRUE force rebuild of all partitioned indices; 
  --                 otherwise rebuild only the partitions marked 
  --                 'UNUSABLE'
  --

end dbms_pclxutil;
/
create or replace public synonym dbms_pclxutil for sys.dbms_pclxutil
/
grant execute on dbms_pclxutil to public
/


@?/rdbms/admin/sqlsessend.sql
