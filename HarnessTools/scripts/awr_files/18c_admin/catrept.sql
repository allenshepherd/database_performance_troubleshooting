Rem
Rem catrept.sql
Rem
Rem Copyright (c) 2005, 2016, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catrept.sql - CATalog script server manageability REPorT framework
Rem
Rem    DESCRIPTION
Rem      Creates the base tables and types for the server manageability
Rem      report framework.  See catrepv for view defs.
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catrept.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catrept.sql
Rem SQL_PHASE: CATREPT
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catptyps.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    shjoshi     05/18/16 - bug 23279437: Remove con_id from wrp tables
Rem    shjoshi     04/08/16 - bug 23059287: Add con_id to wrp tables
Rem    raeburns    05/31/15 - remove OR REPLACE for types with table dependents
Rem    yxie        08/22/14 - add EM Express resource manager report
Rem    jiayan      05/27/14 - Proj 44162: add wri$_rept_statsadv
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    cgervasi    03/25/13 - add wri$_rept_cell
Rem    vbipinbh    10/25/12 - add wri$_rept_tcb
Rem    cgervasi    08/03/12 - add wri$_rept_emx_perf
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    hayu        02/27/12 - update parse_report_ref
Rem    shjoshi     02/24/12 - Add wrp$_reports_control
Rem    shjoshi     02/10/12 - Add get_report_with_summary
Rem    arbalakr    01/14/12 - add compare period types
Rem    shjoshi     01/11/12 - Add report repository object
Rem    abmunir     12/07/11 - add memory report
Rem    jinhuo      11/17/11 - Checking in security component changes
Rem    swexler     11/08/11 - add emx_perf
Rem    jinhuo      10/25/11 - Adding wri$_rept_security type
Rem    acakmak     10/20/11 - add optimizer stats report object
Rem    shjoshi     10/19/11 - Add columns to wrp time_bands table
Rem    shjoshi     10/19/11 - Disable partitioning check for wrp tables
Rem    shjoshi     10/08/11 - Add dbid, con_dbid to wrp* tables
Rem    shjoshi     09/28/11 - Add wrp$_reports*
Rem    cgervasi    08/29/11 - add perfpage
Rem    bdagevil    08/20/11 - add db home report type
Rem    cgervasi    07/20/11 - add awr viewer
Rem    kyagoub     07/13/11 - add ashviewer report
Rem    bdagevil    06/05/11 - add config report
Rem    ddas        08/22/11 - SPM evolve report
Rem    yxie        04/21/11 - move wri$_rept_files to wri$_emx_files
Rem    yxie        04/19/11 - move file management to prvt_emx package
Rem    traney      04/05/11 - 35209: long identifiers dictionary upgrade
Rem    bkhaladk    11/02/09 - Add xmltype for column in wri$_rept_files
Rem    rdongmin    08/15/07 - add xml report for plan diff
Rem    bdagevil    03/25/07 - add report object for SQL monitor
Rem    veeve       03/14/07 - add wri$_rept_dbreplay
Rem    kyagoub     10/05/06 - add wri$_rept_xplan
Rem    pbelknap    07/24/06 - add sqltune report object 
Rem    kyagoub     07/08/06 - add xml report for sqlpi advisor 
Rem    pbelknap    07/15/05 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

