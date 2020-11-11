Rem
Rem $Header: rdbms/admin/dpload.sql /main/23 2017/09/20 08:37:49 sdavidso Exp $
Rem
Rem dpload.sql
Rem
Rem Copyright (c) 2013, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dpload.sql - load entire Data Pump utility.
Rem
Rem    DESCRIPTION
Rem      load entire Data Pump utility (including the metadata layer).
Rem
Rem    NOTES
Rem      When there are changes to any of the following Data Pump files it
Rem      is necessary to unload and then reload the entire Data Pump utility.
Rem         src/server/datapump/services/prvtkupc.sql
Rem         src/server/datapump/ddl/prvtmetd.sql
Rem         admin/dbmsdp.sql
Rem         admin/catmeta.sql
Rem         admin/catmettypes.sql
Rem         admin/catmetviews.sql
Rem         admin/catmetinsert.sql
Rem
Rem      This must be executed as SYS.
Rem
Rem    ISSUES
Rem      This script leaves ~100 packages in an invalid state (i.e., presumably
Rem      consumers of datapump/metdata apis). These packages simply need to be
Rem      recompiled. However, running utlrp.sql is 'expensive'.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    sdavidso    08/29/17 - improve perf tracking
Rem    sdipirro    07/17/17 - Fix unsupported reference when used for backports
Rem                           to earlier than 12.1 release
Rem    bwright     06/21/17 - Bug 25651930: Add OBSOLETE, ALL script options
Rem    sdipirro    02/15/17 - Attempt to merge dpload and dpload2 back into a
Rem                           single file
Rem    sdipirro    01/10/17 - Project 68204 - Synchronized software update
Rem    rapayne     06/30/16 - Bug 23640417: in upgrade mode dropping ku$noexp_tab
Rem                           results in an error. Add error to ignorable metadata
Rem                           until a better solution is found.
Rem    rapayne     03/28/16 - Bug 22879025: correctly handle modules which 
Rem                           dont exist is older versions.
Rem    dvekaria    02/12/16 - Bug 22607194: Fix ORA-01775 and PLS-00201 errors.
Rem    sdipirro    11/19/15 - Add prvthdpi and prvtbdpi
Rem    sogugupt    11/26/15 - Bug 22245383: Add metadata SQL_IGNORABLE_ERRORS
Rem    mjangir     11/19/15 - bug 22222697: Move prvth*.plb utilities package
Rem                           header before prvtmet*.plb
Rem    tbhukya     09/02/15 - Bug 21776925: Use '@@' for file run
Rem    dgagne      08/13/15 - Fix loading of prvtdputh.plb
Rem    dgagne      08/11/15 - backout approot txn
Rem    rapayne     07/15/15 - Fix loading of prvtdputh.plb
Rem    tbhukya     06/12/15 - Bug 21137821: Run files directly instead of a
Rem                           script with relative paths.
Rem    rapayne     04/19/15 - lrg 15977957: remove connect string from the
Rem                           generated loadutl script.
Rem    rapayne     03/15/15 - bug 20680092: disable spooling
Rem    tmontgom    10/31/14 - Move prvtkupc.plb the Utilities package header
Rem                           (depends on types in prvtkupc.plb), mimic order
Rem                           of catproc.sql
Rem    surman      10/16/14 - Update phase
Rem    rapayne     05/14/14 - make changes to accommodate readonly admin dirs.
Rem                           Bug 17039620.
Rem    rapayne     09/17/13 - update sql_file_metadata tags as per sqlpatch team
Rem                           request.
Rem    rapayne     07/10/13 - Created
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/dpload.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/dpload.sql
Rem    SQL_PHASE: DPLOAD
Rem    SQL_STARTUP_MODE: NORMAL
Rem    SQL_IGNORABLE_ERRORS: ORA-04043, ORA-00942, ORA-01921, ORA-00955, ORA-14452
Rem    SQL_CALLING_FILE: NONE
Rem    END SQL_FILE_METADATA

SET FEEDBACK 1
SET NUMWIDTH 10
SET LINESIZE 300
SET TRIMSPOOL ON
SET TAB OFF
SET PAGESIZE 300
SET VERIFY off
SET SERVEROUTPUT ON

-- needed for conditional execution of scripts
COLUMN fname new_val file_name

--
-- Take care of locking for SW updates
--
create or replace package ku$_dplock as

  FUNCTION start_sw_update (
                timeout  IN  NUMBER DEFAULT 0
        ) RETURN VARCHAR2;

  PROCEDURE end_sw_update(
                 swlock_handle IN VARCHAR2);


END ku$_dplock;
/
create or replace package body ku$_dplock as

  FUNCTION start_sw_update (
                timeout  IN  NUMBER DEFAULT 0
        ) RETURN VARCHAR2 IS

