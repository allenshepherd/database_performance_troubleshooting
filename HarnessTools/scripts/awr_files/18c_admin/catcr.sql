Rem
Rem $Header: rdbms/admin/catcr.sql /main/61 2017/10/10 12:10:25 raeburns Exp $
Rem
Rem catcr.sql
Rem
Rem Copyright (c) 2001, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catcr.sql - CATalog Component Registry
Rem
Rem    DESCRIPTION
Rem      This script creates the data dictionary elements and package for
Rem      the registry of components that have been loaded into the database.
Rem
Rem    NOTES
Rem      Use SQLPLUS
Rem      Conned AS SYSDBA
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catcr.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catcr.sql
Rem SQL_PHASE: CATCR
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/cdstrt.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    raeburns    09/18/17 - Bug 26815460: Use v$instance.version_full
Rem    raeburns    09/10/17 - Bug 26255427: Store version_full for components
Rem    rtattuku    06/22/17 - version change from cdilling
Rem    raeburns    05/13/17 - version change - add dbms_registry_basic.sql
Rem    cmlim       02/08/16 - bug 22651705: fix the criteria in loaded() when
Rem                           prv_version and org_version are updated
Rem    cmlim       03/26/15 - bug 20756240: support long identifiers in
Rem                           validation procedure names
Rem    cmlim       12/09/14 - support long identifiers in upgrade-owned pkgs
Rem    surman      06/14/14 - 18977120: Add bundle_series to registry$history
Rem    surman      04/21/14 - 17277459: Seperate script for SQL registry
Rem    surman      03/19/14 - 17665117: Patch UID
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    jerrede     11/14/13 - Add summary table for DBUA
Rem    surman      10/31/13 - 17277459: Add bundle columns to registry$sqlpatch
Rem    surman      10/24/13 - 14563594: Add version to registry$sqlpatch
Rem    surman      09/13/12 - 14624172: Add status column
Rem    surman      09/07/12 - 14563601: Increase size of logfile to account for
Rem                           timestamps
Rem    surman      05/17/12 - 14087480: Proper constraint on SQL registry
Rem    jerrede     05/11/12 - Added date_optionoff to registry$
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    surman      02/08/12 - 13615515: SQL registry table
Rem    sankejai    04/10/11 - create dbms_registry as local to the container
Rem                           in a consolidated database
Rem    cdilling    10/17/10 - add edition and signature to registry$
Rem    rburns      05/25/07 - add timezone file version
Rem    cdilling    11/09/06 - add registry$database table
Rem    cdilling    06/08/06 - add table registry$error
Rem    cdilling    06/06/06 - add registry$dependencies table 
Rem    rburns      05/25/06 - add start rows 
Rem    cdilling    05/18/06 - add registry$progress table 
Rem    rburns      02/15/06 - back to timestamp
Rem    rburns      11/30/05 - use date instead of timestamp for history
Rem    rburns      02/22/05 - add table for upgrade history
Rem    rburns      06/17/04 - remove registry log from loading and loaded
Rem    rburns      06/15/04 - add more procedures to dbms_registry 
Rem    rburns      05/14/04 - add schema list to registry 
Rem    rburns      02/03/04 - add error log table
Rem    rburns      11/07/03 - add new status values 
Rem    rburns      03/18/03 - add catcrsc.sql
Rem    rburns      01/13/03 - fix synonym, loaded procedure and versions
Rem    rburns      11/01/02 - add iAS functionality 
Rem    rburns      11/27/02 - move packages to prvtcr.sql
Rem    tbgraves    11/26/02 - add SYSTEM and SYSAUX tablespace calculations to 
Rem                           timestamp procedure; move internal function 
Rem                           declarations 
Rem    rburns      11/18/02 - use ORA- errors for check_server_instance
Rem    rburns      11/12/02 - set session nls_length_semantics
Rem                         - add check_server_instance interface
Rem    rburns      07/24/02 - change timestamp format
Rem    rburns      04/10/02 - always use full path for nothing.sql
Rem    rburns      04/10/02 - no script for removed components
Rem    rburns      03/27/02 - add 10i interfaces
Rem    rburns      03/08/02 - fix Intermedia populate
Rem    rburns      02/14/02 - change AMD name and fix ORDIM and SDO names
Rem    rburns      02/11/02 - add registry version
Rem    rburns      02/06/02 - add MGW component
Rem    rburns      02/04/02 - fix ODM populate
Rem    rburns      01/09/02 - fix intermedia populate and permission check
Rem    rburns      12/15/01 - add catjava
Rem    rburns      12/12/01 - MDSYS for Spatial
Rem    rburns      12/10/01 - fix validate procedure
Rem    rburns      12/06/01 - add other components
Rem    rburns      10/26/01 - add registry validation procedure
Rem    smavris     11/08/01 - Update interMedia registry
Rem    rburns      10/23/01 - fix views, add drop_user
Rem    rburns      10/15/01 - add owm, ols, and new registry columns
Rem    rburns      10/02/01 - add JAVAVM and new interfaces
Rem    rburns      09/20/01 - add flags column for restart, new interfaces
Rem    rburns      08/30/01 - Merged rburns_component_registry
Rem    rburns      08/15/01 - Created
Rem
Rem ------------------------------------------------------------------------
Rem REGISTRY$ table
Rem ------------------------------------------------------------------------

