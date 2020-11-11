Rem
Rem $Header: rdbms/admin/catqitab.sql /main/13 2015/11/13 03:18:10 dkoppar Exp $
Rem
Rem catqitab.sql
Rem
Rem Copyright (c) 2011, 2015, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catqitab.sql - Creation of tables
Rem
Rem    DESCRIPTION
Rem      Creation of queryable patch inventory tables.
Rem
Rem    NOTES
Rem      .
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catqitab.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catqitab.sql
Rem SQL_PHASE: CATQITAB
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catqptabs.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    dkoppar     11/03/15 - #21143559 long identifier support
Rem    dkoppar     09/12/15 - add RO support for BigSql
Rem    dkoppar     12/26/14 - #19938082 add type of buglist
Rem    ssathyan    03/13/14 - 18288676:DISABLE_DIRECTORY_LINK
Rem    ssathyan    03/23/14 - 18403520: Update readsize
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    dkoppar     12/09/13 - #17665104 embed patch uid
Rem    tbhukya     09/24/12 - Bug 14664194 : Use bat file for preprocessor
Rem    tbhukya     07/13/12 - create new tables with xml implementation.
Rem    dkoppar     07/01/12 - add xml support
Rem    tbhukya     05/08/12 - Bugs 13973746, 13964278 and add opatch_inst_job
Rem    surman      04/12/12 - 13615447: Add SQL patching tags
Rem    tbhukya     12/19/11 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

variable opatch_log_dir varchar2(1000);
variable opatch_script_dir varchar2(1000);


-- Create directories for log, script and xml file
BEGIN
  select value into :opatch_log_dir
               from v$parameter
               where name='user_dump_dest';

  --dbms_system.get_env( 'ORACLE_HOME', :opatch_script_dir );
  :opatch_script_dir := :opatch_script_dir || '/QOpatch';

  -- single quotes in :opatch_log_dir and :opatch_script_dir
  -- would need extra quoting
  execute immediate 'CREATE OR REPLACE directory opatch_log_dir AS ''' ||
                     :opatch_log_dir || '''';
  execute immediate 'CREATE OR REPLACE directory opatch_script_dir AS ''' ||
                     :opatch_script_dir || '''';
END;
/


CREATE TABLE opatch_xml_inv
(
     xml_inventory      CLOB
)
ORGANIZATION EXTERNAL
(
    TYPE oracle_loader
    DEFAULT DIRECTORY opatch_script_dir
    ACCESS PARAMETERS
    (
      RECORDS DELIMITED BY NEWLINE CHARACTERSET UTF8 
      DISABLE_DIRECTORY_LINK_CHECK
      READSIZE 8388608 
      preprocessor opatch_script_dir:'qopiprep.bat'
      BADFILE opatch_script_dir:'qopatch_bad.bad'
      LOGFILE opatch_log_dir:'qopatch_log.log'
      FIELDS TERMINATED BY 'UIJSVTBOEIZBEFFQBL'
      MISSING FIELD VALUES ARE NULL
      REJECT ROWS WITH ALL NULL FIELDS
      (
        xml_inventory    CHAR(100000000)
      )
    )
    LOCATION(opatch_script_dir:'qopiprep.bat')
  )
  PARALLEL 1
  REJECT LIMIT UNLIMITED;

CREATE TABLE opatch_xinv_tab
(
     xml_inventory      CLOB
)
TABLESPACE SYSAUX;


CREATE TABLE opatch_inst_job
       (
         inst_id    NUMBER primary key,
         node_name  VARCHAR2(128) NOT NULL,
         inst_name  VARCHAR2(128) NOT NULL,
         inst_job   VARCHAR2(128) NOT NULL
       )
       TABLESPACE SYSAUX;

CREATE TABLE opatch_inst_patch
       (
          nodeName VARCHAR2(128),
          patchNum VARCHAR2(128),
          patchUId VARCHAR2(128)
       )
       TABLESPACE SYSAUX;


CREATE TABLE opatch_sql_patches 
      (
       patch        VARCHAR2(128),
       patch_uid    VARCHAR2(128),
       node_names   VARCHAR2(32000),
       all_node     CHAR(1)
      ) 
      TABLESPACE SYSAUX;

create type opatch_node_array as VARRAY(100) of varchar(128);
/

create or replace type qopatch_list is varray(64) of varchar(128);
/

@?/rdbms/admin/sqlsessend.sql