-------------------------------------------------------------------------------
--                              type definitions                             --
-------------------------------------------------------------------------------
CREATE TYPE wri$_rept_abstract_t
AUTHID CURRENT_USER
AS OBJECT
(
  dummy_param number,

  ----------------------------------- get_report ------------------------------
  -- NAME: 
  --     get_report
  --
  -- DESCRIPTION:
  --     All components should implement the get_report method to allow the 
  --     framework to fetch their reports.  It should accept the report 
  --     reference specifying the report they need to build, 
  --     and return the report in XML.
  --
  -- PARAMETERS:
  --     report_reference (IN) - the string identifying the report to be built.
  --                             Can be parsed by a call to 
  --                             parse_report_reference.
  --
  -- RETURN:
  --     Report built, in XML
  -----------------------------------------------------------------------------
  member function get_report(report_reference IN VARCHAR2) return xmltype,

  ------------------------------- get_report_with_summary ---------------------
  -- NAME: 
  --     get_report_with_summary
  --
  -- DESCRIPTION:
  --     Currently the wri$_rept_sqlmonitor component implements the 
  --     get_report_with_summary method to allow the framework to fetch a
  --     report along with its summary, from the repository.  It should accept
  --     the report reference specifying the report they need to build, 
  --     and return the report in XML.
  --     The summary is embedded as an xml element with the name 
  --     "report_repository_summary". This tag can have xmlattributes and 
  --     embedded xml elements as per the requirement of the client implementing
  --     this procedure. The report_repository_summary tag should be the 
  --     first-level child of the top-level report tag in the xml returned by
  --     this procedure.
  --
  -- PARAMETERS:
  --     report_reference (IN) - the string identifying the report to be built.
  --                             Can be parsed by a call to 
  --                             parse_report_reference.
  --
  -- RETURN:
  --     Report built, in XML
  -----------------------------------------------------------------------------
  member function get_report_with_summary(
    report_reference IN VARCHAR2) 
  return xmltype,

  ------------------------------- custom_format -------------------------------
  -- NAME: 
  --     custom_format
  --
  -- DESCRIPTION:
  --     In addition to the formatting reports via XSLT or HTML-to-Text, 
  --     components can have their own custom formats.  They just need to
  --     override this function.  One component can have any number of custom
  --     formats by implementing logic around the 'format_name' argument here.
  --
  -- PARAMETERS:
  --     report_name (IN) - report name corresponding to report
  --     format_name (IN) - format name to generate
  --     report      (IN) - report to transform
  --
  -- RETURN:
  --     Transformed report, as CLOB
  -----------------------------------------------------------------------------
  member function custom_format(report_name IN VARCHAR2,
                                format_name IN VARCHAR2, 
                                report      IN XMLTYPE) return clob 
) 
not final
not instantiable
/

CREATE OR REPLACE PUBLIC SYNONYM wri$_rept_abstract_t FOR wri$_rept_abstract_t
/

GRANT EXECUTE ON wri$_rept_abstract_t TO PUBLIC
/

-------------------------------------------------------------------------------
--                             sequence definitions                           -
-------------------------------------------------------------------------------
------------------------------ WRI$_REPT_COMP_ID_SEQ --------------------------
-- NAME:
--     WRI$_REPT_COMP_ID_SEQ
--
-- DESCRIPTION:
--     This is a sequence to generate ID values for WRI$_REPT_COMPONENTS
-------------------------------------------------------------------------------
CREATE SEQUENCE wri$_rept_comp_id_seq
  INCREMENT BY 1
  START WITH 1
  NOMAXVALUE
  CACHE 100
  NOCYCLE
/

------------------------------ WRI$_REPT_REPT_ID_SEQ --------------------------
-- NAME:
--     WRI$_REPT_REPT_ID_SEQ
--
-- DESCRIPTION:
--     This is a sequence to generate ID values for WRI$_REPT_REPORTS
-------------------------------------------------------------------------------
CREATE SEQUENCE wri$_rept_rept_id_seq
  INCREMENT BY 1
  START WITH 1
  NOMAXVALUE
  CACHE 100
  NOCYCLE
/

----------------------------- WRI$_REPT_FORMAT_ID_SEQ -------------------------
-- NAME:
--     WRI$_REPT_FORMAT_ID_SEQ
--
-- DESCRIPTION:
--     This is a sequence to generate ID values for WRI$_REPT_FORMATS
-------------------------------------------------------------------------------
CREATE SEQUENCE wri$_rept_format_id_seq
  INCREMENT BY 1
  START WITH 1
  NOMAXVALUE
  CACHE 100
  NOCYCLE
/

-------------------------------- WRP$_REPORT_ID_SEQ ----------------------------
-- NAME:
--     WRP$_REPORT_ID_SEQ
--
-- DESCRIPTION:
--     This is a sequence to generate ID values for WRP$_REPORTS
--------------------------------------------------------------------------------
CREATE SEQUENCE WRP$_REPORT_ID_SEQ
  INCREMENT BY 1
  START WITH 1
  NOMAXVALUE
  NOCACHE
  NOCYCLE
/

