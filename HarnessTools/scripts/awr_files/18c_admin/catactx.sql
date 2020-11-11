Rem
Rem $Header: rdbms/admin/catactx.sql /main/19 2016/03/10 18:14:45 akruglik Exp $
Rem
Rem catactx.sql
Rem
Rem Copyright (c) 2008, 2016, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catactx.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catactx.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catactx.sql
Rem SQL_PHASE: CATACTX
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catptabs.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    aanverma    02/03/16 - 22593752: cmnt on ORIGIN_CON_ID in DBA_CONTEXT
Rem    akruglik    01/25/16 - (22132084): replace COMMON_DATA with
Rem                           SHARING=EXTENDED DATA
Rem    pyam        07/31/15 - 21500402: fix dba_contexts
Rem    himagarw    02/24/15 - Bug #20558675 : Add long identifier support
Rem    skayoor     11/30/14 - Proj 58196: Change Select priv to Read Priv
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    talliu      06/28/13 - Add CDB view for DBA view
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    sankejai    06/06/11 - 12623919: add CON_ID column to v_$context
Rem    dsirmuka    11/11/08 - #5697725. Pull out outer predicates from sub qry
Rem    gviswana    05/24/01 - CREATE OR REPLACE SYNONYM
Rem    htseng      04/12/01 - eliminate execute twice (remove ;).
Rem    rvissapr    09/08/00 - bug 1394376
Rem    cchui       06/07/00 - add initialized globally context
Rem    rvissapr    06/02/00 - 
Rem    rvissapr    05/24/00 - adding global context views.
Rem    dmwong      08/04/99 - make namespace and context 30 char long
Rem    dmwong      09/23/98 - dictionary views for application context         
Rem    dmwong      09/23/98 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

remark
remark  FAMILY "CONTEXT"
remark
remark  Views for showing information about context namespaces:
remark  SESSION_CONTEXT, ALL_CONTEXT and DBA_CONTEXT
remark
 
create or replace view v_$context as
  select SUBSTR(namespace,1,128) "NAMESPACE", 
         SUBSTR(attribute,1,128) "ATTRIBUTE",
         value "VALUE",
         con_id "CON_ID" from v$context;
create or replace public synonym v$context for v_$context;
grant select on v_$context to select_catalog_role;
 
create or replace view gv_$context as
  select  SUBSTR(namespace,1,128) "NAMESPACE", 
         SUBSTR(attribute,1,128)  "ATTRIBUTE",          
         value "VALUE",
         con_id "CON_ID" from gv$context;
create or replace public synonym gv$context for gv_$context;
grant select on gv_$context to select_catalog_role;
 
create or replace view SESSION_CONTEXT
        ( NAMESPACE, ATTRIBUTE, VALUE )
as
select namespace, attribute, value from v_$context
/
comment on table SESSION_CONTEXT is
'Description of all context attributes set under the current session'
/
comment on column SESSION_CONTEXT.NAMESPACE is
'Namespace of the attribute'
/
comment on column SESSION_CONTEXT.ATTRIBUTE is
'Name of the attribute'
/
comment on column SESSION_CONTEXT.VALUE is
'Value of the attribute'
/
create or replace public synonym SESSION_CONTEXT for SESSION_CONTEXT
/
grant read on SESSION_CONTEXT to PUBLIC with grant option
/
create or replace view ALL_CONTEXT
       (NAMESPACE, SCHEMA, PACKAGE)
as
select o.name, c.schema, c.package 
from  context$ c, obj$ o
where o.obj# = c.obj# and 
      o.type# = 44 and
      exists ( select null
               from v$context  v
               where v.namespace = o.name
             )
/

comment on table ALL_CONTEXT is
'Description of all active context namespaces under the current session'
/
comment on column ALL_CONTEXT.NAMESPACE is
'Namespace of the active context'
/
comment on column ALL_CONTEXT.SCHEMA is
'Schema of the designated package'
/
comment on column ALL_CONTEXT.PACKAGE is
'Name of the designated package'
/
create or replace public synonym ALL_CONTEXT for ALL_CONTEXT
/
grant read on ALL_CONTEXT to PUBLIC with grant option
/
create or replace view INT$DBA_CONTEXT SHARING=EXTENDED DATA
       (NAMESPACE, SCHEMA, PACKAGE, TYPE, SHARING, ORIGIN_CON_ID)
as
select o.name, c.schema, c.package,
  DECODE(c.flags, 0,'ACCESSED LOCALLY',
                  1,'INITIALIZED EXTERNALLY',
                  2,'ACCESSED GLOBALLY',
                  4,'INITIALIZED GLOBALLY'),
  case when bitand(o.flags, 196608)>0 then 1 else 0 end,
  to_number(sys_context('USERENV', 'CON_ID'))
