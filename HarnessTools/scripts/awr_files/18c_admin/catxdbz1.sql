Rem
Rem $Header: rdbms/admin/catxdbz1.sql /main/2 2014/12/11 22:46:35 skayoor Exp $
Rem
Rem catxdbz1.sql
Rem
Rem Copyright (c) 2014, Oracle and/or its affiliates. All rights reserved.
Rem
Rem    NAME
Rem      catxdbz1.sql - XDS security initialization - views
Rem
Rem    DESCRIPTION
Rem      This script creates the views for XDS security
Rem
Rem    NOTES
Rem     
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/catxdbz1.sql 
Rem    SQL_SHIPPED_FILE: rdbms/admin/catxdbz1.sql 
Rem    SQL_PHASE: CATXDBZ1
Rem    SQL_STARTUP_MODE: NORMAL 
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: rdbms/admin/catxdbz0.sql 
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    skayoor     11/30/14 - Proj 58196: Change Select priv to Read Priv
Rem    raeburns    06/25/14 - break out view definitions for reload
Rem    raeburns    06/25/14 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

create or replace view XDS_ACL
  (ACLID, SHARED, DESCRIPTION, SECURITY_CLASS_NS, 
   SECURITY_CLASS_NAME, PARENT_ACL_PATH, INHERITANCE_TYPE)
as 
select a.object_id, 
       substr(extractvalue(a.object_value, '/acl/@shared', 
                           'xmlns="http://xmlns.oracle.com/xdb/acl.xsd"'), 
              1, 5), 
       extractvalue(a.object_value, '/acl/@description', 
                    'xmlns="http://xmlns.oracle.com/xdb/acl.xsd"'), 
       xmlquery('declare namespace a="http://xmlns.oracle.com/xdb/acl.xsd"; fn:namespace-uri-from-QName(fn:data(/a:acl/a:security-class))' PASSING OBJECT_VALUE returning content),
       xmlquery('declare namespace a="http://xmlns.oracle.com/xdb/acl.xsd"; fn:local-name-from-QName(fn:data(/a:acl/a:security-class))' PASSING OBJECT_VALUE returning content),
       CASE existsNode(a.object_value, '/acl/extends-from', 
                       'xmlns="http://xmlns.oracle.com/xdb/acl.xsd"') WHEN 1 
       THEN extractvalue(a.object_value, '/acl/extends-from/@href', 
                         'xmlns="http://xmlns.oracle.com/xdb/acl.xsd"')
       ELSE (CASE existsNode(a.object_value, '/acl/constrained-with', 
                             'xmlns="http://xmlns.oracle.com/xdb/acl.xsd"') 
             WHEN 1 
             THEN extractvalue(a.object_value, '/acl/constrained-with/@href', 
                               'xmlns="http://xmlns.oracle.com/xdb/acl.xsd"')
             ELSE NULL END) END, 
       CASE existsNode(a.object_value, '/acl/extends-from', 
                       'xmlns="http://xmlns.oracle.com/xdb/acl.xsd"') WHEN 1 
       THEN 'extends-from'
       ELSE (CASE existsNode(a.object_value, '/acl/constrained-with', 
                             'xmlns="http://xmlns.oracle.com/xdb/acl.xsd"') 
             WHEN 1 
             THEN 'constrained-with'
             ELSE NULL END) END 
FROM XDB.XDB$ACL a;

create or replace public synonym XDS_ACL for XDS_ACL;

grant read on XDS_ACL to PUBLIC;

comment on table XDS_ACL is
'All ACLs that are visible to the current user in the database'
/

comment on column XDS_ACL.ACLID is
'The ACL ID of an ACL'
/
comment on column XDS_ACL.SHARED is
'Whether this ACL is shared or not'
/

comment on column XDS_ACL.DESCRIPTION is
'The ACL description'
/

comment on column XDS_ACL.SECURITY_CLASS_NS is
'The namespace of the Security Class'
/

comment on column XDS_ACL.SECURITY_CLASS_NAME is
'The name of the Security Class'
/

comment on column XDS_ACL.PARENT_ACL_PATH is
'The path of its parent ACL'
/

comment on column XDS_ACL.INHERITANCE_TYPE is
'The inhertance type, i.e. constrained-with or extends-from'
/

create or replace view XDS_ACE
  (ACLID, START_DATE, END_DATE, IS_GRANT, 
   INVERT, PRINCIPAL, PRIVILEGE)
as 
select a.object_id, 
       extractvalue(value(b), '/ace/@start_date', 
                    'xmlns="http://xmlns.oracle.com/xdb/acl.xsd"'), 
       extractvalue(value(b), '/ace/@end_date', 
                    'xmlns="http://xmlns.oracle.com/xdb/acl.xsd"'), 
       substr(extractvalue(value(b), '/ace/grant', 
                           'xmlns="http://xmlns.oracle.com/xdb/acl.xsd"'), 
              1, 5), 
       CASE existsNode(value(b), '/ace/invert', 
                      'xmlns="http://xmlns.oracle.com/xdb/acl.xsd"') WHEN 1 
       THEN 'true'
       ELSE 'false' END, 
       CASE existsNode(value(b), '/ace/invert', 
                       'xmlns="http://xmlns.oracle.com/xdb/acl.xsd"') WHEN 1 
       THEN extractvalue(value(b), '/ace/invert/principal', 
                         'xmlns="http://xmlns.oracle.com/xdb/acl.xsd"')
       ELSE extractvalue(value(b), '/ace/principal', 
                         'xmlns="http://xmlns.oracle.com/xdb/acl.xsd"') END, 
       extract(value(b), '/ace/privilege', 
               'xmlns="http://xmlns.oracle.com/xdb/acl.xsd"')
from xdb.xdb$acl a, 
     table(XMLSequence(extract(a.object_value, '/acl/ace'))) b;

create or replace public synonym XDS_ACE for XDS_ACE;

grant read on XDS_ACE to PUBLIC; 

comment on table XDS_ACE is
'All ACEs in ACLs that are visible to the current user in the database'
/

comment on column XDS_ACE.ACLID is
'The ACL ID of an ACL'
/

comment on column XDS_ACE.START_DATE is
'The start_date attribute of the ACE'
/

comment on column XDS_ACE.END_DATE is
'The end_date attribute of the ACE'
/

comment on column XDS_ACE.IS_GRANT is
'true if this is a grant ACE, false otherwise'
/

comment on column XDS_ACE.INVERT is
'true if this ACE contains invert principal, false otherwise'
/

comment on column XDS_ACE.PRINCIPAL is
'The principal in this ACE'
/

comment on column XDS_ACE.PRIVILEGE is
'The privileges in this ACE'
/

commit;

@?/rdbms/admin/sqlsessend.sql