-------------------------------------------------------------------------------
--                              table definitions                            --
-------------------------------------------------------------------------------
-----------------------------  wri$_rept_components ---------------------------
-- NAME:
--     wri$_rept_components
--
-- DESCRIPTION: 
--     This table stores the metadata we have about report components.
--
-- PRIMARY KEY:
--     The primary key is id.     
--
-------------------------------------------------------------------------------
CREATE TABLE wri$_rept_components
(
  id          NUMBER               NOT NULL,
  name        VARCHAR2(128)         NOT NULL,
  description VARCHAR2(256),
  object      wri$_rept_abstract_t NOT NULL,
  constraint  wri$_rept_components_pk primary key(id)
  using INDEX tablespace SYSAUX
)
tablespace SYSAUX
/

create unique index wri$_rept_components_idx_01
on wri$_rept_components(name)
tablespace SYSAUX
/

------------------------------ wri$_rept_reports ------------------------------
-- NAME:
--     wri$_rept_reports
--
-- DESCRIPTION: 
--     This table stores the metadata we have about reports.  It keeps the 
--     object which has a member function to fetch a report as well as the
--     report name and description.  A component can have multiple reports.
--
-- PRIMARY KEY:
--     The primary key is id
--
-- FOREIGN KEY:
--     COMPONENT_ID references wri$_rept_components.id
--     SCHEMA_ID references wri$_xmlr_files.id, for an XML schema.  can be NULL
-------------------------------------------------------------------------------
CREATE TABLE wri$_rept_reports
(
  id             NUMBER               NOT NULL,
  component_id   NUMBER               NOT NULL,
  name           VARCHAR2(128)         NOT NULL,
  description    VARCHAR2(256),
  schema_id      NUMBER,
  constraint wri$_rept_reports_pk primary key(id)
  using INDEX tablespace SYSAUX  
)
tablespace SYSAUX
/

create unique index wri$_rept_reports_idx_01
on wri$_rept_reports(component_id, name)
tablespace SYSAUX
/


-------------------------------- wri$_rept_formats ----------------------------
-- NAME:
--     wri$_rept_formats
--
-- DESCRIPTION: 
--     This table stores the list of output formats for a report.  Formats are 
--     in a many-to-one relationship with reports.
--
-- PRIMARY KEY:
--     The primary key is id
--
-- FOREIGN KEY:
--     REPORT_ID references WRI$_REPT_REPORTS(id)
--     STYLESHEET_ID references WRI$_EMX_FILES(id) and can be null when there
--     is no stylesheet (custom transformations only)
-------------------------------------------------------------------------------
CREATE TABLE wri$_rept_formats
(
  id              NUMBER       NOT NULL,
  report_id       NUMBER       NOT NULL,
  name            VARCHAR2(128) NOT NULL,
  description     VARCHAR2(256),
  type            NUMBER,                       /* 1: XSLT 2: Text 3: Custom */
  content_type    NUMBER,                /* 1: xml 2: html 3: text 4: binary */
  stylesheet_id   NUMBER,
  text_linesize   NUMBER,
  constraint wri$_rept_formats_pk primary key(id)
  using INDEX tablespace SYSAUX
)
tablespace SYSAUX
/

create unique index wri$_rept_formats_idx_01
on wri$_rept_formats(report_id, name)
tablespace SYSAUX
/

-- ===========================================================
-- Tables for storing the automatically captured perf reports
-- ===========================================================

-- Turn ON the event to disable the partition check
alter session set events  '14524 trace name context forever, level 1';

-- This table stores the metadata about each automatically captured report
-- We use interval partitioning to create a new partition every hour based 
-- on report generation time. Partitions are helpful while purging.
create table wrp$_reports
(
  snap_id               NUMBER,
  dbid                  NUMBER,
  instance_number       NUMBER,
  report_id             NUMBER,
  con_dbid              NUMBER,
  component_id          NUMBER,
  session_id            NUMBER,
  session_serial#       NUMBER,
  period_start_time     DATE,
  period_end_time       DATE,
  generation_time       DATE,
  component_name        varchar2(128),
  report_name           varchar2(128),
  report_params         varchar2(1024),
  key1                  varchar2(128),
  key2                  varchar2(128),
  key3                  varchar2(128),
  key4                  varchar2(256),
  generation_cost       number, 
  report_summary        varchar2(4000),
  spare1                number default null,
  spare2                number default null, 
  spare3                number default null,
  spare4                varchar2(4000) default null,
  spare5                varchar2(4000) default null,
  spare6                varchar2(4000) default null
) partition by range(generation_time)
  interval (numtodsinterval(1, 'DAY'))
  (partition p0 values less than 
      (to_date('01-01-2010:01:00:00', 'DD-MM-YYYY:HH24:MI:SS')))
  tablespace SYSAUX
