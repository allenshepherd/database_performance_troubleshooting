Rem
Rem $Header: rdbms/admin/olspredowngrade.sql /main/7 2017/05/12 13:12:17 risgupta Exp $
Rem
Rem olspredowngrade.sql
Rem
Rem Copyright (c) 2012, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      olspredowngrade.sql - OLS Pre-processing script prior to 
Rem                            downgrade from 12.1
Rem
Rem    DESCRIPTION
Rem      This is a mandatory OLS preprocess downgrade script that needs to be 
Rem      run by Label Security and Database Vault customers when downgrading 
Rem      from 12.1
Rem
Rem    NOTES
Rem      As a safety measure, before you run either the upgrade or downgrade
Rem      preprocess script, Oracle recommends that you back up your audit
Rem      records. To do this, you can archive the audit trail as described in
Rem      Oracle Database Security Guide.
Rem
Rem      Before processing the audit records, this preprocess script checks
Rem      that there is enough space in the audit tablespace to copy all the
Rem      audit records, and will exit without processing if there is not.
Rem
Rem      You may continue running your applications on the database while OLS
Rem      preprocess scripts are running.
Rem
Rem      You must run the OLS preprocess downgrade script, olspredowngrade.sql,
Rem      to process the aud$ table contents. The OLS downgrade script moves the
Rem      aud$ table from the SYS schema to the SYSTEM schema. The
Rem      olspredowngrade.sql script is a preprocessing script required in
Rem      preparation for this move. It creates a temporary table, PREDWG_AUD$,
Rem      in the SYSTEM schema and moves the SYS.aud$ records to
Rem      SYSTEM.PREDWG_AUD$. The moved records can no longer be viewed through
Rem      the DBA_AUDIT_TRAIL view, but can be viewed by directly accessing the
Rem      SYSTEM.PREDWG_AUD$ table, until the downgrade completes. Once the
Rem      downgrade completes, the SYSTEM.PREDWG_AUD$ table is permanently
Rem      deleted and all audit records, can be viewed through the
Rem      DBA_AUDIT_TRAIL view.
Rem
Rem      Auditing will continue to work and audit records will be written to
Rem      to SYS.aud$ after execution of this script.
Rem
Rem      STEPS TO RUN THE THIS SCRIPT
Rem      -----------------------------
Rem      To run the Oracle Label Security preprocess downgrade script,
Rem      run the script as SYSDBA in the 12.1 ORACLE_HOME.
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/olspredowngrade.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/olspredowngrade.sql
Rem    SQL_PHASE: UTILITY
Rem    SQL_STARTUP_MODE: NORMAL
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    SQL_CALLING_FILE:
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    risgupta    05/08/17 - Bug 26001269: Add SQL_FILE_METADATA
Rem    risgupta    02/16/16 - Bug 22733719: Must explictly set
Rem                           NLS_LENGTH_SEMANTICS to BYTE
Rem    risgupta    03/16/15 - LRG 14680081: Dont make the policy columns in
Rem                           SYSTEM.PREDWG_AUD$ invisible just after CTAS
Rem    pmojjada    02/05/15 - Bug# 20421634: Long identifier changes
Rem    aramappa    08/30/12 - bug 14539286: Do not throw errors when label
Rem                           security not installed and this script is run
Rem    srtata      06/27/12 - bug 14251893: update comments
Rem    srtata      03/12/12 - OLS pre-downgrade script for 12.1
Rem    srtata      03/12/12 - Created
Rem

set serveroutput on

-- Bug 22733719: Must explictly set NLS_LENGTH_SEMANTICS to BYTE
alter session set NLS_LENGTH_SEMANTICS=BYTE;

CREATE OR REPLACE FUNCTION is_ols_predowngd_req RETURN NUMBER
IS
  lbac_cnt    NUMBER := 0;
  ver         VARCHAR2(10);
  p_prv_version VARCHAR2(30);
