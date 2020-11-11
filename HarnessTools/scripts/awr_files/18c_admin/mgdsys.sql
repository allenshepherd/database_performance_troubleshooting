Rem
Rem $Header: rdbms/admin/mgdsys.sql /main/9 2017/05/28 22:46:07 stanaya Exp $
Rem
Rem mgdsys.sql
Rem
Rem Copyright (c) 2006, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      mgdsys.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      Create mgdsys schema and grant appropriate priviledges
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/mgdsys.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/mgdsys.sql
Rem    SQL_PHASE: MGDSYS
Rem    SQL_STARTUP_MODE: NORMAL
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    END SQL_FILE_METADATA
Rem    
Rem    MODIFIED   (MM/DD/YY)
Rem    hgong       04/26/16 - bug 23109575
Rem    hgong       03/02/16 - add call to sqlsessstart and sqlsessend
Rem    dalpern     02/15/12 - proj 32719: INHERIT PRIVILEGES privilege
Rem    jmadduku    02/18/11 - Proj 32507: Grant Unlimited Tablespace privilege
Rem                           explicitly
Rem    hgong       02/05/07 - grant permissions for 
Rem                           javax.management.MBeanServerPermission
Rem                           and javax.management.MBeanPermission to MGDSYS
Rem    hgong       07/12/06 - use upper case sys user 
Rem    hgong       05/22/06 - grant java logging permission 
Rem    hgong       05/15/06 - clean up script 
Rem    hgong       04/04/06 - rename oidcode.jar 
Rem    hgong       03/31/06 - create system user 
Rem    hgong       03/31/06 - Created
Rem

Rem ********************************************************************
Rem #22747454: Indicate Oracle-Supplied object
@@?/rdbms/admin/sqlsessstart.sql
Rem ********************************************************************

prompt .. Creating MGDSYS schema

create user MGDSYS identified by MGDSYS;

#prompt .. lock the user and expire the password
#alter user MGDSYS  ACCOUNT LOCK PASSWORD EXPIRE;

prompt .. Granting permissions to MGDSYS 

GRANT RESOURCE , UNLIMITED TABLESPACE TO MGDSYS;

grant inherit any privileges to MGDSYS;
grant inherit privileges on user SYS to MGDSYS;

call dbms_java.grant_permission('MGDSYS', 'SYS:java.net.SocketPermission','*', 'connect, resolve');
call dbms_java.grant_permission('MGDSYS', 'SYS:java.util.PropertyPermission', '*', 'read,write' );
call dbms_java.grant_permission('MGDSYS', 'SYS:java.io.FilePermission', 'rdbms/jlib/mgd_idcode.jar', 'read' );
call dbms_java.grant_permission( 'MGDSYS', 'SYS:java.util.logging.LoggingPermission', 'control', '' );
call dbms_java.grant_permission( 'MGDSYS', 'SYS:javax.management.MBeanServerPermission', 'createMBeanServer', '' );
call dbms_java.grant_permission( 'MGDSYS', 'SYS:javax.management.MBeanPermission', 'oracle.jdbc.driver.OracleLog#-[com.oracle.jdbc:type=diagnosability]', 'registerMBean' );

Rem ********************************************************************
Rem #22747454: Indicate Oracle-Supplied object
@@?/rdbms/admin/sqlsessend.sql
Rem ********************************************************************

