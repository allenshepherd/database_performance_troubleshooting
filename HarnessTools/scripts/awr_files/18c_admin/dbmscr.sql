Rem
Rem $Header: rdbms/admin/dbmscr.sql /st_rdbms_18.0/2 2018/05/16 14:44:38 surman Exp $
Rem
Rem dbmscr.sql
Rem
Rem Copyright (c) 2006, 2018, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbmscr.sql - DBMS_Registry package specs and views
Rem
Rem    DESCRIPTION
Rem      
Rem
Rem    NOTES
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/dbmscr.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/dbmscr.sql
Rem SQL_PHASE: DBMSCR
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catptabs.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    apfwkr      04/16/18 - Backport raeburns_bug-27591842 from main
Rem    raeburns    02/25/18 - Bug 27591842: add build description, date to ru
Rem                           app/roll
Rem    pyam        10/30/17 - Bug 26799709: add is_server_component
Rem    raeburns    08/14/17 - Bug 26255427: add dbms_registry_extended package
Rem                           to catproc.sql
Rem    pjulsaks    06/26/17 - Bug 25688154: Uppercase create_cdbview's input
Rem    rtattuku    06/22/17 - version change from cdilling
Rem    raeburns    06/04/17 - Bug 26170491: Add interfaces for datapatch
Rem                           function
Rem    fvallin     05/05/17 - Bug 25890128: Added capitalize_single_quote
Rem                           function
Rem    surman      04/27/17 - 25507396: Execute to execute_catalog_role
Rem    surman      04/17/17 - 25269268: Add bundle_series to
Rem                           dba_registry_history
Rem    raeburns    04/08/17 - For 18.0.0 remove old populate and cpu routines
Rem    surman      03/15/17 - 25479222: Remove dir_exists_and_is_writable
Rem    raeburns    03/05/17 - Bug 25491041: Separate upgrade error checking 
Rem                           from validation routines for CATALOG/CATPROC
Rem    welin       10/17/16 - Remove patch_script as <cid>patch.sql will 
Rem                           no longer be called
Rem    raeburns    04/08/16 - restore dbmscr.sql as versioned object
Rem                           add dbms_registry_basic.sql to define sqlplus 
Rem                           variables
Rem    welin       01/04/16 - Bug 22339986: automatically set database version
Rem                           and release status
Rem    jerrede     12/10/15 - Bug 22116552 Additional routines needed for stats
Rem                           upgrade
Rem    cdilling    11/02/15 - Change RDBMS version to 12.2.0.0.2
Rem    raeburns    04/04/15 - add function for catcon query
Rem    raeburns    12/20/14 - Bug 20088724: add view for component schemas
Rem    skayoor     11/30/14 - Proj 58196: Change Select priv to Read Priv
Rem    jerrede     11/20/14 - Support Oracle Read-only Homes
Rem    wesmith     05/05/14 - Project 47511: data-bound collation
Rem    surman      04/21/14 - 17277459: Seperate script for SQL registry
Rem    surman      03/19/14 - 17665117: Patch UID
Rem    cdilling    03/13/14 - update version to 12.2.0.0.0
Rem    traney      01/14/14 - 18074131: fix script_name
Rem    surman      01/13/14 - 13922626: Update SQL metadata
Rem    cdilling    12/26/13 - add DEFAULT NULL to .downgraded (17995763)
Rem    cmlim       12/15/13 - cmlim_bug-17545700: extra: create cdb and dba
Rem                           views on top of registry$error table
Rem    surman      10/31/13 - 17277459: Add bundle columns to registry$sqlpatch
Rem    jerrede     10/24/13 - 17646439 Do not recompile java objects when not
Rem                           installed. Also add registry$error checker
Rem                           for components to call.
Rem    surman      10/24/13 - 14563594: Add version to registry$sqlpatch
Rem    jerrede     09/09/13 - Compile Invalid Java Objects in Root
Rem    surman      08/27/13 - 17343514: Add dir_exists_and_is_writable
Rem    sylin       08/07/13 - longer identifiers
Rem    talliu      06/28/13 - Add CDB view for DBA view
Rem    cdilling    05/12/13 - version to 12.2
Rem    cdilling    01/29/13 - version to 12.1.0.2
Rem    jerrede     11/29/12 - Support for CDB
Rem    jerrede     11/05/12 - Add Exadata Bundle support
Rem    bmccarth    10/24/12 - dir create changes
Rem    surman      09/27/12 - 14685965: Public synonym for
Rem                           dba_registry_sqlpatch
Rem    bmccarth    09/13/12 - bug 14617253 (new dir functions)
Rem    surman      09/13/12 - 14624172: Add status column
Rem    cdilling    08/29/12 - change version to 12.1 production
Rem    jerrede     06/19/12 - Set event to optionally update required stats
Rem                           during upgrade.
Rem    jerrede     05/29/12 - Add Comp Display Routine
Rem    awesley     04/30/12 - add option_off
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    jerrede     02/14/12 - Change function names
Rem    surman      02/08/12 - 13615515: SQL registry table
Rem    jciminsk    01/23/12 - Version to 12.1.0.0.2
Rem    jerrede     12/08/11 - Parallel Upgrade Change Status from Valid to
Rem                           Upgraded
Rem    jerrede     11/01/11 - Fix bug 13252372
Rem    cdilling    09/27/11 - version to 12.1.0.0.1
Rem    jerrede     09/01/11 - Parallel Upgrade Project #23496
Rem    cdilling    10/17/10 - add set_edition
Rem    bmccarth    07/26/10 - move to 12.1
Rem    cdilling    07/15/09 - version to 11.2.0.2.0
Rem    cdilling    04/27/09 - version to 11.2.0.1.0
Rem    cdilling    12/16/08 - version to 11.2.0.2
Rem    rlong       08/07/08 - 
Rem    cdilling    07/17/08 - version to 11.2.0.0.1
Rem    jciminsk    10/22/07 - Upgrade support for 11.2
Rem    jciminsk    10/08/07 - version to 11.2.0.0.0
Rem    jciminsk    08/03/07 - version to 11.1.0.7.0
Rem    emendez     12/14/06 - solve merge conflict
Rem    rburns      06/06/07 - update version to production
Rem    cdilling    04/18/07 - version for beta5
Rem    rburns      02/14/07 - version for BETA5
Rem    rburns      12/07/06 - move gather_stats
Rem    cdilling    12/07/06 - add populate_102
Rem    cdilling    11/13/06 - add support for registry$database
Rem    cdilling    10/06/06 - beta4 version
Rem    cdilling    10/06/06 - beta3 version
Rem    pbagal      08/03/06 - make this work for TB
Rem    rburns      09/14/06 - beta2 version
Rem    cdilling    07/31/06 - overload component dependency procedures
Rem    cdilling    06/06/06 - add comp dependency package specs and views
Rem    cdilling    05/25/06 - add progress package specs and views
Rem    rburns      05/26/06 - update log view 
Rem    cdilling    05/25/06 - add progress package specs and views
Rem    rburns      05/05/06 - registry package specs 
Rem    rburns      05/05/06 - Created
Rem
Rem -------------------------------------------------------------------------
Rem DBMS REGISTRY PACKAGE
Rem -------------------------------------------------------------------------