BEGIN
  -- fetch the previous version
  SELECT prv_version INTO p_prv_version
  FROM registry$ 
  WHERE cid='CATPROC';
  
  IF p_prv_version IS NULL THEN
    DBMS_OUTPUT.PUT_LINE(
'olspredowngrade.sql should not be executed - database has not been upgraded');
    return 0;
  END IF;

  -- olspredowngrade.sql required only for downgrades to 11.2, 11.1
  IF substr(p_prv_version, 1, 4) NOT IN ('11.1','11.2') THEN
    DBMS_OUTPUT.PUT_LINE(
      'olspredowngrade.sql should not be executed for this database version');
    RETURN 0;
  END IF;

  SELECT COUNT(*) INTO lbac_cnt
  FROM dba_users
  WHERE username = 'LBACSYS';

  IF lbac_cnt = 0 THEN
    DBMS_OUTPUT.PUT_LINE('****THIS SCRIPT IS NEEDED ONLY IF ' ||
               'ORACLE LABEL SECURITY OR DATABASE VAULT ARE CONFIGURED*****');
    RETURN 0;
  END IF;

  RETURN 1;
END;
/
show errors;

CREATE OR REPLACE FUNCTION get_space_required(audit_trail_tbs IN VARCHAR2) 
RETURN   NUMBER
AS
    tab_rows        NUMBER := 0;
    temp_rows       NUMBER := 0;
    m_part_cnt      NUMBER := 0;
    space_occ       NUMBER := 0;
    space_req       NUMBER := 0;
    block_size      NUMBER := 0;
    blocks_used     NUMBER := 0;
    div_quotient    NUMBER := 0;
    cursor sel_dba_par IS
      SELECT PARTITION_POSITION, PARTITION_NAME, TABLESPACE_NAME
      FROM DBA_TAB_PARTITIONS
      WHERE TABLE_NAME = 'AUD$' AND
            TABLE_OWNER = 'SYS'
      ORDER BY PARTITION_POSITION;

BEGIN
-- Check space before proceeding with processing
    -- Is the table partitioned?
    SELECT COUNT(PARTITION_POSITION) INTO m_part_cnt
    FROM DBA_TAB_PARTITIONS
    WHERE TABLE_NAME = 'AUD$'
    AND TABLE_OWNER = 'SYS';

    IF m_part_cnt <= 0
    THEN
      -- Not partitioned
      SELECT BLOCK_SIZE INTO block_size FROM DBA_TABLESPACES
      WHERE TABLESPACE_NAME = audit_trail_tbs;
      --DBMS_OUTPUT.PUT_LINE('block_size = ' || block_size);

      SELECT NVL(BLOCKS,0) INTO blocks_used FROM DBA_TABLES
      WHERE TABLE_NAME = 'AUD$' AND OWNER='SYS';
      --DBMS_OUTPUT.PUT_LINE('blocks_used = ' || blocks_used);

      -- Add 3 blocks for meta data
      space_occ := (blocks_used + 3) * block_size;
      --DBMS_OUTPUT.PUT_LINE('space_occ = ' || space_occ);

      SELECT NUM_ROWS INTO tab_rows FROM DBA_TABLES
      WHERE TABLE_NAME = 'AUD$'
      AND OWNER='SYS';

      space_req :=  space_occ + 65536; /* minimum, 64 KB */
      --DBMS_OUTPUT.PUT_LINE('space_req non partitioned = '|| space_req);
    ELSE
      -- Partitioned
      space_occ := 0;
      tab_rows := 0;
      space_req := 0;
      FOR part_info IN sel_dba_par LOOP
        SELECT BLOCK_SIZE INTO block_size FROM DBA_TABLESPACES
        WHERE TABLESPACE_NAME = part_info.tablespace_name;

        SELECT BLOCKS, NUM_ROWS INTO blocks_used, temp_rows
        FROM DBA_TAB_PARTITIONS
        WHERE TABLE_NAME = 'AUD$'
        AND TABLE_OWNER = 'SYS';

        -- Add 3 blocks for meta data
        space_occ := (blocks_used + 3) * block_size;

        tab_rows := tab_rows + temp_rows;

        IF(temp_rows > 0) THEN
          space_req := space_req + space_occ;
        END IF;
      END LOOP;

      space_req :=  space_req+ 65536; /* minimum, 64 KB */
      --DBMS_OUTPUT.PUT_LINE('space_req partitioned = '|| space_req);
    END IF; -- Partitioned/Non-partitioned

       -- Space required must be a multiple of 64 KB
    div_quotient := space_req / 65536;
    space_req := CEIL(div_quotient) * 65536;
    --DBMS_OUTPUT.PUT_LINE('space_req= '|| space_req);
    RETURN space_req;