from  context$ c, obj$ o
where c.obj# = o.obj#
and o.type# = 44
/
create or replace view DBA_CONTEXT
  (NAMESPACE, SCHEMA, PACKAGE, TYPE, ORIGIN_CON_ID)
as
select NAMESPACE, SCHEMA, PACKAGE, TYPE, ORIGIN_CON_ID
  from INT$DBA_CONTEXT
/
comment on table DBA_CONTEXT is
'Description of all context namespace information'
/
comment on column DBA_CONTEXT.NAMESPACE is
'Namespace of the context'
/
comment on column DBA_CONTEXT.SCHEMA is
'Schema of the designated package'
/
comment on column DBA_CONTEXT.PACKAGE is
'Name of the designated package'
/
comment on column DBA_CONTEXT.TYPE is
'Type of the context create'
/
comment on column DBA_CONTEXT.ORIGIN_CON_ID is
'ID of Container where row originates'
/
create or replace public synonym DBA_CONTEXT for DBA_CONTEXT
/
grant select on DBA_CONTEXT to select_catalog_role
/
 

execute CDBView.create_cdbview(false,'SYS','DBA_CONTEXT','CDB_CONTEXT');
grant select on SYS.CDB_CONTEXT to select_catalog_role
/
create or replace public synonym CDB_CONTEXT for SYS.CDB_CONTEXT
/

Remark      Family "CONTEXT"
Remark    Subgroup "GLOBALCONTEXT"
Remark  Views showing information on Global Context
Remark  DBA_GLOBAL_CONTEXT , ALL_GLOBALCONTET


create or replace view v_$globalcontext as
  select SUBSTR(namespace,1,128) "NAMESPACE", 
         SUBSTR(attribute,1,128) "ATTRIBUTE",
         value "VALUE",
         SUBSTR(username,1,128) "USERNAME",
         clientidentifier "CLIENT_IDENTIFIER",
         con_id "CON_ID"
         from v$globalcontext;

create or replace public synonym v$globalcontext for v_$globalcontext;
grant select on v_$globalcontext to select_catalog_role
/
create or replace view gv_$globalcontext as
  select  SUBSTR(namespace,1,128) "NAMESPACE", 
         SUBSTR(attribute,1,128)  "ATTRIBUTE",          
         value "VALUE",
         SUBSTR(username,1,128) "USERNAME",
         clientidentifier "CLIENT_IDENTIFIER",
         con_id "CON_ID"
         from gv$globalcontext;
create or replace public synonym gv$globalcontext for gv_$globalcontext
/
grant select on gv_$globalcontext to select_catalog_role
/
create or replace view GLOBAL_CONTEXT
(namespace,attribute,value,username,client_identifier)
as
select namespace,attribute,value,username,clientidentifier
from v$globalcontext
where clientidentifier is null or clientidentifier = SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER')
/
grant read on global_context to public
/
comment on table GLOBAL_CONTEXT is
'Information on all the globally accessible context attribute values'
/
comment on column GLOBAL_CONTEXT.NAMESPACE is
'Namespace of the globally accesssible context'
/
comment on column GLOBAL_CONTEXT.ATTRIBUTE is
'attribute of the globally accessible context'
/ 
comment on column GLOBAL_CONTEXT.VALUE is
'value of the attribute of the globally accessible context'
/
comment on column GLOBAL_CONTEXT.USERNAME is
'username for which globally accessible context value is applicable '
/
comment on column GLOBAL_CONTEXT.CLIENT_IDENTIFIER is
'client identifier of the globally accessible context'
/
create or replace public synonym global_context for global_context
/
grant select on GLOBAL_CONTEXT to select_catalog_role
/
create or replace view DBA_GLOBAL_CONTEXT
(namespace, schema , package)
as
select o.name, c.schema,c.package
from  context$ c, obj$ o
where c.obj# = o.obj#
and o.type# = 44
and c.flags= 2
/
comment on table DBA_GLOBAL_CONTEXT is
'Description of all context information accessible globally'
/
comment on column DBA_GLOBAL_CONTEXT.SCHEMA is
'Namespace of the globally accessible context'
/
comment on column DBA_GLOBAL_CONTEXT.SCHEMA is
'Schema of the package that administers the globally accessible context'
/
comment on column DBA_GLOBAL_CONTEXT.PACKAGE is
'Package that administers the globally accessible context' 
/
create or replace public synonym DBA_GLOBAL_CONTEXT for DBA_GLOBAL_CONTEXT
/
grant select on DBA_GLOBAL_CONTEXT to select_catalog_role
/ 


execute CDBView.create_cdbview(false,'SYS','DBA_GLOBAL_CONTEXT','CDB_GLOBAL_CONTEXT');
grant select on SYS.CDB_GLOBAL_CONTEXT to select_catalog_role
/
create or replace public synonym CDB_GLOBAL_CONTEXT for SYS.CDB_GLOBAL_CONTEXT
/


@?/rdbms/admin/sqlsessend.sql