@@?/rdbms/admin/sqlsessstart.sql

-- set SQLPLUS variables for use in dbms_registry package
@@dbms_registry_basic.sql

Rem -------------------------------------------------------------------------
Rem DBMS REGISTRY PACKAGE - minimal version for loading CATALOG
Rem -------------------------------------------------------------------------

CREATE OR REPLACE PACKAGE dbms_registry SHARING=NONE AS

PROCEDURE loading     (comp_id      IN VARCHAR2,
                       comp_name    IN VARCHAR2,
                       comp_proc    IN VARCHAR2 DEFAULT NULL,
                       comp_schema  IN VARCHAR2 DEFAULT NULL,
                       comp_parent  IN VARCHAR2 DEFAULT NULL);

PROCEDURE loaded      (comp_id      IN VARCHAR2,
                       comp_version IN VARCHAR2 DEFAULT NULL,
                       comp_banner  IN VARCHAR2 DEFAULT NULL);

FUNCTION  time_stamp  (comp_id IN VARCHAR2) RETURN VARCHAR2; 

PROCEDURE check_server_instance;

END dbms_registry;
/

CREATE OR REPLACE PACKAGE BODY dbms_registry SHARING=NONE
AS

-- STATUS
 
  s_invalid     NUMBER :=0;
  s_valid       NUMBER :=1;
  s_loading     NUMBER :=2;
  s_loaded      NUMBER :=3;
  s_removing    NUMBER :=8;
  s_removed     NUMBER :=99;   

no_component    EXCEPTION;
PRAGMA          EXCEPTION_INIT(no_component, -39705);

not_invoker     EXCEPTION;
PRAGMA          EXCEPTION_INIT(not_invoker, -39704);

-- GLOBAL

g_null         CHAR(1);

----------------------------------------------------------------------
-- PRIVATE FUNCTIONS
----------------------------------------------------------------------

FUNCTION version_greater (left_version VARCHAR2, right_version VARCHAR2)
RETURN BOOLEAN
IS

p_left_version  sys.registry$.version%type := left_version;
p_right_version sys.registry$.version%type := right_version;

left_dot    NUMBER;
right_dot   NUMBER;  
left_number  NUMBER;
right_number NUMBER;

