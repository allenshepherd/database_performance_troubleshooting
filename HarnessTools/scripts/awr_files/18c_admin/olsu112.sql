Rem
Rem $Header: rdbms/admin/olsu112.sql /main/26 2017/05/12 13:12:17 risgupta Exp $
Rem
Rem olsu112.sql
Rem
Rem Copyright (c) 2011, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      olsu112.sql - script to upgrade from 11.2
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/olsu112.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/olsu112.sql
Rem    SQL_PHASE: UPGRADE
Rem    SQL_STARTUP_MODE: UPGRADE
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    SQL_CALLING_FILE: rdbms/admin/olsdbmig.sql
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    risgupta    05/08/17 - Bug 26001269: Add SQL_FILE_METADATA
Rem    risgupta    11/18/15 - Bug 22162088: Use fully qualifed name while
Rem                           altering OLS tables
Rem    risgupta    06/04/15 - Bug 21133861: ols$prog changes to support
Rem                           long identifiers
Rem    risgupta    04/21/15 - Bug 20518167: Complete schema changes to
Rem                           support long identifiers.
Rem    risgupta    06/26/14 - Bug 19076927: Streamline OLS preupgrade with
Rem                           regular RDBMS upgrade
Rem    aramappa    09/25/13 - Bug 17512943: Remove REVOKEs on EXPDEPACT$ 
Rem                           and EXPDEPACT$. Move them to olsu121.sql
Rem    aramappa    07/29/13 - Bug 16593436: Invoke olsu121
Rem    risgupta    07/05/13 - Bug 16893700: Drop CDB_LBAC_* views & public 
Rem                           synonymns for DBA_LBAC_* views, Drop left out 
Rem                           11.2.0.4 public synonymns
Rem    aramappa    04/08/13 - Bug# 16593494,16593502,16593597,16593628: Remove
Rem                           GRANT ALL on EXPPKGACT$ and EXPDEPACT$. Grant
Rem                           only necessary privileges on EXPDEPACT$ to
Rem                           LBACSYS
Rem    aramappa    02/12/13 - bug 16317592: invoke olspreupgrade to move audit
Rem                           records if not moved before upgrade
Rem    risgupta    11/27/12 - Bug 14259254: Update OLS-OID status in props$
Rem    srtata      03/07/12 - bug 13779729: added mandatory OLS pre-upgrade
Rem    risgupta    03/26/12 - Bug 13887731: Fix possible sql injection attack
Rem    aramappa    02/29/12 - bug 13493870: schema changes to support long
Rem                           identifiers during upgrade
Rem    aramappa    02/24/12 - lrg 6626282:do not drop lbacsys.ols_init_session.
Rem                           drop lbacsys.create_fetch_profile
Rem    risgupta    02/16/12 - Bug 13529466: Move audit records from SYSTEM.AUD$
Rem                           to SYS.AUD$
Rem    jkati       02/08/12 - bug#9554465 : set the new invisible column bit
Rem                           KQLDCOP2_INVC for columns which are hidden
Rem    risgupta    12/19/11 - Logon Profile Changes: Add ols$profile table
Rem                           ols$profid_sequence, create ols profiles while
Rem                           populating ols$user table
Rem    risgupta    09/16/11 - Proj 31942: OLS Rearch - Code Cleanup
Rem    srtata      09/03/11 - rename lbac$pol to ols$pol
Rem    gclaborn    07/27/11 - Register LBACSYS types so they will get skipped
Rem    risgupta    07/23/11 - remove set commands added by ade
Rem    risgupta    07/12/11 - Add support for OLS audit tables
Rem    jheng       06/26/11 - Proj 32973: grant to lbacsys
Rem    srtata      06/27/11 - populate new tables
Rem    jkati       06/22/11 - grant execute on sys.dbms_zhelp to lbacsys
Rem    srtata      03/30/11 - upgrade from 11.2 to current release
Rem    srtata      03/30/11 - Created
Rem

GRANT EXECUTE ON SYS.DBMS_ZHELP TO LBACSYS;

