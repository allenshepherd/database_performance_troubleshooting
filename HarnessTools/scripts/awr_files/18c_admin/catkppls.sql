Rem
Rem $Header: rdbms/admin/catkppls.sql /main/13 2016/11/17 10:18:49 ssahu Exp $
Rem
Rem catkppls.sql
Rem
Rem Copyright (c) 2006, 2016, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catkppls.sql - Kernel Programmatic Pool Catalog creation
Rem
Rem    DESCRIPTION
Rem      This file defines the catalog views related to the 
Rem      connection pool on the server side.
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catkppls.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catkppls.sql
Rem SQL_PHASE: CATKPPLS
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catptabs.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    ssahu       11/03/16 - bug 24847590
Rem    thbaby      06/12/14 - 18971004: remove INT$ views for OBL cases
Rem    ncolloor    01/28/14 - Bug:18157062 Add max_txn_think_time 
Rem                           to dba_cpool_info
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    thbaby      08/29/13 - 14515351: add INT$ views for sharing=object
Rem    talliu      06/28/13 - Add CDB view for DBA view
Rem    ssahu       05/22/12  - Bug 14096160 -- make cpool$ cdb aware
Rem    surman      03/27/12  - 13615447: Add SQL patching tags
Rem    ssahu       04/07/09  - num_cbrok and max_conn_cbrok to dba_cpool_info
Rem    kamsubra    02/09/07  - add 2 new columns to the table, view
Rem    kamsubra    10/03/06  - bug-5552291 change column name
Rem    kamsubra    06/06/06 -  Updating the default pool values.
Rem    srseshad    06/04/06 - 
Rem    kamsubra    05/19/06 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

-- Create connection pool table
create table cpool$ sharing=object
(
  connection_pool_name      varchar2(128),           /* connection pool name */
  status                    varchar2(16),              /* status of the pool */
  minsize                   number,                   /* min servers in pool */
  maxsize                   number,                   /* max servers in pool */
  incrsize                  number,           /* increment number of servers */
  session_cached_cursors    number,         /* max cached cursors in session */
  inactivity_timeout        number,         /* drop conn after inactive time */
  max_think_time            number,                        /* max think time */
  max_use_session           number,                   /* max # session usage */
  max_lifetime_session      number,             /* max lifetime of a session */
  num_cbrok                 number,        /* # of CBrokers spawned per inst */
  maxconn_cbrok             number,      /* max # of connections per CBroker */
  max_txn_think_time        number                     /* max txn think time */
)
/
create unique index cpool$_ui
  on cpool$ (connection_pool_name)
/

-- Cleanup the table before inserting the default pool row.
truncate table cpool$;

-- Insert the default pool into the pool table.
insert into cpool$ (connection_pool_name, status, minsize, maxsize, incrsize,
                    session_cached_cursors, inactivity_timeout, max_think_time,
                    max_use_session, max_lifetime_session, num_cbrok, 
                    maxconn_cbrok, max_txn_think_time) 
                    values('SYS_DEFAULT_CONNECTION_POOL', 'INACTIVE', 
                           4, 40, 2, 20, 300, 120, 500000, 86400, 1, 40000,0);

-- Create connection pool view 
CREATE OR REPLACE VIEW DBA_CPOOL_INFO CONTAINER_DATA SHARING=OBJECT 
(
  CONNECTION_POOL,
  STATUS,
  MINSIZE, 
  MAXSIZE,
  INCRSIZE,
  SESSION_CACHED_CURSORS,
  INACTIVITY_TIMEOUT,
  MAX_THINK_TIME,
  MAX_USE_SESSION,
  MAX_LIFETIME_SESSION,
  NUM_CBROK,
  MAXCONN_CBROK,
  MAX_TXN_THINK_TIME, 
  CON_ID
)
AS SELECT
  connection_pool_name,
  status,
  minsize,
  maxsize,
  incrsize,
  session_cached_cursors,
  inactivity_timeout,
  max_think_time,
  max_use_session,
  max_lifetime_session,
  num_cbrok,
  maxconn_cbrok,
  max_txn_think_time, 
  0 CON_ID
FROM cpool$
/
COMMENT ON TABLE DBA_CPOOL_INFO IS
'Connection pool info'
/
COMMENT ON COLUMN DBA_CPOOL_INFO.CONNECTION_POOL IS
'Connection pool name'
/
COMMENT ON COLUMN DBA_CPOOL_INFO.STATUS IS
'connection pool status'
/
COMMENT ON COLUMN DBA_CPOOL_INFO.MINSIZE IS
'Minimum number of connections'
/
COMMENT ON COLUMN DBA_CPOOL_INFO.MAXSIZE IS
'Maximum number of connections'
/
COMMENT ON COLUMN DBA_CPOOL_INFO.INCRSIZE IS
'Increment number of connections'
/
COMMENT ON COLUMN DBA_CPOOL_INFO.SESSION_CACHED_CURSORS IS
'Session cached cursors'
/
COMMENT ON COLUMN DBA_CPOOL_INFO.INACTIVITY_TIMEOUT IS
'Timeout for an idle session'
/
COMMENT ON COLUMN DBA_CPOOL_INFO.MAX_THINK_TIME IS
'Max time for client to start activity on an acquired session'
/
COMMENT ON COLUMN DBA_CPOOL_INFO.MAX_USE_SESSION IS
'Maximum life of a session based on usage'
/
COMMENT ON COLUMN DBA_CPOOL_INFO.MAX_LIFETIME_SESSION IS
'Maximum life of a session based on time'
/
COMMENT ON COLUMN DBA_CPOOL_INFO.MAX_TXN_THINK_TIME IS
'Max time for client to start activity on an acquired session with open txn'
/
CREATE OR REPLACE PUBLIC SYNONYM dba_cpool_info FOR dba_cpool_info
/ 
GRANT SELECT ON dba_cpool_info TO select_catalog_role
/


execute CDBView.create_cdbview(false,'SYS','DBA_CPOOL_INFO','CDB_CPOOL_INFO');
grant select on SYS.CDB_CPOOL_INFO to select_catalog_role
/
create or replace public synonym CDB_CPOOL_INFO for SYS.CDB_CPOOL_INFO
/


@?/rdbms/admin/sqlsessend.sql
