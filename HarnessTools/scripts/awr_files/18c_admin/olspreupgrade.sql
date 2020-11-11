Rem
Rem $Header: rdbms/admin/olspreupgrade.sql /main/9 2017/05/12 13:12:17 risgupta Exp $
Rem
Rem olspreupgrade.sql
Rem
Rem Copyright (c) 2012, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      olspreupgrade.sql - OLS Pre processing script prior to upgrade for 12.1
Rem
Rem    DESCRIPTION
Rem      This is a mandatory OLS preprocess upgrade script that needs to be run
Rem      by Label Security and Database Vault customers  when upgrading to 12.1.
Rem
Rem      This script is NOT NEEEDED if you DO NOT have Database Vault
Rem      or Label Security.
Rem
Rem    NOTES
Rem      As a safety measure, before you run either the upgrade or downgrade
Rem      preprocess script, Oracle recommends that you back up your audit
Rem      records. To do this, you can archive the audit trail as described
Rem      in Oracle Database Security Guide.
Rem
Rem      Before processing the audit records, this preprocess script checks
Rem      that there is enough space in the audit tablespace to copy all the
Rem      audit records, and will exit without processing if there is not.
Rem      
Rem      You may continue running your applications on the database while OLS
Rem      preprocess scripts are running.
Rem
Rem      You must run the OLS preprocess upgrade script, olspreupgrade.sql, to
Rem      process the aud$ table contents.The OLS upgrade moves the aud$ table
Rem      from the SYSTEM schema to the SYS schema. The olspreupgrade.sql script
Rem      is a preprocessing script required in preparation for this move. It
Rem      creates a temporary table, PREUPG_AUD$, in the SYS schema and moves
Rem      the SYSTEM.aud$ records to SYS.PREUPG_AUD$. The moved records can no
Rem      longer be viewed through the DBA_AUDIT_TRAIL view, but can be viewed
Rem      by directly accessing the SYS.PREUPG_AUD$ table, until the upgrade
Rem      completes. Once the upgrade completes, the SYS.PREUPG_AUD$ table is
Rem      permanently deleted and all audit records, can be viewed through the
Rem      DBA_AUDIT_TRAIL view.
Rem
Rem      Auditing will continue to work and audit records will be written to
Rem      to SYSTEM.aud$ after execution of this script. 
Rem      
Rem      If olspreupgrade.sql is not run before upgrade, the Oracle Label 
Rem      Security component upgrade script will run it during the database 
Rem      upgrade. Customers are advised to run olspreupgrade.sql before 
Rem      upgrade to reduce elapsed time for upgrade.
Rem
Rem      STEPS TO RUN THIS SCRIPT
Rem      -----------------------------
Rem      To run the Oracle Label Security preprocess upgrade script, copy the
Rem      $ORACLE_HOME/rdbms/admin/olspreupgrade.sql script to the old
Rem      ORACLE_HOME. Run the script as SYSDBA in the old ORACLE_HOME.
Rem
Rem      However, if you have Database Vault, the following steps need to be 
Rem      done after copying the olspreupgrade.sql to the old ORACLE_HOME:
Rem
Rem      To run the OLS preprocess script on a release 11.1.0.7 database before 
Rem      upgrading:
Rem
Rem      1. Start SQL*Plus and connect to the database to be upgraded as DVOWNER.
Rem      2. Execute the following statement:
Rem   SQL>EXEC dbms_macadm.add_auth_to_realm('Oracle Database Vault','SYS',NULL,0);
Rem      3. Run the OLS preprocess script, at 
Rem         ORACLE_HOME/rdbms/admin/olspreupgrade.sql
Rem      4. After the olspreupgrade.sql has been successfully run, start 
Rem         SQL*Plus and connect to the database as DVOWNER.
Rem      5. Execute the following statement:
Rem   SQL>EXEC dbms_macadm.delete_auth_from_realm('Oracle Database Vault','SYS');
Rem
Rem      To run the OLS preprocess script on a release 10.2.0.5 or 11.2 
Rem      database before upgrading:
Rem
Rem      1. Start SQL*Plus and connect to the database to be upgraded as 
Rem         DVOWNER.
Rem      2. Execute the following statement:
Rem         SQL> GRANT DV_PATCH_ADMIN to SYS;
Rem      3. Run the OLS preprocess script, at 
Rem         ORACLE_HOME/rdbms/admin/olspreupgrade.sql
Rem      4. After the olspreupgrade.sql has been successfully run, start 
Rem         SQL*Plus and connect to the database as DVOWNER.
Rem      5. Execute the following statement:
Rem         SQL> REVOKE DV_PATCH_ADMIN from SYS;
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/olspreupgrade.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/olspreupgrade.sql
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
Rem    pmojjada    04/07/15 - Bug# 20755301: In case of upgrade from 
Rem                           11204 to 12.2 use VARCHAR2(128) not DBMS_ID 
Rem    pmojjada    02/05/15 - Bug# 20421634: Long identifier changes
Rem    risgupta    06/24/14 - bug 18977628: Update steps incase DV is installed
Rem    aramappa    02/12/13 - bug 16317592:is_ols_preupgd_req:Check if SYS.AUD$
Rem                           exists. Remove version check
Rem    aramappa    08/27/12 - bug 14539286: Do not throw errors when label
Rem                           security not installed and this script is run
Rem    srtata      06/27/12 - bug 14251893: update comments
Rem    srtata      03/02/12 - OLS pre-upgrade script for 12.1
Rem    srtata      03/02/12 - Created
Rem

