Rem
Rem $Header: rdbms/src/server/security/ols/admin/olsddv.sql /main/23 2017/06/27 06:26:34 risgupta Exp $
Rem
Rem olsddv.sql
Rem
Rem Copyright (c) 2011, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      olsddv.sql - Oracle Label Security Data Dictionary Views
Rem
Rem    DESCRIPTION
Rem      Creates OLS Views 
Rem
Rem    NOTES
Rem      Run as SYS or LBACSYS
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/src/server/security/ols/admin/catolsddv.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catolsddv.sql
Rem SQL_PHASE: CATOLSDDV
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catols.sql
Rem END SQL_FILE_METADATA
Rem
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    pjulsaks    06/26/17 - Bug 25688154: Uppercase create_cdbview's input
Rem    risgupta    06/19/17 - Bug 26305776: Set user_labels in all_sa_users to
Rem                           NULL
Rem    risgupta    04/12/17 - Bug 25121695: Use fully qualified names
Rem                           for references
Rem    risgupta    03/17/17 - Bug 25642402: Set user_labels in dba_sa_users to
Rem                           NULL
Rem    risgupta    06/22/16 - Bug 23625142: Use CURRENT_USER instead of 
Rem                           SESSION_USER in all_sa_* views
Rem    risgupta    01/23/15 - Bug 20402799: create or replace public synonyms
Rem    risgupta    06/11/14 - Proj 36685: Update users OLS authorizaions view
Rem    aketkar     04/28/14 - Bug 18331292: Adding sql metadata seed
Rem    talliu      07/26/13 - bug 17024953:add cdbviews
Rem    aramappa    02/09/12 - bug 13606907:remove ols_audit_trail
Rem    risgupta    01/19/12 - Bug 13596544: Make SYS.ols_audit_trail view
Rem                           PDB-specific
Rem    risgupta    12/13/11 - Logon Profile Changes: Update DBA_OLS_USERS view
Rem    aramappa    01/16/12 - bug13557529:add grant to sys.ols_audit_trail
Rem    srtata      12/27/11 - create synonym for DBA_OLS_STATUS
Rem    aramappa    10/31/11 - bug13098014: Add DBA_OLS_STATUS view on ols$props
Rem    srtata      11/16/11 - bug 13389617 remove SET ECHO stmts
Rem    risgupta    09/28/11 - Proj 31942: OLS Rearch - remove spool commands
Rem    srtata      08/26/11 - rename all tables to ols$
Rem    nkgopal     08/22/11 - Bug 12794380: V$AUDIT_TRAIL to
Rem                           V$UNIFIED_AUDIT_TRAIL
Rem    risgupta    06/20/11 - proj 5700: Add OLS auditing views
Rem    srtata      06/23/11 - integrate and organize all views
Rem    srtata      05/06/11 - add User views
Rem    risgupta    02/24/11 - Created
Rem


@@?/rdbms/admin/sqlsessstart.sql

-- Convert the below ones to new schema eventually

CREATE OR REPLACE VIEW LBACSYS.dba_lbac_policies 
 (policy_name, column_name, package, status, policy_options, policy_subscribed)
  AS
  SELECT pol_name, 
         column_name, package, 
         DECODE(bitand(flags,1),0,'DISABLED',1,'ENABLED','ERROR'),
         LBACSYS.lbac_cache.option_string(options),
         DECODE(bitand(flags,16),0,'FALSE',16,'TRUE','ERROR')
  FROM LBACSYS.ols$pol;

execute SYS.CDBView.create_cdbview(false,'LBACSYS','DBA_LBAC_POLICIES','CDB_LBAC_POLICIES');
create or replace public synonym CDB_lbac_policies for LBACSYS.CDB_lbac_policies;


CREATE OR REPLACE VIEW LBACSYS.dba_lbac_schema_policies AS
  SELECT pol_name AS policy_name, owner AS schema_name,
  DECODE(bitand(s.flags,1),0,'DISABLED',1,'ENABLED','ERROR') AS status,
  LBACSYS.lbac_cache.option_string(s.options) AS schema_options
  FROM LBACSYS.ols$pol p, LBACSYS.ols$pols s
  WHERE p.pol# = s.pol#;

execute SYS.CDBView.create_cdbview(false,'LBACSYS','DBA_LBAC_SCHEMA_POLICIES','CDB_LBAC_SCHEMA_POLICIES');
create or replace public synonym CDB_lbac_schema_policies for LBACSYS.CDB_lbac_schema_policies;

  
CREATE OR REPLACE VIEW LBACSYS.dba_lbac_table_policies AS
  SELECT pol_name AS policy_name, owner AS schema_name, 
         tbl_name AS table_name,
         DECODE(bitand(t.flags,1),0,'DISABLED',1,'ENABLED','ERROR') AS
         status,
         LBACSYS.lbac_cache.option_string(t.options) AS table_options,
         function,
         predicate
  FROM LBACSYS.ols$pol p, LBACSYS.ols$polt t
  WHERE p.pol# = t.pol#;

execute SYS.CDBView.create_cdbview(false,'LBACSYS','DBA_LBAC_TABLE_POLICIES','CDB_LBAC_TABLE_POLICIES');
create or replace public synonym CDB_lbac_table_policies for LBACSYS.CDB_lbac_table_policies;


-- Create synonyms for old schema based views
CREATE OR REPLACE PUBLIC SYNONYM dba_lbac_policies FOR LBACSYS.dba_lbac_policies;
CREATE OR REPLACE PUBLIC SYNONYM dba_lbac_schema_policies
                     FOR LBACSYS.dba_lbac_schema_policies;
CREATE OR REPLACE PUBLIC SYNONYM dba_lbac_table_policies
                     FOR LBACSYS.dba_lbac_table_policies;

