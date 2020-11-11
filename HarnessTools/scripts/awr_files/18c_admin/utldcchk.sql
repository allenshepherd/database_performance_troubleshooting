Rem
Rem $Header: rdbms/admin/utldcchk.sql /main/1 2016/03/09 08:22:10 vperiwal Exp $
Rem
Rem utldcchk.sql
Rem
Rem Copyright (c) 2016, Oracle and/or its affiliates. All rights reserved.
Rem
Rem    NAME
Rem      utldcchk.sql - Dictionary consistency check
Rem
Rem    DESCRIPTION
Rem      This utility script will check for various dictionary consistencies
Rem        - Data Dictionary consistency check for possible ORA-1
Rem            Note: This will check for some known type of ORA-1
Rem
Rem        - Data Dictionary consistency check for missing parent
Rem        - Data Dictionary consistency check for timestamp mismatch
Rem
Rem    NOTES
Rem      This script may reports false positives in some cases.
Rem      Please see utldtchk.sql for current known false
Rem      positive info.
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/utldcchk.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/utldcchk.sql
Rem    SQL_PHASE: UTLDCCHK
Rem    SQL_STARTUP_MODE: NORMAL
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    SQL_CALLING_FILE: NONE
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    vperiwal    01/30/16 - 22351378: Dictionary consistency check
Rem    vperiwal    01/30/16 - Created
Rem

SET ECHO ON
SET FEEDBACK 1
SET NUMWIDTH 10
SET LINESIZE 80
SET TRIMSPOOL ON
SET TAB OFF
SET PAGESIZE 100
SET LINESIZE 120

column owner format a22
column object_name format a32;
column edition_name format a22;

Rem Data Dictionary consistency check for ORA-1
select distinct obj.owner#, ps.obj#, o.owner, o.object_name, o.object_type, 
  o.edition_name
from sys.source$ ps, sys.obj$ obj, dba_objects_ae o
where obj.obj# = ps.obj#
  and obj.type# = 88
  and o.object_id = obj.dataobj#;

Rem Data Dictionary consistency check for missing parent
column o_name format a32;
column u_name format a32;

select d.d_obj#, usr.name u_name, o1.name o_name, o1.type#
from sys.dependency$ d, sys.obj$ o1, sys.user$ usr
where d.d_obj# = o1.obj#
  and o1.status = 1
  and o1.owner# not in (0,1)
  and usr.user# = o1.owner#
  and not exists
    (select 1
     from sys.obj$ o2
     where d.p_obj# = o2.obj#);

Rem Data Dictionary consistency check for timestamp mismatch
@?/rdbms/admin/utldtchk.sql

Rem End of Report