END;
/
show errors;

CREATE OR REPLACE FUNCTION get_free_space_avail(
                          audit_trail_tbs IN VARCHAR2)
RETURN   NUMBER
AS
  space_auto  NUMBER:=0;
  space_avail NUMBER:=0;
  space_inuse  NUMBER:=0;
  space_alloc NUMBER:=0;
  sum_bytes NUMBER:=0;
  
BEGIN
  -- Get number of kbytes used
  EXECUTE IMMEDIATE
    'SELECT SUM(bytes) FROM sys.dba_segments seg WHERE ' || 
    'seg.tablespace_name = :1'
        INTO sum_bytes 
        USING audit_trail_tbs;

  IF sum_bytes IS NULL THEN
    space_inuse :=0;
  ELSIF sum_bytes <= 1024 THEN 
    space_inuse :=1;
  ELSE
    space_inuse:=ROUND(sum_bytes/1024);
  END IF;

  -- Get number of kbytes allocated

  EXECUTE IMMEDIATE
    'SELECT SUM(bytes) FROM sys.dba_data_files files WHERE ' ||
    'files.tablespace_name = :1'
     INTO sum_bytes
    USING audit_trail_tbs;

  IF sum_bytes IS NULL THEN
    space_alloc :=0;
  ELSIF sum_bytes <= 1024 THEN 
    space_alloc :=1;
  ELSE
    space_alloc :=ROUND(sum_bytes/1024);
  END IF;

  EXECUTE IMMEDIATE
    'SELECT SUM(decode(maxbytes, 0, 0, maxbytes-bytes)) ' ||
    'FROM sys.dba_data_files WHERE tablespace_name=:1'
    INTO sum_bytes
    USING audit_trail_tbs;

  IF sum_bytes IS NULL THEN
    space_auto :=0;
  ELSIF sum_bytes <= 1024 THEN 
    space_auto :=1;
  ELSE
    space_auto :=ROUND(sum_bytes/1024);
  END IF;

  space_avail := (space_auto + space_alloc - space_inuse)*1024;
  return space_avail;

END;
/
show errors;


------------------------------------------------------------------------------
-- BEGIN PRE-downgrade SCRIPT. 

DECLARE

-- Tab_Name will always be PREDWG_AUD$, and doesn't need to be
-- extended to VARCHAR2(128) or dbms_id
tab_name  VARCHAR2(30); 
audtbs    VARCHAR2(256);
col_name  DBMS_ID; 
col_str   VARCHAR2(4000) := NULL;
space_req    NUMBER := 0;
space_avail  NUMBER := 0;
lbac_cnt     NUMBER := 0;
col_name1  DBMS_QUOTED_ID; 
timest      VARCHAR2(60);
npol NUMBER :=0;
sqlstmt VARCHAR2(4000);

