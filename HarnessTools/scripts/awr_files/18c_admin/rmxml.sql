Rem
Rem $Header: xdk/admin/rmxml.sql /main/31 2017/02/16 09:10:49 raeburns Exp $
Rem
Rem rmxml.sql
Rem
Rem Copyright (c) 1999, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      rmxml.sql - ReMove XML components from JServer
Rem
Rem    DESCRIPTION
Rem      Removes xml components from the JServer
Rem
Rem    NOTES
Rem
Rem MODIFIED (MM/DD/YY)
Rem raeburns  01/24/17 - Bug 25438740: Remove ALTER for XMLCharacterInputStream
Rem kzhou     02/04/16 - add regex
Rem kzhou     04/14/14 - add drop regex
Rem tyu       03/15/13 - Common start and end scripts
Rem tyu       07/13/12 - drop fi packages
Rem kzhou     09/27/11 - update for fi, xti and pullparser
Rem jmuller   04/14/11 - Fix bug 8643797: fix upgrade/downgrade for change in
Rem                      XMLCharacterInputStream
Rem shivsriv  01/02/11 - changes for fdom
Rem tyu       11/08/06 - lrg 2625031
Rem bihan     10/25/06 - rm org/xml/sax
Rem mdmehta   02/09/06 - 
Rem kmuthiah  02/23/05 - add xquery too
Rem kkarun    05/12/04 - update for 10g 
Rem kkarun    12/11/03 - update packages 
Rem bihan     12/15/03 - add oracle/xml/jdwp
Rem mjaeger   09/18/03 - bug 3015638: add removal of XSU parts
Rem kkarun    04/16/03 - update pkg list
Rem kkarun    03/25/03 - use dbms_registry vars
Rem kkarun    12/12/02 - dont remove jserver system classes
Rem kkarun    11/12/02 - update version
Rem kkarun    09/26/02 - remove classgen
Rem kkarun    10/02/02 - update version
Rem kkarun    10/02/02 - update version
Rem kkarun    05/30/02 - remove plsql
Rem kkarun    12/17/01 - split drop  package v2
Rem kkarun    12/05/01 - update to use registry
Rem kkarun    04/04/01 - add xsu.
Rem kkarun    07/13/00 - fix paths
Rem kkarun    04/07/00 - update rmxml.sql
Rem nramakri  10/21/99 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

EXECUTE dbms_registry.removing('XML');

-- Drop Java Packages
create or replace procedure xdk_drop_package(pkg varchar2) is
   CURSOR classes is select dbms_java.longname(object_name) class_name
      from all_objects
      where object_type = 'JAVA CLASS'
	and dbms_java.longname(object_name) like '%' || pkg || '%';
begin
   FOR class IN classes LOOP
      dbms_java.dropjava('-r -v -synonym ' || class.class_name);
   END LOOP;
end xdk_drop_package;
/

EXECUTE xdk_drop_package('javax/xml');
EXECUTE xdk_drop_package('org/w3c/dom/bootstrap');
EXECUTE xdk_drop_package('org/w3c/dom/events');
EXECUTE xdk_drop_package('org/w3c/dom/ls');
EXECUTE xdk_drop_package('org/w3c/dom/ranges');
EXECUTE xdk_drop_package('org/w3c/dom/traversal');
EXECUTE xdk_drop_package('org/w3c/dom/validation');
EXECUTE xdk_drop_package('org/xml/sax');
EXECUTE xdk_drop_package('oracle/xml');
EXECUTE xdk_drop_package('OracleXML');
EXECUTE xdk_drop_package('oracle/xdb');
EXECUTE xdk_drop_package('oracle/xquery');
EXECUTE xdk_drop_package('com/sun/xml/fastinfoset');
EXECUTE xdk_drop_package('org/jvnet/fastinfoset');


BEGIN
 dbms_java.dropjava('.xdk_version_' ||
                    dbms_registry.release_version || '_' ||
                    dbms_registry.release_status);
END;
/

drop procedure xdk_drop_package;

EXECUTE dbms_registry.removed('XML');


@?/rdbms/admin/sqlsessend.sql
