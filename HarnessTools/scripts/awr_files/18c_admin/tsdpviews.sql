Rem
Rem $Header: rdbms/admin/tsdpviews.sql /main/9 2015/11/19 05:00:31 amunnoli Exp $
Rem
Rem tsdpviews.sql
Rem
Rem Copyright (c) 2011, 2015, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      tsdpviews.sql - TSDP VIEWS
Rem
Rem    DESCRIPTION
Rem      This file contains the catalog views for Transparent Sensitive
Rem      Data Protection (TSDP).
Rem
Rem    NOTES
Rem      Called by cattsdp.sql
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/tsdpviews.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/tsdpviews.sql
Rem SQL_PHASE: TSDPVIEWS
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/cattsdp.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    amunnoli    11/09/15 - Fix a typo
Rem    gclaborn    07/02/14 - 18844843: grant flashback on SYS views
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    dgraj       08/10/13 - Bug #13716791: Support FGA in TSDP
Rem    dgraj       08/10/13 - Bug #13716803: Support Column Encryption
Rem    talliu      06/28/13 - Add CDB view for DBA view
Rem    surman      04/12/12 - 13615447: Add Add SQL patching tags
Rem    dgraj       02/02/12 - Enhancement for ADM: 13485095. Add view
Rem                           dba_tsdp_import_errors
Rem    dgraj       09/16/11 - Proj 32079, Transparent Sensitive Data
Rem                           Protection (TSDP)
Rem    dgraj       09/16/11 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

CREATE OR REPLACE VIEW DBA_SENSITIVE_DATA (
  SENSITIVE#,
  SCHEMA_NAME,
  TABLE_NAME,
  COLUMN_NAME,
  SENSITIVE_TYPE,
  SOURCE_NAME,
  USER_COMMENT,
  TS)
AS  SELECT
  T.SENSITIVE#,
  U.NAME,
  O.NAME,
  C.NAME,
  T.SENSITIVE_TYPE,
  S.NAME,
  T.USER_COMMENT,
  T.TS
FROM SYS.USER$ U, SYS.OBJ$ O, SYS.COL$ C, SYS.TSDP_SENSITIVE_DATA$ T, 
     SYS.TSDP_SOURCE$ S
WHERE  T.OBJ# = C.OBJ# AND T.COL_ARGUMENT# = c.intcol# AND C.OBJ# = O.OBJ# 
     AND O.OWNER# = U.USER# AND T.SOURCE# = S.SOURCE#
/

create or replace public synonym DBA_SENSITIVE_DATA for
 DBA_SENSITIVE_DATA
/

grant select on DBA_SENSITIVE_DATA to select_catalog_role
/

grant flashback on DBA_SENSITIVE_DATA to select_catalog_role
/

comment on table DBA_SENSITIVE_DATA is
'All sensitive data in the database identified using TSDP'
/

comment on column DBA_SENSITIVE_DATA.SENSITIVE# is
'Unique ID for the sensitive data'
/

comment on column DBA_SENSITIVE_DATA.SCHEMA_NAME is
'The schema containing the sensitive data'
/

comment on column DBA_SENSITIVE_DATA.TABLE_NAME is
'The table containing the sensitive data'
/

comment on column DBA_SENSITIVE_DATA.COLUMN_NAME is
'The column identified as sensitive'
/

comment on column DBA_SENSITIVE_DATA.SENSITIVE_TYPE is
'The sensitive type of the data'
/

comment on column DBA_SENSITIVE_DATA.SOURCE_NAME is
'The source of identification of the sensitive data'
/

comment on column DBA_SENSITIVE_DATA.USER_COMMENT is
'User comment regarding the sensitive data'
/

comment on column DBA_SENSITIVE_DATA.TS is
'The time when the data as identified as sensitive in the database'
/


execute CDBView.create_cdbview(false,'SYS','DBA_SENSITIVE_DATA','CDB_SENSITIVE_DATA');
grant select on SYS.CDB_SENSITIVE_DATA to select_catalog_role
/
create or replace public synonym CDB_SENSITIVE_DATA for SYS.CDB_SENSITIVE_DATA
/

Rem Create table for Datapump
create table dba_sensitive_data_tbl as select * from dba_sensitive_data where 0=1;

grant select on dba_sensitive_data_tbl to select_catalog_role
/

create or replace view DBA_DISCOVERY_SOURCE (
 SOURCE_NAME,
 SOURCE_TYPE,
 CTIME)
as select
 name,
 decode(type, 1, 'DB', 2, 'ADM', 3, 'CUSTOM'),
 ts  
from sys.tsdp_source$ 
/

create or replace public synonym DBA_DISCOVERY_SOURCE for
DBA_DISCOVERY_SOURCE
/

