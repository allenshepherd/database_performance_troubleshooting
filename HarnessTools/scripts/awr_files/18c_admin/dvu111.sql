Rem
Rem $Header: rdbms/admin/dvu111.sql /main/24 2017/05/28 22:45:57 stanaya Exp $
Rem
Rem dvu111.sql
Rem
Rem Copyright (c) 2008, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dvu111.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/dvu111.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/dvu111.sql
Rem    SQL_PHASE: UPGRADE
Rem    SQL_STARTUP_MODE: UPGRADE
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    END SQL_FILE_METADATA
Rem    
Rem    MODIFIED   (MM/DD/YY)
Rem    namoham     06/02/15 - Bug 20216779: remove catmacc, catmacd statements 
Rem    jheng       05/13/09 - grant SYS job authorization on EXFSYS schema
Rem    ruparame    03/30/09 - Bug 8393717 Change the datapump rule set name to
Rem                           Allow Oracle Data Pump Operation
Rem    youyang     03/27/09 - Bug 8385541: to qualify session_roles
Rem    youyang     02/16/09 - Bug8212399: ignore unique constraint error
Rem    jheng       02/17/09 - add DV Job rule set
Rem    ruparame    02/05/09 - Bug 8211922 remove sync_rules
Rem    ruparame    01/20/09 - LRG 3772496
Rem    prramakr    01/15/09 - Bug7711393: create dvlang function and related
Rem                           views
Rem    srtata      12/29/08 - add ruleset view: static ruleset implmentation
Rem    jibyun      12/22/08 - Bug 7656640: Add DV_STREAMS_ADMIN role to
Rem                           Database Vault after creation
Rem    youyang     11/14/08 - remove DDL triggers and set owners of roles to "%"
Rem    clei        12/10/08 - DV_PATCH -> DV_PATCH_ADMIN
Rem    jibyun      10/23/08 - Bug 7550987: Add dv_streams_admin role
Rem    jibyun      10/20/08 - Bug 7489862: Add admin option to the grants of
Rem                           dv_admin, dv_secanalyst, and dv_public to
Rem                           dv_owner
Rem    ssonawan    10/14/08 - bug 6938843: Add rules for alter system command
Rem    jheng       10/06/08 - remove default command rules "GRANT" & "REVOKE"
Rem    ruparame    08/25/08 - Bug 7319691: Create DV_MONITOR role
Rem    clei        08/20/08 - bug 6435192: add DVSYS.CONFIG$ and dv_patch
Rem    pknaggs     07/29/08 - bug 6938028: Database Vault Protected Schema.
Rem    vigaur      04/16/08 - Created
Rem

Rem Please add any metadata upgrade changes below this point.
Rem Note: remember to alter the session to set the current schema 
Rem correctly, before adding any SQL commands.

ALTER SESSION SET CURRENT_SCHEMA = DVSYS;

Rem Create table to store DV enforcement status

BEGIN
EXECUTE IMMEDIATE 'create table dvsys.config$ (status number unique)';
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00955) THEN NULL; --object has already been created
     ELSE RAISE;
     END IF;

END;
/

DECLARE
NUM NUMBER;

BEGIN
SELECT COUNT(*) INTO NUM FROM DVSYS.CONFIG$;
IF NUM = 0 THEN
EXECUTE IMMEDIATE 'insert into dvsys.config$ (status) values (1)';
 END IF;
  EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
     ELSE RAISE;
     END IF;
END;
/

Rem create table to store DV Job Authrization metadata

CREATE TABLE DVSYS.DV_AUTH$
(
  GRANT_TYPE  VARCHAR2 (19) NOT NULL,
  GRANTEE VARCHAR2 (30) NOT NULL,
  OBJECT_OWNER VARCHAR2 (30),
  OBJECT_NAME VARCHAR2 (128),
  OBJECT_TYPE VARCHAR2 (19)
);

commit;

------------------------------------------------------------------
-- Drop before and after DDL triggers.
------------------------------------------------------------------
drop trigger dvsys.dv_before_ddl_trg;
drop trigger dvsys.dv_after_ddl_trg;

------------------------------------------------------------------
-- Update roles' owners to % (not a wildcard) if they are protected in realm.
-- Roles do not have owners.
------------------------------------------------------------------
update DVSYS.realm_object$
set owner = '%'
where object_type = 'ROLE';

----------------------------------------------------------------------
-- Drop stand-alone procedures removed after DDL DV code is moved to C
----------------------------------------------------------------------
drop procedure dvsys.authorize_event;

-- Bug 7449805: remove VPD related command rules "grant" and "revoke"
delete from dvsys.command_rule$ where RULE_SET_ID# = 6 and (ID# = 8 or ID# = 9);

ALTER SESSION SET CURRENT_SCHEMA = SYS;

-- Bug 7657506
-- Protect the ALTER SYSTEM command with the new rule set
-- 'Allow Fine Grained Control of System Parameters'
-- Retain all the old rules and rule set

update DVSYS.command_rule$ set RULE_SET_ID# = 9 where ID# = 10;

-- Call dvu112.sql for upgrade from 11.2 to 12
@@dvu112.sql


commit;