swlock_ret NUMBER;
swlock_handle VARCHAR2(128);
db_version VARCHAR2(60);

BEGIN
  SELECT substr(dbms_registry.version('CATPROC'), 1, 10)
    INTO db_version
    FROM dual;

  IF (db_version < '12.2.0.2') THEN
    RETURN NULL;
  END IF;

  $if DBMS_DB_VERSION.Version < 12
  $then
    dbms_lock.allocate_unique ('ORA$KU$DATAPUMP_SW_UPDATE',
                               swlock_handle);
  $else
    dbms_lock.allocate_unique_autonomous ('ORA$KU$DATAPUMP_SW_UPDATE',
                                        swlock_handle);
  $end

  swlock_ret := dbms_lock.request (swlock_handle, dbms_lock.x_mode, timeout);
  IF NOT (swlock_ret = 0 OR swlock_ret = 4) THEN
    RETURN NULL;
  END IF;

  RETURN swlock_handle;

  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
END;

  PROCEDURE end_sw_update(
                 swlock_handle IN VARCHAR2
            ) IS

swlock_ret NUMBER;

BEGIN

  BEGIN
    IF swlock_handle IS NOT NULL THEN
      swlock_ret := dbms_lock.release (SUBSTR(swlock_handle,1,128));
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;

END;

END ku$_dplock;
/ 
show errors

--
-- Check specified version for a file
--
create or replace package ku$_dpload as

  FUNCTION for_version (
           v_filename IN VARCHAR2,
           v_begin    IN VARCHAR2 DEFAULT NULL,
           v_until    IN VARCHAR2 DEFAULT NULL)
    RETURN VARCHAR2;

  FUNCTION release_swlock RETURN VARCHAR2;

END ku$_dpload;
/
create or replace package body ku$_dpload as

-- package local store
  fmt1          VARCHAR2(2000) := 'SSSSS.FF';
  fmt2          VARCHAR2(2000) := '09999999.990';
  start_t       NUMBER := to_number(to_char(systimestamp,fmt1));
  last_t        NUMBER := start_t;
  db_version    VARCHAR2(10) := NULL;
  swlock_handle VARCHAR2(128) := NULL;
  swlock_error  BOOLEAN := FALSE;
  prev_filename VARCHAR(1000) := NULL;

  FUNCTION dur return varchar2 IS
    -- local variables
    end_t         NUMBER;
    delta         NUMBER;
  BEGIN
    end_t :=  to_number(to_char(systimestamp,fmt1));
    delta  := end_t - last_t;
    last_t := end_t;
    return to_char(delta,fmt2);
  END;

  FUNCTION for_version (
           v_filename IN VARCHAR2,
           v_begin    IN VARCHAR2 DEFAULT NULL,
           v_until    IN VARCHAR2 DEFAULT NULL)
    RETURN VARCHAR2 AS
  BEGIN
    IF db_version IS NULL
    THEN
      SELECT substr(dbms_registry.version('CATPROC'), 1, 10)
        INTO db_version
        FROM dual;
    END IF;

    IF (db_version >= '12.2.0.2')
    THEN
      IF swlock_handle IS NULL
      THEN
        IF swlock_error
        THEN
          RETURN dbms_registry.nothing_script;          
        ELSE
          swlock_handle := ku$_dplock.start_sw_update(0);
          IF swlock_handle IS NULL
          THEN
            swlock_error := TRUE;
            raise_application_error(-20000,
                         'Data Pump or Metadata API in use - ' ||
                         'Please execute rdbms/admin/dpload.sql script later');
          END IF;
        END IF;
      END IF;
    END IF;

    IF (v_begin is null or db_version >= v_begin) AND
       (v_until is null or db_version < v_until)
    THEN
      IF prev_filename IS NOT NULL THEN
        dbms_output.put_line(dur||' dpload processing '||prev_filename);
      END IF;
      prev_filename :=  v_filename;
      RETURN v_filename;
    ELSE
      dbms_output.put_line(' dpload not running '||v_filename);
      RETURN dbms_registry.nothing_script;
    END IF;
  END for_version;

  FUNCTION release_swlock
    RETURN VARCHAR2 AS
  BEGIN
    IF db_version IS NULL
    THEN
      SELECT substr(dbms_registry.version('CATPROC'), 1, 10)
        INTO db_version
        FROM dual;
    END IF;

    IF (db_version >= '12.2.0.2')
    THEN
      IF swlock_handle IS NOT NULL
      THEN
        swlock_error := FALSE;
        ku$_dplock.end_sw_update(swlock_handle);
        dbms_output.put_line(' dpload released lock ');
      END IF;
    END IF;
    RETURN dbms_registry.nothing_script;
  END release_swlock;

