Rem
Rem $Header: rdbms/admin/xdbuo111.sql /main/4 2017/04/27 17:09:45 raeburns Exp $
Rem
Rem xdbuo111.sql
Rem
Rem Copyright (c) 2013, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      xdbuo111.sql - XDB Upgrade RDBMS Objects from 11.1.0
Rem
Rem    DESCRIPTION
Rem     This script upgrades the base XDB objects from release 11.1.0
Rem     to the current release.
Rem
Rem    NOTES
Rem     It is invoked by xdbuo.sql, and invokes the xdbuoNNN script for the 
Rem     subsequent release.
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/xdbuo111.sql 
Rem    SQL_SHIPPED_FILE: rdbms/admin/xdbuo111.sql 
Rem    SQL_PHASE: UPGRADE 
Rem    SQL_STARTUP_MODE: UPGRADE 
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: rdbms/admin/xdbuo.sql 
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    raeburns    04/15/17 - Bug 25790192: Use UPGRADE for SQL_PHASE
Rem    qyu         07/25/16 - add file metadata
Rem    skayoor     11/30/14 - Proj 58196: Change Select priv to Read Priv
Rem    raeburns    10/25/13 - XDB upgrade restructure
Rem    raeburns    10/25/13 - Created

Rem ================================================================
Rem BEGIN XDB RDBMS Object Upgrade from 11.1.0
Rem ================================================================

-- BEGIN from xdbs111.sql


-- utility functions may not have been dropped during prior upgrade from 10.2
-- drop them here
@@xdbuud2


-- increase maxval for namesuff_seq
alter sequence xdb.xdb$namesuff_seq maxvalue 99999;

-- schema_t version attribute should have length 4000
declare
  ubound  number;
  prvers varchar2(30);
  len     NUMBER;
begin
  select UPPER_BOUND into ubound
  from dba_coll_types
  where owner = 'XDB' and type_name = 'XDB$FACET_LIST_T';
  
  -- check if this has been upgraded previously
  select prv_version into prvers from registry$ where cid='XDB';

  if ((ubound < 65536) and (prvers is not null)) then
    -- Artificially increase facet_list_t version number to match table data
    -- Needed because a reset might have done on type during an earlier upgrade from 9.2
    execute immediate 
      'alter type xdb.xdb$facet_list_t 
       modify limit 65536 cascade not including table data';
    dbms_output.put_line('altered facet list limit');
  end if;

  select LENGTH into len
  from dba_type_attrs
  where owner = 'XDB' and TYPE_NAME = 'XDB$SCHEMA_T'
  and ATTR_NAME = 'VERSION';

  if(len < 4000) then
    -- DDL change to schema table
     execute immediate 
       'alter type XDB.XDB$SCHEMA_T 
        modify attribute version varchar2(4000) cascade not including table data';
     dbms_output.put_line('altered schema_t version attr');
  end if;

  if(((ubound < 65536) and (prvers is not null)) or 
     (len < 4000)) then
    -- Upgrade data for tables depending on xdb$facet_list_t, xdb$schema_t
    execute immediate 
      'alter table XDB.XDB$SCHEMA upgrade';
    execute immediate 
      'alter table XDB.XDB$SIMPLE_TYPE upgrade';
    execute immediate 
      'alter table XDB.XDB$COMPLEX_TYPE upgrade';
  end if;
end;
/

/*-----------------------------------------------------------------------*/
/* Update opqtype$ flag for XMLType Tables */
/*-----------------------------------------------------------------------*/
column table_name format a35
column opqflg format a9
column obj# format 999999
select o.obj#, '"'||u.name||'"."'||o.name||'"' table_name,
       '0x'||ltrim(rawtohex(utl_raw.cast_from_binary_integer(opq.flags)),'0') opqflg
from sys.obj$ o, sys.user$ u, xdb.xdb$element e,
     sys.opqtype$ opq, sys.tab$ t, sys.col$ c
