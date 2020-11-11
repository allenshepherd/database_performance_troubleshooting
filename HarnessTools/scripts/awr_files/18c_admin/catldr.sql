rem 
rem $Header: rdbms/admin/catldr.sql /st_rdbms_18.0/1 2017/12/03 18:10:57 jstenois Exp $ ulview.sql 
rem
Rem Copyright (c) 1990, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem NAME
Rem    catldr.sql
Rem  FUNCTION
Rem    Views for the direct path of the loader
Rem  NOTES
Rem    This script must be run while connected as SYS or INTERNAL.
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catldr.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catldr.sql
Rem SQL_PHASE: CATLDR
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catalog.sql
Rem END SQL_FILE_METADATA
Rem
Rem  MODIFIED
Rem     jstenois   11/29/17 - XbranchMerge jstenois_bug-27126506 from main
Rem     jstenois   11/15/17 - 27126506: create private synonym for
Rem                           datapump_dir_objs so that older data pump clients
Rem                           work
Rem     tmontgom   11/01/17 - BUG 27057144. Add public synonym
Rem                           DATAPUMP_DIR_OBJS for older datapump clients like
Rem                           12.2.0.1.
Rem     msakayed   06/21/16 - Bug #23625806: use CURRENT_USER in 
Rem                           LOADER_COL_INFO (security bug)
Rem     jstenois   10/01/15 - 21839715: fix LOADER_DIR_OBJS for application 
Rem                           roots
Rem     msakayed   03/06/15 - Lrg #15305720: fix LOADER_DIR_OBJS
Rem     msakayed   02/19/15 - Bug #20354576: use ORA_CHECK_SYS_PRIVILEGE
Rem     skayoor    11/30/14 - Proj 58196: Change Select priv to Read Priv
Rem     surman     12/29/13 - 13922626: Update SQL metadata
Rem     sasounda   11/19/13 - 17746252: handle KZSRAT when creating all_* views
Rem     mwjohnso   01/31/13 - Bug 16007711: LOADER_DB_OPEN_READ_WRITE view
Rem     krajaman   10/01/12 - Use X$DIR
Rem     jstenois   03/30/12 - lrg 679003: get queue table info from tab$ for
Rem                           LOADER_PART_INFO
Rem     surman     03/27/12 - 13615447: Add SQL patching tags
Rem     rphillip   05/03/11 - Bug 12418269 Find lob index columns
Rem     msakayed   04/03/08 - add "execute" column to LOADER_DIR_OBJS
Rem     spetride   05/16/07 - lrg 2881117: LOADER_OID_INFO: do not count
Rem                           NTAB SETID, hidden columns as primary key
Rem     msakayed   05/25/06 - Project 18265: virtual column support
Rem     msakayed   04/03/06 - system partitioning support (LOADER_PART_INFO)
Rem     achoi      05/15/06 - handle application edition 
Rem     msakayed   08/30/04 - column encryption support (project id 5578) 
Rem     rphillip   05/08/03 - Add view to get full attribute name
Rem     msakayed   02/10/03 - Add security clause to loader views
Rem     rphillip   12/02/02 - Add view to check for nested varray tables
Rem     preilly    11/22/02 - Add view to get version of type used for a column
Rem     msakayed   11/11/02 - remove hard tabs
Rem     msakayed   11/01/02 - Bug #2643907: add LOADER_SKIP_UNUSABLE_INDEXES
Rem     preilly    10/16/02 - Add view to get lob property
Rem     preilly    02/18/02 - Fix char length semantics on unscoped pk ref args
Rem     cmlim      01/28/02 - bug 1989330 - support unscoped pk refs
Rem     cmlim      11/13/01 - bug 2093119
Rem     gviswana   05/24/01 - CREATE OR REPLACE SYNONYM
Rem     jstenois   03/19/01 - improve LOADER_DIR_OBJS definition
Rem     jstenois   03/12/01 - update LOAD_DIR_OBJS
Rem     abrumm     02/03/01 - LOADER_DIR_OBJS_PRIV: let SYS see dir objects
Rem     jstenois   01/20/01 - check for read and write privs on DIR OBJECTS
Rem     jstenois   01/10/01 - add view for writable directories
Rem     jstenois   08/30/00 - move external table types to dbmspump
Rem     cevankov   07/28/00 -
Rem     cevankov   07/20/00 -  add External Table support (directory object)
Rem     nkandalu   06/15/99  - Bug#902012: Add columns to LOADER_TRIGGER_INFO  
Rem     abrumm     03/24/99 -  index error fixed table view
Rem     vnimani    08/31/98  - add view to check the type of the ref           
Rem     nlau       04/28/98 -  Bug #359063: re-write LOADER_CONSTRAINT_INFO
Rem     rjenkins   12/03/97 -  using ENABLE NOVALIDATE constraints
Rem     abrumm     03/23/97 -  Bug #462556: fix FILE= for partitioned tables
Rem     abrumm     08/19/96 -  ldr_bmx_mrg: delete LOADER_IND*_INFO views
Rem     mcoyle     08/26/96 -  add gv$ public synonyms
Rem     mmonajje   05/22/96 -  Replace precision col name with precision#
Rem     abrumm     02/26/96 -  TSRDBA: LOADER_FILE_TS returns rel fileno
Rem     jhealy     01/04/96 -  partition support: add partition stats view
Rem     jhealy     01/16/96 -  remove bitmap index spare8 query
Rem     jhealy     11/07/95 -  bitmap index support phase 1
Rem     skaluska   10/04/95 -  Rename unique$ to property
Rem     wmaimone   05/06/94 -  #184921 run as sys/internal
Rem     ksudarsh   04/07/94 -  update loader_constraints_info
Rem     ksudarsh   02/06/94 -  merge changes from branch 1.3.710.2
Rem     ksudarsh   02/04/94 -  fix authorizations
Rem     jbellemo   12/17/93 -  merge changes from branch 1.3.710.1
Rem     jbellemo   11/29/93 -  #170173: change uid to userenv schemaid
Rem     ksudarsh   11/02/92 -  pdl changes 
Rem     tpystyne   11/22/92 -  use create or replace view 
Rem     glumpkin   10/25/92 -  Renamed from ULVIEW.SQL 
Rem     cheigham   04/28/92 -  users should see info only on tables on which th
Rem     cheigham   10/26/91 -  Creation 
Rem     cheigham   10/07/91 -  add lists, groups to tab,ind views
Rem     cheigham   09/30/91 -  merge changes from branch 1.3.50.2 
Rem     cheigham   09/23/91 -  fix cdef$ column reference 
Rem     cheigham   08/27/91 -  add ts# to loader_tab_info: 
Rem     cheigham   04/11/91 -         expand loader_constraint_info 
Rem   Heigham    09/26/90 - fix v7 LOADER_TRIGGER_INFO def
Rem   Heigham    07/16/90 - remove duplicate grant
Rem   Heigham    06/28/90 - add v$parameters grant
Rem   Heigham    01/22/90 - Creation
Rem

