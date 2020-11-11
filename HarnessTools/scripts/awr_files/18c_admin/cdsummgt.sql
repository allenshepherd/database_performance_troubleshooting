Rem
Rem $Header: rdbms/admin/cdsummgt.sql /main/8 2016/07/18 07:13:21 yanxie Exp $
Rem
Rem cdsummgt.sql
Rem
Rem Copyright (c) 2006, 2016, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      cdsummgt.sql - Catalog DSUMMGT.bsq views
Rem
Rem    DESCRIPTION
Rem      summary management objects
Rem
Rem    NOTES
Rem      This script contains catalog views for objects in dsummgt.bsq.
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/cdsummgt.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/cdsummgt.sql
Rem SQL_PHASE: CDSUMMGT
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catalog.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    yanxie      06/28/16 - remove user$ from all_sumdelta
Rem    skayoor     11/30/14 - Proj 58196: Change Select priv to Read Priv
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    sasounda    11/19/13 - 17746252: handle KZSRAT when creating all_* views
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    huagli      07/08/08 - add new view ALL_SUMMAP
Rem    huagli      03/08/08 - Project 25482: modify view ALL_SUMDELTA to pick 
Rem                           up XID column from SYS.SUMDELTA$
Rem    cdilling    05/04/06 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql


Rem
Rem ALL_SUMDELTA View
Rem
create or replace view ALL_SUMDELTA
    (TABLEOBJ#, PARTITIONOBJ#, DMLOPERATION, SCN,
     TIMESTAMP, LOWROWID, HIGHROWID, SEQUENCE, XID)
as select s.TABLEOBJ#, s.PARTITIONOBJ#, s.DMLOPERATION, s.SCN,
          s.TIMESTAMP, s.LOWROWID, s.HIGHROWID, s.SEQUENCE, s.XID
from  sys.obj$ o, sys.sumdelta$ s
where o.type# = 2
  and s.tableobj# = o.obj#
  and (o.owner# = userenv('SCHEMAID')
    or o.obj# in
      (select oa.obj#
         from sys.objauth$ oa
         where grantee# in ( select kzsrorol from x$kzsro)
      )
    or /* user has system privileges */
      exists (select null from v$enabledprivs
        where priv_number in (-45 /* LOCK ANY TABLE */,
                              -47 /* SELECT ANY TABLE */,
                              -397/* READ ANY TABLE */,
                              -48 /* INSERT ANY TABLE */,
                              -49 /* UPDATE ANY TABLE */,
                              -50 /* DELETE ANY TABLE */)
              )
      )
/
comment on table ALL_SUMDELTA is
'Direct path load entries accessible to the user'
/
comment on column ALL_SUMDELTA.TABLEOBJ# is
'Object number of the table'
/
comment on column ALL_SUMDELTA.PARTITIONOBJ# is
'Object number of table partitions (if the table is partitioned)'
/
comment on column ALL_SUMDELTA.DMLOPERATION is
'Type of DML operation applied to the table'
/
comment on column ALL_SUMDELTA.SCN is
'SCN when the bulk DML occurred'
/
comment on column ALL_SUMDELTA.TIMESTAMP is
'Timestamp of log entry'
/
comment on column ALL_SUMDELTA.LOWROWID is
'The start ROWID in the loaded rowid range'
/
comment on column ALL_SUMDELTA.HIGHROWID is
'The end ROWID in the loaded rowid range'
/
comment on column ALL_SUMDELTA.SEQUENCE is
'The sequence# of the direct load'
/
comment on column ALL_SUMDELTA.XID is
'The transaction ID of the direct load'
/
create or replace public synonym ALL_SUMDELTA for ALL_SUMDELTA
/
grant read on ALL_SUMDELTA to PUBLIC with grant option
/
grant flashback on ALL_SUMDELTA to PUBLIC with grant option
/

Rem
Rem ALL_SUMMAP View
Rem
create or replace view ALL_SUMMAP (XID, COMMIT_SCN)
as select XID, COMMIT_SCN from sys.snap_xcmt$
/
comment on table ALL_SUMMAP is
'mapping entries of transaction ID and commit SCN accessible to the user'
/
comment on column ALL_SUMMAP.XID is
'The ID of a transaction'
/
comment on column ALL_SUMMAP.COMMIT_SCN is
'The commit SCN of a transaction'
/
create or replace public synonym ALL_SUMMAP for ALL_SUMMAP
/
grant read on ALL_SUMMAP to PUBLIC with grant option
/
grant flashback on ALL_SUMMAP to PUBLIC with grant option
/

@?/rdbms/admin/sqlsessend.sql