BEGIN
  FOR i IN 1..5 LOOP   -- up to 5 digits to process

     IF p_left_version IS NULL THEN  -- NULL cannot be greater than anything
        RETURN FALSE;
     END IF;

 -- Locate separators
     left_dot := INSTR(p_left_version, '.',1);
     IF left_dot = 0 THEN
        left_dot := INSTR(p_left_version, ' ',1);  -- If no dot, look for space
     END IF;

     right_dot := INSTR(p_right_version,'.',1);
     IF right_dot = 0 THEN
        right_dot := INSTR(p_right_version, ' ',1); -- If no dot, look space
     END IF;

     -- Set left and right digits
     IF left_dot = 0 THEN
        left_number  := TO_NUMBER(p_left_version);   -- use rest of string
     ELSE
        left_number  := TO_NUMBER(SUBSTR(p_left_version,  1, left_dot-1));  
     END IF; 
     IF right_dot = 0  THEN
        right_number := TO_NUMBER(p_right_version);  -- use rest of string
     ELSE
        right_number := TO_NUMBER(SUBSTR(p_right_version, 1, right_dot-1));
     END IF;

-- Compare left and right digits 
     IF left_number > right_number OR right_number IS NULL THEN
        RETURN TRUE;
     ELSIF right_number > left_number OR left_number is NULL THEN
        RETURN FALSE;
     END IF;

-- Numbers are equal, so advance string to next digit if there is one
     IF left_dot = 0 THEN 
        p_left_version := NULL;
     ELSE
        p_left_version  := SUBSTR(p_left_version,  left_dot+1);
     END IF;
     IF right_dot = 0 THEN
        p_right_version := NULL;
     ELSE
        p_right_version := SUBSTR(p_right_version, right_dot+1);
     END IF;
  
   END LOOP;

-- If loop ends, then all digits are equal, so return false
   RETURN FALSE;

EXCEPTION  -- some comparison digit is non-numeric
   WHEN OTHERS THEN RETURN FALSE;

END version_greater;

------------------------- exists_comp --------------------------------

FUNCTION exists_comp (id IN VARCHAR2) RETURN BOOLEAN
IS
BEGIN
  SELECT NULL INTO g_null FROM sys.registry$
  WHERE cid = id AND namespace='SERVER';
  RETURN TRUE;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN FALSE;
END exists_comp;

------------------------- get_user --------------------------------

FUNCTION get_user RETURN NUMBER
IS

p_user# NUMBER;

BEGIN
  SELECT user# INTO p_user# FROM sys.user$
  WHERE name = SYS_CONTEXT ('USERENV', 'SESSION_USER');
  RETURN p_user#;
END get_user;

--------------------------------------------------------------------

FUNCTION get_user(usr IN VARCHAR2) RETURN NUMBER
IS

p_user# NUMBER;

BEGIN
  SELECT user# INTO p_user# FROM sys.user$
  WHERE name = usr;
  RETURN p_user#;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
     RAISE not_invoker;
END get_user;


------------------------- check_invoker --------------------------------

