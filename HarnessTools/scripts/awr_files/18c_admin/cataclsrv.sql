Rem
Rem $Header: rdbms/admin/cataclsrv.sql /main/6 2016/12/16 18:36:41 bnnguyen Exp $
Rem
Rem cataclsrv.sql
Rem
Rem Copyright (c) 2014, 2016, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      cataclsrv.sql
Rem
Rem    DESCRIPTION
Rem	 Create DBSFWUSER schema and ACL table.
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/cataclsrv.sql 
Rem    SQL_SHIPPED_FILE: rdbms/admin/cataclsrv.sql
Rem    SQL_PHASE: CATACLSRV
Rem    SQL_STARTUP_MODE: NORMAL 
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: rdbms/admin/catptabs.sql
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    bnnguyen    12/14/16 - bug 24808732: change default tbs to SYSAUX
Rem    bnnguyen    01/11/16 - bug 22299462: Revoke inherit privileges on 
Rem                           DBSFWUSER
Rem    bnnguyen    05/07/15 - bug 20134461: Grant select on [G]V$EXADIRECT_ACL
Rem                           and [G]V$IP_ACL to DBSFWUSER 
Rem    bnnguyen    04/11/15 - bug 20860190: Rename 'EXADIRECT' to 'DBSFWUSER'
Rem    bnnguyen    03/18/15 - bug 20726506: Grant select on v_$parameter
Rem                           to EXADIRECT.
Rem    bnnguyen    09/03/14 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

Rem DBSFWUSER USER is created with expired password, locked account and
Rem limited privileges. 

CREATE USER DBSFWUSER
  IDENTIFIED BY SECURE123
  PASSWORD EXPIRE
  ACCOUNT LOCK;

DECLARE
  already_revoked exception;
  pragma exception_init(already_revoked,-01927); 
BEGIN
  execute immediate 'REVOKE INHERIT PRIVILEGES ON USER DBSFWUSER FROM
                     PUBLIC';
EXCEPTION
  WHEN already_revoked THEN 
    null;
END;
/

ALTER USER DBSFWUSER DEFAULT TABLESPACE sysaux;
ALTER USER DBSFWUSER QUOTA UNLIMITED ON sysaux;
ALTER USER DBSFWUSER SET CONTAINER_DATA=ALL;

GRANT UNLIMITED TABLESPACE TO DBSFWUSER;
GRANT CREATE SESSION TO DBSFWUSER;
GRANT SELECT ON SERVICE$ TO DBSFWUSER;
GRANT SELECT ON V_$DATABASE TO DBSFWUSER;
GRANT SELECT ON V_$PARAMETER to DBSFWUSER;
GRANT SELECT ON V_$PDBS to DBSFWUSER;
GRANT SELECT ON GV_$EXADIRECT_ACL to DBSFWUSER;
GRANT SELECT ON V_$EXADIRECT_ACL to DBSFWUSER;
GRANT SELECT ON GV_$IP_ACL to DBSFWUSER;
GRANT SELECT ON V_$IP_ACL to DBSFWUSER;
GRANT SELECT ON CDB_SERVICE$ to DBSFWUSER;

CREATE TABLE DBSFWUSER.EXADIRECT_ACL
(       SERVICE_NAME VARCHAR2(512 BYTE) NOT NULL,
        VM_UUID VARCHAR2(34 BYTE) NOT NULL,
        VM_SGID VARCHAR2(39 BYTE),
        UNIQUE (SERVICE_NAME, VM_UUID)
);

CREATE TABLE DBSFWUSER.IP_ACL
(       SERVICE_NAME VARCHAR2(512 BYTE) NOT NULL,
        HOST VARCHAR2(256 BYTE),
        UNIQUE (SERVICE_NAME, HOST)
);

CREATE TABLE DBSFWUSER.ACL$_OBJ
(
        NAME VARCHAR2(256 BYTE) NOT NULL,
	ID   NUMBER NOT NULL,
        UNIQUE (NAME)
);

CREATE OR REPLACE VIEW SYS.V_X$KSWSASTAB as SELECT * FROM SYS.X$KSWSASTAB;

GRANT SELECT ON V_X$KSWSASTAB TO DBSFWUSER;

@?/rdbms/admin/sqlsessend.sql