@@?/rdbms/admin/sqlsessstart.sql
rem 

create or replace view LOADER_TAB_INFO
(NAME, NUMCOLS, OWNER, OBJECTNO, TABLESPACENO, PARTITIONED)
as
select o.name, t.cols, u.name, t.obj#, t.ts#,
       decode(bitand(t.property, 32), 32, 'YES', 'NO')
from sys.tab$ t, sys.obj$ o, sys.user$ u
where t.obj# = o.obj#
and o.owner# = u.user#
 and (o.owner# = userenv('schemaid')
       or o.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               )
            )
       or 
          ora_check_SYS_privilege (o.owner#, o.type#) = 1
      )
/
create or replace public synonym LOADER_TAB_INFO for LOADER_TAB_INFO
/
grant read on LOADER_TAB_INFO to PUBLIC
/

create or replace view LOADER_PART_INFO
(PNAME, TNAME, OWNER, OBJECTNO, BASEOBJECTNO, TABLESPACENO, PARTTYPE,
 PARTPOS, QTABLE)
as
select 
  o.subname                                                 as pname,
  o.name                                                    as tname,
  u.name                                                    as owner,
  tp.obj#                                                   as objectno,
  tp.bo#                                                    as baseobjectno,
  tp.ts#                                                    as tablespaceno,
  po.parttype                                               as parttype,
  row_number() over (partition by tp.bo# order by tp.part#) as partpos,
  decode(bitand(t.property, 131072), 131072, 'T', 'F')      as qtable
from sys.obj$ o, sys.tabpart$ tp, sys.partobj$ po, user$ u, tab$ t
where o.obj#   = tp.obj#
and   po.obj#  = tp.bo#
and   o.owner# = u.user#
and   t.obj# = tp.bo#
 and (o.owner# = userenv('schemaid')
       or o.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               )
            )
       or 
          ora_check_SYS_privilege (o.owner#, o.type#) = 1
      )