-- enable _oracle_script; needed for container_data in create_cdbview()
@@?/rdbms/admin/sqlsessstart.sql

-- Get UP/DOWN basic constants and extended package
@@dbms_registry_basic.sql
@@dbms_registry_extended.sql

CREATE OR REPLACE PACKAGE dbms_registry AS

-- RELEASE CONSTANTS 
--    The values are taken from sqlplus constants defined in 
--    dbms_registry_basic.sql. The sqlplus constants are
--    derived from the build variables BANNERVERSION, BANNERVERSIONFULL,
--    and BANNER_STATUS.  The constants reflect the scripts in rdbms/admin, 
--    as opposed to the server code running in an instance.

release_version       CONSTANT registry$.version%type := 
                               '&C_ORACLE_HIGH_VERSION_4_DOTS'; 
release_version_full  CONSTANT registry$.version_full%type := 
                               '&C_ORACLE_HIGH_VERSIONFULL'; 
release_status        CONSTANT VARCHAR2(30) := '&C_ORACLE_HIGH_STATUS'; 

-- Component Hierarchy Type and CONSTANTS
TYPE comp_list_t      IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
IMD_COMPS             CONSTANT NUMBER :=1;  /* immediate subcomponents */
TRM_COMPS             CONSTANT NUMBER :=2;  /* terminal subcomponents */
ALL_COMPS             CONSTANT NUMBER :=3;  /* all subcomponents */