END ku$_dpload;
/ 
show errors

SELECT dbms_registry.nothing_script as fname from dual;

--------------------------------------------------
--     Start by dropping Data Pump's AQ tables
--------------------------------------------------
SELECT ku$_dpload.for_version('catnodpaq.sql', '12.2.0.2') AS fname FROM dual;
@@&file_name

--------------------------------------------------
--     Dropping Data Pump and Metadata objects
--------------------------------------------------
SELECT ku$_dpload.for_version('catnodpobs.sql', '12.2.0.2') AS fname FROM dual;
@@&file_name
SELECT ku$_dpload.for_version('catnodp.sql', v_until=>'12.2.0.2') AS fname FROM dual;
@@&file_name

--------------------------------------------------
--     Start building the pieces back up
--------------------------------------------------
SELECT ku$_dpload.for_version('catdpb.sql') AS fname FROM dual;
@@&file_name

-- Metadata Types (12.2.0.2 and later)
SELECT ku$_dpload.for_version('catmettypes.sql','12.2.0.2') AS fname FROM dual;
@@&file_name
-- Metadata package definitions
SELECT ku$_dpload.for_version('dbmsmeta.sql') AS fname FROM dual;
@@&file_name
SELECT ku$_dpload.for_version('dbmsmetb.sql') AS fname FROM dual;
@@&file_name
SELECT ku$_dpload.for_version('dbmsmetd.sql') AS fname FROM dual;
@@&file_name
SELECT ku$_dpload.for_version('dbmsmeti.sql') AS fname FROM dual;
@@&file_name
SELECT ku$_dpload.for_version('dbmsmetu.sql') AS fname FROM dual;
@@&file_name
SELECT ku$_dpload.for_version('dbmsmet2.sql') AS fname FROM dual;
@@&file_name
SELECT ku$_dpload.for_version('utlcxml.sql') AS fname FROM dual;
@@&file_name
-- other package definitions
SELECT ku$_dpload.for_version('dbmsxml.sql') AS fname FROM dual;
@@&file_name
SELECT ku$_dpload.for_version('dbmsdp.sql') AS fname FROM dual;
@@&file_name
SELECT ku$_dpload.for_version('prvthpp.plb') AS fname FROM dual;
@@&file_name
SELECT ku$_dpload.for_version('prvthpd.plb') AS fname FROM dual;
@@&file_name
SELECT ku$_dpload.for_version('prvthpdi.plb') AS fname FROM dual;
@@&file_name
SELECT ku$_dpload.for_version('prvthpvi.plb') AS fname FROM dual;
@@&file_name
SELECT ku$_dpload.for_version('prvthpv.plb') AS fname FROM dual;
@@&file_name
SELECT ku$_dpload.for_version('prvtkupc.plb') AS fname FROM dual;
@@&file_name
SELECT ku$_dpload.for_version('prvthpu.plb') AS fname FROM dual;
@@&file_name
SELECT ku$_dpload.for_version('prvthpui.plb') AS fname FROM dual;
@@&file_name

-- DBMS_DATAPUMP_UTL package body
select ku$_dpload.for_version('prvthdpi.plb','12.2.0.0') AS fname FROM dual;
@@&file_name

-- Metadata Types (12.0 until 12.2.0.2)
SELECT ku$_dpload.for_version('catmettypes.sql','12.1.0.1',v_until=>'12.2.0.2') AS fname FROM dual;
@@&file_name
-- Metadata Views
SELECT ku$_dpload.for_version('catmetviews.sql','12.1.0.1') AS fname FROM dual;
@@&file_name
-- Metadata Grants 1
SELECT ku$_dpload.for_version('catmetgrant1.sql','12.1.0.1') AS fname FROM dual;
@@&file_name
-- Metadata Grants 2
SELECT ku$_dpload.for_version('catmetgrant2.sql','12.1.0.1') AS fname FROM dual;
@@&file_name
-- Inserts on metadata dictionary tables
SELECT ku$_dpload.for_version('catmetinsert.sql','12.1.0.1') AS fname FROM dual;
@@&file_name

-- Metadata Types, Views, Grants and Inserts (prior to in 12.1.0.1)
SELECT ku$_dpload.for_version('catmeta.sql',v_until=>'12.1.0.1') AS fname FROM dual;
@@&file_name