/
create or replace public synonym LOADER_PART_INFO for LOADER_PART_INFO
/
grant read on LOADER_PART_INFO to PUBLIC
/

create or replace view LOADER_PARAM_INFO
(BLOCKSZ, SERIALIZABLE)
as 
select v1.value, v2.value from v$parameter v1, v$parameter v2
where v1.name = 'db_block_size' and  v2.name = 'serializable'
/
create or replace public synonym LOADER_PARAM_INFO for LOADER_PARAM_INFO
/
grant read on LOADER_PARAM_INFO to PUBLIC
/
remark
remark VIEWS FOR FIXED TABLES OF STATISTICS
remark
remark CONTROL BLOCK STATS 
remark - None 
remark
remark TABLE STATS 
remark - None 
remark
remark PARTITION STATS 
remark
create or replace view gv_$loadpstat as select * from gv$loadpstat;
create or replace public synonym gv$loadpstat for gv_$loadpstat;
grant read on gv_$loadpstat to public;
remark
remark INDEX ERRORS/MESSAGES
remark
create or replace view gv_$loadistat as select * from gv$loadistat;
create or replace public synonym gv$loadistat for gv_$loadistat;
grant read on gv_$loadistat to public;
remark
remark PARTITION STATS 
remark
create or replace view v_$loadpstat as select * from v$loadpstat;
create or replace public synonym v$loadpstat for v_$loadpstat;
grant read on v_$loadpstat to public;
remark
remark INDEX ERRORS/MESSAGES
remark
create or replace view v_$loadistat as select * from v$loadistat;
create or replace public synonym v$loadistat for v_$loadistat;
grant read on v_$loadistat to public;
remark
remark VIEWS FOR V7
create or replace view LOADER_CONSTRAINT_INFO
(OWNER, CONSTRAINT_NAME, CONSTRAINT_NUMBER, TYPE, TABLE_NAME, ENABLED,DEFER)
as
   select /*+ ordered index (cd i_cdef2) */
       u.name, con.name, cd.con#, cd.type#,o.name, cd.enabled,nvl(cd.defer,0)
   from sys.user$ u, sys.obj$ o, sys.cdef$ cd, sys.con$ con
   where   o.owner# = u.user#
   and    cd.obj#   = o.obj#
   and   con.con#   = cd.con#
   and (o.owner# = userenv('schemaid')
         or o.obj# in
              (select oa.obj#
               from sys.objauth$ oa
               where grantee# in ( select kzsrorol
                                   from x$kzsro
                                 )
              )
         or 
            ora_check_SYS_privilege (o.owner#, o.type#) = 1
        )
/
create or replace public synonym LOADER_CONSTRAINT_INFO
   for LOADER_CONSTRAINT_INFO
/
grant read on LOADER_CONSTRAINT_INFO to PUBLIC
/
create or replace view LOADER_TRIGGER_INFO
(TRIGGER_OWNER, TRIGGER_NAME, TABLE_OWNER, TABLE_NAME, ENABLED)
as
   select u1.name, o1.name, u.name, o.name, t.enabled
   from sys.obj$ o, sys."_CURRENT_EDITION_OBJ" o1, sys.user$ u, sys.user$ u1,
        sys.trigger$ t
   where t.baseobject = o.obj#
   and o.owner# = u.user#
   and o1.owner# = u1.user#
   and t.obj# = o1.obj#
 and (o.owner# = userenv('schemaid')
       or o.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               )
            )
       or 
          ora_check_SYS_privilege (o.owner#, o.type#) = 1
     )
