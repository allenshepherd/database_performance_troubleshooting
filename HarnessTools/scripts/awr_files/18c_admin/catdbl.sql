Rem
Rem $Header: rdbms/admin/catdbl.sql /main/4 2017/06/26 16:01:18 pjulsaks Exp $
Rem
Rem catdbl.sql
Rem
Rem Copyright (c) 2015, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catdbl.sql - Dblinks Catalog Creation
Rem
Rem    DESCRIPTION
Rem      This file defines the catalog views related to the db links
Rem      on the server side.
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/catdbl.sql 
Rem    SQL_SHIPPED_FILE: rdbms/admin/catdbl.sql 
Rem    SQL_PHASE: CATDBL
Rem    SQL_STARTUP_MODE: NORMAL 
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: rdbms/admin/catptabs.sql 
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    pjulsaks    06/26/17 - Bug 25688154: Uppercase create_cdbview's input
Rem    thbaby      03/13/17 - Bug 25688154: upper case owner name
Rem    rajeekku    11/24/15 - Bug 21795431: Add explicit foreign key constraint
Rem    rajeekku    09/16/15 - Add public synonyms for views 
Rem    rajeekku    01/27/15 - Created
Rem


@@?/rdbms/admin/sqlsessstart.sql

-- Create dblink source table
create table link_sources$ 
(
  source_id number primary key,
  username varchar2(128) not null,
  user# number not null,
  first_logon_time timestamp not null,
  last_logon_time timestamp not null,
  logon_count number not null,
  db_name varchar2(256) not null,
  dbid number not null,
  host_name varchar2(256),
  ip_address varchar2(128),
  protocol varchar2(64),
  db_unique_name varchar2(256)
)
tablespace sysaux
/

-- Create unique index
create unique index link_sources$_ui
  on link_sources$ ( db_name, dbid, username, user#, host_name, 
                     ip_address, protocol, db_unique_name)
tablespace sysaux
/

-- Create index on username 
create index link_sources$_usrnm_idx on link_sources$(username)
tablespace sysaux
/

-- Create dblink logon table
create table link_logons$
(
  logon_time TIMESTAMP NOT NULL,
  source_id number NOT NULL,
  constraint fk_srcid
  foreign key (source_id) 
  references link_sources$(source_id) on delete cascade
) tablespace sysaux
/

-- Create index on source id
create index link_logons$_srcid_idx on link_logons$(source_id)
tablespace sysaux
/

-- Create Sequence for DBLINK Source Id
create sequence link_source_id_seq
  increment by 1
  start with 1
  minvalue 1
  cache 10
/

-- Create external scn activity table
create table external_scn_activity$
(
  operation_timestamp timestamp not null,
  session_id number not null,
  session_serial# number not null,
  audit_sessionid number,
  username varchar2(128) not null,
  inbound_db_link_source_id number,
  outbound_db_link_name varchar2(128),
  outbound_db_link_owner varchar2(128),
  result varchar2(64) not null,
  external_scn number not null,
  scn_adjustment number not null
) tablespace sysaux
/

-- Create View for External SCN activity
CREATE OR REPLACE VIEW DBA_EXTERNAL_SCN_ACTIVITY
(
  OPERATION_TIMESTAMP,
  SESSION_ID,
  SESSION_SERIAL#,
  AUDIT_SESSIONID,
  USERNAME,
  INBOUND_DB_LINK_SOURCE_ID,
  OUTBOUND_DB_LINK_NAME,
  OUTBOUND_DB_LINK_OWNER,
  RESULT,
  EXTERNAL_SCN,
  SCN_ADJUSTMENT
)
AS SELECT
  operation_timestamp,
  session_id,
  session_serial#,
  audit_sessionid,
  username,
  inbound_db_link_source_id,
  outbound_db_link_name,
  outbound_db_link_owner,
  result,
  external_scn,
  scn_adjustment
FROM external_scn_activity$
/
CREATE OR REPLACE PUBLIC SYNONYM dba_external_scn_activity
FOR dba_external_scn_activity
/
GRANT SELECT ON DBA_EXTERNAL_SCN_ACTIVITY TO select_catalog_role
/

-- Create view for DBA_DB_LINK_SOURCES
create or replace view DBA_DB_LINK_SOURCES as
select source_id, db_name, dbid, db_unique_name, host_name, ip_address,
       protocol, username, user#, first_logon_time,
       (select max(llt) from 
          ((select last_logon_time llt from LINK_SOURCES$ 
                   where source_id = X.source_id)
            union
           (select max(logon_time) llt from LINK_LOGONS$ 
                   where source_id = X.source_id))) last_logon_time,
       (select X.logon_count + count(*) from LINK_LOGONS$ 
             where source_id = X.source_id) logon_count 
from LINK_SOURCES$ X
/
COMMENT ON TABLE DBA_DB_LINK_SOURCES IS
'Database link sources'
/
COMMENT ON COLUMN DBA_DB_LINK_SOURCES.SOURCE_ID IS
'Dblink Source Id'
/
COMMENT ON COLUMN DBA_DB_LINK_SOURCES.DB_NAME IS
'DB Name'
/
COMMENT ON COLUMN DBA_DB_LINK_SOURCES.DBID IS
'DB ID'
/
COMMENT ON COLUMN DBA_DB_LINK_SOURCES.DB_UNIQUE_NAME IS
'DB Unique Name'
/
COMMENT ON COLUMN DBA_DB_LINK_SOURCES.HOST_NAME IS
'Host Name'
/
COMMENT ON COLUMN DBA_DB_LINK_SOURCES.IP_ADDRESS IS
'IP Address'
/
COMMENT ON COLUMN DBA_DB_LINK_SOURCES.PROTOCOL IS
'Protocol Used'
/
COMMENT ON COLUMN DBA_DB_LINK_SOURCES.USERNAME IS
'Username'
/
COMMENT ON COLUMN DBA_DB_LINK_SOURCES.USER# IS
'User Number'
/
COMMENT ON COLUMN DBA_DB_LINK_SOURCES.FIRST_LOGON_TIME IS
'First Logon Time'
/
COMMENT ON COLUMN DBA_DB_LINK_SOURCES.LAST_LOGON_TIME IS
'Last Logon Time'
/
COMMENT ON COLUMN DBA_DB_LINK_SOURCES.LOGON_COUNT IS
'Logon Count'
/
CREATE OR REPLACE PUBLIC SYNONYM dba_db_link_sources FOR dba_db_link_sources
/
GRANT SELECT ON DBA_DB_LINK_SOURCES TO select_catalog_role
/


execute SYS.CDBView.create_cdbview(false,'SYS','DBA_DB_LINK_SOURCES',-
'CDB_DB_LINK_SOURCES');
/
create or replace public synonym CDB_DB_LINK_SOURCES for 
SYS.CDB_DB_LINK_SOURCES
/
grant select on CDB_DB_LINK_SOURCES to select_catalog_role ;
/

execute SYS.CDBView.create_cdbview(false,'SYS','DBA_EXTERNAL_SCN_ACTIVITY',-
'CDB_EXTERNAL_SCN_ACTIVITY');
/
create or replace public synonym CDB_EXTERNAL_SCN_ACTIVITY for
SYS.CDB_EXTERNAL_SCN_ACTIVITY ;
/
grant select on CDB_EXTERNAL_SCN_ACTIVITY to select_catalog_role ;
/
  
@?/rdbms/admin/sqlsessend.sql
