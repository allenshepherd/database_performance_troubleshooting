Rem
Rem $Header: rdbms/admin/cattrans.sql /main/14 2014/12/11 22:46:35 skayoor Exp $
Rem
Rem cattrans.sql
Rem
Rem Copyright (c) 2000, 2014, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      cattrans.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/cattrans.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/cattrans.sql
Rem SQL_PHASE: CATTRANS
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catptabs.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    skayoor     11/30/14 - Proj 58196: Change Select priv to Read Priv
Rem    krajaman    09/12/14 - Move tables, sequence to dmisc.bsq 
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    talliu      06/28/13 - Add CDB view for DBA view
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    yberezin    09/16/11 - bug 12926385
Rem    traney      03/31/11 - 35209: long identifiers dictionary upgrade
Rem    swshekha    01/15/09 - add view all_transformations
Rem    wesmith     10/03/03 - register DBMS_TRANSFORM_EXIMP for instance-level 
Rem                           export procedural action
Rem    gviswana    01/29/02 - CREATE OR REPLACE SYNONYM
Rem    nbhatt      01/23/02 - add the type names to dictionary
Rem    rburns      10/28/01 - remove constraint error
Rem    nbhatt      11/29/00 - add the DBMS_TRANSFORM_EXIMP package to exppkgobj
Rem    nbhatt      09/26/00 - add views, comments
Rem    nbhatt      09/19/00 - replace colon with slash
Rem    nbhatt      08/28/00 - add version information in dictionary
Rem    nbhatt      07/31/00 - transformation dictionary tables
Rem    nbhatt      07/31/00 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

--
-- User_transformations
--
create or replace view USER_TRANSFORMATIONS
(transformation_id, name, from_type, to_type)
as
SELECT t.transformation_id,  t.name, 
       t.from_schema||'.'||t.from_type, t.to_schema||'.'||t.to_type
FROM transformations$ t, sys.user$ u
WHERE u.user# = USERENV('SCHEMAID')
and u.name = t.owner
/

--
-- User transformation attributes
--

Create or replace view USER_ATTRIBUTE_TRANSFORMATIONS
(transformation_id, name, from_type, to_type, 
attribute, attribute_transformation)
as
SELECT t.transformation_id,  t.name, 
       t.from_schema||'.'||t.from_type, t.to_schema||'.'||t.to_type,
       at.attribute_number,
       at.sql_expression
FROM transformations$ t, attribute_transformations$ at, sys.user$ u
WHERE u.user# = USERENV('SCHEMAID')
and u.name = t.owner and t.transformation_id = at.transformation_id
/

--
-- DBA_transformations

create or replace view DBA_TRANSFORMATIONS
(transformation_id, owner, name, from_type, to_type)
as
SELECT t.transformation_id, u.name, t.name, 
       t.from_schema||'.'||t.from_type, t.to_schema||'.'||t.to_type
FROM transformations$ t, sys.user$ u
WHERE  u.name = t.owner
/



execute CDBView.create_cdbview(false,'SYS','DBA_TRANSFORMATIONS','CDB_TRANSFORMATIONS');
grant select on SYS.CDB_TRANSFORMATIONS to select_catalog_role
/
create or replace public synonym CDB_TRANSFORMATIONS for SYS.CDB_TRANSFORMATIONS
/

--
-- DBA transformation attributes
--

Create or replace view DBA_ATTRIBUTE_TRANSFORMATIONS
(transformation_id, owner, name, from_type, to_type, attribute, attribute_transformation)
as
SELECT t.transformation_id, u.name, t.name, 
       t.from_schema||'.'||t.from_type, t.to_schema||'.'||t.to_type,
       at.attribute_number,
       at.sql_expression
FROM transformations$ t, attribute_transformations$ at, sys.user$ u
WHERE  u.name = t.owner and t.transformation_id = at.transformation_id
/


execute CDBView.create_cdbview(false,'SYS','DBA_ATTRIBUTE_TRANSFORMATIONS','CDB_ATTRIBUTE_TRANSFORMATIONS');
grant select on SYS.CDB_ATTRIBUTE_TRANSFORMATIONS to select_catalog_role
/
create or replace public synonym CDB_ATTRIBUTE_TRANSFORMATIONS for SYS.CDB_ATTRIBUTE_TRANSFORMATIONS
/

