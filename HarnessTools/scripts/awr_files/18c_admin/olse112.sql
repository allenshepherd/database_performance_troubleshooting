Rem
Rem $Header: rdbms/admin/olse112.sql /main/27 2017/05/12 13:12:17 risgupta Exp $
Rem
Rem olse112.sql
Rem
Rem Copyright (c) 2011, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      olse112.sql - Oracle Label Security Downgrade  to 11.2
Rem
Rem    DESCRIPTION
Rem      This downgrade script is executed to downgrade to 11.2  OLS schema
Rem
Rem    NOTES
Rem      
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/olse112.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/olse112.sql
Rem    SQL_PHASE: DOWNGRADE
Rem    SQL_STARTUP_MODE: DOWNGRADE
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    SQL_CALLING_FILE: rdbms/admin/olsdwgrd.sql
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    risgupta    05/08/17 - Bug 26001269: Add SQL_FILE_METADATA
Rem    anupkk      05/11/16 - Bug 23264000: Unset label function bit
Rem    risgupta    11/27/15 - Bug 22267756: Set current schema to LBACSYS
Rem    risgupta    11/18/15 - Bug 22162088: Use fully qualifed name while
Rem                           altering OLS tables
Rem    risgupta    06/04/15 - Bug 21133861: resize columns in ols$prog to 30
Rem    risgupta    04/21/15 - Bug 20518167: resize left columns to 30
Rem    risgupta    03/16/15 - LRG 14680081: Make the policy columns in
Rem                           SYSTEM.PREDWG_AUD$ invisible after all records 
Rem                           are transferred
Rem    risgupta    01/27/15 - Bug 20402799: Drop public synonyms
Rem    jkati       09/20/13 - bug#16904811 : fix sequences to start with latest
Rem                           values to avoid unique constraint errors
Rem    aramappa    07/29/13 - bug 16593436: Add olse121
Rem    risgupta    11/27/12 - Bug 14259254: remove OLS-OID status from props$
Rem    aramappa    08/20/12 - bug 14506465: set_priv must be invoked for all
Rem                           privileges set for the user
Rem    srtata      06/11/12 - bug 14175223: drop new 12.1 functions
Rem    jkati       05/28/12 - bug#14002092 : revoke inherit any privileges from
Rem                           lbacsys
Rem    aramappa    05/21/12 - bug 13921755: drop procedure feature_usage
Rem    srtata      03/07/12 - bug 13779729 :added mandatory OLS pre-downgrade
Rem    risgupta    03/26/12 - Bug 13887714: Fix possible sql injection attack
Rem    aramappa    03/20/12 - bug 13493870: schema changes to resize columns
Rem    aramappa    02/24/12 - lrg 6626282: Rename indexes, drop
Rem                           procedure,synonym, views and packages specific to
Rem                           12.1
Rem    risgupta    02/16/12 - Bug 13529466: Move audit records from SYS.AUD$ to
Rem                           SYSTEM.AUD$
Rem    jkati       02/08/12 - bug#9554465 : clear the new invisible column bit
Rem                           KQLDCOP2_INVC for columns which are hidden
Rem    risgupta    12/19/11 - Logon Profile Changes: Use both ols$user and
Rem                           ols$profile table for populating lbac$user,
Rem                           remove profile table & profile id sequence
Rem    jkati       10/27/11 - lrg-5980693: correctly populate lbac$pol table
Rem                           during downgrade
Rem    srtata      09/03/11 - rename lbac$pol to ols$pol
Rem    risgupta    07/23/11 - remove set commands added by ade
Rem    risgupta    07/12/11 - Add support for OLS audit tables
Rem    srtata      06/30/11 - populate the old tables for downgrade
Rem    srtata      03/30/11 - downgrade to 11.2
Rem    srtata      03/30/11 - Created
Rem

EXECUTE DBMS_REGISTRY.DOWNGRADING('OLS');

-- bug 16593436: Add olse121 to downgrade to 12.1.0.1
@@olse121.sql

ALTER SESSION SET CURRENT_SCHEMA=LBACSYS;

