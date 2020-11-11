Rem
Rem $Header: rdbms/admin/catnoalr.sql /main/5 2017/05/28 22:46:02 stanaya Exp $
Rem
Rem catnoalr.sql
Rem
Rem Copyright (c) 2002, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catnoalr.sql - Remove server ALeRt schema
Rem
Rem    DESCRIPTION
Rem      Catalog script for server alert.  Used to drop server alert schema.
Rem
Rem    NOTES
Rem      Must be run when connected as SYSDBA.
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/catnoalr.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/catnoalr.sql
Rem    SQL_PHASE: UTILITY
Rem    SQL_STARTUP_MODE: NORMAL
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    END SQL_FILE_METADATA
Rem    
Rem    MODIFIED   (MM/DD/YY)
Rem    ilistvin    03/03/11 - changes for CDB
Rem    jxchen      01/26/04 - Fix bug 339578: use "FORCE" option to drop 
Rem    aime        04/25/03 - aime_going_to_main
Rem    jxchen      04/02/03 - Move threshold table to sysaux
Rem    jxchen      01/21/03 - Drop synonym for v$ views
Rem    jxchen      11/14/02 - jxchen_alrt1
Rem    jxchen      11/13/02 - Add dbms_server_alert package
Rem    jxchen      11/11/02 - Add alert views
Rem    jxchen      10/24/02 - Add alert threshold table
Rem    jxchen      10/16/02 - Created
Rem

DROP TABLE sys.wri$_alert_outstanding;
DROP TABLE sys.wri$_alert_history;
DROP SEQUENCE sys.wri$_alert_sequence;

BEGIN
dbms_aqadm.stop_queue('SYS.ALERT_QUE');
dbms_aqadm.drop_queue('SYS.ALERT_QUE');
dbms_aqadm.drop_queue_table('SYS.ALERT_QT');
commit;
END;
/

DECLARE
  agent SYS.AQ$_AGENT;
BEGIN
  agent := SYS.AQ$_AGENT('server_alert', NULL, NULL);
  dbms_aqadm.drop_aq_agent('server_alert');
END;
/

DROP TYPE sys.alert_type FORCE;

DROP TABLE sys.wri$_alert_threshold;

DROP TYPE sys.threshold_type force;

DROP TYPE sys.threshold_type_set force;

DROP TABLE sys.wri$_alert_threshold_log;

DROP SEQUENCE sys.wri$_alert_thrslog_sequence;

DROP PUBLIC SYNONYM dba_outstanding_alerts;

DROP VIEW sys.dba_outstanding_alerts;

DROP PUBLIC SYNONYM dba_alert_history;

DROP VIEW sys.dba_alert_history;

DROP PUBLIC SYNONYM dba_alert_history_detail;

DROP VIEW sys.dba_alert_history_detail;

DROP PACKAGE sys.dbms_server_alert;

DROP PACKAGE sys.dbms_server_alert_prvt;

DROP VIEW sys.dba_thresholds;

DROP PUBLIC SYNONYM dba_thresholds;

DROP VIEW v_$alert_types;

DROP VIEW v_$threshold_types;

DROP PUBLIC SYNONYM v$alert_types;

DROP PUBLIC SYNONYM v$threshold_types;

