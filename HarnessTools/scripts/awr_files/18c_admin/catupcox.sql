Rem
Rem $Header: rdbms/admin/catupcox.sql /main/4 2017/03/20 12:21:11 raeburns Exp $
Rem
Rem catupcox.sql
Rem
Rem Copyright (c) 2012, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catupcox.sql - CAT UPgrade Create Oracle-supplied eXternal tables
Rem
Rem    DESCRIPTION
Rem      Create external tables containing oracle-supplied bit info for
Rem      obj$ and user$. 
Rem      External tables to be read by catuposb.sql.
Rem
Rem    NOTES
Rem      To be run as SYS.
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catupcox.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catupcox.sql
Rem SQL_PHASE: UPGRADE
Rem SQL_STARTUP_MODE: UPGRADE
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catuposb.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    raeburns    03/08/17 - Bug 25616909: Use UPGRADE for SQL_PHASE
Rem    cmlim       03/30/15 - bug 19367547: extra: use NOLOGFILE for read-only
Rem                           oracle home
Rem    cmlim       04/03/13 - bug 16443441: use disable_directory_link_check so
Rem                           that fetch over symlinks on windows will not fail
Rem    cmlim       11/02/12 - bug 14763826: create oracle-supplied info from
Rem                           external tables
Rem    cmlim       11/02/12 - Created
Rem


REM ***********************************************************************

REM ***********************************************************************
REM create directory object in $ORACLE_HOME/rdbms/admin
REM directory object for creating external tables
REM ***********************************************************************

DECLARE

  homeDir     varchar2(500);  -- ORACLE_HOME path
  upgXTDir    varchar2(500);  -- UPGrade eXternal Table DIRectory
  upgXTLogDir varchar2(500);  -- UPGrade eXternal Table LOG DIRectory
  platform    v$database.platform_name%TYPE;  -- platform

BEGIN

  -- upgrade data directory object is $ORACLE_HOME/rdbms/admin
  DBMS_SYSTEM.GET_ENV('ORACLE_HOME', homeDir);

  -- Determine PLATFORM value
  EXECUTE IMMEDIATE 'SELECT NLS_UPPER(platform_name) FROM v$database'
     INTO platform;

  --
  -- Setup upgXTDir ($ORACLE_HOME/rdbms/admin)
  -- note: this platform-specific code based from utluppkg.sql
  --
  IF INSTR(platform, 'WINDOWS') != 0 THEN
    -- Windows, use '\'
    upgXTDir := homeDir || '\rdbms\admin';
  ELSIF INSTR(platform, 'VMS') != 0 THEN
    -- VMS, use [] and .
    upgXTDir := REPLACE(homeDir || '[rdbms.admin]', '][', '.');
  ELSE
    -- Unix and z/OS, '/'
    upgXTDir := homeDir || '/rdbms/admin';
  END IF;

  --
  -- Setup upgXTLogDir ($ORACLE_HOME/rdbms/log)
  --
  IF INSTR(platform, 'WINDOWS') != 0 THEN
    -- Windows, use '\'
    upgXTLogDir := homeDir || '\rdbms\log';
  ELSIF INSTR(platform, 'VMS') != 0 THEN
    -- VMS, use [] and .
    upgXTLogDir := REPLACE(homeDir || '[rdbms.log]', '][', '.');
  ELSE
    -- Unix and z/OS, '/'
    upgXTLogDir := homeDir || '/rdbms/log';
  END IF;

  -- create upgXTDir directory object
  EXECUTE IMMEDIATE 'create or replace directory upg_xt_dir as ''' ||
                     upgXTDir || ''''; 


end;  -- end of create directory objects upg_xt_dir
/



REM ***********************************************************************

REM ***********************************************************************
REM 1. Create oracle-supplied OBJects eXTernal table 
Rem    (contains oracle-supplied bit info from 12c obj$)
REM ***********************************************************************

begin
  execute immediate 'drop table sys.objxt';
exception
    when others then
      if sqlcode = -942
        then null;
      else
        raise;
      end if;
end;
/

create table sys.objxt
(
   owner     varchar2(128),
   name      varchar2(128),
   subname   varchar2(128),
   type#     number
)
organization external
(
  type ORACLE_LOADER
  DEFAULT DIRECTORY UPG_XT_DIR
  access parameters
  (
    records delimited by '\n'
    nologfile
    nobadfile
    nodiscardfile
    disable_directory_link_check
    characterset 'US7ASCII'
    fields terminated by ','
    missing field values are null
  )
  location ('upobjxt.lst')
)
reject limit unlimited
;


REM ***********************************************************************
REM 2. Create oracle-supplied USERs eXTernal table
Rem    (contains oracle-supplied bit info from 12c obj$)
REM ***********************************************************************
begin
  execute immediate 'drop table sys.userxt';
exception
    when others then
      if sqlcode = -942
        then null;
      else
        raise;
      end if;
end;
/

create table sys.userxt
(
   name   varchar2(128)
)
organization external
(
  type ORACLE_LOADER
  DEFAULT DIRECTORY UPG_XT_DIR
  access parameters
  (
    records delimited by '\n'
    nologfile
    nobadfile
    nodiscardfile
    disable_directory_link_check
    characterset 'US7ASCII'
    fields terminated by ','
    missing field values are null
  )
  location ('upuserxt.lst')
)
reject limit unlimited
;