where o.owner#=u.user# 
  and e.xmldata.default_table is not null 
  and e.xmldata.sql_inline = '00'
  and e.xmldata.property.global = '01' 
  and u.name = e.xmldata.default_table_schema
  and o.name = e.xmldata.default_table
  and opq.obj# = o.obj# and t.obj# = o.obj#
  and c.obj# = opq.obj# and c.intcol# = opq.intcol#
  and bitand(c.property, 512) = 512 --  rowinfo column
  and bitand(opq.flags, 32) = 32    --  OOL
order by 1, 2
/

select d.TABLE_NAME, d.SCHEMA_OWNER||'.'||d.ELEMENT_NAME element_name,
       d.STORAGE_TYPE, o.obj#, 
       '0x'||ltrim(rawtohex(utl_raw.cast_from_binary_integer(opq.flags)),'0') opqflg
from DBA_XML_TABLES d, sys.obj$ o, sys.opqtype$ opq, sys.user$ u, sys.col$ c
where o.name = d.table_name and o.owner# = u.user# and u.name = d.owner
  and o.obj# =  opq.obj#
  and c.obj# = opq.obj# and c.intcol# = opq.intcol#
  and bitand(c.property, 512) = 512  --  rowinfo column
  and bitand(opq.flags, 1024) = 0    -- xmltype table
/

-- XMLType tables should have KKDOOPQF_XMLTYPETABLE set
update sys.opqtype$ op
set op.flags = utl_raw.cast_to_binary_integer
               (
                  utl_raw.bit_or
                  (
                     utl_raw.cast_from_binary_integer(op.flags), 
                     utl_raw.cast_from_binary_integer(1024)
                  )
               )