grant select on DBA_DISCOVERY_SOURCE to select_catalog_role
/

comment on table DBA_DISCOVERY_SOURCE is
'All source of sensitive data discovery'
/

comment on column DBA_DISCOVERY_SOURCE.SOURCE_NAME is
'The name of the source'
/

comment on column DBA_DISCOVERY_SOURCE.SOURCE_TYPE is
'The type of the discovery source - within DB or from ADM'
/

comment on column DBA_DISCOVERY_SOURCE.CTIME is
'The last time sensitive data was identified/imported from this source'
/


execute CDBView.create_cdbview(false,'SYS','DBA_DISCOVERY_SOURCE','CDB_DISCOVERY_SOURCE');
grant select on SYS.CDB_DISCOVERY_SOURCE to select_catalog_role
/
create or replace public synonym CDB_DISCOVERY_SOURCE for SYS.CDB_DISCOVERY_SOURCE
/

create or replace view DBA_SENSITIVE_COLUMN_TYPES (
 NAME,
 USER_COMMENT,
 SOURCE_NAME,
 SOURCE_TYPE)
as select
 t.name,
 t.user_comment,
 s.name,
 decode(s.type, 1, 'DB', 2, 'ADM')
from sys.tsdp_sensitive_type$ t, sys.tsdp_source$ s where t.source#=s.source#
/

create or replace public synonym DBA_SENSITIVE_COLUMN_TYPES for
DBA_SENSITIVE_COLUMN_TYPES
/

grant select on DBA_SENSITIVE_COLUMN_TYPES to select_catalog_role
/

comment on table DBA_SENSITIVE_COLUMN_TYPES is
'All Sensitive Column Types in the database'
/

comment on column DBA_SENSITIVE_COLUMN_TYPES.NAME is
'The name of the Sensitive Column Type'
/

comment on column DBA_SENSITIVE_COLUMN_TYPES.USER_COMMENT is
'User comment on the Sensitive Column Type'
/

comment on column DBA_SENSITIVE_COLUMN_TYPES.SOURCE_NAME is
'The source of the Sensitive Column Type'
/

comment on column DBA_SENSITIVE_COLUMN_TYPES.SOURCE_TYPE is
'The type of the source - DB or ADM'
/


execute CDBView.create_cdbview(false,'SYS','DBA_SENSITIVE_COLUMN_TYPES','CDB_SENSITIVE_COLUMN_TYPES');
grant select on SYS.CDB_SENSITIVE_COLUMN_TYPES to select_catalog_role
/
create or replace public synonym CDB_SENSITIVE_COLUMN_TYPES for SYS.CDB_SENSITIVE_COLUMN_TYPES
/

create or replace view DBA_TSDP_POLICY_FEATURE (
 POLICY_NAME,
 SECURITY_FEATURE)
as select
 name,
 decode(sec_feature, 0, 'REDACT_AUDIT', 1, 'REDACTION', 2, 'AUDIT', 3, 'VPD', 4, 'COL ENCRYPT', 5, 'FGA')
from sys.tsdp_policy$
/

create or replace public synonym DBA_TSDP_POLICY_FEATURE for
DBA_TSDP_POLICY_FEATURE
/

grant select on DBA_TSDP_POLICY_FEATURE  to select_catalog_role
/

comment on table DBA_TSDP_POLICY_FEATURE is
'All TSDP policies in the database'
/

comment on column DBA_TSDP_POLICY_FEATURE.POLICY_NAME is
'Name of the TSDP Policy'
/

comment on column DBA_TSDP_POLICY_FEATURE.SECURITY_FEATURE is
'The security feature associated with the TSDP policy'
/


execute CDBView.create_cdbview(false,'SYS','DBA_TSDP_POLICY_FEATURE','CDB_TSDP_POLICY_FEATURE');
grant select on SYS.CDB_TSDP_POLICY_FEATURE to select_catalog_role
/
create or replace public synonym CDB_TSDP_POLICY_FEATURE for SYS.CDB_TSDP_POLICY_FEATURE
/

create or replace view DBA_TSDP_POLICY_CONDITION (
 POLICY_NAME,
 SUB_POLICY,
 PROPERTY,
 VALUE)
as select
 p.name,
 s.subpolnum,
 decode(c.property, 1, 'DATATYPE', 2, 'LENGTH', 3, 
        'SCHEMA_NAME', 4, 'TABLE_NAME'), 
 c.value
from tsdp_policy$ p, tsdp_condition$ c, tsdp_subpol$ s
where c.subpol# = s.subpol# and s.policy# = p.policy#
/

create or replace public synonym DBA_TSDP_POLICY_CONDITION for
DBA_TSDP_POLICY_CONDITION
/

