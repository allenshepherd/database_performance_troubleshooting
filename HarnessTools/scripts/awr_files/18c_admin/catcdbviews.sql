Rem
Rem $Header: rdbms/admin/catcdbviews.sql /main/40 2017/06/26 16:01:18 pjulsaks Exp $
Rem
Rem catCDBViews.sql
Rem
Rem Copyright (c) 2011, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catCDBViews.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catcdbviews.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catcdbviews.sql
Rem SQL_PHASE: CATCDBVIEWS
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catproc.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    pjulsaks    06/26/17 - Bug 25688154: modify isLegalOwner function
Rem    thbaby      03/13/17 - Bug 25688154: remove use of upper() on owner
Rem    pjulsaks    03/02/17 - Bug 25313154: add assert to prevent SQL injection
Rem    thbaby      02/15/17 - Bug 25100839: add CON$ERRNUM, CON$ERRMSG
Rem    pjulsaks    05/27/16 - Bug 23083309: handle XMLType column
Rem    jmuller     11/24/15 - Fix bug 20559930: reimplement GETLONG
Rem    pjulsaks    02/29/16 - Bug 21785587: handle LONG RAW column
Rem    thbaby      01/13/16 - Bug 20683085: handle Opaque Type correctly
Rem    thbaby      12/30/15 - Bug 22375737: exclude ADT column from comment
Rem    thbaby      04/11/15 - 20869766: add CON$NAME, CDB$NAME to CDB Views
Rem    prshanth    16/04/14 - 18657870: replace CDB$VIEW with CONTAINERS
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    gravipat    11/22/13 - 17843598: populate view comments correctly
Rem    gravipat    11/07/13 - quote view names
Rem    thbaby      10/29/12 - 14781792: ignore GRANT_PATH type
Rem    thbaby      09/26/12 - 13867272: unconditionally create cdb views in
Rem                           catcdbviews during upgrade, catch recompilation 
Rem                           error in create_cdbview
Rem    gravipat    08/22/12 - 13739232: Ignore long columns
Rem    vpriyans    07/05/12 - Bug 14272027: Allow audit_admin and audit_viewer
Rem                           roles to select from cdb_unified_audit_trail
Rem    thbaby      06/21/12 - prevent sql injection by correctly using quotes
Rem    gravipat    06/15/12 - lrg 6995210: Remove quotes around oldview_name
Rem    thbaby      06/11/12 - allow CDB_* views over non-SYS-owned DBA_* views
Rem    gravipat    05/14/12 - 13083137: Make create_cdbview private
Rem    ssonawan    04/25/12 - bug 13964209: add cdb_unified_audit_trail
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    gravipat    02/21/12 - 13724677: CDB_USERS should only show common users
Rem                           once
Rem    bhammers    07/28/07 - add exception for new vies containing xml type
Rem    gravipat    11/29/11 - Get rid of CDBView table function
Rem    sumkumar    11/09/11 - Remove WITH GRANT OPTION from public grants
Rem                         - Do not run SQL statements twice
Rem    gravipat    11/08/11 - 13356587: Use a different escape character
Rem    bhammers    07/28/07 - add exception for new vies containing xml type
Rem    gravipat    04/25/11 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

-- create the trusted pl/sql callout library
create or replace library dbms_pdb_lib trusted as static
/

create or replace package sys.CDBView_internal 
  accessible by (package sys.CDBView) as 

  /* In a separate package to permit PRAGMA RR. */
  PROCEDURE long2varchar2_i (stmt   IN VARCHAR2,
                             rowid  IN ROWID,
                             rowval IN OUT VARCHAR2
                            );
  PRAGMA RESTRICT_REFERENCES (long2varchar2_i, WNDS, RNPS, WNPS);

end;
/

grant execute on sys.CDBView_internal to execute_catalog_role
/

create or replace package body sys.CDBView_internal as 

  PROCEDURE long2varchar2_i (stmt   IN VARCHAR2,
                             rowid  IN ROWID,
                             rowval IN OUT VARCHAR2
                            ) IS
    EXTERNAL
    NAME "kpdbLong2Varchar2"
    LANGUAGE C
    LIBRARY DBMS_PDB_LIB
    PARAMETERS (stmt   OCIString,  stmt   indicator sb4,
                rowid  OCIString,  rowid  indicator sb4,
                rowval OCIString,  rowval indicator sb4,
                rowval length sb4, rowval maxlen sb4
               );

end;
/

create or replace package sys.CDBView as 
  ----------------------------
  --  PROCEDURES AND FUNCTIONS
  --