/

-- index on the key attributes
create index wrp$_reports_idx01 
on wrp$_reports(key1, key2, key3) local
tablespace SYSAUX
/

-- local unique index instead of pk index
create index wrp$_reports_idx02
on wrp$_reports(generation_time, dbid, component_name, report_id) local
tablespace SYSAUX
/

-- This table has the actual compressed XML report
-- We use interval partitioning to create a new partition every hour based 
-- on report generation time. Partitions are helpful while purging
create table wrp$_reports_details
(
  snap_id                      NUMBER,
  dbid                         NUMBER,
  instance_number              NUMBER,
  report_id                    NUMBER,
  con_dbid                     NUMBER,
  session_id                   NUMBER,
  session_serial#              NUMBER,
  generation_time              DATE,
  report_compressed            blob
) partition by range(generation_time)
  interval (numtodsinterval(1, 'DAY'))
  (partition p0 values less than 
      (to_date('01-01-2010:01:00:00', 'DD-MM-YYYY:HH24:MI:SS')))
  tablespace SYSAUX
/

-- index on the report_id attribute
create index wrp$_reports_details_idx01 
on wrp$_reports_details(report_id) local
tablespace SYSAUX
/

-- local unique index instead of pk index
create unique index wrp$_reports_details_idx02
on wrp$_reports_details(generation_time, dbid, report_id) local 
tablespace SYSAUX
/

-- This table will be used to index into the wrp$_reports table by using the
-- report_generation_time which is the partitioning key for that table. 
-- This table has bands at the top of each hour, so for a given time range
-- (t1, t2) it is easy to identify the rows in the time_bands table that
-- include time range (t1, t2) since band_start_time is top of the hour.
-- For each row in this table in the qualifying bands, we retrieve the reports
-- using the generation_time which is the partitioning key.
create table wrp$_reports_time_bands
(
  snap_id                  NUMBER,
  dbid                     NUMBER,
  instance_number          NUMBER,
  con_dbid                 NUMBER,
  session_id               NUMBER,
  session_serial#          NUMBER,
  component_id             NUMBER,
  component_name           varchar2(128),
  band_start_time          DATE,
  band_length              NUMBER,
  report_id                NUMBER,
  report_generation_time   DATE,
  period_start_time        DATE,
  period_end_time          DATE,
  key1                     varchar2(128),
  key2                     varchar2(128),
  key3                     varchar2(128),
  key4                     varchar2(256)
) partition by range(band_start_time)
  interval (numtodsinterval(1, 'DAY'))
  (partition p0 values less than
      (to_date('01-01-2010:01:00:00', 'DD-MM-YYYY:HH24:MI:SS')))    
  tablespace SYSAUX
/

-- This table contains some control parameters used for execution of the 
-- automatic report capture repository
create table wrp$_reports_control
(
  dbid                     NUMBER,
  execution_mode           NUMBER  default 0
) tablespace SYSAUX
/

-- unique index on dbid ensures that duplicate rows wont be inserted
-- in this table for the same dbid
create unique index wrp$_reports_control_idx01
on wrp$_reports_control (dbid)
tablespace SYSAUX
/


-- Turn OFF the event to disable the partition check 
alter session set events  '14524 trace name context off';

-------------------------------------------------------------------------------
--                         client sub-type definitions                       --
-------------------------------------------------------------------------------

--
-- Sqlpi advisor report subtype
--
CREATE TYPE wri$_rept_sqlpi AUTHID CURRENT_USER UNDER wri$_rept_abstract_t
(
  overriding member function get_report(report_reference IN VARCHAR2) 
    return xmltype,
  overriding member function custom_format(report_name IN VARCHAR2,
                                           format_name IN VARCHAR2,
                                           report      IN XMLTYPE)
    return clob
)
/

