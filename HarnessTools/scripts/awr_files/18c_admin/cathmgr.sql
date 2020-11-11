Rem
Rem $Header: rdbms/admin/cathmgr.sql /main/5 2016/08/03 18:54:01 wbattist Exp $
Rem
Rem cathmgr.sql
Rem
Rem Copyright (c) 2014, 2016, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      cathmgr.sql - Table and views for Hang Manager parameters
Rem
Rem    DESCRIPTION
Rem      This table is used for storing Hang Manager parameters. Each row of
Rem      this table represents a parameter. Each parameter has a value and the
Rem      time it was set and the previous value and the time when it was set.
Rem
Rem      Update to this table is done through dbms_hang_manager package.
Rem
Rem      Table will be populated with parameter defaults when database
Rem      is started.
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/cathmgr.sql 
Rem    SQL_SHIPPED_FILE: rdbms/admin/cathmgr.sql 
Rem    SQL_PHASE: CATHMGR
Rem    SQL_STARTUP_MODE: NORMAL 
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: rdbms/admin/catptabs.sql 
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    wbattist    08/01/16 - bug 24369603 - add missing create public synonym
Rem                           for DBA_HANG_MANAGER_PARAMETERS
Rem    cqi         08/12/15 - bug 21621708: change the parameter table column
Rem                           names
Rem    cqi         06/04/15 - remove initial settings of parameters
Rem    cqi         01/08/15 - fix bug 20327985: add a dba and cdb view for
Rem                           hang manager parameters
Rem    cqi         09/17/14 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

CREATE TABLE hang_manager_parameters sharing=object
(  name             VARCHAR2(40),
   current_value    VARCHAR2(20),
   current_time     DATE,
   previous_value   VARCHAR2(20),
   previous_time    DATE,
   CONSTRAINT name_pk PRIMARY KEY (name)
)
/

COMMENT ON TABLE hang_manager_parameters IS
'Hang Manager parameters'
/

COMMENT ON COLUMN hang_manager_parameters.name IS
'Hang Manager parameter name'
/

COMMENT ON COLUMN hang_manager_parameters.current_value IS
'Hang Manager parameter current value'
/

COMMENT ON COLUMN hang_manager_parameters.current_time IS
'Hang Manager parameter update time of the current value'
/

COMMENT ON COLUMN hang_manager_parameters.previous_value IS
'Hang Manager parameter previous value'
/

COMMENT ON COLUMN hang_manager_parameters.previous_time IS
'Hang Manager parameter update time of the previous value'
/

/* DBA view of the hang_manager_parameters table */
CREATE OR REPLACE VIEW dba_hang_manager_parameters sharing=object
(
  name,                                                    /* Parameter name */
  current_value,                                  /* Current parameter value */
  current_time,                    /* Update time of current parameter value */
  previous_value,                                /* Previous parameter value */
  previous_time                   /* Update time of previous parameter value */
)
AS
SELECT name, current_value, current_time, previous_value, previous_time
FROM hang_manager_parameters;
/

COMMENT ON TABLE dba_hang_manager_parameters IS
'Hang Manager parameters'
/

COMMENT ON COLUMN dba_hang_manager_parameters.name IS
'Hang Manager parameter name'
/

COMMENT ON COLUMN dba_hang_manager_parameters.current_value IS
'Hang Manager parameter current value'
/

COMMENT ON COLUMN dba_hang_manager_parameters.current_time IS
'Hang Manager parameter update time of the current value'
/

COMMENT ON COLUMN dba_hang_manager_parameters.previous_value IS
'Hang Manager parameter previous value'
/

COMMENT ON COLUMN dba_hang_manager_parameters.previous_time IS
'Hang Manager parameter update time of the previous value'
/

grant select on DBA_HANG_MANAGER_PARAMETERS to select_catalog_role
/

CREATE OR REPLACE PUBLIC SYNONYM dba_hang_manager_parameters
   FOR sys.dba_hang_manager_parameters
/

begin
  CDBView.create_cdbview(false,'SYS','DBA_HANG_MANAGER_PARAMETERS',
                                     'CDB_HANG_MANAGER_PARAMETERS');
end;
/

grant select on CDB_HANG_MANAGER_PARAMETERS to select_catalog_role
/

CREATE OR REPLACE PUBLIC SYNONYM cdb_hang_manager_parameters
   FOR sys.cdb_hang_manager_parameters
/

@?/rdbms/admin/sqlsessend.sql