grant select on DBA_TSDP_POLICY_CONDITION  to select_catalog_role
/

comment on table DBA_TSDP_POLICY_CONDITION is
'The conditions of TSDP policies'
/

comment on column DBA_TSDP_POLICY_CONDITION.POLICY_NAME is
'The TSDP policy'
/

comment on column DBA_TSDP_POLICY_CONDITION.SUB_POLICY is
'The sub policy of the TSDP policy'
/

comment on column DBA_TSDP_POLICY_CONDITION.PROPERTY is
'The condition property'
/

comment on column DBA_TSDP_POLICY_CONDITION.VALUE is
'The value of the condition property'
/


execute CDBView.create_cdbview(false,'SYS','DBA_TSDP_POLICY_CONDITION','CDB_TSDP_POLICY_CONDITION');
grant select on SYS.CDB_TSDP_POLICY_CONDITION to select_catalog_role
/
create or replace public synonym CDB_TSDP_POLICY_CONDITION for SYS.CDB_TSDP_POLICY_CONDITION
/

create or replace view DBA_TSDP_POLICY_PARAMETER (
 POLICY_NAME,
 SUB_POLICY,
 PARAMETER,
 VALUE,
 DEFAULT_OPTION)
as select
  po.name,
  sb.subpolnum,
  pr.parameter,
  pr.value,
  decode(bitand(sb.property, 1), 1, 'TRUE', 'FALSE')
from tsdp_policy$ po, tsdp_parameter$ pr, tsdp_subpol$ sb
where pr.subpol# = sb.subpol# and sb.policy# = po.policy#
/

create or replace public synonym DBA_TSDP_POLICY_PARAMETER for
DBA_TSDP_POLICY_PARAMETER
/

grant select on DBA_TSDP_POLICY_PARAMETER to select_catalog_role
/

comment on table DBA_TSDP_POLICY_PARAMETER  is
'Parameters of the TSDP policies'
/

comment on column DBA_TSDP_POLICY_PARAMETER.POLICY_NAME is
'The TSDP policy name'
/

comment on column DBA_TSDP_POLICY_PARAMETER.SUB_POLICY is
'The sub policy of the TSDP policy'
/

comment on column DBA_TSDP_POLICY_PARAMETER.PARAMETER is
'The parameter for the TSDP sub policy'
/

comment on column DBA_TSDP_POLICY_PARAMETER.VALUE is
'The value of the parameter'
/

comment on column DBA_TSDP_POLICY_PARAMETER.DEFAULT_OPTION is
'Is this the default option for the policy ?'
/


execute CDBView.create_cdbview(false,'SYS','DBA_TSDP_POLICY_PARAMETER','CDB_TSDP_POLICY_PARAMETER');
grant select on SYS.CDB_TSDP_POLICY_PARAMETER to select_catalog_role
/
create or replace public synonym CDB_TSDP_POLICY_PARAMETER for SYS.CDB_TSDP_POLICY_PARAMETER
/

create or replace view DBA_TSDP_POLICY_TYPE (
 POLICY_NAME,
 SENSITIVE_TYPE)
as select
 p.name,
 s.name
from sys.tsdp_policy$ p, sys.tsdp_sensitive_type$ s, sys.tsdp_association$ a
where a.policy# = p.policy# and a.sensitive_type# = s.type#
/

create or replace public synonym DBA_TSDP_POLICY_TYPE for
DBA_TSDP_POLICY_TYPE
/

grant select on DBA_TSDP_POLICY_TYPE to select_catalog_role
/

comment on table DBA_TSDP_POLICY_TYPE is
'All TSDP policy and Sensitive Type associations'
/

comment on column DBA_TSDP_POLICY_TYPE.POLICY_NAME is
'The TSDP policy name'
/

comment on column DBA_TSDP_POLICY_TYPE.SENSITIVE_TYPE is
'The Sensitive Type'
/


execute CDBView.create_cdbview(false,'SYS','DBA_TSDP_POLICY_TYPE','CDB_TSDP_POLICY_TYPE');
grant select on SYS.CDB_TSDP_POLICY_TYPE to select_catalog_role
/
create or replace public synonym CDB_TSDP_POLICY_TYPE for SYS.CDB_TSDP_POLICY_TYPE
/