set serveroutput on

-- Bug 22733719: Must explictly set NLS_LENGTH_SEMANTICS to BYTE
alter session set NLS_LENGTH_SEMANTICS=BYTE;

CREATE OR REPLACE FUNCTION is_ols_preupgd_req RETURN NUMBER
IS
  lbac_cnt    NUMBER := 0;
  ver         VARCHAR2(10);
  cnt         NUMBER;
BEGIN

  SELECT COUNT(*) INTO lbac_cnt 
  FROM dba_users 
  WHERE username = 'LBACSYS';

  IF lbac_cnt = 0 THEN
    DBMS_OUTPUT.PUT_LINE('****THIS SCRIPT IS NEEDED ONLY IF ' ||
               'ORACLE LABEL SECURITY OR DATABASE VAULT ARE CONFIGURED*****');
    RETURN 0;
  END IF;
 
  -- bug 16317592: check if SYS.aud$ already exists. may be upgrade 
  -- script was run before. If SYS.aud$ exists, don't do anything
  SELECT count(*) INTO cnt FROM dba_tables
  WHERE table_name = 'AUD$' AND owner = 'SYS';

  IF cnt = 1 THEN
    DBMS_OUTPUT.PUT_LINE('AUD$ already exists in SYS schema');
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
            TABLE_OWNER = 'SYSTEM'
      ORDER BY PARTITION_POSITION;

BEGIN
-- Check space before proceeding with processing
    -- Is the table partitioned?
    SELECT COUNT(PARTITION_POSITION) INTO m_part_cnt
    FROM DBA_TAB_PARTITIONS
    WHERE TABLE_NAME = 'AUD$'
    AND TABLE_OWNER = 'SYSTEM';

    IF m_part_cnt <= 0
    THEN
      -- Not partitioned
      SELECT BLOCK_SIZE INTO block_size FROM DBA_TABLESPACES
      WHERE TABLESPACE_NAME = audit_trail_tbs;

      SELECT NVL(BLOCKS,0) INTO blocks_used FROM DBA_TABLES
      WHERE TABLE_NAME = 'AUD$'
      AND owner = 'SYSTEM';

      -- Add 3 blocks for meta data
      space_occ := (blocks_used + 3) * block_size;

      SELECT NUM_ROWS INTO tab_rows FROM DBA_TABLES
      WHERE TABLE_NAME = 'AUD$'
      AND owner = 'SYSTEM';

      space_req :=  space_occ + 65536; /* minimum, 64 KB */
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
        AND TABLE_OWNER = 'SYSTEM';

        -- Add 3 blocks for meta data
        space_occ := (blocks_used + 3) * block_size;

        tab_rows := tab_rows + temp_rows;

        IF(temp_rows > 0) THEN
          space_req := space_req + space_occ;
        END IF;
      END LOOP;

      space_req :=  space_req+ 65536; /* minimum, 64 KB */
    END IF; -- Partitioned/Non-partitioned

       -- Space required must be a multiple of 64 KB
    div_quotient := space_req / 65536;
    space_req := CEIL(div_quotient) * 65536;
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

-- BEGIN PRE-UPGRADE SCRIPT. 
DECLARE
  tab_name    VARCHAR2(30); 
  audtbs      VARCHAR2(256);
