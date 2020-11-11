Rem
Rem $Header: rdbms/admin/catxdbck.sql /main/9 2014/02/20 12:46:26 surman Exp $
Rem
Rem catxdbck.sql
Rem
Rem Copyright (c) 2002, 2014, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catxdbck.sql - XDB install pre-conditions check
Rem
Rem    DESCRIPTION
Rem      This file contains all the preconditions that are required
Rem      for a successful install of Oracle XML DB.
Rem       (-) should be run as sys
Rem
Rem    NOTES
Rem      The current list of conditions that prevent install
Rem       1. XDB user already exists
Rem       2. shared pool size too low
Rem
Rem    INPUTS
Rem       This expects the following three inputs
Rem         1. XDB password
Rem         2. XDB user tablespace
Rem         3. XDB user temporary tablespace.
Rem
Rem        Keep in sync with other parameters to catqm.sql
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catxdbck.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catxdbck.sql
Rem SQL_PHASE: CATXDBCK
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catqm_int
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    surman      01/23/14 - 13922626: Update SQL metadata
Rem    qyu         03/18/13 - Common start and end scripts
Rem    haiswang    02/15/12 - check temp_tbs and res_tbs existing
Rem    thbaby      09/20/11 - remove check for compression
Rem    spetride    04/28/08 - check res_tbs is assm
Rem    najain      03/15/04 - flush shared pool in the beginning
Rem    spannala    06/13/03 - removing set statements
Rem    thoang      03/06/03 - #2831402 lower SHARED_POOL_SIZE to work on NT 
Rem    sichandr    01/22/03 - sichandr_bug-2679778
Rem    sichandr    12/16/02 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

define xdb_pass    = &1
define res_tbs     = &2
define temp_tbs    = &3

Rem This frees all freeable memory which can be freed (from sga)

alter system flush shared_pool;
alter system flush shared_pool;
alter system flush shared_pool;
alter system flush shared_pool;

declare

  SHARED_POOL_SIZE  number := 6*1024*1024;
  usrcnt            number;
  tbscomp           varchar2(10);
  spbytes           number;
  segmgmt           varchar2(6);
  tempcnt           number;
  rescnt            number;

  e_user_exists     exception;
  e_comp_tmptbs     exception;
  e_low_sharedpool  exception;
  e_not_assm        exception;
  e_temp_tbs_notexists   exception;
  e_res_tbs_notexists    exception;

begin

  /* check if XDB user already exists */
  select count(*) into usrcnt from dba_users where username = 'XDB';
  if usrcnt > 0 then
    raise e_user_exists;
  end if;

  /* check if tablespace &temp_tbs does not exist*/
  select count(*) into tempcnt from dba_tablespaces where tablespace_name =  upper('&temp_tbs');
  if tempcnt = 0 then
    raise e_temp_tbs_notexists;
  end if;

  /* check if tablespace &res_tbs does not exist*/
  select count(*) into rescnt from dba_tablespaces where tablespace_name =  upper('&res_tbs');
  if rescnt = 0 then
    raise e_res_tbs_notexists;
  end if;


  select def_tab_compression into tbscomp from dba_tablespaces
  where tablespace_name = upper('&temp_tbs');
  if tbscomp = 'ENABLED' then
    raise e_comp_tmptbs;
  end if;

  /* check shared pool size */
  select bytes into spbytes from v$sgastat
  where pool = 'shared pool' and name = 'free memory';
  dbms_output.put_line ('spbytes ' || spbytes);
  if spbytes < SHARED_POOL_SIZE then
    raise e_low_sharedpool;
  end if;

  /* check if XDB tablespace is ASSM */
  if (:usesecfiles = 'YES') then
    select segment_space_management into segmgmt from dba_tablespaces 
    where tablespace_name = upper('&res_tbs');
    if (segmgmt != 'AUTO') then
      raise e_not_assm;
    end if;
  end if;
  
exception
  
  when e_user_exists then
    raise_application_error(-20000, 'XDB User already exists');
  when e_comp_tmptbs then
    raise_application_error(-20002, 'Compressed temporary tablespace ' ||
                                    '&temp_tbs cannot be used');
  when e_low_sharedpool then
    raise_application_error(-20003, 'Shared pool size too low');

  when e_not_assm then
    raise_application_error(-20004, 'Tablespace &res_tbs is not ASSM ');

  when e_temp_tbs_notexists then
    raise_application_error(-20005, 'Tablespace &temp_tbs does not exist');

  when e_res_tbs_notexists then
    raise_application_error(-20006, 'Tablespace &res_tbs does not exist');

end;
/

@?/rdbms/admin/sqlsessend.sql