-- resize columns to 30 bytes
ALTER TABLE LBACSYS.ols$pol  MODIFY column_name VARCHAR2(30);
ALTER TABLE LBACSYS.ols$pols MODIFY owner VARCHAR2(30);
ALTER TABLE LBACSYS.ols$polt MODIFY tbl_name VARCHAR2(30);
ALTER TABLE LBACSYS.ols$polt MODIFY owner VARCHAR2(30);

-- Bug 20518167: resize left columns to support 30 bytes
ALTER TABLE LBACSYS.ols$props MODIFY name VARCHAR2(30); 
ALTER TABLE LBACSYS.ols$audit MODIFY usr_name VARCHAR2(30); 

-- Bug 21133861: resize left columns to support 30 bytes
ALTER TABLE LBACSYS.ols$prog MODIFY pgm_name VARCHAR2(30);
ALTER TABLE LBACSYS.ols$prog MODIFY owner VARCHAR2(30);

ALTER TABLE LBACSYS.ols$pol RENAME TO lbac$pol;
ALTER TABLE LBACSYS.lbac$pol ADD (policy_format VARCHAR2(30));
ALTER TABLE LBACSYS.lbac$pol ADD (db_labels  LBACSYS.lbac_label_list);
ALTER TABLE LBACSYS.lbac$pol ADD (default_format VARCHAR2(30));
ALTER TABLE LBACSYS.lbac$pol ADD (bin_size NUMBER);
UPDATE LBACSYS.lbac$pol SET bin_size=0;
ALTER TABLE LBACSYS.lbac$pol MODIFY bin_size NOT NULL;


ALTER TABLE LBACSYS.ols$polt RENAME TO lbac$polt;
ALTER TABLE LBACSYS.ols$pols RENAME TO lbac$pols;

--populate sa$levels
ALTER TABLE LBACSYS.ols$levels RENAME TO sa$levels;

--populate sa$compartments
ALTER TABLE LBACSYS.ols$compartments RENAME TO sa$compartments;

--populate sa$groups
ALTER TABLE LBACSYS.ols$groups RENAME TO sa$groups;

--populate sa$user_levels
ALTER TABLE LBACSYS.ols$user_levels RENAME TO sa$user_levels;

--populate sa$user_compartments
ALTER TABLE LBACSYS.ols$user_compartments RENAME TO sa$user_compartments;

--populate sa$user_groups
ALTER TABLE LBACSYS.ols$user_groups RENAME TO sa$user_groups;

--populate sa$profiles
ALTER TABLE LBACSYS.ols$profiles MODIFY(POLICY_NAME VARCHAR2(30),
                                     PROFILE_NAME VARCHAR2(30));   
ALTER TABLE LBACSYS.ols$profiles RENAME TO sa$profiles;

--populate sa$dip_debug
ALTER TABLE LBACSYS.ols$dip_debug RENAME TO sa$dip_debug;

--populate sa$dip_events
ALTER TABLE LBACSYS.ols$dip_events RENAME TO sa$dip_events;

--populate lbac$policy_admin
ALTER TABLE LBACSYS.ols$policy_admin MODIFY(POLICY_NAME VARCHAR2(30));
ALTER TABLE LBACSYS.ols$policy_admin RENAME TO lbac$policy_admin;

--populate lbac$installations
ALTER TABLE LBACSYS.ols$installations RENAME TO lbac$installations;

--populate lbac$props
ALTER TABLE LBACSYS.ols$props RENAME TO lbac$props;

--rename sessinfo table
ALTER TABLE LBACSYS.ols$sessinfo RENAME TO sessinfo;

-- Drop views
DROP VIEW LBACSYS.dba_ols_users;
DROP VIEW LBACSYS.dba_ols_status;
DROP VIEW LBACSYS.dba_ols_audit_options;
-- olsrelod.sql creates the lbac$trusted_progs view
-- in the downgraded database
DROP VIEW LBACSYS.ols$trusted_progs;

-- drop packages
DROP PACKAGE LBACSYS.ols_enforcement;
DROP PACKAGE LBACSYS.ols$datapump;
-- olsrelod.sql creates the lbac_audit_admin package and
-- the sa_audit_admin synonym in the downgraded database
DROP PACKAGE LBACSYS.sa_audit_admin;