-- Current customer facing DBA_ views for policies

CREATE OR REPLACE VIEW LBACSYS.dba_sa_policies AS
   SELECT policy_name, column_name, status, policy_options, policy_subscribed
   FROM LBACSYS.dba_lbac_policies
   WHERE package = 'LBAC$SA';

execute SYS.CDBView.create_cdbview(false,'LBACSYS','DBA_SA_POLICIES','CDB_SA_POLICIES');
create or replace public synonym CDB_sa_policies for LBACSYS.CDB_sa_policies;
grant select on CDB_sa_policies to select_catalog_role;


CREATE OR REPLACE VIEW LBACSYS.dba_sa_schema_policies AS
  SELECT s.policy_name, schema_name, s.status, schema_options
  FROM LBACSYS.dba_lbac_policies p, LBACSYS.dba_lbac_schema_policies s
  WHERE p.policy_name=s.policy_name
    AND p.package='LBAC$SA';

execute SYS.CDBView.create_cdbview(false,'LBACSYS','DBA_SA_SCHEMA_POLICIES','CDB_SA_SCHEMA_POLICIES');
create or replace public synonym CDB_sa_schema_policies for LBACSYS.CDB_sa_schema_policies;
grant select on CDB_sa_schema_policies to select_catalog_role;


CREATE OR REPLACE VIEW LBACSYS.dba_sa_table_policies AS
  SELECT t.policy_name, schema_name, table_name, t.status,
         table_options, function, predicate
  FROM LBACSYS.dba_lbac_policies p, LBACSYS.dba_lbac_table_policies t
  WHERE p.policy_name=t.policy_name
    AND p.package='LBAC$SA';

execute SYS.CDBView.create_cdbview(false,'LBACSYS','DBA_SA_TABLE_POLICIES','CDB_SA_TABLE_POLICIES');
create or replace public synonym CDB_sa_table_policies for LBACSYS.CDB_sa_table_policies;
grant select on CDB_sa_table_policies to select_catalog_role;



-- private views to Support All SA views

CREATE OR REPLACE VIEW LBACSYS.sa$pol AS
SELECT pol#,
       pol_name,
       column_name,
       DECODE(bitand(flags,1),0,'DISABLED',1,'ENABLED','ERROR') AS status,
       LBACSYS.lbac_cache.option_string(options) AS policy_options,
       pol_role as Admin_Role
  FROM LBACSYS.ols$pol
 WHERE package = 'LBAC$SA';

CREATE OR REPLACE VIEW LBACSYS.sa$admin AS
SELECT POL#, pol_name, granted_role admin_role, R.grantee usr_name
  FROM LBACSYS.ols$pol P,
       sys.dba_role_privs R
 WHERE P.package = 'LBAC$SA'
   AND R.granted_role = P.pol_role;

-- All public SA views   
-- The following views are intended for policy administrators.

CREATE OR REPLACE VIEW LBACSYS.all_sa_policies AS
   SELECT p.pol_name as policy_name, p.column_name, p.status, p.policy_options
     FROM LBACSYS.sa$pol p
    WHERE pol# in (select pol# from LBACSYS.sa$admin
                   where usr_name = SYS_CONTEXT('USERENV', 'CURRENT_USER'));

CREATE OR REPLACE VIEW LBACSYS.all_sa_schema_policies AS
  SELECT s.policy_name, schema_name, s.status, schema_options
    FROM LBACSYS.sa$pol p, LBACSYS.dba_lbac_schema_policies s
   WHERE p.pol_name = s.policy_name 
     AND pol# in (select pol# from LBACSYS.sa$admin
                  where usr_name = SYS_CONTEXT('USERENV', 'CURRENT_USER'));

CREATE OR REPLACE VIEW LBACSYS.all_sa_table_policies AS
  SELECT t.policy_name, schema_name, table_name, t.status,
         table_options, function, predicate
    FROM LBACSYS.sa$pol p, LBACSYS.dba_lbac_table_policies t
   WHERE p.pol_name=t.policy_name 
     AND pol# in (select pol# from LBACSYS.sa$admin
                  where usr_name = SYS_CONTEXT('USERENV', 'CURRENT_USER'));

---------------------------------------------------------------------------
-- First create all the "DBA_" views

CREATE OR REPLACE VIEW LBACSYS.dba_lbac_data_labels AS
  SELECT pol_name AS policy_name,
         slabel AS label,
         nlabel AS label_tag
  FROM LBACSYS.ols$lab l, LBACSYS.ols$pol p
  WHERE p.pol# = l.pol# AND BITAND(l.flags,1)=1;

execute SYS.CDBView.create_cdbview(false,'LBACSYS','DBA_LBAC_DATA_LABELS','CDB_LBAC_DATA_LABELS');



CREATE OR REPLACE VIEW LBACSYS.dba_lbac_labels AS
  SELECT pol_name AS policy_name,
         slabel AS label,
         nlabel AS label_tag,
         DECODE (l.flags,2,'USER LABEL',
                 3, 'USER/DATA LABEL', 'UNDEFINED') AS label_type
  FROM LBACSYS.ols$lab l, LBACSYS.ols$pol p
  WHERE p.pol# = l.pol#;

execute SYS.CDBView.create_cdbview(false,'LBACSYS','DBA_LBAC_LABELS','CDB_LBAC_LABELS');

CREATE OR REPLACE VIEW LBACSYS.dba_lbac_label_tags AS
  SELECT pol_name AS policy_name,
         slabel AS labelvalue,
         nlabel AS labeltag,
         DECODE (l.flags,2,'USER LABEL',
                 3, 'USER/DATA LABEL','UNDEFINED') AS
         labeltype
  FROM LBACSYS.ols$lab l, LBACSYS.ols$pol p
  WHERE p.pol# = l.pol#;