-- Schema List Parameter
TYPE schema_list_t    IS TABLE OF dbms_id;

-- Component dependency Type - table of component IDs
TYPE comp_depend_list_t IS TABLE OF VARCHAR2(30);

-- Component dependency Type - table of component IDs and associated namespaces
TYPE comp_depend_record_t IS RECORD(
    cid VARCHAR2(30), -- component id
    cnamespace VARCHAR2(30) -- component namespace
    );

TYPE comp_depend_rec IS TABLE OF comp_depend_record_t INDEX BY BINARY_INTEGER;

PROCEDURE set_session_namespace (namespace IN VARCHAR2);

PROCEDURE set_comp_namespace (comp_id IN VARCHAR2, 
                              namespace IN VARCHAR2);

PROCEDURE set_rdbms_status(comp_id      IN VARCHAR2,
                           status       IN NUMBER);

PROCEDURE invalid     (comp_id      IN VARCHAR2);

PROCEDURE valid       (comp_id      IN VARCHAR2);

PROCEDURE loading     (comp_id      IN VARCHAR2,
                       comp_name    IN VARCHAR2,
                       comp_proc    IN VARCHAR2 DEFAULT NULL,
                       comp_schema  IN VARCHAR2 DEFAULT NULL,
                       comp_parent  IN VARCHAR2 DEFAULT NULL);

PROCEDURE loading     (comp_id      IN VARCHAR2,
                       comp_name    IN VARCHAR2,
                       comp_proc    IN VARCHAR2,
                       comp_schema  IN VARCHAR2,
                       comp_schemas IN schema_list_t,
                       comp_parent  IN VARCHAR2 DEFAULT NULL);

PROCEDURE loaded      (comp_id      IN VARCHAR2,
                       comp_version IN VARCHAR2 DEFAULT NULL,
                       comp_banner  IN VARCHAR2 DEFAULT NULL);

PROCEDURE upgrading   (comp_id      IN VARCHAR2,
                       new_name     IN VARCHAR2 DEFAULT NULL,
                       new_proc     IN VARCHAR2 DEFAULT NULL,
                       new_schema   IN VARCHAR2 DEFAULT NULL,
                       new_parent   IN VARCHAR2 DEFAULT NULL);

PROCEDURE upgrading   (comp_id      IN VARCHAR2,
                       new_name     IN VARCHAR2,
                       new_proc     IN VARCHAR2,
                       new_schema   IN VARCHAR2,
                       new_schemas  IN schema_list_t,
                       new_parent   IN VARCHAR2 DEFAULT NULL);

PROCEDURE upgraded     (comp_id      IN VARCHAR2,
                       new_version   IN VARCHAR2 DEFAULT NULL,
                       new_banner    IN VARCHAR2 DEFAULT NULL);

PROCEDURE downgrading (comp_id      IN VARCHAR2,
                       old_name     IN VARCHAR2 DEFAULT NULL,
                       old_proc     IN VARCHAR2 DEFAULT NULL,
                       old_schema   IN VARCHAR2 DEFAULT NULL,
                       old_parent   IN VARCHAR2 DEFAULT NULL);

PROCEDURE downgraded  (comp_id      IN VARCHAR2,
                       old_version  IN VARCHAR2 DEFAULT NULL);

PROCEDURE removing    (comp_id      IN VARCHAR2);

PROCEDURE removed     (comp_id      IN VARCHAR2);

PROCEDURE option_off  (comp_id      IN VARCHAR2);

PROCEDURE startup_required (comp_id IN VARCHAR2);

PROCEDURE startup_complete (comp_id IN VARCHAR2);

PROCEDURE reset_version (comp_id      IN VARCHAR2);

