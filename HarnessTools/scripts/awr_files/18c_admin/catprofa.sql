Rem
Rem $Header: rdbms/admin/catprofa.sql /main/19 2017/06/26 16:01:18 pjulsaks Exp $
Rem
Rem catprofa.sql
Rem
Rem Copyright (c) 2010, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catprofa.sql - Privilege Capture Views
Rem
Rem    DESCRIPTION
Rem      Views for privilege capture
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catprofa.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catprofa.sql
Rem SQL_PHASE: CATPROFA
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catproftab.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    pjulsaks    06/26/17 - Bug 25688154: Uppercase create_cdbview's input
Rem    thbaby      03/13/17 - Bug 25688154: upper case owner name
Rem    lutan       01/30/17 - bug22902825: add run_name to dba_priv_captures
Rem    youyang     11/03/15 - bug22068074:fix unused_grant view for capture
Rem                           without run
Rem    rajeekku    08/06/15 - Proj 57189: Inherit remote Privileges changes
Rem    jibyun      05/29/15 - Bug 17976112: add dba_checked_roles and
Rem                           dba_checked_roles_path views
Rem    youyang     03/03/15 - bug20137899:redefine dba_used_privs with correct
Rem                           run_name
Rem    youyang     08/17/14 - change views to add run names
Rem    jheng       02/10/14 - Remove duplicate records from dba_used_privs
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    jheng       12/19/13 - Bug 17969234: filter empty records
Rem    jheng       08/06/13 - Bug 16931220: modify DBA_USED_PUBPRIVS view since
Rem                           grant_path is changed as varray
Rem    talliu      06/28/13 - Add CDB view for DBA view
Rem    jheng       08/13/12 - Add user privilege
Rem    jheng       07/18/12 - Change column enabled to boolean
Rem    jheng       04/24/12 - Bug 12696127: remove sessionid
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    jheng       12/01/11 - Change view names
Rem    jheng       09/06/11 - bug 12876448: fix role type profile report
Rem    jheng       11/19/10 - privilege usage analysis
Rem    jheng       11/19/10 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

CREATE OR REPLACE FUNCTION sys.grantpath_to_string(path IN grant_path)
RETURN VARCHAR2 IS 
  result VARCHAR2(19350) := null; -- grant_path (150*128) + delimiter(1*150)
BEGIN
 IF path is null OR path.count = 0 THEN
   return result;
 END IF;

 FOR i IN path.FIRST .. path.LAST LOOP
    result := result || ',' || path(i);
 END LOOP;

 RETURN substr(result, 2); -- remove the leading delimiter
END;
/
show errors;

CREATE OR REPLACE FUNCTION sys.string_to_grantpath(path in varchar2)
RETURN grant_path IS 
  result grant_path := grant_path();
  prev   number := 1;
  curr   number := 0;
BEGIN  
  IF path is null THEN
    return result;
  END IF;

  curr := instr(path, ',', prev);
  WHILE curr != 0 LOOP
    result.extend;
    result(result.count) := substr(path, prev, curr-prev);
    prev := curr+1;
    curr := instr(path, ',', prev);
  END LOOP;
  result.extend;
  result(result.count) := substr(path, prev);

  RETURN result;
END;
/
show errors;

-- DBA view to show the existing captures