CREATE OR REPLACE PUBLIC SYNONYM wri$_rept_sqlpi FOR wri$_rept_sqlpi
/
GRANT EXECUTE ON wri$_rept_sqlpi TO PUBLIC
/

--
-- Sql Tuning Advisor report object
--
CREATE TYPE wri$_rept_sqlt AUTHID CURRENT_USER UNDER wri$_rept_abstract_t
(
  overriding member function get_report(report_reference IN VARCHAR2) 
    return xmltype
)
/

CREATE OR REPLACE PUBLIC SYNONYM wri$_rept_sqlt FOR wri$_rept_sqlt
/

GRANT EXECUTE ON wri$_rept_sqlt TO PUBLIC
/

--
-- Explan plan report object
--
CREATE TYPE wri$_rept_xplan AUTHID CURRENT_USER UNDER wri$_rept_abstract_t
(
  overriding member function get_report(report_reference IN VARCHAR2) 
    return xmltype
)
/

CREATE OR REPLACE PUBLIC SYNONYM wri$_rept_xplan FOR wri$_rept_xplan
/

GRANT EXECUTE ON wri$_rept_xplan TO PUBLIC
/

--
-- DB Replay report subtype
--
CREATE TYPE wri$_rept_dbreplay AUTHID CURRENT_USER UNDER wri$_rept_abstract_t
(
  overriding member function get_report(report_reference IN VARCHAR2) 
    return xmltype
)
/

CREATE OR REPLACE PUBLIC SYNONYM wri$_rept_dbreplay FOR wri$_rept_dbreplay
/
GRANT EXECUTE ON wri$_rept_dbreplay TO PUBLIC
/

--
-- SQL Monitor report object
--
CREATE TYPE wri$_rept_sqlmonitor AUTHID CURRENT_USER UNDER wri$_rept_abstract_t
(
  overriding member function get_report(report_reference IN VARCHAR2) 
    return xmltype,
  overriding member function get_report_with_summary(
        report_reference IN VARCHAR2) 
    return xmltype
)
/

CREATE OR REPLACE PUBLIC SYNONYM wri$_rept_sqlmonitor FOR wri$_rept_sqlmonitor
/

GRANT EXECUTE ON wri$_rept_sqlmonitor TO PUBLIC
/

--
-- Sql Plan Diff report object
--
CREATE TYPE wri$_rept_plan_diff AUTHID CURRENT_USER UNDER wri$_rept_abstract_t
(
  overriding member function get_report(report_reference IN VARCHAR2) 
    return xmltype
)
/

CREATE OR REPLACE PUBLIC SYNONYM wri$_rept_plan_diff FOR wri$_rept_plan_diff
/

GRANT EXECUTE ON wri$_rept_plan_diff TO PUBLIC
/

--
-- SPM evolve report object
--
CREATE TYPE wri$_rept_spmevolve AUTHID CURRENT_USER UNDER wri$_rept_abstract_t
(
  overriding member function get_report(report_reference IN VARCHAR2)
    return xmltype
)
/

CREATE OR REPLACE PUBLIC SYNONYM wri$_rept_spmevolve FOR wri$_rept_spmevolve
/

GRANT EXECUTE ON wri$_rept_spmevolve TO PUBLIC
/

--
-- DB config report object
--
CREATE TYPE wri$_rept_config AUTHID CURRENT_USER UNDER wri$_rept_abstract_t
(
  overriding member function get_report(report_reference IN VARCHAR2)
    return xmltype
)
/

CREATE OR REPLACE PUBLIC SYNONYM wri$_rept_config FOR wri$_rept_config
/

GRANT EXECUTE ON wri$_rept_config TO PUBLIC
/


--
-- DB storage report object
--
CREATE TYPE wri$_rept_storage AUTHID CURRENT_USER UNDER wri$_rept_abstract_t
(
  overriding member function get_report(report_reference IN VARCHAR2)
    return xmltype
)
/

CREATE OR REPLACE PUBLIC SYNONYM wri$_rept_storage FOR wri$_rept_storage
/

GRANT EXECUTE ON wri$_rept_storage TO PUBLIC
/