--
-- Privite package headers
--
SELECT ku$_dpload.for_version('prvthpc.plb') AS fname FROM dual;
@@&file_name
SELECT ku$_dpload.for_version('prvthpci.plb') AS fname FROM dual;
@@&file_name
SELECT ku$_dpload.for_version('prvthpw.plb') AS fname FROM dual;
@@&file_name
SELECT ku$_dpload.for_version('prvthpm.plb') AS fname FROM dual;
@@&file_name
SELECT ku$_dpload.for_version('prvthpfi.plb') AS fname FROM dual;
@@&file_name
SELECT ku$_dpload.for_version('prvthpf.plb') AS fname FROM dual;
@@&file_name

-- DBMS_METADATA_INT package body: Dependent on prvtpbui
select ku$_dpload.for_version('prvtmeti.plb') AS fname FROM dual;
@@&file_name
-- DBMS_METADATA_UTIL package body: dependent on prvthpdi
select ku$_dpload.for_version('prvtmetu.plb') AS fname FROM dual;
@@&file_name
-- DBMS_METADATA_BUILD package body
select ku$_dpload.for_version('prvtmetb.plb') AS fname FROM dual;
@@&file_name
-- DBMS_METADATA_DPBUILD package body
select ku$_dpload.for_version('prvtmetd.plb') AS fname FROM dual;
@@&file_name
-- DBMS_METADATA_DIFF package body
select ku$_dpload.for_version('prvtmet2.plb') AS fname FROM dual;
@@&file_name

-- UTL_XML: PL/SQL wrapper around CORE LPX facility: C-based XML/XSL parsing
select ku$_dpload.for_version('prvtcxml.plb') AS fname FROM dual;
@@&file_name
select ku$_dpload.for_version('prvtbpu.plb') AS fname FROM dual;
@@&file_name
select ku$_dpload.for_version('prvtbpui.plb') AS fname FROM dual;
@@&file_name

-- DBMS_DATAPUMP public package body
select ku$_dpload.for_version('prvtdp.plb') AS fname FROM dual;
@@&file_name

-- DBMS_DATAPUMP_UTL package body (note: pkg def was split out in 12.1)
SELECT ku$_dpload.for_version('prvtdputh.plb','12.1.0.1') AS fname FROM dual;
@@&file_name
select ku$_dpload.for_version('prvtdput.plb') AS fname FROM dual;
@@&file_name

-- DBMS_DATAPUMP_INT definers private package body
SELECT ku$_dpload.for_version('prvtbdpi.plb','12.2.0.0') AS fname FROM dual;
select ku$_dpload.for_version('&file_name') AS fname FROM dual;
@@&file_name
-- KUPC$QUEUE invokers private package body
select ku$_dpload.for_version('prvtbpc.plb') AS fname FROM dual;
@@&file_name
-- KUPC$QUEUE_INT definers private package body
select ku$_dpload.for_version('prvtbpci.plb') AS fname FROM dual;
@@&file_name
-- KUPW$WORKER private package body
select ku$_dpload.for_version('prvtbpw.plb') AS fname FROM dual;
@@&file_name
-- KUPM$MCP private package body: Dependent on prvtbpui
select ku$_dpload.for_version('prvtbpm.plb') AS fname FROM dual;
@@&file_name
-- DBMS_METADATA package body: Dependent on dbmsxml.sql
select ku$_dpload.for_version('prvtmeta.plb') AS fname FROM dual;
@@&file_name
-- KUPF$FILE_INT private package body
select ku$_dpload.for_version('prvtbpfi.plb') AS fname FROM dual;
@@&file_name
-- KUPF$FILE private package body
select ku$_dpload.for_version('prvtbpf.plb') AS fname FROM dual;
@@&file_name
-- KUPP$PROC private package body
select ku$_dpload.for_version('prvtbpp.plb') AS fname FROM dual;
@@&file_name
-- KUPD$DATA invokers private package body
select ku$_dpload.for_version('prvtbpd.plb') AS fname FROM dual;
@@&file_name
-- KUPD$DATA_INT private package body
select ku$_dpload.for_version('prvtbpdi.plb') AS fname FROM dual;
@@&file_name
-- KUPV$FT private package body
select ku$_dpload.for_version('prvtbpv.plb') AS fname FROM dual;
@@&file_name
-- KUPV$FT_INT private package body
select ku$_dpload.for_version('prvtbpvi.plb') AS fname FROM dual;
@@&file_name

-- Create queue tables, default dirobj, and load catmet2.sql
select ku$_dpload.for_version('catdph.sql') AS fname FROM dual;
@@&file_name
select ku$_dpload.for_version('dbmspump.sql') AS fname FROM dual;
@@&file_name
-- one more call, just to get duration printed
select ku$_dpload.for_version(dbms_registry.nothing_script) AS fname FROM dual;

-- Cleanup
SELECT ku$_dpload.release_swlock AS fname FROM dual;
drop package ku$_dpload;
drop package ku$_dplock;
exec dbms_output.put_line('dpload done');
