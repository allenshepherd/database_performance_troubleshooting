Rem
Rem $Header: rdbms/admin/catptt.sql /main/1 2017/02/06 12:18:01 prakumar Exp $
Rem
Rem catptt.sql
Rem
Rem Copyright (c) 2017, Oracle and/or its affiliates. All rights reserved.
Rem
Rem    NAME
Rem      catptt.sql 
Rem
Rem    DESCRIPTION
Rem      Creates the catalog views for Private Temporary Tables(PTT)
Rem
Rem    NOTES
Rem      Must be run while connectd as SYS 
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/catptt.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/catptt.sql
Rem    SQL_PHASE: CATPTT
Rem    SQL_STARTUP_MODE: NORMAL
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    SQL_CALLING_FILE: rdbms/admin/catalog.sql
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    prakumar    01/04/17 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

----------------------------------------------------------------------
-- DBA_PRIVATE_TEMP_TABLES
----------------------------------------------------------------------
CREATE OR REPLACE VIEW dba_private_temp_tables
(sid, serial#, inst_id, owner, table_name, tablespace_name,
 duration, num_rows, blocks, avg_row_len, last_analyzed, 
 txn_id, save_point_num) AS
SELECT session_num sid, session_serial_num serial#, inst_id, 
       owner, table_name, tablespace_name, duration,
       num_rows, blocks, avg_row_len, last_analyzed,
       txn_id, save_point_num 
FROM gv$private_temp_tables;

GRANT SELECT ON dba_private_temp_tables TO SELECT_CATALOG_ROLE;
CREATE OR REPLACE PUBLIC SYNONYM dba_private_temp_tables FOR
sys.dba_private_temp_tables;

COMMENT ON TABLE dba_private_temp_tables IS
'Description of the Private Temp Table accessible to the DBA'
/

COMMENT ON COLUMN dba_private_temp_tables.sid IS
'Session id of the session which created the PTT'
/

COMMENT ON COLUMN dba_private_temp_tables.serial# IS
'Session Serial number of the session which created the PTT'
/

COMMENT ON COLUMN dba_private_temp_tables.inst_id IS
'Instance id of the session which created the PTT'
/

COMMENT ON COLUMN dba_private_temp_tables.owner IS
'Owner name of the PTT'
/

COMMENT ON COLUMN dba_private_temp_tables.table_name IS
'Private temporary table name'
/

COMMENT ON COLUMN dba_private_temp_tables.tablespace_name IS
'Private temporary table''s tablespace name'
/

COMMENT ON COLUMN dba_private_temp_tables.duration IS
'Private temporary table''s duration(i.e SESSION or TRANSACTION)'
/

COMMENT ON COLUMN dba_private_temp_tables.num_rows IS
'Number of rows in PTT when analyzed using gather_table_stats'
/

COMMENT ON COLUMN dba_private_temp_tables.blocks IS
'Number of blocks used by PTT '
/

COMMENT ON COLUMN dba_private_temp_tables.avg_row_len IS
'Average row length'
/

COMMENT ON COLUMN dba_private_temp_tables.last_analyzed IS
'Timestamp of last gather_table_stats call'
/

COMMENT ON COLUMN dba_private_temp_tables.txn_id IS
'Transaction Id of the Transaction duration PTT'
/

COMMENT ON COLUMN dba_private_temp_tables.save_point_num IS
'Save point number of  the Transaction duration PTT'
/

----------------------------------------------------------------------
-- CDB_PRIVATE_TEMP_TABLES 
----------------------------------------------------------------------
EXECUTE CDBView.create_cdbview(false, 'SYS', 'DBA_PRIVATE_TEMP_TABLES', 'CDB_PRIVATE_TEMP_TABLES');

GRANT SELECT ON SYS.cdb_private_temp_tables TO SELECT_CATALOG_ROLE
/
CREATE OR REPLACE PUBLIC SYNONYM cdb_private_temp_tables FOR sys.cdb_private_temp_tables
/

----------------------------------------------------------------------
-- USER_PRIVATE_TEMP_TABLES
----------------------------------------------------------------------
CREATE OR REPLACE VIEW user_private_temp_tables
(sid, serial#, owner, table_name, tablespace_name,
 duration, num_rows, blocks, avg_row_len, last_analyzed, 
 txn_id, save_point_num) AS
SELECT session_num sid, session_serial_num serial#, 
       owner, table_name, tablespace_name, duration, 
       num_rows, blocks, avg_row_len, last_analyzed, 
       txn_id, save_point_num 
FROM v$private_temp_tables 
WHERE current_sess=1;

COMMENT ON TABLE user_private_temp_tables IS
'Description of the Private Temp Tables in the current session '
/

COMMENT ON COLUMN user_private_temp_tables.sid IS
'Session id of the session which created the PTT'
/

COMMENT ON COLUMN user_private_temp_tables.serial# IS
'Session Serial number of the session which created the PTT'
/

COMMENT ON COLUMN user_private_temp_tables.owner IS
'Owner name of the PTT'
/

COMMENT ON COLUMN user_private_temp_tables.table_name IS
'Private temporary table name'
/

COMMENT ON COLUMN user_private_temp_tables.tablespace_name IS
'Private temporary table''s tablespace name'
/

COMMENT ON COLUMN user_private_temp_tables.duration IS
'Private temporary table''s duration(i.e SESSION or TRANSACTION)'
/

COMMENT ON COLUMN user_private_temp_tables.num_rows IS
'Number of rows in PTT when analyzed using gather_table_stats'
/

COMMENT ON COLUMN user_private_temp_tables.blocks IS
'Number of blocks used by PTT '
/

COMMENT ON COLUMN user_private_temp_tables.avg_row_len IS
'Average row length'
/

COMMENT ON COLUMN user_private_temp_tables.last_analyzed IS
'Timestamp of last gather_table_stats call'
/

COMMENT ON COLUMN user_private_temp_tables.txn_id IS
'Transaction Id of the Transaction duration PTT'
/

COMMENT ON COLUMN user_private_temp_tables.save_point_num IS
'Save point number of  the Transaction duration PTT'
/

GRANT READ ON user_private_temp_tables TO PUBLIC;
CREATE OR REPLACE PUBLIC SYNONYM user_private_temp_tables FOR 
sys.user_private_temp_tables;

@?/rdbms/admin/sqlsessend.sql
 
