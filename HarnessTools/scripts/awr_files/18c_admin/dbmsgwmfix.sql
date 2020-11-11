Rem
Rem $Header: rdbms/admin/dbmsgwmfix.sql /main/9 2017/05/30 17:18:31 saratho Exp $
Rem
Rem dbmsgwmfix.sql
Rem
Rem Copyright (c) 2014, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbmsgwmfix.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/dbmsgwmfix.sql 
Rem    SQL_SHIPPED_FILE: rdbms/admin/dbmsgwmfix.sql
Rem    SQL_PHASE: DBMSGWMFIX
Rem    SQL_STARTUP_MODE: NORMAL 
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: rdbms/admin/dbmsgwm.sql
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    saratho     04/12/17 - Bug 25816781: add fixBC for replace shard
Rem    itaranov    01/26/17 - Bug 24695992: Chunk split native code impl via
Rem                           kkpo
Rem    dcolello    04/16/16 - move validateDatabase() to DBMS_GSM_FIX package
Rem    itaranov    02/24/16 - add getTablespaceDDL
Rem    dcolello    10/30/15 - add validateParameters
Rem    ralekra     11/23/15 - add OGG gg_service validation with add shard
Rem    sdball      06/10/15 - Support for long identifiers
Rem    sdball      03/14/14 - Fixed package for initial shard setup
Rem    sdball      03/14/14 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

-- DE-HEAD     <- tell SED where to cut when generating fixed package

CREATE OR REPLACE PACKAGE dbms_gsm_fixed AS

TYPE name_list IS TABLE OF 
  varchar2(gsmadmin_internal.dbms_gsm_common.max_ident)
  index by binary_integer;

TYPE connect_list IS TABLE OF varchar2(1000) index by binary_integer;

PROCEDURE setupBC (primary_db       IN   varchar2,
                   prim_conn_str    IN   varchar2,
                   prot_mode        IN   number,
                   standby_dbs      IN   name_list,
                   standby_conn_str IN   connect_list,
                   err_num          OUT  number,
                   err_string       OUT  varchar2);

PROCEDURE fixBC (standby_db       IN   varchar2,
                 standby_conn_str IN   varchar2,
                 old_db_name      IN   varchar2,
                 prot_mode        IN   number,
                 err_num          OUT  number,
                 err_string       OUT  varchar2);

PROCEDURE validateParameters (reptype IN NUMBER);

procedure getColumnInfoEx(object_owner in varchar2, object_name in varchar2,
  column_name in varchar2, col_type out number, adt_num out number);

function getTablespaceDDLInternal(tablespaceName varchar2,
    remapName varchar2 default null) return varchar2;

-------------------------------------------------------------------------------
  pragma TIMESTAMP('2014-03-14:18:43:00');
-------------------------------------------------------------------------------

END dbms_gsm_fixed;

-- CUT_HERE    <- tell sed where to chop off the rest

/
show errors
@?/rdbms/admin/sqlsessend.sql