-- dbms_id does not exists in 11.2.0.4.0 DB. Usual VARCHAR2 idn
  col_name    VARCHAR2(128); 
  col_name1   VARCHAR2(130);
  col_name2   VARCHAR2(258);
  col_str     VARCHAR2(4000) := NULL;
  where_str   VARCHAR2(4000) := NULL;
  sqlstmt     VARCHAR2(4000);
  space_req   NUMBER := 0;
  space_avail NUMBER := 0;
  obj_num     NUMBER := 0;
  npol        NUMBER :=0;
  timest      VARCHAR2(60);

  TYPE ref_cur_type IS REF CURSOR;
  policy_col_cur ref_cur_type;
BEGIN

  -- check if we need to run olspreupgrade.sql
  IF is_ols_preupgd_req = 0 THEN
    RETURN;
  END IF;

  -- stop processing if PREUPG_AUD$ exists
  BEGIN
    SELECT table_name INTO tab_name 
    FROM all_tables
    WHERE table_name = 'PREUPG_AUD$' 
    AND owner = 'SYS';

    DBMS_OUTPUT.PUT_LINE('olspreupgrade.sql has been already run');
    RETURN;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      NULL; 
  END;

  -- get the tablespace used for auditing
  SELECT tablespace_name INTO audtbs 
  FROM SYS.dba_tables 
  WHERE table_name = 'AUD$' 
  AND owner = 'SYSTEM';

  SELECT TO_CHAR(SYSTIMESTAMP,'YYYY-MM-DD HH24:MI:SS ') INTO timest FROM DUAL;
  DBMS_OUTPUT.PUT_LINE(timest||
                       '******* BEGINNING OLS PRE UPGRADE SCRIPT ********');

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
    RAISE_APPLICATION_ERROR (-20000, 'NOT ENOUGH SPACE IN TABLESPACE ' 
       ||audtbs||'. SPACE AVAILABLE='||space_avail|| ' BYTES, SPACE REQUIRED='
       ||space_req|| ' BYTES. PLEASE RERUN UPGRADE AFTER INCREASING 
       TABLESPACE SIZE');
    RETURN;
  END IF;

  -- Construct a string with the list of policy columns 
  BEGIN
    -- make olspreupgrade.sql runnable during a upgrade rerun
    BEGIN
      OPEN policy_col_cur FOR 'SELECT column_name FROM lbacsys.lbac$pol';
    EXCEPTION 
      WHEN OTHERS THEN
        IF SQLCODE != -942 THEN
          RAISE;
        ELSE
          OPEN policy_col_cur FOR 'SELECT column_name FROM lbacsys.ols$pol';
        END IF;
    END;

    LOOP
      FETCH policy_col_cur INTO col_name;
      EXIT WHEN policy_col_cur%NOTFOUND;

      npol:= npol+1;

      -- 1. Use DBMS_ASSERT.ENQUOTE_NAME for SELECT column list.
      col_name1 := dbms_assert.enquote_name(col_name, false);

      -- 2. Use DBMS_ASSERT.ENQUOTE_LITERAL for WHERE clause list
      --    since ENQUOTE_NAME will add double-quotes too.
      col_name2 := dbms_assert.enquote_literal
                   (replace((col_name), '''', ''''''));

      IF npol <> 1 THEN
        col_str := col_str || ', t.' || col_name1;
        where_str := where_str || ' or name = ' || col_name2;
      ELSE
        col_str := ', t.' || col_name1;
        where_str := ' name = ' || col_name2;
      END IF;

    END LOOP;   
    CLOSE policy_col_cur;

  EXCEPTION 
    WHEN OTHERS THEN
      CLOSE policy_col_cur;
      RAISE;
  END;

  SELECT TO_CHAR(SYSTIMESTAMP,'YYYY-MM-DD HH24:MI:SS ') INTO timest FROM DUAL;
  DBMS_OUTPUT.PUT_LINE(timest||
                       '******** PROCEEDING WITH OLS PRE UPGRADE *******');

  sqlstmt := 'CREATE TABLE SYS.PREUPG_AUD$ PARALLEL TABLESPACE ' || 
              dbms_assert.simple_sql_name(audtbs) || 
              ' AS SELECT t.* ' || col_str || ' FROM SYSTEM.AUD$ t' ;

  EXECUTE IMMEDIATE sqlstmt;
  DBMS_OUTPUT.PUT_LINE('Audit records successfully moved to SYS.PREUPG_AUD$');

  -- If an OLS Policy exists,
  IF (npol > 0) THEN
    BEGIN
      -- Update the policy columns with hidden bits in SYS.aud$ table
      -- Get obj# for SYS.aud$ table
      SELECT tab.obj# into obj_num
      FROM sys.tab$ tab, sys.obj$ obj, sys.user$ usr
      WHERE obj.name ='PREUPG_AUD$' AND usr.name = 'SYS'
      AND obj.obj# =tab.obj# AND usr.user# = obj.owner#
      AND obj.type#=2;

      -- set bit to KQLDCOP_HID | KQLDCOP_EHC | KQLDCOP2_INVCQ
      sqlstmt := 'UPDATE sys.col$ set ' ||
      'property = property + 4194336' ||
     ' WHERE (' || where_str ||
      ') AND  obj#  = '|| obj_num;
      EXECUTE IMMEDIATE sqlstmt;

      -- update the tab$  to decrease the column count
      -- tab$.cols corresponds to the num_usrcols_kqldtvc field
      UPDATE sys.tab$ SET cols = cols - npol WHERE obj# = obj_num;

      COMMIT;
    EXCEPTION
      WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
    END;
  END IF;
END;
/
show errors;

-- delete the processed rows in SYSTEM.aud$
DECLARE
  nrows        NUMBER := 0;
  maxtime1      TIMESTAMP(6);
  tot_count    NUMBER := 0;
  timest      VARCHAR2(60);
  cnt         NUMBER;
BEGIN

  -- check if we need to run olspreupgrade.sql
  IF is_ols_preupgd_req = 0 THEN
    RETURN;
  END IF;
 
  -- stop processing if PREUPG_AUD$ does not exist
  SELECT count(*) INTO cnt
  FROM all_tables
  WHERE table_name = 'PREUPG_AUD$' 
  AND owner = 'SYS';

  IF cnt = 0 THEN
    DBMS_OUTPUT.PUT_LINE('PREUPG_AUD$ does not exist');
    RETURN;
  END IF;
 
  -- Create a temporary table to store rowids
  EXECUTE IMMEDIATE 'CREATE TABLE system.aud$_temp 
                     AS SELECT rowid rid_col 
                     FROM SYSTEM.aud$ 
                     WHERE 1=0';

  -- fetch the max timestamp copied to the temp table during pre-upgrade
  EXECUTE IMMEDIATE 'SELECT MAX(ntimestamp#) FROM sys.preupg_aud$' 
  INTO maxtime1;

  -- fetch processed rows from aud$ in batches
  LOOP
    EXECUTE IMMEDIATE 
     'INSERT /*+ append */ INTO system.aud$_temp
      SELECT rowid FROM system.aud$
      WHERE ROWNUM <= 100000
      AND  ntimestamp# <= TO_TIMESTAMP(TO_CHAR(:1))' USING maxtime1;
    COMMIT;

    EXECUTE IMMEDIATE 'SELECT count(*) FROM system.aud$_temp' 
    INTO nrows ;

    IF (nrows = 0) THEN
          EXIT;
    END IF;

    -- delete processed rows from aud$
    EXECUTE IMMEDIATE
     'DELETE FROM SYSTEM.aud$ aud WHERE EXISTS
        (SELECT 1 
         FROM system.aud$_temp aud_t 
         WHERE aud.rowid = aud_t.rid_col )';

    COMMIT;

    EXECUTE IMMEDIATE 'TRUNCATE TABLE system.aud$_temp';
  END LOOP;

  EXECUTE IMMEDIATE 'DROP TABLE system.aud$_temp';

  EXECUTE IMMEDIATE 'SELECT count(*) FROM SYS.PREUPG_AUD$'
  INTO tot_count;

  DBMS_OUTPUT.PUT_LINE('Total number of rows in SYS.PREUPG_AUD$: '||tot_count);

  SELECT TO_CHAR(SYSTIMESTAMP,'YYYY-MM-DD HH24:MI:SS ') INTO timest FROM DUAL;
  DBMS_OUTPUT.PUT_LINE(timest||
                       ' ******* FINISHING OLS PRE UPGRADE SCRIPT ********');


EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE;
END;
/
show errors;

set serveroutput off