--
-- ALL transformations
--

CREATE OR REPLACE VIEW ALL_TRANSFORMATIONS
(transformation_id, owner, name, from_type, to_type)
AS
select  t.transformation_id, t.owner, t.name, t.from_type,
        t.to_type from transformations$ t, sys.user$ u
where
u.user# = USERENV('SCHEMAID')                     
and (u.name = t.owner                                        /* user is the owner */
or (exists (select null from v$enabledprivs          /* user has system privelege */    
               where priv_number in (-184 /* EXECUTE ANY TYPE */)))
or
(t.from_type in                                  /* user has execute on from type */ 
(
select t.from_type from transformations$ t, obj$ o, objauth$ oa
where
o.obj# = oa.obj# and
t.from_type = o.name and
(oa.grantor# = userenv('SCHEMAID') OR  
    oa.obj# in
         (select ro.obj#
          from sys.objauth$ ro
          where grantee# in (select kzsrorol from x$kzsro))
)
and t.to_type in                                /* user has execute on to type */  
(
select t.to_type from transformations$ t, obj$ o, objauth$ oa
where
o.obj# = oa.obj# and
t.to_type = o.name and
(oa.grantor# = userenv('SCHEMAID') OR
    oa.obj# in
         (select ro.obj#
          from sys.objauth$ ro
          where grantee# in (select kzsrorol from x$kzsro))))))
) 
/

--
-- ALL transformation attributes
--

Create or replace view ALL_ATTRIBUTE_TRANSFORMATIONS
(transformation_id, owner, name, from_type, to_type, attribute, attribute_transformation)
as
SELECT t.transformation_id, t.owner, t.name,
       t.from_schema||'.'||t.from_type, t.to_schema||'.'||t.to_type,
       at.attribute_number,
       at.sql_expression
FROM transformations$ t, attribute_transformations$ at, sys.user$ u
WHERE  
t.transformation_id = at.transformation_id and
u.user# = USERENV('SCHEMAID')
and (u.name = t.owner                                      /* user is the owner */
or (exists (select null from v$enabledprivs        /* user has system privelege */ 
               where priv_number in (-184 /* EXECUTE ANY TYPE */)))
or
(t.from_type in                                 /* user has execute on from type */
(
select t.from_type from transformations$ t, obj$ o, objauth$ oa
where
o.obj# = oa.obj# and
t.from_type = o.name and
(oa.grantor# = userenv('SCHEMAID') OR      oa.obj# in
         (select ro.obj#
          from sys.objauth$ ro
          where grantee# in (select kzsrorol from x$kzsro))
)
and t.to_type in                                  /* user has execute on to type */
(
select t.to_type from transformations$ t, obj$ o, objauth$ oa
where
o.obj# = oa.obj# and
t.to_type = o.name and
(oa.grantor# = userenv('SCHEMAID') OR
    oa.obj# in
         (select ro.obj#
          from sys.objauth$ ro
          where grantee# in (select kzsrorol from x$kzsro))))))
)
/


create or replace public synonym dba_transformations for dba_transformations
/

create or replace public synonym user_transformations for user_transformations
/

create or replace public synonym all_transformations for all_transformations
/

grant read on user_transformations to PUBLIC with grant option
/


create or replace public synonym dba_attribute_transformations
   for dba_attribute_transformations
/

create or replace public synonym user_attribute_transformations
   for user_attribute_transformations
/

create or replace public synonym all_attribute_transformations
   for all_attribute_transformations
/

grant read on user_attribute_transformations to PUBLIC with grant option
/

grant select on dba_attribute_transformations to select_catalog_role
/

grant select on dba_transformations to select_catalog_role
/

grant read on all_attribute_transformations to PUBLIC
/

grant read on all_transformations to PUBLIC
/

delete from sys.exppkgact$ 
where package = 'DBMS_TRANSFORM_EXIMP' and schema='SYS';

insert into sys.exppkgact$(package, schema, class, level#)
values('DBMS_TRANSFORM_EXIMP', 'SYS', 2, 1000)
/
insert into sys.exppkgact$(package, schema, class, level#)
values('DBMS_TRANSFORM_EXIMP', 'SYS', 3, 1000)
/

@?/rdbms/admin/sqlsessend.sql
