Rem
Rem $Header: rdbms/admin/cdplsql.sql /main/54 2017/06/26 16:01:18 pjulsaks Exp $
Rem
Rem cdplsql.sql
Rem
Rem Copyright (c) 2006, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      cdplsql.sql - Catalog DPLSQL.bsq views.
Rem
Rem    DESCRIPTION
Rem      libraries, procedure, etc
Rem
Rem    NOTES
Rem     This script contains catalog views for objects in dplsql.bsq.
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/cdplsql.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/cdplsql.sql
Rem SQL_PHASE: CDPLSQL
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catalog.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    pjulsaks    06/26/17 - Bug 25688154: Uppercase create_cdbview's input
Rem    pjulsaks    05/11/17 - Bug 19552209: modify int$dba_procedures
Rem    rdecker     04/24/17 - 24622715: Add SQL_BUILTIN column to plscope
Rem    thbaby      03/13/17 - Bug 25688154: upper case owner name
Rem    rdecker     02/23/17 - 24622590: enhance PL/Scope for constraints
Rem    rdecker     02/03/17 - 5910872: add support TYPE_OBJECT_TYPE
Rem    sagrawal    12/08/16 - modify *procedures view for polymorphic table
Rem                           functions
Rem    rdecker     07/12/16 - Bug 23725672: new obj# column in plscope_sql$
Rem    rpang       02/22/16 - Bug 22806411: remove debuggable session views
Rem    akruglik    01/29/16 - (22132084) handle Ext Data Link bit
Rem    akruglik    01/25/16 - (22132084): replace COMMON_DATA with
Rem                           SHARING=EXTENDED DATA
Rem    lvbcheng    12/11/15 - Bug 22343522: DEBUGGABLE_SESSIONS now READ
Rem    rpang       11/30/15 - Bug 22275640: rename USER/ALL_DEBUGGABLE_SESSIONS
Rem                           views to USER/ALL_PLSQL_DEBUGGABLE_SESSIONS, add
Rem                           PLSQL_DEBUGGER_CONNECTED column
Rem    rpang       11/23/15 - Bug 22258548: DEBUG CONNECT user priv in
Rem                           ALL_DEBUGGABLE_SESSIONS
Rem    rdecker     11/16/15 - Fix pl/scope type issues
Rem    rpang       06/30/15 - Fix USER/ALL_DEBUGGABLE_SESSIONS descriptions
Rem    thbaby      12/19/14 - Proj 47234: INT$DBA_PROCEDURES is PDB_LOCAL_ONLY 
Rem    rpang       12/17/14 - add debuggable session views
Rem    rdecker     12/01/14 - New PL/Scope for SQL tables
Rem    thbaby      12/01/14 - Proj 47234: remove decode from SHARING column
Rem    skayoor     11/30/14 - Proj 58196: Change Select priv to Read Priv
Rem    surman      11/29/13 - 13922626: Update SQL metadata
Rem    jmuller     11/27/13 - Fix bug 14271032: add RESULT_CACHE
Rem    thbaby      10/17/13 - 17406127: optional object # for more OBJ_ID cases
Rem    thbaby      10/06/13 - 17406127: optional object num arg for OBJ_ID
Rem    thbaby      08/14/13 - 17313338: *_stored_settings and Common Data 
Rem    thbaby      05/08/13 - 13606922: mark *_PLSQL_OBJECT_SETTINGS views as
Rem                           Common Data
Rem    thbaby      02/28/13 - use constant object type # argument for OBJ_ID
Rem    thbaby      02/13/13 - add SHARING column to Common Data views
Rem    thbaby      02/04/13 - bypass linked obj$ rows in int$dba_procedures
Rem    thbaby      01/29/13 - XbranchMerge thbaby_bug_15827913_ph8 from
Rem                           st_rdbms_12.1.0.1
Rem    thbaby      01/28/13 - XbranchMerge thbaby_bug_15827913_ph7 from
Rem                           st_rdbms_12.1.0.1
Rem    thbaby      01/21/13 - lrg 8809394: fix *_IDENTIFIERS views
Rem    thbaby      01/16/13 - XbranchMerge thbaby_bug_15827913_ph2 from
Rem                           st_rdbms_12.1.0.1
Rem    thbaby      01/14/13 - XbranchMerge thbaby_com_dat from
Rem                           st_rdbms_12.1.0.1
Rem    thbaby      01/24/13 - 15827913: add NO_ROOT_SW_FOR_LOCAL
Rem    thbaby      01/10/13 - 15827913: exclude Linked for non Common Data
Rem    thbaby      12/31/12 - 15827913: add ORIGIN_CON_ID columns
Rem    akruglik    12/27/12 - XbranchMerge akruglik_lrg-8591165 from
Rem                           st_rdbms_12.1.0.1
Rem    akruglik    12/17/12 - (LRG 8591165): changing 3rd parameter for OBJ_ID
Rem    thbaby      11/13/12 - 15827913: define ALL_ view on top of DBA_view
Rem    rdecker     09/05/12 - Modify plsql_types views for %rowtypes
Rem    traney      03/29/12 - bug 13715632: add agent to library$
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    rdecker     11/11/11 - 13020741: new plsql type views
Rem    ckavoor     10/11/11 - 7357877:Add XMLTYPE to ALL_ARGUMENTS defnition
Rem    traney      03/04/10 - bug 9279149
Rem    rdecker     02/05/10 - bug 9297309: fix dba_identifiers
Rem    anighosh    04/29/09 - #(8469280): Improve DBA_PROCEDURES performance
Rem    kquinn      09/22/08 - 7281025: amend views to handle evolved TYPEs
Rem    rdecker     08/08/08 - bug 6054304: update *_IDENTIFIERS view comments
Rem    rdecker     12/17/07 - bug 6681502: libary perms fix in all_identifiers
Rem    rdecker     09/20/07 - bug 6418470: persistent library settings
Rem    rdecker     10/20/06 - plscope views for SYSAUX
Rem    achoi       06/26/06 - support application edition 
Rem    rdecker     06/30/06 - Changes to PL/Scope identifiers views
Rem    rdecker     06/05/06 - Add PL/Scope identifiers view
Rem    achoi       05/18/06 - handle application edition 
Rem    cdilling    05/04/06 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

-- SHARING bits in OBJ$.FLAGS are:
-- - 65536  = MDL (Metadata Link)
-- - 131072 = DL (Data Link, formerly OBL)
-- - 4294967296 = EDL (Extended Data Link)
define mdl=65536
define dl=131072
define edl=4294967296
define sharing_bits=(&mdl+&dl+&edl)

remark
remark  FAMILY "LIBRARIES"
remark
remark  Views for showing information about PL/SQL Libraries:
remark  USER_LIBRARIES, ALL_LIBRARIES and DBA_LIBRARIES
remark
create or replace view INT$DBA_LIBRARIES SHARING=EXTENDED DATA 
(OWNER, LIBRARY_NAME, OBJECT_ID, FILE_SPEC, DYNAMIC, STATUS, AGENT, 
 LEAF_FILENAME, SHARING, ORIGIN_CON_ID)
as
select u.name,
       o.name,
       o.obj#,
       l.filespec,
       decode(bitand(l.property, 1), 0, 'Y', 1, 'N', NULL),
       decode(o.status, 0, 'N/A', 1, 'VALID', 'INVALID'),
       l.agent,
       l.leaf_filename,
       case when bitand(o.flags, &sharing_bits)>0 then 1 else 0 end,
       to_number(sys_context('USERENV', 'CON_ID'))
from sys."_CURRENT_EDITION_OBJ" o, sys.library$ l, sys.user$ u
where o.owner# = u.user#
  and o.obj# = l.obj#
/

create or replace view DBA_LIBRARIES
(OWNER, LIBRARY_NAME, FILE_SPEC, DYNAMIC, STATUS, AGENT, LEAF_FILENAME, 
 ORIGIN_CON_ID)
as
select OWNER, LIBRARY_NAME, FILE_SPEC, DYNAMIC, STATUS, AGENT, 
       LEAF_FILENAME, ORIGIN_CON_ID
from   INT$DBA_LIBRARIES 
/

comment on table DBA_LIBRARIES is
'Description of all libraries in the database'
/
comment on column DBA_LIBRARIES.OWNER is
'Owner of the library'
/
comment on column DBA_LIBRARIES.LIBRARY_NAME is
'Name of the library'
/
comment on column DBA_LIBRARIES.FILE_SPEC is
'Operating system file specification of the library'
/
comment on column DBA_LIBRARIES.DYNAMIC is
'Is the library dynamically loadable'
/
comment on column DBA_LIBRARIES.STATUS is
'Status of the library'
/
comment on column DBA_LIBRARIES.AGENT is
'Agent of the library'
/
comment on column DBA_LIBRARIES.LEAF_FILENAME is
'Leaf filename of the library'
/
comment on column DBA_LIBRARIES.ORIGIN_CON_ID is
'ID of Container where row originates'
/
create or replace public synonym DBA_LIBRARIES for DBA_LIBRARIES
/
grant select on DBA_LIBRARIES to select_catalog_role
/

execute SYS.CDBView.create_cdbview(false,'SYS','DBA_LIBRARIES',-
'CDB_LIBRARIES');
create or replace public synonym CDB_LIBRARIES for sys.CDB_LIBRARIES;
grant select on CDB_LIBRARIES to select_catalog_role;

create or replace view USER_LIBRARIES
(LIBRARY_NAME, FILE_SPEC, DYNAMIC, STATUS, AGENT, LEAF_FILENAME, ORIGIN_CON_ID)
as
select LIBRARY_NAME, FILE_SPEC, DYNAMIC, STATUS, AGENT, 
       LEAF_FILENAME, ORIGIN_CON_ID
from   NO_ROOT_SW_FOR_LOCAL(INT$DBA_LIBRARIES) 
where  OWNER = SYS_CONTEXT('USERENV', 'CURRENT_USER')
/
rem  and ((l.property is null) or (bitand(l.property, 2) = 0))
comment on table USER_LIBRARIES is
'Description of the user''s own libraries'
/
comment on column USER_LIBRARIES.LIBRARY_NAME is
'Name of the library'
/
comment on column USER_LIBRARIES.FILE_SPEC is
'Operating system file specification of the library'
/
comment on column USER_LIBRARIES.DYNAMIC is
'Is the library dynamically loadable'
/
comment on column USER_LIBRARIES.STATUS is
'Status of the library'
/
comment on column USER_LIBRARIES.AGENT is
'Agent of the library'
/
comment on column USER_LIBRARIES.LEAF_FILENAME is
'Leaf filename of the library'
/
comment on column USER_LIBRARIES.ORIGIN_CON_ID is
'ID of Container where row originates'
/
create or replace public synonym USER_LIBRARIES for USER_LIBRARIES
/
grant read on USER_LIBRARIES to PUBLIC with grant option
/

create or replace view ALL_LIBRARIES
(OWNER, LIBRARY_NAME, FILE_SPEC, DYNAMIC, STATUS, AGENT, LEAF_FILENAME,
 ORIGIN_CON_ID)
as
select OWNER, LIBRARY_NAME, FILE_SPEC, DYNAMIC, STATUS, AGENT, 
       LEAF_FILENAME, ORIGIN_CON_ID
from   INT$DBA_LIBRARIES 
where  (OWNER = SYS_CONTEXT('USERENV', 'CURRENT_USER')
       or OWNER = 'PUBLIC'
       or OBJ_ID(OWNER, LIBRARY_NAME, 22, OBJECT_ID) in
          ( select oa.obj#
            from sys.objauth$ oa
            where grantee# in (select kzsrorol from x$kzsro)
          )
       or (
            exists (select NULL from v$enabledprivs
                    where priv_number in (
                                      -189 /* CREATE ANY LIBRARY */,
                                      -190 /* ALTER ANY LIBRARY */,
                                      -191 /* DROP ANY LIBRARY */,
                                      -192 /* EXECUTE ANY LIBRARY */
                                         )
                   )
          )
      )
/
comment on table ALL_LIBRARIES is
'Description of libraries accessible to the user'
/
comment on column ALL_LIBRARIES.OWNER is
'Owner of the library'
/
comment on column ALL_LIBRARIES.LIBRARY_NAME is
'Name of the library'
/
comment on column ALL_LIBRARIES.FILE_SPEC is
'Operating system file specification of the library'
/
comment on column ALL_LIBRARIES.DYNAMIC is
'Is the library dynamically loadable'
/
comment on column ALL_LIBRARIES.STATUS is
'Status of the library'
/
comment on column ALL_LIBRARIES.AGENT is
'Agent of the library'
/
comment on column ALL_LIBRARIES.LEAF_FILENAME is
'Leaf filename of the library'
/
comment on column ALL_LIBRARIES.ORIGIN_CON_ID is
'ID of Container where row originates'
/
create or replace public synonym ALL_LIBRARIES for ALL_LIBRARIES
/
grant read on ALL_LIBRARIES to PUBLIC with grant option
/


remark FAMILY  "PROCEDURES"
remark   List of procedures (and functions) and associated properties
  
create or replace view INT$DBA_PROCEDURES PDB_LOCAL_ONLY SHARING=EXTENDED DATA 
(OWNER, OBJECT_NAME, PROCEDURE_NAME, OBJECT_ID, SUBPROGRAM_ID, 
  OVERLOAD, OBJECT_TYPE, OBJECT_TYPE#,
  AGGREGATE, PIPELINED,
  IMPLTYPEOWNER, IMPLTYPENAME, PARALLEL,
  INTERFACE, DETERMINISTIC, AUTHID, RESULT_CACHE, SHARING, ORIGIN_CON_ID,
  POLYMORPHIC, APPLICATION)