/
create or replace public synonym LOADER_TRIGGER_INFO for LOADER_TRIGGER_INFO
/
grant read on LOADER_TRIGGER_INFO to PUBLIC
/
remark
remark VIEWS for Parallel Data Loader
remark  Note: FILENO is now a relative file number.
remark
create or replace view LOADER_FILE_TS
(TABLESPACENO, FILENAME, FILENO)
as
   select file$.ts#, v$dbfile.name, file$.relfile# 
   from file$, v$dbfile
   where file$.file# = v$dbfile.file#
/
create or replace public synonym LOADER_FILE_TS for LOADER_FILE_TS
/
grant read on LOADER_FILE_TS to public
/

remark ==================================================================
remark
remark VIEW for checking ref type (pk or system based)
remark __________________________________________________________________
create or replace view LOADER_REF_INFO 
(OWNER, TABLE_NAME, OBJECT_ID_TYPE)
as 
        select owner, table_name, object_id_type
        from all_object_tables
/
create or replace public synonym LOADER_REF_INFO for LOADER_REF_INFO
/
grant read on LOADER_REF_INFO to public
/

remark ==================================================================
remark
remark VIEW for getting column information of the column(s) that make up
remark an OID.  Tables retrieved are only the tables that are accessible to the
remark user who executed the query statement against this view.
remark
remark OWNER - owner of object table 
remark TABLE_NAME - name of object table
remark OID_TYPE - oid type: 1 is system-generated, 2 is primary key
remark COLUMN_NAME - column that makes up the primary key OID
remark COLUMN_TYPE - column data type 
remark LENGTH - column length
remark CHAR_LENGTH - length in characters
remark PRECISION - precision
remark SCALE - scale
remark NULLABLE - 1 if column allows null values, 0 if can't
remark CHARSETID - character set id
remark INDEX_POSITION - column's position in index
remark CHAR_LENGTH_SEMANTICS - TRUE if using character length semantics
remark __________________________________________________________________
create or replace view LOADER_OID_INFO
(TABLE_OWNER, TABLE_NAME, OID_TYPE, COLUMN_NAME, COLUMN_TYPE, LENGTH, 
 CHAR_LENGTH, PRECISION, SCALE, NULLABLE, CHARSETID, INDEX_POSITION, 
 CHAR_LENGTH_SEMANTICS) 
