Rem
Rem $Header: rdbms/admin/xrdud121.sql /st_rdbms_18.0/1 2017/12/05 20:25:20 atomar Exp $
Rem
Rem xrdud121.sql
Rem
Rem Copyright (c) 2014, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      xrdud121.sql - XRD Upgrade Dependent objects from 12.1
Rem
Rem    DESCRIPTION
Rem      This script contains upgrade actions that make use of
Rem      objects loaded by catxrd.sql
Rem
Rem    NOTES
Rem      
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/xrdud121.sql 
Rem    SQL_SHIPPED_FILE: rdbms/admin/xrdud121.sql 
Rem    SQL_PHASE: UPGRADE
Rem    SQL_STARTUP_MODE: UPGRADE
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: rdbms/admin/xrdupgrd.sql
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    atomar      11/19/17 - bug 27107844
Rem    raeburns    10/21/17 - RTI 20225108: Cleanup SQL_METADATA
Rem    raeburns    08/19/16 - add xrdud122 invocation
Rem    raeburns    12/11/14 - XRD dependent upgrade
Rem    raeburns    12/11/14 - Created
Rem

Rem ======================================================
Rem BEGIN XRD dependent upgrade from 12.1
Rem ======================================================



Rem ======================================================
Rem END XRD dependent upgrade from 12.1
Rem ======================================================
Rem =========================================================================
Rem BEGIN upgrade unsharded Queue View
Rem =========================================================================
DECLARE
altvstmt       VARCHAR2(1000);
BEGIN

  FOR cur_rec IN (
                  SELECT t.schema, t.name, t.flags, q.eventid
                  FROM system.aq$_queue_tables t, system.aq$_queues q
                  WHERE t.objno = q.table_objno and NVL(q.sharded,0) =0
                 )
  LOOP
    BEGIN
       BEGIN 
         altvstmt := 'alter view
         '||dbms_assert.enquote_name(cur_rec.schema,FALSE) ||'.'||
         dbms_assert.enquote_name('AQ$_'||cur_rec.name ||'_F',FALSE) || 
         '  compile';
        execute immediate altvstmt;
       EXCEPTION WHEN OTHERS THEN
       null;
       END;

      IF cur_rec.name != 'AQ$DEF$_AQCALL' and cur_rec.name != 'DEF$_AQERROR' THEN
        IF  bitand(cur_rec.flags, 1) = 1 THEN           -- multi-consumer queue
          sys.dbms_prvtaqim.create_base_view(cur_rec.schema, cur_rec.name, cur_rec.flags);
        ELSE                                            -- singleconsumer queue
          sys.dbms_aqadm_sys.create_base_view(cur_rec.schema, cur_rec.name, cur_rec.flags);
        END IF;
      END IF;
    END;
  END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_SYSTEM.ksdwrt(DBMS_SYSTEM.trace_file,
                         'error in unsharded view creation' || sqlcode);
      RAISE;
END;
/
Rem =========================================================================
Rem END upgrade unsharded Queue View
Rem =========================================================================

Rem ======================================================
Rem Upgrade from subsequent releases
Rem ======================================================

@@xrdud122.sql

Rem ======================================================
Rem END xrdud121.sql
Rem ======================================================

