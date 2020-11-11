Rem
Rem $Header: rdbms/admin/cdcore_cols.sql /main/2 2017/06/26 16:01:20 pjulsaks Exp $
Rem
Rem cdcore_cols.sql
Rem
Rem Copyright (c) 2017, Oracle and/or its affiliates. All rights reserved.
Rem
Rem    NAME
Rem      cdcore_cols.sql - Catalog DCORE.bsq COLumn viewS
Rem
Rem    DESCRIPTION
Rem      This script contains _COLS view definitions for dcore.bsq objects
Rem
Rem    NOTES
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/cdcore_cols.sql
Rem    SQL_SHIPPED_FILE:rdbms/admin/cdcore_cols.sql
Rem    SQL_PHASE:CDCORE_COLS
Rem    SQL_STARTUP_MODE: NORMAL
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    pjulsaks    06/26/17 - Bug 25688154: Uppercase create_cdbview's input
Rem    pjulsaks    05/11/17 - Bug 19552209: Add APPLICATION column
Rem    raeburns    04/23/17 - Bug 25825613: Restructure cdcore.sql
Rem    raeburns    04/23/17 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

-- SHARING bits in OBJ$.FLAGS are:
-- - 65536  = MDL (Metadata Link)
-- - 131072 = DL (Data Link, formerly OBL)
-- - 4294967296 = EDL (Extended Data Link)
define mdl=65536
define dl=131072
define edl=4294967296
define sharing_bits=(&mdl+&dl+&edl)

remark
remark  FAMILY "CONS_COLUMNS"
remark
create or replace view USER_CONS_COLUMNS
    (OWNER, CONSTRAINT_NAME, TABLE_NAME, COLUMN_NAME, POSITION)
as
select u.name, c.name, o.name,
       decode(ac.name, null, col.name, ac.name), cc.pos#
from sys.user$ u, sys.con$ c, sys.col$ col, sys.ccol$ cc, sys.cdef$ cd,
     sys."_CURRENT_EDITION_OBJ" o, sys.attrcol$ ac