as 
        select u.name, o.name, 
               decode(c.property, 1056, 1, decode(bitand(c.property, 2), 0, 2, 1)),
               decode(ac.name, null, c.name, ac.name),
               c.type#, c.length, c.spare3, 
               decode(c.precision#, null, 0, c.precision#),
               decode(c.scale, null, 0, c.scale),
               decode(sign(c.null$), 0, 1, 0), c.charsetid, ic.pos#, 
               decode(bitand(c.property, 8388608), 8388608, 1, 0)
        from sys.col$ c, sys.obj$ o, sys.user$ u, sys.attrcol$ ac, 
             sys.icol$ ic
        where o.owner# = u.user# and c.obj# = o.obj#
          and c.obj# = ac.obj# (+) and c.intcol# = ac.intcol# (+)
          and c.obj# = ic.bo# and c.col# = ic.col# 
          and c.intcol# = ic.intcol# 
          and (o.owner# = userenv('SCHEMAID')
                or o.obj# in
                     (select oa.obj#
                      from sys.objauth$ oa
                      where grantee# in ( select kzsrorol
                                          from x$kzsro
                                        )
                     )
                or 
                   ora_check_SYS_privilege (o.owner#, o.type#) = 1
              )
        order by o.obj#, ic.pos#
/
create or replace public synonym LOADER_OID_INFO for LOADER_OID_INFO
/
grant read on LOADER_OID_INFO to public
/

Rem
Rem View which returns READ/WRITE/EXECUTE permission on an oracle directory
Rem object for the querying user.
Rem NOTE:
Rem  First case:
Rem    SYS owns all directory objects, hence has read/write/execute privilege
Rem    on all directory objects.  
Rem  Second case:
Rem    Usage of "group by" to group all directory objects
Rem    for which the requesting user has a read(17)/write(18)/execute(12)
Rem    privilege grant.  The sum(decode) results in either non-zero, or
Rem    zero if the requesting user has a corresponding grant.
Rem
Rem  Note also that (select kszrorol from x$kzsro) returns all roles
Rem  for which the requesting user has grants for (including their
Rem  own UID.)
Rem
Rem  note that o.type# = 23 is the type for Oracle directory objects.
Rem
create or replace view LOADER_DIR_OBJS
(name, path, read, write, execute) as
  SELECT d.directory_name, d.directory_path, 'TRUE', 'TRUE', 'TRUE'
    FROM sys.obj$ o, sys.int$dba_directories d
   WHERE o.obj#=OBJ_ID(d.OWNER, d.DIRECTORY_NAME, d.OBJECT_TYPE#, d.OBJECT_ID)
     AND o.type# = 23
     AND ora_check_SYS_privilege (o.owner#, o.type#) = 1
  UNION ALL
  SELECT d.directory_name, d.directory_path,
         decode(sum(decode(oa.privilege#,17,1,0)),0, 'FALSE','TRUE'),
         decode(sum(decode(oa.privilege#,18,1,0)),0, 'FALSE','TRUE'),
         decode(sum(decode(oa.privilege#,12,1,0)),0, 'FALSE','TRUE')
    FROM sys.obj$ o, sys.int$dba_directories d, sys.objauth$ oa
   WHERE oa.obj#=OBJ_ID(d.OWNER, d.DIRECTORY_NAME, d.OBJECT_TYPE#, d.OBJECT_ID)
     AND o.type# = 23
     AND oa.obj#=o.obj#
     AND oa.privilege# IN (12,17,18)
     AND grantee# IN (SELECT kzsrorol FROM x$kzsro)
     AND ora_check_SYS_privilege (o.owner#, o.type#) != 1
    GROUP BY d.directory_name, d.directory_path
/

create or replace public synonym LOADER_DIR_OBJS for LOADER_DIR_OBJS
/

create or replace public synonym DATAPUMP_DIR_OBJS for SYS.LOADER_DIR_OBJS
/

create or replace synonym DATAPUMP_DIR_OBJS for SYS.LOADER_DIR_OBJS
/

grant read on LOADER_DIR_OBJS to public
/

remark ==================================================================
remark
remark VIEW for finding charactersetform for columns
remark __________________________________________________________________
create or replace view LOADER_COL_INFO
(TBLNAME, COLNAME, CSFORM)
as
        select o.name as tblnam,c.name as colnam,c.charsetform as csform
          from col$ c,obj$ o 
         where o.obj# = c.obj# 
         and o.type# = 2 
         and o.owner# = SYS_CONTEXT('USERENV','CURRENT_USERID')
         and 
         ( o.owner# = userenv('schemaid')
           or o.obj# in (select oa.obj#
                           from sys.objauth$ oa
                          where grantee# in (select kzsrorol from x$kzsro)
                        )
           or ora_check_SYS_privilege (o.owner#, o.type#) = 1
         )
/
create or replace public synonym LOADER_COL_INFO for LOADER_COL_INFO
/
grant read on LOADER_COL_INFO to public
/

remark ==================================================================
remark
remark VIEW for finding column property flags
remark __________________________________________________________________
remark
remark Note concerning virtual columns. Currently the concept of a virtual
remark is overloaded to also include the following:
remark 1. Nested tables and other Object types
remark 2. Functional indexes. FI created virtual columns in the table (since 
remark    the col did not exist in the table)
remark 3. XML columns which introduced their own set of virtual columns 
remark 4. User defined virtual columns. 
remark
remark We are concerned with case #4 which should look very similar to 
remark functional index based virtual columns
remark
remark Here is breakdown of the property flags also found in qcdl.h and written 
remark to property field in col$.
remark 1. Functional Indexes
remark     Should have KQLDCOP_VIR( 0x00000008), KQLDCOP_EXP (0x00010000) 
remark     KQLDCOP_HID (0x00000020) and KQLDCOP_GEN (0x0000010) properties set 
remark     in col$
remark 2. Used defined virtual columns
remark     Would have the KQLDCOP_VIR( 0x00000008), KQLDCOP_EXP (0x00010000) 
remark     bits set. Optionally KQLDCOP_HID (0x00000020) may be set if it was 
remark     created as hidden via the syntax.
remark 3. XML columns
remark     Should have the KQLDCOP_VCEXP(0x01000000) bit set in addition the 
remark     other bits they deem fit..
remark
remark In order to determine if a user virtual column is specified check the
remark KQLDCOP_VIR and KQLDCOP_EXP flags which should be set for both 
remark functional indexes and user virtual columns.  Then check the KQLDCOP_GEN
remark would only be set for functional indexes. Finally, check to make sure
remark the column is not system generated.

create or replace view LOADER_COL_FLAGS
(TABLE_OWNER, TABLE_NAME, COLNAME, PROPERTY, ISENCRYPTED, ISVIRTUAL)
as
  select u.name as table_owner, o.name as table_name, c.name as colname,
         c.property as property,
         decode(bitand(c.property, 67108864), 67108864, 1, 0) as isencrypted,
         decode((bitand ((bitand(decode(bitand(c.property, 10), 10, 0, 1),
                          decode(bitand(c.property, 256), 256, 0, 1))),
                        decode(bitand(c.property, 65544), 65544, 1, 0))), 
                1, 'YES', 'NO') isvirtual
    from sys.col$ c, sys.obj$ o, sys.user$ u 
   where o.obj# = c.obj# and u.user# = o.owner#
   and   (o.owner# = userenv('schemaid')
    or   o.obj# in (select oa.obj#
                      from sys.objauth$ oa
                      where grantee# in ( select kzsrorol
                                          from x$kzsro
                                        )
                   )
    or 
         ora_check_SYS_privilege (o.owner#, o.type#) = 1
    )
/
create or replace public synonym LOADER_COL_FLAGS for LOADER_COL_FLAGS
/
grant read on LOADER_COL_FLAGS to public
/


remark ==================================================================
remark
remark VIEW for finding lob column property flags
remark __________________________________________________________________
create or replace view LOADER_LOB_FLAGS
(TABLE_OWNER, TABLE_NAME, COLNAME, PROPERTY)
as
        select u.name as table_owner, o.name as table_name, c.name as colnam,
               l.property as property
          from sys.col$ c,sys.obj$ o, sys.lob$ l, sys.user$ u where 
            o.obj# = c.obj# and l.obj# = o.obj# and c.intcol# = l.intcol#
            and u.user# = o.owner#
            and (o.owner# = userenv('schemaid')
                  or o.obj# in
                       (select oa.obj#
                        from sys.objauth$ oa
                        where grantee# in ( select kzsrorol
                                            from x$kzsro
                                          )
                       )
                  or 
                     ora_check_SYS_privilege (o.owner#, o.type#) = 1
                 )
/
create or replace public synonym LOADER_LOB_FLAGS for LOADER_LOB_FLAGS
/
grant read on LOADER_LOB_FLAGS to public
/


remark ==================================================================
remark
remark VIEW for finding value of 'skip_unusable_indexes'
remark __________________________________________________________________
create or replace view LOADER_SKIP_UNUSABLE_INDEXES
(value)
as
  select count(*) as value from v$parameter 
   where upper(name) = 'SKIP_UNUSABLE_INDEXES' 
   and value = 'TRUE'
/

create or replace public synonym LOADER_SKIP_UNUSABLE_INDEXES for
  LOADER_SKIP_UNUSABLE_INDEXES
/
grant read on LOADER_SKIP_UNUSABLE_INDEXES to public
/

remark ==================================================================
remark
remark VIEW for finding type and version used for a column 
remark __________________________________________________________________
create or replace view LOADER_COL_TYPE
(TABLE_OWNER, TABLE_NAME, COLNAME, TOID, VERSION)
as
        select u.name as table_owner, o.name as table_name, c.name as colnam,
               ct.toid as toid, ct.version# as version
          from sys.col$ c,sys.obj$ o, sys.coltype$ ct, sys.user$ u where 
            o.obj# = c.obj# and ct.obj# = o.obj# and c.intcol# = ct.intcol#
            and u.user# = o.owner#
            and (o.owner# = userenv('schemaid')
                  or o.obj# in
                       (select oa.obj#
                        from sys.objauth$ oa
                        where grantee# in ( select kzsrorol
                                            from x$kzsro
                                          )
                       ) 
                  or 
                     ora_check_SYS_privilege (o.owner#, o.type#) = 1
                 )
/
create or replace public synonym LOADER_COL_TYPE for LOADER_COL_TYPE
/
grant read on LOADER_COL_TYPE to public
/

remark ==================================================================
remark
remark VIEW to detect nested varray tables 
remark __________________________________________________________________
create or replace view LOADER_NESTED_VARRAYS
(TABLE_OWNER, TABLE_NAME)
as
        select u.name as table_owner, o.name as table_name
        from col$ c, obj$ o, user$ u, ntab$ nt
        where o.obj# = nt.ntab# and o.owner# = u.user# and 
              c.obj# = nt.obj#  and c.type#  = 123 and c.intcol# = nt.intcol#
              and (o.owner# = userenv('schemaid')
                    or o.obj# in
                         (select oa.obj#
                          from sys.objauth$ oa
                          where grantee# in ( select kzsrorol
                                              from x$kzsro
                                            )
                         )
                    or 
                      ora_check_SYS_privilege (o.owner#, o.type#) = 1
                   )
/
create or replace public synonym LOADER_NESTED_VARRAYS 
  for LOADER_NESTED_VARRAYS
/
grant read on LOADER_NESTED_VARRAYS to public
/

remark ==================================================================
remark
remark VIEW to get fully qualified name of an object attribute  
remark __________________________________________________________________
create or replace view LOADER_FULL_ATTR_NAME
(FULL_ATTR_NAME, INTCOL_NAME, TABLE_OWNER, TABLE_NAME)
as
        select a.name as full_attr_name, c.name as intcol_name,
               u.name as table_owner,    o.name as table_name
        from sys.col$ c, sys.obj$ o, sys.user$ u, sys.attrcol$ a 
        where o.obj# = c.obj# and o.owner# = u.user# and 
              c.obj# = a.obj# and c.intcol# = a.intcol#
              and (o.owner# = userenv('schemaid')
                    or o.obj# in
                         (select oa.obj#
                          from sys.objauth$ oa
                          where grantee# in ( select kzsrorol
                                              from x$kzsro
                                            )
                         )
                    or 
                      ora_check_SYS_privilege (o.owner#, o.type#) = 1
                   )
/
create or replace public synonym LOADER_FULL_ATTR_NAME
  for LOADER_FULL_ATTR_NAME
/
grant read on LOADER_FULL_ATTR_NAME to public
/

remark ==================================================================
remark
remark View used to get the int column# of an encrypted column.
remark The int col# is required for the KZEC encryption API.
remark __________________________________________________________________
create or replace view LOADER_INTCOL_INFO
(TABLE_NAME, COL_NAME, INTCOL)
as
       select o.name as table_name, c.name as col_name, c.intcol# as intcol
          from sys.col$ c, sys.obj$ o, sys.user$ u where
            o.obj# = c.obj# and u.user# = o.owner#
            and (o.owner# = userenv('schemaid')
                  or o.obj# in
                       (select oa.obj#
                        from sys.objauth$ oa
                        where grantee# in ( select kzsrorol
                                            from x$kzsro
                                          )
                       )
                  or 
                     ora_check_SYS_privilege (o.owner#, o.type#) = 1
                 )

/
create or replace public synonym LOADER_INTCOL_INFO for LOADER_INTCOL_INFO
/
grant read on LOADER_INTCOL_INFO to public
/
remark ==================================================================
remark
remark View used to get the underlying tables for a view
remark __________________________________________________________________
create or replace view LOADER_LOB_INDEX_TAB
(TABLE_OWNER, TABLE_NAME, VIEW_OWNER, VIEW_NAME)
as
  select u1.name as table_owner, o1.name as table_name, u2.name as VIEW_OWNER,
         o2.name as VIEW_NAME
  from sys.obj$ o1, sys.obj$ o2, sys.user$ u1, sys.user$ u2, sys.dependency$ d
  where o1.owner# = u1.user# and o2.owner# = u2.user# and o1.type# = 2 and
        o2.type# = 4 and d.p_obj# = o1.obj# and d.d_obj# = o2.obj#
            and (o1.owner# = userenv('schemaid')
                  or o1.obj# in
                       (select oa.obj#
                        from sys.objauth$ oa
                        where grantee# in ( select kzsrorol
                                            from x$kzsro
                                          )
                       )
                  or 
                     ora_check_SYS_privilege (o1.owner#, o1.type#) = 1
                 )

/
create or replace public synonym LOADER_LOB_INDEX_TAB for LOADER_LOB_INDEX_TAB
/
grant read on LOADER_LOB_INDEX_TAB to public
/

remark ==================================================================
remark
remark View used to get the column name of lob index columns.
remark __________________________________________________________________
create or replace view LOADER_LOB_INDEX_COL
(TABLE_OWNER, TABLE_NAME, COLUMN_NAME)
as
  select u.name as table_owner, o.name as table_name, c.name as column_name
     from sys.col$ c, sys.obj$ o, sys.user$ u, sys.icoldep$ i
     where o.owner# = u.user# and o.type# = 2 and c.obj# = o.obj# and
           c.type# in (112, 113) and i.bo# = o.obj# and i.intcol# = c.intcol# 
           and bitand(c.property, 32) != 32
            and (o.owner# = userenv('schemaid')
                  or o.obj# in
                       (select oa.obj#
                        from sys.objauth$ oa
                        where grantee# in ( select kzsrorol
                                            from x$kzsro
                                          )
                       )
                  or 
                     ora_check_SYS_privilege (o.owner#, o.type#) = 1
                 )
UNION ALL
  select u.name as table_owner, o.name as table_name, a.name as column_name
     from sys.attrcol$ a, sys.obj$ o, sys.user$ u, sys.icoldep$ i, 
          sys.col$ c
     where o.owner# = u.user# and o.type# = 2 and c.obj# = o.obj# and
           c.type# in (112, 113) and i.bo# = o.obj# and i.intcol# = a.intcol#
           and c.intcol# = i.intcol# and a.obj# = o.obj#
            and (o.owner# = userenv('schemaid')
                  or o.obj# in
                       (select oa.obj#
                        from sys.objauth$ oa
                        where grantee# in ( select kzsrorol
                                            from x$kzsro
                                          )
                       )
                  or 
                     ora_check_SYS_privilege (o.owner#, o.type#) = 1
                 )
UNION ALL
  select u.name as table_owner, o.name as table_name, a.name as column_name
     from sys.attrcol$ a, sys.obj$ o, sys.user$ u, sys.icol$ i, sys.col$ c,
          sys.ind$ x
     where o.owner# = u.user# and o.type# = 2 and c.obj# = o.obj# and
           c.type# in (112, 113) and i.bo# = o.obj# and i.intcol# = a.intcol#
           and c.intcol# = i.intcol# and a.obj# = o.obj# and x.bo# = o.obj#
           and x.type# = 9 and i.obj# = x.obj#
            and (o.owner# = userenv('schemaid')
                  or o.obj# in
                       (select oa.obj#
                        from sys.objauth$ oa
                        where grantee# in ( select kzsrorol
                                            from x$kzsro
                                          )
                       )
                  or 
                     ora_check_SYS_privilege (o.owner#, o.type#) = 1
                 )
UNION ALL
  select u.name as table_owner, o.name as table_name, c.name as column_name
     from sys.obj$ o, sys.user$ u, sys.icol$ i, sys.col$ c, sys.ind$ x
     where o.owner# = u.user# and o.type# = 2 and c.obj# = o.obj# and
           c.type# in (112, 113) and i.bo# = o.obj# and i.intcol# = c.intcol#
           and bitand(c.property, 32) != 32 and x.bo# = o.obj#
           and x.type# = 9 and i.obj# = x.obj#
            and (o.owner# = userenv('schemaid')
                  or o.obj# in
                       (select oa.obj#
                        from sys.objauth$ oa
                        where grantee# in ( select kzsrorol
                                            from x$kzsro
                                          )
                       )
                  or 
                     ora_check_SYS_privilege (o.owner#, o.type#) = 1
                 )
/
create or replace public synonym LOADER_LOB_INDEX_COL for LOADER_LOB_INDEX_COL
/
grant read on LOADER_LOB_INDEX_COL to public
/

remark ==================================================================
remark
remark VIEW for finding if database is open for read write access
remark __________________________________________________________________
create or replace view LOADER_DB_OPEN_READ_WRITE
(results)
as
  select count(*) from v$database where open_mode = 'READ WRITE'
/

create or replace public synonym LOADER_DB_OPEN_READ_WRITE for
  LOADER_DB_OPEN_READ_WRITE
/
grant read on LOADER_DB_OPEN_READ_WRITE to public
/

@?/rdbms/admin/sqlsessend.sql