-- drop procedures
DROP PROCEDURE LBACSYS.configure_ols;
DROP PROCEDURE LBACSYS.feature_usage;

 -- Rename indexes
ALTER INDEX LBACSYS.ols$pol_pfcpidx    RENAME TO lbac$pol_pfcpidx;
ALTER INDEX LBACSYS.ols$polt_otfpidx   RENAME TO lbac$polt_otfpidx;
ALTER INDEX LBACSYS.ols$pols_ownpolidx RENAME TO lbac$pols_ownpolidx;
ALTER INDEX LBACSYS.ols$sessinfo_idx   RENAME TO sessinfo_idx;

--populate lbac$lab
declare
   cursor cur is SELECT TAG#,POL#, NLABEL, SLABEL, ILABEL, FLAGS
                 FROM LBACSYS.ols$lab;   
   label         LBACSYS.lbac_label := NULL;
   blabel        LBACSYS.lbac_bin_label := NULL;
BEGIN
  FOR erow IN cur LOOP
    label := LBACSYS.lbac_label.new_lbac_label(erow.nlabel);
    -- Can be normal insert instead of execute immediate
    INSERT INTO LBACSYS.lbac$lab VALUES
    (erow.tag#, label, erow.pol#, erow.nlabel, blabel, erow.slabel,
     erow.ilabel, erow.flags);

  END LOOP;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
  RAISE;
END;
/

--populate lbac$user
Declare
  cursor cur is SELECT U.POL#, USR_NAME, MAX_READ, MAX_WRITE, 
                       MIN_WRITE, DEF_READ, DEF_WRITE, DEF_ROW,
                       PRIVS FROM LBACSYS.ols$user u, LBACSYS.ols$profile p
                       WHERE u.pol# = p.pol# AND u.profid = p.profid;
  nlabel              NUMBER(10);
  maxr_label          LBACSYS.lbac_label := NULL;
  maxw_label          LBACSYS.lbac_label := NULL;
  minw_label          LBACSYS.lbac_label := NULL;
  defr_label          LBACSYS.lbac_label := NULL;
  defw_label          LBACSYS.lbac_label := NULL;
  row_label           LBACSYS.lbac_label := NULL;
  label_list          LBACSYS.lbac_label_list := NULL;
  privs               LBACSYS.lbac_privs;
  savlabels           LBACSYS.lbac_label_list := NULL;
  savprivs            LBACSYS.lbac_privs := NULL;
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