where c.owner# = u.user#
  and c.con# = cd.con#
  and (cd.type# < 14 or cd.type# > 17)   /* don't include supplog cons   */
  and (cd.type# != 12)                   /* don't include log group cons */
  and cd.con# = cc.con#
  and cc.obj# = col.obj#
  and cc.intcol# = col.intcol#
  and cc.obj# = o.obj#
  and c.owner# = userenv('SCHEMAID')
  and col.obj# = ac.obj#(+)
  and col.intcol# = ac.intcol#(+)
/
comment on table USER_CONS_COLUMNS is
'Information about accessible columns in constraint definitions'
/
comment on column USER_CONS_COLUMNS.OWNER is
'Owner of the constraint definition'
/
comment on column USER_CONS_COLUMNS.CONSTRAINT_NAME is
'Name associated with the constraint definition'
/
comment on column USER_CONS_COLUMNS.TABLE_NAME is
'Name associated with table with constraint definition'
/
comment on column USER_CONS_COLUMNS.COLUMN_NAME is
'Name associated with column or attribute of object column specified in the constraint definition'
/
comment on column USER_CONS_COLUMNS.POSITION is
'Original position of column or attribute in definition'
/
grant read on USER_CONS_COLUMNS to public with grant option
/
create or replace public synonym USER_CONS_COLUMNS for USER_CONS_COLUMNS
/
create or replace view ALL_CONS_COLUMNS
    (OWNER, CONSTRAINT_NAME, TABLE_NAME, COLUMN_NAME, POSITION)
as
select u.name, c.name, o.name,
       decode(ac.name, null, col.name, ac.name), cc.pos#
from sys.user$ u, sys.con$ c, sys.col$ col, sys.ccol$ cc, sys.cdef$ cd,
     sys."_CURRENT_EDITION_OBJ" o, sys.attrcol$ ac
where c.owner# = u.user#
  and c.con# = cd.con#
  and (cd.type# < 14 or cd.type# > 17)   /* don't include supplog cons   */
  and (cd.type# != 12)                   /* don't include log group cons */
  and cd.con# = cc.con#
  and cc.obj# = col.obj#
  and cc.intcol# = col.intcol#
  and cc.obj# = o.obj#
  and (c.owner# = userenv('SCHEMAID')
       or cd.obj# in (select obj#
                      from sys.objauth$
                      where grantee# in ( select kzsrorol
                                         from x$kzsro
                                       )
                     )
        or /* user has system privileges */
         ora_check_sys_privilege ( o.owner#, o.type#) = 1
      )
  and col.obj# = ac.obj#(+)
  and col.intcol# = ac.intcol#(+)
/
comment on table ALL_CONS_COLUMNS is
'Information about accessible columns in constraint definitions'
/
comment on column ALL_CONS_COLUMNS.OWNER is
'Owner of the constraint definition'
/
comment on column ALL_CONS_COLUMNS.CONSTRAINT_NAME is
'Name associated with the constraint definition'
/
comment on column ALL_CONS_COLUMNS.TABLE_NAME is
'Name associated with table with constraint definition'
/
comment on column ALL_CONS_COLUMNS.COLUMN_NAME is
'Name associated with column or attribute of object column specified in the constraint definition'
/
comment on column ALL_CONS_COLUMNS.POSITION is
'Original position of column or attribute in definition'
/
grant read on ALL_CONS_COLUMNS to public with grant option
/
create or replace public synonym ALL_CONS_COLUMNS for ALL_CONS_COLUMNS
/
create or replace view DBA_CONS_COLUMNS
    (OWNER, CONSTRAINT_NAME, TABLE_NAME, COLUMN_NAME, POSITION)
as
select u.name, c.name, o.name,
       decode(ac.name, null, col.name, ac.name), cc.pos#
from sys.user$ u, sys.con$ c, sys.col$ col, sys.ccol$ cc, sys.cdef$ cd,
     sys."_CURRENT_EDITION_OBJ" o, sys.attrcol$ ac
where c.owner# = u.user#
  and c.con# = cd.con#
  and (cd.type# < 14 or cd.type# > 17)   /* don't include supplog cons   */
  and (cd.type# != 12)                   /* don't include log group cons */
  and cd.con# = cc.con#
  and cc.obj# = col.obj#
  and cc.intcol# = col.intcol#
  and cc.obj# = o.obj#
  and col.obj# = ac.obj#(+)
  and col.intcol# = ac.intcol#(+)
/
create or replace public synonym DBA_CONS_COLUMNS for DBA_CONS_COLUMNS
/
grant select on DBA_CONS_COLUMNS to select_catalog_role
/
comment on table DBA_CONS_COLUMNS is
'Information about accessible columns in constraint definitions'
/
comment on column DBA_CONS_COLUMNS.OWNER is
'Owner of the constraint definition'
/
comment on column DBA_CONS_COLUMNS.CONSTRAINT_NAME is
'Name associated with the constraint definition'
/
comment on column DBA_CONS_COLUMNS.TABLE_NAME is
'Name associated with table with constraint definition'
/
comment on column DBA_CONS_COLUMNS.COLUMN_NAME is
'Name associated with column or attribute of object column specified in the constraint definition'
/
comment on column DBA_CONS_COLUMNS.POSITION is
'Original position of column or attribute in definition'
/


execute CDBView.create_cdbview(false,'SYS','DBA_CONS_COLUMNS','CDB_CONS_COLUMNS');
grant select on SYS.CDB_CONS_COLUMNS to select_catalog_role
/
create or replace public synonym CDB_CONS_COLUMNS for SYS.CDB_CONS_COLUMNS
/

remark
remark  FAMILY "LOG_GROUP_COLUMNS"
remark
create or replace view USER_LOG_GROUP_COLUMNS
    (OWNER, LOG_GROUP_NAME, TABLE_NAME, COLUMN_NAME, POSITION,LOGGING_PROPERTY)
as
select u.name, c.name, o.name,
       decode(ac.name, null, col.name, ac.name), cc.pos#,
       decode(cc.spare1, 1, 'NO LOG', 'LOG')
from sys.user$ u, sys.con$ c, sys.col$ col, sys.ccol$ cc, sys.cdef$ cd,
     sys.obj$ o, sys.attrcol$ ac
where c.owner# = u.user#
  and c.con# = cd.con#
  and cd.type# = 12
  and cd.con# = cc.con#
  and cc.obj# = col.obj#
  and cc.intcol# = col.intcol#
  and cc.obj# = o.obj#
  and c.owner# = userenv('SCHEMAID')
  and col.obj# = ac.obj#(+)
  and col.intcol# = ac.intcol#(+)
/
comment on table USER_LOG_GROUP_COLUMNS is
'Information about columns in log group definitions'
/
comment on column USER_LOG_GROUP_COLUMNS.OWNER is
'Owner of the log group definition'
/
comment on column USER_LOG_GROUP_COLUMNS.LOG_GROUP_NAME is
'Name associated with the log group definition'
/
comment on column USER_LOG_GROUP_COLUMNS.TABLE_NAME is
'Name associated with table with log group definition'
/
comment on column USER_LOG_GROUP_COLUMNS.COLUMN_NAME is
'Name associated with column or attribute of object column specified in the log group definition'
/
comment on column USER_LOG_GROUP_COLUMNS.POSITION is
'Original position of column or attribute in definition'
/
comment on column USER_LOG_GROUP_COLUMNS.LOGGING_PROPERTY is
'Whether the column or attribute would be supplementally logged'
/
grant read on USER_LOG_GROUP_COLUMNS to public with grant option
/
create or replace public synonym USER_LOG_GROUP_COLUMNS
   for USER_LOG_GROUP_COLUMNS
/
create or replace view ALL_LOG_GROUP_COLUMNS
   (OWNER, LOG_GROUP_NAME, TABLE_NAME, COLUMN_NAME, POSITION,LOGGING_PROPERTY)
as
select u.name, c.name, o.name,
       decode(ac.name, null, col.name, ac.name), cc.pos#,
       decode(cc.spare1, 1, 'NO LOG', 'LOG')
from sys.user$ u, sys.con$ c, sys.col$ col, sys.ccol$ cc, sys.cdef$ cd,
     sys.obj$ o, sys.attrcol$ ac
where c.owner# = u.user#
  and c.con# = cd.con#
  and cd.type# = 12
  and cd.con# = cc.con#
  and cc.obj# = col.obj#
  and cc.intcol# = col.intcol#
  and cc.obj# = o.obj#
  and (c.owner# = userenv('SCHEMAID')
       or cd.obj# in (select obj#
                      from sys.objauth$
                      where grantee# in ( select kzsrorol
                                         from x$kzsro
                                       )
                     )
        or /* user has system privileges */
        ora_check_sys_privilege ( o.owner#, o.type#) = 1
      )
  and col.obj# = ac.obj#(+)
  and col.intcol# = ac.intcol#(+)
/
comment on table ALL_LOG_GROUP_COLUMNS is
'Information about columns in log group definitions'
/
comment on column ALL_LOG_GROUP_COLUMNS.OWNER is
'Owner of the log group definition'
/
comment on column ALL_LOG_GROUP_COLUMNS.LOG_GROUP_NAME is
'Name associated with the log group definition'
/
comment on column ALL_LOG_GROUP_COLUMNS.TABLE_NAME is
'Name associated with table with log group definition'
/
comment on column ALL_LOG_GROUP_COLUMNS.COLUMN_NAME is
'Name associated with column or attribute of object column specified in the log group definition'
/
comment on column ALL_LOG_GROUP_COLUMNS.POSITION is
'Original position of column or attribute in definition'
/
comment on column ALL_LOG_GROUP_COLUMNS.LOGGING_PROPERTY is
'Whether the column or attribute would be supplementally logged'
/

grant read on ALL_LOG_GROUP_COLUMNS to public with grant option
/
create or replace public synonym ALL_LOG_GROUP_COLUMNS
   for ALL_LOG_GROUP_COLUMNS
/
create or replace view DBA_LOG_GROUP_COLUMNS
   (OWNER, LOG_GROUP_NAME, TABLE_NAME, COLUMN_NAME, POSITION,LOGGING_PROPERTY)
as
select u.name, c.name, o.name,
       decode(ac.name, null, col.name, ac.name), cc.pos#,
       decode(cc.spare1, 1, 'NO LOG', 'LOG')
from sys.user$ u, sys.con$ c, sys.col$ col, sys.ccol$ cc, sys.cdef$ cd,
     sys.obj$ o, sys.attrcol$ ac
where c.owner# = u.user#
  and c.con# = cd.con#
  and cd.type# = 12
  and cd.con# = cc.con#
  and cc.obj# = col.obj#
  and cc.intcol# = col.intcol#
  and cc.obj# = o.obj#
  and col.obj# = ac.obj#(+)
  and col.intcol# = ac.intcol#(+)
/
create or replace public synonym DBA_LOG_GROUP_COLUMNS
   for DBA_LOG_GROUP_COLUMNS
/
grant select on DBA_LOG_GROUP_COLUMNS to select_catalog_role
/
comment on table DBA_LOG_GROUP_COLUMNS is
'Information about columns in log group definitions'
/
comment on column DBA_LOG_GROUP_COLUMNS.OWNER is
'Owner of the log group definition'
/
comment on column DBA_LOG_GROUP_COLUMNS.LOG_GROUP_NAME is
'Name associated with the log group definition'
/
comment on column DBA_LOG_GROUP_COLUMNS.TABLE_NAME is
'Name associated with table with log group definition'
/
comment on column DBA_LOG_GROUP_COLUMNS.COLUMN_NAME is
'Name associated with column or attribute of object column specified in the log group definition'
/
comment on column DBA_LOG_GROUP_COLUMNS.POSITION is
'Original position of column or attribute in definition'
/
comment on column DBA_LOG_GROUP_COLUMNS.LOGGING_PROPERTY is
'Whether the column or attribute would be supplementally logged'
/



execute CDBView.create_cdbview(false,'SYS','DBA_LOG_GROUP_COLUMNS','CDB_LOG_GROUP_COLUMNS');
grant select on SYS.CDB_LOG_GROUP_COLUMNS to select_catalog_role
/
create or replace public synonym CDB_LOG_GROUP_COLUMNS for SYS.CDB_LOG_GROUP_COLUMNS
/


remark
remark  FAMILY "COL_COMMENTS"
remark  Comments on columns of tables and views.
remark
create or replace view INT$DBA_COL_COMMENTS PDB_LOCAL_ONLY 
  SHARING=EXTENDED DATA 
    (OWNER, OWNERID, TABLE_NAME, OBJECT_ID, OBJECT_TYPE#, COLUMN_NAME, COMMENTS, 
     SHARING, ORIGIN_CON_ID, APPLICATION)
as
select u.name, u.user#, o.name, o.obj#, o.type#, c.name, co.comment$,
       case when bitand(o.flags, &sharing_bits)>0 then 1 else 0 end,
       to_number(sys_context('USERENV', 'CON_ID')),
       /* Bug 19552209: Add APPLICATION column for application object */
       case when bitand(o.flags, 134217728)>0 then 1 else 0 end 
from sys."_CURRENT_EDITION_OBJ" o, sys.col$ c, sys.user$ u, sys.com$ co
where o.owner# = u.user#
  and o.type# in (2, 4)
  and o.obj# = c.obj#
  and c.obj# = co.obj#(+)
  and c.intcol# = co.col#(+)
  and bitand(c.property, 32) = 0 /* not hidden column */
  and (SYS_CONTEXT('USERENV', 'CON_ID') = 0 or 
          (SYS_CONTEXT('USERENV','IS_APPLICATION_ROOT') = 'YES' and 
           bitand(o.flags, 4194304)<>4194304) or
          SYS_CONTEXT('USERENV','IS_APPLICATION_ROOT') = 'NO')
/

create or replace view USER_COL_COMMENTS
    (TABLE_NAME, COLUMN_NAME, COMMENTS, ORIGIN_CON_ID)
as
select TABLE_NAME, COLUMN_NAME, COMMENTS, ORIGIN_CON_ID
from NO_ROOT_SW_FOR_LOCAL(INT$DBA_COL_COMMENTS) 
where OWNER = SYS_CONTEXT('USERENV', 'CURRENT_USER')
/

comment on table USER_COL_COMMENTS is
'Comments on columns of user''s tables and views'
/
comment on column USER_COL_COMMENTS.TABLE_NAME is
'Object name'
/
comment on column USER_COL_COMMENTS.COLUMN_NAME is
'Column name'
/
comment on column USER_COL_COMMENTS.COMMENTS is
'Comment on the column'
/
comment on column USER_COL_COMMENTS.ORIGIN_CON_ID is
'ID of Container where row originates'
/
create or replace public synonym USER_COL_COMMENTS for USER_COL_COMMENTS
/
grant read on USER_COL_COMMENTS to PUBLIC with grant option
/
create or replace view ALL_COL_COMMENTS
    (OWNER, TABLE_NAME, COLUMN_NAME, COMMENTS, ORIGIN_CON_ID)
as
select OWNER, TABLE_NAME, COLUMN_NAME, COMMENTS, ORIGIN_CON_ID
from INT$DBA_COL_COMMENTS 
where (OWNER = SYS_CONTEXT('USERENV', 'CURRENT_USER')
       or OBJ_ID(OWNER, TABLE_NAME, OBJECT_TYPE#, OBJECT_ID) in
         (select obj#
          from sys.objauth$
          where grantee# in ( select kzsrorol
                              from x$kzsro
                            )
          )
       or
       /* 2 is the type# for Table. See kgl.h for more info */
       ora_check_sys_privilege ( ownerid, 2 ) = 1 
      )
/
comment on table ALL_COL_COMMENTS is
'Comments on columns of accessible tables and views'
/
comment on column ALL_COL_COMMENTS.OWNER is
'Owner of the object'
/
comment on column ALL_COL_COMMENTS.TABLE_NAME is
'Name of the object'
/
comment on column ALL_COL_COMMENTS.COLUMN_NAME is
'Name of the column'
/
comment on column ALL_COL_COMMENTS.COMMENTS is
'Comment on the column'
/
comment on column ALL_COL_COMMENTS.ORIGIN_CON_ID is
'ID of Container where row originates'
/
create or replace public synonym ALL_COL_COMMENTS for ALL_COL_COMMENTS
/
grant read on ALL_COL_COMMENTS to PUBLIC with grant option
/
create or replace view DBA_COL_COMMENTS
    (OWNER, TABLE_NAME, COLUMN_NAME, COMMENTS, ORIGIN_CON_ID)
as
select OWNER, TABLE_NAME, COLUMN_NAME, COMMENTS, ORIGIN_CON_ID
from INT$DBA_COL_COMMENTS 
/
create or replace public synonym DBA_COL_COMMENTS for DBA_COL_COMMENTS
/
grant select on DBA_COL_COMMENTS to select_catalog_role
/
comment on table DBA_COL_COMMENTS is
'Comments on columns of all tables and views'
/
comment on column DBA_COL_COMMENTS.OWNER is
'Name of the owner of the object'
/
comment on column DBA_COL_COMMENTS.TABLE_NAME is
'Name of the object'
/
comment on column DBA_COL_COMMENTS.COLUMN_NAME is
'Name of the column'
/
comment on column DBA_COL_COMMENTS.COMMENTS is
'Comment on the object'
/
comment on column DBA_COL_COMMENTS.ORIGIN_CON_ID is
'ID of Container where row originates'
/

execute CDBView.create_cdbview(false,'SYS','DBA_COL_COMMENTS','CDB_COL_COMMENTS');
grant select on SYS.CDB_COL_COMMENTS to select_catalog_role
/
create or replace public synonym CDB_COL_COMMENTS for SYS.CDB_COL_COMMENTS
/

remark
remark  FAMILY "ENCRYPTED_COLUMNS"
remark  information about encrypted columns.
remark
create or replace view DBA_ENCRYPTED_COLUMNS
  (OWNER, TABLE_NAME, COLUMN_NAME, ENCRYPTION_ALG, SALT, INTEGRITY_ALG) as
   select u.name, o.name, c.name,
          case e.ENCALG when 1 then '3 Key Triple DES 168 bits key'
                        when 2 then 'AES 128 bits key'
                        when 3 then 'AES 192 bits key'
                        when 4 then 'AES 256 bits key'
                        when 5 then 'ARIA 128 bits key'
                        when 6 then 'ARIA 192 bits key'
                        when 7 then 'ARIA 256 bits key'
                        when 8 then 'SEED 128 bits key'
                        when 9 then 'GOST 256 bits key'
                        else 'Internal Err'
          end,
          decode(bitand(c.property, 536870912), 0, 'YES', 'NO'),
          case e.INTALG when 1 then 'SHA-1'
                        when 2 then 'NOMAC'
                        else 'Internal Err'
          end
   from user$ u, obj$ o, col$ c, enc$ e
   where e.obj#=o.obj# and o.owner#=u.user# and bitand(flags, 128)=0 and
         e.obj#=c.obj# and bitand(c.property, 67108864) = 67108864
/
comment on table DBA_ENCRYPTED_COLUMNS is
'Encryption information on columns in the database'
/
comment on column DBA_ENCRYPTED_COLUMNS.OWNER is
'Owner of the table'
/
comment on column DBA_ENCRYPTED_COLUMNS.TABLE_NAME is
'Name of the table'
/
comment on column DBA_ENCRYPTED_COLUMNS.COLUMN_NAME is
'Name of the column'
/
comment on column DBA_ENCRYPTED_COLUMNS.ENCRYPTION_ALG is
'Encryption algorithm used for the column'
/
comment on column DBA_ENCRYPTED_COLUMNS.SALT is
'Is this column encrypted with salt? YES or NO'
/
comment on column DBA_ENCRYPTED_COLUMNS.INTEGRITY_ALG is
'Integrity algorithm used for the column'
/
create or replace public synonym DBA_ENCRYPTED_COLUMNS for DBA_ENCRYPTED_COLUMNS
/
grant select on DBA_ENCRYPTED_COLUMNS to select_catalog_role
/

execute CDBView.create_cdbview(false,'SYS','DBA_ENCRYPTED_COLUMNS','CDB_ENCRYPTED_COLUMNS');
grant select on SYS.CDB_ENCRYPTED_COLUMNS to select_catalog_role
/
create or replace public synonym CDB_ENCRYPTED_COLUMNS for SYS.CDB_ENCRYPTED_COLUMNS
/

create or replace view ALL_ENCRYPTED_COLUMNS
  (OWNER, TABLE_NAME, COLUMN_NAME, ENCRYPTION_ALG, SALT, INTEGRITY_ALG) as
   select u.name, o.name, c.name,
          case e.ENCALG when 1 then '3 Key Triple DES 168 bits key'
                        when 2 then 'AES 128 bits key'
                        when 3 then 'AES 192 bits key'
                        when 4 then 'AES 256 bits key'
                        when 5 then 'ARIA 128 bits key'
                        when 6 then 'ARIA 192 bits key'
                        when 7 then 'ARIA 256 bits key'
                        when 8 then 'SEED 128 bits key'
                        when 9 then 'GOST 256 bits key'
                        else 'Internal Err'
          end,
          decode(bitand(c.property, 536870912), 0, 'YES', 'NO'),
          case e.INTALG when 1 then 'SHA-1'
                        when 2 then 'NOMAC'
                        else 'Internal Err'
          end
   from user$ u, obj$ o, col$ c, enc$ e
   where e.obj#=o.obj# and o.owner#=u.user# and bitand(flags, 128)=0 and
         e.obj#=c.obj# and bitand(c.property, 67108864) = 67108864 and
         (o.owner# = userenv('SCHEMAID')
          or
          e.obj# in (select obj# from sys.objauth$ where grantee# in
                        (select kzsrorol from x$kzsro))
          or
          /* user has system privileges */
          ora_check_sys_privilege ( o.owner#, o.type#) = 1
         )
/
comment on table ALL_ENCRYPTED_COLUMNS is
'Encryption information on all accessible columns'
/
comment on column ALL_ENCRYPTED_COLUMNS.OWNER is
'Owner of the table'
/
comment on column ALL_ENCRYPTED_COLUMNS.TABLE_NAME is
'Name of the table'
/
comment on column ALL_ENCRYPTED_COLUMNS.COLUMN_NAME is
'Name of the column'
/
comment on column ALL_ENCRYPTED_COLUMNS.ENCRYPTION_ALG is
'Encryption algorithm used for the column'
/
comment on column ALL_ENCRYPTED_COLUMNS.SALT is
'Is this column encrypted with salt? YES or NO'
/
comment on column ALL_ENCRYPTED_COLUMNS.INTEGRITY_ALG is
'Integrity algorithm used for the column'
/
drop public synonym ALL_ENCRYPTED_COLUMNS
/
create public synonym ALL_ENCRYPTED_COLUMNS for ALL_ENCRYPTED_COLUMNS
/
grant read on ALL_ENCRYPTED_COLUMNS to public
/
create or replace view USER_ENCRYPTED_COLUMNS
  (TABLE_NAME, COLUMN_NAME, ENCRYPTION_ALG, SALT, INTEGRITY_ALG) as
  select TABLE_NAME, COLUMN_NAME, ENCRYPTION_ALG,SALT, INTEGRITY_ALG from DBA_ENCRYPTED_COLUMNS
  where OWNER = SYS_CONTEXT('USERENV','CURRENT_USER')
/
comment on table USER_ENCRYPTED_COLUMNS is
'Encryption information on columns of tables owned by the user'
/
comment on column USER_ENCRYPTED_COLUMNS.TABLE_NAME is
'Name of the table'
/
comment on column USER_ENCRYPTED_COLUMNS.COLUMN_NAME is
'Name of the column'
/
comment on column USER_ENCRYPTED_COLUMNS.ENCRYPTION_ALG is
'Encryption algorithm used for the column'
/
comment on column USER_ENCRYPTED_COLUMNS.SALT is
'Is this column encrypted with salt? YES or NO'
/
comment on column USER_ENCRYPTED_COLUMNS.INTEGRITY_ALG is
'Integrity algorithm used for the column'
/
drop public synonym USER_ENCRYPTED_COLUMNS
/
create public synonym USER_ENCRYPTED_COLUMNS for USER_ENCRYPTED_COLUMNS
/
grant read on USER_ENCRYPTED_COLUMNS to public
/

remark
remark  FAMILY "TAB_COLS"
remark  The columns that make up objects:  Tables, Views, Clusters
remark  Includes information specified or implied by user in
remark  CREATE/ALTER TABLE/VIEW/CLUSTER.
remark
remark this view contains all columns user_tab_cols needs and statistics
remark specific columns that will be referred in user_tab_col_statistics
remark see cdcore_mig.sql for definition
alter view user_tab_cols_v$ compile;

create or replace view USER_TAB_COLS
as select 
     TABLE_NAME, COLUMN_NAME, DATA_TYPE, DATA_TYPE_MOD, DATA_TYPE_OWNER,
     DATA_LENGTH, DATA_PRECISION, DATA_SCALE, NULLABLE, COLUMN_ID,
     DEFAULT_LENGTH, DATA_DEFAULT, NUM_DISTINCT, LOW_VALUE, HIGH_VALUE,
     DENSITY, NUM_NULLS, NUM_BUCKETS, LAST_ANALYZED, SAMPLE_SIZE,
     CHARACTER_SET_NAME, CHAR_COL_DECL_LENGTH,
     GLOBAL_STATS, 
     USER_STATS, AVG_COL_LEN, CHAR_LENGTH, CHAR_USED,
     V80_FMT_IMAGE, DATA_UPGRADED, HIDDEN_COLUMN, VIRTUAL_COLUMN,
     SEGMENT_COLUMN_ID, INTERNAL_COLUMN_ID, HISTOGRAM, QUALIFIED_COL_NAME,
     USER_GENERATED, DEFAULT_ON_NULL, IDENTITY_COLUMN,
     EVALUATION_EDITION, UNUSABLE_BEFORE, UNUSABLE_BEGINNING, 
     COLLATION, COLLATED_COLUMN_ID
from user_tab_cols_v$;

comment on table USER_TAB_COLS is
'Columns of user''s tables, views and clusters'
/
comment on column USER_TAB_COLS.TABLE_NAME is
'Table, view or cluster name'
/
comment on column USER_TAB_COLS.COLUMN_NAME is
'Column name'
/
comment on column USER_TAB_COLS.DATA_LENGTH is
'Length of the column in bytes'
/
comment on column USER_TAB_COLS.DATA_TYPE is
'Datatype of the column'
/
comment on column USER_TAB_COLS.DATA_TYPE_MOD is
'Datatype modifier of the column'
/
comment on column USER_TAB_COLS.DATA_TYPE_OWNER is
'Owner of the datatype of the column'
/
comment on column USER_TAB_COLS.DATA_PRECISION is
'Length: decimal digits (NUMBER) or binary digits (FLOAT)'
/
comment on column USER_TAB_COLS.DATA_SCALE is
'Digits to right of decimal point in a number'
/
comment on column USER_TAB_COLS.NULLABLE is
'Does column allow NULL values?'
/
comment on column USER_TAB_COLS.COLUMN_ID is
'Sequence number of the column as created'
/
comment on column USER_TAB_COLS.DEFAULT_LENGTH is
'Length of default value for the column'
/
comment on column USER_TAB_COLS.DATA_DEFAULT is
'Default value for the column'
/
comment on column USER_TAB_COLS.NUM_DISTINCT is
'The number of distinct values in the column'
/
comment on column USER_TAB_COLS.LOW_VALUE is
'The low value in the column'
/
comment on column USER_TAB_COLS.HIGH_VALUE is
'The high value in the column'
/
comment on column USER_TAB_COLS.DENSITY is
'The density of the column'
/
comment on column USER_TAB_COLS.NUM_NULLS is
'The number of nulls in the column'
/
comment on column USER_TAB_COLS.NUM_BUCKETS is
'The number of buckets in histogram for the column'
/
comment on column USER_TAB_COLS.LAST_ANALYZED is
'The date of the most recent time this column was analyzed'
/
comment on column USER_TAB_COLS.SAMPLE_SIZE is
'The sample size used in analyzing this column'
/
comment on column USER_TAB_COLS.CHARACTER_SET_NAME is
'Character set name'
/
comment on column USER_TAB_COLS.CHAR_COL_DECL_LENGTH is
'Declaration length of character type column'
/
comment on column USER_TAB_COLS.GLOBAL_STATS is
'Are the statistics calculated without merging underlying partitions?'
/
comment on column USER_TAB_COLS.USER_STATS is
'Were the statistics entered directly by the user?'
/
comment on column USER_TAB_COLS.AVG_COL_LEN is
'The average length of the column in bytes'
/
comment on column USER_TAB_COLS.CHAR_LENGTH is
'The maximum length of the column in characters'
/
comment on column USER_TAB_COLS.CHAR_USED is
'C is maximum length given in characters, B if in bytes'
/
comment on column USER_TAB_COLS.V80_FMT_IMAGE is
'Is column data in 8.0 image format?'
/
comment on column USER_TAB_COLS.DATA_UPGRADED is
'Has column data been upgraded to the latest type version format?'
/
comment on column USER_TAB_COLS.HIDDEN_COLUMN is
'Is this a hidden column?'
/
comment on column USER_TAB_COLS.VIRTUAL_COLUMN is
'Is this a virtual column?'
/
comment on column USER_TAB_COLS.SEGMENT_COLUMN_ID is
'Sequence number of the column in the segment'
/
comment on column USER_TAB_COLS.INTERNAL_COLUMN_ID is
'Internal sequence number of the column'
/
comment on column USER_TAB_COLS.QUALIFIED_COL_NAME is
'Qualified column name'
/
comment on column USER_TAB_COLS.USER_GENERATED is
'Is this an user-generated column?'
/
comment on column USER_TAB_COLS.DEFAULT_ON_NULL is
'Is this a default on null column?'
/
comment on column USER_TAB_COLS.IDENTITY_COLUMN is
'Is this an identity column?'
/
comment on column USER_TAB_COLS.EVALUATION_EDITION is
'Name of the evaluation edition assigned to the column expression'
/
comment on column USER_TAB_COLS.UNUSABLE_BEFORE is
'Name of the oldest edition in which the column is usable'
/
comment on column USER_TAB_COLS.UNUSABLE_BEGINNING is
'Name of the oldest edition in which the column becomes perpetually unusable'
/
comment on column USER_TAB_COLS.COLLATION is
'Collation name'
/
comment on column USER_TAB_COLS.COLLATED_COLUMN_ID is
'Reference to the actual collated column''s internal sequence number'
/
create or replace public synonym USER_TAB_COLS for USER_TAB_COLS
/
grant read on USER_TAB_COLS to PUBLIC with grant option
/

remark see cdcore_mig.sql for definition
alter view all_tab_cols_v$ compile;

create or replace view ALL_TAB_COLS
as select
     OWNER, TABLE_NAME,
     COLUMN_NAME, DATA_TYPE, DATA_TYPE_MOD, DATA_TYPE_OWNER,
     DATA_LENGTH, DATA_PRECISION, DATA_SCALE, NULLABLE, COLUMN_ID,
     DEFAULT_LENGTH, DATA_DEFAULT, NUM_DISTINCT, LOW_VALUE, HIGH_VALUE,
     DENSITY, NUM_NULLS, NUM_BUCKETS, LAST_ANALYZED, SAMPLE_SIZE,
     CHARACTER_SET_NAME, CHAR_COL_DECL_LENGTH,
     GLOBAL_STATS, 
     USER_STATS, AVG_COL_LEN, CHAR_LENGTH, CHAR_USED,
     V80_FMT_IMAGE, DATA_UPGRADED, HIDDEN_COLUMN, VIRTUAL_COLUMN,
     SEGMENT_COLUMN_ID, INTERNAL_COLUMN_ID, HISTOGRAM, QUALIFIED_COL_NAME,
     USER_GENERATED, DEFAULT_ON_NULL, IDENTITY_COLUMN,
     EVALUATION_EDITION, UNUSABLE_BEFORE, UNUSABLE_BEGINNING, 
     COLLATION, COLLATED_COLUMN_ID
from all_tab_cols_v$;

comment on table ALL_TAB_COLS is
'Columns of user''s tables, views and clusters'
/
comment on column ALL_TAB_COLS.TABLE_NAME is
'Table, view or cluster name'
/
comment on column ALL_TAB_COLS.COLUMN_NAME is
'Column name'
/
comment on column ALL_TAB_COLS.DATA_LENGTH is
'Length of the column in bytes'
/
comment on column ALL_TAB_COLS.DATA_TYPE is
'Datatype of the column'
/
comment on column ALL_TAB_COLS.DATA_TYPE_MOD is
'Datatype modifier of the column'
/
comment on column ALL_TAB_COLS.DATA_TYPE_OWNER is
'Owner of the datatype of the column'
/
comment on column ALL_TAB_COLS.DATA_PRECISION is
'Length: decimal digits (NUMBER) or binary digits (FLOAT)'
/
comment on column ALL_TAB_COLS.DATA_SCALE is
'Digits to right of decimal point in a number'
/
comment on column ALL_TAB_COLS.NULLABLE is
'Does column allow NULL values?'
/
comment on column ALL_TAB_COLS.COLUMN_ID is
'Sequence number of the column as created'
/
comment on column ALL_TAB_COLS.DEFAULT_LENGTH is
'Length of default value for the column'
/
comment on column ALL_TAB_COLS.DATA_DEFAULT is
'Default value for the column'
/
comment on column ALL_TAB_COLS.NUM_DISTINCT is
'The number of distinct values in the column'
/
comment on column ALL_TAB_COLS.LOW_VALUE is
'The low value in the column'
/
comment on column ALL_TAB_COLS.HIGH_VALUE is
'The high value in the column'
/
comment on column ALL_TAB_COLS.DENSITY is
'The density of the column'
/
comment on column ALL_TAB_COLS.NUM_NULLS is
'The number of nulls in the column'
/
comment on column ALL_TAB_COLS.NUM_BUCKETS is
'The number of buckets in histogram for the column'
/
comment on column ALL_TAB_COLS.LAST_ANALYZED is
'The date of the most recent time this column was analyzed'
/
comment on column ALL_TAB_COLS.SAMPLE_SIZE is
'The sample size used in analyzing this column'
/
comment on column ALL_TAB_COLS.CHARACTER_SET_NAME is
'Character set name'
/
comment on column ALL_TAB_COLS.CHAR_COL_DECL_LENGTH is
'Declaration length of character type column'
/
comment on column ALL_TAB_COLS.GLOBAL_STATS is
'Are the statistics calculated without merging underlying partitions?'
/
comment on column ALL_TAB_COLS.USER_STATS is
'Were the statistics entered directly by the user?'
/
comment on column ALL_TAB_COLS.AVG_COL_LEN is
'The average length of the column in bytes'
/
comment on column ALL_TAB_COLS.CHAR_LENGTH is
'The maximum length of the column in characters'
/
comment on column ALL_TAB_COLS.CHAR_USED is
'C if maximum length is specified in characters, B if in bytes'
/
comment on column ALL_TAB_COLS.V80_FMT_IMAGE is
'Is column data in 8.0 image format?'
/
comment on column ALL_TAB_COLS.DATA_UPGRADED is
'Has column data been upgraded to the latest type version format?'
/
comment on column ALL_TAB_COLS.HIDDEN_COLUMN is
'Is this a hidden column?'
/
comment on column ALL_TAB_COLS.VIRTUAL_COLUMN is
'Is this a virtual column?'
/
comment on column ALL_TAB_COLS.SEGMENT_COLUMN_ID is
'Sequence number of the column in the segment'
/
comment on column ALL_TAB_COLS.INTERNAL_COLUMN_ID is
'Internal sequence number of the column'
/
comment on column ALL_TAB_COLS.QUALIFIED_COL_NAME is
'Qualified column name'
/
comment on column ALL_TAB_COLS.USER_GENERATED is
'Is this an user-generated column?'
/
comment on column ALL_TAB_COLS.DEFAULT_ON_NULL is
'Is this a default on null column?'
/
comment on column ALL_TAB_COLS.IDENTITY_COLUMN is
'Is this an identity column?'
/
comment on column ALL_TAB_COLS.EVALUATION_EDITION is
'Name of the evaluation edition assigned to the column expression'
/
comment on column ALL_TAB_COLS.UNUSABLE_BEFORE is
'Name of the oldest edition in which the column is usable'
/
comment on column ALL_TAB_COLS.UNUSABLE_BEGINNING is
'Name of the oldest edition in which the column becomes perpetually unusable'
/
comment on column ALL_TAB_COLS.COLLATION is
'Collation name'
/
comment on column ALL_TAB_COLS.COLLATED_COLUMN_ID is
'Reference to the actual collated column''s internal sequence number'
/
create or replace public synonym ALL_TAB_COLS for ALL_TAB_COLS
/
grant read on ALL_TAB_COLS to PUBLIC with grant option
/

remark see cdcore_mig.sql for definition
alter view dba_tab_cols_v$ compile;

execute CDBView.create_cdbview(false,'SYS','DBA_TAB_COLS_V$','CDB_TAB_COLS_V$');

create or replace view DBA_TAB_COLS
as select
     OWNER, TABLE_NAME,
     COLUMN_NAME, DATA_TYPE, DATA_TYPE_MOD, DATA_TYPE_OWNER,
     DATA_LENGTH, DATA_PRECISION, DATA_SCALE, NULLABLE, COLUMN_ID,
     DEFAULT_LENGTH, DATA_DEFAULT, NUM_DISTINCT, LOW_VALUE, HIGH_VALUE,
     DENSITY, NUM_NULLS, NUM_BUCKETS, LAST_ANALYZED, SAMPLE_SIZE,
     CHARACTER_SET_NAME, CHAR_COL_DECL_LENGTH,
     GLOBAL_STATS, 
     USER_STATS, AVG_COL_LEN, CHAR_LENGTH, CHAR_USED,
     V80_FMT_IMAGE, DATA_UPGRADED, HIDDEN_COLUMN, VIRTUAL_COLUMN,
     SEGMENT_COLUMN_ID, INTERNAL_COLUMN_ID, HISTOGRAM, QUALIFIED_COL_NAME,
     USER_GENERATED, DEFAULT_ON_NULL, IDENTITY_COLUMN, SENSITIVE_COLUMN,
     EVALUATION_EDITION, UNUSABLE_BEFORE, UNUSABLE_BEGINNING, 
     COLLATION, COLLATED_COLUMN_ID
from dba_tab_cols_v$;

comment on table DBA_TAB_COLS is
'Columns of user''s tables, views and clusters'
/
comment on column DBA_TAB_COLS.TABLE_NAME is
'Table, view or cluster name'
/
comment on column DBA_TAB_COLS.COLUMN_NAME is
'Column name'
/
comment on column DBA_TAB_COLS.DATA_LENGTH is
'Length of the column in bytes'
/
comment on column DBA_TAB_COLS.DATA_TYPE is
'Datatype of the column'
/
comment on column DBA_TAB_COLS.DATA_TYPE_MOD is
'Datatype modifier of the column'
/
comment on column DBA_TAB_COLS.DATA_TYPE_OWNER is
'Owner of the datatype of the column'
/
comment on column DBA_TAB_COLS.DATA_PRECISION is
'Length: decimal digits (NUMBER) or binary digits (FLOAT)'
/
comment on column DBA_TAB_COLS.DATA_SCALE is
'Digits to right of decimal point in a number'
/
comment on column DBA_TAB_COLS.NULLABLE is
'Does column allow NULL values?'
/
comment on column DBA_TAB_COLS.COLUMN_ID is
'Sequence number of the column as created'
/
comment on column DBA_TAB_COLS.DEFAULT_LENGTH is
'Length of default value for the column'
/
comment on column DBA_TAB_COLS.DATA_DEFAULT is
'Default value for the column'
/
comment on column DBA_TAB_COLS.NUM_DISTINCT is
'The number of distinct values in the column'
/
comment on column DBA_TAB_COLS.LOW_VALUE is
'The low value in the column'
/
comment on column DBA_TAB_COLS.HIGH_VALUE is
'The high value in the column'
/
comment on column DBA_TAB_COLS.DENSITY is
'The density of the column'
/
comment on column DBA_TAB_COLS.NUM_NULLS is
'The number of nulls in the column'
/
comment on column DBA_TAB_COLS.NUM_BUCKETS is
'The number of buckets in histogram for the column'
/
comment on column DBA_TAB_COLS.LAST_ANALYZED is
'The date of the most recent time this column was analyzed'
/
comment on column DBA_TAB_COLS.SAMPLE_SIZE is
'The sample size used in analyzing this column'
/
comment on column DBA_TAB_COLS.CHARACTER_SET_NAME is
'Character set name'
/
comment on column DBA_TAB_COLS.CHAR_COL_DECL_LENGTH is
'Declaration length of character type column'
/
comment on column DBA_TAB_COLS.GLOBAL_STATS is
'Are the statistics calculated without merging underlying partitions?'
/
comment on column DBA_TAB_COLS.USER_STATS is
'Were the statistics entered directly by the user?'
/
comment on column DBA_TAB_COLS.AVG_COL_LEN is
'The average length of the column in bytes'
/
comment on column DBA_TAB_COLS.CHAR_LENGTH is
'The maximum length of the column in characters'
/
comment on column DBA_TAB_COLS.CHAR_USED is
'C if the width was specified in characters, B if in bytes'
/
comment on column DBA_TAB_COLS.V80_FMT_IMAGE is
'Is column data in 8.0 image format?'
/
comment on column DBA_TAB_COLS.DATA_UPGRADED is
'Has column data been upgraded to the latest type version format?'
/
comment on column DBA_TAB_COLS.HIDDEN_COLUMN is
'Is this a hidden column?'
/
comment on column DBA_TAB_COLS.VIRTUAL_COLUMN is
'Is this a virtual column?'
/
comment on column DBA_TAB_COLS.SEGMENT_COLUMN_ID is
'Sequence number of the column in the segment'
/
comment on column DBA_TAB_COLS.INTERNAL_COLUMN_ID is
'Internal sequence number of the column'
/
comment on column DBA_TAB_COLS.QUALIFIED_COL_NAME is
'Qualified column name'
/
comment on column ALL_TAB_COLS.USER_GENERATED is
'Is this an user-generated column?'
/
comment on column DBA_TAB_COLS.DEFAULT_ON_NULL is
'Is this a default on null column?'
/
comment on column DBA_TAB_COLS.IDENTITY_COLUMN is
'Is this an identity column?'
/
comment on column DBA_TAB_COLS.SENSITIVE_COLUMN is
'Is this column sensitive?'
/
comment on column DBA_TAB_COLS.EVALUATION_EDITION is
'Name of the evaluation edition assigned to the column expression'
/
comment on column DBA_TAB_COLS.UNUSABLE_BEFORE is
'Name of the oldest edition in which the column is usable'
/
comment on column DBA_TAB_COLS.UNUSABLE_BEGINNING is
'Name of the oldest edition in which the column becomes perpetually unusable'
/
comment on column DBA_TAB_COLS.COLLATION is
'Collation name'
/
comment on column DBA_TAB_COLS.COLLATED_COLUMN_ID is
'Reference to the actual collated column''s internal sequence number'
/
create or replace public synonym DBA_TAB_COLS for DBA_TAB_COLS
/
grant select on DBA_TAB_COLS to select_catalog_role
/

execute CDBView.create_cdbview(false,'SYS','DBA_TAB_COLS','CDB_TAB_COLS');
grant select on SYS.CDB_TAB_COLS to select_catalog_role
/
create or replace public synonym CDB_TAB_COLS for SYS.CDB_TAB_COLS
/

remark
remark  FAMILY "TAB_COLUMNS"
remark  The columns that make up objects:  Tables, Views, Clusters
remark  Includes information specified or implied by user in
remark  CREATE/ALTER TABLE/VIEW/CLUSTER.
remark
create or replace view USER_TAB_COLUMNS
    (TABLE_NAME, COLUMN_NAME, DATA_TYPE, DATA_TYPE_MOD, DATA_TYPE_OWNER,
     DATA_LENGTH, DATA_PRECISION, DATA_SCALE, NULLABLE, COLUMN_ID,
     DEFAULT_LENGTH, DATA_DEFAULT, NUM_DISTINCT, LOW_VALUE, HIGH_VALUE,
     DENSITY, NUM_NULLS, NUM_BUCKETS, LAST_ANALYZED, SAMPLE_SIZE,
     CHARACTER_SET_NAME, CHAR_COL_DECL_LENGTH,
     GLOBAL_STATS, USER_STATS, AVG_COL_LEN, CHAR_LENGTH, CHAR_USED,
     V80_FMT_IMAGE, DATA_UPGRADED, HISTOGRAM, DEFAULT_ON_NULL, 
     IDENTITY_COLUMN, EVALUATION_EDITION , UNUSABLE_BEFORE, UNUSABLE_BEGINNING,
     COLLATION)
as
select TABLE_NAME, COLUMN_NAME, DATA_TYPE, DATA_TYPE_MOD, DATA_TYPE_OWNER,
       DATA_LENGTH, DATA_PRECISION, DATA_SCALE, NULLABLE, COLUMN_ID,
       DEFAULT_LENGTH, DATA_DEFAULT, NUM_DISTINCT, LOW_VALUE, HIGH_VALUE,
       DENSITY, NUM_NULLS, NUM_BUCKETS, LAST_ANALYZED, SAMPLE_SIZE,
       CHARACTER_SET_NAME, CHAR_COL_DECL_LENGTH,
       GLOBAL_STATS, USER_STATS, AVG_COL_LEN, CHAR_LENGTH, CHAR_USED,
       V80_FMT_IMAGE, DATA_UPGRADED, HISTOGRAM, DEFAULT_ON_NULL, 
       IDENTITY_COLUMN, EVALUATION_EDITION, UNUSABLE_BEFORE, 
       UNUSABLE_BEGINNING, COLLATION
  from USER_TAB_COLS
 where USER_GENERATED = 'YES'
/
comment on table USER_TAB_COLUMNS is
'Columns of user''s tables, views and clusters'
/
comment on column USER_TAB_COLUMNS.TABLE_NAME is
'Table, view or cluster name'
/
comment on column USER_TAB_COLUMNS.COLUMN_NAME is
'Column name'
/
comment on column USER_TAB_COLUMNS.DATA_LENGTH is
'Length of the column in bytes'
/
comment on column USER_TAB_COLUMNS.DATA_TYPE is
'Datatype of the column'
/
comment on column USER_TAB_COLUMNS.DATA_TYPE_MOD is
'Datatype modifier of the column'
/
comment on column USER_TAB_COLUMNS.DATA_TYPE_OWNER is
'Owner of the datatype of the column'
/
comment on column USER_TAB_COLUMNS.DATA_PRECISION is
'Length: decimal digits (NUMBER) or binary digits (FLOAT)'
/
comment on column USER_TAB_COLUMNS.DATA_SCALE is
'Digits to right of decimal point in a number'
/
comment on column USER_TAB_COLUMNS.NULLABLE is
'Does column allow NULL values?'
/
comment on column USER_TAB_COLUMNS.COLUMN_ID is
'Sequence number of the column as created'
/
comment on column USER_TAB_COLUMNS.DEFAULT_LENGTH is
'Length of default value for the column'
/
comment on column USER_TAB_COLUMNS.DATA_DEFAULT is
'Default value for the column'
/
comment on column USER_TAB_COLUMNS.NUM_DISTINCT is
'The number of distinct values in the column'
/
comment on column USER_TAB_COLUMNS.LOW_VALUE is
'The low value in the column'
/
comment on column USER_TAB_COLUMNS.HIGH_VALUE is
'The high value in the column'
/
comment on column USER_TAB_COLUMNS.DENSITY is
'The density of the column'
/
comment on column USER_TAB_COLUMNS.NUM_NULLS is
'The number of nulls in the column'
/
comment on column USER_TAB_COLUMNS.NUM_BUCKETS is
'The number of buckets in histogram for the column'
/
comment on column USER_TAB_COLUMNS.LAST_ANALYZED is
'The date of the most recent time this column was analyzed'
/
comment on column USER_TAB_COLUMNS.SAMPLE_SIZE is
'The sample size used in analyzing this column'
/
comment on column USER_TAB_COLUMNS.CHARACTER_SET_NAME is
'Character set name'
/
comment on column USER_TAB_COLUMNS.CHAR_COL_DECL_LENGTH is
'Declaration length of character type column'
/
comment on column USER_TAB_COLUMNS.GLOBAL_STATS is
'Are the statistics calculated without merging underlying partitions?'
/
comment on column USER_TAB_COLUMNS.USER_STATS is
'Were the statistics entered directly by the user?'
/
comment on column USER_TAB_COLUMNS.AVG_COL_LEN is
'The average length of the column in bytes'
/
comment on column USER_TAB_COLUMNS.CHAR_LENGTH is
'The maximum length of the column in characters'
/
comment on column USER_TAB_COLUMNS.CHAR_USED is
'C is maximum length given in characters, B if in bytes'
/
comment on column USER_TAB_COLUMNS.V80_FMT_IMAGE is
'Is column data in 8.0 image format?'
/
comment on column USER_TAB_COLUMNS.DATA_UPGRADED is
'Has column data been upgraded to the latest type version format?'
/
comment on column USER_TAB_COLUMNS.DEFAULT_ON_NULL is
'Is this a default on null column?'
/
comment on column USER_TAB_COLUMNS.IDENTITY_COLUMN is
'Is this an identity column?'
/
comment on column USER_TAB_COLUMNS.EVALUATION_EDITION is
'Name of the evaluation edition assigned to the column expression'
/
comment on column USER_TAB_COLUMNS.UNUSABLE_BEFORE is
'Name of the oldest edition in which the column is usable'
/
comment on column USER_TAB_COLUMNS.UNUSABLE_BEGINNING is
'Name of the oldest edition in which the column becomes perpetually unusable'
/
comment on column USER_TAB_COLUMNS.COLLATION is
'Collation name'
/
create or replace public synonym USER_TAB_COLUMNS for USER_TAB_COLUMNS
/
create or replace public synonym COLS for USER_TAB_COLUMNS
/
grant read on USER_TAB_COLUMNS to PUBLIC with grant option
/
create or replace view ALL_TAB_COLUMNS
    (OWNER, TABLE_NAME,
     COLUMN_NAME, DATA_TYPE, DATA_TYPE_MOD, DATA_TYPE_OWNER,
     DATA_LENGTH, DATA_PRECISION, DATA_SCALE, NULLABLE, COLUMN_ID,
     DEFAULT_LENGTH, DATA_DEFAULT, NUM_DISTINCT, LOW_VALUE, HIGH_VALUE,
     DENSITY, NUM_NULLS, NUM_BUCKETS, LAST_ANALYZED, SAMPLE_SIZE,
     CHARACTER_SET_NAME, CHAR_COL_DECL_LENGTH,
     GLOBAL_STATS, USER_STATS, AVG_COL_LEN, CHAR_LENGTH, CHAR_USED,
     V80_FMT_IMAGE, DATA_UPGRADED, HISTOGRAM, DEFAULT_ON_NULL, 
     IDENTITY_COLUMN, EVALUATION_EDITION, UNUSABLE_BEFORE, UNUSABLE_BEGINNING,
     COLLATION)
as
select OWNER, TABLE_NAME,
       COLUMN_NAME, DATA_TYPE, DATA_TYPE_MOD, DATA_TYPE_OWNER,
       DATA_LENGTH, DATA_PRECISION, DATA_SCALE, NULLABLE, COLUMN_ID,
       DEFAULT_LENGTH, DATA_DEFAULT, NUM_DISTINCT, LOW_VALUE, HIGH_VALUE,
       DENSITY, NUM_NULLS, NUM_BUCKETS, LAST_ANALYZED, SAMPLE_SIZE,
       CHARACTER_SET_NAME, CHAR_COL_DECL_LENGTH,
       GLOBAL_STATS, USER_STATS, AVG_COL_LEN, CHAR_LENGTH, CHAR_USED,
       V80_FMT_IMAGE, DATA_UPGRADED, HISTOGRAM, DEFAULT_ON_NULL, 
       IDENTITY_COLUMN, EVALUATION_EDITION, UNUSABLE_BEFORE, 
       UNUSABLE_BEGINNING, COLLATION
  from ALL_TAB_COLS
 where USER_GENERATED = 'YES'
/
comment on table ALL_TAB_COLUMNS is
'Columns of user''s tables, views and clusters'
/
comment on column ALL_TAB_COLUMNS.TABLE_NAME is
'Table, view or cluster name'
/
comment on column ALL_TAB_COLUMNS.COLUMN_NAME is
'Column name'
/
comment on column ALL_TAB_COLUMNS.DATA_LENGTH is
'Length of the column in bytes'
/
comment on column ALL_TAB_COLUMNS.DATA_TYPE is
'Datatype of the column'
/
comment on column ALL_TAB_COLUMNS.DATA_TYPE_MOD is
'Datatype modifier of the column'
/
comment on column ALL_TAB_COLUMNS.DATA_TYPE_OWNER is
'Owner of the datatype of the column'
/
comment on column ALL_TAB_COLUMNS.DATA_PRECISION is
'Length: decimal digits (NUMBER) or binary digits (FLOAT)'
/
comment on column ALL_TAB_COLUMNS.DATA_SCALE is
'Digits to right of decimal point in a number'
/
comment on column ALL_TAB_COLUMNS.NULLABLE is
'Does column allow NULL values?'
/
comment on column ALL_TAB_COLUMNS.COLUMN_ID is
'Sequence number of the column as created'
/
comment on column ALL_TAB_COLUMNS.DEFAULT_LENGTH is
'Length of default value for the column'
/
comment on column ALL_TAB_COLUMNS.DATA_DEFAULT is
'Default value for the column'
/
comment on column ALL_TAB_COLUMNS.NUM_DISTINCT is
'The number of distinct values in the column'
/
comment on column ALL_TAB_COLUMNS.LOW_VALUE is
'The low value in the column'
/
comment on column ALL_TAB_COLUMNS.HIGH_VALUE is
'The high value in the column'
/
comment on column ALL_TAB_COLUMNS.DENSITY is
'The density of the column'
/
comment on column ALL_TAB_COLUMNS.NUM_NULLS is
'The number of nulls in the column'
/
comment on column ALL_TAB_COLUMNS.NUM_BUCKETS is
'The number of buckets in histogram for the column'
/
comment on column ALL_TAB_COLUMNS.LAST_ANALYZED is
'The date of the most recent time this column was analyzed'
/
comment on column ALL_TAB_COLUMNS.SAMPLE_SIZE is
'The sample size used in analyzing this column'
/
comment on column ALL_TAB_COLUMNS.CHARACTER_SET_NAME is
'Character set name'
/
comment on column ALL_TAB_COLUMNS.CHAR_COL_DECL_LENGTH is
'Declaration length of character type column'
/
comment on column ALL_TAB_COLUMNS.GLOBAL_STATS is
'Are the statistics calculated without merging underlying partitions?'
/
comment on column ALL_TAB_COLUMNS.USER_STATS is
'Were the statistics entered directly by the user?'
/
comment on column ALL_TAB_COLUMNS.AVG_COL_LEN is
'The average length of the column in bytes'
/
comment on column ALL_TAB_COLUMNS.CHAR_LENGTH is
'The maximum length of the column in characters'
/
comment on column ALL_TAB_COLUMNS.CHAR_USED is
'C if maximum length is specified in characters, B if in bytes'
/
comment on column ALL_TAB_COLUMNS.V80_FMT_IMAGE is
'Is column data in 8.0 image format?'
/
comment on column ALL_TAB_COLUMNS.DATA_UPGRADED is
'Has column data been upgraded to the latest type version format?'
/
comment on column ALL_TAB_COLUMNS.DEFAULT_ON_NULL is
'Is this a default on null column?'
/
comment on column ALL_TAB_COLUMNS.IDENTITY_COLUMN is
'Is this an identity column?'
/
comment on column ALL_TAB_COLUMNS.EVALUATION_EDITION is
'Name of the evaluation edition assigned to the column expression'
/
comment on column ALL_TAB_COLUMNS.UNUSABLE_BEFORE is
'Name of the oldest edition in which the column is usable'
/
comment on column ALL_TAB_COLUMNS.UNUSABLE_BEGINNING is
'Name of the oldest edition in which the column becomes perpetually unusable'
/
comment on column ALL_TAB_COLUMNS.COLLATION is
'Collation name'
/
create or replace public synonym ALL_TAB_COLUMNS for ALL_TAB_COLUMNS
/
grant read on ALL_TAB_COLUMNS to PUBLIC with grant option
/
create or replace view DBA_TAB_COLUMNS
    (OWNER, TABLE_NAME,
     COLUMN_NAME, DATA_TYPE, DATA_TYPE_MOD, DATA_TYPE_OWNER,
     DATA_LENGTH, DATA_PRECISION, DATA_SCALE, NULLABLE, COLUMN_ID,
     DEFAULT_LENGTH, DATA_DEFAULT, NUM_DISTINCT, LOW_VALUE, HIGH_VALUE,
     DENSITY, NUM_NULLS, NUM_BUCKETS, LAST_ANALYZED, SAMPLE_SIZE,
     CHARACTER_SET_NAME, CHAR_COL_DECL_LENGTH,
     GLOBAL_STATS, USER_STATS, AVG_COL_LEN, CHAR_LENGTH, CHAR_USED,
     V80_FMT_IMAGE, DATA_UPGRADED, HISTOGRAM, DEFAULT_ON_NULL, 
     IDENTITY_COLUMN, SENSITIVE_COLUMN,
     EVALUATION_EDITION, UNUSABLE_BEFORE, UNUSABLE_BEGINNING, COLLATION)
as
select OWNER, TABLE_NAME,
       COLUMN_NAME, DATA_TYPE, DATA_TYPE_MOD, DATA_TYPE_OWNER,
       DATA_LENGTH, DATA_PRECISION, DATA_SCALE, NULLABLE, COLUMN_ID,
       DEFAULT_LENGTH, DATA_DEFAULT, NUM_DISTINCT, LOW_VALUE, HIGH_VALUE,
       DENSITY, NUM_NULLS, NUM_BUCKETS, LAST_ANALYZED, SAMPLE_SIZE,
       CHARACTER_SET_NAME, CHAR_COL_DECL_LENGTH,
       GLOBAL_STATS, USER_STATS, AVG_COL_LEN, CHAR_LENGTH, CHAR_USED,
       V80_FMT_IMAGE, DATA_UPGRADED, HISTOGRAM, DEFAULT_ON_NULL, 
       IDENTITY_COLUMN, SENSITIVE_COLUMN,
       EVALUATION_EDITION, UNUSABLE_BEFORE, UNUSABLE_BEGINNING, COLLATION
  from DBA_TAB_COLS
 where USER_GENERATED = 'YES'
/
comment on table DBA_TAB_COLUMNS is
'Columns of user''s tables, views and clusters'
/
comment on column DBA_TAB_COLUMNS.TABLE_NAME is
'Table, view or cluster name'
/
comment on column DBA_TAB_COLUMNS.COLUMN_NAME is
'Column name'
/
comment on column DBA_TAB_COLUMNS.DATA_LENGTH is
'Length of the column in bytes'
/
comment on column DBA_TAB_COLUMNS.DATA_TYPE is
'Datatype of the column'
/
comment on column DBA_TAB_COLUMNS.DATA_TYPE_MOD is
'Datatype modifier of the column'
/
comment on column DBA_TAB_COLUMNS.DATA_TYPE_OWNER is
'Owner of the datatype of the column'
/
comment on column DBA_TAB_COLUMNS.DATA_PRECISION is
'Length: decimal digits (NUMBER) or binary digits (FLOAT)'
/
comment on column DBA_TAB_COLUMNS.DATA_SCALE is
'Digits to right of decimal point in a number'
/
comment on column DBA_TAB_COLUMNS.NULLABLE is
'Does column allow NULL values?'
/
comment on column DBA_TAB_COLUMNS.COLUMN_ID is
'Sequence number of the column as created'
/
comment on column DBA_TAB_COLUMNS.DEFAULT_LENGTH is
'Length of default value for the column'
/
comment on column DBA_TAB_COLUMNS.DATA_DEFAULT is
'Default value for the column'
/
comment on column DBA_TAB_COLUMNS.NUM_DISTINCT is
'The number of distinct values in the column'
/
comment on column DBA_TAB_COLUMNS.LOW_VALUE is
'The low value in the column'
/
comment on column DBA_TAB_COLUMNS.HIGH_VALUE is
'The high value in the column'
/
comment on column DBA_TAB_COLUMNS.DENSITY is
'The density of the column'
/
comment on column DBA_TAB_COLUMNS.NUM_NULLS is
'The number of nulls in the column'
/
comment on column DBA_TAB_COLUMNS.NUM_BUCKETS is
'The number of buckets in histogram for the column'
/
comment on column DBA_TAB_COLUMNS.LAST_ANALYZED is
'The date of the most recent time this column was analyzed'
/
comment on column DBA_TAB_COLUMNS.SAMPLE_SIZE is
'The sample size used in analyzing this column'
/
comment on column DBA_TAB_COLUMNS.CHARACTER_SET_NAME is
'Character set name'
/
comment on column DBA_TAB_COLUMNS.CHAR_COL_DECL_LENGTH is
'Declaration length of character type column'
/
comment on column DBA_TAB_COLUMNS.GLOBAL_STATS is
'Are the statistics calculated without merging underlying partitions?'
/
comment on column DBA_TAB_COLUMNS.USER_STATS is
'Were the statistics entered directly by the user?'
/
comment on column DBA_TAB_COLUMNS.AVG_COL_LEN is
'The average length of the column in bytes'
/
comment on column DBA_TAB_COLUMNS.CHAR_LENGTH is
'The maximum length of the column in characters'
/
comment on column DBA_TAB_COLUMNS.CHAR_USED is
'C if the width was specified in characters, B if in bytes'
/
comment on column DBA_TAB_COLUMNS.V80_FMT_IMAGE is
'Is column data in 8.0 image format?'
/
comment on column DBA_TAB_COLUMNS.DATA_UPGRADED is
'Has column data been upgraded to the latest type version format?'
/
comment on column DBA_TAB_COLUMNS.DEFAULT_ON_NULL is
'Is this a default on null column?'
/
comment on column DBA_TAB_COLUMNS.IDENTITY_COLUMN is
'Is this an identity column?'
/
comment on column DBA_TAB_COLUMNS.SENSITIVE_COLUMN is
'Is this column sensitive?'
/
comment on column DBA_TAB_COLUMNS.EVALUATION_EDITION is
'Name of the evaluation edition assigned to the column expression'
/
comment on column DBA_TAB_COLUMNS.UNUSABLE_BEFORE is
'Name of the oldest edition in which the column is usable'
/
comment on column DBA_TAB_COLUMNS.UNUSABLE_BEGINNING is
'Name of the oldest edition in which the column becomes perpetually unusable'
/
comment on column DBA_TAB_COLUMNS.COLLATION is
'Collation name'
/
create or replace public synonym DBA_TAB_COLUMNS for DBA_TAB_COLUMNS
/
grant select on DBA_TAB_COLUMNS to select_catalog_role
/


execute CDBView.create_cdbview(false,'SYS','DBA_TAB_COLUMNS','CDB_TAB_COLUMNS');
grant select on SYS.CDB_TAB_COLUMNS to select_catalog_role
/
create or replace public synonym CDB_TAB_COLUMNS for SYS.CDB_TAB_COLUMNS
/


remark
remark  FAMILY "LOG_GROUPS"
remark
create or replace view USER_LOG_GROUPS
    (OWNER, LOG_GROUP_NAME, TABLE_NAME, LOG_GROUP_TYPE, ALWAYS, GENERATED)
as
select ou.name, oc.name, o.name,
       case c.type# when 14 then 'PRIMARY KEY LOGGING'
                    when 15 then 'UNIQUE KEY LOGGING'
                    when 16 then 'FOREIGN KEY LOGGING'
                    when 17 then 'ALL COLUMN LOGGING'
                    else 'USER LOG GROUP'
       end,
       case bitand(c.defer,64) when 64 then 'ALWAYS'
                               else  'CONDITIONAL'
       end,
       case bitand(c.defer,8) when 8 then 'GENERATED NAME'
                              else  'USER NAME'
       end
from sys.con$ oc,  sys.user$ ou,
     sys.obj$ o, sys.cdef$ c
where oc.owner# = ou.user#
  and oc.con# = c.con#
  and c.obj# = o.obj#
  and o.owner# = userenv('SCHEMAID')
  and
  (c.type# = 12 or c.type# = 14 or
   c.type# = 15 or c.type# = 16 or
   c.type# = 17)
/
comment on table USER_LOG_GROUPS is
'Log group definitions on user''s own tables'
/
comment on column USER_LOG_GROUPS.OWNER is
'Owner of the table'
/
comment on column USER_LOG_GROUPS.LOG_GROUP_NAME is
'Name associated with log group definition'
/
comment on column USER_LOG_GROUPS.TABLE_NAME is
'Name of the table on which this log group is defined'
/
comment on column USER_LOG_GROUPS.LOG_GROUP_TYPE is
'Type of the log group'
/
comment on column USER_LOG_GROUPS.ALWAYS is
'Is this an ALWAYS or a CONDITIONAL supplemental log group?'
/
comment on column USER_LOG_GROUPS.GENERATED is
'Was the name of this supplemental log group system generated?'
/
grant read on USER_LOG_GROUPS to public with grant option
/
create or replace public synonym USER_LOG_GROUPS for USER_LOG_GROUPS
/
create or replace view ALL_LOG_GROUPS
    (OWNER, LOG_GROUP_NAME, TABLE_NAME, LOG_GROUP_TYPE, ALWAYS, GENERATED)
as
select ou.name, oc.name, o.name,
       case c.type# when 14 then 'PRIMARY KEY LOGGING'
                    when 15 then 'UNIQUE KEY LOGGING'
                    when 16 then 'FOREIGN KEY LOGGING'
                    when 17 then 'ALL COLUMN LOGGING'
                    else 'USER LOG GROUP'
       end,
       case bitand(c.defer,64) when 64 then 'ALWAYS'
                               else  'CONDITIONAL'
       end,
       case bitand(c.defer,8) when 8 then 'GENERATED NAME'
                              else  'USER NAME'
       end
from sys.con$ oc,  sys.user$ ou,
     sys.obj$ o, sys.cdef$ c
where oc.owner# = ou.user#
  and oc.con# = c.con#
  and c.obj# = o.obj#
  and
  (c.type# = 12 or c.type# = 14 or
   c.type# = 15 or c.type# = 16 or
   c.type# = 17)
  and (o.owner# = userenv('SCHEMAID')
       or o.obj# in (select obj#
                     from sys.objauth$
                     where grantee# in ( select kzsrorol
                                         from x$kzsro
                                       )
                    )
        or /* user has system privileges */
        ora_check_sys_privilege ( o.owner#, o.type#) = 1
      )
/
comment on table ALL_LOG_GROUPS is
'Log group definitions on accessible tables'
/
comment on column ALL_LOG_GROUPS.OWNER is
'Owner of the table'
/
comment on column ALL_LOG_GROUPS.LOG_GROUP_NAME is
'Name associated with log group definition'
/
comment on column USER_LOG_GROUPS.TABLE_NAME is
'Name of the table on which this log group is defined'
/
comment on column USER_LOG_GROUPS.LOG_GROUP_TYPE is
'Type of the log group'
/
comment on column ALL_LOG_GROUPS.ALWAYS is
'Is this an ALWAYS or a CONDITIONAL supplemental log group?'
/
comment on column ALL_LOG_GROUPS.GENERATED is
'Was the name of this supplemental log group system generated?'
/
grant read on ALL_LOG_GROUPS to public with grant option
/
create or replace public synonym ALL_LOG_GROUPS for ALL_LOG_GROUPS
/
create or replace view DBA_LOG_GROUPS
    (OWNER, LOG_GROUP_NAME, TABLE_NAME, LOG_GROUP_TYPE, ALWAYS, GENERATED)
as
select ou.name, oc.name, o.name,
       case c.type# when 14 then 'PRIMARY KEY LOGGING'
                    when 15 then 'UNIQUE KEY LOGGING'
                    when 16 then 'FOREIGN KEY LOGGING'
                    when 17 then 'ALL COLUMN LOGGING'
                    else 'USER LOG GROUP'
       end,
       case bitand(c.defer,64) when 64 then 'ALWAYS'
                               else  'CONDITIONAL'
       end,
       case bitand(c.defer,8) when 8 then 'GENERATED NAME'
                              else  'USER NAME'
       end
from sys.con$ oc, sys.user$ ou, sys.obj$ o, sys.cdef$ c
where oc.owner# = ou.user#
  and oc.con# = c.con#
  and c.obj# = o.obj#
  and
  (c.type# = 12 or c.type# = 14 or
   c.type# = 15 or c.type# = 16 or
   c.type# = 17)
/

comment on column DBA_LOG_GROUPS.GENERATED is
'Was the name of this supplemental log group system generated?'
/
create or replace public synonym DBA_LOG_GROUPS for DBA_LOG_GROUPS
/
grant select on DBA_LOG_GROUPS to select_catalog_role
/
comment on table DBA_LOG_GROUPS is
'Log group definitions on all tables'
/
comment on column DBA_LOG_GROUPS.OWNER is
'Owner of the table'
/
comment on column DBA_LOG_GROUPS.LOG_GROUP_NAME is
'Name associated with log group definition'
/
comment on column USER_LOG_GROUPS.TABLE_NAME is
'Name of the table on which this log group is defined'
/
comment on column USER_LOG_GROUPS.LOG_GROUP_TYPE is
'Type of the log group'
/
comment on column DBA_LOG_GROUPS.ALWAYS is
'Is this an ALWAYS or a CONDITIONAL supplemental log group?'
/
comment on column ALL_LOG_GROUPS.GENERATED is
'Was the name of this supplemental log group system generated?'
/

execute CDBView.create_cdbview(false,'SYS','DBA_LOG_GROUPS','CDB_LOG_GROUPS');
grant select on SYS.CDB_LOG_GROUPS to select_catalog_role
/
create or replace public synonym CDB_LOG_GROUPS for SYS.CDB_LOG_GROUPS
/

remark
remark  FAMILY "UPDATABLE_COLUMNS"
remark
create or replace view USER_UPDATABLE_COLUMNS
(OWNER, TABLE_NAME, COLUMN_NAME, UPDATABLE, INSERTABLE, DELETABLE)
as
select u.name, o.name, c.name,
      decode(bitand(c.fixedstorage,2),
             2,
             case when
               exists
                 (select 1 from trigger$ t, "_CURRENT_EDITION_OBJ" trigobj
                  where     t.obj# = trigobj.obj#  /* trigger in edition */
                        and t.type# = 4            /* and insted of trigger */
                        and t.enabled = 1          /* and enabled */
                        and t.baseobject = o.obj#  /* on selected object */
                        and t.update$ <> 0)        /* triggers on update */
               then
                 'YES'
               else
                 'NO'
             end,
             decode(bitand(c.property,4096),4096,'NO','YES')),
      decode(bitand(c.fixedstorage,2),
             2,
             case when
               exists
                 (select 1 from trigger$ t, "_CURRENT_EDITION_OBJ" trigobj
                  where     t.obj# = trigobj.obj#  /* trigger in edition */
                        and t.type# = 4            /* and insted of trigger */
                        and t.enabled = 1          /* and enabled */
                        and t.baseobject = o.obj#  /* on selected object */
                        and t.insert$ <> 0)        /* triggers on insert */
               then
                 'YES'
               else
                 'NO'
             end,
             decode(bitand(c.property,2048),2048,'NO','YES')),
      decode(bitand(c.fixedstorage,2),
             2,
             case when
               exists
                 (select 1 from trigger$ t, "_CURRENT_EDITION_OBJ" trigobj
                  where     t.obj# = trigobj.obj#  /* trigger in edition */
                        and t.type# = 4            /* and insted of trigger */
                        and t.enabled = 1          /* and enabled */
                        and t.baseobject = o.obj#  /* on selected object */
                        and t.delete$ <> 0)        /* triggers on delete */
               then
                 'YES'
               else
                 'NO'
             end,
             decode(bitand(c.property,8192),8192,'NO','YES'))
from sys."_CURRENT_EDITION_OBJ" o, sys.user$ u, sys.col$ c
where u.user# = o.owner#
  and c.obj#  = o.obj#
  and u.user# = userenv('SCHEMAID')
  and bitand(c.property, 32) = 0 /* not hidden column */
/
comment on table USER_UPDATABLE_COLUMNS is
'Description of updatable columns'
/
comment on column USER_UPDATABLE_COLUMNS.OWNER is
'Table owner'
/
comment on column USER_UPDATABLE_COLUMNS.TABLE_NAME is
'Table name'
/
comment on column USER_UPDATABLE_COLUMNS.COLUMN_NAME is
'Column name'
/
comment on column USER_UPDATABLE_COLUMNS.UPDATABLE is
'Is the column updatable?'
/
comment on column USER_UPDATABLE_COLUMNS.INSERTABLE is
'Is the column insertable?'
/
comment on column USER_UPDATABLE_COLUMNS.DELETABLE is
'Is the column deletable?'
/
create or replace public synonym USER_UPDATABLE_COLUMNS
   for USER_UPDATABLE_COLUMNS
/
grant read on USER_UPDATABLE_COLUMNS to PUBLIC with grant option
/
create or replace view ALL_UPDATABLE_COLUMNS
(OWNER, TABLE_NAME, COLUMN_NAME, UPDATABLE, INSERTABLE, DELETABLE)
as
select u.name, o.name, c.name,
      decode(bitand(c.fixedstorage,2),
             2,
             case when
               exists
                 (select 1 from trigger$ t, "_CURRENT_EDITION_OBJ" trigobj
                  where     t.obj# = trigobj.obj#  /* trigger in edition */
                        and t.type# = 4            /* and insted of trigger */
                        and t.enabled = 1          /* and enabled */
                        and t.baseobject = o.obj#  /* on selected object */
                        and t.update$ <> 0)        /* triggers on update */
               then
                 'YES'
               else
                 'NO'
             end,
             decode(bitand(c.property,4096),4096,'NO','YES')),
      decode(bitand(c.fixedstorage,2),
             2,
             case when
               exists
                 (select 1 from trigger$ t, "_CURRENT_EDITION_OBJ" trigobj
                  where     t.obj# = trigobj.obj#  /* trigger in edition */
                        and t.type# = 4            /* and insted of trigger */
                        and t.enabled = 1          /* and enabled */
                        and t.baseobject = o.obj#  /* on selected object */
                        and t.insert$ <> 0)        /* triggers on insert */
               then
                 'YES'
               else
                 'NO'
             end,
             decode(bitand(c.property,2048),2048,'NO','YES')),
      decode(bitand(c.fixedstorage,2),
             2,
             case when
               exists
                 (select 1 from trigger$ t, "_CURRENT_EDITION_OBJ" trigobj
                  where     t.obj# = trigobj.obj#  /* trigger in edition */
                        and t.type# = 4            /* and insted of trigger */
                        and t.enabled = 1          /* and enabled */
                        and t.baseobject = o.obj#  /* on selected object */
                        and t.delete$ <> 0)        /* triggers on delete */
               then
                 'YES'
               else
                 'NO'
             end,
             decode(bitand(c.property,8192),8192,'NO','YES'))
from sys."_CURRENT_EDITION_OBJ" o, sys.user$ u, sys.col$ c
where o.owner# = u.user#
  and o.obj#  = c.obj#
  and bitand(c.property, 32) = 0 /* not hidden column */
  and (o.owner# = userenv('SCHEMAID')
       or o.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               )
            )
       or /* user has system privileges */
       ora_check_sys_privilege ( o.owner#, o.type# ) = 1
      )
/
comment on table ALL_UPDATABLE_COLUMNS is
'Description of all updatable columns'
/
comment on column ALL_UPDATABLE_COLUMNS.OWNER is
'Table owner'
/
comment on column ALL_UPDATABLE_COLUMNS.TABLE_NAME is
'Table name'
/
comment on column ALL_UPDATABLE_COLUMNS.COLUMN_NAME is
'Column name'
/
comment on column ALL_UPDATABLE_COLUMNS.UPDATABLE is
'Is the column updatable?'
/
comment on column ALL_UPDATABLE_COLUMNS.INSERTABLE is
'Is the column insertable?'
/
comment on column ALL_UPDATABLE_COLUMNS.DELETABLE is
'Is the column deletable?'
/
create or replace public synonym ALL_UPDATABLE_COLUMNS
   for ALL_UPDATABLE_COLUMNS
/
grant read on ALL_UPDATABLE_COLUMNS to PUBLIC with grant option
/
create or replace view DBA_UPDATABLE_COLUMNS
(OWNER, TABLE_NAME, COLUMN_NAME, UPDATABLE, INSERTABLE, DELETABLE)
as
select u.name, o.name, c.name,
      decode(bitand(c.fixedstorage,2),
             2,
             case when
               exists
                 (select 1 from trigger$ t, "_CURRENT_EDITION_OBJ" trigobj
                  where     t.obj# = trigobj.obj#  /* trigger in edition */
                        and t.type# = 4            /* and insted of trigger */
                        and t.enabled = 1          /* and enabled */
                        and t.baseobject = o.obj#  /* on selected object */
                        and t.update$ <> 0)        /* triggers on update */
               then
                 'YES'
               else
                 'NO'
             end,
             decode(bitand(c.property,4096),4096,'NO','YES')),
      decode(bitand(c.fixedstorage,2),
             2,
             case when
               exists
                 (select 1 from trigger$ t, "_CURRENT_EDITION_OBJ" trigobj
                  where     t.obj# = trigobj.obj#  /* trigger in edition */
                        and t.type# = 4            /* and insted of trigger */
                        and t.enabled = 1          /* and enabled */
                        and t.baseobject = o.obj#  /* on selected object */
                        and t.insert$ <> 0)        /* triggers on insert */
               then
                 'YES'
               else
                 'NO'
             end,
             decode(bitand(c.property,2048),2048,'NO','YES')),
      decode(bitand(c.fixedstorage,2),
             2,
             case when
               exists
                 (select 1 from trigger$ t, "_CURRENT_EDITION_OBJ" trigobj
                  where     t.obj# = trigobj.obj#  /* trigger in edition */
                        and t.type# = 4            /* and insted of trigger */
                        and t.enabled = 1          /* and enabled */
                        and t.baseobject = o.obj#  /* on selected object */
                        and t.delete$ <> 0)        /* triggers on delete */
               then
                 'YES'
               else
                 'NO'
             end,
             decode(bitand(c.property,8192),8192,'NO','YES'))
from sys."_CURRENT_EDITION_OBJ" o, sys.user$ u, sys.col$ c
where u.user# = o.owner#
  and c.obj#  = o.obj#
  and bitand(c.property, 32) = 0 /* not hidden column */
/
comment on table DBA_UPDATABLE_COLUMNS is
'Description of dba updatable columns'
/
comment on column DBA_UPDATABLE_COLUMNS.OWNER is
'table owner'
/
comment on column DBA_UPDATABLE_COLUMNS.TABLE_NAME is
'table name'
/
comment on column DBA_UPDATABLE_COLUMNS.COLUMN_NAME is
'column name'
/
comment on column DBA_UPDATABLE_COLUMNS.UPDATABLE is
'Is the column updatable?'
/
comment on column DBA_UPDATABLE_COLUMNS.INSERTABLE is
'Is the column insertable?'
/
comment on column DBA_UPDATABLE_COLUMNS.DELETABLE is
'Is the column deletable?'
/
create or replace public synonym DBA_UPDATABLE_COLUMNS
   for DBA_UPDATABLE_COLUMNS
/
grant select on DBA_UPDATABLE_COLUMNS to select_catalog_role
/


execute CDBView.create_cdbview(false,'SYS','DBA_UPDATABLE_COLUMNS','CDB_UPDATABLE_COLUMNS');
grant select on SYS.CDB_UPDATABLE_COLUMNS to select_catalog_role
/
create or replace public synonym CDB_UPDATABLE_COLUMNS for SYS.CDB_UPDATABLE_COLUMNS
/



remark
remark  FAMILY "TAB_IDENTITY_COLS"
remark
remark  Views for showing tables with identity columns:
remark  USER_TAB_IDENTITY_COLS, ALL_TAB_IDENTITY_COLS, DBA_TAB_IDENTITY_COLS
remark
create or replace view USER_TAB_IDENTITY_COLS
(TABLE_NAME, COLUMN_NAME, GENERATION_TYPE, SEQUENCE_NAME, IDENTITY_OPTIONS)
as
select o.name, c.name, 
       decode(bitand(c.property, 137438953472 + 274877906944), 
                     137438953472, 'ALWAYS',
                     274877906944, 'BY DEFAULT'),
       so.name,
       'START WITH: '     || i.startwith ||
       ', INCREMENT BY: ' || s.increment$ ||
       ', MAX_VALUE: '    || s.maxvalue ||
       ', MIN_VALUE: '    || s.minvalue ||
       ', CYCLE_FLAG: '   || decode (s.cycle#, 0, 'N', 1, 'Y') ||
       ', CACHE_SIZE: '   || s.cache ||
       ', ORDER_FLAG: '   || decode (s.order$, 0, 'N', 1, 'Y') ||
       ', SCALE_FLAG: '   || decode (bitand(s.flags, 16), 16, 'Y', 'N') ||
       ', EXTEND_FLAG: '  || decode (bitand(s.flags, 2048), 2048, 'Y', 'N') ||
       ', SESSION_FLAG: ' || decode(bitand(s.flags, 64), 64, 'Y', 'N') ||
       ', KEEP_VALUE: '   || decode(bitand(s.flags, 512), 512, 'Y', 'N')
from sys.idnseq$ i, sys.obj$ o, sys.col$ c, 
     sys.seq$ s, sys.obj$ so
where o.owner# = userenv('SCHEMAID')
and o.obj# = i.obj#
and c.intcol# = i.intcol#
and c.obj# = i.obj#
and s.obj# = i.seqobj#
and so.obj# = i.seqobj#
/
comment on table USER_TAB_IDENTITY_COLS is
'Describes all table identity columns'
/
comment on column USER_TAB_IDENTITY_COLS.TABLE_NAME is
'Name of the table'
/
comment on column USER_TAB_IDENTITY_COLS.COLUMN_NAME is
'Name of the identity column'
/
comment on column USER_TAB_IDENTITY_COLS.GENERATION_TYPE is
'Generation type of the identity column'
/
comment on column USER_TAB_IDENTITY_COLS.SEQUENCE_NAME is
'Name of the sequence associated with the identity column'
/
comment on column USER_TAB_IDENTITY_COLS.IDENTITY_OPTIONS is
'Options of the identity column'
/
create or replace public synonym USER_TAB_IDENTITY_COLS for 
  USER_TAB_IDENTITY_COLS
/
grant read on USER_TAB_IDENTITY_COLS to PUBLIC with grant option
/

create or replace view ALL_TAB_IDENTITY_COLS
(OWNER, TABLE_NAME, COLUMN_NAME, GENERATION_TYPE, SEQUENCE_NAME, 
 IDENTITY_OPTIONS)
as
select u.name, o.name, c.name, 
       decode(bitand(c.property, 137438953472 + 274877906944), 
                     137438953472, 'ALWAYS',
                     274877906944, 'BY DEFAULT'),
       so.name,
       'START WITH: '     || i.startwith ||
       ', INCREMENT BY: ' || s.increment$ ||
       ', MAX_VALUE: '    || s.maxvalue ||
       ', MIN_VALUE: '    || s.minvalue ||
       ', CYCLE_FLAG: '   || decode (s.cycle#, 0, 'N', 1, 'Y') ||
       ', CACHE_SIZE: '   || s.cache ||
       ', ORDER_FLAG: '   || decode (s.order$, 0, 'N', 1, 'Y')  ||
       ', SCALE_FLAG: '   || decode (bitand(s.flags, 16), 16, 'Y', 'N') ||
       ', EXTEND_FLAG: '  || decode (bitand(s.flags, 2048), 2048, 'Y', 'N') ||
       ', SESSION_FLAG: ' || decode(bitand(s.flags, 64), 64, 'Y', 'N') ||
       ', KEEP_VALUE: '   || decode(bitand(s.flags, 512), 512, 'Y', 'N')
from sys.idnseq$ i, sys.obj$ o, sys.user$ u, sys.col$ c, 
     sys.seq$ s, sys.obj$ so
where o.owner# = u.user#
and o.obj# = i.obj#
and c.intcol# = i.intcol#
and c.obj# = i.obj#
and s.obj# = i.seqobj#
and so.obj# = i.seqobj#
and (o.owner# = userenv('SCHEMAID')
     or o.obj# in
          (select oa.obj#
           from sys.objauth$ oa
           where grantee# in ( select kzsrorol
                               from x$kzsro
                             )
          )
     or /* user has system privileges */
     ora_check_sys_privilege ( o.owner#, o.type# ) = 1
    )
/
comment on table ALL_TAB_IDENTITY_COLS is
'Describes all table identity columns'
/
comment on column ALL_TAB_IDENTITY_COLS.OWNER is
'Owner of the table'
/
comment on column ALL_TAB_IDENTITY_COLS.TABLE_NAME is
'Name of the table'
/
comment on column ALL_TAB_IDENTITY_COLS.COLUMN_NAME is
'Name of the identity column'
/
comment on column ALL_TAB_IDENTITY_COLS.GENERATION_TYPE is
'Generation type of the identity column'
/
comment on column ALL_TAB_IDENTITY_COLS.SEQUENCE_NAME is
'Name of the sequence associated with the identity column'
/
comment on column ALL_TAB_IDENTITY_COLS.IDENTITY_OPTIONS is
'Options of the identity column'
/
create or replace public synonym ALL_TAB_IDENTITY_COLS for 
  ALL_TAB_IDENTITY_COLS
/
grant read on ALL_TAB_IDENTITY_COLS to PUBLIC with grant option
/

create or replace view DBA_TAB_IDENTITY_COLS
(OWNER, TABLE_NAME, COLUMN_NAME, GENERATION_TYPE, SEQUENCE_NAME, 
 IDENTITY_OPTIONS)
as
select u.name, o.name, c.name, 
       decode(bitand(c.property, 137438953472 + 274877906944), 
                     137438953472, 'ALWAYS',
                     274877906944, 'BY DEFAULT'),
       so.name,
       'START WITH: '     || i.startwith ||
       ', INCREMENT BY: ' || s.increment$ ||
       ', MAX_VALUE: '    || s.maxvalue ||
       ', MIN_VALUE: '    || s.minvalue ||
       ', CYCLE_FLAG: '   || decode (s.cycle#, 0, 'N', 1, 'Y') ||
       ', CACHE_SIZE: '   || s.cache ||
       ', ORDER_FLAG: '   || decode (s.order$, 0, 'N', 1, 'Y') ||
       ', SCALE_FLAG: '   || decode (bitand(s.flags, 16), 16, 'Y', 'N') ||
       ', EXTEND_FLAG: '  || decode (bitand(s.flags, 2048), 2048, 'Y', 'N') ||
       ', SESSION_FLAG: ' || decode(bitand(s.flags, 64), 64, 'Y', 'N') ||
       ', KEEP_VALUE: '   || decode(bitand(s.flags, 512), 512, 'Y', 'N')
from sys.idnseq$ i, sys.obj$ o, sys.user$ u, sys.col$ c, 
     sys.seq$ s, sys.obj$ so
where o.owner# = u.user#
and o.obj# = i.obj#
and c.intcol# = i.intcol#
and c.obj# = i.obj#
and s.obj# = i.seqobj#
and so.obj# = i.seqobj#
/
comment on table DBA_TAB_IDENTITY_COLS is
'Describes all table identity columns'
/
comment on column DBA_TAB_IDENTITY_COLS.OWNER is
'Owner of the table'
/
comment on column DBA_TAB_IDENTITY_COLS.TABLE_NAME is
'Name of the table'
/
comment on column DBA_TAB_IDENTITY_COLS.COLUMN_NAME is
'Name of the identity column'
/
comment on column DBA_TAB_IDENTITY_COLS.GENERATION_TYPE is
'Generation type of the identity column'
/
comment on column DBA_TAB_IDENTITY_COLS.SEQUENCE_NAME is
'Name of the sequence associated with the identity column'
/
comment on column DBA_TAB_IDENTITY_COLS.IDENTITY_OPTIONS is
'Options of the identity column'
/
create or replace public synonym DBA_TAB_IDENTITY_COLS for 
  DBA_TAB_IDENTITY_COLS
/
grant select on DBA_TAB_IDENTITY_COLS to select_catalog_role
/


execute CDBView.create_cdbview(false,'SYS','DBA_TAB_IDENTITY_COLS','CDB_TAB_IDENTITY_COLS');
grant select on SYS.CDB_TAB_IDENTITY_COLS to select_catalog_role
/
create or replace public synonym CDB_TAB_IDENTITY_COLS for SYS.CDB_TAB_IDENTITY_COLS
/

@?/rdbms/admin/sqlsessend.sql
 