where (op.obj#, op.intcol#) in 
   (select opq.obj#, opq.intcol#
    from sys.obj$ o, sys.user$ u, sys.opqtype$ opq, sys.col$ c, sys.coltype$ ac, sys.tab$ t
    where o.owner#=u.user#
    and o.obj# = t.obj#
    and bitand(t.property, 1) = 1
    and opq.obj# = o.obj#
    and c.obj# = ac.obj#
    and c.intcol# = ac.intcol#
    and ac.toid = '00000000000000000000000000020100'
    and c.obj# = opq.obj# and c.intcol# = opq.intcol#
    and bitand(c.property, 512) = 512  /* rowinfo column */ 
    and bitand(opq.flags, 1024) = 0    /* flag not already set xmltype table */
    );

-- Default tables for global schema element are not OOL
update sys.opqtype$ op
set op.flags = op.flags - 32 
where (op.obj#, op.intcol#) in 
   (select opq.obj#, opq.intcol#
    from sys.obj$ o, sys.user$ u, xdb.xdb$element e,
         sys.opqtype$ opq, sys.tab$ t, sys.col$ c
    where o.owner#=u.user# 
      and e.xmldata.default_table is not null 
      and e.xmldata.sql_inline = '00'
      and e.xmldata.property.global = '01' 
      and u.name = e.xmldata.default_table_schema
      and o.name = e.xmldata.default_table
      and opq.obj# = o.obj# and t.obj# = o.obj#
      and c.obj# = opq.obj# and c.intcol# = opq.intcol#
      and bitand(c.property, 512) = 512 --  rowinfo column
      and bitand(opq.flags, 32) = 32    --  OOL
   );

begin
  begin
    execute immediate 'drop procedure sys.set_tablespace';
    exception
       when others then
          if (SQLCODE != -4043) then
            raise;
          end if;
  end;
  begin
    execute immediate 'drop procedure sys.movexdb_table';
    exception
       when others then
          if (SQLCODE != -4043) then
            raise;
          end if;
  end;
  begin
    execute immediate 'drop procedure sys.movexdb_table_part2';
    exception
       when others then
          if (SQLCODE != -4043) then
            raise;
          end if;
  end;
end;
/

Rem Data Pump has the new requirement that users granted 
Rem DATAPUMP_FULL_EXP_DATABASE be able to export in FULL mode
Rem tables in the XDB schema. The advise is actually to grant
Rem SELECT on XDB tables to the SELECT_CATALOG_ROLE, which in 
Rem turn is granted to DATAPUMP_FULL_EXP_DATABASE, to be in sync
Rem with other components to be supported by FULL export.
Rem Some XDB tables are actually allowing PUBLIC access, so this
Rem grant will be a noop for them, but some do not. 
Rem If other XDB scripts are run beyond this point,
Rem it is the responsability of the script developer to allow similar
Rem grants on any XDB-owned tables that may get created in the script.
Rem
prompt Granting SELECT on XDB tables to SELECT_CATALOG_ROLE
prompt ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

set serveroutput on

declare
  type    cur_type is ref cursor;
  cur     cur_type;
  tname   varchar2(100);
  stmt    varchar2(2000);
begin
  open cur for 'select table_name from dba_tables where owner=:1 union ' ||
               'select table_name from dba_object_tables where owner=:2 ' 
    using 'XDB', 'XDB';
  loop
    fetch cur into tname;
    exit when cur%NOTFOUND;

    tname := 'XDB."' ||    tname || '"';
    stmt := 'grant select on ' || tname || ' to SELECT_CATALOG_ROLE';
    begin
       execute immediate stmt;
       exception
          when OTHERS then
             if ((SQLCODE != -22812) and (SQLCODE != -30967)) then
               dbms_output.put_line(stmt);
               dbms_output.put_line(SQLERRM);
             end if;
    end;
  end loop;
end;
/

set serveroutput off

/*-----------------------------------------------------------------------*/
/*  Upgrade XMLIndex type -- moved from xdbu111.sql */
/*-----------------------------------------------------------------------*/

drop table XDB.XDB$XIDX_IMP_T;
create global temporary table XDB.XDB$XIDX_IMP_T
                                (index_name VARCHAR2(40), 
                                 schema_name VARCHAR2(40),
                                 id VARCHAR2(40), 
                                 data CLOB,
                                 grppos NUMBER)
       on commit preserve rows;
 grant insert, select, delete on XDB.XDB$XIDX_IMP_T to public;

/*
 The ALTER TYPE statements for xdb.XMLIndexMethods need to precede the type body compile in
 catxidx.sql (invoked from xdbptrl1.sql).  The CREATE OR REPLACE TYPE statement in 
 catxidx.sql does not replace the type specification because there are dependent objects 
 (and the error is suppressed in UPGRADE mode since it is a "normal" error.)  So ALTER TYPE
 statements are needed.
*/

-- alter type in xdb.XMLIndexMethods
-- first drop the old definition
 ALTER TYPE xdb.XMLIndexMethods DROP  static function ODCIIndexGetMetadata(idxinfo IN sys.ODCIIndexInfo, expver IN VARCHAR2, len_newblock OUT number, idxenv IN sys.ODCIEnv) return VARCHAR2;

-- create new definition
 ALTER TYPE xdb.XMLIndexMethods ADD  static function ODCIIndexGetMetadata(idxinfo IN sys.ODCIIndexInfo, expver IN VARCHAR2, newblock OUT number, idxenv IN sys.ODCIEnv) return VARCHAR2;

ALTER TYPE xdb.XMLIndexMethods ADD static function ODCIIndexUtilGetTableNames(ia IN sys.ODCIIndexInfo, read_only IN PLS_INTEGER, version IN varchar2, context OUT PLS_INTEGER) return BOOLEAN;

ALTER TYPE xdb.XMLIndexMethods ADD static procedure ODCIIndexUtilCleanup (context  IN PLS_INTEGER);

-- END from xdbs111.sql

-- BEGIN from xdbu111.sql

/*-----------------------------------------------------------------------*/
/*  Set 'UNSTRUCTURED PRESENT' flag for all XML indexes where flag is not */
/*  yet set.  This is valid because there are only unstructured XML  */
/*  indexes in 11.1.0.7. It is also required because on 11.2 we differentiate */
/*  structured and unstructured component using this flag. */
/*-----------------------------------------------------------------------*/
BEGIN
EXECUTE IMMEDIATE 'UPDATE xdb.xdb$dxptab 
                   SET flags = flags + 268435456 
                   WHERE bitand(flags, 268435456) = 0';
EXCEPTION
  WHEN others THEN dbms_output.put_line('XDBNB: xdb$dxptab flag update failed');
end;
/
commit;

create index xdb.xdb$resource_acloid_idx on XDB.XDB$RESOURCE e (e.xmldata.ACLOID);

grant execute on xdb.xdb$nlocks_t to public with grant option;

/*-----------------------------------------------------------------------*/
/*  Create XDB$REPOS table */
/*-----------------------------------------------------------------------*/
CREATE TABLE XDB.XDB$REPOS
(
   obj#         NUMBER NOT NULL,
   flags        NUMBER,
   rootinfo#    NUMBER,
   hindex#      NUMBER,
   hlink#       NUMBER,
   resource#    NUMBER,
   acl#         NUMBER,
   config#      NUMBER,
   dlink#       NUMBER,
   nlocks#      NUMBER,
   stats#       NUMBER,
   checkouts#   NUMBER,
   resconfig#   NUMBER
);

/*-----------------------------------------------------------------------*/
/*  Create XDB$MOUNTS table */
/*-----------------------------------------------------------------------*/
CREATE TABLE XDB.XDB$MOUNTS
(
   dobj#        NUMBER,
   dpath        VARCHAR2(4000),
   sobj#        NUMBER,
   flags        NUMBER
);

begin
  execute immediate 'drop trigger xdb.xdb_pi_trig';
exception
  when others then null;
end;
/


/*-----------------------------------------------------------------------*/
/*  Add indexes to xdb.xdb$element */
/*-----------------------------------------------------------------------*/
BEGIN
  /* parent_schema */
  execute immediate 
    'CREATE INDEX xdb.xdb$element_ps ON ' ||
    '  xdb.xdb$element e (sys_op_r2o(e.xmldata.property.parent_schema))';   

  /* propref_ref */
  execute immediate
    'CREATE INDEX xdb.xdb$element_pr ON ' || 
    '  xdb.xdb$element e (sys_op_r2o(e.xmldata.property.propref_ref))'; 

  /* type_ref */
  execute immediate
    'CREATE INDEX xdb.xdb$element_tr ON ' ||
    '  xdb.xdb$element e (sys_op_r2o(e.xmldata.property.type_ref))'; 

  /* head_elem_ref */
  execute immediate
    'CREATE INDEX xdb.xdb$element_her ON ' ||
    '  xdb.xdb$element ct (sys_op_r2o(ct.xmldata.head_elem_ref))';

  /* global */
  execute immediate 
    'CREATE  BITMAP index xdb.xdb$element_global ON ' ||
    '  xdb.xdb$element e (e.xmldata.property.global)';

  /* sequence_kid */
  execute immediate
    'CREATE INDEX xdb.xdb$complex_type_sk ON ' ||
    '  xdb.xdb$complex_type ct (sys_op_r2o(ct.xmldata.sequence_kid))'; 

  /* choice_kid */
  execute immediate
    'CREATE INDEX xdb.xdb$complex_type_ck ON ' ||
    '  xdb.xdb$complex_type ct (sys_op_r2o(ct.xmldata.choice_kid))'; 

  /* all_kid */
  execute immediate
    'CREATE INDEX xdb.xdb$complex_type_ak ON ' ||
    '  xdb.xdb$complex_type ct (sys_op_r2o(ct.xmldata.all_kid))';
EXCEPTION
  WHEN others THEN dbms_output.put_line('XDBNB: xdb$element index not created');
END;
/
commit;

/*-----------------------------------------------------------------------*/
/* Explicit grants to DBA,System; "any" privileges are no more applicable for */
/* XDB tables. Listing these specifically since there are certain tables */
/* for which we dont grant full access by default even to DBA & System. */
/* (eg, purely-dictionary tables like XDB$SCHEMA, XDB$TTSET etc.) */
/*-----------------------------------------------------------------------*/
grant all on XDB.XDB$RESOURCE to dba;
grant all on XDB.XDB$RESOURCE to system with grant option;
grant all on XDB.XDB$H_INDEX to dba;
grant all on XDB.XDB$H_INDEX to system with grant option;
grant all on XDB.XDB$H_LINK to dba;
grant all on XDB.XDB$H_LINK to system with grant option;
grant all on XDB.XDB$D_LINK to dba;
grant all on XDB.XDB$D_LINK to system with grant option;
grant all on XDB.XDB$NLOCKS to dba;
grant all on XDB.XDB$NLOCKS to system with grant option;
grant all on XDB.XDB$CHECKOUTS to dba;
grant all on XDB.XDB$CHECKOUTS to system with grant option;
grant all on XDB.XDB$ACL to dba;
grant all on XDB.XDB$ACL to system with grant option;
grant all on XDB.XDB$CONFIG to dba;
grant all on XDB.XDB$CONFIG to system with grant option;
grant all on XDB.XDB$RESCONFIG to dba;
grant all on XDB.XDB$RESCONFIG to system with grant option;

-- ensure that public has limited privileges on acl table
revoke all on XDB.XDB$ACL from public;
grant read, insert, update, delete on XDB.XDB$ACL to public;
commit;

-- lrg 4337840
-- Remove 'with grant option' by revoking rights and
-- re-granting without grant option.
revoke execute on XDB.DBMS_XMLSCHEMA from public;
revoke execute on XDB.DBMS_XMLSCHEMA_INT from public;

-- Both sys and xdb might appear as grantors, revoke again
BEGIN
  EXECUTE IMMEDIATE 'revoke execute on XDB.DBMS_XMLSCHEMA from public';
EXCEPTION
 WHEN OTHERS THEN NULL;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'revoke execute on XDB.DBMS_XMLSCHEMA_INT from public';
EXCEPTION
 WHEN OTHERS THEN NULL;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'revoke execute on SYS.SYS_IXQAGGSUM from public';
EXCEPTION
 WHEN OTHERS THEN NULL;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'revoke execute on SYS.SYS_IXQAGGAVG from public';
EXCEPTION
 WHEN OTHERS THEN NULL;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'revoke execute on SYS.XQSEQUENCEFROMXMLTYPE  from public';
EXCEPTION
 WHEN OTHERS THEN NULL;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'revoke execute on SYS.SYS_IXQAGG from public';
EXCEPTION
 WHEN OTHERS THEN NULL;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'revoke execute on SYS.SYS_IXMLAGG from public';
EXCEPTION
 WHEN OTHERS THEN NULL;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'revoke execute on SYS.SYS_XMLAGG from public';
EXCEPTION
 WHEN OTHERS THEN NULL;
END;
/


grant execute on XDB.DBMS_XMLSCHEMA to public;
grant execute on XDB.DBMS_XMLSCHEMA_INT to public;

BEGIN
  EXECUTE IMMEDIATE 'grant execute on SYS.SYS_XMLAGG to public';
EXCEPTION
 WHEN OTHERS THEN NULL;
END;
/
BEGIN
  EXECUTE IMMEDIATE 'grant execute on SYS.SYS_IXMLAGG to public';
EXCEPTION
 WHEN OTHERS THEN NULL;
END;
/
BEGIN
  EXECUTE IMMEDIATE 'grant execute on SYS.SYS_IXQAGG to public';
EXCEPTION
 WHEN OTHERS THEN NULL;
END;
/
BEGIN
  EXECUTE IMMEDIATE 'grant execute on SYS.XQSEQUENCEFROMXMLTYPE to public';
EXCEPTION
 WHEN OTHERS THEN NULL;
END;
/
BEGIN
  EXECUTE IMMEDIATE 'grant execute on SYS.SYS_IXQAGGAVG to public';
EXCEPTION
 WHEN OTHERS THEN NULL;
END;
/
BEGIN
  EXECUTE IMMEDIATE 'grant execute on SYS.SYS_IXQAGGSUM to public';
EXCEPTION
 WHEN OTHERS THEN NULL;
END;
/


-- END from xdbu111.sql

--Upgrade xtab tables (needed for changes in 11.2 upgrade)
@@catxtbix.sql

Rem ================================================================
Rem END XDB RDBMS Object Upgrade from 11.1.0
Rem ================================================================

Rem ================================================================
Rem BEGIN XDB RDBMS Object Upgrade from the next release
Rem ================================================================

@@xdbuo112.sql