PROCEDURE check_invoker (id IN VARCHAR2, usr# IN NUMBER)
IS 
BEGIN
  SELECT NULL into g_null from sys.registry$
  WHERE id = cid AND namespace='SERVER' AND 
        (usr# = invoker# OR usr# = schema#);

EXCEPTION
  WHEN NO_DATA_FOUND THEN
     RAISE not_invoker;
END check_invoker;

------------------------- new_comp --------------------------------

PROCEDURE new_comp (st     IN VARCHAR2,
                    id     IN VARCHAR2, 
                    nme    IN VARCHAR2, 
                    prc    IN VARCHAR2,
                    par    IN VARCHAR2,
                    inv#   IN NUMBER,
                    sch#   IN NUMBER)
IS 
  openmigrate v$instance.status%TYPE;
BEGIN

  IF par IS NOT NULL THEN
     IF NOT exists_comp(par) THEN
        RAISE no_component;
     END IF;
  END IF;
  INSERT INTO sys.registry$ (modified, status, cid, cname, 
                             pid, vproc, invoker#, schema#, flags,
                             namespace)
         VALUES (SYSDATE, st, id, nme, par, prc, inv#, sch#, 0,
                 'SERVER');
END new_comp;


------------------------- update_comp --------------------------------

PROCEDURE update_comp (st     IN VARCHAR2,
                       id     IN VARCHAR2, 
                       nme    IN VARCHAR2, 
                       prc    IN VARCHAR2,
                       par    IN VARCHAR2,
                       ver    IN VARCHAR2,
                       ban    IN VARCHAR2)

IS 
  openmigrate v$instance.status%TYPE;
BEGIN

  IF par IS NOT NULL THEN
     IF NOT exists_comp(par) THEN
        RAISE no_component;
     END IF;
  END IF;

  UPDATE sys.registry$ SET status = st, modified = SYSDATE WHERE id = cid AND
         namespace='SERVER'; 

  IF nme IS NOT NULL THEN
     UPDATE sys.registry$ SET cname = nme WHERE id = cid AND
         namespace='SERVER'; 
  END IF;
  IF par IS NOT NULL THEN
     UPDATE sys.registry$ SET pid = par WHERE id = cid AND
         namespace='SERVER'; 
  END IF;
  IF prc IS NOT NULL THEN
     UPDATE sys.registry$ SET vproc = prc WHERE id = cid AND
         namespace='SERVER'; 
  END IF;
  IF ver IS NOT NULL THEN
     UPDATE sys.registry$ SET version = ver WHERE id = cid AND
         namespace='SERVER'; 
  END IF;
  IF ban IS NOT NULL THEN
     UPDATE sys.registry$ SET banner = ban WHERE id = cid AND
         namespace='SERVER'; 
  END IF;

END update_comp;

FUNCTION  comp_name  (comp_id IN VARCHAR2) RETURN VARCHAR2
IS

p_id      registry$.cid%TYPE :=NLS_UPPER(comp_id);
p_name    registry$.cname%TYPE;

BEGIN
   SELECT cname INTO p_name FROM sys.registry$ WHERE cid=p_id AND
         namespace='SERVER'; 
   RETURN p_name;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
     RETURN NULL;

END comp_name;
  
----------------------------------------------------------------------
-- PUBLIC FUNCTIONS
----------------------------------------------------------------------

------------------------- LOADING ------------------------------------

PROCEDURE loading     (comp_id      IN VARCHAR2,
                       comp_name    IN VARCHAR2,
                       comp_proc    IN VARCHAR2 DEFAULT NULL,
                       comp_schema  IN VARCHAR2 DEFAULT NULL,
                       comp_parent  IN VARCHAR2 DEFAULT NULL)
IS

p_id      VARCHAR2(30) :=NLS_UPPER(comp_id);
p_name    VARCHAR2(255):=comp_name;
p_proc    dbms_id      :=NLS_UPPER(comp_proc);
p_schema  dbms_id      :=NLS_UPPER(comp_schema);
p_parent  VARCHAR2(30) :=NLS_UPPER(comp_parent);
p_invoker#   NUMBER    :=get_user;
p_schema#    NUMBER;

BEGIN
  IF p_schema IS NOT NULL then
     p_schema#:=get_user(p_schema);
  ELSE
     p_schema#:=p_invoker#;
  END IF;

  IF exists_comp(p_id) THEN
     check_invoker(p_id,p_invoker#);
     update_comp(s_loading, p_id, p_name, p_proc, p_parent, NULL, NULL);
     update sys.registry$ set schema# = p_schema#, 
            date_loading = SYSDATE 
            where cid=p_id AND
            namespace = 'SERVER'; 
  ELSE
     new_comp(s_loading, p_id, p_name, p_proc, p_parent, 
              p_invoker#, p_schema#); 
     update sys.registry$ set date_loading = SYSDATE where cid=p_id AND
        namespace = 'SERVER';
END IF;
commit;

END loading;

-------------------------- LOADED -------------------------------------

PROCEDURE loaded      (comp_id      IN VARCHAR2,
                       comp_version IN VARCHAR2 DEFAULT NULL,
                       comp_banner  IN VARCHAR2 DEFAULT NULL)
IS

p_id      VARCHAR2(30) :=NLS_UPPER(comp_id);
p_version sys.registry$.version%type := NLS_UPPER(comp_version);
p_version_full sys.registry$.version_full%type;
p_banner  sys.registry$.banner%type := comp_banner;
p_banner_full  sys.registry$.banner_full%type;
p_invoker#   NUMBER       :=get_user;
p_cur_version sys.registry$.version%type;  -- current version for CATALOG

BEGIN
  
IF exists_comp(p_id) THEN
   check_invoker(p_id, p_invoker#);
   IF p_version IS NULL THEN  -- use values from v$instance
--    Bug 26815460 get full version
      SELECT version, version_full INTO p_version, p_version_full 
      FROM v$instance;
   ELSE -- use supplied version for full version as well
      p_version_full := p_version;
   END IF;

   SELECT version INTO p_cur_version FROM sys.registry$
     where cid = p_id;
   IF p_cur_version IS NULL THEN -- set original version
      update registry$ set org_version = p_version,
          org_version_full = p_version_full
      where cid=p_id AND namespace = 'SERVER' and org_version IS NULL;     
    ELSIF version_greater(p_version, p_cur_version) THEN 
      -- the procedure is being called during an upgrade, so if the
      -- version is changing, also update the prv_version and if
      -- the org_version has not been set, update it.
      update registry$ set prv_version = version,
             prv_version_full = version_full 
      where cid=p_id AND
            namespace = 'SERVER';
      -- if org_version is not set, then also set it
      update registry$ set org_version = version,
             org_version_full = version_full 
      where org_version is NULL AND cid=p_id AND
            namespace = 'SERVER';
   END IF;
   IF p_banner IS NULL THEN
      p_banner:= dbms_registry.comp_name(p_id) || ' Release ' ||
          p_version || ' - ' || '&C_ORACLE_HIGH_STATUS';     
   END IF;
   update_comp(s_loaded, p_id, NULL, NULL, NULL, p_version, p_banner);
   update registry$ set date_loaded = SYSDATE,
          version_full = p_version_full 
   where cid=p_id AND namespace = 'SERVER';
   -- Bug 26255427 store banner_full
   update registry$ set banner_full = p_banner || '
 Version ' || p_version_full 
   where cid=p_id AND namespace = 'SERVER';
   commit;
ELSE
   raise NO_COMPONENT;
END IF;

END loaded;

-------------------------- TIME --------------------------------

FUNCTION time_stamp (comp_id IN VARCHAR2) RETURN VARCHAR2 
IS

p_cid    VARCHAR2(30) := NLS_UPPER(comp_id);
p_null   CHAR(1);
p_string VARCHAR2(200);

BEGIN
  SELECT NULL INTO p_null FROM registry$
  WHERE cid = p_cid AND status NOT IN (s_removing, s_removed) AND 
        namespace = 'SERVER';
  p_string:='COMP_TIMESTAMP ' ||
             RPAD(p_cid,10) || ' ' || 
             TO_CHAR(SYSTIMESTAMP,'YYYY-MM-DD HH24:MI:SS ');
  RETURN p_string;
EXCEPTION
  WHEN NO_DATA_FOUND THEN 
     RETURN NULL;
END time_stamp;

----------------- CHECK_SERVER_INSTANCE ---------------------------

PROCEDURE check_server_instance
IS

  openmigrate     VARCHAR2(30);
  vers            VARCHAR2(30);

BEGIN

-- See if server version and script version match. Raise an error if no match.
   select substr(version,1,6) into vers from v$instance;
   if vers != '10.2.0' then
      RAISE_APPLICATION_ERROR(-20000,'server version does not match script');
   end if;

-- verify open for migrate
   select status into openmigrate from v$instance;
   if openmigrate != 'OPEN MIGRATE' then
      RAISE_APPLICATION_ERROR(-20000,'database not open for UPGRADE');
   end if;

-- avoid use of CHAR semantics in dictionary objects
   execute immediate 'ALTER SESSION SET NLS_LENGTH_SEMANTICS = BYTE';

-- turn off PL/SQL event used by APPS
   execute immediate 'ALTER SESSION SET EVENTS=''10933 trace name context off''';

END check_server_instance;
                    
END dbms_registry;
/

show errors

Rem Server Components script
@@catcrsc


@?/rdbms/admin/sqlsessend.sql