-- Project 32973: grant to LBACSYS
GRANT EXECUTE ON dbms_priv_capture to LBACSYS;

-- rename lbac$pol
ALTER TABLE LBACSYS.lbac$pol DROP COLUMN bin_size;
ALTER TABLE LBACSYS.lbac$pol DROP COLUMN default_format;
ALTER TABLE LBACSYS.lbac$pol DROP COLUMN db_labels;
ALTER TABLE LBACSYS.lbac$pol DROP COLUMN policy_format;
ALTER TABLE LBACSYS.lbac$pol RENAME TO ols$pol;

-- rename lbac$polt;
ALTER TABLE LBACSYS.lbac$polt RENAME TO ols$polt;

-- rename lbac$pols;
ALTER TABLE LBACSYS.lbac$pols RENAME TO ols$pols;

CREATE TABLE LBACSYS.ols$profile (
   profid       NUMBER PRIMARY KEY,
   pol#         NUMBER
                REFERENCES LBACSYS.ols$pol (pol#) ON DELETE CASCADE,
   max_read     VARCHAR2(4000),
   max_write    VARCHAR2(4000),
   min_write    VARCHAR2(4000),
   def_read     VARCHAR2(4000),
   def_write    VARCHAR2(4000),
   def_row      VARCHAR2(4000),
   privs        NUMBER
);

CREATE TABLE LBACSYS.ols$user (
   pol#         NUMBER         NOT NULL
                REFERENCES LBACSYS.ols$pol (pol#) ON DELETE CASCADE,
   usr_name     VARCHAR2(1024) NOT NULL,
   profid       NUMBER         NOT NULL
                REFERENCES LBACSYS.ols$profile (profid) ON DELETE CASCADE,
   PRIMARY KEY  (pol#,usr_name));

CREATE TABLE LBACSYS.ols$prog (
   pol#         NUMBER NOT NULL
                REFERENCES LBACSYS.ols$pol (pol#) ON DELETE CASCADE,
   pgm_name     VARCHAR2(128) NOT NULL,
   owner        VARCHAR2(128) NOT NULL,
   privs        NUMBER,
   PRIMARY KEY (pol#,pgm_name,owner));

CREATE TABLE LBACSYS.ols$lab (
   tag#         NUMBER(10),
   pol#         NUMBER     NOT NULL,
   nlabel       NUMBER(10) NOT NULL,
   slabel       VARCHAR2(4000) NOT NULL,
   ilabel       VARCHAR2(4000) NOT NULL,
   flags        NUMBER NOT NULL,
   CONSTRAINT   ols_label_pk PRIMARY KEY(nlabel),
   CONSTRAINT   ols_label_policy_fk FOREIGN KEY (pol#)
                REFERENCES LBACSYS.ols$pol ON DELETE CASCADE);

CREATE SEQUENCE LBACSYS.ols$lab_sequence
   INCREMENT BY 1
   MINVALUE 1000000000
   MAXVALUE 4000000000
   CACHE 20
   ORDER;

CREATE SEQUENCE LBACSYS.ols$tag_sequence
   INCREMENT BY 1
   MINVALUE 1
   MAXVALUE 4000000000
   CACHE 20
   ORDER;

CREATE SEQUENCE LBACSYS.ols$profid_sequence
   INCREMENT BY 1
   MINVALUE 1
   MAXVALUE 4000000000
   CACHE 20
   ORDER;

-- rename sessinfo table
ALTER TABLE LBACSYS.sessinfo RENAME TO ols$sessinfo;

-- rename existing indexing when tables are renamed
ALTER INDEX LBACSYS.LBAC$POL_PFCPIDX RENAME TO OLS$POL_PFCPIDX;

ALTER INDEX LBACSYS.LBAC$POLT_OTFPIDX RENAME TO OLS$POLT_OTFPIDX;

ALTER INDEX LBACSYS.LBAC$POLS_OWNPOLIDX RENAME TO OLS$POLS_OWNPOLIDX;

ALTER INDEX LBACSYS.SESSINFO_IDX RENAME TO OLS$SESSINFO_IDX;

-- create new indexed for new tables
CREATE INDEX LBACSYS.i_ols$lab_1
ON LBACSYS.ols$lab(tag#);

CREATE INDEX LBACSYS.i_ols$lab_2
ON LBACSYS.ols$lab(ilabel,pol#);

-- generally views go in olsdbmig.sql , but these are needed by packages
CREATE OR REPLACE VIEW LBACSYS.ols$trusted_progs AS
  SELECT l.pol#, l.owner, l.pgm_name, l.privs,
         po.pol_name, po.package
  FROM LBACSYS.ols$prog l, LBACSYS.ols$pol po
  where l.pol#=po.pol#;

CREATE OR REPLACE VIEW LBACSYS.ols$policy_columns
   (owner, table_name, column_name, column_data_type)
AS
SELECT u.name, o.name,
       c.name,
       decode(c.type#, 2, decode(c.scale, null,
                                 decode(c.precision#, null, 'NUMBER'),
                                 'NUMBER'),
                       58, 'OPAQUE')
FROM sys.col$ c, sys.obj$ o, sys.user$ u,
     sys.coltype$ ac, sys.obj$ ot
WHERE o.obj# = c.obj#
  AND o.owner# = u.user#
  AND c.obj# = ac.obj#(+) AND c.intcol# = ac.intcol#(+)
  AND ac.toid = ot.oid$(+)
  AND ot.type#(+) = 13
  AND o.type# =  2;

delete from sys.impcalloutreg$ where tag = 'LABEL_SECURITY'
/

insert into sys.impcalloutreg$ (package, schema, tag, class, level#, flags,
                tgt_schema, tgt_object, tgt_type, cmnt) values
                ('OLS$DATAPUMP', 'LBACSYS', 'LABEL_SECURITY', 3, 1, 1,
                 'LBACSYS', 'LBAC$%', 2,'Oracle Label Security');

insert into sys.impcalloutreg$ (package, schema, tag, class, level#, flags,
                tgt_schema, tgt_object, tgt_type, cmnt) values
                ('OLS$DATAPUMP', 'LBACSYS', 'LABEL_SECURITY', 3, 2, 1,
                 'LBACSYS', 'SA$%', 2, 'Oracle Label Security');
insert into sys.impcalloutreg$ (package, schema, tag, class, level#, flags,
                tgt_schema, tgt_object, tgt_type, cmnt) values
                ('OLS$DATAPUMP', 'LBACSYS', 'LABEL_SECURITY', 3, 3, 1,
                 'LBACSYS', 'OLS$%', 2, 'Oracle Label Security');

-- In 11.2.0.3, type definitions upon which registered tables depend are 
-- incorrectly being exported. This causes problems for transportable network
-- imports. So, explicitly register LBACSYS types so that the 
-- instance_callout_imp() in pkg. OLS$DATAPUMP will return SKIP for these.
-- The exclude flag is also specified so they are not exported in 12.1 onwards.

insert into sys.impcalloutreg$ (package, schema, tag, class, level#, flags,
                tgt_schema, tgt_object, tgt_type, cmnt) values
                ('OLS$DATAPUMP', 'LBACSYS', 'LABEL_SECURITY', 3, 3, 1+8,
                 'LBACSYS', '%', 13, 'Oracle Label Security');
insert into sys.impcalloutreg$ (package, schema, tag, class, level#, flags,
                tgt_schema, tgt_object, tgt_type, cmnt) values
                ('OLS$DATAPUMP', 'LBACSYS', 'LABEL_SECURITY', 1, 1, 0,
                 '', '', 0, 'Oracle Label Security');

commit;

DROP PACKAGE LBACSYS.SA$CTX;
DROP PACKAGE LBACSYS.LBAC_LABEL_ADMIN;
DROP PACKAGE LBACSYS.LBAC_USER_ADMIN;
DROP PACKAGE LBACSYS.LBAC_COMPARE;
DROP PACKAGE LBACSYS.LBAC_AUDIT_ADMIN;

DROP FUNCTION LBACSYS.LBAC_STRICTLY_DOMINATED_BY;
DROP FUNCTION LBACSYS.LBAC_DOMINATED_BY;
DROP FUNCTION LBACSYS.LBAC_STRICTLY_DOMINATES;
DROP FUNCTION LBACSYS.LBAC_DOMINATES;
DROP FUNCTION LBACSYS.LBAC_LEAST_UBOUND;
DROP FUNCTION LBACSYS.LBAC_GREATEST_LBOUND;
DROP FUNCTION LBACSYS.LBAC_MERGE_LABEL;
DROP FUNCTION LBACSYS.FROM_BIN_LABEL;
DROP FUNCTION LBACSYS.TO_BIN_LABEL;
DROP FUNCTION LBACSYS.FROM_INTERNAL_LABEL;
DROP FUNCTION LBACSYS.TO_INTERNAL_LABEL;
DROP FUNCTION LBACSYS.TO_PRIVS;
DROP FUNCTION LBACSYS.LBAC_LABEL_TAGSEQ_TO_CHAR;
DROP FUNCTION LBACSYS.NUMERIC_LABEL_TAGSEQ_TO_CHAR;
DROP FUNCTION LBACSYS.LABEL_LIST_NAMED_CHAR;
DROP FUNCTION LBACSYS.LABEL_LIST_TO_CHAR;
DROP FUNCTION LBACSYS.LABEL_LIST_TO_NAMED_CHAR;
DROP FUNCTION LBACSYS.LABELNAMES_TO_CHAR;
DROP FUNCTION LBACSYS.BIN_TO_RAW;
DROP PROCEDURE LBACSYS.INIT_OLS_SESSION;

DROP VIEW LBACSYS.ALL_SA_AUDIT_OPTIONS;
DROP VIEW LBACSYS.DBA_SA_AUDIT_OPTIONS;
DROP VIEW LBACSYS.DBA_LBAC_AUDIT_OPTIONS;
DROP VIEW LBACSYS.DBA_LBAC_PROG_PRIVS;
DROP VIEW LBACSYS.DBA_LBAC_USER_PRIVS;
DROP VIEW LBACSYS.DBA_LBAC_PROG_LABELS;
DROP VIEW LBACSYS.DBA_LBAC_USER_LABELS;
DROP VIEW LBACSYS.DBA_LBAC_PROGRAMS;
DROP VIEW LBACSYS.DBA_LBAC_USERS;
DROP VIEW LBACSYS.LBAC$POLICY_COLUMNS;
DROP VIEW LBACSYS.LBAC$TRUSTED_PROGS;
DROP VIEW LBACSYS.LBAC$PACKAGE_FUNCTIONS;
DROP VIEW LBACSYS.LBAC$ALL_TABLE_POLICIES;
DROP VIEW LBACSYS.LBAC$USER_LOGON;

-- Remove left out 11.2.0.4 public synonyms
DROP PUBLIC SYNONYM LBAC_LABEL_ADMIN;
DROP PUBLIC SYNONYM LBAC_AUDIT_ADMIN;
DROP PUBLIC SYNONYM LBAC_USER_ADMIN;
DROP PUBLIC SYNONYM LABEL_LIST_TO_CHAR;
DROP PUBLIC SYNONYM LABEL_LIST_TO_NAMED_CHAR;
DROP PUBLIC SYNONYM DBA_LBAC_AUDIT_OPTIONS;
DROP PUBLIC SYNONYM DBA_LBAC_PROG_PRIVS;
DROP PUBLIC SYNONYM DBA_LBAC_USER_PRIVS;
DROP PUBLIC SYNONYM DBA_LBAC_PROG_LABELS;
DROP PUBLIC SYNONYM DBA_LBAC_USER_LABELS;
DROP PUBLIC SYNONYM DBA_LBAC_PROGRAMS;
DROP PUBLIC SYNONYM DBA_LBAC_USERS;

-- Bug 16893700: Drop CDB_LBAC_* views and public snynonyms for
-- the dropped DBA_LBAC_* views
ALTER SESSION SET "_ORACLE_SCRIPT" = TRUE;

DROP VIEW LBACSYS.CDB_LBAC_PROG_PRIVS;
DROP VIEW LBACSYS.CDB_LBAC_USER_PRIVS;
DROP VIEW LBACSYS.CDB_LBAC_PROG_LABELS;
DROP VIEW LBACSYS.CDB_LBAC_USER_LABELS;
DROP VIEW LBACSYS.CDB_LBAC_PROGRAMS;
DROP VIEW LBACSYS.CDB_LBAC_USERS;
DROP VIEW LBACSYS.CDB_LBAC_AUDIT_OPTIONS;

DROP PUBLIC SYNONYM CDB_LBAC_AUDIT_OPTIONS;
DROP PUBLIC SYNONYM CDB_LBAC_PROG_PRIVS;
DROP PUBLIC SYNONYM CDB_LBAC_USER_PRIVS;
DROP PUBLIC SYNONYM CDB_LBAC_PROG_LABELS;
DROP PUBLIC SYNONYM CDB_LBAC_USER_LABELS;
DROP PUBLIC SYNONYM CDB_LBAC_PROGRAMS;
DROP PUBLIC SYNONYM CDB_LBAC_USERS;

ALTER SESSION SET "_ORACLE_SCRIPT" = FALSE;

DROP TYPE LBACSYS.LBAC_COMPS;
DROP LIBRARY LBACSYS.LBAC$COMPS_LIBT;
DROP LIBRARY LBACSYS.SECURE_CONTEXT_LIB;

---populate new ols* tables from old lbac* tables
-- remove this later 
ALTER SESSION SET CURRENT_SCHEMA=LBACSYS;

--populate ols$levels
ALTER TABLE LBACSYS.sa$levels RENAME TO ols$levels;

--populate ols$compartments
ALTER TABLE LBACSYS.sa$compartments RENAME TO ols$compartments;

--populate ols$groups
ALTER TABLE LBACSYS.sa$groups RENAME TO ols$groups;

--populate ols$user_levels
ALTER TABLE LBACSYS.sa$user_levels RENAME TO ols$user_levels; 

--populate ols$user_compartments
ALTER TABLE LBACSYS.sa$user_compartments RENAME TO ols$user_compartments;

--populate ols$user_groups
ALTER TABLE LBACSYS.sa$user_groups RENAME TO ols$user_groups;

--populate ols$profiles
ALTER TABLE LBACSYS.sa$profiles MODIFY(POLICY_NAME VARCHAR2(128), 
                                       PROFILE_NAME VARCHAR2(128));
ALTER TABLE LBACSYS.sa$profiles RENAME TO ols$profiles;

--populate ols$dip_debug
ALTER TABLE LBACSYS.sa$dip_debug RENAME TO ols$dip_debug;

--populate ols$dip_events
ALTER TABLE LBACSYS.sa$dip_events RENAME TO ols$dip_events;

--populate ols$policy_admin
ALTER TABLE LBACSYS.lbac$policy_admin RENAME TO ols$policy_admin;

--populate ols$installations 
ALTER TABLE LBACSYS.lbac$installations RENAME TO ols$installations;

--populate ols$props
ALTER TABLE LBACSYS.lbac$props RENAME TO ols$props;

-- modify columns to support 128 bytes
ALTER TABLE LBACSYS.ols$pol  MODIFY column_name VARCHAR2(128);
ALTER TABLE LBACSYS.ols$pols MODIFY owner VARCHAR2(128);
ALTER TABLE LBACSYS.ols$polt MODIFY tbl_name VARCHAR2(128);
ALTER TABLE LBACSYS.ols$polt MODIFY owner VARCHAR2(128);

-- populate ols$user table 
-- Create Temporary function create_fetch_profile 
-- to populate ols$profile table.
CREATE OR REPLACE FUNCTION LBACSYS.create_fetch_profile
                    (pol_id        IN PLS_INTEGER,
                     max_rd_label  IN VARCHAR2,
                     max_wrt_label IN VARCHAR2,
                     min_wrt_label IN VARCHAR2,
                     read_label    IN VARCHAR2,
                     write_label   IN VARCHAR2,
                     row_label     IN VARCHAR2,
                     privilege     IN PLS_INTEGER)
RETURN PLS_INTEGER IS
prof_id PLS_INTEGER;
BEGIN

  -- Check whether row exists in ols$profile
  BEGIN
    -- If labels are NULL, use 'IS NULL' in where clause
    IF max_rd_label IS NULL THEN
      SELECT profid INTO prof_id FROM LBACSYS.ols$profile
        WHERE pol#      = pol_id
          AND max_read  IS NULL
          AND privs     = privilege;
    ELSE
      SELECT profid INTO prof_id FROM LBACSYS.ols$profile
        WHERE pol#      = pol_id
          AND max_read  = max_rd_label
          AND max_write = max_wrt_label
          AND min_write = min_wrt_label
          AND def_read  = read_label
          AND def_write = write_label
          AND def_row   = row_label
          AND privs     = privilege;
    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
-- No existing profile, create a new profile and return profid.
      INSERT into LBACSYS.ols$profile VALUES
        (LBACSYS.ols$profid_sequence.NEXTVAL, pol_id, max_rd_label,
         max_wrt_label, min_wrt_label, read_label,
         write_label, row_label, privilege)
      RETURNING profid INTO prof_id;
      COMMIT;
  END;

  RETURN prof_id;
END;
/

Declare 
  cursor cur is SELECT POL#, USR_NAME, LABELS, PRIVS 
                FROM LBACSYS.lbac$user;
  label                        LBACSYS.LBAC_LABEL;
  MAX_READ                     VARCHAR2(4000);
  MAX_WRITE                    VARCHAR2(4000);
  MIN_WRITE                    VARCHAR2(4000);
  DEF_READ                     VARCHAR2(4000);
  DEF_WRITE                    VARCHAR2(4000);
  DEF_ROW                      VARCHAR2(4000);
  profile_access_priv CONSTANT PLS_INTEGER :=1;
  full_priv           CONSTANT PLS_INTEGER :=2;
  read_priv           CONSTANT PLS_INTEGER :=3;
  writeup_priv        CONSTANT PLS_INTEGER :=4;
  writedown_priv      CONSTANT PLS_INTEGER :=5;
  writeacross_priv    CONSTANT PLS_INTEGER :=6;
  compaccess_priv     CONSTANT PLS_INTEGER :=7;

  profile_access     CONSTANT PLS_INTEGER := 1;
  full_access        CONSTANT PLS_INTEGER := 2;
  read_access        CONSTANT PLS_INTEGER := 4;
  writeup_access     CONSTANT PLS_INTEGER := 8;
  writedown_access   CONSTANT PLS_INTEGER := 16;
  writeacross_access CONSTANT PLS_INTEGER := 32;
  comp_access        CONSTANT PLS_INTEGER := 64;
  usrprivs                    PLS_INTEGER := 0;
  
  profid                      PLS_INTEGER;
BEGIN 
  FOR erow IN cur LOOP 
    IF erow.LABELS IS NOT NULL THEN 

      label := erow.LABELS.get(1); 
      SELECT ILABEL INTO MAX_READ FROM LBACSYS.LBAC$LAB WHERE
                                         NLABEL=label.to_tag;
      
      label := erow.LABELS.get(2); 
      SELECT ILABEL INTO MAX_WRITE FROM LBACSYS.LBAC$LAB WHERE
                                         NLABEL=label.to_tag;
      
      label := erow.LABELS.get(3); 
      SELECT ILABEL INTO MIN_WRITE FROM LBACSYS.LBAC$LAB WHERE
                                         NLABEL=label.to_tag;

      label := erow.LABELS.get(4); 
      SELECT ILABEL INTO DEF_READ FROM LBACSYS.LBAC$LAB WHERE
                                         NLABEL=label.to_tag;

      label := erow.LABELS.get(5); 
      SELECT ILABEL INTO DEF_WRITE FROM LBACSYS.LBAC$LAB WHERE
                                         NLABEL=label.to_tag;

      label := erow.LABELS.get(6); 
      SELECT ILABEL INTO DEF_ROW FROM LBACSYS.LBAC$LAB WHERE
                                         NLABEL=label.to_tag;

    END IF; -- label list not null 
    IF erow.privs IS NOT NULL THEN 
      
      IF erow.privs.test_priv(profile_access_priv) THEN 
        usrprivs := usrprivs + profile_access;
      END IF;
      IF erow.privs.test_priv(full_priv) THEN 
        usrprivs := usrprivs + full_access;
      END IF;
      IF erow.privs.test_priv(read_priv) THEN 
        usrprivs := usrprivs + read_access;
      END IF;
      IF erow.privs.test_priv(writeup_priv) THEN 
        usrprivs := usrprivs + writeup_access;
      END IF;
      IF erow.privs.test_priv(writedown_priv) THEN
        usrprivs := usrprivs + writedown_access;
      END IF;
      IF erow.privs.test_priv(writeacross_priv) THEN 
        usrprivs := usrprivs + writeacross_access;
      END IF;
      IF erow.privs.test_priv(compaccess_priv) THEN 
        usrprivs := usrprivs + comp_access;
      END IF;
    END IF; -- privs not null 

    profid := LBACSYS.create_fetch_profile(erow.pol#, MAX_READ, MAX_WRITE,
                                           MIN_WRITE, DEF_READ, DEF_WRITE,
                                           DEF_ROW, usrprivs);

    INSERT INTO LBACSYS.ols$user VALUES
      (erow.pol#, erow.usr_name, profid);

    usrprivs := 0;
    MAX_READ := NULL;
    MAX_WRITE := NULL;
    MIN_WRITE := NULL;
    DEF_READ := NULL;
    DEF_WRITE := NULL;
    DEF_ROW := NULL;
  
  END LOOP;  
  COMMIT;
EXCEPTION 
  WHEN OTHERS THEN 
  RAISE;
END;
/

-- drop helper function created during upgrade
DROP FUNCTION LBACSYS.create_fetch_profile;

--populate ols$prog
declare 
  cursor cur is SELECT POL#, PGM_NAME, OWNER, PRIVS 
                FROM LBACSYS.lbac$prog;
  profile_access_priv CONSTANT PLS_INTEGER :=1;
  full_priv           CONSTANT PLS_INTEGER :=2;
  read_priv           CONSTANT PLS_INTEGER :=3;
  writeup_priv        CONSTANT PLS_INTEGER :=4;
  writedown_priv      CONSTANT PLS_INTEGER :=5;
  writeacross_priv    CONSTANT PLS_INTEGER :=6;
  compaccess_priv     CONSTANT PLS_INTEGER :=7;

  profile_access     CONSTANT PLS_INTEGER := 1;
  full_access        CONSTANT PLS_INTEGER := 2;
  read_access        CONSTANT PLS_INTEGER := 4;
  writeup_access     CONSTANT PLS_INTEGER := 8;
  writedown_access   CONSTANT PLS_INTEGER := 16;
  writeacross_access CONSTANT PLS_INTEGER := 32;
  comp_access        CONSTANT PLS_INTEGER := 64;
  usrprivs                    PLS_INTEGER := 0;
                
BEGIN
  FOR erow IN cur LOOP 
    IF erow.privs IS NOT NULL THEN 
      
      IF erow.privs.test_priv(profile_access_priv) THEN 
        usrprivs := usrprivs + profile_access;
      END IF;
      IF erow.privs.test_priv(full_priv) THEN 
        usrprivs := usrprivs + full_access;
      END IF;
      IF erow.privs.test_priv(read_priv) THEN 
        usrprivs := usrprivs + read_access;
      END IF;
      IF erow.privs.test_priv(writeup_priv) THEN 
        usrprivs := usrprivs + writeup_access;
      END IF;
      IF erow.privs.test_priv(writedown_priv) THEN
        usrprivs := usrprivs + writedown_access;
      END IF;
      IF erow.privs.test_priv(writeacross_priv) THEN 
        usrprivs := usrprivs + writeacross_access;
      END IF;
      IF erow.privs.test_priv(compaccess_priv) THEN 
        usrprivs := usrprivs + comp_access;
      END IF;
    END IF; -- privs not null 

    INSERT INTO LBACSYS.ols$prog VALUES
         (erow.pol#, erow.pgm_name, erow.owner, usrprivs);
    END LOOP;  
    COMMIT;
EXCEPTION 
  WHEN OTHERS THEN 
  RAISE;
END;
/

-- populate ols$lab
declare 
  cursor cur is SELECT TAG#,POL#, NLABEL, SLABEL, ILABEL, FLAGS
                FROM LBACSYS.lbac$lab;
BEGIN
  FOR erow IN cur LOOP 
    INSERT INTO LBACSYS.ols$lab VALUES
     (erow.tag#, erow.pol#, erow.nlabel, erow.slabel,
      erow.ilabel, erow.flags);
  END LOOP;  
  COMMIT;
EXCEPTION 
  WHEN OTHERS THEN 
  RAISE;
END;
/

-- bug#9554465 : set the new invisible column bit - KQLDCOP2_INVC
-- for tables with their columns as HIDDEN
declare 
  cursor cur is SELECT ob.obj# , p.column_name FROM 
  lbacsys.ols$polt  pt, lbacsys.ols$pol p, sys.obj$ ob, sys.user$ u WHERE 
  bitand(pt.options,128)=128 and ob.owner# = u.user# and  
  pt.tbl_name=ob.name and p.pol# = pt.pol# and pt.owner=u.name;
  objnum NUMBER;
  colname VARCHAR2(128);
BEGIN
  FOR erow IN cur LOOP 
    objnum := erow.obj#;
    colname := erow.column_name;
    UPDATE sys.col$ set property = property+17179869184 
    WHERE name=colname and obj#=objnum;
  END LOOP;  
  COMMIT;
EXCEPTION 
  WHEN OTHERS THEN 
  RAISE;
END;
/

--populate ols$audit_actions
ALTER TABLE LBACSYS.lbac_audit_actions RENAME TO ols$audit_actions;

--populate ols$audit
ALTER TABLE LBACSYS.lbac$audit RENAME TO ols$audit;

-- Bug 20518167: modify left columns to support 128 bytes
ALTER TABLE LBACSYS.ols$policy_admin MODIFY policy_name VARCHAR2(128);
ALTER TABLE LBACSYS.ols$props MODIFY name VARCHAR2(128);
ALTER TABLE LBACSYS.ols$audit MODIFY usr_name VARCHAR2(128);

-- Bug 21133861: modify left columns to support 128 bytes
ALTER TABLE LBACSYS.ols$prog MODIFY pgm_name VARCHAR2(128);
ALTER TABLE LBACSYS.ols$prog MODIFY owner VARCHAR2(128);

TRUNCATE TABLE LBACSYS.LBAC$LAB;
TRUNCATE TABLE LBACSYS.LBAC$USER;
TRUNCATE TABLE LBACSYS.LBAC$PROG;

show errors;

ALTER SESSION SET CURRENT_SCHEMA=SYS;

-- Bug 14259254: Update OLS-OID status in props$ table.
declare
value VARCHAR2(255);
BEGIN
  SELECT value$ INTO value FROM LBACSYS.ols$props
  WHERE name = 'OID_STATUS_FLAG';

  INSERT INTO SYS.props$ values ('OLS_OID_STATUS', value, 
                                 'OLS OID Status used for Label Security');
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE;
END;
/

-- Invoke olsu121 for upgrade from 12.1.0.1 to the latest version 
@@olsu121.sql
