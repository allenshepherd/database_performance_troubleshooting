Rem
Rem $Header: rdbms/admin/olsaudup.sql /main/3 2017/05/12 13:12:17 risgupta Exp $
Rem
Rem olsaudup.sql
Rem
Rem Copyright (c) 2014, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      olsaudup.sql - Oracle Label Security AUD$ pre-UPgrade.
Rem
Rem    DESCRIPTION
Rem      This script is used to move audit records from SYSTEM schema
Rem      to SYS schema.
Rem
Rem    NOTES
Rem      Called from c1102000.sql
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/olsaudup.sql 
Rem    SQL_SHIPPED_FILE: rdbms/admin/olsaudup.sql 
Rem    SQL_PHASE: UPGRADE
Rem    SQL_STARTUP_MODE: UPGRADE 
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: rdbms/admin/c1102000.sql
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    risgupta    05/08/17 - Bug 26001269: Modify SQL_FILE_METADATA
Rem    pmojjada    02/05/15 - Bug# 20421634: Long identifier changes
Rem    risgupta    05/16/14 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

-- Alter preupg_aud$ to change VARCHAR2 columns max lengths

-- bug 16317592: Require to move this block here because we should not
-- alter column lengths AFTER invoking olspreupgrade.sql below since 
-- this ends up resetting our updates to tab$.cols

-- Note: This block returns without altering preupg_aud$ if the user never
-- ran olspreupgrade.sql before starting upgrade. When olspreupgrade is
-- invoked after this block below, the CTAS would create preupg_aud$ from 
-- the "upgraded" aud$, so these alter ddls are not needed on preupg_aud$
DECLARE
  cnt NUMBER;
BEGIN
  -- Find out if preupg_aud$ exists.
  SELECT count(*) INTO cnt FROM dba_tables
  WHERE table_name = 'PREUPG_AUD$' AND owner = 'SYS';

  -- If preupg_aud$ exists, alter it.
  IF (cnt = 1) THEN
    begin
      execute immediate 'alter table preupg_aud$ 
                           modify (clientid     varchar2(128),
                                   userid       varchar2(128),
                                   obj$creator  varchar2(128),
                                   auth$grantee varchar2(128),
                                   new$owner    varchar2(128),
                                   obj$edition  varchar2(128)
                                  )';
    exception when others then
      if sqlcode in (-904, -942) then null;
      else raise;
      end if;
    end;
  END IF;
END;
/

-- bug 16317592: start moving audit records to temp table. This
-- post processing is needed before we finally move all records
-- to SYS.aud$ and remove SYSTEM.aud$ contents. olspreupgrade.sql 
-- returns without any processing if it was run before upgrade
@@olspreupgrade.sql

-- Bug 13529466: Move Audit Records from SYSTEM.AUD$ to SYS.AUD$
-- Drop aud$ synonym
DROP SYNONYM AUD$;


-- Create a utility procedure to populate SYS.aud$ table
CREATE OR REPLACE PROCEDURE populate_aud(col_str      VARCHAR2,
                                         orignal_rows NUMBER)
AS
counter      NUMBER := 0;
nrows        NUMBER := 0;
column_list  VARCHAR2(4000);
type ctyp is ref cursor;

rowid_cur ctyp;
rowid_tab dbms_sql.urowid_table;
BEGIN
  -- populate SYS.aud$ with the rows from SYSTEM.aud$
  -- delete the processed rows in SYSTEM.aud$
  nrows := orignal_rows;
  column_list := 'sessionid, entryid, statement, timestamp#, userid, ' ||
                 'userhost, terminal, action#, returncode, ' ||
                 'obj$creator, obj$name, auth$privileges, auth$grantee, '||
                 'new$owner, new$name, ses$actions, ses$tid, ' ||
                 'logoff$lread, logoff$pread, logoff$lwrite, ' ||
                 'logoff$dead, logoff$time, comment$text, clientid, ' ||
                 'spare1, spare2, obj$label, ses$label, priv$used, ' ||
                 'sessioncpu, ntimestamp#, proxy$sid, user$guid, ' ||
                 'instance#, process#, xid, auditid, scn, dbid, ' ||
                 'sqlbind, sqltext, obj$edition';

  column_list := column_list || col_str;

  counter := ceil(nrows/1000000);
  LOOP
    OPEN rowid_cur FOR 'select rowid from SYSTEM.aud$' ||
                       ' where rownum <= 1000000';

    -- Fetch 1st 100000 rows
    FETCH rowid_cur bulk collect into rowid_tab limit 100000;

    -- Exit, if no rows
    IF (rowid_tab.count = 0) THEN
      EXIT;
    END IF;

    -- For each row fetched
    LOOP
        -- 1. Insert into SYS.aud$
        FORALL i in 1..rowid_tab.count
          EXECUTE IMMEDIATE
          'INSERT /*APPEND*/ INTO SYS.aud$ (' || column_list ||
          ') (SELECT ' || column_list ||
          ' FROM SYSTEM.aud$ WHERE rowid = :1)' using rowid_tab(i);

        -- 2. Delete from SYSTEM.aud$
        FORALL i in 1..rowid_tab.count
          EXECUTE IMMEDIATE
          ' DELETE FROM SYSTEM.aud$ WHERE rowid = :1 ' using rowid_tab(i);

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
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE;
END;
/
show errors;