TYPE ref_cur_type IS REF CURSOR;
policy_col_cur ref_cur_type;
BEGIN

  -- check if we need to run olspredowngrade.sql
  IF is_ols_predowngd_req = 0 THEN
    RETURN;
  END IF;

  BEGIN
    SELECT object_name INTO tab_name 
    FROM all_objects
    WHERE object_name = 'PREDWG_AUD$' 
    AND owner = 'SYSTEM' 
    AND object_type='TABLE';

    DBMS_OUTPUT.PUT_LINE('olspredowngrade.sql has been already run');
    RETURN;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
    NULL;
  END;

  -- get the tablespace used for auditing
  sqlstmt := 'SELECT tablespace_name FROM SYS.dba_tables ' ||
             'WHERE table_name = ''AUD$'' AND owner = ''SYS''';

  EXECUTE IMMEDIATE sqlstmt INTO audtbs;

  SELECT TO_CHAR(SYSTIMESTAMP,'YYYY-MM-DD HH24:MI:SS ') INTO timest FROM DUAL;
  DBMS_OUTPUT.PUT_LINE(timest||
                       '******* BEGINNING OLS PRE DOWNGRADE SCRIPT ********');

  --Space checks
  space_req := get_space_required(audtbs);
  --get space availble in the audit tablespace
  space_avail := get_free_space_avail(audtbs);

  -- Note that space_req is 64KB greater than actual space occupied
  -- but this is needed to account for any incoming records.
  DBMS_OUTPUT.PUT_LINE('The amount of FREE space required = '
                       || space_req || ' Bytes');
  DBMS_OUTPUT.PUT_LINE('Free space available  on ' || audtbs ||
                       ' tablespace= ' || space_avail || ' Bytes');

  IF space_avail < space_req  THEN
    DBMS_OUTPUT.PUT_LINE('NOT ENOUGH SPACE ON TABLESPACE ' || audtbs);
    RETURN;
  END IF;

  -- Construct a string with the list of policy columns 
  BEGIN
    OPEN policy_col_cur FOR 'SELECT column_name FROM lbacsys.ols$pol';
    LOOP
      FETCH policy_col_cur INTO col_name;
      EXIT WHEN policy_col_cur%NOTFOUND;

      npol:= npol+1;

      -- 1. Use DBMS_ASSERT.ENQUOTE_NAME for SELECT column list.
      col_name1 := dbms_assert.enquote_name(col_name, false);

      IF npol <> 1 THEN
        col_str := col_str || ', t.' || col_name1;
      ELSE
        col_str := ', t.' || col_name1;
      END IF;
    END LOOP;   
    CLOSE policy_col_cur;
  EXCEPTION
    WHEN OTHERS THEN
      CLOSE policy_col_cur;
      RAISE;
  END;
  
  sqlstmt := 'CREATE TABLE SYSTEM.PREDWG_AUD$ PARALLEL TABLESPACE ' || 
              dbms_assert.simple_sql_name(audtbs) || 
              ' AS SELECT t.* ' || col_str || ' FROM SYS.AUD$ t' ;

  EXECUTE IMMEDIATE sqlstmt;
  DBMS_OUTPUT.PUT_LINE('Audit records successfully moved to SYSTEM.PREDWG_AUD$');
END;
/

-- delete the processed rows in SYS.aud$
DECLARE
counter      NUMBER := 0;
nrows        NUMBER := 0;
tot_count    NUMBER := 0;
maxtime1      TIMESTAMP(6);
type ctyp is ref cursor;
rowid_cur ctyp;
rowid_tab dbms_sql.urowid_table;
timest      VARCHAR2(60);
BEGIN
  -- check if we need to run olspredowngrade.sql
  IF is_ols_predowngd_req = 0 THEN
    RETURN;
  END IF;

  -- Get a count of audit records in SYS.AUD$
  select count(*) INTO nrows from sys.aud$ ;

  IF nrows = 0 THEN
   RETURN;
  END IF;

  counter := ceil(nrows/1000000);

  EXECUTE IMMEDIATE 'SELECT MAX(ntimestamp#) FROM SYSTEM.PREDWG_AUD$' 
  INTO maxtime1;

  LOOP
    OPEN rowid_cur FOR 'select rowid from SYS.aud$' ||
         ' where rownum <= 1000000 and ntimestamp#<= TO_TIMESTAMP('''||
           TO_CHAR(maxtime1) || ''')';

    -- Fetch 1st 100000 rows
    FETCH rowid_cur bulk collect into rowid_tab limit 100000;

    -- Exit, if no rows
    IF (rowid_tab.count = 0) THEN
      EXIT;
    END IF;

    -- For each row fetched
    LOOP
        --  Delete from SYSTEM.aud$
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

        -- Exit, if no rows left
        IF (rowid_tab.count = 0) THEN
          EXIT;
        END IF;
    END LOOP;
    counter := counter - 1;
  END LOOP;
  CLOSE rowid_cur;

  EXECUTE IMMEDIATE 'SELECT count(*) FROM SYSTEM.PREDWG_AUD$'
  INTO tot_count;

  DBMS_OUTPUT.PUT_LINE('Total number of rows in SYSTEM.PREDWG_AUD$: '||
                        tot_count);

  SELECT TO_CHAR(SYSTIMESTAMP,'YYYY-MM-DD HH24:MI:SS ') INTO timest FROM DUAL;
  DBMS_OUTPUT.PUT_LINE(timest||
                       ' ******* FINISHING OLS PRE DOWNRADE SCRIPT ********');
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE;
END;
/
show errors;

set serveroutput off