execute SYS.CDBView.create_cdbview(false,'LBACSYS','DBA_LBAC_LABEL_TAGS','CDB_LBAC_LABEL_TAGS');

CREATE OR REPLACE VIEW LBACSYS.dba_sa_labels AS
  SELECT p.pol_name AS policy_name,
         l.slabel AS label,
         l.nlabel AS label_tag,
         DECODE (l.flags,2,'USER LABEL',
                 3, 'USER/DATA LABEL', 'UNDEFINED') AS label_type
  FROM LBACSYS.ols$lab l, LBACSYS.ols$pol p
  WHERE p.pol# = l.pol#;

execute SYS.CDBView.create_cdbview(false,'LBACSYS','DBA_SA_LABELS','CDB_SA_LABELS');
create or replace public synonym CDB_sa_labels for LBACSYS.CDB_sa_labels;
grant select on CDB_sa_labels to select_catalog_role;

CREATE OR REPLACE VIEW LBACSYS.dba_sa_data_labels AS
   SELECT l.policy_name, label, label_tag
   FROM LBACSYS.dba_lbac_data_labels l, LBACSYS.dba_lbac_policies p
   WHERE l.policy_name = p.policy_name AND
         p.package = 'LBAC$SA';

execute SYS.CDBView.create_cdbview(false,'LBACSYS','DBA_SA_DATA_LABELS','CDB_SA_DATA_LABELS');
create or replace public synonym CDB_sa_data_labels for LBACSYS.CDB_sa_data_labels;
grant select on CDB_sa_data_labels to select_catalog_role;


CREATE OR REPLACE VIEW LBACSYS.dba_sa_levels AS
   SELECT p.pol_name AS policy_name, l.level# AS level_num,
          l.code AS short_name, l.name AS long_name
   FROM LBACSYS.ols$pol p, LBACSYS.ols$levels l
   WHERE p.pol# = l.pol#;

execute SYS.CDBView.create_cdbview(false,'LBACSYS','DBA_SA_LEVELS','CDB_SA_LEVELS');
create or replace public synonym CDB_sa_levels for LBACSYS.CDB_sa_levels;
grant select on CDB_sa_levels to select_catalog_role;


CREATE OR REPLACE VIEW LBACSYS.dba_sa_compartments AS
   SELECT p.pol_name AS policy_name, c.comp# AS comp_num,
          c.code AS short_name, c.name AS long_name
   FROM LBACSYS.ols$pol p, LBACSYS.ols$compartments c
   WHERE p.pol# = c.pol#;

execute SYS.CDBView.create_cdbview(false,'LBACSYS','DBA_SA_COMPARTMENTS','CDB_SA_COMPARTMENTS');
create or replace public synonym CDB_sa_compartments for LBACSYS.CDB_sa_compartments;
grant select on CDB_sa_compartments to select_catalog_role;


CREATE OR REPLACE VIEW LBACSYS.dba_sa_groups AS
   SELECT p.pol_name AS policy_name, g.group# AS group_num,
          g.code AS short_name, g.name AS long_name,
          g.parent# AS parent_num, pg.code AS parent_name
   FROM LBACSYS.ols$pol p, LBACSYS.ols$groups g, LBACSYS.ols$groups pg
   WHERE p.pol# = g.pol# AND
         g.pol# = pg.pol# (+) AND
         g.parent# = pg.group#(+);

execute SYS.CDBView.create_cdbview(false,'LBACSYS','DBA_SA_GROUPS','CDB_SA_GROUPS');
create or replace public synonym CDB_sa_groups for LBACSYS.CDB_sa_groups;
grant select on CDB_sa_groups to select_catalog_role;


