Rem
Rem $Header: rdbms/admin/catmacpre.sql /main/14 2017/05/02 08:57:19 jibyun Exp $
Rem
Rem catmacpre.sql
Rem
Rem Copyright (c) 2007, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catmacpre.sql - Creates DV Account Manager Account
Rem
Rem    DESCRIPTION
Rem      This script is called at the end of catmac script and creates the
Rem       DV account manager.
Rem
Rem    NOTES
Rem      Must be run as SYSDBA 
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catmacpre.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catmacpre.sql
Rem SQL_PHASE: CATMACPRE
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catmac.sql
Rem END SQL_FILE_METADATA
Rem
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    jibyun      04/24/17 - Bug 25932440: alter DVSYS with NO AUTHENTICATION
Rem    jibyun      08/11/16 - XbranchMerge jibyun_bug-24380389 from
Rem                           st_rdbms_12.2.0.1.0
Rem    jibyun      08/02/16 - Bug 24380389: remove parameter for SYS password
Rem    jibyun      08/05/15 - Bug 21519712: allow ORACLE_OCM to query
Rem                           DBA_DV_REALM
Rem    aketkar     04/29/14 - sql patch metadata seed
Rem    sanbhara    02/27/12 - Bug 13699578 fix.
Rem    jaeblee     08/26/11 - 12914214: remove connects
Rem    sanbhara    08/11/11 - Project 24121 - removing call to
Rem                           update_command_rule since these are already
Rem                           enabled when rows are created in catmacd.sql.
Rem    sanbhara    05/02/11 - Project 24121 - move DV configuration out of
Rem                           catmac.
Rem    sankejai    04/11/11 - set _oracle_script in session after connect
Rem    jsamuel     09/24/08 - passwordless patching
Rem    pknaggs     06/20/07 - 6141884: backout fix for bug 5716741.
Rem    pknaggs     05/31/07 - 5716741: sysdba can't do account management.
Rem    ruparame    05/18/07 - Make DV account manager optional
Rem    ruparame    01/13/07 - DV/DBCA Integration
Rem    ruparame    01/10/07 - DV/DBCA Integration
Rem    ruparame    01/10/07 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

SET ECHO ON
SET FEEDBACK 1
SET NUMWIDTH 10
SET LINESIZE 80
SET TRIMSPOOL ON
SET TAB OFF
SET PAGESIZE 100

--from catmacpost.sql
GRANT DV_MONITOR to DBSNMP;

-- Bug 21519712: allow ORACLE_OCM to query DBA_DV_REALM.
BEGIN
  execute immediate 'GRANT SELECT on DVSYS.DBA_DV_REALM to ORACLE_OCM';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE IN (-1917) THEN NULL; --ignore if ORACLE_OCM does not exist.
      ELSE RAISE;
    END IF;
END;
/

GRANT DV_ADMIN to SYS;

begin
  dbms_macadm.authorize_scheduler_user('SYS', 'EXFSYS');
exception when others then
  -- Ignore the error if EXFSYS is not created.
  if SQLCODE in (-47324, -47951, -29504) then 
    null;
  else 
    raise;
  end if;
end;
/

REVOKE DV_ADMIN from SYS;

ALTER USER dvsys ACCOUNT LOCK NO AUTHENTICATION
/


DECLARE
    num number;
BEGIN
    dbms_registry.loaded('DV');
    SYS.validate_dv;
END;
/
commit;


@?/rdbms/admin/sqlsessend.sql