as
(select u.name, o.name, pi.procedurename, o.obj#, pi.procedure#, 
decode(pi.overload#, 0, NULL, pi.overload#),
decode(o.type#, 7, 'PROCEDURE',
       8, 'FUNCTION', 9, 'PACKAGE', 11, 'PACKAGE BODY',
       12, 'TRIGGER', 13, 'TYPE', 14, 'TYPE BODY',
       22, 'LIBRARY', 28, 'JAVA SOURCE', 29, 'JAVA CLASS',
       30, 'JAVA RESOURCE', 87, 'ASSEMBLY', 'UNDEFINED'),
o.type#,
decode(bitand(pi.properties,8),8,'YES','NO'),
decode(bitand(pi.properties,16),16,'YES','NO'),
u2.name, o2.name,
  decode(bitand(pi.properties,32),32,'YES','NO'),
  decode(bitand(pi.properties,512),512,'YES','NO'),
decode(bitand(pi.properties,256),256,'YES','NO'),
decode(bitand(pi.properties,1024),1024,'CURRENT_USER','DEFINER'), 
decode(bitand(pi.properties2,8),8,'YES','NO'),
case when bitand(o.flags, &sharing_bits)>0 then 1 else 0 end,
to_number(sys_context('USERENV', 'CON_ID')),
 CASE  
     WHEN bitand(pi.properties,1073741824) > 0 THEN 
        CASE 
           when bitand(properties2, 1) > 0 THEN 'TABLE'
           when bitand(properties2, 2) > 0 THEN 'ROW'
           when bitand(properties2, 4) > 0 THEN 'LEAF'
        ELSE 'NULL'
        END
  ELSE 'NULL'
   end,
/* Bug 19552209: Add APPLICATION column for application object */
case when bitand(o.flags, 134217728)>0 then 1 else 0 end 
from sys."_CURRENT_EDITION_OBJ" o, user$ u, procedureinfo$ pi,
     sys."_CURRENT_EDITION_OBJ" o2, user$ u2
where u.user# = o.owner# and o.obj# = pi.obj#
and (o.type# in (7, 8, 9, 11, 12, 14, 22, 28, 29, 30, 87) or
     (o.type# = 13 and o.subname is null))
and pi.itypeobj# = o2.obj# (+) and o2.owner#  = u2.user# (+)
/* Bug 19552209: to avoid duplication when query from app pdb, 
 * oracle-maintained procedure shouldn't be returned in app root.
 */
and (SYS_CONTEXT('USERENV', 'CON_ID') = 0 or
     (SYS_CONTEXT('USERENV','IS_APPLICATION_ROOT') = 'YES' and 
      bitand(o.flags, 4194304)<>4194304) or
     SYS_CONTEXT('USERENV','IS_APPLICATION_ROOT') = 'NO' )
)
union all
(select u.name, o.name, NULL,
  o.obj#,
  CASE 
    WHEN o.type# = 12 THEN 1
    ELSE 0
  END,
  NULL, decode(o.type#,12,'TRIGGER',9,'PACKAGE'), o.type#,
  'NO', 'NO', NULL, NULL, 'NO', 'NO', 'NO',
  CASE
    WHEN o.type#=12 THEN 'DEFINER'
    ELSE decode(bitand(pi.properties,1024),NULL,NULL,
                1024,'CURRENT_USER','DEFINER')
  END CASE, 'NO', case when bitand(o.flags, &sharing_bits)>0 then 1 else 0 end,
  to_number(sys_context('USERENV', 'CON_ID')), NULL,
  /* Bug 19552209: Add APPLICATION column for application object */
  case when bitand(o.flags, 134217728)>0 then 1 else 0 end
  from sys."_CURRENT_EDITION_OBJ" o, user$ u, procedureinfo$ pi
  where ((o.owner# = u.user# and o.obj# = pi.obj# (+)) AND
         (o.type# in (12,9)) AND
         ((pi.procedure# is null) OR (pi.procedure# = 1)) AND
         /* Bug 19552209: to avoid duplication when query from app pdb, 
          * oracle-maintained procedure shouldn't be returned in app root.
          */
         (SYS_CONTEXT('USERENV', 'CON_ID') = 0 or 
          (SYS_CONTEXT('USERENV','IS_APPLICATION_ROOT') = 'YES' and 
           bitand(o.flags, 4194304)<>4194304) or
          SYS_CONTEXT('USERENV','IS_APPLICATION_ROOT') = 'NO'))
)
/

create or replace view DBA_PROCEDURES
(OWNER, OBJECT_NAME, PROCEDURE_NAME, OBJECT_ID, SUBPROGRAM_ID,
  OVERLOAD, OBJECT_TYPE,
  AGGREGATE, PIPELINED,
  IMPLTYPEOWNER, IMPLTYPENAME, PARALLEL,
  INTERFACE, DETERMINISTIC, AUTHID, RESULT_CACHE, ORIGIN_CON_ID,
  POLYMORPHIC)
as
select OWNER, OBJECT_NAME, PROCEDURE_NAME, OBJECT_ID, SUBPROGRAM_ID,
       OVERLOAD, OBJECT_TYPE,
       AGGREGATE, PIPELINED,
       IMPLTYPEOWNER, IMPLTYPENAME, PARALLEL,
       INTERFACE, DETERMINISTIC, AUTHID, RESULT_CACHE, ORIGIN_CON_ID,
       POLYMORPHIC
from INT$DBA_PROCEDURES 
/

comment on table DBA_PROCEDURES is
'Description of the dba functions/procedures/packages/types/triggers'
/
comment on column DBA_PROCEDURES.OBJECT_NAME is
'Name of the object: top level function/procedure/package/type/trigger name'
/
comment on column DBA_PROCEDURES.PROCEDURE_NAME is
'Name of the package or type subprogram'
/
comment on column DBA_PROCEDURES.OBJECT_ID is
'Object number of the object'
/
comment on column DBA_PROCEDURES.SUBPROGRAM_ID is
'Unique sub-program identifier'
/
comment on column DBA_PROCEDURES.OVERLOAD is
'Overload unique identifier'
/
comment on column DBA_PROCEDURES.OBJECT_TYPE is
'The typename of the object'
/
comment on column DBA_PROCEDURES.AGGREGATE is
'Is it an aggregate function ?'
/
comment on column DBA_PROCEDURES.PIPELINED is
'Is it a pipelined table function ?'
/
comment on column DBA_PROCEDURES.RESULT_CACHE is
'Is it a result-cached function ?'
/
comment on column DBA_PROCEDURES.IMPLTYPEOWNER is
'Name of the owner of the implementation type (if any)'
/
comment on column DBA_PROCEDURES.IMPLTYPENAME is
'Name of the implementation type (if any)'
/
comment on column DBA_PROCEDURES.PARALLEL is
'Is the procedure parallel enabled ?'
/
comment on column DBA_PROCEDURES.ORIGIN_CON_ID is
'ID of Container where row originates'
/
comment on column DBA_PROCEDURES.POLYMORPHIC is
'If it is a polymorphic table function, then what is its kind ?'
/
create or replace public synonym DBA_PROCEDURES for DBA_PROCEDURES
/
grant select on DBA_PROCEDURES to select_catalog_role
/

execute SYS.CDBView.create_cdbview(false,'SYS','DBA_PROCEDURES',-
'CDB_PROCEDURES');
create or replace public synonym CDB_PROCEDURES for sys.CDB_PROCEDURES;
grant select on CDB_PROCEDURES to select_catalog_role;

create or replace view USER_PROCEDURES
(OBJECT_NAME, PROCEDURE_NAME, OBJECT_ID, SUBPROGRAM_ID, 
  OVERLOAD, OBJECT_TYPE,
  AGGREGATE, PIPELINED,
  IMPLTYPEOWNER, IMPLTYPENAME, PARALLEL,
  INTERFACE, DETERMINISTIC, AUTHID, RESULT_CACHE, ORIGIN_CON_ID,
  POLYMORPHIC)
as
select OBJECT_NAME, PROCEDURE_NAME, OBJECT_ID, SUBPROGRAM_ID, 
       OVERLOAD, OBJECT_TYPE,
       AGGREGATE, PIPELINED,
       IMPLTYPEOWNER, IMPLTYPENAME, PARALLEL,
       INTERFACE, DETERMINISTIC, AUTHID, RESULT_CACHE, ORIGIN_CON_ID,
       POLYMORPHIC
  from NO_ROOT_SW_FOR_LOCAL(INT$DBA_PROCEDURES) 
 where OWNER = SYS_CONTEXT('USERENV', 'CURRENT_USER')
/

comment on table USER_PROCEDURES is
'Description of the user functions/procedures/packages/types/triggers'
/
comment on column USER_PROCEDURES.OBJECT_NAME is
'Name of the object: top level function/procedure/package/type/trigger name'
/
comment on column USER_PROCEDURES.PROCEDURE_NAME is
'Name of the package or type subprogram'
/
comment on column USER_PROCEDURES.OBJECT_ID is
'Object number of the object'
/
comment on column USER_PROCEDURES.SUBPROGRAM_ID is
'Unique sub-program identifier'
/
comment on column USER_PROCEDURES.OVERLOAD is
'Overload unique identifier'
/
comment on column USER_PROCEDURES.OBJECT_TYPE is
'The typename of the object'
/
comment on column USER_PROCEDURES.AGGREGATE is
'Is it an aggregate function ?'
/
comment on column USER_PROCEDURES.PIPELINED is
'Is it a pipelined table function ?'
/
comment on column USER_PROCEDURES.RESULT_CACHE is
'Is it a result-cached function ?'
/
comment on column USER_PROCEDURES.IMPLTYPEOWNER is
'Name of the owner of the implementation type (if any)'
/
comment on column USER_PROCEDURES.IMPLTYPENAME is
'Name of the implementation type (if any)'
/
comment on column USER_PROCEDURES.PARALLEL is
'Is the procedure parallel enabled ?'
/
comment on column USER_PROCEDURES.ORIGIN_CON_ID is
'ID of Container where row originates'
/
comment on column USER_PROCEDURES.POLYMORPHIC is
'If it is a polymorphic table function, then what is its kind ?'
/
create or replace public synonym user_procedures for user_procedures
/
grant read on user_procedures to public with grant option
/

create or replace view ALL_PROCEDURES
(OWNER, OBJECT_NAME, PROCEDURE_NAME, OBJECT_ID, SUBPROGRAM_ID,
  OVERLOAD, OBJECT_TYPE,
  AGGREGATE, PIPELINED,
  IMPLTYPEOWNER, IMPLTYPENAME, PARALLEL,
  INTERFACE, DETERMINISTIC, AUTHID, RESULT_CACHE, ORIGIN_CON_ID,
  POLYMORPHIC)
as
select OWNER, OBJECT_NAME, PROCEDURE_NAME, OBJECT_ID, SUBPROGRAM_ID,
       OVERLOAD, OBJECT_TYPE,
       AGGREGATE, PIPELINED,
       IMPLTYPEOWNER, IMPLTYPENAME, PARALLEL,
       INTERFACE, DETERMINISTIC, AUTHID, RESULT_CACHE, ORIGIN_CON_ID,
       POLYMORPHIC
  from INT$DBA_PROCEDURES 
 where OWNER = SYS_CONTEXT('USERENV', 'CURRENT_USER')
    or exists
       (select null from v$enabledprivs where priv_number in (-144,-141))
    or OBJ_ID(OWNER, OBJECT_NAME, OBJECT_TYPE#, OBJECT_ID) in 
       (select obj# 
          from sys.objauth$ 
         where grantee# in (select kzsrorol from x$kzsro) 
           and privilege# = 12)
/

comment on table ALL_PROCEDURES is
'Functions/procedures/packages/types/triggers available to the user'
/
comment on column ALL_PROCEDURES.OBJECT_NAME is
'Name of the object: top level function/procedure/package/type/trigger name'
/
comment on column ALL_PROCEDURES.PROCEDURE_NAME is
'Name of the package or type subprogram'
/
comment on column ALL_PROCEDURES.OBJECT_ID is
'Object number of the object'
/
comment on column ALL_PROCEDURES.SUBPROGRAM_ID is
'Unique sub-program identifier'
/
comment on column ALL_PROCEDURES.OVERLOAD is
'Overload unique identifier'
/
comment on column ALL_PROCEDURES.OBJECT_TYPE is
'The typename of the object'
/
comment on column ALL_PROCEDURES.AGGREGATE is
'Is it an aggregate function ?'
/
comment on column ALL_PROCEDURES.PIPELINED is
'Is it a pipelined table function ?'
/
comment on column ALL_PROCEDURES.RESULT_CACHE is
'Is it a result-cached function ?'
/
comment on column ALL_PROCEDURES.IMPLTYPEOWNER is
'Name of the owner of the implementation type (if any)'
/
comment on column ALL_PROCEDURES.IMPLTYPENAME is
'Name of the implementation type (if any)'
/
comment on column ALL_PROCEDURES.PARALLEL is
'Is the procedure parallel enabled ?'
/
comment on column ALL_PROCEDURES.ORIGIN_CON_ID is
'ID of Container where row originates'
/
comment on column ALL_PROCEDURES.POLYMORPHIC is
'If it is a polymorphic table function, then what is its kind ?'
/
create or replace public synonym all_procedures for all_procedures
/
grant read on all_procedures to public with grant option
/



remark
remark Family STORED_SETTINGS
remark

-- Define the base view that is used to define DBA, ALL, and USER flavors
-- of *_stored_settings. This base view is defined as Common Data so that 
-- Common object information is fetched from ROOT when this view is queried 
-- in a PDB. Note that this base view has an object_type# column whose 
-- value is passed to the OBJ_ID function in the definition of 
-- all_stored_settings. 
-- Proj 47234: settings$ in PDB stores information about common TYPE
-- objects. In order to prevent selecting rows corresponding to these 
-- common objects, we set the attribute pdb_local_only.
CREATE OR REPLACE VIEW int$dba_stored_settings 
pdb_local_only sharing=extended data 
(owner, object_name, object_id, object_type, object_type#, 
 param_name, param_value, sharing, origin_con_id)
AS
SELECT u.name, o.name, o.obj#,
DECODE(o.type#,
        7, 'PROCEDURE',
        8, 'FUNCTION',
        9, 'PACKAGE',
       11, 'PACKAGE BODY',
       12, 'TRIGGER',
       13, 'TYPE',
       14, 'TYPE BODY',
       'UNDEFINED'),
o.type#,
p.param, p.value,
case when bitand(o.flags, &sharing_bits)>0 then 1 else 0 end,
to_number(sys_context('USERENV', 'CON_ID'))
FROM sys."_CURRENT_EDITION_OBJ" o, sys.user$ u, sys.settings$ p
WHERE o.owner# = u.user#
AND o.linkname is null
AND p.obj# = o.obj#
AND (o.type# in (7, 8, 9, 11, 12, 14) or (o.type# = 13 and o.subname is null))
/

CREATE OR REPLACE VIEW all_stored_settings
(owner, object_name, object_id, object_type, param_name, param_value, 
 origin_con_id)
AS
SELECT owner, object_name, object_id, object_type, param_name, param_value,
       origin_con_id
FROM int$dba_stored_settings int$dba_stored_settings
WHERE (
    int$dba_stored_settings.owner = 'PUBLIC' 
    or
    (
      (
         (
          (int$dba_stored_settings.object_type# = 7 or 
           int$dba_stored_settings.object_type# = 8 or 
           int$dba_stored_settings.object_type# = 9 or 
           int$dba_stored_settings.object_type# = 13)
          and
          obj_id(int$dba_stored_settings.owner, 
                 int$dba_stored_settings.object_name, 
                 int$dba_stored_settings.object_type#,
                 int$dba_stored_settings.object_id) in 
                   (select obj# from sys.objauth$
                     where grantee# in (select kzsrorol from x$kzsro)
                       and privilege# in (12 /* EXECUTE */, 
                                          26 /* DEBUG */))
        )
        or
        exists
        (
          select null from sys.sysauth$
          where grantee# in (select kzsrorol from x$kzsro)
          and
          (
            (
              /* procedure */
              (int$dba_stored_settings.object_type# = 7 or 
               int$dba_stored_settings.object_type# = 8 or 
               int$dba_stored_settings.object_type# = 9)
              and
              (
                privilege# = -144 /* EXECUTE ANY PROCEDURE */
                or
                privilege# = -141 /* CREATE ANY PROCEDURE */
                or
                privilege# = -241 /* DEBUG ANY PROCEDURE */
              )
            )
            or
            (
              /* package body */
              int$dba_stored_settings.object_type# = 11 and
              (
                privilege# = -141 /* CREATE ANY PROCEDURE */
                or
                privilege# = -241 /* DEBUG ANY PROCEDURE */
              )
            )
            or
            (
              /* type */
              int$dba_stored_settings.object_type# = 13 
              and
              (
                privilege# = -184 /* EXECUTE ANY TYPE */
                or
                privilege# = -181 /* CREATE ANY TYPE */
                or
                privilege# = -241 /* DEBUG ANY PROCEDURE */
              )
            )
            or
            (
              /* type body */
              int$dba_stored_settings.object_type# = 14 and
              (
                privilege# = -181 /* CREATE ANY TYPE */
                or
                privilege# = -241 /* DEBUG ANY PROCEDURE */
              )
            )
          )
        )
      )
    )
  )
/
comment on table all_stored_settings is
'Parameter settings for objects accessible to the user'
/
comment on column all_stored_settings.owner is
'Username of the owner of the object'
/
comment on column all_stored_settings.object_name is
'Name of the object'
/
comment on column all_stored_settings.object_id is
'Object number of the object'
/
comment on column all_stored_settings.object_type is
'Type of the object'
/
comment on column all_stored_settings.param_name is
'Name of the parameter'
/
comment on column all_stored_settings.param_value is
'Value of the parameter'
/
comment on column all_stored_settings.origin_con_id is
'ID of Container where row originates'
/
create or replace public synonym all_stored_settings for all_stored_settings
/
grant read on all_stored_settings to public with grant option
/

create or replace view user_stored_settings
(object_name, object_id, object_type, param_name, param_value, 
 origin_con_id)
AS
SELECT object_name, object_id, object_type, param_name, param_value,
       origin_con_id
  from NO_ROOT_SW_FOR_LOCAL(int$dba_stored_settings)
 where OWNER = SYS_CONTEXT('USERENV', 'CURRENT_USER')
/
comment on table user_stored_settings is
'Parameter settings for objects owned by the user'
/
comment on column user_stored_settings.object_name is
'Name of the object'
/
comment on column user_stored_settings.object_id is
'Object number of the object'
/
comment on column user_stored_settings.object_type is
'Type of the object'
/
comment on column user_stored_settings.param_name is
'Name of the parameter'
/
comment on column user_stored_settings.param_value is
'Value of the parameter'
/
comment on column user_stored_settings.origin_con_id is
'ID of Container where row originates'
/
create or replace public synonym user_stored_settings for user_stored_settings
/
grant read on user_stored_settings to public with grant option
/

CREATE OR REPLACE VIEW dba_stored_settings
(owner, object_name, object_id, object_type, param_name, param_value, 
 origin_con_id)
AS
SELECT owner, object_name, object_id, object_type, param_name, param_value,
       origin_con_id
FROM int$dba_stored_settings
/
comment on table dba_stored_settings is
'Parameter settings for all objects'
/
comment on column dba_stored_settings.owner is
'Username of the owner of the object'
/
comment on column dba_stored_settings.object_name is
'Name of the object'
/
comment on column dba_stored_settings.object_id is
'Object number of the object'
/
comment on column dba_stored_settings.object_type is
'Type of the object'
/
comment on column dba_stored_settings.param_name is
'Name of the parameter'
/
comment on column dba_stored_settings.param_value is
'Value of the parameter'
/
comment on column dba_stored_settings.origin_con_id is
'ID of Container where row originates'
/
create or replace public synonym dba_stored_settings for dba_stored_settings
/
grant select on dba_stored_settings to select_catalog_role
/

execute SYS.CDBView.create_cdbview(false,'SYS','DBA_STORED_SETTINGS',-
'CDB_STORED_SETTINGS');
create or replace public synonym CDB_stored_settings for
sys.CDB_stored_settings;
grant select on CDB_stored_settings to select_catalog_role;

create or replace view INT$DBA_PLSQL_OBJECT_SETTINGS SHARING=EXTENDED DATA 
(OWNER, NAME, OBJECT_ID, TYPE, TYPE#, PLSQL_OPTIMIZE_LEVEL, PLSQL_CODE_TYPE, 
 PLSQL_DEBUG, PLSQL_WARNINGS, NLS_LENGTH_SEMANTICS, PLSQL_CCFLAGS, 
 PLSCOPE_SETTINGS, SHARING, ORIGIN_CON_ID)
as
select u.name, o.name, o.obj#, 
decode(o.type#, 7, 'PROCEDURE', 8, 'FUNCTION', 9, 'PACKAGE',
                11, 'PACKAGE BODY', 12, 'TRIGGER',
                13, 'TYPE', 14, 'TYPE BODY', 22, 'LIBRARY', 'UNDEFINED'),
o.type#,
(select to_number(value) from settings$ s
  where s.obj# = o.obj# and param = 'plsql_optimize_level'),
(select value from settings$ s
  where s.obj# = o.obj# and param = 'plsql_code_type'),
(select value from settings$ s
  where s.obj# = o.obj# and param = 'plsql_debug'),
(select value from settings$ s
  where s.obj# = o.obj# and param = 'plsql_warnings'),
(select value from settings$ s
  where s.obj# = o.obj# and param = 'nls_length_semantics'),
(select value from settings$ s
  where s.obj# = o.obj# and param = 'plsql_ccflags'),
(select value from settings$ s
  where s.obj# = o.obj# and param = 'plscope_settings'),
case when bitand(o.flags, &sharing_bits)>0 then 1 else 0 end,
to_number(sys_context('USERENV', 'CON_ID'))
from sys."_CURRENT_EDITION_OBJ" o, sys.user$ u
where o.owner# = u.user#
  and (o.type# in (7, 8, 9, 11, 12, 14, 22) 
  or  (o.type# = 13 and o.subname is null))
  and exists (select 1 from settings$ s where s.obj# = o.obj#)
/

create or replace view USER_PLSQL_OBJECT_SETTINGS
(NAME, TYPE, PLSQL_OPTIMIZE_LEVEL, PLSQL_CODE_TYPE, PLSQL_DEBUG,
 PLSQL_WARNINGS, NLS_LENGTH_SEMANTICS, PLSQL_CCFLAGS, PLSCOPE_SETTINGS,
 ORIGIN_CON_ID)
as
select NAME, TYPE, PLSQL_OPTIMIZE_LEVEL, PLSQL_CODE_TYPE, PLSQL_DEBUG,
       PLSQL_WARNINGS, NLS_LENGTH_SEMANTICS, PLSQL_CCFLAGS, PLSCOPE_SETTINGS,
       ORIGIN_CON_ID
  from NO_ROOT_SW_FOR_LOCAL(INT$DBA_PLSQL_OBJECT_SETTINGS)
 where OWNER = SYS_CONTEXT('USERENV', 'CURRENT_USER')
/
comment on table USER_PLSQL_OBJECT_SETTINGS is
'Compiler settings of stored objects owned by the user'
/
comment on column USER_PLSQL_OBJECT_SETTINGS.NAME is
'Name of the object'
/
comment on column USER_PLSQL_OBJECT_SETTINGS.TYPE is
'Type of the object: "PROCEDURE", "FUNCTION",
"PACKAGE", "PACKAGE BODY", "TRIGGER", "TYPE", "TYPE BODY" or "LIBRARY"'
/
comment on column USER_PLSQL_OBJECT_SETTINGS.PLSQL_OPTIMIZE_LEVEL is
'The optimization level to use to compile the object'
/
comment on column USER_PLSQL_OBJECT_SETTINGS.PLSQL_CODE_TYPE is
'The object codes are to be compiled natively or are interpreted'
/
comment on column USER_PLSQL_OBJECT_SETTINGS.PLSQL_DEBUG is
'The object is to be compiled with debug information or not'
/
comment on column USER_PLSQL_OBJECT_SETTINGS.PLSQL_WARNINGS is
'The compiler warning settings to use to compile the object'
/
comment on column USER_PLSQL_OBJECT_SETTINGS.NLS_LENGTH_SEMANTICS is
'The NLS length semantics to use to compile the object'
/
comment on column USER_PLSQL_OBJECT_SETTINGS.PLSQL_CCFLAGS is
'The conditional compilation flag settings to use to compile the object'
/
comment on column USER_PLSQL_OBJECT_SETTINGS.PLSCOPE_SETTINGS is
'Settings for using PL/Scope'
/
comment on column USER_PLSQL_OBJECT_SETTINGS.ORIGIN_CON_ID is
'ID of Container where row originates'
/
create or replace public synonym USER_PLSQL_OBJECT_SETTINGS for 
USER_PLSQL_OBJECT_SETTINGS
/
grant read on USER_PLSQL_OBJECT_SETTINGS to public with grant option
/

create or replace view ALL_PLSQL_OBJECT_SETTINGS
(OWNER, NAME, TYPE, PLSQL_OPTIMIZE_LEVEL, PLSQL_CODE_TYPE, PLSQL_DEBUG,
 PLSQL_WARNINGS, NLS_LENGTH_SEMANTICS, PLSQL_CCFLAGS, PLSCOPE_SETTINGS,
 ORIGIN_CON_ID)
as
select OWNER, NAME, TYPE, PLSQL_OPTIMIZE_LEVEL, PLSQL_CODE_TYPE, PLSQL_DEBUG,
       PLSQL_WARNINGS, NLS_LENGTH_SEMANTICS, PLSQL_CCFLAGS, PLSCOPE_SETTINGS,
       ORIGIN_CON_ID
  from INT$DBA_PLSQL_OBJECT_SETTINGS
 where 
  (
    OWNER = SYS_CONTEXT('USERENV', 'CURRENT_USER')
    or OWNER = 'PUBLIC'
    or
    (
      /* EXECUTE privilege does not let user see package or type body */
      TYPE# in (7, 8, 9, 12, 13, 22)
      and
      OBJ_ID(OWNER, NAME, TYPE#, OBJECT_ID) in (select obj# from sys.objauth$
                 where grantee# in (select kzsrorol from x$kzsro)
                   and privilege# in (12 /* EXECUTE */, 
                                      26 /* DEBUG */)
                )
    )
    or
    (
       TYPE# in (7, 8, 9) /* procedure, function, package */
       and
       exists (select null from v$enabledprivs
               where priv_number in (
                                      -144 /* EXECUTE ANY PROCEDURE */,
                                      -141 /* CREATE ANY PROCEDURE */,
                                      -241 /* DEBUG ANY PROCEDURE */
                                    )
              )
    )
    or
    (
      TYPE# = 11 /* package body */
      and
      exists (select null from v$enabledprivs
              where priv_number in (-141 /* CREATE ANY PROCEDURE */,
                                    -241 /* DEBUG ANY PROCEDURE */))
    )
    or
    (
       TYPE# = 12 /* trigger */
       and
       exists (select null from v$enabledprivs
               where priv_number in (-152 /* CREATE ANY TRIGGER */,
                                     -241 /* DEBUG ANY PROCEDURE */))
    )
    or
    (
      TYPE# = 13 /* type */
      and
      exists (select null from v$enabledprivs
              where priv_number in (-184 /* EXECUTE ANY TYPE */,
                                    -181 /* CREATE ANY TYPE */,
                                    -241 /* DEBUG ANY PROCEDURE */))
    )
    or
    (
      TYPE# = 14 /* type body */
      and
      exists (select null from v$enabledprivs
              where priv_number in (-181 /* CREATE ANY TYPE */,
                                    -241 /* DEBUG ANY PROCEDURE */))
    )
    or
    (
      TYPE# = 22 /* library */
      and
      exists (select null from v$enabledprivs
              where priv_number in ( -189 /* CREATE ANY LIBRARY */,
                                     -192 /* EXECUTE ANY LIBRARY */))
    )
  )
/
comment on table ALL_PLSQL_OBJECT_SETTINGS is
'Compiler settings of stored objects accessible to the user'
/
comment on column ALL_PLSQL_OBJECT_SETTINGS.OWNER is
'Username of the owner of the object'
/
comment on column ALL_PLSQL_OBJECT_SETTINGS.NAME is
'Name of the object'
/
comment on column ALL_PLSQL_OBJECT_SETTINGS.TYPE is
'Type of the object: "PROCEDURE", "FUNCTION",
"PACKAGE", "PACKAGE BODY", "TRIGGER", "TYPE", "TYPE BODY" or "LIBRARY"'
/
comment on column ALL_PLSQL_OBJECT_SETTINGS.PLSQL_OPTIMIZE_LEVEL is
'The optimization level to use to compile the object'
/
comment on column ALL_PLSQL_OBJECT_SETTINGS.PLSQL_CODE_TYPE is
'The object codes are to be compiled natively or are interpreted'
/
comment on column ALL_PLSQL_OBJECT_SETTINGS.PLSQL_DEBUG is
'The object is to be compiled with debug information or not'
/
comment on column ALL_PLSQL_OBJECT_SETTINGS.PLSQL_WARNINGS is
'The compiler warning settings to use to compile the object'
/
comment on column ALL_PLSQL_OBJECT_SETTINGS.NLS_LENGTH_SEMANTICS is
'The NLS length semantics to use to compile the object'
/
comment on column ALL_PLSQL_OBJECT_SETTINGS.PLSQL_CCFLAGS is
'The conditional compilation flag settings to use to compile the object'
/
comment on column ALL_PLSQL_OBJECT_SETTINGS.PLSCOPE_SETTINGS is
'Settings for using PL/Scope'
/
comment on column ALL_PLSQL_OBJECT_SETTINGS.ORIGIN_CON_ID is
'ID of Container where row originates'
/
create or replace public synonym ALL_PLSQL_OBJECT_SETTINGS for 
ALL_PLSQL_OBJECT_SETTINGS
/
grant read on ALL_PLSQL_OBJECT_SETTINGS to public with grant option
/

create or replace view DBA_PLSQL_OBJECT_SETTINGS
(OWNER, NAME, TYPE, PLSQL_OPTIMIZE_LEVEL, PLSQL_CODE_TYPE, PLSQL_DEBUG,
 PLSQL_WARNINGS, NLS_LENGTH_SEMANTICS, PLSQL_CCFLAGS, PLSCOPE_SETTINGS,
 ORIGIN_CON_ID)
as
select OWNER, NAME, TYPE, PLSQL_OPTIMIZE_LEVEL, PLSQL_CODE_TYPE, PLSQL_DEBUG,
       PLSQL_WARNINGS, NLS_LENGTH_SEMANTICS, PLSQL_CCFLAGS, PLSCOPE_SETTINGS,
       ORIGIN_CON_ID
from INT$DBA_PLSQL_OBJECT_SETTINGS
/

create or replace public synonym DBA_PLSQL_OBJECT_SETTINGS for 
DBA_PLSQL_OBJECT_SETTINGS
/
grant select on DBA_PLSQL_OBJECT_SETTINGS to select_catalog_role
/
comment on table DBA_PLSQL_OBJECT_SETTINGS is
'Compiler settings of all objects in the database'
/
comment on column DBA_PLSQL_OBJECT_SETTINGS.OWNER is
'Username of the owner of the object'
/
comment on column DBA_PLSQL_OBJECT_SETTINGS.NAME is
'Name of the object'
/
comment on column DBA_PLSQL_OBJECT_SETTINGS.TYPE is
'Type of the object: "PROCEDURE", "FUNCTION",
"PACKAGE", "PACKAGE BODY", "TRIGGER", "TYPE", "TYPE BODY" or "LIBRARY"'
/
comment on column DBA_PLSQL_OBJECT_SETTINGS.PLSQL_OPTIMIZE_LEVEL is
'The optimization level to use to compile the object'
/
comment on column DBA_PLSQL_OBJECT_SETTINGS.PLSQL_CODE_TYPE is
'The object codes are to be compiled natively or are interpreted'
/
comment on column DBA_PLSQL_OBJECT_SETTINGS.PLSQL_DEBUG is
'The object is to be compiled with debug information or not'
/
comment on column DBA_PLSQL_OBJECT_SETTINGS.PLSQL_WARNINGS is
'The compiler warning settings to use to compile the object'
/
comment on column DBA_PLSQL_OBJECT_SETTINGS.NLS_LENGTH_SEMANTICS is
'The NLS length semantics to use to compile the object'
/
comment on column DBA_PLSQL_OBJECT_SETTINGS.PLSQL_CCFLAGS is
'The conditional compilation flag settings to use to compile the object'
/
comment on column DBA_PLSQL_OBJECT_SETTINGS.PLSCOPE_SETTINGS is
'Settings for using PL/Scope'
/
comment on column DBA_PLSQL_OBJECT_SETTINGS.ORIGIN_CON_ID is
'ID of Container where row originates'
/

execute SYS.CDBView.create_cdbview(false,'SYS','DBA_PLSQL_OBJECT_SETTINGS',-
'CDB_PLSQL_OBJECT_SETTINGS');
create or replace public synonym CDB_PLSQL_OBJECT_SETTINGS for 
sys.CDB_PLSQL_OBJECT_SETTINGS;
grant select on CDB_PLSQL_OBJECT_SETTINGS to select_catalog_role;

remark
remark Family ARGUMENTS
remark

create or replace view INT$DBA_ARGUMENTS SHARING=EXTENDED DATA 
(OWNER, OBJECT_NAME, OBJECT_TYPE#, PACKAGE_NAME, OBJECT_ID, OVERLOAD, 
SUBPROGRAM_ID, ARGUMENT_NAME, POSITION, SEQUENCE,
DATA_LEVEL, DATA_TYPE, DEFAULTED, DEFAULT_VALUE, DEFAULT_LENGTH, IN_OUT, 
DATA_LENGTH, DATA_PRECISION, DATA_SCALE, RADIX, CHARACTER_SET_NAME,
TYPE_OWNER, TYPE_NAME, TYPE_SUBNAME, TYPE_LINK, TYPE_OBJECT_TYPE, 
PLS_TYPE, CHAR_LENGTH, CHAR_USED, SHARING, ORIGIN_CON_ID)
as
select
u.name, /* OWNER */
nvl(a.procedure$,o.name), /* OBJECT_NAME */
o.type#, /* OBJECT_TYPE# */
decode(a.procedure$,null,null, o.name), /* PACKAGE_NAME */
o.obj#, /* OBJECT_ID */
decode(a.overload#,0,null,a.overload#), /* OVERLOAD */
a.procedure#, /* SUBPROGRAM ID */
a.argument, /* ARGUMENT_NAME */
a.position#, /* POSITION */
a.sequence#, /* SEQUENCE */
a.level#, /* DATA_LEVEL */
decode(a.type#,  /* DATA_TYPE */
0, null,
1, decode(a.charsetform, 2, 'NVARCHAR2', 'VARCHAR2'),
2, decode(a.scale, -127, 'FLOAT', 'NUMBER'),
3, 'NATIVE INTEGER',
8, 'LONG',
9, decode(a.charsetform, 2, 'NCHAR VARYING', 'VARCHAR'),
11, 'ROWID',
12, 'DATE',
23, 'RAW',
24, 'LONG RAW',
29, 'BINARY_INTEGER',
58, 'OPAQUE/XMLTYPE',
69, 'ROWID',
96, decode(a.charsetform, 2, 'NCHAR', 'CHAR'),
100, 'BINARY_FLOAT',
101, 'BINARY_DOUBLE',
102, 'REF CURSOR',
104, 'UROWID',
105, 'MLSLABEL',
106, 'MLSLABEL',
110, 'REF',
111, 'REF',
112, decode(a.charsetform, 2, 'NCLOB', 'CLOB'),
113, 'BLOB', 114, 'BFILE', 115, 'CFILE',
121, 'OBJECT',
122, 'TABLE',
123, 'VARRAY',
178, 'TIME',
179, 'TIME WITH TIME ZONE',
180, 'TIMESTAMP',
181, 'TIMESTAMP WITH TIME ZONE',
231, 'TIMESTAMP WITH LOCAL TIME ZONE',
182, 'INTERVAL YEAR TO MONTH',
183, 'INTERVAL DAY TO SECOND',
250, 'PL/SQL RECORD',
251, 'PL/SQL TABLE',
252, 'PL/SQL BOOLEAN',
'UNDEFINED'),
decode(default#, 1, 'Y', 'N'), /* DEFAULTED */
default$, /* DEFAULT_VALUE */
deflength, /* DEFAULT_LENGTH */
decode(in_out,null,'IN',1,'OUT',2,'IN/OUT','Undefined'), /* IN_OUT */
length, /* DATA_LENGTH */
precision#, /* DATA_PRECISION */
decode(a.type#, 2, scale, 1, null, 96, null, scale), /* DATA_SCALE */
radix, /* RADIX */
decode(a.charsetform, 1, 'CHAR_CS',           /* CHARACTER_SET_NAME */
                      2, 'NCHAR_CS',
                      3, NLS_CHARSET_NAME(a.charsetid),
                      4, 'ARG:'||a.charsetid),
a.type_owner, /* TYPE_OWNER */
a.type_name, /* TYPE_NAME */
a.type_subname, /* TYPE_SUBNAME */
a.type_linkname, /* TYPE_LINK */
decode(a.type_type#, 0, null, 
                     2, 'TABLE', 
                     4, 'VIEW', 
                     9, 'PACKAGE', 
                    13, 'TYPE'),
a.pls_type, /* PLS_TYPE */
decode(a.type#, 1, a.scale, 96, a.scale, 0), /* CHAR_LENGTH */
decode(a.type#,
        1, decode(bitand(a.properties, 128), 128, 'C', 'B'),
       96, decode(bitand(a.properties, 128), 128, 'C', 'B'), 0), /*CHAR_USED*/
case when bitand(o.flags, &sharing_bits)>0 then 1 else 0 end,
to_number(sys_context('USERENV', 'CON_ID'))
from sys."_CURRENT_EDITION_OBJ" o,argument$ a,user$ u
where o.obj# = a.obj#
and (o.type# in (7, 8, 9, 11, 14) or
     (o.type# = 13 and o.subname is null))
and o.owner# = u.user#
/

create or replace view DBA_ARGUMENTS
(OWNER, OBJECT_NAME, PACKAGE_NAME, OBJECT_ID, OVERLOAD, SUBPROGRAM_ID, 
ARGUMENT_NAME, POSITION, SEQUENCE,
DATA_LEVEL, DATA_TYPE, DEFAULTED, DEFAULT_VALUE, DEFAULT_LENGTH, IN_OUT, 
DATA_LENGTH, DATA_PRECISION, DATA_SCALE, RADIX, CHARACTER_SET_NAME,
TYPE_OWNER, TYPE_NAME, TYPE_SUBNAME, TYPE_LINK, TYPE_OBJECT_TYPE, PLS_TYPE,
CHAR_LENGTH, CHAR_USED, ORIGIN_CON_ID)
as
select
   OWNER, OBJECT_NAME, PACKAGE_NAME, OBJECT_ID, OVERLOAD, 
   SUBPROGRAM_ID, ARGUMENT_NAME, POSITION, SEQUENCE,
   DATA_LEVEL, DATA_TYPE, DEFAULTED, DEFAULT_VALUE, DEFAULT_LENGTH, 
   IN_OUT, DATA_LENGTH, DATA_PRECISION, DATA_SCALE, RADIX, 
   CHARACTER_SET_NAME, TYPE_OWNER, TYPE_NAME, TYPE_SUBNAME, 
   TYPE_LINK, TYPE_OBJECT_TYPE, PLS_TYPE, CHAR_LENGTH, CHAR_USED, ORIGIN_CON_ID
from INT$DBA_ARGUMENTS 
/

comment on table dba_arguments is
'All arguments for objects in the database'
/
comment on column dba_arguments.object_name is
'Procedure or function name'
/
comment on column dba_arguments.overload is
'Overload unique identifier'
/
comment on column dba_arguments.subprogram_id is
'Unique sub-program Identifier'
/
comment on column dba_arguments.package_name is
'Package name'
/
comment on column dba_arguments.object_id is
'Object number of the object'
/
comment on column dba_arguments.argument_name is
'Argument name'
/
comment on column dba_arguments.position is
'Position in argument list, or null for function return value'
/
comment on column dba_arguments.sequence is
'Argument sequence, including all nesting levels'
/
comment on column dba_arguments.data_level is
'Nesting depth of argument for composite types'
/
comment on column dba_arguments.data_type is
'Datatype of the argument'
/
comment on column dba_arguments.defaulted is
'Is the argument defaulted?'
/
comment on column dba_arguments.default_value is
'Default value for the argument'
/
comment on column dba_arguments.default_length is
'Length of default value for the argument'
/
comment on column dba_arguments.in_out is
'Argument direction (IN, OUT, or IN/OUT)'
/
comment on column dba_arguments.data_length is
'Length of the column in bytes'
/
comment on column dba_arguments.data_precision is
'Length: decimal digits (NUMBER) or binary digits (FLOAT)'
/
comment on column dba_arguments.data_scale is
'Digits to right of decimal point in a number'
/
comment on column dba_arguments.radix is
'Argument radix for a number'
/
comment on column dba_arguments.character_set_name is
'Character set name for the argument'
/
comment on column dba_arguments.type_owner is
'Owner name for the argument type in case of object types'
/
comment on column dba_arguments.type_name is
'Object name for the argument type in case of object types'
/
comment on column dba_arguments.type_subname is
'Subordinate object name for the argument type in case of object types'
/
comment on column dba_arguments.type_link is
'Database link name for the argument type in case of object types'
/
comment on column dba_arguments.type_object_type is
'Object type of the argument type'
/
comment on column dba_arguments.pls_type is
'PL/SQL type name for the argument'
/
comment on column dba_arguments.char_length is
'Character limit for string datatypes'
/
comment on column dba_arguments.char_used is
'Is the byte limit (B) or char limit (C) official for this string?'
/
comment on column dba_arguments.origin_con_id is
'ID of Container where row originates'
/
create or replace public synonym DBA_ARGUMENTS for DBA_ARGUMENTS
/
grant select on DBA_ARGUMENTS to select_catalog_role
/

execute SYS.CDBView.create_cdbview(false,'SYS','DBA_ARGUMENTS',-
'CDB_ARGUMENTS');
create or replace public synonym CDB_ARGUMENTS for sys.CDB_ARGUMENTS;
grant select on CDB_ARGUMENTS to select_catalog_role;

create or replace view ALL_ARGUMENTS
(OWNER, OBJECT_NAME, PACKAGE_NAME, OBJECT_ID, OVERLOAD, SUBPROGRAM_ID,
ARGUMENT_NAME, POSITION, SEQUENCE,
DATA_LEVEL, DATA_TYPE, DEFAULTED, DEFAULT_VALUE, DEFAULT_LENGTH, IN_OUT, 
DATA_LENGTH, DATA_PRECISION, DATA_SCALE, RADIX, CHARACTER_SET_NAME,
TYPE_OWNER, TYPE_NAME, TYPE_SUBNAME, TYPE_LINK, TYPE_OBJECT_TYPE, PLS_TYPE,
CHAR_LENGTH, CHAR_USED, ORIGIN_CON_ID)
as
select
   OWNER, OBJECT_NAME, PACKAGE_NAME, OBJECT_ID, OVERLOAD, 
   SUBPROGRAM_ID, ARGUMENT_NAME, POSITION, SEQUENCE,
   DATA_LEVEL, DATA_TYPE, DEFAULTED, DEFAULT_VALUE, DEFAULT_LENGTH, 
   IN_OUT, DATA_LENGTH, DATA_PRECISION, DATA_SCALE, RADIX, 
   CHARACTER_SET_NAME, TYPE_OWNER, TYPE_NAME, TYPE_SUBNAME, 
   TYPE_LINK, TYPE_OBJECT_TYPE, PLS_TYPE, CHAR_LENGTH, CHAR_USED, ORIGIN_CON_ID
from INT$DBA_ARGUMENTS 
where (OWNER = SYS_CONTEXT('USERENV', 'CURRENT_USER')
   or  exists
       (select null 
          from v$enabledprivs 
         where priv_number in (-144,-141)
       )
   or  OBJ_ID(OWNER, nvl(PACKAGE_NAME, OBJECT_NAME), OBJECT_TYPE#,
              OBJECT_ID) in 
       (select obj# 
          from sys.objauth$ 
         where grantee# in (select kzsrorol from x$kzsro) 
           and privilege# = 12
       )
      )
/
comment on table all_arguments is
'Arguments in object accessible to the user'
/
comment on column all_arguments.owner is
'Username of the owner of the object'
/
comment on column all_arguments.object_name is
'Procedure or function name'
/
comment on column all_arguments.overload is
'Overload unique identifier'
/
comment on column all_arguments.subprogram_id is
'Unique sub-program Identifier'
/
comment on column all_arguments.package_name is
'Package name'
/
comment on column all_arguments.object_id is
'Object number of the object'
/
comment on column all_arguments.argument_name is
'Argument name'
/
comment on column all_arguments.position is
'Position in argument list, or null for function return value'
/
comment on column all_arguments.sequence is
'Argument sequence, including all nesting levels'
/
comment on column all_arguments.data_level is
'Nesting depth of argument for composite types'
/
comment on column all_arguments.data_type is
'Datatype of the argument'
/
comment on column all_arguments.defaulted is
'Is the argument defaulted?'
/
comment on column all_arguments.default_value is
'Default value for the argument'
/
comment on column all_arguments.default_length is
'Length of default value for the argument'
/
comment on column all_arguments.in_out is
'Argument direction (IN, OUT, or IN/OUT)'
/
comment on column all_arguments.data_length is
'Length of the column in bytes'
/
comment on column all_arguments.data_precision is
'Length: decimal digits (NUMBER) or binary digits (FLOAT)'
/
comment on column all_arguments.data_scale is
'Digits to right of decimal point in a number'
/
comment on column all_arguments.radix is
'Argument radix for a number'
/
comment on column all_arguments.character_set_name is
'Character set name for the argument'
/
comment on column all_arguments.type_owner is
'Owner name for the argument type in case of object types'
/
comment on column all_arguments.type_name is
'Object name for the argument type in case of object types'
/
comment on column all_arguments.type_subname is
'Subordinate object name for the argument type in case of object types'
/
comment on column all_arguments.type_link is
'Database link name for the argument type in case of object types'
/
comment on column all_arguments.type_object_type is
'Object type of the argument type'
/
comment on column all_arguments.pls_type is
'PL/SQL type name for the argument'
/
comment on column all_arguments.char_length is
'Character limit for string datatypes'
/
comment on column all_arguments.char_used is
'Is the byte limit (B) or char limit (C) official for this string?'
/
comment on column all_arguments.origin_con_id is
'ID of Container where row originates'
/
create or replace public synonym all_arguments for all_arguments
/
grant read on all_arguments to public with grant option
/

create or replace view USER_ARGUMENTS
(OBJECT_NAME, PACKAGE_NAME, OBJECT_ID, OVERLOAD, SUBPROGRAM_ID, 
ARGUMENT_NAME, POSITION, SEQUENCE,
DATA_LEVEL, DATA_TYPE, DEFAULTED, DEFAULT_VALUE, DEFAULT_LENGTH, IN_OUT, 
DATA_LENGTH, DATA_PRECISION, DATA_SCALE, RADIX, CHARACTER_SET_NAME,
TYPE_OWNER, TYPE_NAME, TYPE_SUBNAME, TYPE_LINK, TYPE_OBJECT_TYPE, PLS_TYPE,
CHAR_LENGTH, CHAR_USED, ORIGIN_CON_ID)
as
select
   OBJECT_NAME, PACKAGE_NAME, OBJECT_ID, OVERLOAD, 
   SUBPROGRAM_ID, ARGUMENT_NAME, POSITION, SEQUENCE,
   DATA_LEVEL, DATA_TYPE, DEFAULTED, DEFAULT_VALUE, DEFAULT_LENGTH, 
   IN_OUT, DATA_LENGTH, DATA_PRECISION, DATA_SCALE, RADIX, 
   CHARACTER_SET_NAME, TYPE_OWNER, TYPE_NAME, TYPE_SUBNAME, 
   TYPE_LINK, TYPE_OBJECT_TYPE, PLS_TYPE, CHAR_LENGTH, CHAR_USED, ORIGIN_CON_ID
from NO_ROOT_SW_FOR_LOCAL(INT$DBA_ARGUMENTS) 
where OWNER = SYS_CONTEXT('USERENV', 'CURRENT_USER')
/

comment on table user_arguments is
'Arguments in object accessible to the user'
/
comment on column user_arguments.object_name is
'Procedure or function name'
/
comment on column user_arguments.overload is
'Overload unique identifier'
/
comment on column user_arguments.subprogram_id is
'Unique sub-program Identifier'
/
comment on column user_arguments.package_name is
'Package name'
/
comment on column user_arguments.object_id is
'Object number of the object'
/
comment on column user_arguments.argument_name is
'Argument name'
/
comment on column user_arguments.position is
'Position in argument list, or null for function return value'
/
comment on column user_arguments.sequence is
'Argument sequence, including all nesting levels'
/
comment on column user_arguments.data_level is
'Nesting depth of argument for composite types'
/
comment on column user_arguments.data_type is
'Datatype of the argument'
/
comment on column user_arguments.defaulted is
'Is the argument defaulted?'
/
comment on column user_arguments.default_value is
'Default value for the argument'
/
comment on column user_arguments.default_length is
'Length of default value for the argument'
/
comment on column user_arguments.in_out is
'Argument direction (IN, OUT, or IN/OUT)'
/
comment on column user_arguments.data_length is
'Length of the column in bytes'
/
comment on column user_arguments.data_precision is
'Length: decimal digits (NUMBER) or binary digits (FLOAT)'
/
comment on column user_arguments.data_scale is
'Digits to right of decimal point in a number'
/
comment on column user_arguments.radix is
'Argument radix for a number'
/
comment on column user_arguments.character_set_name is
'Character set name for the argument'
/
comment on column user_arguments.type_owner is
'Owner name for the argument type in case of object types'
/
comment on column user_arguments.type_name is
'Object name for the argument type in case of object types'
/
comment on column user_arguments.type_subname is
'Subordinate object name for the argument type in case of object types'
/
comment on column user_arguments.type_link is
'Database link name for the argument type in case of object types'
/
comment on column user_arguments.type_object_type is
'Object type of the argument type'
/
comment on column user_arguments.pls_type is
'PL/SQL type name for the argument'
/
comment on column user_arguments.char_length is
'Character limit for string datatypes'
/
comment on column user_arguments.char_used is
'Is the byte limit (B) or char limit (C) official for this string?'
/
comment on column user_arguments.origin_con_id is
'ID of Container where row originates'
/
create or replace public synonym user_arguments for user_arguments
/
grant read on user_arguments to public with grant option
/

remark
remark  FAMILY "ASSEMBLIES"
remark
remark  Views for showing information about PL/SQL Assemblies:
remark  USER_ASSEMBLIES, ALL_ASSEMBLIES and DBA_ASSEMBLIES
remark
create or replace view USER_ASSEMBLIES
(ASSEMBLY_NAME, FILE_SPEC, SECURITY_LEVEL, IDENTITY, STATUS)
as
select o.name,
       a.filespec,
       decode(a.security_level, 0, 'SAFE', 1, 'EXTERNAL_1', 2, 'EXTERNAL_2',
                                3, 'EXTERNAL_3', 4, 'UNSAFE'),
       a.identity,
       decode(o.status, 0, 'N/A', 1, 'VALID', 'INVALID')
from sys."_CURRENT_EDITION_OBJ" o, sys.assembly$ a
where o.owner# = userenv('SCHEMAID')
  and o.obj# = a.obj#
/
rem  and ((l.property is null) or (bitand(l.property, 2) = 0))
comment on table USER_ASSEMBLIES is
'Description of the user''s own assemblies'
/
comment on column USER_ASSEMBLIES.ASSEMBLY_NAME is
'Name of the assembly'
/
comment on column USER_ASSEMBLIES.FILE_SPEC is
'Operating system file specification of the assembly'
/
comment on column USER_ASSEMBLIES.SECURITY_LEVEL is
'The maximum security level of the assembly'
/
comment on column USER_ASSEMBLIES.IDENTITY is
'The identity of the assembly'
/
comment on column USER_ASSEMBLIES.STATUS is
'Status of the assembly'
/
create or replace public synonym USER_ASSEMBLIES for USER_ASSEMBLIES
/
grant read on USER_ASSEMBLIES to PUBLIC with grant option
/

create or replace view ALL_ASSEMBLIES
(OWNER, ASSEMBLY_NAME, FILE_SPEC, SECURITY_LEVEL, IDENTITY, STATUS)
as
select u.name,
       o.name,
       a.filespec,
       decode(a.security_level, 0, 'SAFE', 1, 'EXTERNAL_1', 2, 'EXTERNAL_2',
                                3, 'EXTERNAL_3', 4, 'UNSAFE'),
       a.identity,
       decode(o.status, 0, 'N/A', 1, 'VALID', 'INVALID')
from sys."_CURRENT_EDITION_OBJ" o, sys.assembly$ a, sys.user$ u
where o.owner# = u.user#
  and o.obj# = a.obj#
  and (o.owner# in (userenv('SCHEMAID'), 1 /* PUBLIC */)
       or o.obj# in
          ( select oa.obj#
            from sys.objauth$ oa
            where grantee# in (select kzsrorol from x$kzsro)
          )
       or (
            exists (select NULL from v$enabledprivs
                    where priv_number in (
                                           -282 /* CREATE ANY ASSEMBLY */,
                                           -283 /* ALTER ANY ASSEMBLY */,
                                           -284 /* DROP ANY ASSEMBLY */,
                                           -285 /* EXECUTE ANY ASSEMBLY */
                                         )
                   )
          )
      )
/
comment on table ALL_ASSEMBLIES is
'Description of assemblies accessible to the user'
/
comment on column ALL_ASSEMBLIES.OWNER is
'Owner of the assembly'
/
comment on column ALL_ASSEMBLIES.ASSEMBLY_NAME is
'Name of the assembly'
/
comment on column ALL_ASSEMBLIES.FILE_SPEC is
'Operating system file specification of the assembly'
/
comment on column ALL_ASSEMBLIES.SECURITY_LEVEL is
'The maximum security level of the assembly'
/
comment on column ALL_ASSEMBLIES.IDENTITY is
'The identity of the assembly'
/
comment on column ALL_ASSEMBLIES.STATUS is
'Status of the assembly'
/
create or replace public synonym ALL_ASSEMBLIES for ALL_ASSEMBLIES
/
grant read on ALL_ASSEMBLIES to PUBLIC with grant option
/

create or replace view DBA_ASSEMBLIES
(OWNER, ASSEMBLY_NAME, FILE_SPEC, SECURITY_LEVEL, IDENTITY, STATUS)
as
select u.name,
       o.name,
       a.filespec,
       decode(a.security_level, 0, 'SAFE', 1, 'EXTERNAL_1', 2, 'EXTERNAL_2',
                                3, 'EXTERNAL_3', 4, 'UNSAFE'),
       a.identity,
       decode(o.status, 0, 'N/A', 1, 'VALID', 'INVALID')
from sys."_CURRENT_EDITION_OBJ" o, sys.assembly$ a, sys.user$ u
where o.owner# = u.user#
  and o.obj# = a.obj#
/
comment on table DBA_ASSEMBLIES is
'Description of all assemblies in the database'
/
comment on column DBA_ASSEMBLIES.OWNER is
'Owner of the assembly'
/
comment on column DBA_ASSEMBLIES.ASSEMBLY_NAME is
'Name of the assembly'
/
comment on column DBA_ASSEMBLIES.FILE_SPEC is
'Operating system file specification of the assembly'
/
comment on column DBA_ASSEMBLIES.SECURITY_LEVEL is
'The maximum security level of the assembly'
/
comment on column DBA_ASSEMBLIES.IDENTITY is
'The identity of the assembly'
/
comment on column DBA_ASSEMBLIES.STATUS is
'Status of the assembly'
/
create or replace public synonym DBA_ASSEMBLIES for DBA_ASSEMBLIES
/
grant select on DBA_ASSEMBLIES to select_catalog_role
/

execute SYS.CDBView.create_cdbview(false,'SYS','DBA_ASSEMBLIES',-
'CDB_ASSEMBLIES');
create or replace public synonym CDB_ASSEMBLIES for sys.CDB_ASSEMBLIES;
grant select on CDB_ASSEMBLIES to select_catalog_role;


remark
remark    FAMILY "IDENTIFIERS"
remark    PL/SQL IDENTIFIERS in stored objects.  Objects are types, 
remark    type bodies, PL/SQL packages, package bodies, procedures and 
remark    functions.
remark

create or replace view INT$DBA_IDENTIFIERS SHARING=EXTENDED DATA 
(OWNER, NAME, SIGNATURE, TYPE, OBJECT_NAME, OBJECT_ID, OBJECT_TYPE, 
OBJECT_TYPE#, USAGE, USAGE_ID, LINE, COL, USAGE_CONTEXT_ID, CHARACTER_SET, 
ATTRIBUTE, CHAR_USED, LENGTH, PRECISION, PRECISION2, SCALE, LOWER_RANGE, 
UPPER_RANGE, NULL_CONSTRAINT, SQL_BUILTIN, SHARING, ORIGIN_CON_ID)
as
select u.name, i.symrep, i.signature,
decode(i.type#, 1, 'VARIABLE', 2, 'ITERATOR', 3, 'DATE DATATYPE',
                4, 'PACKAGE',  5, 'PROCEDURE', 6, 'FUNCTION', 7, 'FORMAL IN',
                8, 'SUBTYPE',  9, 'CURSOR', 10, 'INDEX TABLE', 11, 'OBJECT',
               12, 'RECORD', 13, 'EXCEPTION', 14, 'BOOLEAN DATATYPE', 
               15, 'CONSTANT',
               16, 'LIBRARY', 17, 'ASSEMBLY', 18, 'DBLINK', 19, 'LABEL',
               20, 'TABLE', 21, 'NESTED TABLE', 22, 'VARRAY', 23, 'REFCURSOR',
               24, 'BLOB DATATYPE', 25, 'CLOB DATATYPE', 26, 'BFILE DATATYPE', 
               27, 'FORMAL IN OUT', 28, 'FORMAL OUT', 29, 'OPAQUE', 
               30, 'NUMBER DATATYPE', 31, 'CHARACTER DATATYPE', 
               32, 'ASSOCIATIVE ARRAY', 33, 'TIME DATATYPE', 34, 'TIMESTAMP DATATYPE', 
               35, 'INTERVAL DATATYPE', 36, 'UROWID', 37, 'SYNONYM', 38, 'TRIGGER',
               39, 'VIEW', 40, 'COLUMN', 55, 'SEQUENCE', 56, 'OPERATOR', 'UNDEFINED'),
o.name, 
o.obj#,
decode(o.type#, 2, 'TABLE', 4, 'VIEW', 5, 'SYNONYM', 6, 'SEQUENCE', 7, 'PROCEDURE', 
                8, 'FUNCTION', 9, 'PACKAGE', 11, 'PACKAGE BODY', 12, 'TRIGGER', 
                13, 'TYPE', 14, 'TYPE BODY', 22, 'LIBRARY', 33, 'OPERATOR', 
                87, 'ASSEMBLY', 'UNDEFINED'),
o.type#, 
decode(a.action, 1, 'DECLARATION', 2, 'DEFINITION', 3, 'CALL', 4, 'REFERENCE', 
                 5, 'ASSIGNMENT', 'UNDEFINED'),
a.action#, a.line, a.col, a.context#, 
/*CHARACTER_SET */
decode(bitand(a.flags, 30), 2, 'ANY_CS', 4, 'NCHAR_CS', 8, 'CHAR_CS', 
                           16, 'IDENTIFIER', NULL),
/* ATTRIBUTE */
decode(bitand(a.flags, 224), 32, 'ROWTYPE', 64, 'CHARSET', 128, 'TYPE', NULL),
/* CHAR_USED */
decode(bitand(a.flags, 768), 256, 'CHAR', 512, 'BYTE', NULL),
/* LENGTH */
decode(bitand(a.flags, 40960), 40960, a.exp2, NULL),
/* PRECISION */
CASE                                                            
  WHEN bitand(a.flags, 69632)=69632 then a.exp1
  WHEN bitand(a.flags, 139264)=139264 then a.exp2
  WHEN bitand(a.flags, 266240)=266240 then a.exp1
  ELSE NULL
END,
/* PRECISION2 */
decode(bitand(a.flags, 270336), 270336, a.exp2, NULL),
/* SCALE */
decode(bitand(a.flags, 73728), 73728, a.exp2, NULL),
/* LOWER_RANGE */
decode(bitand(a.flags, 20480), 20480, a.exp1, NULL),
/* UPPER_RANGE */
decode(bitand(a.flags, 24576), 24576, a.exp2, NULL),
/* NULL_CONSTRAINT */
decode(bitand(a.flags, 3072), 1024, 'NOT NULL', 2048, 'NULL', NULL),   
/* SQL_BUILTIN */
decode(bitand(a.flags,  524288),  524288, 'YES', 'NO'),
case when bitand(o.flags, &sharing_bits)>0 then 1 else 0 end,
to_number(sys_context('USERENV', 'CON_ID'))
from sys."_CURRENT_EDITION_OBJ" o, sys.plscope_identifier$ i, 
     sys.plscope_action$ a, sys.user$ u
where i.signature = a.signature 
  and o.obj# = a.obj# 
  and o.owner# = u.user#
  and ( o.type# in (2, 4, 5, 6, 7, 8, 9, 11, 12, 14, 22, 33, 87) OR
       ( o.type# = 13 AND o.subname is null))
/
create or replace view USER_IDENTIFIERS
(NAME, SIGNATURE, TYPE, OBJECT_NAME, OBJECT_TYPE, USAGE, USAGE_ID, LINE, 
 COL, USAGE_CONTEXT_ID, CHARACTER_SET, 
ATTRIBUTE, CHAR_USED, LENGTH, PRECISION, PRECISION2, SCALE, LOWER_RANGE, 
UPPER_RANGE, NULL_CONSTRAINT, SQL_BUILTIN, ORIGIN_CON_ID)
as
select NAME, SIGNATURE, TYPE, OBJECT_NAME, OBJECT_TYPE, USAGE, 
       USAGE_ID, LINE, COL, USAGE_CONTEXT_ID, CHARACTER_SET, 
       ATTRIBUTE, CHAR_USED, LENGTH, PRECISION, PRECISION2, SCALE, 
       LOWER_RANGE, UPPER_RANGE, NULL_CONSTRAINT, SQL_BUILTIN, 
       ORIGIN_CON_ID
from NO_ROOT_SW_FOR_LOCAL(INT$DBA_IDENTIFIERS) 
where OWNER = SYS_CONTEXT('USERENV', 'CURRENT_USER')
/
comment on table USER_IDENTIFIERS is
'Identifiers in stored objects accessible to the user'
/
comment on column USER_IDENTIFIERS.NAME is
'Name of the identifier'
/
comment on column USER_IDENTIFIERS.SIGNATURE is
'Signature of the identifier'
/
comment on column USER_IDENTIFIERS.TYPE is
'Type of the identifier'
/
comment on column USER_IDENTIFIERS.OBJECT_NAME is
'Name of the object where the identifier usage occurred'
/
comment on column USER_IDENTIFIERS.OBJECT_TYPE is
'Type of the object where the identifier usage occurred'
/
comment on column USER_IDENTIFIERS.USAGE is
'Type of the identifier usage'
/
comment on column USER_IDENTIFIERS.USAGE_ID is
'Unique key for an identifier usage within the object'
/
comment on column USER_IDENTIFIERS.LINE is
'Line number of the identifier usage'
/
comment on column USER_IDENTIFIERS.COL is
'Column number of the identifier usage'
/
comment on column USER_IDENTIFIERS.USAGE_CONTEXT_ID is
'Context USAGE_ID of an identifier usage'
/
comment on column USER_IDENTIFIERS.ORIGIN_CON_ID is
'ID of Container where row originates'
/
comment on column USER_IDENTIFIERS.CHARACTER_SET is
'Character set of the identifier when supplied'
/
comment on column USER_IDENTIFIERS.ATTRIBUTE is
'Attribute of the identifier when supplied'
/
comment on column USER_IDENTIFIERS.CHAR_USED is
'When applicable, CHAR if a length was specified in characters, BTYE otherwise'
/
comment on column USER_IDENTIFIERS.LENGTH is
'Length constraint of the identifier when supplied'
/
comment on column USER_IDENTIFIERS.PRECISION is
'Precision constraint of the identifier when supplied'
/
comment on column USER_IDENTIFIERS.PRECISION2 is
'Second precision constraint of the identifier when supplied'
/
comment on column USER_IDENTIFIERS.SCALE is
'Scale precision constraint of the identifier when supplied'
/
comment on column USER_IDENTIFIERS.LOWER_RANGE is
'Lower range constraint of the identifier when supplied'
/
comment on column USER_IDENTIFIERS.UPPER_RANGE is
'Upper range constraint of the identifier when supplied'
/
comment on column USER_IDENTIFIERS.NULL_CONSTRAINT is
'NULL/NOT_NULL constraint of the identifier when supplied'
/
comment on column USER_IDENTIFIERS.SQL_BUILTIN is
'Is the identifier a SQL builtin mapped to a STANDARD function'
/


create or replace public synonym USER_IDENTIFIERS for USER_IDENTIFIERS
/
grant read on USER_IDENTIFIERS to public with grant option
/

create or replace view ALL_IDENTIFIERS
(OWNER, NAME, SIGNATURE, TYPE, OBJECT_NAME, OBJECT_TYPE, USAGE, USAGE_ID, 
LINE, COL, USAGE_CONTEXT_ID, CHARACTER_SET, 
ATTRIBUTE, CHAR_USED, LENGTH, PRECISION, PRECISION2, SCALE, LOWER_RANGE, 
UPPER_RANGE, NULL_CONSTRAINT, SQL_BUILTIN, ORIGIN_CON_ID)
as
select OWNER, NAME, SIGNATURE, TYPE, OBJECT_NAME, OBJECT_TYPE, 
       USAGE, USAGE_ID, LINE, COL, USAGE_CONTEXT_ID, CHARACTER_SET, 
       ATTRIBUTE, CHAR_USED, LENGTH, PRECISION, PRECISION2, SCALE, 
       LOWER_RANGE, UPPER_RANGE, NULL_CONSTRAINT, SQL_BUILTIN,
       ORIGIN_CON_ID
from INT$DBA_IDENTIFIERS 
where 
  (
    OWNER = SYS_CONTEXT('USERENV', 'CURRENT_USER')
    or OWNER = 'PUBLIC'
    or
    (
      (
         (
          (OBJECT_TYPE#
           in (7 /* proc */, 8 /* func */, 9 /* pkg */, 13 /* type */, 
               22 /* library */))
          and
          OBJ_ID(OWNER, OBJECT_NAME, OBJECT_TYPE#, OBJECT_ID) in 
          (select obj# from sys.objauth$
                     where grantee# in (select kzsrorol from x$kzsro)
                       and privilege# in (12 /* EXECUTE */, 26 /* DEBUG */))
        )
        or
        (
          (OBJECT_TYPE# in (2 /* table */, 4 /* view */))
          and
          OBJ_ID(OWNER, OBJECT_NAME, OBJECT_TYPE#, OBJECT_ID) in 
          (select obj# from sys.objauth$
                     where grantee# in (select kzsrorol from x$kzsro)
                       and privilege# in (0 /* ALTER */, 6 /* INSERT */,
                                          9 /* SELECT */, 10 /* UPDATE */))
        )
        or
        (
          (OBJECT_TYPE# in (6 /* sequence */))
          and
          OBJ_ID(OWNER, OBJECT_NAME, OBJECT_TYPE#, OBJECT_ID) in 
          (select obj# from sys.objauth$
                     where grantee# in (select kzsrorol from x$kzsro)
                       and privilege# in (0 /* ALTER */, 9 /* SELECT */))
        )
        or
        (
          (OBJECT_TYPE# in (11 /* package body */, 14 /* type body */))
          and
          exists
          (
            select null from sys.obj$ specobj, sys.objauth$ oa, sys.user$ u
            where specobj.owner# = u.user#
              and u.name = OWNER
              and specobj.name = OBJECT_NAME
              and specobj.type# = decode(OBJECT_TYPE#,
                                         11 /* pkg body */, 9 /* pkg */,
                                         14 /* type body */, 13 /* type */,
                                         null)
              and oa.obj# = specobj.obj#
              and oa.grantee# in (select kzsrorol from x$kzsro)
              and oa.privilege# = 26 /* DEBUG */)
        )
        or
        (
          (OBJECT_TYPE# = 12 /* trigger */)
          and
          exists
          (
            select null 
            from sys.trigger$ t, sys.obj$ tabobj, sys.objauth$ oa, sys.user$ u
            where t.obj# = OBJ_ID(OWNER, OBJECT_NAME, 12, OBJECT_ID)
              and tabobj.obj# = t.baseobject
              and tabobj.owner# = u.user#
              and u.name = OWNER
              and oa.obj# = tabobj.obj#
              and oa.grantee# in (select kzsrorol from x$kzsro)
              and oa.privilege# = 26 /* DEBUG */)
        )
        or
        exists
        (
          select null from sys.sysauth$
          where grantee# in (select kzsrorol from x$kzsro)
          and
          (
            (
              /* procedure */
              (OBJECT_TYPE# = 7 or OBJECT_TYPE# = 8 or OBJECT_TYPE# = 9)
              and
              (
                privilege# = -144 /* EXECUTE ANY PROCEDURE */
                or
                privilege# = -141 /* CREATE ANY PROCEDURE */
                or
                privilege# = -241 /* DEBUG ANY PROCEDURE */
              )
            )
            or
            (
              /* package body */
              OBJECT_TYPE# = 11 and
              (
                privilege# = -141 /* CREATE ANY PROCEDURE */
                or
                privilege# = -241 /* DEBUG ANY PROCEDURE */
              )
            )
            or
            (
              /* type */
              OBJECT_TYPE# = 13
              and
              (
                privilege# = -184 /* EXECUTE ANY TYPE */
                or
                privilege# = -181 /* CREATE ANY TYPE */
                or
                privilege# = -241 /* DEBUG ANY PROCEDURE */
              )
            )
            or
            (
              /* type body */
              OBJECT_TYPE# = 14 and
              (
                privilege# = -181 /* CREATE ANY TYPE */
                or
                privilege# = -241 /* DEBUG ANY PROCEDURE */
              )
            )
            or
            (
              /* triggers */
              OBJECT_TYPE# = 12 and
              (
                privilege# = -152 /* CREATE ANY TRIGGER */
                or
                privilege# = -241 /* DEBUG ANY PROCEDURE */
              )
            )
            or 
            (
              /* library */
              OBJECT_TYPE# = 22 and
              (
                privilege# = -189 /* CREATE ANY LIBRARY */
                or
                privilege# = -192 /* EXECUTE ANY LIBRARY */
              )
            )
          )
        )
      )
    )
  )
/
comment on table ALL_IDENTIFIERS is
'All identifiers in stored objects accessible to the user'
/
comment on column ALL_IDENTIFIERS.NAME is
'Name of the identifier'
/
comment on column ALL_IDENTIFIERS.SIGNATURE is
'Signature of the identifier'
/
comment on column ALL_IDENTIFIERS.TYPE is
'Type of the identifier'
/
comment on column ALL_IDENTIFIERS.OBJECT_NAME is
'Name of the object where the identifier usage occurred'
/
comment on column ALL_IDENTIFIERS.OBJECT_TYPE is
'Type of the object where the identifier usage occurred'
/
comment on column ALL_IDENTIFIERS.USAGE is
'Type of the identifier usage'
/
comment on column ALL_IDENTIFIERS.USAGE_ID is
'Unique key for an identifier usage within the object'
/
comment on column ALL_IDENTIFIERS.LINE is
'Line number of the identifier usage'
/
comment on column ALL_IDENTIFIERS.COL is
'Column number of the identifier usage'
/
comment on column ALL_IDENTIFIERS.USAGE_CONTEXT_ID is
'Context USAGE_ID of an identifier usage'
/
comment on column ALL_IDENTIFIERS.ORIGIN_CON_ID is
'ID of Container where row originates'
/
comment on column ALL_IDENTIFIERS.CHARACTER_SET is
'Character set of the identifier when supplied'
/
comment on column ALL_IDENTIFIERS.ATTRIBUTE is
'Attribute of the identifier when supplied'
/
comment on column ALL_IDENTIFIERS.CHAR_USED is
'When applicable, CHAR if a length was specified in characters, BTYE otherwise'
/
comment on column ALL_IDENTIFIERS.LENGTH is
'Length constraint of the identifier when supplied'
/
comment on column ALL_IDENTIFIERS.PRECISION is
'Precision constraint of the identifier when supplied'
/
comment on column ALL_IDENTIFIERS.PRECISION2 is
'Second precision constraint of the identifier when supplied'
/
comment on column ALL_IDENTIFIERS.SCALE is
'Scale precision constraint of the identifier when supplied'
/
comment on column ALL_IDENTIFIERS.LOWER_RANGE is
'Lower range constraint of the identifier when supplied'
/
comment on column ALL_IDENTIFIERS.UPPER_RANGE is
'Upper range constraint of the identifier when supplied'
/
comment on column ALL_IDENTIFIERS.NULL_CONSTRAINT is
'NULL/NOT_NULL constraint of the identifier when supplied'
/
comment on column ALL_IDENTIFIERS.SQL_BUILTIN is
'Is the identifier a SQL builtin mapped to a STANDARD function'
/

create or replace public synonym ALL_IDENTIFIERS for ALL_IDENTIFIERS
/
grant read on ALL_IDENTIFIERS to public with grant option
/


create or replace view DBA_IDENTIFIERS
(OWNER, NAME, SIGNATURE, TYPE, OBJECT_NAME, OBJECT_TYPE, USAGE, USAGE_ID, 
LINE, COL, USAGE_CONTEXT_ID, CHARACTER_SET, 
ATTRIBUTE, CHAR_USED, LENGTH, PRECISION, PRECISION2, SCALE, LOWER_RANGE, 
UPPER_RANGE, NULL_CONSTRAINT, SQL_BUILTIN, ORIGIN_CON_ID)
as
select OWNER, NAME, SIGNATURE, TYPE, OBJECT_NAME, OBJECT_TYPE, 
       USAGE, USAGE_ID, LINE, COL, USAGE_CONTEXT_ID, CHARACTER_SET, 
       ATTRIBUTE, CHAR_USED, LENGTH, PRECISION, PRECISION2, SCALE, 
       LOWER_RANGE, UPPER_RANGE, NULL_CONSTRAINT, SQL_BUILTIN, 
       ORIGIN_CON_ID
from INT$DBA_IDENTIFIERS 
/

comment on table DBA_IDENTIFIERS is
'Identifiers in stored objects accessible to sys'
/
comment on column DBA_IDENTIFIERS.NAME is
'Name of the identifier'
/
comment on column DBA_IDENTIFIERS.SIGNATURE is
'Signature of the identifier'
/
comment on column DBA_IDENTIFIERS.TYPE is
'Type of the identifier'
/
comment on column DBA_IDENTIFIERS.OBJECT_NAME is
'Name of the object where the identifier usage occurred'
/
comment on column DBA_IDENTIFIERS.OBJECT_TYPE is
'Type of the object where the identifier usage occurred'
/
comment on column DBA_IDENTIFIERS.USAGE is
'Type of the identifier usage'
/
comment on column DBA_IDENTIFIERS.USAGE_ID is
'Unique key for an identifier usage within the object'
/
comment on column DBA_IDENTIFIERS.LINE is
'Line number of the identifier usage'
/
comment on column DBA_IDENTIFIERS.COL is
'Column number of the identifier usage'
/
comment on column DBA_IDENTIFIERS.USAGE_CONTEXT_ID is
'Context USAGE_ID of an identifier usage'
/
comment on column DBA_IDENTIFIERS.ORIGIN_CON_ID is
'ID of Container where row originates'
/
comment on column DBA_IDENTIFIERS.CHARACTER_SET is
'Character set of the identifier when supplied'
/
comment on column DBA_IDENTIFIERS.ATTRIBUTE is
'Attribute of the identifier when supplied'
/
comment on column DBA_IDENTIFIERS.CHAR_USED is
'When applicable, CHAR if a length was specified in characters, BTYE otherwise'
/
comment on column DBA_IDENTIFIERS.LENGTH is
'Length constraint of the identifier when supplied'
/
comment on column DBA_IDENTIFIERS.PRECISION is
'Precision constraint of the identifier when supplied'
/
comment on column DBA_IDENTIFIERS.PRECISION2 is
'Second precision constraint of the identifier when supplied'
/
comment on column DBA_IDENTIFIERS.SCALE is
'Scale precision constraint of the identifier when supplied'
/
comment on column DBA_IDENTIFIERS.LOWER_RANGE is
'Lower range constraint of the identifier when supplied'
/
comment on column DBA_IDENTIFIERS.UPPER_RANGE is
'Upper range constraint of the identifier when supplied'
/
comment on column DBA_IDENTIFIERS.NULL_CONSTRAINT is
'NULL/NOT_NULL constraint of the identifier when supplied'
/
comment on column DBA_IDENTIFIERS.SQL_BUILTIN is
'Is the identifier a SQL builtin mapped to a STANDARD function'
/

create or replace public synonym DBA_IDENTIFIERS for DBA_IDENTIFIERS
/
grant select on DBA_IDENTIFIERS to select_catalog_role
/

execute SYS.CDBView.create_cdbview(false,'SYS','DBA_IDENTIFIERS',-
'CDB_IDENTIFIERS');
create or replace public synonym CDB_IDENTIFIERS for sys.CDB_IDENTIFIERS;
grant select on CDB_IDENTIFIERS to select_catalog_role;

remark
remark    FAMILY "STATEMENTS"
remark    SQL STATEMENTS in stored PL/SQL objects. 
remark

create or replace view INT$DBA_STATEMENTS SHARING=EXTENDED DATA 
(OWNER, SIGNATURE, TYPE, OBJECT_NAME, OBJECT_ID, OBJECT_TYPE, 
OBJECT_TYPE#, USAGE_ID, LINE, COL, USAGE_CONTEXT_ID, SQL_ID, 
HAS_HINT, HAS_INTO_BULK, HAS_INTO_RETURNING, HAS_INTO_RECORD,
HAS_CURRENT_OF, HAS_FOR_UPDATE, HAS_IN_BINDS,
TEXT, FULL_TEXT,
SHARING, ORIGIN_CON_ID)
as
select u.name, st.signature,
decode(st.type#, 41, 'SELECT', 42, 'INSERT',  43, 'UPDATE', 44, 'DELETE', 
                 45, 'MERGE', 46, 'SET TRANSACTION', 47, 'LOCK TABLE', 
                 48, 'COMMIT', 49, 'SAVEPOINT', 50, 'ROLLBACK', 
                 51, 'EXECUTE IMMEDIATE', 52, 'OPEN', 53, 'CLOSE', 
                 54, 'FETCH', 'UNDEFINED'),
o.name, 
o.obj#,
decode(o.type#, 2, 'TABLE', 4, 'VIEW', 7, 'PROCEDURE', 8, 'FUNCTION',
                9, 'PACKAGE', 11, 'PACKAGE BODY', 12, 'TRIGGER', 13, 'TYPE',
                14, 'TYPE BODY',
                'UNDEFINED'),
o.type#, 
a.action#, a.line, a.col, a.context#, 
decode(st.type#, 41, s.sql_id,42, s.sql_id, 43, s.sql_id, 
                 44, s.sql_id,45, s.sql_id, null),
decode(bitand(st.flags, 1), 1, 'YES', 'NO'),
decode(bitand(st.flags, 2), 2, 'YES', 'NO'),
decode(bitand(st.flags, 4), 4, 'YES', 'NO'),
decode(bitand(st.flags, 8), 8, 'YES', 'NO'),
decode(bitand(st.flags, 16), 16, 'YES', 'NO'),
decode(bitand(st.flags, 32), 32, 'YES', 'NO'),
decode(bitand(st.flags, 64), 64, 'YES', 'NO'),
decode(st.type#, 41, s.sql_text, 42, s.sql_text, 43, s.sql_text, 
                 44, s.sql_text, 45, s.sql_text, null),
decode(st.type#, 41, s.sql_fulltext, 42, s.sql_fulltext, 
                 43, s.sql_fulltext, 44, s.sql_fulltext, 
                 45, s.sql_fulltext, null),
decode(bitand(o.flags, &sharing_bits), 0, 0, 1), 
to_number(sys_context('USERENV', 'CON_ID'))
from sys."_CURRENT_EDITION_OBJ" o, sys.plscope_statement$ st, 
     sys.plscope_action$ a, sys.user$ u, sys.plscope_sql$ s
where st.signature = a.signature 
  and o.obj# = a.obj# 
  and o.owner# = u.user#
  and ( o.type# in (2, 4, 5, 7, 8, 9, 11, 12, 13, 14))
  and st.sql_id = s.sql_id
  and st.obj# = s.obj#
/

create or replace view USER_STATEMENTS
(SIGNATURE, TYPE, OBJECT_NAME, OBJECT_TYPE, 
USAGE_ID, LINE, COL, USAGE_CONTEXT_ID, SQL_ID, HAS_HINT, HAS_INTO_BULK, 
HAS_INTO_RETURNING, HAS_INTO_RECORD, HAS_CURRENT_OF, HAS_FOR_UPDATE, HAS_IN_BINDS,
TEXT, FULL_TEXT, ORIGIN_CON_ID)
as
select SIGNATURE, TYPE, OBJECT_NAME, OBJECT_TYPE, 
USAGE_ID, LINE, COL, USAGE_CONTEXT_ID, SQL_ID, HAS_HINT, HAS_INTO_BULK, 
HAS_INTO_RETURNING, HAS_INTO_RECORD, HAS_CURRENT_OF, HAS_FOR_UPDATE, HAS_IN_BINDS,
TEXT, FULL_TEXT, ORIGIN_CON_ID
from NO_ROOT_SW_FOR_LOCAL(INT$DBA_STATEMENTS) 
where OWNER = SYS_CONTEXT('USERENV', 'CURRENT_USER')
/
comment on table USER_STATEMENTS is
'SQL statements in stored PL/SQL objects accessible to the user'
/
comment on column USER_STATEMENTS.SIGNATURE is
'Signature of the SQL statement'
/
comment on column USER_STATEMENTS.TYPE is
'Type of the statement'
/
comment on column USER_STATEMENTS.OBJECT_NAME is
'Name of the object where the SQL statement occurred'
/
comment on column USER_STATEMENTS.OBJECT_TYPE is
'Type of the object where the SQL statement occurred'
/
comment on column USER_STATEMENTS.USAGE_ID is
'Unique key for a SQL statement within the object'
/
comment on column USER_STATEMENTS.LINE is
'Line number of the SQL statement'
/
comment on column USER_STATEMENTS.COL is
'Column number of the SQL statement'
/
comment on column USER_STATEMENTS.USAGE_CONTEXT_ID is
'Context USAGE_ID of a the SQL statement'
/
comment on column USER_STATEMENTS.SQL_ID is
'SQLID of the SQL statement'
/
comment on column USER_STATEMENTS.HAS_HINT is
'TRUE if the SQL statement contains a hint'
/
comment on column USER_STATEMENTS.TEXT is
'Varchar2 text of the SQL statement'
/
comment on column USER_STATEMENTS.FULL_TEXT is
'Clob text of the SQL statement'
/
comment on column USER_STATEMENTS.ORIGIN_CON_ID is
'ID of Container where row originates'
/

create or replace public synonym USER_STATEMENTS for USER_STATEMENTS
/
grant read on USER_STATEMENTS to public with grant option
/

create or replace view ALL_STATEMENTS
(OWNER, SIGNATURE, TYPE, OBJECT_NAME, OBJECT_TYPE, 
USAGE_ID, LINE, COL, USAGE_CONTEXT_ID, SQL_ID, HAS_HINT, HAS_INTO_BULK, 
HAS_INTO_RETURNING, HAS_INTO_RECORD, HAS_CURRENT_OF, HAS_FOR_UPDATE, HAS_IN_BINDS,
TEXT, FULL_TEXT, ORIGIN_CON_ID)
as
select OWNER, SIGNATURE, TYPE, OBJECT_NAME, OBJECT_TYPE, 
USAGE_ID, LINE, COL, USAGE_CONTEXT_ID, SQL_ID, HAS_HINT, HAS_INTO_BULK, 
HAS_INTO_RETURNING, HAS_INTO_RECORD, HAS_CURRENT_OF, HAS_FOR_UPDATE, HAS_IN_BINDS,
TEXT, FULL_TEXT, ORIGIN_CON_ID
from INT$DBA_STATEMENTS
where 
  (
    OWNER = SYS_CONTEXT('USERENV', 'CURRENT_USER')
    or OWNER = 'PUBLIC'
    or
    (
      (
         (
          (OBJECT_TYPE#
           in (7 /* proc */, 8 /* func */, 9 /* pkg */, 13 /* type */))
          and
          OBJ_ID(OWNER, OBJECT_NAME, OBJECT_TYPE#, OBJECT_ID) in 
          (select obj# from sys.objauth$
                     where grantee# in (select kzsrorol from x$kzsro)
                       and privilege# in (12 /* EXECUTE */, 26 /* DEBUG */))
        )
        or
        (
          (OBJECT_TYPE# in (2 /* table */, 4 /* view */))
          and
          OBJ_ID(OWNER, OBJECT_NAME, OBJECT_TYPE#, OBJECT_ID) in 
          (select obj# from sys.objauth$
                     where grantee# in (select kzsrorol from x$kzsro)
                       and privilege# in (0 /* ALTER */, 6 /* INSERT */,
                                          9 /* SELECT */, 10 /* UPDATE */))
        )
        or
        (
          (OBJECT_TYPE# in (11 /* package body */, 14 /* type body */))
          and
          exists
          (
            select null from sys.obj$ specobj, sys.objauth$ oa, sys.user$ u
            where specobj.owner# = u.user#
              and u.name = OWNER
              and specobj.name = OBJECT_NAME
              and specobj.type# = decode(OBJECT_TYPE#,
                                         11 /* pkg body */, 9 /* pkg */,
                                         14 /* type body */, 13 /* type */,
                                         null)
              and oa.obj# = specobj.obj#
              and oa.grantee# in (select kzsrorol from x$kzsro)
              and oa.privilege# = 26 /* DEBUG */)
        )
        or
        (
          (OBJECT_TYPE# = 12 /* trigger */)
          and
          exists
          (
            select null 
            from sys.trigger$ t, sys.obj$ tabobj, sys.objauth$ oa, sys.user$ u
            where t.obj# = OBJ_ID(OWNER, OBJECT_NAME, 12, OBJECT_ID)
              and tabobj.obj# = t.baseobject
              and tabobj.owner# = u.user#
              and u.name = OWNER
              and oa.obj# = tabobj.obj#
              and oa.grantee# in (select kzsrorol from x$kzsro)
              and oa.privilege# = 26 /* DEBUG */)
        )
        or
        exists
        (
          select null from sys.sysauth$
          where grantee# in (select kzsrorol from x$kzsro)
          and
          (
            (
              /* procedure */
              (OBJECT_TYPE# = 7 or OBJECT_TYPE# = 8 or OBJECT_TYPE# = 9)
              and
              (
                privilege# = -144 /* EXECUTE ANY PROCEDURE */
                or
                privilege# = -141 /* CREATE ANY PROCEDURE */
                or
                privilege# = -241 /* DEBUG ANY PROCEDURE */
              )
            )
            or
            (
              /* package body */
              OBJECT_TYPE# = 11 and
              (
                privilege# = -141 /* CREATE ANY PROCEDURE */
                or
                privilege# = -241 /* DEBUG ANY PROCEDURE */
              )
            )
            or
            (
              /* type */
              OBJECT_TYPE# = 13
              and
              (
                privilege# = -184 /* EXECUTE ANY TYPE */
                or
                privilege# = -181 /* CREATE ANY TYPE */
                or
                privilege# = -241 /* DEBUG ANY PROCEDURE */
              )
            )
            or
            (
              /* type body */
              OBJECT_TYPE# = 14 and
              (
                privilege# = -181 /* CREATE ANY TYPE */
                or
                privilege# = -241 /* DEBUG ANY PROCEDURE */
              )
            )
            or
            (
              /* triggers */
              OBJECT_TYPE# = 12 and
              (
                privilege# = -152 /* CREATE ANY TRIGGER */
                or
                privilege# = -241 /* DEBUG ANY PROCEDURE */
              )
            )
            or 
            (
              /* library */
              OBJECT_TYPE# = 22 and
              (
                privilege# = -189 /* CREATE ANY LIBRARY */
                or
                privilege# = -192 /* EXECUTE ANY LIBRARY */
              )
            )
          )
        )
      )
    )
  )
/
comment on table ALL_STATEMENTS is
'All SQL statements in stored objects accessible to the user'
/
comment on column ALL_STATEMENTS.SIGNATURE is
'Signature of the statement'
/
comment on column ALL_STATEMENTS.TYPE is
'Type of the statement'
/
comment on column ALL_STATEMENTS.OBJECT_NAME is
'Name of the object where the statement usage occurred'
/
comment on column ALL_STATEMENTS.OBJECT_TYPE is
'Type of the object where the statement usage occurred'
/
comment on column ALL_STATEMENTS.USAGE_ID is
'Unique key for an statement usage within the object'
/
comment on column ALL_STATEMENTS.LINE is
'Line number of the statement usage'
/
comment on column ALL_STATEMENTS.COL is
'Column number of the statement usage'
/
comment on column ALL_STATEMENTS.USAGE_CONTEXT_ID is
'Context USAGE_ID of an statement usage'
/
comment on column ALL_STATEMENTS.SQL_ID is
'SQLID of the SQL statement'
/
comment on column ALL_STATEMENTS.HAS_HINT is
'TRUE if the SQL statement contains a hint'
/
comment on column ALL_STATEMENTS.TEXT is
'Varchar2 text of the SQL statement'
/
comment on column ALL_STATEMENTS.FULL_TEXT is
'Clob text of the SQL statement'
/
comment on column ALL_STATEMENTS.ORIGIN_CON_ID is
'ID of Container where row originates'
/

create or replace public synonym ALL_STATEMENTS for ALL_STATEMENTS
/
grant read on ALL_STATEMENTS to public with grant option
/


create or replace view DBA_STATEMENTS
(OWNER, SIGNATURE, TYPE, OBJECT_NAME, OBJECT_TYPE, 
USAGE_ID, LINE, COL, USAGE_CONTEXT_ID, SQL_ID, HAS_HINT, HAS_INTO_BULK, 
HAS_INTO_RETURNING, HAS_INTO_RECORD, HAS_CURRENT_OF, HAS_FOR_UPDATE, HAS_IN_BINDS,
TEXT, FULL_TEXT, ORIGIN_CON_ID)
as
select OWNER, SIGNATURE, TYPE, OBJECT_NAME, OBJECT_TYPE, 
USAGE_ID, LINE, COL, USAGE_CONTEXT_ID, SQL_ID, HAS_HINT, HAS_INTO_BULK, 
HAS_INTO_RETURNING, HAS_INTO_RECORD, HAS_CURRENT_OF, HAS_FOR_UPDATE, HAS_IN_BINDS,
TEXT, FULL_TEXT, ORIGIN_CON_ID
from INT$DBA_STATEMENTS
/

comment on table DBA_STATEMENTS is
'Statements in stored objects accessible to sys'
/
comment on column DBA_STATEMENTS.SIGNATURE is
'Signature of the statement'
/
comment on column DBA_STATEMENTS.TYPE is
'Type of the statement'
/
comment on column DBA_STATEMENTS.OBJECT_NAME is
'Name of the object where the statement usage occurred'
/
comment on column DBA_STATEMENTS.OBJECT_TYPE is
'Type of the object where the statement usage occurred'
/
comment on column DBA_STATEMENTS.USAGE_ID is
'Unique key for an statement usage within the object'
/
comment on column DBA_STATEMENTS.LINE is
'Line number of the statement usage'
/
comment on column DBA_STATEMENTS.COL is
'Column number of the statement usage'
/
comment on column DBA_STATEMENTS.USAGE_CONTEXT_ID is
'Context USAGE_ID of an statement usage'
/
comment on column DBA_STATEMENTS.SQL_ID is
'SQLID of the SQL statement'
/
comment on column DBA_STATEMENTS.HAS_HINT is
'TRUE if the SQL statement contains a hint'
/
comment on column DBA_STATEMENTS.TEXT is
'Varchar2 text of the SQL statement'
/
comment on column DBA_STATEMENTS.FULL_TEXT is
'Clob text of the SQL statement'
/
comment on column DBA_STATEMENTS.ORIGIN_CON_ID is
'ID of Container where row originates'
/
create or replace public synonym DBA_STATEMENTS for DBA_STATEMENTS
/
grant select on DBA_STATEMENTS to select_catalog_role
/

execute SYS.CDBView.create_cdbview(false,'SYS','DBA_STATEMENTS',-
'CDB_STATEMENTS');
create or replace public synonym CDB_STATEMENTS for sys.CDB_STATEMENTS;
grant select on CDB_STATEMENTS to select_catalog_role;

remark
remark  FAMILY "PLSQL_TYPES"
remark
remark  Views for showing information about types:
remark  USER_PLSQL_TYPES, ALL_PLSQL_TYPES, and DBA_PLSQL_TYPES
remark
create or replace view USER_PLSQL_TYPES
    (TYPE_NAME, PACKAGE_NAME, TYPE_OID, TYPECODE, ATTRIBUTES, 
     CONTAINS_PLSQL)
as
--
-- Package types
--
select t.typ_name || 
        decode(bitand(t.properties,134217728),134217728,
                      '%ROWTYPE', null), 
       o.name, t.toid,
       decode(t.typecode, 250, 
                          decode(bitand(t.properties,134217728),134217728,
                          'CURSOR ROWTYPE', 'PL/SQL RECORD'),
                          122, 'COLLECTION',
                          'UNKNOWN TYPECODE: ' || t.typecode),
       t.attributes, 
       decode(bitand(t.properties, 67108864), 67108864, 'YES', 0, 'NO')
from sys.type$ t, sys."_CURRENT_EDITION_OBJ" o
where o.owner# = userenv('SCHEMAID')                   -- only the current user
  and t.package_obj# IS NOT NULL                          -- only package types
  and o.obj# = t.package_obj#                 -- match type to its package obj#
  and o.type# <> 10                              -- package must not be invalid
/
comment on table USER_PLSQL_TYPES is
'Description of the user''s own types'
/
comment on column USER_PLSQL_TYPES.TYPE_NAME is
'Name of the type'
/
comment on column USER_PLSQL_TYPES.TYPE_OID is
'Object identifier (OID) of the type'
/
comment on column USER_PLSQL_TYPES.TYPECODE is
'Typecode of the type'
/
comment on column USER_PLSQL_TYPES.ATTRIBUTES is
'Number of attributes (if any) in the type'
/
comment on column USER_PLSQL_TYPES.PACKAGE_NAME is
'Name of the package containing the type'
/
comment on column USER_PLSQL_TYPES.CONTAINS_PLSQL is
'Does the type contain plsql specific data types?'
/
create or replace public synonym USER_PLSQL_TYPES for USER_PLSQL_TYPES
/
grant read on USER_PLSQL_TYPES to PUBLIC with grant option
/

create or replace view ALL_PLSQL_TYPES
    (OWNER, TYPE_NAME, PACKAGE_NAME, TYPE_OID,
     TYPECODE, ATTRIBUTES, CONTAINS_PLSQL)
as
-- 
-- Package Types
--
select u.name, t.typ_name || decode(bitand(t.properties,134217728),134217728,
                                    '%ROWTYPE', null), 
       o.name, t.toid,
       decode(t.typecode, 250, 
                          decode(bitand(t.properties,134217728),134217728,
                          'CURSOR ROWTYPE', 'PL/SQL RECORD'),
                          122, 'COLLECTION',
                          'UNKNOWN TYPECODE: ' || t.typecode),
       t.attributes, 
       decode(bitand(t.properties, 67108864), 67108864, 'YES', 0, 'NO')
from sys.user$ u, sys.type$ t, sys."_CURRENT_EDITION_OBJ" o 
where o.owner# = u.user#
  and o.type# <> 10 -- must not be invalid
  and t.package_obj# IS NOT NULL                          -- only package types
  and o.obj# = t.package_obj#
  and (o.owner# = userenv('SCHEMAID')
       or
       o.obj# in (select oa.obj#
                  from sys.objauth$ oa
                  where grantee# in (select kzsrorol
                                     from x$kzsro))
       or /* user has system privileges */
       exists (select null from v$enabledprivs
               where priv_number in (-144 /* EXECUTE ANY PROCEDURE */,
                                     -141 /* CREATE ANY PROCEDURE */
                                     -241 /* DEBUG ANY PROCEDURE */)))
/
comment on table ALL_PLSQL_TYPES is
'Description of types accessible to the user'
/
comment on column ALL_PLSQL_TYPES.OWNER is
'Owner of the type'
/
comment on column ALL_PLSQL_TYPES.TYPE_NAME is
'Name of the type'
/
comment on column ALL_PLSQL_TYPES.TYPE_OID is
'Object identifier (OID) of the type'
/
comment on column ALL_PLSQL_TYPES.TYPECODE is
'Typecode of the type'
/
comment on column ALL_PLSQL_TYPES.ATTRIBUTES is
'Number of attributes in the type'
/
comment on column ALL_PLSQL_TYPES.PACKAGE_NAME is
'Name of the package containing the type'
/
comment on column ALL_PLSQL_TYPES.CONTAINS_PLSQL is
'Does the type contain plsql specific data types?'
/
create or replace public synonym ALL_PLSQL_TYPES for ALL_PLSQL_TYPES
/
grant read on ALL_PLSQL_TYPES to PUBLIC with grant option
/

create or replace view DBA_PLSQL_TYPES
    (OWNER, TYPE_NAME, PACKAGE_NAME, TYPE_OID,
     TYPECODE, ATTRIBUTES, CONTAINS_PLSQL)
as
--
-- Package types
--
select u.name, t.typ_name || decode(bitand(t.properties,134217728),134217728,
                                    '%ROWTYPE', null), 
       o.name, t.toid,
       decode(t.typecode, 250, 
                          decode(bitand(t.properties,134217728),134217728,
                          'CURSOR ROWTYPE', 'PL/SQL RECORD'),
                          122, 'COLLECTION',
                          'UNKNOWN TYPECODE: ' || t.typecode),
       t.attributes, 
       decode(bitand(t.properties, 67108864), 67108864, 'YES', 0, 'NO')
from sys.user$ u, sys.type$ t, sys."_CURRENT_EDITION_OBJ" o
where t.package_obj# IS NOT NULL                          -- only package types
  and o.obj# = t.package_obj#
  and o.owner# = u.user#
  and o.type# <> 10 -- must not be invalid
/
comment on table DBA_PLSQL_TYPES is
'Description of all types in the database'
/
comment on column DBA_PLSQL_TYPES.OWNER is
'Owner of the type'
/
comment on column DBA_PLSQL_TYPES.TYPE_NAME is
'Name of the type'
/
comment on column DBA_PLSQL_TYPES.TYPE_OID is
'Object identifier (OID) of the type'
/
comment on column DBA_PLSQL_TYPES.TYPECODE is
'Typecode of the type'
/
comment on column DBA_PLSQL_TYPES.ATTRIBUTES is
'Number of attributes in the type'
/
comment on column DBA_PLSQL_TYPES.PACKAGE_NAME is
'Name of the package containing the type'
/
comment on column DBA_PLSQL_TYPES.CONTAINS_PLSQL is
'Does the type contain plsql specific data types?'
/
create or replace public synonym DBA_PLSQL_TYPES for DBA_PLSQL_TYPES
/
grant select on DBA_PLSQL_TYPES to select_catalog_role
/

execute SYS.CDBView.create_cdbview(false,'SYS','DBA_PLSQL_TYPES',-
'CDB_PLSQL_TYPES');
create or replace public synonym CDB_PLSQL_TYPES for sys.CDB_PLSQL_TYPES;
grant select on CDB_PLSQL_TYPES to select_catalog_role;

remark
remark  FAMILY "PLSQL_COLL_TYPES"
remark
remark  Views for showing information about named collection types
remark  (also categorized under named primitive types):
remark  USER_PLSQL_COLL_TYPES, ALL_PLSQL_COLL_TYPES, and DBA_PLSQL_COLL_TYPES
remark
create or replace view USER_PLSQL_COLL_TYPES
    (TYPE_NAME, PACKAGE_NAME, COLL_TYPE, UPPER_BOUND,
     ELEM_TYPE_OWNER, ELEM_TYPE_NAME, ELEM_TYPE_PACKAGE,
     LENGTH, PRECISION, SCALE, CHARACTER_SET_NAME, ELEM_STORAGE, 
     NULLS_STORED, CHAR_USED, INDEX_BY, ELEM_TYPE_MOD)
as
--
-- Package collection types with "obj$" element type
--
select c.coll_name, 
       o.name,
       decode(bitand(c.properties, 2097152), 2097152, 'PL/SQL INDEX TABLE',
              decode(bitand(c.properties, 4194304), 4194304, 
                     'PL/SQL INDEX TABLE', co.name)),
       c.upper_bound, 
       nvl2(c.synobj#, (select u.name from user$ u, "_CURRENT_EDITION_OBJ" o
            where o.owner#=u.user# and o.obj#=c.synobj#),
            decode(bitand(et.properties, 64), 64, null, eu.name)),
       nvl2(c.synobj#, (select o.name from "_CURRENT_EDITION_OBJ" o 
                        where o.obj#=c.synobj#),
            decode(et.typecode,
                   9, decode(c.charsetform, 2, 'NVARCHAR2', eo.name),
                   96, decode(c.charsetform, 2, 'NCHAR', eo.name),
                   112, decode(c.charsetform, 2, 'NCLOB', eo.name),
                   eo.name)),
       null,
       c.length, 
       c.precision, 
       c.scale,
       decode(c.charsetform, 1, 'CHAR_CS',
                             2, 'NCHAR_CS',
                             3, NLS_CHARSET_NAME(c.charsetid),
                             4, 'ARG:'||c.charsetid),
       decode(bitand(c.properties, 131072), 131072, 'FIXED',
              decode(bitand(c.properties, 262144), 262144, 'VARYING')),
       decode(bitand(c.properties, 65536), 65536, 'NO', 'YES'), 
       decode(bitand(c.properties, 4096), 4096, 'C', 'B'),
       decode(bitand(c.properties, 2097152), 2097152, 'BINARY_INTEGER', 
              decode(bitand(c.properties, 4194304), 4194304, 'VARCHAR2')),
       decode(bitand(c.properties, 32768), 32768, 'REF',
              decode(bitand(c.properties, 16384), 16384, 'POINTER'))
from sys."_CURRENT_EDITION_OBJ" o, sys.collection$ c, 
     sys."_CURRENT_EDITION_OBJ" co,
     sys."_CURRENT_EDITION_OBJ" eo, sys.user$ eu, sys.type$ et
where o.owner# = userenv('SCHEMAID')
  and c.package_obj# IS NOT NULL                          -- only package types
  and o.obj# = c.package_obj#
  and o.subname IS NULL -- only the most recent version 
  and o.type# <> 10 -- must not be invalid
  and c.coll_toid = co.oid$
  and c.elem_toid = eo.oid$
  and eo.owner# = eu.user#
  and c.elem_toid = et.tvoid
UNION
--
-- Package collection types with package level element types
--
select c.coll_name, 
       o.name,
       decode(bitand(c.properties, 2097152), 2097152, 'PL/SQL INDEX TABLE', 
              decode(bitand(c.properties, 4194304), 4194304, 
                     'PL/SQL INDEX TABLE', co.name)),
       c.upper_bound, 
       nvl2(c.synobj#, (select u.name from user$ u, "_CURRENT_EDITION_OBJ" o
            where o.owner#=u.user# and o.obj#=c.synobj#),
            decode(bitand(et.properties, 64), 64, null, eu.name)),
       et.typ_name ||  decode(bitand(et.properties,134217728),134217728,
                                     '%ROWTYPE', null), 
       nvl2(c.synobj#, (select o.name 
                        from "_CURRENT_EDITION_OBJ" o 
                        where o.obj#=c.synobj#),
            decode(et.typecode,
                   9, decode(c.charsetform, 2, 'NVARCHAR2', eo.name),
                   96, decode(c.charsetform, 2, 'NCHAR', eo.name),
                   112, decode(c.charsetform, 2, 'NCLOB', eo.name),
                   eo.name)), 
       c.length, 
       c.precision, 
       c.scale,
       decode(c.charsetform, 1, 'CHAR_CS',
                             2, 'NCHAR_CS',
                             3, NLS_CHARSET_NAME(c.charsetid),
                             4, 'ARG:'||c.charsetid),
       decode(bitand(c.properties, 131072), 131072, 'FIXED',
              decode(bitand(c.properties, 262144), 262144, 'VARYING')),
       decode(bitand(c.properties, 65536), 65536, 'NO', 'YES'), 
       decode(bitand(c.properties, 4096), 4096, 'C', 'B'),
       decode(bitand(c.properties, 2097152), 2097152, 'BINARY_INTEGER', 
              decode(bitand(c.properties, 4194304), 4194304, 'VARCHAR2')),
       null
from sys."_CURRENT_EDITION_OBJ" o, sys.collection$ c, 
     sys."_CURRENT_EDITION_OBJ" co,
     sys."_CURRENT_EDITION_OBJ" eo, sys.user$ eu, sys.type$ et
where o.owner# = userenv('SCHEMAID')
  and c.package_obj# IS NOT NULL                          -- only package types
  and o.obj# = c.package_obj#
  and o.type# <> 10 -- must not be invalid
  and c.coll_toid = co.oid$
  and et.package_obj# IS NOT NULL
  and et.package_obj# = eo.obj#
  and eo.owner# = eu.user#
  and c.elem_toid = et.toid
UNION
--
-- Package collection types with rowtype elements
--
select c.coll_name, 
       o.name,
       decode(bitand(c.properties, 2097152), 2097152, 'PL/SQL INDEX TABLE',
              decode(bitand(c.properties, 4194304), 4194304, 
                     'PL/SQL INDEX TABLE', co.name)),
       c.upper_bound, 
       nvl2(c.synobj#, (select u.name                          /* Type Owner */
                        from user$ u, "_CURRENT_EDITION_OBJ" o
                        where o.owner#=u.user# and o.obj#=c.synobj#),
            eu.name),                                          
       nvl2(c.synobj#, (select o.name                           /* Type Name */
                        from "_CURRENT_EDITION_OBJ" o 
                        where o.obj#=c.synobj#),
            eo.name) || '%ROWTYPE',
       null,                                                 /* Package Name */
       null, null, null, null,
       decode(bitand(c.properties, 131072), 131072, 'FIXED',
              decode(bitand(c.properties, 262144), 262144, 'VARYING')),
       decode(bitand(c.properties, 65536), 65536, 'NO', 'YES'), 
       decode(bitand(c.properties, 4096), 4096, 'C', 'B'),
       decode(bitand(c.properties, 2097152), 2097152, 'BINARY_INTEGER', 
              decode(bitand(c.properties, 4194304), 4194304, 'VARCHAR2')),
       decode(bitand(c.properties, 32768), 32768, 'REF',
              decode(bitand(c.properties, 16384), 16384, 'POINTER'))
from sys."_CURRENT_EDITION_OBJ" o, sys.collection$ c, 
     sys."_CURRENT_EDITION_OBJ" co,
     sys."_CURRENT_EDITION_OBJ" eo, sys.user$ eu, sys.oid$ id
where o.owner# = userenv('SCHEMAID')
  and c.package_obj# IS NOT NULL                          -- only package types
  and o.obj# = c.package_obj#
  and o.subname IS NULL -- only the most recent version 
  and o.type# <> 10 -- must not be invalid
  and c.coll_toid = co.oid$
  and c.elem_toid = id.oid$
  and id.obj# = eo.obj#
  and eo.type# in (2,4)                     -- table or view collection element
  and eo.owner# = eu.user#;
/
comment on table USER_PLSQL_COLL_TYPES is
'Description of the user''s own named plsql collection types'
/
comment on column USER_PLSQL_COLL_TYPES.TYPE_NAME is
'Name of the type'
/
comment on column USER_PLSQL_COLL_TYPES.PACKAGE_NAME is
'Name of the package containing the collection'
/
comment on column USER_PLSQL_COLL_TYPES.COLL_TYPE is
'Collection type'
/
comment on column USER_PLSQL_COLL_TYPES.UPPER_BOUND is
'The upper bound of a varray or length constraint of an index table type'
/
comment on column USER_PLSQL_COLL_TYPES.ELEM_TYPE_OWNER is
'Owner of the type of the element'
/
comment on column USER_PLSQL_COLL_TYPES.ELEM_TYPE_NAME is
'Name of the type of the element'
/
comment on column USER_PLSQL_COLL_TYPES.ELEM_TYPE_PACKAGE is
'Name of the package containing the element'
/
comment on column USER_PLSQL_COLL_TYPES.LENGTH is
'Length of the CHAR element or maximum length of the VARCHAR
or VARCHAR2 element'
/
comment on column USER_PLSQL_COLL_TYPES.PRECISION is
'Decimal precision of the NUMBER or DECIMAL element or
binary precision of the FLOAT element'
/
comment on column USER_PLSQL_COLL_TYPES.SCALE is
'Scale of the NUMBER or DECIMAL element'
/
comment on column USER_PLSQL_COLL_TYPES.CHARACTER_SET_NAME is
'Character set name of the element'
/
comment on column USER_PLSQL_COLL_TYPES.ELEM_STORAGE is
'Storage optimization specification for VARRAY of numeric elements'
/
comment on column USER_PLSQL_COLL_TYPES.NULLS_STORED is
'Is null information stored with each VARRAY element?'
/
comment on column USER_PLSQL_COLL_TYPES.CHAR_USED is
'C if the width was specified in characters, B if in bytes'
/
comment on column USER_PLSQL_COLL_TYPES.INDEX_BY is
'Index by binary_integer or varchar2'
/
create or replace public synonym USER_PLSQL_COLL_TYPES for 
USER_PLSQL_COLL_TYPES
/
grant read on USER_PLSQL_COLL_TYPES to PUBLIC with grant option
/
create or replace view ALL_PLSQL_COLL_TYPES
    (OWNER, TYPE_NAME, PACKAGE_NAME, COLL_TYPE, UPPER_BOUND,
     ELEM_TYPE_OWNER, ELEM_TYPE_NAME, ELEM_TYPE_PACKAGE,
     LENGTH, PRECISION, SCALE, CHARACTER_SET_NAME, ELEM_STORAGE, 
     NULLS_STORED, CHAR_USED, INDEX_BY, ELEM_TYPE_MOD)
as
--
-- Package collection types with "obj$" element type
--
select u.name, 
       c.coll_name, 
       o.name,
       decode(bitand(c.properties, 2097152), 2097152, 'PL/SQL INDEX TABLE', 
              decode(bitand(c.properties, 4194304), 4194304, 
                     'PL/SQL INDEX TABLE', co.name)),
       c.upper_bound, 
       nvl2(c.synobj#, (select u.name from user$ u, "_CURRENT_EDITION_OBJ" o
            where o.owner#=u.user# and o.obj#=c.synobj#),
            decode(bitand(et.properties, 64), 64, null, eu.name)),
       nvl2(c.synobj#, (select o.name from "_CURRENT_EDITION_OBJ" o 
                        where o.obj#=c.synobj#),
            decode(et.typecode,
                   9, decode(c.charsetform, 2, 'NVARCHAR2', eo.name),
                   96, decode(c.charsetform, 2, 'NCHAR', eo.name),
                   112, decode(c.charsetform, 2, 'NCLOB', eo.name),
                   eo.name)), 
       null,
       c.length, 
       c.precision, 
       c.scale,
       decode(c.charsetform, 1, 'CHAR_CS',
                             2, 'NCHAR_CS',
                             3, NLS_CHARSET_NAME(c.charsetid),
                             4, 'ARG:'||c.charsetid),
       decode(bitand(c.properties, 131072), 131072, 'FIXED',
              decode(bitand(c.properties, 262144), 262144, 'VARYING')),
       decode(bitand(c.properties, 65536), 65536, 'NO', 'YES'), 
       decode(bitand(c.properties, 4096), 4096, 'C', 'B'),
       decode(bitand(c.properties, 2097152), 2097152, 'BINARY_INTEGER', 
              decode(bitand(c.properties, 4194304), 4194304, 'VARCHAR2')),
       decode(bitand(c.properties, 32768), 32768, 'REF',
              decode(bitand(c.properties, 16384), 16384, 'POINTER'))
from sys.user$ u, sys."_CURRENT_EDITION_OBJ" o, sys.collection$ c, 
     sys."_CURRENT_EDITION_OBJ" co, sys."_CURRENT_EDITION_OBJ" eo, 
     sys.user$ eu, sys.type$ et
where c.package_obj# IS NOT NULL                          -- only package types
  and o.obj# = c.package_obj#
  and o.owner# = u.user#
  and o.subname IS NULL -- only the most recent version 
  and o.type# <> 10 -- must not be invalid
  and c.coll_toid = co.oid$
  and c.elem_toid = eo.oid$
  and eo.owner# = eu.user#
  and c.elem_toid = et.tvoid
  and (o.owner# = userenv('SCHEMAID')
       or
       o.obj# in (select oa.obj#
                  from sys.objauth$ oa
                  where grantee# in (select kzsrorol
                                     from x$kzsro))
       or /* user has system privileges */
       exists (select null from v$enabledprivs
               where priv_number in (-184 /* EXECUTE ANY TYPE */,
                                     -181 /* CREATE ANY TYPE */)))
UNION
--
-- Package collection types with package level element types
--
select u.name, 
       c.coll_name, 
       o.name,
       decode(bitand(c.properties, 2097152), 2097152, 'PL/SQL INDEX TABLE', 
              decode(bitand(c.properties, 4194304), 4194304, 
                     'PL/SQL INDEX TABLE', co.name)),
       c.upper_bound, 
       nvl2(c.synobj#, (select u.name from user$ u, "_CURRENT_EDITION_OBJ" o
            where o.owner#=u.user# and o.obj#=c.synobj#), eu.name),
       et.typ_name || decode(bitand(et.properties,134217728),134217728,
                                    '%ROWTYPE', null),
       nvl2(c.synobj#, (select o.name from "_CURRENT_EDITION_OBJ" o 
                        where o.obj#=c.synobj#), eo.name),
       c.length, 
       c.precision, 
       c.scale,
       decode(c.charsetform, 1, 'CHAR_CS',
                             2, 'NCHAR_CS',
                             3, NLS_CHARSET_NAME(c.charsetid),
                             4, 'ARG:'||c.charsetid),
       decode(bitand(c.properties, 131072), 131072, 'FIXED',
              decode(bitand(c.properties, 262144), 262144, 'VARYING')),
       decode(bitand(c.properties, 65536), 65536, 'NO', 'YES'), 
       decode(bitand(c.properties, 4096), 4096, 'C', 'B'), 
       decode(bitand(c.properties, 2097152), 2097152, 'BINARY_INTEGER', 
              decode(bitand(c.properties, 4194304), 4194304, 'VARCHAR2')),
       null
from sys.user$ u, sys."_CURRENT_EDITION_OBJ" o, sys.collection$ c, 
     sys."_CURRENT_EDITION_OBJ" co,
     sys."_CURRENT_EDITION_OBJ" eo, sys.user$ eu, sys.type$ et
where c.package_obj# IS NOT NULL                          -- only package types
  and o.obj# = c.package_obj#
  and o.owner# = u.user#
  and o.type# <> 10 -- must not be invalid
  and c.coll_toid = co.oid$
  and et.package_obj# IS NOT NULL
  and et.package_obj# = eo.obj#
  and eo.owner# = eu.user#
  and c.elem_toid = et.toid
  and (o.owner# = userenv('SCHEMAID')
       or
       o.obj# in (select oa.obj#
                  from sys.objauth$ oa
                  where grantee# in (select kzsrorol
                                     from x$kzsro))
       or /* user has system privileges */
       exists (select null from v$enabledprivs
               where priv_number in (-144 /* EXECUTE ANY PROCEDURE */,
                                     -141 /* CREATE ANY PROCEDURE */
                                     -241 /* DEBUG ANY PROCEDURE */)))
UNION
--
-- Package collection types with table/view rowtypes
--
select u.name, 
       c.coll_name, 
       o.name,
       decode(bitand(c.properties, 2097152), 2097152, 'PL/SQL INDEX TABLE', 
              decode(bitand(c.properties, 4194304), 4194304, 
                     'PL/SQL INDEX TABLE', co.name)),
       c.upper_bound, 
       nvl2(c.synobj#, (select u.name 
                        from user$ u, "_CURRENT_EDITION_OBJ" o
                        where o.owner#=u.user# and o.obj#=c.synobj#),
            eu.name),
       nvl2(c.synobj#, (select o.name 
                        from "_CURRENT_EDITION_OBJ" o 
                        where o.obj#=c.synobj#),
             eo.name) || '%ROWTYPE', 
       null, null, null, null, null,
       decode(bitand(c.properties, 131072), 131072, 'FIXED',
              decode(bitand(c.properties, 262144), 262144, 'VARYING')),
       decode(bitand(c.properties, 65536), 65536, 'NO', 'YES'), 
       decode(bitand(c.properties, 4096), 4096, 'C', 'B'),
       decode(bitand(c.properties, 2097152), 2097152, 'BINARY_INTEGER', 
              decode(bitand(c.properties, 4194304), 4194304, 'VARCHAR2')),
       decode(bitand(c.properties, 32768), 32768, 'REF',
              decode(bitand(c.properties, 16384), 16384, 'POINTER'))
from sys.user$ u, sys."_CURRENT_EDITION_OBJ" o, sys.collection$ c, 
     sys."_CURRENT_EDITION_OBJ" co, sys."_CURRENT_EDITION_OBJ" eo, 
     sys.user$ eu, sys.oid$ id
where c.package_obj# IS NOT NULL                          -- only package types
  and o.obj# = c.package_obj#
  and o.owner# = u.user#
  and o.subname IS NULL -- only the most recent version 
  and o.type# <> 10 -- must not be invalid
  and c.coll_toid = co.oid$
  and c.elem_toid = id.oid$
  and id.obj# = eo.obj#
  and eo.type# in (2,4)                     -- table or view collection element
  and eo.owner# = eu.user#
  and (o.owner# = userenv('SCHEMAID')
       or
       o.obj# in (select oa.obj#
                  from sys.objauth$ oa
                  where grantee# in (select kzsrorol
                                     from x$kzsro))
       or /* user has system privileges */
       exists (select null from v$enabledprivs
               where priv_number in (-184 /* EXECUTE ANY TYPE */,
                                     -181 /* CREATE ANY TYPE */)))

/
comment on table ALL_PLSQL_COLL_TYPES is
'Description of named plsql collection types accessible to the user'
/
comment on column ALL_PLSQL_COLL_TYPES.OWNER is
'Owner of the type'
/
comment on column ALL_PLSQL_COLL_TYPES.TYPE_NAME is
'Name of the type'
/
comment on column ALL_PLSQL_COLL_TYPES.PACKAGE_NAME is
'Name of the package containing the collection'
/
comment on column ALL_PLSQL_COLL_TYPES.COLL_TYPE is
'Collection type'
/
comment on column ALL_PLSQL_COLL_TYPES.UPPER_BOUND is
'The upper bound of a varray or length constraint of an index by varchar2 
table'
/
comment on column ALL_PLSQL_COLL_TYPES.ELEM_TYPE_OWNER is
'Owner of the type of the element'
/
comment on column ALL_PLSQL_COLL_TYPES.ELEM_TYPE_NAME is
'Name of the type of the element'
/
comment on column ALL_PLSQL_COLL_TYPES.ELEM_TYPE_PACKAGE is
'Name of the package containing the element'
/
comment on column ALL_PLSQL_COLL_TYPES.LENGTH is
'Length of the CHAR element or maximum length of the VARCHAR
or VARCHAR2 element'
/
comment on column ALL_PLSQL_COLL_TYPES.PRECISION is
'Decimal precision of the NUMBER or DECIMAL element or
binary precision of the FLOAT element'
/
comment on column ALL_PLSQL_COLL_TYPES.SCALE is
'Scale of the NUMBER or DECIMAL element'
/
comment on column ALL_PLSQL_COLL_TYPES.CHARACTER_SET_NAME is
'Character set name of the element'
/
comment on column ALL_PLSQL_COLL_TYPES.ELEM_STORAGE is
'Storage optimization specification for VARRAY of numeric elements'
/
comment on column ALL_PLSQL_COLL_TYPES.NULLS_STORED is
'Is null information stored with each VARRAY element?'
/
comment on column ALL_PLSQL_COLL_TYPES.CHAR_USED is
'C if the width was specified in characters, B if in bytes'
/
comment on column ALL_PLSQL_COLL_TYPES.INDEX_BY is
'Index by binary_integer or varchar2'
/
create or replace public synonym ALL_PLSQL_COLL_TYPES for ALL_PLSQL_COLL_TYPES
/
grant read on ALL_PLSQL_COLL_TYPES to PUBLIC with grant option
/
create or replace view DBA_PLSQL_COLL_TYPES
    (OWNER, TYPE_NAME, PACKAGE_NAME, COLL_TYPE, UPPER_BOUND,
     ELEM_TYPE_OWNER, ELEM_TYPE_NAME, ELEM_TYPE_PACKAGE,
     LENGTH, PRECISION, SCALE, CHARACTER_SET_NAME,ELEM_STORAGE, 
     NULLS_STORED, CHAR_USED, INDEX_BY, ELEM_TYPE_MOD)
as
--
-- Package collection types with "obj$" element type
--
select u.name, 
       c.coll_name, 
       o.name,
       decode(bitand(c.properties, 2097152), 2097152, 'PL/SQL INDEX TABLE', 
              decode(bitand(c.properties, 4194304), 4194304, 
                     'PL/SQL INDEX TABLE', co.name)),
       c.upper_bound, 
       nvl2(c.synobj#, (select u.name from user$ u, "_CURRENT_EDITION_OBJ" o
            where o.owner#=u.user# and o.obj#=c.synobj#),
            decode(bitand(et.properties, 64), 64, null, eu.name)),
       nvl2(c.synobj#, (select o.name from "_CURRENT_EDITION_OBJ" o 
                        where o.obj#=c.synobj#),
            decode(et.typecode,
                   9, decode(c.charsetform, 2, 'NVARCHAR2', eo.name),
                   96, decode(c.charsetform, 2, 'NCHAR', eo.name),
                   112, decode(c.charsetform, 2, 'NCLOB', eo.name),
                   eo.name)), 
       null,
       c.length, 
       c.precision, 
       c.scale,
       decode(c.charsetform, 1, 'CHAR_CS',
                             2, 'NCHAR_CS',
                             3, NLS_CHARSET_NAME(c.charsetid),
                             4, 'ARG:'||c.charsetid),
       decode(bitand(c.properties, 131072), 131072, 'FIXED',
              decode(bitand(c.properties, 262144), 262144, 'VARYING')),
       decode(bitand(c.properties, 65536), 65536, 'NO', 'YES'), 
       decode(bitand(c.properties, 4096), 4096, 'C', 'B'),
       decode(bitand(c.properties, 2097152), 2097152, 'BINARY_INTEGER', 
              decode(bitand(c.properties, 4194304), 4194304, 'VARCHAR2')),
       decode(bitand(c.properties, 32768), 32768, 'REF',
              decode(bitand(c.properties, 16384), 16384, 'POINTER'))
from sys.user$ u, sys."_CURRENT_EDITION_OBJ" o, sys.collection$ c, 
     sys."_CURRENT_EDITION_OBJ" co,
     sys."_CURRENT_EDITION_OBJ" eo, sys.user$ eu, sys.type$ et
where o.owner# = u.user#
  and c.package_obj# IS NOT NULL                          -- only package types
  and o.obj# = c.package_obj#
  and o.subname IS NULL -- only the most recent version 
  and o.type# <> 10 -- must not be invalid
  and c.coll_toid = co.oid$
  and c.elem_toid = eo.oid$
  and eo.owner# = eu.user#
  and c.elem_toid = et.tvoid
UNION
--
-- Package collection types with package level element types
--
select u.name, 
       c.coll_name, 
       o.name,
       decode(bitand(c.properties, 2097152), 2097152, 'PL/SQL INDEX TABLE', 
              decode(bitand(c.properties, 4194304), 4194304, 
                     'PL/SQL INDEX TABLE', co.name)),
       c.upper_bound, 
       nvl2(c.synobj#, (select u.name from user$ u, "_CURRENT_EDITION_OBJ" o
            where o.owner#=u.user# and o.obj#=c.synobj#), eu.name),
       et.typ_name || decode(bitand(et.properties,134217728),134217728,
                                    '%ROWTYPE', null),
       nvl2(c.synobj#, (select o.name from "_CURRENT_EDITION_OBJ" o 
                        where o.obj#=c.synobj#), eo.name),
       c.length, 
       c.precision, 
       c.scale,
       decode(c.charsetform, 1, 'CHAR_CS',
                             2, 'NCHAR_CS',
                             3, NLS_CHARSET_NAME(c.charsetid),
                             4, 'ARG:'||c.charsetid),
       decode(bitand(c.properties, 131072), 131072, 'FIXED',
              decode(bitand(c.properties, 262144), 262144, 'VARYING')),
       decode(bitand(c.properties, 65536), 65536, 'NO', 'YES'), 
       decode(bitand(c.properties, 4096), 4096, 'C', 'B'),
       decode(bitand(c.properties, 2097152), 2097152, 'BINARY_INTEGER', 
              decode(bitand(c.properties, 4194304), 4194304, 'VARCHAR2')),
       null
from sys.user$ u, sys."_CURRENT_EDITION_OBJ" o, sys.collection$ c, 
     sys."_CURRENT_EDITION_OBJ" co,
     sys."_CURRENT_EDITION_OBJ" eo, sys.user$ eu, sys.type$ et
where o.owner# = u.user#
  and c.package_obj# IS NOT NULL                          -- only package types
  and o.obj# = c.package_obj#
  and o.type# <> 10 -- must not be invalid
  and c.coll_toid = co.oid$
  and et.package_obj# IS NOT NULL
  and et.package_obj# = eo.obj#
  and eo.owner# = eu.user#
  and c.elem_toid = et.toid
--
-- Package collection types with %rowtypes
--
UNION
select u.name, 
       c.coll_name, 
       o.name,
       decode(bitand(c.properties, 2097152), 2097152, 'PL/SQL INDEX TABLE', 
              decode(bitand(c.properties, 4194304), 4194304, 
                     'PL/SQL INDEX TABLE', co.name)),
       c.upper_bound, 
       nvl2(c.synobj#, (select u.name 
                        from user$ u, "_CURRENT_EDITION_OBJ" o
                        where o.owner#=u.user# and o.obj#=c.synobj#),
            eu.name),
       nvl2(c.synobj#, (select o.name 
                        from "_CURRENT_EDITION_OBJ" o 
                        where o.obj#=c.synobj#),
            eo.name) || '%ROWTYPE',
       null, null, null, null, null,
       decode(bitand(c.properties, 131072), 131072, 'FIXED',
              decode(bitand(c.properties, 262144), 262144, 'VARYING')),
       decode(bitand(c.properties, 65536), 65536, 'NO', 'YES'), 
       decode(bitand(c.properties, 4096), 4096, 'C', 'B'),
       decode(bitand(c.properties, 2097152), 2097152, 'BINARY_INTEGER', 
              decode(bitand(c.properties, 4194304), 4194304, 'VARCHAR2')),
       decode(bitand(c.properties, 32768), 32768, 'REF',
              decode(bitand(c.properties, 16384), 16384, 'POINTER'))
from sys.user$ u, sys."_CURRENT_EDITION_OBJ" o, sys.collection$ c, 
     sys."_CURRENT_EDITION_OBJ" co,
     sys."_CURRENT_EDITION_OBJ" eo, sys.user$ eu, sys.oid$ id
where o.owner# = u.user#
  and c.package_obj# IS NOT NULL                          -- only package types
  and o.obj# = c.package_obj#
  and o.subname IS NULL -- only the most recent version 
  and o.type# <> 10 -- must not be invalid
  and c.coll_toid = co.oid$
  and c.elem_toid = id.oid$
  and id.obj# = eo.obj#
  and eo.type# in (2,4)                     -- table or view collection element
  and eo.owner# = eu.user#;
/
comment on table DBA_PLSQL_COLL_TYPES is
'Description of all named collection types in the database'
/
comment on column DBA_PLSQL_COLL_TYPES.OWNER is
'Owner of the type'
/
comment on column DBA_PLSQL_COLL_TYPES.TYPE_NAME is
'Name of the type'
/
comment on column DBA_PLSQL_COLL_TYPES.PACKAGE_NAME is
'Name of the package containing the collection'
/
comment on column DBA_PLSQL_COLL_TYPES.COLL_TYPE is
'Collection type'
/
comment on column ALL_PLSQL_COLL_TYPES.UPPER_BOUND is
'The upper bound of a varray or length constraint of an index by varchar2 
table'
/
comment on column DBA_PLSQL_COLL_TYPES.ELEM_TYPE_MOD is
'Type modifier of the element'
/
comment on column DBA_PLSQL_COLL_TYPES.ELEM_TYPE_OWNER is
'Owner of the type of the element'
/
comment on column DBA_PLSQL_COLL_TYPES.ELEM_TYPE_NAME is
'Name of the type of the element'
/
comment on column DBA_PLSQL_COLL_TYPES.ELEM_TYPE_PACKAGE is
'Name of the package containing the element'
/
comment on column DBA_PLSQL_COLL_TYPES.LENGTH is
'Length of the CHAR element or maximum length of the VARCHAR
or VARCHAR2 element'
/
comment on column DBA_PLSQL_COLL_TYPES.PRECISION is
'Decimal precision of the NUMBER or DECIMAL element or
binary precision of the FLOAT element'
/
comment on column DBA_PLSQL_COLL_TYPES.SCALE is
'Scale of the NUMBER or DECIMAL element'
/
comment on column DBA_PLSQL_COLL_TYPES.CHARACTER_SET_NAME is
'Character set name of the element'
/
comment on column DBA_PLSQL_COLL_TYPES.ELEM_STORAGE is
'Storage optimization specification for VARRAY of numeric elements'
/
comment on column DBA_PLSQL_COLL_TYPES.NULLS_STORED is
'Is null information stored with each VARRAY element?'
/
comment on column DBA_PLSQL_COLL_TYPES.CHAR_USED is
'C if the width was specified in characters, B if in bytes'
/
comment on column DBA_PLSQL_COLL_TYPES.INDEX_BY is
'Index by binary_integer or varchar2'
/

create or replace public synonym DBA_PLSQL_COLL_TYPES for DBA_PLSQL_COLL_TYPES
/
grant select on DBA_PLSQL_COLL_TYPES to select_catalog_role
/

execute SYS.CDBView.create_cdbview(false,'SYS','DBA_PLSQL_COLL_TYPES',-
'CDB_PLSQL_COLL_TYPES');
create or replace public synonym CDB_PLSQL_COLL_TYPES for 
sys.CDB_PLSQL_COLL_TYPES;
grant select on CDB_PLSQL_COLL_TYPES to select_catalog_role;

remark
remark  FAMILY "PLSQL_TYPE_ATTRS"
remark
remark  Views for showing attribute information of object types:
remark  USER_PLSQL_TYPE_ATTRS, ALL_PLSQL_TYPE_ATTRS, and DBA_PLSQL_TYPE_ATTRS
remark
create or replace view USER_PLSQL_TYPE_ATTRS
    (TYPE_NAME, PACKAGE_NAME, ATTR_NAME,
     ATTR_TYPE_MOD, ATTR_TYPE_OWNER, ATTR_TYPE_NAME, ATTR_TYPE_PACKAGE,
     LENGTH, PRECISION, SCALE, CHARACTER_SET_NAME, ATTR_NO, CHAR_USED)
as
--
-- obj$ type attributes (User and predefined) in package types. 
--
select t.typ_name || decode(bitand(t.properties,134217728),134217728,
                             '%ROWTYPE', null), 
       o.name,
       a.name,
       decode(bitand(a.properties, 32768), 32768, 'REF',
              decode(bitand(a.properties, 16384), 16384, 'POINTER')),
       nvl2(a.synobj#, (select u.name from user$ u, "_CURRENT_EDITION_OBJ" o 
            where o.owner#=u.user# and o.obj#=a.synobj#),
            decode(bitand(at.properties, 64), 64, null, au.name)),
       nvl2(a.synobj#, (select o.name from "_CURRENT_EDITION_OBJ" o 
                        where o.obj#=a.synobj#),
            decode(at.typecode,
                   9, decode(a.charsetform, 2, 'NVARCHAR2', ao.name),
                   96, decode(a.charsetform, 2, 'NCHAR', ao.name),
                   112, decode(a.charsetform, 2, 'NCLOB', ao.name),
                   ao.name)),
       null,
       a.length, 
       a.precision#, 
       a.scale,
       decode(a.charsetform, 1, 'CHAR_CS',
                             2, 'NCHAR_CS',
                             3, NLS_CHARSET_NAME(a.charsetid),
                             4, 'ARG:'||a.charsetid),
       a.attribute#,
       decode(bitand(a.properties, 4096), 4096, 'C', 'B')
from sys."_CURRENT_EDITION_OBJ" o, sys.type$ t, sys.attribute$ a, 
     sys."_CURRENT_EDITION_OBJ" ao, sys.user$ au, sys.type$ at
where o.owner# = userenv('SCHEMAID')
  and t.package_obj# IS NOT NULL                          -- only package types
  and o.obj# = t.package_obj#
  and o.subname IS NULL -- only the latest version
  and o.type# <> 10 -- must not be invalid
  and bitand(t.properties, 2048) = 0 -- not system-generated
  and t.toid = a.toid
  and t.version# = a.version#
  and a.attr_toid = ao.oid$
  and ao.owner# = au.user#
  and a.attr_toid = at.tvoid
UNION
--
-- Package type attributes
--
select t.typ_name, 
       o.name,
       a.name,
       null, 
       nvl2(a.synobj#, (select u.name from user$ u, "_CURRENT_EDITION_OBJ" o 
            where o.owner#=u.user# and o.obj#=a.synobj#), au.name),
       at.typ_name || decode(bitand(at.properties,134217728),134217728,
                             '%ROWTYPE', null), 
       nvl2(a.synobj#, (select o.name from "_CURRENT_EDITION_OBJ" o 
                        where o.obj#=a.synobj#), ao.name),
       a.length, 
       a.precision#, 
       a.scale,
       decode(a.charsetform, 1, 'CHAR_CS',
                             2, 'NCHAR_CS',
                             3, NLS_CHARSET_NAME(a.charsetid),
                             4, 'ARG:'||a.charsetid),
       a.attribute#,
       decode(bitand(a.properties, 4096), 4096, 'C', 'B')
from sys."_CURRENT_EDITION_OBJ" o, sys.type$ t, sys.attribute$ a, 
     sys."_CURRENT_EDITION_OBJ" ao, sys.user$ au, sys.type$ at
where o.owner# = userenv('SCHEMAID')
  and t.package_obj# IS NOT NULL                          -- only package types
  and o.obj# = t.package_obj#
  and o.subname IS NULL -- only the latest version
  and o.type# <> 10 -- must not be invalid
  and bitand(t.properties, 2048) = 0 -- not system-generated
  and t.toid = a.toid
  and t.version# = a.version#
  and at.package_obj# IS NOT NULL
  and at.package_obj# = ao.obj#
  and ao.owner# = au.user#
  and a.attr_toid = at.toid
UNION
--
-- %rowtype attributes in package types. 
--
select t.typ_name,
       o.name,
       a.name, null,
       nvl2(a.synobj#, (select u.name 
                        from user$ u, "_CURRENT_EDITION_OBJ" o 
                        where o.owner#=u.user# and o.obj#=a.synobj#),
            au.name),
       nvl2(a.synobj#, (select o.name 
                        from "_CURRENT_EDITION_OBJ" o 
                        where o.obj#=a.synobj#),
             ao.name) || '%ROWTYPE',
       null, null, null, null, null,
       a.attribute#,
       decode(bitand(a.properties, 4096), 4096, 'C', 'B')
from sys."_CURRENT_EDITION_OBJ" o, sys.type$ t, sys.attribute$ a, 
     sys."_CURRENT_EDITION_OBJ" ao, sys.user$ au, sys.oid$ id
where o.owner# = userenv('SCHEMAID')
  and t.package_obj# IS NOT NULL                          -- only package types
  and o.obj# = t.package_obj#
  and o.subname IS NULL -- only the latest version
  and o.type# <> 10 -- must not be invalid
  and bitand(t.properties, 2048) = 0 -- not system-generated
  and t.toid = a.toid
  and t.version# = a.version#
  and a.attr_toid = id.oid$
  and id.obj# = ao.obj#
  and ao.type# in (2,4)                     -- table or view collection element
  and ao.owner# = au.user#;
/
comment on table USER_PLSQL_TYPE_ATTRS is
'Description of attributes of the user''s own types'
/
comment on column USER_PLSQL_TYPE_ATTRS.TYPE_NAME is
'Name of the type'
/
comment on column USER_PLSQL_TYPE_ATTRS.PACKAGE_NAME is
'Name of the package containing the type'
/
comment on column USER_PLSQL_TYPE_ATTRS.ATTR_NAME is
'Name of the attribute'
/
comment on column USER_PLSQL_TYPE_ATTRS.ATTR_TYPE_MOD is
'Type modifier of the attribute'
/
comment on column USER_PLSQL_TYPE_ATTRS.ATTR_TYPE_OWNER is
'Owner of the type of the attribute'
/
comment on column USER_PLSQL_TYPE_ATTRS.ATTR_TYPE_NAME is
'Name of the type of the attribute'
/
comment on column USER_PLSQL_TYPE_ATTRS.ATTR_TYPE_PACKAGE is
'Name of the package containing the attribute type'
/
comment on column USER_PLSQL_TYPE_ATTRS.LENGTH is
'Length of the CHAR attribute or maximum length of the VARCHAR
or VARCHAR2 attribute'
/
comment on column USER_PLSQL_TYPE_ATTRS.PRECISION is
'Decimal precision of the NUMBER or DECIMAL attribute or
binary precision of the FLOAT attribute'
/
comment on column USER_PLSQL_TYPE_ATTRS.SCALE is
'Scale of the NUMBER or DECIMAL attribute'
/
comment on column USER_PLSQL_TYPE_ATTRS.CHARACTER_SET_NAME is
'Character set name of the attribute'
/
comment on column USER_PLSQL_TYPE_ATTRS.ATTR_NO is
'Syntactical order number or position of the attribute as specified in the
type specification or CREATE TYPE statement (not to be used as ID number)'
/
comment on column USER_PLSQL_TYPE_ATTRS.CHAR_USED is
'C if the width was specified in characters, B if in bytes'
/
create or replace public synonym USER_PLSQL_TYPE_ATTRS for 
USER_PLSQL_TYPE_ATTRS
/
grant read on USER_PLSQL_TYPE_ATTRS to PUBLIC with grant option
/
create or replace view ALL_PLSQL_TYPE_ATTRS
    (OWNER, TYPE_NAME, PACKAGE_NAME, ATTR_NAME,
     ATTR_TYPE_MOD, ATTR_TYPE_OWNER, ATTR_TYPE_NAME, ATTR_TYPE_PACKAGE,
     LENGTH, PRECISION, SCALE, CHARACTER_SET_NAME, 
     ATTR_NO, CHAR_USED)
as
--
-- obj$ type attributes (User and predefined) in package types.  
--
select u.name, 
       t.typ_name || decode(bitand(t.properties,134217728),134217728,
                             '%ROWTYPE', null), 
       o.name, a.name, 
       decode(bitand(a.properties, 32768), 32768, 'REF',
              decode(bitand(a.properties, 16384), 16384, 'POINTER')),
       nvl2(a.synobj#, (select u.name from user$ u, "_CURRENT_EDITION_OBJ" o
            where o.owner#=u.user# and o.obj#=a.synobj#),
            decode(bitand(at.properties, 64), 64, null, au.name)),
       nvl2(a.synobj#, (select o.name from "_CURRENT_EDITION_OBJ" o
                        where o.obj#=a.synobj#),
            decode(at.typecode,
                   9, decode(a.charsetform, 2, 'NVARCHAR2', ao.name),
                   96, decode(a.charsetform, 2, 'NCHAR', ao.name),
                   112, decode(a.charsetform, 2, 'NCLOB', ao.name),
                   ao.name)),
       null,
       a.length, a.precision#, a.scale,
       decode(a.charsetform, 1, 'CHAR_CS',
                             2, 'NCHAR_CS',
                             3, NLS_CHARSET_NAME(a.charsetid),
                             4, 'ARG:'||a.charsetid),
       a.attribute#,
       decode(bitand(a.properties, 4096), 4096, 'C', 'B')
from sys.user$ u, sys."_CURRENT_EDITION_OBJ" o, sys.type$ t, 
     sys.attribute$ a,
     sys."_CURRENT_EDITION_OBJ" ao, sys.user$ au, sys.type$ at
where bitand(t.properties, 64) != 64 -- u.name
  and o.owner# = u.user#
  and t.package_obj# IS NOT NULL                          -- only package types
  and o.obj# = t.package_obj#
  and o.subname IS NULL -- get the latest version only
  and o.type# <> 10 -- must not be invalid
  and bitand(t.properties, 2048) = 0 -- not system-generated
  and t.toid = a.toid
  and t.version# = a.version#
  and a.attr_toid = ao.oid$
  and ao.owner# = au.user#
  and a.attr_toid = at.toid
  and a.attr_version# = at.version#
  and (o.owner# = userenv('SCHEMAID')
       or
       o.obj# in (select oa.obj#
                  from sys.objauth$ oa
                  where grantee# in (select kzsrorol
                                     from x$kzsro))
       or /* user has system privileges */
       exists (select null from v$enabledprivs
               where priv_number in (-184 /* EXECUTE ANY TYPE */,
                                     -181 /* CREATE ANY TYPE */)))
UNION
--
-- Package type attributes in package types.
--
select u.name, t.typ_name, o.name, a.name, null, 
       nvl2(a.synobj#, (select u.name 
                        from user$ u, "_CURRENT_EDITION_OBJ" o 
                        where o.owner#=u.user# and o.obj#=a.synobj#), 
            au.name),
       at.typ_name || decode(bitand(at.properties,134217728),134217728,
                             '%ROWTYPE', null), 
       nvl2(a.synobj#, (select o.name 
                        from "_CURRENT_EDITION_OBJ" o 
                        where o.obj#=a.synobj#), 
            ao.name),
       a.length, a.precision#, a.scale,
       decode(a.charsetform, 1, 'CHAR_CS',
                             2, 'NCHAR_CS',
                             3, NLS_CHARSET_NAME(a.charsetid),
                             4, 'ARG:'||a.charsetid),
       a.attribute#, 
       decode(bitand(a.properties, 4096), 4096, 'C', 'B')
from sys.user$ u, sys."_CURRENT_EDITION_OBJ" o, sys.type$ t, 
     sys.attribute$ a,
     sys."_CURRENT_EDITION_OBJ" ao, sys.user$ au, sys.type$ at
where o.owner# = u.user#
  and t.package_obj# IS NOT NULL                          -- only package types
  and o.obj# = t.package_obj#
  and o.type# <> 10 -- must not be invalid
  and t.toid = a.toid
  and t.version# = a.version#
  and at.package_obj# IS NOT NULL
  and at.package_obj# = ao.obj#
  and ao.owner# = au.user#
  and a.attr_toid = at.toid
  and a.attr_version# = at.version#
  and (o.owner# = userenv('SCHEMAID')
       or
       o.obj# in (select oa.obj#
                  from sys.objauth$ oa
                  where grantee# in (select kzsrorol
                                     from x$kzsro))
       or /* user has system privileges */
       exists (select null from v$enabledprivs
               where priv_number in (-144 /* EXECUTE ANY PROCEDURE */,
                                     -141 /* CREATE ANY PROCEDURE */
                                     -241 /* DEBUG ANY PROCEDURE */)))
UNION
--
-- %rowtype attributes in package types.  
--
select u.name, 
       t.typ_name,
       o.name, a.name, null,
       nvl2(a.synobj#, (select u.name 
                        from user$ u, "_CURRENT_EDITION_OBJ" o
                        where o.owner#=u.user# and o.obj#=a.synobj#),
            au.name),
       nvl2(a.synobj#, (select o.name 
                        from "_CURRENT_EDITION_OBJ" o
                        where o.obj#=a.synobj#),
            ao.name) || '%ROWTYPE',
       null, null, null, null, null, 
       a.attribute#, null
from sys.user$ u, sys."_CURRENT_EDITION_OBJ" o, sys.type$ t, 
     sys.attribute$ a,
     sys."_CURRENT_EDITION_OBJ" ao, sys.user$ au, sys.oid$ id
where bitand(t.properties, 64) != 64 -- u.name
  and o.owner# = u.user#
  and t.package_obj# IS NOT NULL                          -- only package types
  and o.obj# = t.package_obj#
  and o.subname IS NULL -- get the latest version only
  and o.type# <> 10 -- must not be invalid
  and bitand(t.properties, 2048) = 0 -- not system-generated
  and t.toid = a.toid
  and t.version# = a.version#
  and a.attr_toid = id.oid$
  and id.obj# = ao.obj#
  and ao.type# in (2,4)                     -- table or view collection element
  and ao.owner# = au.user#
  and (o.owner# = userenv('SCHEMAID')
       or
       o.obj# in (select oa.obj#
                  from sys.objauth$ oa
                  where grantee# in (select kzsrorol
                                     from x$kzsro))
       or /* user has system privileges */
       exists (select null from v$enabledprivs
               where priv_number in (-184 /* EXECUTE ANY TYPE */,
                                     -181 /* CREATE ANY TYPE */)));
/
comment on table ALL_PLSQL_TYPE_ATTRS is
'Description of attributes of types accessible to the user'
/
comment on column ALL_PLSQL_TYPE_ATTRS.OWNER is
'Owner of the type'
/
comment on column ALL_PLSQL_TYPE_ATTRS.TYPE_NAME is
'Name of the type'
/
comment on column ALL_PLSQL_TYPE_ATTRS.PACKAGE_NAME is
'Name of the package containing the type'
/
comment on column ALL_PLSQL_TYPE_ATTRS.ATTR_NAME is
'Name of the attribute'
/
comment on column ALL_PLSQL_TYPE_ATTRS.ATTR_TYPE_MOD is
'Type modifier of the attribute'
/
comment on column ALL_PLSQL_TYPE_ATTRS.ATTR_TYPE_OWNER is
'Owner of the type of the attribute'
/
comment on column ALL_PLSQL_TYPE_ATTRS.ATTR_TYPE_NAME is
'Name of the type of the attribute'
/
comment on column ALL_PLSQL_TYPE_ATTRS.ATTR_TYPE_PACKAGE is
'Name of the package containing the attribute type'
/
comment on column ALL_PLSQL_TYPE_ATTRS.LENGTH is
'Length of the CHAR attribute or maximum length of the VARCHAR
or VARCHAR2 attribute'
/
comment on column ALL_PLSQL_TYPE_ATTRS.PRECISION is
'Decimal precision of the NUMBER or DECIMAL attribute or
binary precision of the FLOAT attribute'
/
comment on column ALL_PLSQL_TYPE_ATTRS.SCALE is
'Scale of the NUMBER or DECIMAL attribute'
/
comment on column ALL_PLSQL_TYPE_ATTRS.CHARACTER_SET_NAME is
'Character set name of the attribute'
/
comment on column ALL_PLSQL_TYPE_ATTRS.ATTR_NO is
'Syntactical order number or position of the attribute as specified in the
type specification or CREATE TYPE statement (not to be used as ID number)'
/
comment on column ALL_PLSQL_TYPE_ATTRS.CHAR_USED is
'C if the width was specified in characters, B if in bytes'
/
create or replace public synonym ALL_PLSQL_TYPE_ATTRS for ALL_PLSQL_TYPE_ATTRS
/
grant read on ALL_PLSQL_TYPE_ATTRS to PUBLIC with grant option
/

create or replace view DBA_PLSQL_TYPE_ATTRS
    (OWNER, TYPE_NAME, PACKAGE_NAME, ATTR_NAME,
     ATTR_TYPE_MOD, ATTR_TYPE_OWNER, ATTR_TYPE_NAME, ATTR_TYPE_PACKAGE,
     LENGTH, PRECISION, SCALE, CHARACTER_SET_NAME, ATTR_NO, CHAR_USED)
as
--
-- obj$ type attributes (User and predefined) in package types.  
--
select u.name, 
       t.typ_name || decode(bitand(t.properties,134217728),134217728,
                            '%ROWTYPE', null), 
       o.name, a.name, 
       decode(bitand(a.properties, 32768), 32768, 'REF',
              decode(bitand(a.properties, 16384), 16384, 'POINTER')),
       nvl2(a.synobj#, (select u.name from user$ u, "_CURRENT_EDITION_OBJ" o
            where o.owner#=u.user# and o.obj#=a.synobj#),
            decode(bitand(at.properties, 64), 64, null, au.name)),
       nvl2(a.synobj#, (select o.name from "_CURRENT_EDITION_OBJ" o
                        where o.obj#=a.synobj#),
            decode(at.typecode,
                   9, decode(a.charsetform, 2, 'NVARCHAR2', ao.name),
                   96, decode(a.charsetform, 2, 'NCHAR', ao.name),
                   112, decode(a.charsetform, 2, 'NCLOB', ao.name),
                   ao.name)),
       null,
       a.length, a.precision#, a.scale,
       decode(a.charsetform, 1, 'CHAR_CS',
                             2, 'NCHAR_CS',
                             3, NLS_CHARSET_NAME(a.charsetid),
                             4, 'ARG:'||a.charsetid),
       a.attribute#,
       decode(bitand(a.properties, 4096), 4096, 'C', 'B')
from sys.user$ u, sys."_CURRENT_EDITION_OBJ" o, sys.type$ t, 
     sys.attribute$ a,
     sys."_CURRENT_EDITION_OBJ" ao, sys.user$ au, sys.type$ at
where bitand(t.properties, 64) != 64 -- u.name
  and o.owner# = u.user#
  and t.package_obj# IS NOT NULL                          -- only package types
  and o.obj# = t.package_obj#
  and o.subname IS NULL -- get the latest version only
  and o.type# <> 10 -- must not be invalid
  and bitand(t.properties, 2048) = 0 -- not system-generated
  and t.toid = a.toid
  and t.version# = a.version#
  and a.attr_toid = ao.oid$
  and a.attr_version# = at.version#
  and ao.owner# = au.user#
  and a.attr_toid = at.toid
UNION
--
-- Package type attributes in package types.  
--
select u.name, t.typ_name, o.name, a.name, null, 
       nvl2(a.synobj#, (select u.name from user$ u, "_CURRENT_EDITION_OBJ" o 
            where o.owner#=u.user# and o.obj#=a.synobj#), au.name),
       at.typ_name || decode(bitand(at.properties,134217728),134217728,
                             '%ROWTYPE', null), 
       nvl2(a.synobj#, (select o.name from "_CURRENT_EDITION_OBJ" o 
                        where o.obj#=a.synobj#), ao.name),
       a.length, 
       a.precision#, 
       a.scale,
       decode(a.charsetform, 1, 'CHAR_CS',
                             2, 'NCHAR_CS',
                             3, NLS_CHARSET_NAME(a.charsetid),
                             4, 'ARG:'||a.charsetid),
       a.attribute#,
       decode(bitand(a.properties, 4096), 4096, 'C', 'B')
from sys.user$ u, sys."_CURRENT_EDITION_OBJ" o, sys.type$ t, 
     sys.attribute$ a,
     sys."_CURRENT_EDITION_OBJ" ao, sys.user$ au, sys.type$ at
where o.owner# = u.user#
  and t.package_obj# IS NOT NULL                          -- only package types
  and o.obj# = t.package_obj#
  and o.type# <> 10 -- must not be invalid
  and t.toid = a.toid
  and t.version# = a.version#
  and at.package_obj# IS NOT NULL
  and at.package_obj# = ao.obj#
  and ao.owner# = au.user#
  and a.attr_toid = at.toid
  and a.attr_version# = at.version#
UNION
--
-- %rowtype attributes in package types.  
--
select u.name, 
       t.typ_name,
       o.name, a.name, null,
       nvl2(a.synobj#, (select u.name 
                        from user$ u, "_CURRENT_EDITION_OBJ" o
                        where o.owner#=u.user# and o.obj#=a.synobj#),
            au.name),
       nvl2(a.synobj#, (select o.name 
                        from "_CURRENT_EDITION_OBJ" o 
                         where o.obj#=a.synobj#),
            ao.name) || '%ROWTYPE',
       null, null, null, null, null,
       a.attribute#, null
from sys.user$ u, sys."_CURRENT_EDITION_OBJ" o, sys.type$ t, 
     sys.attribute$ a,
     sys."_CURRENT_EDITION_OBJ" ao, sys.user$ au, sys.oid$ id
where bitand(t.properties, 64) != 64 -- u.name
  and o.owner# = u.user#
  and t.package_obj# IS NOT NULL                          -- only package types
  and o.obj# = t.package_obj#
  and o.subname IS NULL -- get the latest version only
  and o.type# <> 10 -- must not be invalid
  and bitand(t.properties, 2048) = 0 -- not system-generated
  and t.toid = a.toid
  and t.version# = a.version#
  and a.attr_toid = id.oid$
  and id.obj# = ao.obj#
  and ao.type# in (2,4)                     -- table or view collection element
  and ao.owner# = au.user#;
/
comment on table DBA_PLSQL_TYPE_ATTRS is
'Description of attributes of all plsql types in the database'
/
comment on column DBA_PLSQL_TYPE_ATTRS.OWNER is
'Owner of the type'
/
comment on column DBA_PLSQL_TYPE_ATTRS.TYPE_NAME is
'Name of the type'
/
comment on column DBA_PLSQL_TYPE_ATTRS.PACKAGE_NAME is
'Name of the package containing the type'
/
comment on column DBA_PLSQL_TYPE_ATTRS.ATTR_NAME is
'Name of the attribute'
/
comment on column DBA_PLSQL_TYPE_ATTRS.ATTR_TYPE_MOD is
'Type modifier of the attribute'
/
comment on column DBA_PLSQL_TYPE_ATTRS.ATTR_TYPE_OWNER is
'Owner of the type of the attribute'
/
comment on column DBA_PLSQL_TYPE_ATTRS.ATTR_TYPE_NAME is
'Name of the type of the attribute'
/
comment on column DBA_PLSQL_TYPE_ATTRS.ATTR_TYPE_PACKAGE is
'Name of the package containing the attribute type'
/
comment on column DBA_PLSQL_TYPE_ATTRS.LENGTH is
'Length of the CHAR attribute or maximum length of the VARCHAR
or VARCHAR2 attribute'
/
comment on column DBA_PLSQL_TYPE_ATTRS.PRECISION is
'Decimal precision of the NUMBER or DECIMAL attribute or
binary precision of the FLOAT attribute'
/
comment on column DBA_PLSQL_TYPE_ATTRS.SCALE is
'Scale of the NUMBER or DECIMAL attribute'
/
comment on column DBA_PLSQL_TYPE_ATTRS.CHARACTER_SET_NAME is
'Character set name of the attribute'
/
comment on column DBA_PLSQL_TYPE_ATTRS.ATTR_NO is
'Syntactical order number or position of the attribute as specified in the
type specification or CREATE TYPE statement (not to be used as ID number)'
/
comment on column DBA_PLSQL_TYPE_ATTRS.CHAR_USED is
'C if the width was specified in characters, B if in bytes'
/
create or replace public synonym DBA_PLSQL_TYPE_ATTRS for DBA_PLSQL_TYPE_ATTRS
/
grant select on DBA_PLSQL_TYPE_ATTRS to select_catalog_role
/

execute SYS.CDBView.create_cdbview(false,'SYS','DBA_PLSQL_TYPE_ATTRS',-
'CDB_PLSQL_TYPE_ATTRS');
create or replace public synonym CDB_PLSQL_TYPE_ATTRS for 
sys.CDB_PLSQL_TYPE_ATTRS;
grant select on CDB_PLSQL_TYPE_ATTRS to select_catalog_role;

@?/rdbms/admin/sqlsessend.sql