PROCEDURE update_schema_list     
                      (comp_id      IN VARCHAR2,
                       comp_schemas IN schema_list_t);

FUNCTION  status_name  (status NUMBER) RETURN VARCHAR2;

FUNCTION  status      (comp_id IN VARCHAR2) RETURN VARCHAR2;

FUNCTION  version     (comp_id IN VARCHAR2) RETURN VARCHAR2;

FUNCTION  prev_version (comp_id IN VARCHAR2) RETURN VARCHAR2;

FUNCTION  version_full (comp_id IN VARCHAR2) RETURN VARCHAR2;

FUNCTION  version_greater (left_version VARCHAR2, right_version VARCHAR2)
  RETURN BOOLEAN;

FUNCTION  edition      (comp_id IN VARCHAR2) RETURN VARCHAR2;

FUNCTION  schema      (comp_id IN VARCHAR2) RETURN VARCHAR2;

FUNCTION  schema_list (comp_id IN VARCHAR2) RETURN schema_list_t;

FUNCTION  schema_list_string  (comp_id IN VARCHAR2) RETURN VARCHAR2;

FUNCTION  subcomponents (comp_id IN VARCHAR2, 
                         comp_option IN NUMBER DEFAULT 1) 
                         RETURN comp_list_t;

FUNCTION  comp_name   (comp_id IN VARCHAR2) RETURN VARCHAR2;

FUNCTION  session_namespace RETURN VARCHAR2;

FUNCTION  script      (comp_id IN VARCHAR2, 
                       script_name IN VARCHAR2) RETURN VARCHAR2;

FUNCTION  script_path  (comp_id IN VARCHAR2) RETURN VARCHAR2;

FUNCTION  script_prefix  (comp_id IN VARCHAR2) RETURN VARCHAR2;

FUNCTION  nothing_script RETURN VARCHAR2;

FUNCTION  is_loaded   (comp_id IN VARCHAR2, 
                       version IN VARCHAR2 DEFAULT NULL) RETURN NUMBER;

FUNCTION  is_valid   (comp_id IN VARCHAR2, 
                       version IN VARCHAR2 DEFAULT NULL) RETURN NUMBER;

FUNCTION  is_startup_required (comp_id IN VARCHAR2) RETURN NUMBER;

FUNCTION  is_component (comp_id VARCHAR2) RETURN BOOLEAN;

FUNCTION  is_server_component (comp_id VARCHAR2) RETURN NUMBER DETERMINISTIC;

FUNCTION  is_in_registry (comp_id IN VARCHAR2) RETURN BOOLEAN;

FUNCTION  count_errors_in_registry (comp_id IN VARCHAR2) RETURN NUMBER;

FUNCTION  is_in_upgrade_mode RETURN BOOLEAN;

FUNCTION  is_trace_event_set(trace_event VARCHAR2) RETURN BOOLEAN;

FUNCTION  is_db_consolidated RETURN BOOLEAN;

FUNCTION  is_db_root         RETURN BOOLEAN;

FUNCTION  is_db_pdb          RETURN BOOLEAN;

FUNCTION  is_db_pdb_seed     RETURN BOOLEAN;

FUNCTION  is_upgrade_running RETURN BOOLEAN;

FUNCTION  is_stats_from_upgrade RETURN BOOLEAN;

FUNCTION  set_session_to_container_name(con_name IN obj$.name%TYPE) RETURN BOOLEAN;

