Rem
Rem $Header: rdbms/admin/catappcont.sql /main/4 2014/02/20 12:45:48 surman Exp $
Rem
Rem catappcont.sql
Rem
Rem Copyright (c) 2012, 2014, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catappcont.sql - Create objects for transaction guard
Rem
Rem    DESCRIPTION
Rem      Creates the table for the transaction guard feature.
Rem
Rem    NOTES
Rem      -
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catappcont.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catappcont.sql
Rem SQL_PHASE: CATAPPCONT
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catptabs.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    surman      01/23/14 - 13922626: Update SQL metadata
Rem    sroesch     06/14/12 - Lrg 6959449: Avoid ORA-02260 error
Rem    sroesch     04/03/12 - Created
Rem    sroesch     06/31/12 - Bug 14106198 - Disable partition check
Rem

@@?/rdbms/admin/sqlsessstart.sql

rem Create table for transaction guard
alter session set events '14524 trace name context forever, level 1';

create table sys.ltxid_trans
(
  maj_version          number       not null,
  min_version          number       not null,
  inst_id              number       not null,
  db_id                number       not null,
  session_guid         raw(64)      not null,
  txn_uid              number       not null,
  commit_no            number       not null,
  start_date           timestamp with time zone not null,
  service_id           number       not null,
  state                number       not null,
  flags                number       not null,
  req_flags            number       not null,
  error_code           number       not null,
  CONSTRAINT ltxid_trans$pk PRIMARY KEY(inst_id, db_id, session_guid, txn_uid)
    USING INDEX (create unique index sys.i_ltxid_trans$pk
                     on sys.ltxid_trans(inst_id, db_id, session_guid, txn_uid)
                     LOCAL (PARTITION ltxid_trans_pk_01 TABLESPACE SYSAUX))
)
PCTFREE 40 INITRANS 20 MAXTRANS 255 
STORAGE (INITIAL 1M NEXT 1M PCTINCREASE 0)
PARTITION BY LIST (inst_id)
  (PARTITION ltxid_trans_1 values (1) TABLESPACE SYSAUX)
/

alter session set events  '14524 OFF';


@?/rdbms/admin/sqlsessend.sql