procedure create_cdbview(chk_upgrd IN boolean, owner IN varchar2,
                         oldview_name IN varchar2, newview_name IN varchar2);

function getlong(opcode in number, p_rowid in rowid) return varchar2;
--  accessible by(FUNCTION SYS.GETLONG);
pragma restrict_references (getlong, WNPS, RNPS, WNDS, TRUST);

end CDBView;
/

grant execute on sys.CDBView to execute_catalog_role
/

create or replace package body sys.CDBView is

function isLegalOwnerViewName(owner IN varchar2, oldview IN varchar2,
                              newview IN varchar2) return varchar2;
-- Create the cdb view
-- private helper procedure to create the cdb view
-- Note that quotes should not be added around owner, oldview_name and 
-- newview_name before create_cdbview is invoked since all three are used 
-- as literals to query dictionary views.
procedure create_cdbview(chk_upgrd IN boolean, owner IN varchar2,
                         oldview_name IN varchar2, newview_name IN varchar2) as
  sqlstmt        varchar2(4000);
  col_name       varchar2(128);
  comments       varchar2(4000);
  col_type       number;
  newview        varchar2(128);
  quoted_owner   varchar2(130); -- 2 more than size of owner
  quoted_oldview varchar2(130); -- 2 more than size of oldview_name
  quoted_newview varchar2(130); -- 2 more than size of newview_name
  unsupp_col_condition varchar2(4000);
  colcomments          varchar2(4000);
  unsupp_col_count     number;
  colcommentscur       SYS_REFCURSOR;
  table_not_found      EXCEPTION;
  PRAGMA               exception_init(table_not_found, -942);  


  cursor tblcommentscur is select c.comment$
                from sys.obj$ o, sys.user$ u, sys.com$ c
                where o.name = oldview_name and u.name = owner
                and o.obj# = c.obj# and o.owner#=u.user# 
                and (o.type# = 4 or o.type# = 2)
                and c.col# is null;

begin

  newview := isLegalOwnerViewName(owner, oldview_name, newview_name);
  if (newview is NULL) then
    RAISE table_not_found;
  end if;

  quoted_owner   := '"' || owner               || '"';
  quoted_oldview := '"' || oldview_name  || '"';
  quoted_newview := '"' || newview       || '"';

  -- Create cdb view
  sqlstmt := 'CREATE OR REPLACE VIEW ' || 
     quoted_owner || '.' || quoted_newview || 
     ' CONTAINER_DATA AS' || 
     ' SELECT k.*, k.CON$NAME, k.CDB$NAME, k.CON$ERRNUM, k.CON$ERRMSG' ||
     ' FROM CONTAINERS(' || quoted_owner || '.' || quoted_oldview || ') k';

  execute immediate sqlstmt;

  -- table and column comments
  open tblcommentscur;
  fetch tblcommentscur into comments;
  comments := replace(comments, '''','''''');
  sqlstmt := 'comment on table ' || quoted_owner || '.' || quoted_newview ||
              ' is ''' || comments || ' in all containers''';
  execute immediate sqlstmt;
  close tblcommentscur;

  sqlstmt := 'comment on column ' || quoted_owner || '.' || quoted_newview ||
             '.CON_ID is ''container id''';
  execute immediate sqlstmt;

  sqlstmt := 'comment on column ' || quoted_owner || '.' || quoted_newview ||
             '.CON$NAME is ''Container Name''';
  execute immediate sqlstmt;

  sqlstmt := 'comment on column ' || quoted_owner || '.' || quoted_newview ||
             '.CDB$NAME is ''Database Name''';
  execute immediate sqlstmt;

  sqlstmt := 'comment on column ' || quoted_owner || '.' || quoted_newview ||
             '.CON$ERRNUM is ''Error Number''';
  execute immediate sqlstmt;

  sqlstmt := 'comment on column ' || quoted_owner || '.' || quoted_newview ||
             '.CON$ERRMSG is ''Error Message''';
  execute immediate sqlstmt;

  colcomments := 'select c.name, co.comment$ ' || 
                 'from sys.obj$ o, sys.col$ c, sys.user$ u, sys.com$ co ' ||
                 'where o.name = :1 ' ||
                 'and u.name = :2 ' ||
                 'and o.owner# = u.user# and (o.type# = 4 or o.type# = 2) ' ||
                 'and o.obj# = c.obj# ' ||
                 'and c.obj# = co.obj# and c.intcol# = co.col# ' ||
                 -- skip hidden column 
                 'and bitand(c.property, 32) = 0 '|| 
                 -- skip null comment 
                 'and co.comment$ is not null';
                          -- skip Long, Nested Table, Varray columns 
  unsupp_col_condition := 'c.type# = 8 or c.type# = 122 or c.type# = 123 ' ||
                          -- skip ADT and REF columns 
                          'or c.type# = 121 or c.type# = 111 ' ||
                          -- Bug 20683085: skip Opaque Type column except 
                          -- xmltype stored as LOB. Check xmltype as lob using
                          -- property bit KQLDCOP2_XSLB.
		          -- Bug 23083309: if there are unsupported columns, 
                          -- then XMLType column is skipped (hidden XMLType lob 
                          -- column is already handled)
                          'or (c.type# = 58 and ' || 
                              '((bitand(c.property, ' ||
                                'power(2,32)*4194304)<>power(2,32)*4194304) '||
                                'or :3 > 0)) ' ||
                          -- Bug 21785587: skip long raw
                          'or c.type# = 24';

  sqlstmt := colcomments || ' and (' || unsupp_col_condition || ')';

  unsupp_col_count := 0;
  EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM (' || sqlstmt ||')' 
    INTO unsupp_col_count USING oldview_name, owner, unsupp_col_count;
  
  open colcommentscur for colcomments ||' and not ('|| 
                            unsupp_col_condition ||')' 
                      USING oldview_name, owner, unsupp_col_count;
  loop
    fetch colcommentscur into col_name, comments;
    exit when colcommentscur%NOTFOUND;

    comments := replace(comments, '''','''''');
    sqlstmt := 'comment on column ' ||
               quoted_owner || '.' || quoted_newview || '.' ||
               col_name || ' is ''' || comments || '''';

    execute immediate sqlstmt;
  end loop;
  close colcommentscur;
end;

  function getlong(opcode in number, p_rowid in rowid) return varchar2
  as
      tablename dbms_id;
      colname   dbms_id;
      stmt      varchar2(400);
      retval    varchar2(4000);
  begin
      if (opcode = 1) then 
        tablename := 'SYS.VIEW$';
        colname   := 'TEXT';
      elsif (opcode = 2) then
        tablename := 'SYS.CDEF$';
        colname   := 'CONDITION';
      else
        return NULL;
      end if;

      stmt := 'SELECT ' || colname || ' FROM ' || tablename || 
              ' WHERE ROWID = :1';
      CDBView_internal.long2varchar2_i(stmt, p_rowid, retval);
      return retval;
  end getlong;

  -- This function is created to prevent SQL injection. We couldn't use
  -- dbms_assert because catcdbviews.sql is called before dbms_assert
  -- is created
  function isLegalOwnerViewName(owner IN varchar2, oldview IN varchar2,
                             newview IN varchar2) return varchar2 as
    cCheck       number;
    cleanOldview varchar2(128);
    cleanNewview varchar2(128);
  begin
    
    -- Check if owner already exist
    execute immediate 'SELECT COUNT(*) FROM USER$ WHERE NAME = :1' 
             into cCheck using owner;
    if (cCheck = 0) then
      RETURN NULL;
    end if;

    -- Check if oldview already exist
    execute immediate 'SELECT COUNT(*) FROM OBJ$ WHERE NAME = :1' ||
                      ' AND (TYPE# = 4 OR TYPE# = 2)' 
             into cCheck using oldview;
    if (cCheck = 0) then
      RETURN NULL;
    end if;

    if (not REGEXP_LIKE(newview, '^[A-Za-z_][A-Za-z0-9_$#]*$')) then
      RETURN NULL;
    end if;

    -- Check for appropriate newview name
    -- The following is allowed for newview name
    -- 1. Substitute 'DBA' with 'CDB'
    -- 2. Substitute 'AWR_PDB' with 'CDB_HIST'
    -- 3. Substitute 'ATTRIBUTES' with 'ATTRIB'
    -- 4. Substitute 'DATABASE' with 'CDB'
    -- 5. Remove 'REDUCED'
    -- 6. Add 'AWRI$_CDB'
    cleanOldview := REGEXP_REPLACE(oldview,
       'DBA|DATABASE|_| |HIST|ATTRIB(UTE)?S?|CDB|AWR_PDB|REDUCED');
    cleanNewview := REGEXP_REPLACE(newview,
       'CDB|DATABASE|_| |HIST|ATTRIB(UTE)?S?|AWRI\$');

    if (cleanOldview <> cleanNewview) then
      RETURN NULL;
    end if;

    RETURN newview;

  end isLegalOwnerViewName;

end CDBView;
/

@?/rdbms/admin/sqlsessend.sql