create or replace view DBA_TSDP_POLICY_PROTECTION (
  SCHEMA_NAME,
  TABLE_NAME,
  COLUMN_NAME,
  TSDP_POLICY,
  SECURITY_FEATURE,
  SECURITY_FEATURE_POLICY,
  SUBPOLICY#)
as select
  u.name,
  o.name,
  c.name,
  po.name,
  decode(fp.sec_feature, 0, 'REDACT_AUDIT', 1, 'REDACTION', 2, 'AUDIT', 3, 'VPD', 4, 'COL ENCRYPT', 5, 'FGA'),
  fp.feature_polname,
  sb.subpolnum
from sys.tsdp_protection$ pr, sys.tsdp_policy$ po, sys.user$ u, sys.obj$ o,
     sys.col$ c, sys.tsdp_subpol$ sb, sys.tsdp_sensitive_data$ s, 
     sys.tsdp_feature_policy$ fp
where pr.sensitive# = s.sensitive# 
      and s.obj# = c.obj#
      and s.col_argument# = c.intcol#
      and c.obj# = o.obj#
      and o.owner# = u.user#
      and pr.subpol# = sb.subpol#
      and sb.policy# = po.policy#
      and pr.feature_polname = fp.feature_polname
      and fp.obj# = s.obj#
/

create or replace public synonym DBA_TSDP_POLICY_PROTECTION for
DBA_TSDP_POLICY_PROTECTION
/

grant select on DBA_TSDP_POLICY_PROTECTION to select_catalog_role
/

grant flashback on DBA_TSDP_POLICY_PROTECTION to select_catalog_role
/

comment on table DBA_TSDP_POLICY_PROTECTION is 
'Lists the protection enabled through TSDP'
/

comment on column DBA_TSDP_POLICY_PROTECTION.SCHEMA_NAME is
'The schema containing the sensitive data'
/

comment on column DBA_TSDP_POLICY_PROTECTION.TABLE_NAME is
'The table containing the sensitive data'
/

comment on column DBA_TSDP_POLICY_PROTECTION.COLUMN_NAME is
'The sensitive column'
/

comment on column DBA_TSDP_POLICY_PROTECTION.TSDP_POLICY is
'The TSDP policy based on which protection was enabled'
/

comment on column DBA_TSDP_POLICY_PROTECTION.SECURITY_FEATURE is
'The security feature enabled on the sensitive data'
/

comment on column DBA_TSDP_POLICY_PROTECTION.SECURITY_FEATURE_POLICY is
'Name of the underlying security feature policy'
/

comment on column DBA_TSDP_POLICY_PROTECTION.SUBPOLICY# is
'The subpolicy of the TSDP policy based on which protection has been enabled'
/


execute CDBView.create_cdbview(false,'SYS','DBA_TSDP_POLICY_PROTECTION','CDB_TSDP_POLICY_PROTECTION');
grant select on SYS.CDB_TSDP_POLICY_PROTECTION to select_catalog_role
/
create or replace public synonym CDB_TSDP_POLICY_PROTECTION for SYS.CDB_TSDP_POLICY_PROTECTION
/

Rem Table for Datapump
create table dba_tsdp_policy_protection_tbl as select * from dba_tsdp_policy_protection where 0=1;

grant select on dba_tsdp_policy_protection_tbl to select_catalog_role
/

create or replace view DBA_TSDP_IMPORT_ERRORS (
  ERROR_CODE,
  SCHEMA_NAME,
  TABLE_NAME,
  COLUMN_NAME,
  SENSITIVE_TYPE)
as select
  errcode,
  identifier1,
  identifier2,
  identifier3,
  identifier4
from sys.tsdp_error$
/

create or replace public synonym DBA_TSDP_IMPORT_ERRORS for
DBA_TSDP_IMPORT_ERRORS
/

grant select on DBA_TSDP_IMPORT_ERRORS to select_catalog_role
/

comment on table DBA_TSDP_IMPORT_ERRORS is 
'Lists the errors encountered during import of Discovery Result'
/

comment on column DBA_TSDP_IMPORT_ERRORS.ERROR_CODE is
'The ORA error code of the error encountered'
/

comment on column DBA_TSDP_IMPORT_ERRORS.SCHEMA_NAME is
'The Schema corresponding to the error'
/

comment on column DBA_TSDP_IMPORT_ERRORS.TABLE_NAME is
'The Table corresponding to the error'
/

comment on column DBA_TSDP_IMPORT_ERRORS.COLUMN_NAME is
'The Column corresponding to the error'
/

comment on column DBA_TSDP_IMPORT_ERRORS.SENSITIVE_TYPE is
'The Sensitive Type corresponding to the error'
/


execute CDBView.create_cdbview(false,'SYS','DBA_TSDP_IMPORT_ERRORS','CDB_TSDP_IMPORT_ERRORS');
grant select on SYS.CDB_TSDP_IMPORT_ERRORS to select_catalog_role
/
create or replace public synonym CDB_TSDP_IMPORT_ERRORS for SYS.CDB_TSDP_IMPORT_ERRORS
/


@?/rdbms/admin/sqlsessend.sql