FUNCTION  get_container_name(con_id IN container$.con_id#%TYPE)
          RETURN obj$.name%TYPE;

FUNCTION  set_session_container (con_id IN container$.con_id#%TYPE) RETURN BOOLEAN;

FUNCTION  num_of_exadata_cells RETURN NUMBER;

PROCEDURE check_server_instance;

PROCEDURE set_progress_action (comp_id IN VARCHAR2, 
                               action  IN VARCHAR2, 
                               value   IN VARCHAR2 DEFAULT NULL,
                               step    IN NUMBER DEFAULT NULL);

PROCEDURE delete_progress_action (comp_id IN VARCHAR2,
                                  action  IN VARCHAR2);

PROCEDURE set_progress_value (comp_id IN VARCHAR2, 
                              action  IN VARCHAR2, 
                              value   IN VARCHAR2);

PROCEDURE set_progress_step (comp_id IN VARCHAR2, 
                             action  IN VARCHAR2, 
                             step    IN NUMBER);

FUNCTION get_progress_value (comp_id IN VARCHAR2, 
                             action  IN VARCHAR2) RETURN VARCHAR2;

FUNCTION get_progress_step (comp_id IN VARCHAR2, 
                            action  IN VARCHAR2) RETURN NUMBER;

PROCEDURE set_required_comps (comp_id IN VARCHAR2, 
                              comp_depend_list IN comp_depend_list_t );

PROCEDURE set_required_comps (comp_id IN VARCHAR2, 
                              comp_depend_list IN comp_depend_rec );

FUNCTION get_required_comps (comp_id IN VARCHAR2) RETURN comp_depend_list_t;

FUNCTION get_required_comps_rec (comp_id IN VARCHAR2) RETURN comp_depend_rec;

FUNCTION get_dependent_comps (comp_id IN VARCHAR2) RETURN comp_depend_list_t;

FUNCTION get_dependent_comps_rec (comp_id IN VARCHAR2) RETURN comp_depend_rec;

PROCEDURE set_edition (comp_id      IN VARCHAR2);

PROCEDURE set_edition (comp_id      IN VARCHAR2,
                       edition_var  IN VARCHAR2);

FUNCTION get_con_id RETURN NUMBER;

PROCEDURE RU_apply    (comp_version      IN VARCHAR2  DEFAULT NULL,
                       build_description IN VARCHAR2  DEFAULT NULL,
                       build_timestamp   IN TIMESTAMP DEFAULT NULL);

PROCEDURE RU_rollback (comp_version      IN VARCHAR2  DEFAULT NULL,
                       build_description IN VARCHAR2  DEFAULT NULL,
                       build_timestamp   IN TIMESTAMP DEFAULT NULL);

END dbms_registry;
/

show errors

CREATE OR REPLACE PUBLIC SYNONYM dbms_registry FOR dbms_registry;

GRANT EXECUTE ON dbms_registry TO execute_catalog_role;

--------------------------------------------------------------------
--  Internal functions used by SYS during upgrade/downgrade
--------------------------------------------------------------------

CREATE OR REPLACE PACKAGE dbms_registry_sys
AS

PROCEDURE drop_user  (username IN VARCHAR2);
 
PROCEDURE validate_catalog;

PROCEDURE validate_catproc;

PROCEDURE validate_catjava;

PROCEDURE validate_components;

FUNCTION  time_stamp   (comp_id IN VARCHAR2) RETURN VARCHAR2;

FUNCTION  time_stamp_display (comp_id IN VARCHAR2) RETURN VARCHAR2;

FUNCTION  time_stamp_comp_display (comp_id IN VARCHAR2) RETURN VARCHAR2;

FUNCTION  catcon_query (comp_id IN VARCHAR2) RETURN NUMBER;

FUNCTION  dbupg_script (comp_id IN VARCHAR2) RETURN VARCHAR2;

FUNCTION  dbdwg_script (comp_id IN VARCHAR2) RETURN VARCHAR2;

FUNCTION  relod_script (comp_id IN VARCHAR2) RETURN VARCHAR2;

FUNCTION  removal_script (comp_id IN VARCHAR2) RETURN VARCHAR2;

PROCEDURE check_component_downgrades;

PROCEDURE record_action (action    IN VARCHAR2, 
                         action_id IN NUMBER,
                         comments  IN VARCHAR2);

FUNCTION diagnostics RETURN NUMBER;

PROCEDURE gather_stats (comp_id IN VARCHAR2);

PROCEDURE populate;

FUNCTION select_props_data (pname IN VARCHAR2) RETURN BOOLEAN;

FUNCTION delete_props_data (pname IN VARCHAR2) RETURN BOOLEAN;

FUNCTION insert_props_data (pname    IN VARCHAR2,
                            pvalue   IN VARCHAR2, 
                            pcomment IN VARCHAR2) RETURN BOOLEAN;

FUNCTION update_props_data (pname    IN VARCHAR2,
                            pvalue   IN VARCHAR2) RETURN BOOLEAN;

PROCEDURE set_registry_context (ctx_variable IN VARCHAR2,
                                ctx_value    IN VARCHAR2);

FUNCTION utlmmig_script_name RETURN VARCHAR2;

PROCEDURE resolve_catjava;

FUNCTION capitalize_single_quoted(comp IN VARCHAR2) RETURN VARCHAR2;

END dbms_registry_sys;
/

show errors

Rem -------------------------------------------------------------------------
Rem DBA_REGISTRY view
Rem -------------------------------------------------------------------------

CREATE OR REPLACE VIEW dba_registry (
            comp_id, comp_name, version, version_full, status,
            modified, namespace, control, schema, procedure,
            startup, parent_id, other_schemas)
AS
SELECT r.cid, r.cname, r.version, r.version_full,
       SUBSTR(dbms_registry.status_name(r.status),1,11),
       TO_CHAR(r.modified,'DD-MON-YYYY HH24:MI:SS'), 
       r.namespace, i.name, s.name, r.vproc,
       DECODE(bitand(r.flags,1),1,'REQUIRED',NULL), r.pid,
       dbms_registry.schema_list_string(r.cid)
FROM registry$ r, user$ s, user$ i
WHERE r.schema# = s.user# AND r.invoker#=i.user#;
         
CREATE OR REPLACE PUBLIC SYNONYM dba_registry FOR dba_registry;
GRANT SELECT ON dba_registry TO SELECT_CATALOG_ROLE;


execute CDBView.create_cdbview(false,'SYS','DBA_REGISTRY','CDB_REGISTRY');
grant select on SYS.CDB_registry to select_catalog_role
/
create or replace public synonym CDB_registry for SYS.CDB_registry
/

Rem -------------------------------------------------------------------------
Rem DBA_SERVER_REGISTRY view
Rem -------------------------------------------------------------------------

CREATE OR REPLACE VIEW dba_server_registry (
            comp_id, comp_name, version, version_full, status,
            modified, control, schema, procedure,
            startup, parent_id, other_schemas)
AS 
SELECT comp_id, comp_name, version, version_full, status,
       modified, control, schema, procedure,
       startup, parent_id, other_schemas
FROM dba_registry 
WHERE namespace='SERVER';

CREATE OR REPLACE PUBLIC SYNONYM dba_server_registry FOR dba_server_registry;
GRANT SELECT ON dba_server_registry TO SELECT_CATALOG_ROLE;


execute CDBView.create_cdbview(false,'SYS','DBA_SERVER_REGISTRY','CDB_SERVER_REGISTRY');
grant select on SYS.CDB_server_registry to select_catalog_role
/
create or replace public synonym CDB_server_registry for SYS.CDB_server_registry
/

Rem -------------------------------------------------------------------------
Rem USER_REGISTRY view
Rem -------------------------------------------------------------------------

CREATE OR REPLACE VIEW user_registry (
            comp_id, comp_name, version, version_full, status,
            modified, namespace, control, schema, procedure,
            startup, parent_id, other_schemas)
AS
SELECT r.cid, r.cname, r.version, r.version_full,
       SUBSTR(dbms_registry.status_name(r.status),1,11),
       TO_CHAR(r.modified,'DD-MON-YYYY HH24:MI:SS'), 
       r.namespace, i.name, s.name, r.vproc,
       DECODE(bitand(r.flags,1),1,'REQUIRED',NULL), r.pid,
       dbms_registry.schema_list_string(r.cid)
FROM registry$ r, user$ s, user$ i
WHERE (r.schema# = USERENV('SCHEMAID') OR r.invoker# = USERENV('SCHEMAID'))
      AND r.schema# = s.user# AND r.invoker#=i.user#;

CREATE OR REPLACE PUBLIC SYNONYM user_registry FOR user_registry;
GRANT READ ON user_registry TO PUBLIC;

Rem -------------------------------------------------------------------------
Rem DBA_REGISTRY_HIERARCHY view
Rem -------------------------------------------------------------------------

CREATE OR REPLACE VIEW dba_registry_hierarchy (
            namespace, comp_id, version, version_full, status, modified)
AS
SELECT namespace, LPAD(' ',2*(LEVEL-1)) || LEVEL || ' ' || cid, version,
       version_full, SUBSTR(dbms_registry.status_name(status),1,11),
       TO_CHAR(modified,'DD-MON-YYYY HH24:MI:SS')
FROM registry$ 
START WITH pid IS NULL
CONNECT BY PRIOR cid = pid and PRIOR namespace = namespace;

CREATE OR REPLACE PUBLIC SYNONYM dba_registry_hierarchy 
                  FOR dba_registry_hierarchy;
GRANT SELECT ON dba_registry_hierarchy TO SELECT_CATALOG_ROLE;


execute CDBView.create_cdbview(false,'SYS','DBA_REGISTRY_HIERARCHY','CDB_REGISTRY_HIERARCHY');
grant select on SYS.CDB_registry_hierarchy to select_catalog_role
/
create or replace public synonym CDB_registry_hierarchy for SYS.CDB_registry_hierarchy
/

Rem -------------------------------------------------------------------------
Rem ALL_REGISTRY_BANNERS view
Rem    Public view of valid components in the database
Rem -------------------------------------------------------------------------

CREATE OR REPLACE VIEW all_registry_banners 
AS
SELECT banner, banner_full FROM registry$
WHERE status = 1; 

CREATE OR REPLACE PUBLIC SYNONYM all_registry_banners
                  FOR all_registry_banners;
GRANT READ ON all_registry_banners TO PUBLIC;

Rem -------------------------------------------------------------------------
Rem  CREATE log view 
Rem -------------------------------------------------------------------------

CREATE OR REPLACE VIEW dba_registry_log (
            optime, namespace, comp_id, operation, message)
AS
SELECT optime,
       namespace, cid,
       DECODE(operation,-1, 'START',
                         0, 'INVALID',
                         1, 'VALID',
                         2, 'LOADING',
                         3, 'LOADED',
                         4, 'UPGRADING',
                         5, 'UPGRADED',
                         6, 'DOWNGRADING',
                         7, 'DOWNGRADED',
                         8, 'REMOVING',
                         9, 'OPTION OFF',
                         10, 'NO SCRIPT',
                         99, 'REMOVED',
                         100, 'ERROR',
                         NULL),
       errmsg
FROM registry$log;

CREATE OR REPLACE PUBLIC SYNONYM dba_registry_log
                  FOR dba_registry_log;
GRANT SELECT ON dba_registry_log TO SELECT_CATALOG_ROLE;


execute CDBView.create_cdbview(false,'SYS','DBA_REGISTRY_LOG','CDB_REGISTRY_LOG');
grant select on SYS.CDB_registry_log to select_catalog_role
/
create or replace public synonym CDB_registry_log for SYS.CDB_registry_log
/

Rem -------------------------------------------------------------------------
Rem CREATE history VIEW
Rem -------------------------------------------------------------------------

CREATE OR REPLACE VIEW dba_registry_history (
  action_time, action, namespace, version, id, comments, bundle_series)
AS
SELECT action_time, action, namespace, version, id, comments, bundle_series
  FROM registry$history;

CREATE OR REPLACE PUBLIC SYNONYM dba_registry_history FOR dba_registry_history;
GRANT SELECT ON dba_registry_history TO SELECT_CATALOG_ROLE;



execute CDBView.create_cdbview(false,'SYS','DBA_REGISTRY_HISTORY','CDB_REGISTRY_HISTORY');
grant select on SYS.CDB_registry_history to select_catalog_role
/
create or replace public synonym CDB_registry_history for SYS.CDB_registry_history
/

Rem -------------------------------------------------------------------------
Rem CREATE progress VIEW
Rem -------------------------------------------------------------------------

CREATE OR REPLACE VIEW dba_registry_progress (
            comp_id, namespace, action, value, step, action_time)
AS
SELECT  cid, namespace, action, value, step, action_time
FROM registry$progress;

CREATE OR REPLACE PUBLIC SYNONYM dba_registry_progress 
                  FOR dba_registry_progress;
GRANT SELECT ON dba_registry_progress TO SELECT_CATALOG_ROLE;


execute CDBView.create_cdbview(false,'SYS','DBA_REGISTRY_PROGRESS','CDB_REGISTRY_PROGRESS');
grant select on SYS.CDB_registry_progress to select_catalog_role
/
create or replace public synonym CDB_registry_progress for SYS.CDB_registry_progress
/

Rem -------------------------------------------------------------------------
Rem CREATE dependencies VIEW
Rem -------------------------------------------------------------------------

CREATE OR REPLACE VIEW dba_registry_dependencies (
            comp_id, namespace, req_comp_id, req_namespace)
AS
SELECT  cid, namespace, req_cid, req_namespace
FROM registry$dependencies;

CREATE OR REPLACE PUBLIC SYNONYM dba_registry_dependencies 
                  FOR dba_registry_dependencies;
GRANT SELECT ON dba_registry_dependencies TO SELECT_CATALOG_ROLE;


execute CDBView.create_cdbview(false,'SYS','DBA_REGISTRY_DEPENDENCIES','CDB_REGISTRY_DEPENDENCIES');
grant select on SYS.CDB_registry_dependencies to select_catalog_role
/
create or replace public synonym CDB_registry_dependencies for SYS.CDB_registry_dependencies
/

Rem -------------------------------------------------------------------------
Rem CREATE database VIEW
Rem -------------------------------------------------------------------------
 
CREATE OR REPLACE VIEW dba_registry_database (
            platform_id, platform_name, edition)
AS
SELECT  platform_id, platform_name, edition
FROM registry$database;
 
CREATE OR REPLACE PUBLIC SYNONYM dba_registry_database
                   FOR dba_registry_database;
GRANT SELECT ON dba_registry_database TO SELECT_CATALOG_ROLE;


execute CDBView.create_cdbview(false,'SYS','DBA_REGISTRY_DATABASE','CDB_REGISTRY_DATABASE');
grant select on SYS.CDB_registry_database to select_catalog_role
/
create or replace public synonym CDB_registry_database for SYS.CDB_registry_database
/

Rem -------------------------------------------------------------------------
Rem CREATE error VIEWs from registry$error table
Rem -------------------------------------------------------------------------

-- dba_registry_error
create or replace view DBA_REGISTRY_ERROR
as
select * from sys.registry$error;

create or replace public synonym DBA_REGISTRY_ERROR for SYS.DBA_REGISTRY_ERROR;
grant select on DBA_REGISTRY_ERROR to select_catalog_role;

-- cdb_registry_error
execute CDBView.create_cdbview(false,'SYS','DBA_REGISTRY_ERROR','CDB_REGISTRY_ERROR');
grant select on SYS.CDB_REGISTRY_ERROR to select_catalog_role
/
create or replace public synonym CDB_REGISTRY_ERROR for SYS.CDB_REGISTRY_ERROR
/

Rem -------------------------------------------------------------------------
Rem CREATE schemas VIEW
Rem -------------------------------------------------------------------------
 
CREATE OR REPLACE VIEW dba_registry_schemas (
            namespace, comp_id, schema)
AS
  SELECT r.namespace, r.cid as comp_id, u.name as schema
    FROM registry$ r, user$ u
    WHERE r.schema#  = u.user#
  UNION ALL
     SELECT r.namespace, r.cid as comp_id, u.name as schema
     FROM registry$ r, registry$schemas s, user$ u
     WHERE r.cid = s.cid
           and s.schema# = u.user#
/
 
CREATE OR REPLACE PUBLIC SYNONYM dba_registry_schemas
                   FOR dba_registry_schemas;
GRANT SELECT ON dba_registry_schemas TO SELECT_CATALOG_ROLE;

execute CDBView.create_cdbview(false,'SYS','DBA_REGISTRY_SCHEMAS','CDB_REGISTRY_SCHEMAS');
create or replace public synonym CDB_registry_schemas for SYS.CDB_registry_schemas;
grant select on SYS.CDB_registry_schemas to select_catalog_role;

-- disable _oracle_script on script exit
@@?/rdbms/admin/sqlsessend.sql