CREATE OR REPLACE VIEW LBACSYS.dba_sa_group_hierarchy AS
   SELECT l.pol_name AS policy_name, g.hierarchy_level, g.group_name
   FROM ( SELECT LEVEL AS hierarchy_level,
            RPAD(' ',2*LEVEL,' ') || code || ' - ' ||  name AS group_name,
            pol#
        FROM LBACSYS.ols$groups
        CONNECT BY PRIOR pol#=pol# AND PRIOR group#=parent#
        START WITH parent# IS NULL) g, LBACSYS.ols$pol l
   WHERE g.pol#=l.pol#;

execute SYS.CDBView.create_cdbview(false,'LBACSYS','DBA_SA_GROUP_HIERARCHY','CDB_SA_GROUP_HIERARCHY');
create or replace public synonym CDB_sa_group_hierarchy for LBACSYS.CDB_sa_group_hierarchy;
grant select on CDB_sa_group_hierarchy to select_catalog_role;


CREATE OR REPLACE VIEW LBACSYS.dba_sa_user_levels AS
   SELECT DISTINCT p.pol_name AS policy_name, 
          ul.usr_name AS user_name,
          lmax.code AS max_level, 
          lmin.code AS min_level, 
          ldef.code AS def_level, 
          lrow.code AS row_level
   FROM LBACSYS.ols$pol p, LBACSYS.ols$user_levels ul,
        LBACSYS.ols$levels lmax, LBACSYS.ols$levels lmin,
        LBACSYS.ols$levels ldef, LBACSYS.ols$levels lrow
   WHERE p.pol#=ul.pol# AND
         ul.pol#=lmax.pol# AND 
         ul.pol#=lmin.pol# AND 
         ul.pol#=ldef.pol# AND 
         ul.pol#=lrow.pol# AND 
         ul.max_level = lmax.level# AND
         ul.min_level = lmin.level# AND
         ul.def_level = ldef.level# AND
         ul.row_level = lrow.level#;

execute SYS.CDBView.create_cdbview(false,'LBACSYS','DBA_SA_USER_LEVELS','CDB_SA_USER_LEVELS');
create or replace public synonym CDB_sa_user_levels for LBACSYS.CDB_sa_user_levels;
grant select on CDB_sa_user_levels to select_catalog_role;


CREATE OR REPLACE VIEW LBACSYS.dba_sa_user_compartments AS
   SELECT p.pol_name AS policy_name, uc.usr_name AS user_name,
        c.code AS comp, DECODE(uc.rw_access,'1','WRITE','READ') AS rw_access,
        uc.def_comp, uc.row_comp
   FROM LBACSYS.ols$pol p, LBACSYS.ols$user_compartments uc,
        LBACSYS.ols$compartments c
   WHERE p.pol#=uc.pol# AND uc.pol#=c.pol# AND uc.comp# = c.comp#;

execute SYS.CDBView.create_cdbview(false,'LBACSYS','DBA_SA_USER_COMPARTMENTS','CDB_SA_USER_COMPARTMENTS');
create or replace public synonym CDB_sa_user_compartments for LBACSYS.CDB_sa_user_compartments;
grant select on CDB_sa_user_compartments to select_catalog_role;


CREATE OR REPLACE VIEW LBACSYS.dba_sa_user_groups AS
   SELECT p.pol_name AS policy_name, ug.usr_name AS user_name,
        g.code AS grp, DECODE(ug.rw_access,'1','WRITE','READ') AS rw_access,
        ug.def_group, ug.row_group
   FROM LBACSYS.ols$pol p, LBACSYS.ols$user_groups ug, LBACSYS.ols$groups g
   WHERE p.pol#=ug.pol# AND ug.pol#=g.pol# AND ug.group# = g.group#;

execute SYS.CDBView.create_cdbview(false,'LBACSYS','DBA_SA_USER_GROUPS','CDB_SA_USER_GROUPS');
create or replace public synonym CDB_sa_user_groups for LBACSYS.CDB_sa_user_groups;
grant select on CDB_sa_user_groups to select_catalog_role;


-- Proj 36685: Use privs_to_char_n standalone function to remove 
-- view dependency on SA_USER_ADMIN package.
CREATE OR REPLACE VIEW LBACSYS.dba_ols_users AS
  SELECT usr_name AS user_name,
         pol_name AS policy_name,
         LBACSYS.privs_to_char_n(pf.privs) AS user_privileges,
         lbacsys.lbac$sa_labels.from_label(pf.max_read) AS LABEL1,
         lbacsys.lbac$sa_labels.from_label(pf.max_write) AS LABEL2,
         lbacsys.lbac$sa_labels.from_label(pf.min_write) AS LABEL3,
         lbacsys.lbac$sa_labels.from_label(pf.def_read) AS LABEL4,
         lbacsys.lbac$sa_labels.from_label(pf.def_write) AS LABEL5, 
         lbacsys.lbac$sa_labels.from_label(pf.def_row) AS LABEL6
  FROM LBACSYS.ols$pol p, LBACSYS.ols$user u, LBACSYS.ols$profile pf
  WHERE p.pol# = u.pol# AND p.pol# = pf.pol# 
    AND u.pol# = pf.pol# AND u.profid = pf.profid;

execute SYS.CDBView.create_cdbview(false,'LBACSYS','DBA_OLS_USERS','CDB_OLS_USERS');


CREATE OR REPLACE VIEW LBACSYS.dba_sa_users AS
  SELECT user_name,  u.policy_name, user_privileges, 
         NULL AS user_labels,
         LABEL1 AS MAX_READ_LABEL, LABEL2 AS MAX_WRITE_LABEL,
         LABEL3 AS MIN_WRITE_LABEL , LABEL4 AS DEFAULT_READ_LABEL,
         LABEL5 AS DEFAULT_WRITE_LABEL, LABEL6 AS DEFAULT_ROW_LABEL
  FROM LBACSYS.dba_lbac_policies p, LBACSYS.dba_ols_users u 
  WHERE p.policy_name=u.policy_name;

execute SYS.CDBView.create_cdbview(false,'LBACSYS','DBA_SA_USERS','CDB_SA_USERS');
create or replace public synonym CDB_sa_users for LBACSYS.CDB_sa_users;
grant select on CDB_sa_users to select_catalog_role;



CREATE OR REPLACE VIEW LBACSYS.dba_sa_user_labels AS
  SELECT user_name,policy_name, user_labels as labels,
         MAX_READ_LABEL, MAX_WRITE_LABEL, MIN_WRITE_LABEL,
         DEFAULT_READ_LABEL, DEFAULT_WRITE_LABEL, DEFAULT_ROW_LABEL
  FROM LBACSYS.dba_sa_users
  WHERE MAX_READ_LABEL IS NOT NULL;

execute SYS.CDBView.create_cdbview(false,'LBACSYS','DBA_SA_USER_LABELS','CDB_SA_USER_LABELS');
create or replace public synonym CDB_sa_user_labels for LBACSYS.CDB_sa_user_labels;
grant select on CDB_sa_user_labels to select_catalog_role;



CREATE OR REPLACE VIEW LBACSYS.dba_sa_user_privs AS
  SELECT user_name,
         policy_name,
         user_privileges
  FROM LBACSYS.dba_sa_users 
  WHERE user_privileges IS NOT NULL;

execute SYS.CDBView.create_cdbview(false,'LBACSYS','DBA_SA_USER_PRIVS','CDB_SA_USER_PRIVS');
create or replace public synonym CDB_sa_user_privs for LBACSYS.CDB_sa_user_privs;
grant select on CDB_sa_user_privs to select_catalog_role;



-- Proj 36685: Use privs_to_char_n standalone function to remove 
-- view dependency on SA_USER_ADMIN package.
CREATE OR REPLACE VIEW LBACSYS.dba_sa_programs AS
  SELECT owner as schema_name, pgm_name AS program_name,
         pol_name AS policy_name,
         LBACSYS.privs_to_char_n(privs) AS prog_privileges,
         '             ' as prog_labels
  FROM LBACSYS.ols$pol p, LBACSYS.ols$prog g
  WHERE p.pol# = g.pol#;

execute SYS.CDBView.create_cdbview(false,'LBACSYS','DBA_SA_PROGRAMS','CDB_SA_PROGRAMS');
create or replace public synonym CDB_sa_programs for LBACSYS.CDB_sa_programs;
grant select on CDB_sa_programs to select_catalog_role;



-- Proj 36685: Use privs_to_char_n standalone function to remove 
-- view dependency on SA_USER_ADMIN package.
CREATE OR REPLACE VIEW LBACSYS.dba_sa_prog_privs AS
  SELECT owner as schema_name, pgm_name AS program_name,
         pol_name AS policy_name,
         LBACSYS.privs_to_char_n(privs) AS program_privileges
  FROM LBACSYS.ols$pol p, LBACSYS.ols$prog g
  WHERE p.pol# = g.pol#;

execute SYS.CDBView.create_cdbview(false,'LBACSYS','DBA_SA_PROG_PRIVS','CDB_SA_PROG_PRIVS');
create or replace public synonym CDB_sa_prog_privs for LBACSYS.CDB_sa_prog_privs;
grant select on CDB_sa_prog_privs to select_catalog_role;


-- Create all the "ALL_" View Definitions

-- View Definitions for Labels
CREATE OR REPLACE VIEW LBACSYS.all_sa_labels AS 
  SELECT p.pol_name AS policy_name,
         l.slabel   AS label,
         l.nlabel   AS label_tag,
         DECODE (l.flags,2,'USER LABEL',
                 3, 'USER/DATA LABEL', 'UNDEFINED') AS label_type
   FROM LBACSYS.ols$lab l, LBACSYS.sa$pol p
  WHERE p.pol# = l.pol#
    AND (p.pol# in (select pol# from LBACSYS.sa$admin
                    where usr_name = SYS_CONTEXT('USERENV', 'CURRENT_USER'))
         OR
         LBACSYS.lbac$sa.enforce_read(p.pol_name, l.ilabel)>0);
   
