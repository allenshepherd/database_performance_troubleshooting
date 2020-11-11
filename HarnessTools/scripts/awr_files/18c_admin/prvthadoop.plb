                              CREATE_EXTDDL_FOR_HIVE.TEXT_OF_DDL to CLOB type
@@?/rdbms/admin/sqlsessstart.sql
VAR pfid NUMBER;
DECLARE
  pfid     NUMBER := 0;
BEGIN
  SELECT platform_id INTO pfid FROM v$database;
  :pfid := pfid;
END;
/
VAR execfile VARCHAR2(32)
COLUMN :execfile NEW_VALUE execfile NOPRINT;
BEGIN
   IF (:pfid = 13 OR :pfid = 2) THEN
      :execfile := 'prvthadoop1.plb';
   ELSE
      :execfile := 'nothing.sql';
   END IF;
END;
/
SELECT :execfile FROM DUAL;
@@&execfile
@@?/rdbms/admin/sqlsessend.sql
