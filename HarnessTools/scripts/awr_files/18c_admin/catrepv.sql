Rem
Rem catrepv.sql
Rem
Rem Copyright (c) 2005, 2016, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catrepv.sql - XML Reporting framework View definitions
Rem
Rem    DESCRIPTION
Rem      This file contains the view definitions for the xml reporting
Rem      framework catalog
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catrepv.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catrepv.sql
Rem SQL_PHASE: CATREPV
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catptabs.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    shjoshi     05/18/16 - bug 23279437: Derive No con_id in wrp tables
Rem    shjoshi     04/08/16 - bug 23059287: Use con_id from wrp tables
Rem    skayoor     11/30/14 - Proj 58196: Change Select priv to Read Priv
Rem    thbaby      06/12/14 - 18971004: remove INT$ views for OBL cases
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    talliu      06/28/13 - Add CDB view for DBA view
Rem    shjoshi     10/09/12 - Add con_id to dba_hist_reports*
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    shjoshi     02/24/12 - Add dba_hist_reports_control
Rem    shjoshi     10/08/11 - Add dbid to dba_hist_reports* views
Rem    shjoshi     09/28/11 - Add views for auto report capture
Rem    yxie        04/21/11 - change wri$_rept_files to wri$_emx_files
Rem    pbelknap    08/02/06 - add report and component ids to views
Rem    pbelknap    07/25/05 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

-------------------------------------------------------------------------------
--                           public view definitions                         --
-------------------------------------------------------------------------------

CREATE OR REPLACE VIEW REPORT_COMPONENTS
  AS SELECT c.id component_id, c.name component_name, 
            c.description component_description, 
            r.id report_id, r.name report_name, 
            r.description report_description, 
            f.name schema_filename,
            XMLType(f.data) schema_data
     FROM   wri$_rept_components c,
            wri$_rept_reports r,
            wri$_emx_files f
     WHERE  c.id = r.component_id AND 
            r.schema_id = f.id (+)
/

CREATE OR REPLACE PUBLIC SYNONYM REPORT_COMPONENTS FOR REPORT_COMPONENTS
/

GRANT READ ON REPORT_COMPONENTS TO PUBLIC
/

CREATE OR REPLACE VIEW REPORT_FORMATS
  AS SELECT c.id component_id,
            c.name component_name,
            r.id report_id, 
            r.name report_name,
            fo.name format_name,
            fo.description description,
            DECODE(fo.type, 1, 'XSLT',
                            2, 'Text',
                            3, 'Custom') type,
            f.name xslt_filename,
            XMLType(f.data) xslt_data,
            fo.text_linesize
     FROM   wri$_rept_components c,
            wri$_rept_reports    r,
            wri$_emx_files      f,
            wri$_rept_formats    fo
     WHERE  c.id = r.component_id AND
            r.id = fo.report_id AND
            fo.stylesheet_id = f.id(+)
/

CREATE OR REPLACE PUBLIC SYNONYM REPORT_FORMATS FOR REPORT_FORMATS
/

GRANT READ ON REPORT_FORMATS TO PUBLIC
/

-- The foll 3 views are for the Automatic report capture infrastructure. They
-- have the dba_hist prefix indicating they may be AWR views, but are currently
-- in this catalog to avoid any conflicts/requirements of adding them to the 
-- catawrvw.sql file.

/* Enable container_data sharing=object */
alter session set "_ORACLE_SCRIPT"=TRUE
/

/***************************************
 *   DBA_HIST_REPORTS
 ***************************************/
create or replace view DBA_HIST_REPORTS
     container_data sharing=object
  (SNAP_ID, DBID, INSTANCE_NUMBER, REPORT_ID, COMPONENT_ID, SESSION_ID, 
   SESSION_SERIAL#, PERIOD_START_TIME, 
   PERIOD_END_TIME, GENERATION_TIME, COMPONENT_NAME, REPORT_NAME, 
   REPORT_PARAMETERS, KEY1, KEY2, KEY3, KEY4, GENERATION_COST_SECONDS, 
   REPORT_SUMMARY, CON_DBID, CON_ID)
as 
select  snap_id, dbid, instance_number, report_id, component_id, session_id, 
        session_serial#, period_start_time, period_end_time, generation_time, 
        component_name, report_name, report_params, key1, key2, key3, key4,
        generation_cost, report_summary, con_dbid, 
        nvl(con_dbid_to_id(con_dbid), 0) con_id
from   wrp$_reports r
/
create or replace public synonym DBA_HIST_REPORTS
  for DBA_HIST_REPORTS
/ 
grant select on DBA_HIST_REPORTS to SELECT_CATALOG_ROLE
/



execute CDBView.create_cdbview(false,'SYS','DBA_HIST_REPORTS','CDB_HIST_REPORTS');
grant select on SYS.CDB_HIST_REPORTS to select_catalog_role
/
create or replace public synonym CDB_HIST_REPORTS for SYS.CDB_HIST_REPORTS
/

 
/***************************************
 *   DBA_HIST_REPORTS_DETAILS
 ***************************************/
create or replace view DBA_HIST_REPORTS_DETAILS
     container_data sharing=object
  (SNAP_ID, DBID, INSTANCE_NUMBER, REPORT_ID, SESSION_ID, SESSION_SERIAL#, 
   GENERATION_TIME, REPORT_COMPRESSED, REPORT, CON_DBID, CON_ID)