CREATE OR REPLACE VIEW LBACSYS.all_sa_data_labels AS
  SELECT p.pol_name AS policy_name,
         l.slabel   AS label,
         l.nlabel   AS label_tag 
   FROM LBACSYS.ols$lab l, LBACSYS.sa$pol p
  WHERE p.pol# = l.pol# 
    AND BITAND(l.flags, 1) = 1
    AND (p.pol# in (select pol# from LBACSYS.sa$admin
                    where usr_name = SYS_CONTEXT('USERENV', 'CURRENT_USER'))
         OR
         lbacsys.lbac$sa.enforce_read(p.pol_name, l.ilabel)>0);


-- View Definitions for Label Components
-- The following views are intended for administrators and users

CREATE OR REPLACE VIEW LBACSYS.all_sa_levels AS
   SELECT p.pol_name as policy_name, l.level# AS level_num,
          l.code AS short_name, l.name AS long_name
     FROM LBACSYS.sa$pol p, LBACSYS.ols$levels l
    WHERE p.pol# = l.pol#
      AND p.pol# in (select pol# from LBACSYS.sa$admin
                     where usr_name = SYS_CONTEXT('USERENV', 'CURRENT_USER'))
    UNION
   SELECT p.pol_name as policy_name, l.level# AS level_num,
          l.code AS short_name, l.name AS long_name
     FROM LBACSYS.sa$pol p, LBACSYS.ols$levels l, LBACSYS.ols$user_levels ul
    WHERE p.pol# = l.pol#
      and l.pol# = ul.pol#
      and l.level# <= ul.max_level
      and 
      ul.usr_name = lbacsys.sa_session.sa_user_name(
                    lbacsys.lbac_cache.policy_name(ul.pol#));

CREATE OR REPLACE VIEW LBACSYS.all_sa_compartments AS
   SELECT p.pol_name as policy_name, c.comp# AS comp_num,
          c.code AS short_name, c.name AS long_name
     FROM LBACSYS.sa$pol p, LBACSYS.ols$compartments c
    WHERE p.pol# = c.pol#
      and (p.pol# in (select pol# from LBACSYS.sa$admin
                      where usr_name = SYS_CONTEXT('USERENV', 'CURRENT_USER'))
           OR
          (c.pol#,c.comp#) in (select pol#,comp#
                               from LBACSYS.ols$user_compartments
                            where usr_name = lbacsys.sa_session.sa_user_name(
                                    lbacsys.lbac_cache.policy_name(pol#))));

CREATE OR REPLACE VIEW LBACSYS.all_sa_groups AS
   SELECT p.pol_name as policy_name, g.group# AS group_num,
          g.code AS short_name, g.name AS long_name,
          g.parent# AS parent_num, pg.code AS parent_name
     FROM LBACSYS.sa$pol p, LBACSYS.ols$groups g, LBACSYS.ols$groups pg
    WHERE p.pol# = g.pol#
      AND g.pol# = pg.pol# (+)
      AND g.parent# = pg.group#(+)
      and (p.pol# in (select pol# from LBACSYS.sa$admin
                      where usr_name = SYS_CONTEXT('USERENV', 'CURRENT_USER'))
           OR
          (g.pol#,g.group#) in (select pol#,group#
                                from LBACSYS.ols$user_groups
                             where usr_name = lbacsys.sa_session.sa_user_name(
                                      lbacsys.lbac_cache.policy_name(pol#))));

CREATE OR REPLACE VIEW LBACSYS.all_sa_group_hierarchy AS
   SELECT p.pol_name as policy_name, g.hierarchy_level, g.group_name
     FROM (SELECT LEVEL AS hierarchy_level,
               RPAD(' ',2*LEVEL,' ') || code || ' - ' ||  name AS group_name,
               pol#
             FROM LBACSYS.ols$groups
                  CONNECT BY PRIOR pol#=pol# AND PRIOR group#=parent#
            START WITH ((pol# in (select pol# from LBACSYS.sa$admin
                  where usr_name = SYS_CONTEXT('USERENV', 'CURRENT_USER'))
                         and parent# IS NULL)
                        or
                        (pol#,group#) in
                        (select pol#,group# from LBACSYS.ols$user_groups
                          where usr_name = lbacsys.sa_session.sa_user_name(
                                       lbacsys.lbac_cache.policy_name(pol#))))
          ) g,
          lbacsys.sa$pol p
    WHERE g.pol#=p.pol#;


CREATE OR REPLACE VIEW LBACSYS.all_sa_user_levels AS
   SELECT DISTINCT p.pol_name AS policy_name, 
          ul.usr_name AS user_name,
          lmax.code AS max_level, 
          lmin.code AS min_level, 
          ldef.code AS def_level, 
          lrow.code AS row_level
     FROM LBACSYS.sa$pol p, LBACSYS.ols$user_levels ul, 
          LBACSYS.ols$levels lmax, LBACSYS.ols$levels lmin, 
          LBACSYS.ols$levels ldef, LBACSYS.ols$levels lrow
    WHERE p.pol#=ul.pol# 
      AND ul.pol#=lmax.pol#  
      AND ul.pol#=lmin.pol#  
      AND ul.pol#=ldef.pol#  
      AND ul.pol#=lrow.pol#  
      AND ul.max_level = lmax.level# 
      AND ul.min_level = lmin.level# 
      AND ul.def_level = ldef.level#
      AND ul.row_level = lrow.level# 
      AND (p.pol# in (select pol# from LBACSYS.sa$admin
                      where usr_name = SYS_CONTEXT('USERENV', 'CURRENT_USER'))
           or
           ul.usr_name = lbacsys.sa_session.sa_user_name(
                         lbacsys.lbac_cache.policy_name(p.pol#)));
        
                          
CREATE OR REPLACE VIEW LBACSYS.all_sa_user_compartments AS
   SELECT p.pol_name AS policy_name, uc.usr_name AS user_name,
          c.code AS comp, DECODE(uc.rw_access,'1','WRITE','READ') AS rw_access,
          uc.def_comp, uc.row_comp
     FROM LBACSYS.sa$pol p, LBACSYS.ols$user_compartments uc, 
          LBACSYS.ols$compartments c
    WHERE p.pol#=uc.pol# 
      AND uc.pol#=c.pol# 
      AND uc.comp# = c.comp#
      AND (p.pol# in (select pol# from LBACSYS.sa$admin
                      where usr_name = SYS_CONTEXT('USERENV', 'CURRENT_USER'))
           or
           uc.usr_name = lbacsys.sa_session.sa_user_name(
                         lbacsys.lbac_cache.policy_name(p.pol#)));


CREATE OR REPLACE VIEW LBACSYS.all_sa_user_groups AS
   SELECT p.pol_name AS policy_name, ug.usr_name AS user_name,
          g.code AS grp, DECODE(ug.rw_access,'1','WRITE','READ') AS rw_access,
          ug.def_group, ug.row_group
     FROM LBACSYS.sa$pol p, LBACSYS.ols$user_groups ug, LBACSYS.ols$groups g
    WHERE p.pol#=ug.pol# 
      AND ug.pol#=g.pol# 
      AND ug.group# = g.group#
      AND (p.pol# in (select pol# from LBACSYS.sa$admin
                      where usr_name = SYS_CONTEXT('USERENV', 'CURRENT_USER'))
           or
           ug.usr_name = lbacsys.sa_session.sa_user_name(
                         lbacsys.lbac_cache.policy_name(p.pol#)));

CREATE OR REPLACE VIEW LBACSYS.all_sa_users AS
   SELECT user_name,  u.policy_name, user_privileges,
          NULL AS user_labels,
          LABEL1 AS MAX_READ_LABEL, LABEL2 AS MAX_WRITE_LABEL,
          LABEL3 AS MIN_WRITE_LABEL , LABEL4 AS DEFAULT_READ_LABEL,
          LABEL5 AS DEFAULT_WRITE_LABEL, LABEL6 AS DEFAULT_ROW_LABEL
     FROM LBACSYS.sa$pol p, LBACSYS.dba_ols_users u
    WHERE p.pol_name=u.policy_name
      AND (p.pol# in (select pol# from LBACSYS.sa$admin 
                      where usr_name = SYS_CONTEXT('USERENV', 'CURRENT_USER'))
           or
           u.user_name = lbacsys.sa_session.sa_user_name(
                         lbacsys.lbac_cache.policy_name(p.pol#)));

CREATE OR REPLACE VIEW LBACSYS.all_sa_user_labels AS
   SELECT user_name,
          policy_name,
          user_labels as labels,
          MAX_READ_LABEL,
          MAX_WRITE_LABEL, MIN_WRITE_LABEL ,DEFAULT_READ_LABEL,
          DEFAULT_WRITE_LABEL ,  DEFAULT_ROW_LABEL
     FROM LBACSYS.all_sa_users
    WHERE MAX_READ_LABEL IS NOT NULL;

-- The following are intended for policy administrators only
-- all_sa_programs is a private view in 8.1.7 release
CREATE OR REPLACE VIEW LBACSYS.all_sa_programs AS
   SELECT schema_name, program_name, p.policy_name, program_privileges as 
          prog_privileges, NULL as prog_labels
     FROM LBACSYS.sa$pol, LBACSYS.dba_sa_prog_privs p
    WHERE pol_name=p.policy_name 
      AND pol# in (select pol# from LBACSYS.sa$admin
                   where usr_name = SYS_CONTEXT('USERENV', 'CURRENT_USER'));

CREATE OR REPLACE VIEW LBACSYS.all_sa_user_privs AS
  SELECT user_name,
         policy_name,
         user_privileges
    FROM LBACSYS.all_sa_users 
   WHERE user_privileges IS NOT NULL;

CREATE OR REPLACE VIEW LBACSYS.all_sa_prog_privs AS
  SELECT schema_name, program_name, policy_name, 
         prog_privileges as program_privileges
    FROM LBACSYS.all_sa_programs
   WHERE prog_privileges IS NOT NULL;


CREATE OR REPLACE VIEW LBACSYS.user_sa_session AS
  SELECT p.pol_name AS policy_name,
         lbacsys.sa_session.sa_user_name(p.pol_name)    AS sa_user_name,
         lbacsys.sa_session.privs(p.pol_name)           AS privs,
         lbacsys.sa_session.max_read_label(p.pol_name)  AS max_read_label,
         lbacsys.sa_session.max_write_label(p.pol_name) AS max_write_label,
         lbacsys.sa_session.min_level(p.pol_name)       AS min_level,
         lbacsys.sa_session.label(p.pol_name)           AS label,
         lbacsys.sa_session.comp_write(p.pol_name)      AS comp_write,
         lbacsys.sa_session.group_write(p.pol_name)     AS group_write,
         lbacsys.sa_session.row_label(p.pol_name)       AS row_label
  FROM LBACSYS.ols$pol p
  WHERE p.package='LBAC$SA';

-- create synonyms for dba views
CREATE OR REPLACE PUBLIC SYNONYM dba_sa_policies 
                     FOR LBACSYS.dba_sa_policies;
CREATE OR REPLACE PUBLIC SYNONYM dba_sa_table_policies 
                     FOR LBACSYS.dba_sa_table_policies;
CREATE OR REPLACE PUBLIC SYNONYM dba_sa_schema_policies
                     FOR LBACSYS.dba_sa_schema_policies;
CREATE OR REPLACE PUBLIC SYNONYM dba_sa_labels FOR LBACSYS.dba_sa_labels;
CREATE OR REPLACE PUBLIC SYNONYM dba_sa_data_labels 
                     FOR LBACSYS.dba_sa_data_labels;
CREATE OR REPLACE PUBLIC SYNONYM dba_sa_levels FOR LBACSYS.dba_sa_levels;
CREATE OR REPLACE PUBLIC SYNONYM dba_sa_compartments 
                     FOR LBACSYS.dba_sa_compartments;
CREATE OR REPLACE PUBLIC SYNONYM dba_sa_groups FOR LBACSYS.dba_sa_groups;
CREATE OR REPLACE PUBLIC SYNONYM dba_sa_group_hierarchy
                     FOR LBACSYS.dba_sa_group_hierarchy;
CREATE OR REPLACE PUBLIC SYNONYM dba_sa_users FOR LBACSYS.dba_sa_users;
CREATE OR REPLACE PUBLIC SYNONYM dba_sa_user_levels 
                     FOR LBACSYS.dba_sa_user_levels;
CREATE OR REPLACE PUBLIC SYNONYM dba_sa_user_compartments
                     FOR LBACSYS.dba_sa_user_compartments;
CREATE OR REPLACE PUBLIC SYNONYM dba_sa_user_groups 
                     FOR LBACSYS.dba_sa_user_groups;
CREATE OR REPLACE PUBLIC SYNONYM dba_sa_user_labels 
                     FOR LBACSYS.dba_sa_user_labels;
CREATE OR REPLACE PUBLIC SYNONYM dba_sa_user_privs 
                     FOR LBACSYS.dba_sa_user_privs;
CREATE OR REPLACE PUBLIC SYNONYM dba_sa_programs FOR LBACSYS.dba_sa_programs;
CREATE OR REPLACE PUBLIC SYNONYM dba_sa_prog_privs 
                     FOR LBACSYS.dba_sa_prog_privs;

-- create synonyms for all_ views
CREATE OR REPLACE PUBLIC SYNONYM all_sa_policies FOR LBACSYS.all_sa_policies;
CREATE OR REPLACE PUBLIC SYNONYM all_sa_table_policies
                     FOR LBACSYS.all_sa_table_policies;
CREATE OR REPLACE PUBLIC SYNONYM all_sa_schema_policies
                     FOR LBACSYS.all_sa_schema_policies;
CREATE OR REPLACE PUBLIC SYNONYM all_sa_labels FOR LBACSYS.all_sa_labels;
CREATE OR REPLACE PUBLIC SYNONYM all_sa_data_labels 
                     FOR LBACSYS.all_sa_data_labels;
CREATE OR REPLACE PUBLIC SYNONYM all_sa_levels FOR LBACSYS.all_sa_levels;
CREATE OR REPLACE PUBLIC SYNONYM all_sa_compartments 
                     FOR LBACSYS.all_sa_compartments;
CREATE OR REPLACE PUBLIC SYNONYM all_sa_groups FOR LBACSYS.all_sa_groups;
CREATE OR REPLACE PUBLIC SYNONYM all_sa_group_hierarchy
                     FOR LBACSYS.all_sa_group_hierarchy;
CREATE OR REPLACE PUBLIC SYNONYM all_sa_users 
                     FOR LBACSYS.all_sa_users;
CREATE OR REPLACE PUBLIC SYNONYM all_sa_user_levels 
                     FOR LBACSYS.all_sa_user_levels;
CREATE OR REPLACE PUBLIC SYNONYM all_sa_user_compartments
                     FOR LBACSYS.all_sa_user_compartments;
CREATE OR REPLACE PUBLIC SYNONYM all_sa_user_groups 
                     FOR LBACSYS.all_sa_user_groups;
CREATE OR REPLACE PUBLIC SYNONYM all_sa_user_labels 
                     FOR LBACSYS.all_sa_user_labels;
CREATE OR REPLACE PUBLIC SYNONYM all_sa_user_privs 
                     FOR LBACSYS.all_sa_user_privs;
CREATE OR REPLACE PUBLIC SYNONYM all_sa_prog_privs 
                     FOR LBACSYS.all_sa_prog_privs;
CREATE OR REPLACE PUBLIC SYNONYM user_sa_session FOR LBACSYS.user_sa_session;

-- OLS Auditing Views

-- pre12 OLS Auditing
CREATE OR REPLACE VIEW LBACSYS.dba_ols_audit_options
(POLICY_NAME,
 USER_NAME,
 APY,
 REM,
 SET_,
 PRV)
AS
  SELECT pol_name,
         usr_name,
decode(bitand(success,1), 0, '-', 1, decode(bitand(suc_type,1),0,'S',1,'A'), '-')
 || '/' ||
decode(bitand(failure,1), 0, '-',1,decode(bitand(fail_type,1),0,'S',1,'A'), '-'),
decode(bitand(success,2), 0, '-', 2, decode(bitand(suc_type,2),0,'S',2,'A'), '-')
 || '/' ||
decode(bitand(failure,2), 0, '-',2,decode(bitand(fail_type,2),0,'S',2,'A'), '-'),
decode(bitand(success,4), 0, '-', 4, decode(bitand(suc_type,4),0,'S',4,'A'), '-')
 || '/' ||
decode(bitand(failure,4), 0, '-', 4, decode(bitand(fail_type,4),0,'S',4,'A'), '-'),
decode(option_priv#, 0, '-', decode(success_priv, 0, '-',
                                                decode(suc_priv_type,0,'S','A')))
 || '/' ||
decode(option_priv#, 0, '-', decode(failure_priv, 0, '-',
                                               decode(fail_priv_type,0,'S','A')))
  FROM LBACSYS.ols$pol p, LBACSYS.ols$audit a
  WHERE p.pol# = a.pol#;

execute SYS.CDBView.create_cdbview(false,'LBACSYS','DBA_OLS_AUDIT_OPTIONS','CDB_OLS_AUDIT_OPTIONS');

CREATE OR REPLACE VIEW LBACSYS.dba_sa_audit_options AS
  SELECT a.policy_name, a.user_name, APY, REM, SET_, PRV
  FROM LBACSYS.dba_lbac_policies p, LBACSYS.dba_ols_audit_options a
  WHERE p.policy_name = a.policy_name AND
        p.package = 'LBAC$SA';

execute SYS.CDBView.create_cdbview(false,'LBACSYS','DBA_SA_AUDIT_OPTIONS','CDB_SA_AUDIT_OPTIONS');
create or replace public synonym CDB_sa_audit_options for LBACSYS.CDB_sa_audit_options;
grant select on CDB_sa_audit_options to select_catalog_role;


CREATE OR REPLACE VIEW LBACSYS.all_sa_audit_options AS
  SELECT a.policy_name, a.user_name, APY, REM, SET_, PRV
    FROM LBACSYS.sa$pol p, LBACSYS.dba_ols_audit_options a
   WHERE p.pol_name = a.policy_name
     AND p.pol# in (select pol# from LBACSYS.sa$admin
                    where usr_name = SYS_CONTEXT('USERENV', 'CURRENT_USER'));

-- View showing status indicating if OLS is 
--  1. Configured
--  2. Enabled 
--  3. If OLS-OID
CREATE OR REPLACE VIEW LBACSYS.DBA_OLS_STATUS AS 
  SELECT DECODE(name, 'OLS_STATUS_FLAG', 'OLS_ENABLE_STATUS',
                      'OLS_CONFIGURED_FLAG','OLS_CONFIGURE_STATUS',
                      'OID_STATUS_FLAG','OLS_DIRECTORY_STATUS') AS name,
         DECODE(value$, '0', 'FALSE','TRUE') AS status,
         comment$ AS description
  FROM LBACSYS.ols$props
  WHERE name IN ('OLS_STATUS_FLAG', 'OLS_CONFIGURED_FLAG', 'OID_STATUS_FLAG')
  ORDER BY name;

execute SYS.CDBView.create_cdbview(false,'LBACSYS','DBA_OLS_STATUS','CDB_OLS_STATUS');
create or replace public synonym CDB_OLS_STATUS for LBACSYS.CDB_OLS_STATUS;
grant select on CDB_OLS_STATUS to select_catalog_role;


-- Synonym Definition
CREATE OR REPLACE PUBLIC SYNONYM lbac_audit_actions 
                     FOR LBACSYS.ols$audit_actions;
CREATE OR REPLACE PUBLIC SYNONYM dba_sa_audit_options
                     FOR LBACSYS.dba_sa_audit_options;
CREATE OR REPLACE PUBLIC SYNONYM all_sa_audit_options 
                     FOR LBACSYS.all_sa_audit_options;
CREATE OR REPLACE PUBLIC SYNONYM DBA_OLS_STATUS  FOR LBACSYS.DBA_OLS_STATUS;

@?/rdbms/admin/sqlsessend.sql