-- 
-- Security
--
CREATE TYPE wri$_rept_security AUTHID CURRENT_USER UNDER wri$_rept_abstract_t
(
  overriding member function get_report(report_reference IN VARCHAR2)
    return xmltype
)
/

CREATE OR REPLACE PUBLIC SYNONYM wri$_rept_security FOR wri$_rept_security
/

GRANT EXECUTE ON wri$_rept_security TO PUBLIC
/

-- 
-- Memory report object
--
CREATE TYPE wri$_rept_memory AUTHID CURRENT_USER UNDER wri$_rept_abstract_t
(
  overriding member function get_report(report_reference IN VARCHAR2)
    return xmltype
)
/

CREATE OR REPLACE PUBLIC SYNONYM wri$_rept_memory FOR wri$_rept_memory
/

GRANT EXECUTE ON wri$_rept_memory TO PUBLIC
/


--
-- ASH viewer report object
--
CREATE TYPE wri$_rept_ash AUTHID CURRENT_USER UNDER wri$_rept_abstract_t
(
  overriding member function get_report(report_reference IN VARCHAR2)
    return xmltype
)
/

CREATE OR REPLACE PUBLIC SYNONYM wri$_rept_ash FOR wri$_rept_ash
/

GRANT EXECUTE ON wri$_rept_ash TO PUBLIC
/


--
-- AWR viewer report object
--
CREATE TYPE wri$_rept_awrv AUTHID CURRENT_USER UNDER wri$_rept_abstract_t
(
  overriding member function get_report(report_reference IN VARCHAR2)
    return xmltype
)
/

CREATE OR REPLACE PUBLIC SYNONYM wri$_rept_awrv FOR wri$_rept_awrv
/

GRANT EXECUTE ON wri$_rept_awrv TO PUBLIC
/

--
-- ADDM report object
--
CREATE TYPE wri$_rept_addm AUTHID CURRENT_USER UNDER wri$_rept_abstract_t
(
  overriding member function get_report(report_reference IN VARCHAR2)
    return xmltype
)
/

CREATE OR REPLACE PUBLIC SYNONYM wri$_rept_addm FOR wri$_rept_addm
/

GRANT EXECUTE ON wri$_rept_addm TO PUBLIC
/

--
-- Real-Time ADDM report object
--
CREATE TYPE wri$_rept_rtaddm AUTHID CURRENT_USER UNDER wri$_rept_abstract_t
(
  overriding member function get_report(report_reference IN VARCHAR2)
    return xmltype
)
/

CREATE OR REPLACE PUBLIC SYNONYM wri$_rept_rtaddm FOR wri$_rept_rtaddm
/

GRANT EXECUTE ON wri$_rept_rtaddm TO PUBLIC
/

--
-- Compare Period ADDM report object
--
CREATE TYPE wri$_rept_cpaddm AUTHID CURRENT_USER UNDER wri$_rept_abstract_t
(
  overriding member function get_report(report_reference IN VARCHAR2)
  return xmltype
)
/

CREATE OR REPLACE PUBLIC SYNONYM wri$_rept_cpaddm FOR wri$_rept_cpaddm
/

GRANT EXECUTE ON wri$_rept_cpaddm TO PUBLIC


--
-- Perf page report object
--
CREATE TYPE wri$_rept_perf AUTHID CURRENT_USER UNDER wri$_rept_abstract_t
(
  overriding member function get_report(report_reference IN VARCHAR2)
    return xmltype
)
/

CREATE OR REPLACE PUBLIC SYNONYM wri$_rept_perf FOR wri$_rept_perf
/

GRANT EXECUTE ON wri$_rept_perf TO PUBLIC
/

--
-- SQL Details report object
--
CREATE TYPE wri$_rept_sqldetail AUTHID CURRENT_USER UNDER wri$_rept_abstract_t
(
  overriding member function get_report(report_reference IN VARCHAR2)
    return xmltype
)
/

CREATE OR REPLACE PUBLIC SYNONYM wri$_rept_sqldetail FOR wri$_rept_sqldetail
/

GRANT EXECUTE ON wri$_rept_sqldetail TO PUBLIC
/