as 
select snap_id, dbid, instance_number, report_id, session_id, session_serial#,
       generation_time, report_compressed,
       dbms_auto_report_internal.i_uncompress_report(report_compressed), 
       con_dbid,
       nvl(con_dbid_to_id(con_dbid), 0) con_id
from wrp$_reports_details d
/
create or replace public synonym DBA_HIST_REPORTS_DETAILS
  for DBA_HIST_REPORTS_DETAILS
/
grant select on DBA_HIST_REPORTS_DETAILS to SELECT_CATALOG_ROLE
/


execute CDBView.create_cdbview(false,'SYS','DBA_HIST_REPORTS_DETAILS','CDB_HIST_REPORTS_DETAILS');
grant select on SYS.CDB_HIST_REPORTS_DETAILS to select_catalog_role
/
create or replace public synonym CDB_HIST_REPORTS_DETAILS for SYS.CDB_HIST_REPORTS_DETAILS
/

/***************************************************************
 *   DBA_HIST_REPORTS_TIMEBANDS - time bands view for 
 ***************************************************************/
create or replace view DBA_HIST_REPORTS_TIMEBANDS
     container_data sharing=object
  (SNAP_ID, DBID, INSTANCE_NUMBER, CON_DBID, COMPONENT_ID, COMPONENT_NAME,
   BAND_START_TIME, BAND_LENGTH, REPORT_ID, REPORT_GENERATION_TIME, 
   PERIOD_START_TIME, PERIOD_END_TIME, KEY1, KEY2, KEY3, KEY4, SESSION_ID, 
   SESSION_SERIAL#, CON_ID)
as 
select SNAP_ID, DBID, INSTANCE_NUMBER, CON_DBID, COMPONENT_ID, COMPONENT_NAME,
       BAND_START_TIME, BAND_LENGTH, REPORT_ID, REPORT_GENERATION_TIME, 
       PERIOD_START_TIME, PERIOD_END_TIME, KEY1, KEY2, KEY3, KEY4, SESSION_ID, 
       SESSION_SERIAL#,
       nvl(con_dbid_to_id(con_dbid), 0) CON_ID
from  wrp$_reports_time_bands;
/
create or replace public synonym DBA_HIST_REPORTS_TIMEBANDS
  for DBA_HIST_REPORTS_TIMEBANDS
/
grant select on DBA_HIST_REPORTS_TIMEBANDS to SELECT_CATALOG_ROLE
/


execute CDBView.create_cdbview(false,'SYS','DBA_HIST_REPORTS_TIMEBANDS','CDB_HIST_REPORTS_TIMEBANDS');
grant select on SYS.CDB_HIST_REPORTS_TIMEBANDS to select_catalog_role
/
create or replace public synonym CDB_HIST_REPORTS_TIMEBANDS for SYS.CDB_HIST_REPORTS_TIMEBANDS
/

/********************************************************************
 *   DBA_HIST_REPORTS_CONTROL - control table view for report capture
 ********************************************************************/
create or replace view DBA_HIST_REPORTS_CONTROL
  (DBID, EXECUTION_MODE)
as
select dbid, decode(execution_mode, 0, 'REGULAR', 1, 'FULL_CAPTURE') 
                execution_mode
from wrp$_reports_control;

create or replace public synonym DBA_HIST_REPORTS_CONTROL
  for DBA_HIST_REPORTS_CONTROL
/
grant select on DBA_HIST_REPORTS_CONTROL to SELECT_CATALOG_ROLE
/


execute CDBView.create_cdbview(false,'SYS','DBA_HIST_REPORTS_CONTROL','CDB_HIST_REPORTS_CONTROL');
grant select on SYS.CDB_HIST_REPORTS_CONTROL to select_catalog_role
/
create or replace public synonym CDB_HIST_REPORTS_CONTROL for SYS.CDB_HIST_REPORTS_CONTROL
/

/* reset the underscore param */
alter session set "_ORACLE_SCRIPT"=FALSE
/

-------------------------------------------------------------------------------
--                        underscore view definitions                        --
-------------------------------------------------------------------------------
CREATE OR REPLACE VIEW "_REPORT_COMPONENT_OBJECTS"
AS SELECT c.id component_id, c.name component_name, c.object component_object
   FROM   wri$_rept_components c
/

CREATE OR REPLACE PUBLIC SYNONYM "_REPORT_COMPONENT_OBJECTS" 
FOR "_REPORT_COMPONENT_OBJECTS"
/

GRANT READ ON "_REPORT_COMPONENT_OBJECTS" TO PUBLIC
/

CREATE OR REPLACE VIEW "_REPORT_FORMATS"
AS SELECT c.id component_id, c.name component_name, 
          r.id report_id, r.name report_name, 
          fo.name format_name, fo.type, fo.content_type, fo.text_linesize,
          f.name xslt_filename
   FROM   wri$_rept_components c, wri$_rept_reports r, 
          wri$_emx_files f, wri$_rept_formats fo
   WHERE  c.id = r.component_id AND 
          fo.report_id = r.id  AND 
          fo.stylesheet_id = f.id (+);

CREATE OR REPLACE PUBLIC SYNONYM "_REPORT_FORMATS" FOR "_REPORT_FORMATS"
/

GRANT READ ON "_REPORT_FORMATS" TO PUBLIC
/

@?/rdbms/admin/sqlsessend.sql