BEGIN
  FOR erow IN cur LOOP
    IF erow.MAX_READ IS NOT NULL THEN
      
      SELECT NLABEL INTO nlabel FROM LBACSYS.ols$lab WHERE 
                                           ILABEL=erow.MAX_READ;
      maxr_label := LBACSYS.lbac_label.new_lbac_label(nlabel);

      SELECT NLABEL INTO nlabel FROM LBACSYS.ols$lab WHERE 
                                           ILABEL=erow.MAX_WRITE;
      maxw_label := LBACSYS.lbac_label.new_lbac_label(nlabel);

      SELECT NLABEL INTO nlabel FROM LBACSYS.ols$lab WHERE 
                                           ILABEL=erow.MIN_WRITE;
      minw_label := LBACSYS.lbac_label.new_lbac_label(nlabel);

      SELECT NLABEL INTO nlabel FROM LBACSYS.ols$lab WHERE 
                                           ILABEL=erow.DEF_READ;
      defr_label := LBACSYS.lbac_label.new_lbac_label(nlabel);
      
      SELECT NLABEL INTO nlabel FROM LBACSYS.ols$lab WHERE 
                                           ILABEL=erow.DEF_WRITE;
      defw_label := LBACSYS.lbac_label.new_lbac_label(nlabel);

      SELECT NLABEL INTO nlabel FROM LBACSYS.ols$lab WHERE 
                                           ILABEL=erow.DEF_ROW;
      row_label := LBACSYS.lbac_label.new_lbac_label(nlabel);

      label_list := LBACSYS.to_label_list.from_label(erow.pol#,
                  maxr_label, maxw_label, minw_label, defr_label,
                                          defw_label, row_label);
    END IF;

    -- create the privs opaque type
    privs := LBACSYS.lbac_privs.new_lbac_privs(erow.pol#);

    -- invoke set_priv after checking each possible privilege
    IF bitand(erow.privs, profile_access) = profile_access THEN
      privs.set_priv(profile_access_priv);
    END IF;

    IF bitand(erow.privs, full_access) = full_access THEN
      privs.set_priv(full_priv);
    END IF;

    IF bitand(erow.privs, read_access) = read_access THEN
      privs.set_priv(read_priv);
    END IF;

    IF bitand(erow.privs, writeup_access) = writeup_access THEN
      privs.set_priv(writeup_priv);
    END IF;

    IF bitand(erow.privs, writedown_access) = writedown_access THEN
      privs.set_priv(writedown_priv);
    END IF;

    IF bitand(erow.privs, writeacross_access) = writeacross_access THEN
      privs.set_priv(writeacross_priv);
    END IF;

    IF bitand(erow.privs, comp_access) = comp_access THEN
      privs.set_priv(compaccess_priv);
    END IF;  
    
    INSERT INTO LBACSYS.lbac$user VALUES
     (erow.pol#, erow.usr_name, label_list, privs, savlabels, savprivs);
  END LOOP;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
  RAISE;
END;
/

--populate lbac$prog
Declare
  cursor cur is SELECT POL#, PGM_NAME, OWNER, PRIVS 
                       FROM LBACSYS.ols$prog;
  privs               LBACSYS.lbac_privs;
  label               LBACSYS.lbac_label_list := NULL;
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

BEGIN
  FOR erow IN cur LOOP
    privs := LBACSYS.lbac_privs.new_lbac_privs(erow.pol#);

    IF bitand(erow.privs, profile_access) = profile_access THEN
      privs.set_priv(profile_access_priv);
    END IF;

    IF bitand(erow.privs, full_access) = full_access THEN
      privs.set_priv(full_priv);
    END IF;

    IF bitand(erow.privs, read_access) = read_access THEN
      privs.set_priv(read_priv);
    END IF;

    IF bitand(erow.privs, writeup_access) = writeup_access THEN
      privs.set_priv(writeup_priv);
    END IF;

    IF bitand(erow.privs, writedown_access) = writedown_access THEN
      privs.set_priv(writedown_priv);
    END IF;
 
    IF bitand(erow.privs, writeacross_access) = writeacross_access THEN
      privs.set_priv(writeacross_priv);
    END IF;

    IF bitand(erow.privs, comp_access) = comp_access THEN
      privs.set_priv(compaccess_priv);
    END IF;  
    
    INSERT INTO LBACSYS.lbac$prog VALUES (erow.pol#, erow.pgm_name,
          erow.owner, label, privs);
  END LOOP;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
  RAISE;
END;
/

-- bug#9554465 : clear the new invisible column bit - KQLDCOP2_INVC
-- for tables with their columns as HIDDEN
declare
  cursor cur is SELECT ob.obj# , p.column_name FROM
  lbacsys.lbac$polt  pt, lbacsys.lbac$pol p, sys.obj$ ob, sys.user$ u WHERE
  bitand(pt.options,128)=128 and ob.owner# = u.user# and
  pt.tbl_name=ob.name and p.pol# = pt.pol# and pt.owner=u.name;
  objnum NUMBER;
  colname VARCHAR2(128);
BEGIN
  FOR erow IN cur LOOP
    objnum := erow.obj#;
    colname := erow.column_name;
    UPDATE sys.col$ set property = property-17179869184
    WHERE name=colname and obj#=objnum;
  END LOOP;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
  RAISE;
END;
/

-- bug#16904811 : fix sequences to start with latest values
declare 
  nl_seqmax NUMBER :=0;
  tn_seqmax NUMBER :=0;
  curseqval NUMBER :=0;
  seqdiff   NUMBER :=0;
BEGIN
  -- select the max nlabel among the dynamic labels
  SELECT MAX(nlabel) INTO nl_seqmax FROM LBACSYS.lbac$lab 
   WHERE nlabel > 99999999;
  IF nl_seqmax > 0
  THEN
    -- select the current sequence value
    SELECT LBACSYS.lbac$lab_sequence.NEXTVAL into curseqval FROM DUAL;
    seqdiff := nl_seqmax - curseqval;
    IF seqdiff > 0
    THEN
      EXECUTE IMMEDIATE 'ALTER SEQUENCE LBACSYS.lbac$lab_sequence INCREMENT BY '
                                                                     || seqdiff;
      EXECUTE IMMEDIATE 'SELECT LBACSYS.lbac$lab_sequence.NEXTVAL FROM DUAL'
                                                            INTO curseqval;
      EXECUTE IMMEDIATE 'ALTER SEQUENCE LBACSYS.lbac$lab_sequence 
                                                 INCREMENT BY 1';
    END IF; -- seqdiff > 0                                             
  END IF;   -- nl_seqmax > 0

  -- select the max tag#
  SELECT MAX(tag#) INTO tn_seqmax FROM LBACSYS.lbac$lab;
  IF tn_seqmax > 0
  THEN
    -- select the current sequence value
    SELECT LBACSYS.lbac$tag_sequence.nextval INTO curseqval FROM DUAL;
    seqdiff := tn_seqmax - curseqval;
    IF seqdiff > 0
    THEN
      EXECUTE IMMEDIATE 'ALTER SEQUENCE LBACSYS.lbac$tag_sequence INCREMENT BY '
                                                                     || seqdiff;
      EXECUTE IMMEDIATE 'SELECT LBACSYS.lbac$tag_sequence.NEXTVAL FROM DUAL'
                                                    INTO curseqval;
      EXECUTE IMMEDIATE 'ALTER SEQUENCE LBACSYS.lbac$tag_sequence 
                                                 INCREMENT BY 1';
    END IF; -- seqdiff > 0                                             
  END IF;   -- tn_seqmax > 0
END;
/

-- drop the tables as opposed to truncate because many tables have 
-- foriegn key constraints and truncate does not work unless 
-- constraints are disabled.

DROP TABLE LBACSYS.ols$user;

DROP TABLE LBACSYS.ols$prog;

DROP TABLE LBACSYS.ols$lab;

DROP TABLE LBACSYS.ols$profile;

DROP SEQUENCE LBACSYS.ols$lab_sequence;

DROP SEQUENCE LBACSYS.ols$tag_sequence;

DROP SEQUENCE LBACSYS.ols$profid_sequence;

--populate lbac$audit_actions
ALTER TABLE LBACSYS.ols$audit_actions RENAME TO lbac_audit_actions;

--populate lbac$audit
ALTER TABLE LBACSYS.ols$audit RENAME TO lbac$audit;

-- Move Audit Records from SYS.AUD$ to SYSTEM.AUD$
ALTER SESSION SET CURRENT_SCHEMA = SYS;

-- Create a utility procedure to move audit records to SYSTEM.aud$ table
CREATE OR REPLACE PROCEDURE populate_aud(col_str      VARCHAR2,
                                         orignal_rows NUMBER)
AS
counter      NUMBER := 0;
nrows        NUMBER := 0;
npol         NUMBER := 0;

type ctyp is ref cursor;

rowid_cur ctyp;
rowid_tab dbms_sql.urowid_table;
BEGIN
  -- populate SYSTEM.aud$ with the rows from SYS.aud$
  -- delete the processed rows in SYS.aud$
  nrows := orignal_rows;

  counter := ceil(nrows/1000000);
  LOOP
    OPEN rowid_cur FOR 'select rowid from SYS.aud$' ||
                       ' where rownum <= 1000000';

    -- Fetch 1st 100000 rows
    FETCH rowid_cur bulk collect into rowid_tab limit 100000;

    -- Exit, if no rows
    IF (rowid_tab.count = 0) THEN
      EXIT;
    END IF;

    -- For each row fetched from SYS.AUD$
    LOOP
        -- 1. Insert into SYSTEM.aud$
        FORALL i in 1..rowid_tab.count
          EXECUTE IMMEDIATE
          'INSERT INTO SYSTEM.aud$ (SELECT t.* ' || col_str ||
          ' FROM SYS.AUD$ t WHERE rowid = :1)' using rowid_tab(i);

        -- 2. Delete from SYS.aud$
        FORALL i in 1..rowid_tab.count
          EXECUTE IMMEDIATE
          ' DELETE FROM SYS.aud$ WHERE rowid = :1 ' using rowid_tab(i);

        COMMIT;

        -- Exit if total rows is less than 100000
        IF (counter = 1 and nrows <= 100000) THEN
          EXIT;
        END IF;

        nrows := nrows - 100000;

        -- Fetch next 100000 rows
        FETCH rowid_cur bulk collect into rowid_tab limit 100000;
        IF (rowid_tab.count = 0) THEN
          EXIT;
        END IF;
    END LOOP;
    counter := counter - 1;
  END LOOP;
  CLOSE rowid_cur;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE;
END;
/
show errors;

ALTER SESSION SET CURRENT_SCHEMA = SYSTEM;

-- Move audit records
DECLARE
tab_name  VARCHAR2(4000);
col_str   VARCHAR2(4000) := '';
sqlstmt   VARCHAR2(4000);
nrows        NUMBER := 0;
npol         NUMBER := 0;
temp_exists  BOOLEAN := TRUE;
col_name1  VARCHAR2(130);
cnt          NUMBER;
tstamp       TIMESTAMP;
where_str VARCHAR2(4000) := '';
col_name2 VARCHAR2(258);
obj_num      NUMBER;

type ctyp is ref cursor;
rowid_cur ctyp;
rowid_tab dbms_sql.urowid_table;

CURSOR c_policy_columns IS
  SELECT column_name
  FROM lbacsys.lbac$pol p;

pol_row c_policy_columns%ROWTYPE;

BEGIN

  -- check if SYSTEM.aud$ already exists. 
  -- may be downgrade script was run before
  -- If SYSTEM.aud$ exists, don't do anything
  SELECT count(*) INTO cnt FROM dba_tables
     WHERE table_name = 'AUD$' AND owner = 'SYSTEM';
    
  IF cnt = 1 THEN
    RETURN;
  END IF;

  -- Check if temp aud table exists
  BEGIN
   SELECT table_name INTO tab_name FROM dba_tables
   WHERE table_name = 'PREDWG_AUD$' AND owner = 'SYSTEM';
  EXCEPTION
   WHEN NO_DATA_FOUND THEN
      RAISE;
   /* abort the downgrade *. This should never happen as 
      we check for SYSTEM.PREDWG_AUD$ at the beginning of downgrade */
  END;

  -- construct the col_str to be used when inserting into SYSTEM.aud$
  FOR pol_row IN c_policy_columns LOOP
    npol:= npol + 1;

    -- Bug 13887714: prevent sql injection
    -- 1. Use DBMS_ASSERT.ENQUOTE_NAME for SELECT column list.
    col_name1 := dbms_assert.enquote_name(pol_row.column_name, false);
    -- 2. Use DBMS_ASSERT.ENQUOTE_LITERAL for WHERE clause list
    --    since ENQUOTE_NAME will add double-quotes too.
    col_name2 := dbms_assert.enquote_literal
                 (replace((pol_row.column_name), '''', ''''''));

    IF npol <> 1 THEN
      col_str := col_str || ', t.' || col_name1;
      where_str := where_str || ' or name = ' || col_name2;
    ELSE
      col_str :=', t.' || col_name1;
      where_str := ' name = ' || col_name2;
    END IF;
  END LOOP;

  EXECUTE IMMEDIATE 'ALTER TABLE SYSTEM.predwg_aud$ RENAME TO aud$';

  -- Get a count of audit records in SYS.AUD$
  select count(*) INTO nrows from sys.aud$ ;

  IF (nrows > 0) THEN
    -- insert the rows into SYSTEM.aud$
    SYS.populate_aud(col_str, nrows);
  END IF;

  -- If an OLS Policy exists
  IF (npol > 0) THEN
    BEGIN
      -- Update the policy columns with hidden bits in SYSTEM.aud$ table
      -- Get obj# for SYSTEM.aud$ table
      SELECT tab.obj# into obj_num
      FROM sys.tab$ tab, sys.obj$ obj, sys.user$ usr
      WHERE obj.name ='AUD$' AND usr.name = 'SYSTEM'
      AND obj.obj# =tab.obj# AND usr.user# = obj.owner#;

      -- set bit to KQLDCOP_HID | KQLDCOP_EHC | KQLDCOP2_INVCQ
      sqlstmt := 'UPDATE sys.col$ set ' ||
      'property = property + 4194336' ||
      ' WHERE (' || where_str ||
      ') AND  obj#  = '|| obj_num;
      EXECUTE IMMEDIATE sqlstmt;

      -- update the tab$ to decrease the column count
      -- tab$.cols corresponds to the num_usrcols_kqldtvc field
      UPDATE SYS.tab$ SET cols = cols - npol WHERE obj# = obj_num;

      COMMIT;
    EXCEPTION
      WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
    END;
  END IF;
  
  -- Make sure the number of rows in SYSTEM.aud$ >= nrows
  BEGIN
    EXECUTE IMMEDIATE 'select SYSTIMESTAMP from dual  WHERE ' ||
           '(SELECT count(*) FROM SYSTEM.aud$) >= :1'
            INTO tstamp
            USING nrows;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE;
  END;

  -- Make sure there are no more rows left in SYS.aud$
    BEGIN
    select SYSTIMESTAMP into tstamp  from dual  WHERE
           (SELECT count(*) FROM SYS.aud$) = 0;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE;
    END;

END;
/
show errors;

ALTER SESSION SET CURRENT_SCHEMA = SYS;

-- bug#14002092 : revoke inherit any privileges from lbacsys
REVOKE INHERIT ANY PRIVILEGES FROM LBACSYS;

-- Bug 14259254: remove OLS-OID status from props$ table
BEGIN
  DELETE FROM SYS.props$ where name = 'OLS_OID_STATUS';
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE;
END;
/

-- Drop SYS.aud$, temp utility procedure; create synonym
DROP TABLE SYS.aud$;
DROP PROCEDURE populate_aud;
CREATE SYNONYM aud$ FOR SYSTEM.aud$;

-- Bug 22267756: Set current schema to LBACSYS
ALTER SESSION SET CURRENT_SCHEMA = LBACSYS;

-- bug 14175223 : Drop new 12.1 functions and packages
DROP FUNCTION LBACSYS.to_numeric_label_internal;
DROP FUNCTION LBACSYS.to_lbac_label_internal;
DROP FUNCTION LBACSYS.to_lbac_data_label_internal;
DROP FUNCTION LBACSYS.ora_get_audited_label;
DROP FUNCTION LBACSYS.fetch_ilabel;
DROP FUNCTION LBACSYS.create_or_fetch_ilabel;

DROP PROCEDURE LBACSYS.dp_add_rls_policy;
DROP PROCEDURE LBACSYS.dp_drop_rls_policy;
-- remove code_coverage from 12.1 code and then can remove it here
DROP PROCEDURE LBACSYS.code_coverage;

DROP LIBRARY LBACSYS.ols$session_libt;
DROP LIBRARY LBACSYS.ols$lab_libt;
DROP LIBRARY LBACSYS.lbac$rls_libt;

DROP PUBLIC SYNONYM ORA_GET_AUDITED_LABEL;

-- In pre 12.1 the package used was lbac_label_admin
DROP PACKAGE LBACSYS.SA_LABEL_ADMIN;

-- Bug 20402799: Drop synonyms which referenced new LBACSYS objects
DROP PUBLIC SYNONYM TAGSEQ_TO_CHAR;
DROP PUBLIC SYNONYM LBAC_AUDIT_ACTIONS;
DROP PUBLIC SYNONYM SA_LABEL_ADMIN;
DROP PUBLIC SYNONYM SA_AUDIT_ADMIN;

-- Bug 20402799: Drop synonyms for new objects
DROP PUBLIC SYNONYM DBA_OLS_STATUS;

-- Bug 23264000: Unset label function bit during downgrade
UPDATE lbacsys.lbac$polt
SET    options = options - 512
WHERE  BITAND (options, 512) = 512 AND
       function IS NOT NULL;
COMMIT;

-- Bug 22267756: Reset current schema to SYS
ALTER SESSION SET CURRENT_SCHEMA = SYS;

EXECUTE DBMS_REGISTRY.DOWNGRADED('OLS', '11.2.0');