--
-- Session Details report object
--
CREATE TYPE wri$_rept_session AUTHID CURRENT_USER UNDER wri$_rept_abstract_t
(
  overriding member function get_report(report_reference IN VARCHAR2)
    return xmltype
)
/

CREATE OR REPLACE PUBLIC SYNONYM wri$_rept_session FOR wri$_rept_session
/

GRANT EXECUTE ON wri$_rept_session TO PUBLIC
/



--
-- DB Home page report object
--
CREATE TYPE wri$_rept_dbhome AUTHID CURRENT_USER UNDER wri$_rept_abstract_t
(
  overriding member function get_report(report_reference IN VARCHAR2)
    return xmltype
)
/

CREATE OR REPLACE PUBLIC SYNONYM wri$_rept_dbhome FOR wri$_rept_dbhome
/

GRANT EXECUTE ON wri$_rept_dbhome TO PUBLIC
/

--
-- Optimizer stats operations report object
--
CREATE TYPE wri$_rept_optstats AUTHID CURRENT_USER UNDER wri$_rept_abstract_t
(
  overriding member function get_report(report_reference IN VARCHAR2)
    return xmltype
)
/

CREATE OR REPLACE PUBLIC SYNONYM wri$_rept_optstats FOR wri$_rept_optstats
/

GRANT EXECUTE ON wri$_rept_optstats TO PUBLIC
/

--
-- Automatic Report Repository report object
--
CREATE TYPE wri$_rept_arc AUTHID CURRENT_USER UNDER wri$_rept_abstract_t
(
  overriding member function get_report(report_reference IN VARCHAR2)
    return xmltype
)
/

CREATE OR REPLACE PUBLIC SYNONYM wri$_rept_arc FOR wri$_rept_arc
/

GRANT EXECUTE ON wri$_rept_arc TO PUBLIC
/

--
-- EMX Hub report object
--
CREATE TYPE wri$_rept_emx_perf AUTHID CURRENT_USER UNDER wri$_rept_abstract_t
(
  overriding member function get_report(report_reference IN VARCHAR2)
    return xmltype
)
/

CREATE OR REPLACE PUBLIC SYNONYM wri$_rept_emx_perf FOR wri$_rept_emx_perf
/

GRANT EXECUTE ON wri$_rept_emx_perf TO PUBLIC
/

--
-- SQL test case builder report object
--
CREATE TYPE wri$_rept_tcb AUTHID CURRENT_USER UNDER wri$_rept_abstract_t
(
  overriding member function get_report(report_reference IN VARCHAR2)
    return xmltype
)
/

CREATE OR REPLACE PUBLIC SYNONYM wri$_rept_tcb FOR wri$_rept_tcb
/

GRANT EXECUTE ON wri$_rept_tcb TO PUBLIC
/

--
-- Exadata Cell report object
--
CREATE TYPE wri$_rept_cell AUTHID CURRENT_USER UNDER wri$_rept_abstract_t
(
  overriding member function get_report(report_reference IN VARCHAR2)
    return xmltype
)
/

CREATE OR REPLACE PUBLIC SYNONYM wri$_rept_cell FOR wri$_rept_cell
/

GRANT EXECUTE ON wri$_rept_cell TO PUBLIC
/

--
-- Statistics Advisor report object
--
CREATE TYPE wri$_rept_statsadv AUTHID CURRENT_USER UNDER wri$_rept_abstract_t
(
  overriding member function get_report(report_reference IN VARCHAR2)
    return xmltype
)
/

CREATE OR REPLACE PUBLIC SYNONYM wri$_rept_statsadv FOR wri$_rept_statsadv
/

GRANT EXECUTE ON wri$_rept_statsadv TO PUBLIC
/

-- 
-- Resource Manager report object
--
CREATE TYPE wri$_rept_rsrcmgr AUTHID CURRENT_USER UNDER wri$_rept_abstract_t
(
  overriding member function get_report(report_reference IN VARCHAR2)
    return xmltype
)
/

CREATE OR REPLACE PUBLIC SYNONYM wri$_rept_rsrcmgr FOR wri$_rept_rsrcmgr
/

GRANT EXECUTE ON wri$_rept_rsrcmgr TO PUBLIC
/

@?/rdbms/admin/sqlsessend.sql