-- Move audit records
DECLARE
tab_name  DBMS_ID; 
col_str   VARCHAR2(4000) := '';
where_str VARCHAR2(4000) := '';
sqlstmt   VARCHAR2(4000);
nrows        NUMBER := 0;
npol         NUMBER := 0;
obj_num      NUMBER;
cnt          NUMBER;
tstamp       TIMESTAMP;
col_name   DBMS_QUOTED_ID; 
col_name1  DBMS_QUOTED_ID; 
col_name2  VARCHAR2(258);

type ctyp is ref cursor;
rowid_cur ctyp;
rowid_tab dbms_sql.urowid_table;

c_policy_columns ctyp;

BEGIN

  -- check if SYS.aud$ already exists. may be upgrade script was run before
  -- If SYS.aud$ exists, don't do anything
  SELECT count(*) INTO cnt FROM dba_tables
     WHERE table_name = 'AUD$' AND owner = 'SYS';

  IF cnt = 1 THEN
    RETURN;
  END IF;

  -- Check if temp aud table exists
  BEGIN
   SELECT table_name INTO tab_name FROM dba_tables
   WHERE table_name = 'PREUPG_AUD$' AND owner = 'SYS';
  EXCEPTION
   WHEN NO_DATA_FOUND THEN
      RAISE;
   /* abort the upgrade *. This should never happen as 
      we check for SYS.PREUPG_AUD$ at the beginning of upgrade */
  END;

  -- construct the col_str to be used when inserting into SYS.aud$
  -- construct the where clause of columns names to be used by update
  BEGIN
    -- make olspreupgrade.sql runnable during a upgrade rerun
    BEGIN
      OPEN c_policy_columns FOR 'SELECT column_name FROM lbacsys.lbac$pol';
    EXCEPTION
      WHEN OTHERS THEN
        IF SQLCODE != -942 THEN
          RAISE;
        ELSE
          OPEN c_policy_columns FOR 'SELECT column_name FROM lbacsys.ols$pol';
        END IF;
    END;

    LOOP
      FETCH c_policy_columns INTO col_name;
      EXIT WHEN c_policy_columns%NOTFOUND;

      npol:= npol + 1;

      -- Bug 13887731: prevent sql injection
      -- 1. Use DBMS_ASSERT.ENQUOTE_NAME for SELECT column list.
      col_name1 := dbms_assert.enquote_name(col_name, false);
      -- 2. Use DBMS_ASSERT.ENQUOTE_LITERAL for WHERE clause list
      --    since ENQUOTE_NAME will add double-quotes too.
      col_name2 := dbms_assert.enquote_literal
                     (replace((col_name), '''', ''''''));

      IF npol <> 1 THEN
        col_str := col_str || ', ' || col_name1;
        where_str := where_str || ' or name = ' || col_name2;
      ELSE
        col_str := ', ' || col_name1;
        where_str := ' name = ' || col_name2;
      END IF;

    END LOOP;
    CLOSE c_policy_columns;

  EXCEPTION 
    WHEN OTHERS THEN
      CLOSE c_policy_columns;
      RAISE;
  END;

  EXECUTE IMMEDIATE 'ALTER TABLE SYS.preupg_aud$ RENAME TO aud$';

  -- Get a count of audit records in SYSTEM.AUD$
  EXECUTE IMMEDIATE 'select count(*) from system.aud$' INTO nrows;

  IF (nrows > 0) THEN
    -- insert the rows into SYS.aud$
    populate_aud(col_str, nrows);
  END IF;

  -- Can make ols policy columns hidden since they are not last columns
  -- If an OLS Policy exists,
  IF (npol > 0) THEN
    BEGIN
      -- Update the policy columns with hidden bits in SYS.aud$ table
      -- Get obj# for SYS.aud$ table
      SELECT tab.obj# into obj_num
      FROM sys.tab$ tab, sys.obj$ obj, sys.user$ usr
      WHERE obj.name ='AUD$' AND usr.name = 'SYS'
      AND obj.obj# =tab.obj# AND usr.user# = obj.owner#
      AND obj.type#=2;

      -- set bit to KQLDCOP2_INVCQ
      sqlstmt := 'UPDATE sys.col$ set ' ||
      'property = property + 17179869184' ||
      ' WHERE (' || where_str ||
      ') AND  obj#  = '|| obj_num;
      EXECUTE IMMEDIATE sqlstmt;

      COMMIT;
    EXCEPTION
      WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
    END;
  END IF;

  -- Make sure the number of rows in SYS.aud$ >= nrows
  BEGIN
    EXECUTE IMMEDIATE 'select SYSTIMESTAMP from dual  WHERE ' ||
           '(SELECT count(*) FROM SYS.aud$) >= :1'
            INTO tstamp
            USING nrows;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE;
  END;

  -- Make sure there are no more rows left in SYSTEM.aud$
    BEGIN
    EXECUTE IMMEDIATE 'select SYSTIMESTAMP from dual  WHERE ' ||
           '(SELECT count(*) FROM SYSTEM.aud$) =0'
            INTO tstamp;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE;
    END;

    -- drop system.aud$ if everything went ok with moving
    -- its contents to sys.aud$
    EXECUTE IMMEDIATE 'DROP TABLE SYSTEM.aud$';
END;
/
show errors;

DROP PROCEDURE populate_aud;

@?/rdbms/admin/sqlsessend.sql