CREATE OR REPLACE VIEW SYS.DBA_PRIV_CAPTURES(name, description, type, enabled, roles, context, run_name)
AS
SELECT name, description, 
decode(type, 1, 'DATABASE', 2, 'ROLE', 3, 'CONTEXT', 4, 'ROLE_AND_CONTEXT') type, decode(enabled * decode((r.run_seq# - p.run_seq#),0,1,0), 1, 'Y', 0, 'N') enabled, roles, context, run_name
FROM sys.priv_capture$ p left join sys.capture_run_log$ r
ON p.id# = r.capture;

execute SYS.CDBView.create_cdbview(false,'SYS','DBA_PRIV_CAPTURES','CDB_PRIV_CAPTURES');
create or replace public synonym CDB_PRIV_CAPTURES for sys.CDB_PRIV_CAPTURES;
grant select on CDB_PRIV_CAPTURES to CAPTURE_ADMIN;

--DBA view to show captured privileges for all captures
CREATE OR REPLACE VIEW SYS.DBA_USED_PRIVS (CAPTURE, SEQUENCE, OS_USER, USERHOST, MODULE, USERNAME, USED_ROLE, SYS_PRIV, OBJ_PRIV, USER_PRIV, OBJECT_OWNER, OBJECT_NAME, OBJECT_TYPE, COLUMN_NAME, OPTION$, PATH, RUN_NAME)
as
select capture, run_seq#, os_user, host, module, username, used_role, sys_priv, obj_priv, user_priv, object_owner, object_name, object_type, column_name, option$, sys.string_to_grantpath(path), run_name
from 
(select unique cap.name capture, 
              priv.run_seq# run_seq#, 
              priv.os_user os_user, 
              priv.host host, 
              priv.module module, 
              u.name username,
              (select name from sys.user$ where priv.role# != 0 
               and priv.role#=user#) used_role,
              (select m.name from sys.system_privilege_map m
               where priv.syspriv# = -m.privilege) sys_priv,
              (select m.name from sys.table_privilege_map m
               where priv.objpriv# = m.privilege and priv.syspriv# = 0) 
               obj_priv,
              decode(priv.userpriv#, 
               0, 'INHERIT PRIVILEGES', 1, 'TRANSLATE SQL',
               2, 'INHERIT REMOTE PRIVILEGES', NULL) user_priv,
              decode(priv.userpriv#, 255,
                     (select u.name from sys.obj$ o, sys.user$ u 
                     where o.obj#=priv.obj# and o.owner#=u.user#), NULL) object_owner,
              decode(priv.userpriv#, 255, /* not user privilege */
                     (select o.name from sys.obj$ o, sys.user$ u 
                      where o.obj#=priv.obj# and o.owner#=u.user#),
                     (select u.name from sys.user$ u where u.user# = priv.obj#)) object_name,
              decode(priv.userpriv#, 255, /* not user privilege */
                     (select d.object_type from dba_objects d 
                      where d.object_id = priv.obj#), 'USER') object_type,
             (select c.name from sys.col$ c where priv.col# !=0 and 
              obj#=priv.obj# and col#=priv.col#) column_name,
             priv.option$ option$, 
             sys.grantpath_to_string(pa.path) path,
             decode(pa.run_seq#, 0, NULL, 
                (select log1.run_name from sys.capture_run_log$ log1 where log1.capture=priv.capture and log1.run_seq#=priv.run_seq#)) run_name
from (select * from sys.captured_priv$ p where p.syspriv# != 0 or /* syspriv */
     (p.objpriv# != 255 and                       /* objpriv used and exists */
       exists (select name from sys.obj$ o where p.obj# = o.obj#)) or
     (p.userpriv# != 255  and                    /* userpriv used and exists */
       exists (select name from sys.user$ u where u.user#=p.obj#)) or
     (p.objpriv# = 255 and p.userpriv# = 255 and/* only role used and exists */
       exists (select name from sys.user$ where p.role# != 0 and 
       p.role# = user#))) priv, 
     sys.priv_used_path$ pa, sys.priv_capture$ cap, sys.user$ u
where priv.capture = cap.id# and u.user#=priv.user# and priv.id# =pa.id# and priv.capture = pa.capture);

execute SYS.CDBView.create_cdbview(false,'SYS','DBA_USED_PRIVS','CDB_USED_PRIVS');
create or replace public synonym CDB_USED_PRIVS for sys.CDB_USED_PRIVS;
grant select on CDB_USED_PRIVS to CAPTURE_ADMIN;

--DBA view to show used system privileges with grant path
CREATE OR REPLACE VIEW SYS.DBA_USED_SYSPRIVS_PATH (CAPTURE, SEQUENCE, OS_USER, USERHOST, MODULE, USERNAME, USED_ROLE, SYS_PRIV, ADMIN_OPTION, PATH, RUN_NAME)
AS
SELECT CAPTURE, SEQUENCE, OS_USER, USERHOST, MODULE, USERNAME, USED_ROLE, SYS_PRIV, OPTION$, PATH, RUN_NAME FROM SYS.DBA_USED_PRIVS WHERE SYS_PRIV IS NOT NULL;

execute SYS.CDBView.create_cdbview(false,'SYS','DBA_USED_SYSPRIVS_PATH','CDB_USED_SYSPRIVS_PATH');
create or replace public synonym CDB_USED_SYSPRIVS_PATH for sys.CDB_USED_SYSPRIVS_PATH;
grant select on CDB_USED_SYSPRIVS_PATH to CAPTURE_ADMIN;


--DBA view to show used object privielges with grant path
CREATE OR REPLACE VIEW SYS.DBA_USED_OBJPRIVS_PATH (CAPTURE, SEQUENCE, OS_USER, USERHOST, MODULE, USERNAME, USED_ROLE, OBJ_PRIV, OBJECT_OWNER, OBJECT_NAME, OBJECT_TYPE, COLUMN_NAME, GRANT_OPTION, PATH, RUN_NAME)
AS
SELECT CAPTURE, SEQUENCE, OS_USER, USERHOST, MODULE, USERNAME, USED_ROLE, OBJ_PRIV, OBJECT_OWNER, OBJECT_NAME, OBJECT_TYPE, COLUMN_NAME, OPTION$, PATH, RUN_NAME FROM SYS.DBA_USED_PRIVS WHERE OBJ_PRIV IS NOT NULL;

execute SYS.CDBView.create_cdbview(false,'SYS','DBA_USED_OBJPRIVS_PATH','CDB_USED_OBJPRIVS_PATH');
create or replace public synonym CDB_USED_OBJPRIVS_PATH for sys.CDB_USED_OBJPRIVS_PATH;
grant select on CDB_USED_OBJPRIVS_PATH to CAPTURE_ADMIN;


--DBA view to show user privileges with grant path
CREATE OR REPLACE VIEW SYS.DBA_USED_USERPRIVS_PATH (CAPTURE, SEQUENCE, OS_USER, USERHOST, MODULE, USERNAME, USED_ROLE, USER_PRIV, ONUSER, GRANT_OPTION, PATH, RUN_NAME)
AS
SELECT CAPTURE, SEQUENCE, OS_USER, USERHOST, MODULE, USERNAME, USED_ROLE, USER_PRIV, OBJECT_NAME, OPTION$, PATH, RUN_NAME FROM SYS.DBA_USED_PRIVS WHERE USER_PRIV IS NOT NULL;

execute SYS.CDBView.create_cdbview(false,'SYS','DBA_USED_USERPRIVS_PATH','CDB_USED_USERPRIVS_PATH');
create or replace public synonym CDB_USED_USERPRIVS_PATH for sys.CDB_USED_USERPRIVS_PATH;
grant select on CDB_USED_USERPRIVS_PATH to CAPTURE_ADMIN;

-- Bug 17976112: DBA view to show explicitly checked roles with grant path
CREATE OR REPLACE VIEW SYS.DBA_CHECKED_ROLES_PATH (CAPTURE, SEQUENCE, OS_USER, USERHOST, MODULE, USERNAME, CHECKED_ROLE, PATH, RUN_NAME) AS
SELECT CAPTURE, SEQUENCE, OS_USER, USERHOST, MODULE, USERNAME, USED_ROLE, PATH, RUN_NAME FROM SYS.DBA_USED_PRIVS WHERE SYS_PRIV IS NULL AND OBJ_PRIV IS NULL AND USER_PRIV IS NULL;

execute SYS.CDBView.create_cdbview(false,'SYS','DBA_CHECKED_ROLES_PATH','CDB_CHECKED_ROLES_PATH');
create or replace public synonym CDB_CHECKED_ROLES_PATH for sys.CDB_CHECKED_ROLES_PATH;
grant select on CDB_CHECKED_ROLES_PATH to CAPTURE_ADMIN;


--DBA view to show used system privileges without grant path
CREATE OR REPLACE VIEW SYS.DBA_USED_SYSPRIVS (CAPTURE, SEQUENCE, OS_USER, USERHOST, MODULE, USERNAME, USED_ROLE, SYS_PRIV, ADMIN_OPTION, RUN_NAME) AS 
SELECT UNIQUE CAPTURE, SEQUENCE, OS_USER, USERHOST, MODULE, USERNAME, USED_ROLE, SYS_PRIV, OPTION$, RUN_NAME FROM SYS.DBA_USED_PRIVS WHERE SYS_PRIV IS NOT NULL;

execute SYS.CDBView.create_cdbview(false,'SYS','DBA_USED_SYSPRIVS','CDB_USED_SYSPRIVS');
create or replace public synonym CDB_USED_SYSPRIVS for sys.CDB_USED_SYSPRIVS;
grant select on CDB_USED_SYSPRIVS to CAPTURE_ADMIN;

-- DBA view to show used object privileges without grant path
CREATE OR REPLACE VIEW SYS.DBA_USED_OBJPRIVS (CAPTURE, SEQUENCE, OS_USER, USERHOST, MODULE, USERNAME, USED_ROLE, OBJ_PRIV, OBJECT_OWNER, OBJECT_NAME, OBJECT_TYPE, COLUMN_NAME, GRANT_OPTION, RUN_NAME)
AS
SELECT UNIQUE CAPTURE, SEQUENCE, OS_USER, USERHOST, MODULE, USERNAME, USED_ROLE, OBJ_PRIV, OBJECT_OWNER, OBJECT_NAME, OBJECT_TYPE, COLUMN_NAME,OPTION$, RUN_NAME FROM SYS.DBA_USED_PRIVS WHERE OBJ_PRIV IS NOT NULL;

execute SYS.CDBView.create_cdbview(false,'SYS','DBA_USED_OBJPRIVS','CDB_USED_OBJPRIVS');
create or replace public synonym CDB_USED_OBJPRIVS for sys.CDB_USED_OBJPRIVS;
grant select on CDB_USED_OBJPRIVS to CAPTURE_ADMIN;


--DBA view to show used user privileges without grant path
CREATE OR REPLACE VIEW SYS.DBA_USED_USERPRIVS(CAPTURE, SEQUENCE, OS_USER, USERHOST, MODULE, USERNAME, USED_ROLE, USER_PRIV, ONUSER, GRANT_OPTION, RUN_NAME)
AS
SELECT UNIQUE CAPTURE, SEQUENCE, OS_USER, USERHOST, MODULE, USERNAME, USED_ROLE, USER_PRIV, OBJECT_NAME, OPTION$, RUN_NAME FROM SYS.DBA_USED_PRIVS WHERE USER_PRIV IS NOT NULL;

execute SYS.CDBView.create_cdbview(false,'SYS','DBA_USED_USERPRIVS','CDB_USED_USERPRIVS');
create or replace public synonym CDB_USED_USERPRIVS for sys.CDB_USED_USERPRIVS;
grant select on CDB_USED_USERPRIVS to CAPTURE_ADMIN;

-- Bug 17976112: DBA view to show explicitly checked roles without grant path
CREATE OR REPLACE VIEW SYS.DBA_CHECKED_ROLES (CAPTURE, SEQUENCE, OS_USER, USERHOST, MODULE, USERNAME, CHECKED_ROLE, RUN_NAME) AS
SELECT UNIQUE CAPTURE, SEQUENCE, OS_USER, USERHOST, MODULE, USERNAME, USED_ROLE, RUN_NAME FROM SYS.DBA_USED_PRIVS WHERE SYS_PRIV IS NULL AND OBJ_PRIV IS NULL AND USER_PRIV IS NULL;

execute SYS.CDBView.create_cdbview(false,'SYS','DBA_CHECKED_ROLES','CDB_CHECKED_ROLES');
create or replace public synonym CDB_CHECKED_ROLES for sys.CDB_CHECKED_ROLES;
grant select on CDB_CHECKED_ROLES to CAPTURE_ADMIN;

--DBA view for used PUBLIC privilege
CREATE OR REPLACE VIEW SYS.DBA_USED_PUBPRIVS (CAPTURE, SEQUENCE, OS_USER, USERHOST, MODULE, USERNAME, SYS_PRIV, OBJ_PRIV, OBJECT_OWNER, OBJECT_NAME, OBJECT_TYPE, OPTION$, RUN_NAME)
AS
SELECT UNIQUE CAPTURE, SEQUENCE, OS_USER, USERHOST, MODULE, USERNAME, SYS_PRIV, OBJ_PRIV, OBJECT_OWNER, OBJECT_NAME, OBJECT_TYPE, OPTION$, RUN_NAME FROM SYS.DBA_USED_PRIVS WHERE 'PUBLIC' in (select column_value from table(path));

execute SYS.CDBView.create_cdbview(false,'SYS','DBA_USED_PUBPRIVS','CDB_USED_PUBPRIVS');
create or replace public synonym CDB_USED_PUBPRIVS for sys.CDB_USED_PUBPRIVS;
grant select on CDB_USED_PUBPRIVS to CAPTURE_ADMIN;

--DBA view for unused privileges
CREATE OR REPLACE VIEW SYS.DBA_UNUSED_PRIVS(CAPTURE, USERNAME, ROLENAME, SYS_PRIV, OBJ_PRIV, USER_PRIV, OBJECT_OWNER, OBJECT_NAME, OBJECT_TYPE, COLUMN_NAME, OPTION$, PATH, RUN_NAME) as
SELECT cap.name, 
 (select u.name from dual where cap.type = 1 or cap.type = 3),
 (select u.name from dual where cap.type = 2 or cap.type = 4),
 (select m.name from sys.system_privilege_map m where priv.syspriv# = -m.privilege),
 (select m.name from sys.table_privilege_map m  
  where priv.objpriv# = m.privilege and priv.syspriv# = 0),
 decode(priv.userpriv#, 0, 'INHERIT PRIVILEGES', 1, 'TRANSLATE SQL', 
                        2, 'INHERIT REMOTE PRIVILEGES', NULL),
 decode(priv.userpriv#, 255,
        (select u.name from sys.obj$ o, sys.user$ u
        where o.obj#=priv.obj# and o.owner#=u.user#), NULL),
 decode(priv.userpriv#, 255,
        (select o.name from sys.obj$ o, sys.user$ u where o.obj#=priv.obj#
         and o.owner#=u.user#), 
        (select u.name from sys.user$ u where u.user# = priv.obj#)),
 decode(priv.userpriv#, 255,
        (select d.object_type from dba_objects d where d.object_id = priv.obj#), 'USER'),
 (select c.name from sys.col$ c
  where priv.col# !=0 and obj#=priv.obj# and col#=priv.col#),
  priv.option$, pa.path,
 decode(pa.run_seq#, 0, NULL,
                (select log1.run_name from sys.capture_run_log$ log1 where log1.capture=priv.capture and log1.run_seq#=pa.run_seq#)) run_name
FROM sys.priv_unused$ priv, sys.priv_capture$ cap, sys.user$ u, 
     sys.priv_unused_path$ pa
WHERE priv.capture = cap.id# and u.user#=priv.user# and priv.id# = pa.id# and priv.run_seq#=pa.run_seq# 
      and priv.capture = pa.capture;

execute SYS.CDBView.create_cdbview(false,'SYS','DBA_UNUSED_PRIVS','CDB_UNUSED_PRIVS');
create or replace public synonym CDB_UNUSED_PRIVS for sys.CDB_UNUSED_PRIVS;
grant select on CDB_UNUSED_PRIVS to CAPTURE_ADMIN;


--unused system privilege with grant path
CREATE OR REPLACE VIEW SYS.DBA_UNUSED_SYSPRIVS_PATH(CAPTURE, USERNAME, ROLENAME, SYS_PRIV, ADMIN_OPTION, PATH, RUN_NAME) 
as
SELECT CAPTURE, USERNAME, ROLENAME, SYS_PRIV, OPTION$, PATH, RUN_NAME FROM SYS.DBA_UNUSED_PRIVS
WHERE SYS_PRIV IS NOT NULL;

execute SYS.CDBView.create_cdbview(false,'SYS','DBA_UNUSED_SYSPRIVS_PATH','CDB_UNUSED_SYSPRIVS_PATH');
create or replace public synonym CDB_UNUSED_SYSPRIVS_PATH for sys.CDB_UNUSED_SYSPRIVS_PATH;
grant select on CDB_UNUSED_SYSPRIVS_PATH to CAPTURE_ADMIN;


--unused system privileges without grant path
CREATE OR REPLACE VIEW SYS.DBA_UNUSED_SYSPRIVS(CAPTURE, USERNAME, ROLENAME, SYS_PRIV, ADMIN_OPTION, RUN_NAME) 
as
SELECT UNIQUE CAPTURE, USERNAME, ROLENAME, SYS_PRIV, OPTION$, RUN_NAME FROM SYS.DBA_UNUSED_PRIVS
WHERE SYS_PRIV IS NOT NULL;

execute SYS.CDBView.create_cdbview(false,'SYS','DBA_UNUSED_SYSPRIVS','CDB_UNUSED_SYSPRIVS');
create or replace public synonym CDB_UNUSED_SYSPRIVS for sys.CDB_UNUSED_SYSPRIVS;
grant select on CDB_UNUSED_SYSPRIVS to CAPTURE_ADMIN;


--unused object privileges with grant path
CREATE OR REPLACE VIEW SYS.DBA_UNUSED_OBJPRIVS_PATH(CAPTURE, USERNAME, ROLENAME, OBJ_PRIV, OBJECT_OWNER, OBJECT_NAME, OBJECT_TYPE, COLUMN_NAME, GRANT_OPTION, PATH, RUN_NAME) 
as
SELECT CAPTURE, USERNAME, ROLENAME, OBJ_PRIV, OBJECT_OWNER, OBJECT_NAME, OBJECT_TYPE, COLUMN_NAME, OPTION$, PATH, RUN_NAME
FROM SYS.DBA_UNUSED_PRIVS
WHERE OBJ_PRIV IS NOT NULL;

execute SYS.CDBView.create_cdbview(false,'SYS','DBA_UNUSED_OBJPRIVS_PATH','CDB_UNUSED_OBJPRIVS_PATH');
create or replace public synonym CDB_UNUSED_OBJPRIVS_PATH for sys.CDB_UNUSED_OBJPRIVS_PATH;
grant select on CDB_UNUSED_OBJPRIVS_PATH to CAPTURE_ADMIN;


--unused object privileges without grant path
CREATE OR REPLACE VIEW SYS.DBA_UNUSED_OBJPRIVS(CAPTURE, USERNAME, ROLENAME, OBJ_PRIV, OBJECT_OWNER, OBJECT_NAME, OBJECT_TYPE, COLUMN_NAME, GRANT_OPTION, RUN_NAME) 
as
SELECT UNIQUE CAPTURE, USERNAME, ROLENAME, OBJ_PRIV, OBJECT_OWNER, OBJECT_NAME, OBJECT_TYPE, COLUMN_NAME , OPTION$, RUN_NAME
FROM SYS.DBA_UNUSED_PRIVS
WHERE OBJ_PRIV IS NOT NULL;

execute SYS.CDBView.create_cdbview(false,'SYS','DBA_UNUSED_OBJPRIVS','CDB_UNUSED_OBJPRIVS');
create or replace public synonym CDB_UNUSED_OBJPRIVS for sys.CDB_UNUSED_OBJPRIVS;
grant select on CDB_UNUSED_OBJPRIVS to CAPTURE_ADMIN;


--unused user privileges with grant path
CREATE OR REPLACE VIEW SYS.DBA_UNUSED_USERPRIVS_PATH(CAPTURE, USERNAME, ROLENAME, USER_PRIV, ONUSER, GRANT_OPTION, PATH, RUN_NAME)
as
SELECT CAPTURE, USERNAME, ROLENAME, USER_PRIV, OBJECT_NAME, OPTION$, PATH, RUN_NAME
FROM SYS.DBA_UNUSED_PRIVS WHERE USER_PRIV IS NOT NULL;

execute SYS.CDBView.create_cdbview(false,'SYS','DBA_UNUSED_USERPRIVS_PATH','CDB_UNUSED_USERPRIVS_PATH');
create or replace public synonym CDB_UNUSED_USERPRIVS_PATH for sys.CDB_UNUSED_USERPRIVS_PATH;
grant select on CDB_UNUSED_USERPRIVS_PATH to CAPTURE_ADMIN;


--unused user privileges with grant path
CREATE OR REPLACE VIEW SYS.DBA_UNUSED_USERPRIVS(CAPTURE, USERNAME, ROLENAME, USER_PRIV, ONUSER, GRANT_OPTION, RUN_NAME)
as
SELECT UNIQUE CAPTURE, USERNAME, ROLENAME, USER_PRIV, OBJECT_NAME, OPTION$, RUN_NAME
FROM SYS.DBA_UNUSED_PRIVS WHERE USER_PRIV IS NOT NULL;

execute SYS.CDBView.create_cdbview(false,'SYS','DBA_UNUSED_USERPRIVS','CDB_UNUSED_USERPRIVS');
create or replace public synonym CDB_UNUSED_USERPRIVS for sys.CDB_UNUSED_USERPRIVS;
grant select on CDB_UNUSED_USERPRIVS to CAPTURE_ADMIN;

-- unused grants
CREATE OR REPLACE VIEW SYS.DBA_UNUSED_GRANTS(CAPTURE, RUN_NAME, GRANTEE, ROLENAME, SYS_PRIV, OBJ_PRIV, USER_PRIV, OBJECT_OWNER, OBJECT_NAME, OBJECT_TYPE, COLUMN_NAME, OPTION$) as
SELECT cap.name, log.run_name, u.name,
 (select u1.name from sys.user$ u1 where u1.user# = ugrant.role#), 
 (select m.name from sys.system_privilege_map m where ugrant.syspriv# = -m.privilege),
 (select m.name from sys.table_privilege_map m
  where ugrant.objpriv# = m.privilege and ugrant.syspriv# = 0),
 decode(ugrant.userpriv#, 0, 'INHERIT PRIVILEGES', 1, 'TRANSLATE SQL', 
                          2, 'INHERIT REMOTE PRIVILEGES', NULL),
 decode(ugrant.userpriv#, 255,
        (select u.name from sys.obj$ o, sys.user$ u2
        where o.obj#=ugrant.obj# and o.owner#=u2.user#), NULL),
 decode(ugrant.userpriv#, 255,
        (select o.name from sys.obj$ o, sys.user$ u2 where o.obj#=ugrant.obj#
         and o.owner#=u2.user#),
        (select u2.name from sys.user$ u2 where u2.user# = ugrant.obj#)),
 decode(ugrant.userpriv#, 255,
        (select d.object_type from dba_objects d where d.object_id = ugrant.obj#), 'USER'),
 (select c.name from sys.col$ c
  where ugrant.col# !=0 and obj#=ugrant.obj# and col#=ugrant.col#),
  ugrant.option$
FROM sys.unused_grant$ ugrant, sys.priv_capture$ cap, sys.user$ u, sys.capture_run_log$ log
WHERE ugrant.capture# = cap.id# and u.user#=ugrant.grantee# and ugrant.run_seq# = log.run_seq#
      and ugrant.capture# = log.capture
UNION
SELECT cap.name, NULL, u.name,
 (select u1.name from sys.user$ u1 where u1.user# = ugrant.role#), 
 (select m.name from sys.system_privilege_map m where ugrant.syspriv# = -m.privilege),
 (select m.name from sys.table_privilege_map m
  where ugrant.objpriv# = m.privilege and ugrant.syspriv# = 0),
 decode(ugrant.userpriv#, 0, 'INHERIT PRIVILEGES', 1, 'TRANSLATE SQL', 
                          2, 'INHERIT REMOTE PRIVILEGES', NULL),
 decode(ugrant.userpriv#, 255,
        (select u.name from sys.obj$ o, sys.user$ u2
        where o.obj#=ugrant.obj# and o.owner#=u2.user#), NULL),
 decode(ugrant.userpriv#, 255,
        (select o.name from sys.obj$ o, sys.user$ u2 where o.obj#=ugrant.obj#
         and o.owner#=u2.user#),
        (select u2.name from sys.user$ u2 where u2.user# = ugrant.obj#)),
 decode(ugrant.userpriv#, 255,
        (select d.object_type from dba_objects d where d.object_id = ugrant.obj#), 'USER'),
 (select c.name from sys.col$ c
  where ugrant.col# !=0 and obj#=ugrant.obj# and col#=ugrant.col#),
  ugrant.option$
FROM sys.unused_grant$ ugrant, sys.priv_capture$ cap, sys.user$ u
WHERE ugrant.capture# = cap.id# and u.user#=ugrant.grantee# and ugrant.run_seq# = 0;

execute SYS.CDBView.create_cdbview(false,'SYS','DBA_UNUSED_GRANTS','CDB_UNUSED_GRANTS');
create or replace public synonym CDB_UNUSED_GRANTS for sys.CDB_UNUSED_GRANTS;
grant select on CDB_UNUSED_GRANTS to CAPTURE_ADMIN;

CREATE OR REPLACE PUBLIC SYNONYM DBA_PRIV_CAPTURES FOR sys.DBA_PRIV_CAPTURES;
CREATE OR REPLACE PUBLIC SYNONYM DBA_USED_PRIVS FOR sys.DBA_USED_PRIVS;
CREATE OR REPLACE PUBLIC SYNONYM DBA_USED_SYSPRIVS_PATH FOR sys.DBA_USED_SYSPRIVS_PATH;
CREATE OR REPLACE PUBLIC SYNONYM DBA_USED_OBJPRIVS_PATH FOR sys.DBA_USED_OBJPRIVS_PATH;
CREATE OR REPLACE PUBLIC SYNONYM DBA_USED_USERPRIVS_PATH FOR sys.DBA_USED_USERPRIVS_PATH;
CREATE OR REPLACE PUBLIC SYNONYM DBA_CHECKED_ROLES_PATH FOR SYS.DBA_CHECKED_ROLES_PATH;
CREATE OR REPLACE PUBLIC SYNONYM DBA_USED_SYSPRIVS FOR sys.DBA_USED_SYSPRIVS;
CREATE OR REPLACE PUBLIC SYNONYM DBA_USED_OBJPRIVS FOR sys.DBA_USED_OBJPRIVS;
CREATE OR REPLACE PUBLIC SYNONYM DBA_USED_USERPRIVS FOR sys.DBA_USED_USERPRIVS;
CREATE OR REPLACE PUBLIC SYNONYM DBA_USED_PUBPRIVS FOR sys.DBA_USED_PUBPRIVS;
CREATE OR REPLACE PUBLIC SYNONYM DBA_UNUSED_PRIVS FOR SYS.DBA_UNUSED_PRIVS;
CREATE OR REPLACE PUBLIC SYNONYM DBA_CHECKED_ROLES FOR SYS.DBA_CHECKED_ROLES;
CREATE OR REPLACE PUBLIC SYNONYM DBA_UNUSED_SYSPRIVS_PATH FOR SYS.DBA_UNUSED_SYSPRIVS_PATH;
CREATE OR REPLACE PUBLIC SYNONYM DBA_UNUSED_OBJPRIVS_PATH FOR SYS.DBA_UNUSED_OBJPRIVS_PATH;
CREATE OR REPLACE PUBLIC SYNONYM DBA_UNUSED_USERPRIVS_PATH FOR SYS.DBA_UNUSED_USERPRIVS_PATH;
CREATE OR REPLACE PUBLIC SYNONYM DBA_UNUSED_SYSPRIVS FOR SYS.DBA_UNUSED_SYSPRIVS;
CREATE OR REPLACE PUBLIC SYNONYM DBA_UNUSED_OBJPRIVS FOR SYS.DBA_UNUSED_OBJPRIVS;
CREATE OR REPLACE PUBLIC SYNONYM DBA_UNUSED_USERPRIVS FOR SYS.DBA_UNUSED_USERPRIVS;
CREATE OR REPLACE PUBLIC SYNONYM DBA_UNUSED_GRANTS FOR SYS.DBA_UNUSED_GRANTS;

-- grant SELECT ON DBA_ views to CAPTURE_ADMIN
grant select on DBA_PRIV_CAPTURES to CAPTURE_ADMIN;
grant select on DBA_USED_PRIVS to CAPTURE_ADMIN;
grant select on DBA_USED_SYSPRIVS to CAPTURE_ADMIN;
grant select on DBA_USED_OBJPRIVS to CAPTURE_ADMIN;
grant select on DBA_USED_USERPRIVS to CAPTURE_ADMIN;
grant select on DBA_CHECKED_ROLES to CAPTURE_ADMIN;
grant select on DBA_USED_SYSPRIVS_PATH to CAPTURE_ADMIN;
grant select on DBA_USED_OBJPRIVS_PATH to CAPTURE_ADMIN;
grant select on DBA_USED_USERPRIVS_PATH to CAPTURE_ADMIN;
grant select on DBA_CHECKED_ROLES_PATH to CAPTURE_ADMIN;
grant select on DBA_USED_PUBPRIVS to CAPTURE_ADMIN;
grant select on DBA_UNUSED_PRIVS to CAPTURE_ADMIN;
grant select on DBA_UNUSED_SYSPRIVS to CAPTURE_ADMIN;
grant select on DBA_UNUSED_OBJPRIVS to CAPTURE_ADMIN;
grant select on DBA_UNUSED_USERPRIVS to CAPTURE_ADMIN;
grant select on DBA_UNUSED_SYSPRIVS_PATH to CAPTURE_ADMIN;
grant select on DBA_UNUSED_OBJPRIVS_PATH to CAPTURE_ADMIN;
grant select on DBA_UNUSED_USERPRIVS_PATH to CAPTURE_ADMIN;
grant select on DBA_UNUSED_GRANTS to CAPTURE_ADMIN;

@?/rdbms/admin/sqlsessend.sql
