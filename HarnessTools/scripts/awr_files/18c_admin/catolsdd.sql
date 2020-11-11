Rem
Rem $Header: rdbms/src/server/security/ols/admin/olsdd.sql /main/17 2017/03/15 10:34:26 anupkk Exp $
Rem
Rem olsdd.sql
Rem
Rem Copyright (c) 2010, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      olsdd.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/src/server/security/ols/admin/catolsdd.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catolsdd.sql
Rem SQL_PHASE: CATOLSDD
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catols.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    anupkk      03/08/17 - Bug 25387289: Grant read on ols$audit_actions
Rem                           to audit_viewer and audit_admin roles
Rem    risgupta    05/18/15 - Bug 20435157: schema changes to support 
Rem                           long identifiers for policy name
Rem    aketkar     04/28/14 - Bug 18331292: Adding sql metadata seed
Rem    aramappa    08/25/13 - Bug 16593436: Use _BASE_USER instead of user$ for
Rem                           ols$policy_columns
Rem    jkati       05/11/12 - bug#14002092 : grant select, alter on
Rem                           ols$lab_sequence to execute_catalog_role
Rem    risgupta    03/21/12 - Bug 13656227: change level# for OLS% imports
Rem    aramappa    01/23/12 - bug 13493870: schema changes to support long
Rem                           identifiers
Rem    risgupta    11/27/11 - Logon Profile changes: Add ols$profile table,
Rem                           ols$profid_sequence & Update ols$user table
Rem    srtata      11/16/11 - bug 13389617 remove SET ECHO stmts
Rem    srtata      08/26/11 - rename everything to ols$
Rem    gclaborn    07/27/11 - Register LBACSYS types so they will get skipped
Rem    risgupta    06/09/11 - remove old ols audit tables 
Rem    srtata      05/25/11 - old tables for integration
Rem    srtata      05/22/11 - stil reference lbac$pol
Rem    traney      03/30/11 - 35209: long identifiers dictionary upgrade
Rem    risgupta    03/12/11 - Change LBACSYS.OLS_GROUP_PARENT constraint on
Rem                           ols$groups
Rem    srtata      10/18/10 - Oracle Label Security Data Dictionary tables
Rem    srtata      10/18/10 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

CREATE TABLE LBACSYS.ols$pol (
   pol#           NUMBER PRIMARY KEY,
   pol_name       VARCHAR2(128) NOT NULL UNIQUE,
   column_name    VARCHAR2(128) NOT NULL UNIQUE,
   package        VARCHAR2(30) NOT NULL,
   pol_role       VARCHAR2(128) NOT NULL,
   options        NUMBER,
   flags          NUMBER NOT NULL);


CREATE TABLE LBACSYS.ols$pols (
   pol#         NUMBER NOT NULL
                REFERENCES LBACSYS.ols$pol (pol#) ON DELETE CASCADE,
   owner        VARCHAR2(128) NOT NULL,
   options      NUMBER,
   flags        NUMBER,
   PRIMARY KEY (pol#,owner));

CREATE TABLE LBACSYS.ols$polt (
   pol#         NUMBER NOT NULL
                REFERENCES LBACSYS.ols$pol (pol#) ON DELETE CASCADE,
   tbl_name     VARCHAR2(128) NOT NULL,
   owner        VARCHAR2(128) NOT NULL,
   predicate    VARCHAR2(256),
   function     VARCHAR2(1024),
   options      NUMBER,
   flags        NUMBER,
   PRIMARY KEY (pol#,owner,tbl_name));

-- Logon Profile Table
CREATE TABLE LBACSYS.ols$profile (
   profid       NUMBER PRIMARY KEY,
   pol#         NUMBER NOT NULL
                REFERENCES LBACSYS.ols$pol (pol#) ON DELETE CASCADE,
   max_read     VARCHAR2(4000),
   max_write    VARCHAR2(4000),
   min_write    VARCHAR2(4000),
   def_read     VARCHAR2(4000),
   def_write    VARCHAR2(4000),
   def_row      VARCHAR2(4000),
   privs        NUMBER  
);

CREATE TABLE LBACSYS.ols$user (
   pol#         NUMBER         NOT NULL
                REFERENCES LBACSYS.ols$pol (pol#) ON DELETE CASCADE,
   usr_name     VARCHAR2(1024) NOT NULL,
   profid       NUMBER         NOT NULL
                REFERENCES LBACSYS.ols$profile (profid),
   PRIMARY KEY  (pol#,usr_name));

CREATE TABLE LBACSYS.ols$prog (
   pol#         NUMBER NOT NULL
                REFERENCES LBACSYS.ols$pol (pol#) ON DELETE CASCADE,
   pgm_name     VARCHAR2(128) NOT NULL,
   owner        VARCHAR2(128) NOT NULL,
   privs        NUMBER,
   PRIMARY KEY (pol#,pgm_name,owner));

CREATE TABLE LBACSYS.ols$lab (
   tag#         NUMBER(10),
   pol#         NUMBER     NOT NULL,
   nlabel       NUMBER(10) NOT NULL,
   slabel       VARCHAR2(4000) NOT NULL,
   ilabel       VARCHAR2(4000) NOT NULL,
   flags        NUMBER NOT NULL,
   CONSTRAINT   ols_label_pk PRIMARY KEY(nlabel),
   CONSTRAINT   ols_label_policy_fk FOREIGN KEY (pol#)
                REFERENCES LBACSYS.ols$pol ON DELETE CASCADE);

CREATE TABLE LBACSYS.ols$policy_admin(
      admin_dn    VARCHAR2(1024) NOT NULL,
      policy_name VARCHAR2(128)   NOT NULL,
      CONSTRAINT ols_admin_policy_fk FOREIGN KEY (policy_name)
                 REFERENCES LBACSYS.ols$pol(pol_name) ON DELETE CASCADE );

CREATE SEQUENCE LBACSYS.ols$lab_sequence
   INCREMENT BY 1
   MINVALUE 1000000000
   MAXVALUE 4000000000
   CACHE 20
   ORDER;

-- bug#:14002092 : ols$lab_sequence is used during datapump import callouts
-- to update the sequence value after successful import of dynamic labels
-- Since the OLS datapump package is invokers rights, we need to 
-- explicitly grant select and alter on this sequence to EXECUTE_CATALOG_ROLE
-- which inturn is granted to imp_full_database role for the user who is 
-- doing the import
grant select,alter  on lbacsys.ols$lab_sequence to EXECUTE_CATALOG_ROLE;
   

CREATE SEQUENCE LBACSYS.ols$tag_sequence
   INCREMENT BY 1
   MINVALUE 1
   MAXVALUE 4000000000
   CACHE 20
   ORDER;

-- Sequence for Profile IDs
CREATE SEQUENCE LBACSYS.ols$profid_sequence
   INCREMENT BY 1
   MINVALUE 1
   MAXVALUE 4000000000
   CACHE 20
   ORDER;

CREATE TABLE LBACSYS.ols$installations (
   component     VARCHAR(30),
   description   VARCHAR2(500),
   version       VARCHAR2(64),
   banner        VARCHAR2(80),
   installed     DATE);


CREATE TABLE LBACSYS.ols$props (
   name         VARCHAR2(128) CONSTRAINT OLS_PK_LP PRIMARY KEY, 
   value$       VARCHAR2(4000),
   comment$     VARCHAR2(4000));

CREATE TABLE LBACSYS.ols$sessinfo (
   key          VARCHAR2(32) NOT NULL,
   inst_number  NUMBER,
   userid       NUMBER,
   sid          NUMBER,
   serial#      NUMBER,
   startup_time DATE,
   type         INTEGER,
   name         VARCHAR2(1024),
   strvalue1    VARCHAR2(4000),
   strvalue2    VARCHAR2(4000),
   strvalue3    VARCHAR2(4000),
   numvalue1    INTEGER,
   numvalue2    INTEGER);

-- Create tables for levels, compartments, and groups
CREATE TABLE LBACSYS.ols$levels (
      pol#    NUMBER      NOT NULL,       /* associated policy ID */
      level#  NUMBER(4)   NOT NULL,          /* sensitivity level */
      code    VARCHAR(30) NOT NULL,                 /* short name */
      name    VARCHAR(80) NOT NULL,           /* full description */
      CONSTRAINT ols_level_pk     PRIMARY KEY (pol#, level#),
      CONSTRAINT ols_level_pol_fk FOREIGN KEY (pol#)
                              REFERENCES LBACSYS.ols$pol ON DELETE CASCADE,
      CONSTRAINT ols_level_range  CHECK (level# BETWEEN 0 AND 9999),
      CONSTRAINT ols_level_short_unique 
                              UNIQUE (pol#, code),
      CONSTRAINT ols_level_long_unique 
                              UNIQUE (pol#, name));

CREATE TABLE LBACSYS.ols$compartments (
      pol#    NUMBER      NOT NULL,       /* associated policy ID */
      comp#   NUMBER(4)   NOT NULL,         /* compartment number */
      code    VARCHAR(30) NOT NULL,                 /* short name */
      name    VARCHAR(80) NOT NULL,           /* full description */
      CONSTRAINT ols_comp_pk     PRIMARY KEY (pol#, comp#),
      CONSTRAINT ols_comp_pol_fk FOREIGN KEY (pol#)
                             REFERENCES LBACSYS.ols$pol ON DELETE CASCADE,
      CONSTRAINT ols_comp_range  CHECK (comp# BETWEEN 0 AND 9999),
      CONSTRAINT ols_comp_short_unique 
                             UNIQUE (pol#, code),
      CONSTRAINT ols_comp_long_unique 
                             UNIQUE (pol#, name));

CREATE TABLE LBACSYS.ols$groups (
      pol#    NUMBER      NOT NULL,       /* associated policy ID */
      group#  NUMBER(4)   NOT NULL,         /* compartment number */
      code    VARCHAR(30) NOT NULL,                 /* short name */
      name    VARCHAR(80) NOT NULL,           /* full description */
      parent# NUMBER(4),                   /* parent group number */   
      CONSTRAINT ols_group_pk     PRIMARY KEY (pol#, group#),
      CONSTRAINT ols_group_pol_fk FOREIGN KEY (pol#)
                              REFERENCES LBACSYS.ols$pol ON DELETE CASCADE,
      CONSTRAINT ols_group_parent FOREIGN KEY (pol#, parent#)
                              REFERENCES LBACSYS.ols$groups,
      CONSTRAINT ols_group_range  CHECK (group# BETWEEN 0 AND 9999),
      CONSTRAINT ols_group_short_unique 
                              UNIQUE (pol#, code),
      CONSTRAINT ols_group_long_unique 
                              UNIQUE (pol#, name));

-- Create tables for user access authorizations for levels, 
--       compartments, and groups

CREATE TABLE LBACSYS.ols$user_levels (
      pol#      NUMBER       NOT NULL,    /* associated policy ID */
      usr_name  VARCHAR2(1024) NOT NULL,      /* Oracle user name */  
      max_level NUMBER(4),           /* maximum sensitivity level */
      min_level NUMBER(4),           /* minimum sensitivity level */
      def_level NUMBER(4), /* level for default read/write labels */
      row_level NUMBER(4),         /* level for default row label */
      CONSTRAINT ols_user_level_pk PRIMARY KEY (pol#, usr_name),
      CONSTRAINT ols_user_level_pol_fk FOREIGN KEY (pol#)
                             REFERENCES LBACSYS.ols$pol ON DELETE CASCADE,
      CONSTRAINT ols_user_max_fk FOREIGN KEY (pol#, max_level)
                             REFERENCES LBACSYS.ols$levels,
      CONSTRAINT ols_user_min_fk FOREIGN KEY (pol#,min_level)
                             REFERENCES LBACSYS.ols$levels,
      CONSTRAINT ols_user_def_fk FOREIGN KEY (pol#,def_level)
                             REFERENCES LBACSYS.ols$levels,
      CONSTRAINT ols_user_row_fk FOREIGN KEY (pol#,row_level)
                             REFERENCES LBACSYS.ols$levels);

CREATE TABLE LBACSYS.ols$user_compartments (
      pol#      NUMBER       NOT NULL,    /* associated policy ID */
      usr_name  VARCHAR2(1024) NOT NULL,      /* Oracle user name */  
      comp#     NUMBER(4)    NOT NULL,      /* compartment number */
      rw_access NUMBER(2)    NOT NULL,         /* READ-0, WRITE-1 */
      def_comp  VARCHAR(1)   DEFAULT 'Y' NOT NULL,     /* Default */
      row_comp  VARCHAR(1)   DEFAULT 'Y' NOT NULL,   /* Row Label */
      CONSTRAINT ols_user_comp_pk PRIMARY KEY (pol#, usr_name, comp#),
      CONSTRAINT ols_user_comp_fk FOREIGN KEY (pol#, comp#)
                              REFERENCES LBACSYS.ols$compartments,
      CONSTRAINT ols_user_comp_level_fk 
                              FOREIGN KEY (pol#, usr_name)
                              REFERENCES LBACSYS.ols$user_levels
                                ON DELETE CASCADE,
      CONSTRAINT ols_user_comp_access CHECK (rw_access IN (0,1)),
      CONSTRAINT ols_user_comp_def    CHECK (def_comp  IN ('Y','N')),
      CONSTRAINT ols_user_comp_row    CHECK (row_comp  IN ('Y','N')));


CREATE TABLE LBACSYS.ols$user_groups (
      pol#       NUMBER       NOT NULL,    /* associated policy ID */
      usr_name   VARCHAR2(1024) NOT NULL,      /* Oracle user name */  
      group#     NUMBER(4)    NOT NULL,      /* compartment number */
      rw_access  NUMBER(2)    NOT NULL,         /* READ-0, WRITE-1 */
      def_group  VARCHAR(1)   DEFAULT 'Y' NOT NULL,     /* Default */
      row_group  VARCHAR(1)   DEFAULT 'Y' NOT NULL,   /* Row Label */
      CONSTRAINT ols_user_grp_pk PRIMARY KEY (pol#, usr_name, group#),
      CONSTRAINT ols_user_grp_fk FOREIGN KEY (pol#, group#)
                             REFERENCES LBACSYS.ols$groups,
      CONSTRAINT ols_user_grp_level_fk 
                             FOREIGN KEY (pol#, usr_name)
                             REFERENCES LBACSYS.ols$user_levels
                               ON DELETE CASCADE,
      CONSTRAINT ols_user_grp_access CHECK (rw_access IN (0,1,2)),
      CONSTRAINT ols_user_grp_def    CHECK (def_group IN ('Y','N')),
      CONSTRAINT ols_user_grp_row    CHECK (row_group  IN ('Y','N')));

-- The table ols$profiles stores the profiles which are created in the OID
-- It is populated when the events are propagated from OID to DIP and is
-- not directly used by the SA policy package.

CREATE TABLE LBACSYS.ols$profiles (
      policy_name     VARCHAR2(128)   NOT NULL,
      profile_name    VARCHAR2(128)   NOT NULL,
      max_read_label  VARCHAR2(4000),
      max_write_label VARCHAR2(4000),
      min_write_label VARCHAR2(4000),
      def_read_label  VARCHAR2(4000),
      def_row_label   VARCHAR2(4000),
      privs           VARCHAR2(256),
      CONSTRAINT ols_profile_pk        PRIMARY KEY (policy_name,profile_name),
      CONSTRAINT ols_profile_policy_fk FOREIGN KEY (policy_name)
                 REFERENCES LBACSYS.ols$pol(pol_name) ON DELETE CASCADE);

-- The table ols$dip_debug stores information which assists in the 
-- debugging of event propagation from OID through DIP. It is populated 
-- by the DIP calolsk function when executed with a debug level greater
-- than 0.

CREATE TABLE LBACSYS.ols$dip_debug(
      event_id      VARCHAR2(32)  NOT NULL,
      objectdn      VARCHAR2(1024) NOT NULL,
      ols_operation VARCHAR2(50) );

-- The table ols$dip_events is needed to keep track of the DIP events
-- which have already been processed.

CREATE TABLE LBACSYS.ols$dip_events(
      event_id      VARCHAR2(32) NOT NULL,
      purpose       VARCHAR2(40) NOT NULL );

INSERT INTO LBACSYS.ols$dip_events values('0', 'LAST_PROCESSED_EVENT');
INSERT INTO LBACSYS.ols$dip_events values('0', 'BOOTSTRAP_END_EVENT');

CREATE INDEX LBACSYS.OLS$POL_PFCPIDX 
ON LBACSYS.ols$pol(pol#,flags,column_name);

CREATE INDEX LBACSYS.OLS$POLT_OTFPIDX 
ON LBACSYS.ols$polt(owner,tbl_name,flags,pol#,predicate);

CREATE INDEX LBACSYS.OLS$POLS_OWNPOLIDX 
ON LBACSYS.ols$pols(owner,pol#);

CREATE INDEX LBACSYS.i_ols$lab_1
ON LBACSYS.ols$lab(tag#);

CREATE INDEX LBACSYS.i_ols$lab_2
ON LBACSYS.ols$lab(ilabel,pol#);

CREATE INDEX LBACSYS.OLS$SESSINFO_IDX
ON LBACSYS.OLS$SESSINFO(key, userid, name);

CREATE TABLE LBACSYS.ols$audit (
   pol#         NUMBER NOT NULL
                REFERENCES LBACSYS.ols$pol (pol#) ON DELETE CASCADE,
   usr_name     VARCHAR2(128) NOT NULL,
   option#      NUMBER,
   success      NUMBER,
   failure      NUMBER,
   suc_type     NUMBER,
   fail_type    NUMBER,
   option_priv#   NUMBER,
   success_priv   NUMBER,
   failure_priv   NUMBER,
   suc_priv_type  NUMBER,
   fail_priv_type NUMBER,
   PRIMARY KEY (pol#,usr_name));

-- Create ols$audit_actions table
CREATE TABLE LBACSYS.ols$audit_actions(
  action#       NUMBER NOT NULL,
  name          VARCHAR2(40) NOT NULL);

delete from LBACSYS.ols$audit_actions;
insert into LBACSYS.ols$audit_actions values
                (500, 'APPLY TABLE OR SCHEMA POLICY');
insert into LBACSYS.ols$audit_actions values
                (501, 'REMOVE TABLE OR SCHEMA POLICY');
insert into LBACSYS.ols$audit_actions values
                (502, 'SET USER OR PROGRAM UNIT LABEL RANGES');
insert into LBACSYS.ols$audit_actions values
                (503, 'GRANT POLICY SPECIFIC PRIVILEGES');
insert into LBACSYS.ols$audit_actions values
                (504, 'REVOKE POLICY SPECIFIC PRIVILEGES');
insert into LBACSYS.ols$audit_actions values
                (505, 'OBJECT EXISTS ERRORS');
insert into LBACSYS.ols$audit_actions values
                (506, 'PRIVILEGED ACTION');
insert into LBACSYS.ols$audit_actions values
                (507, 'DBA ACTION');

-- Bug 25387289: Grant read on lbacsys.ols$audit_actions
GRANT READ ON lbacsys.ols$audit_actions TO AUDIT_VIEWER, AUDIT_ADMIN;

-- The below views are created here instead of in olsddv.sql 
-- as some packages depend on these
CREATE OR REPLACE VIEW LBACSYS.ols$trusted_progs AS
  SELECT l.pol#, l.owner, l.pgm_name, l.privs,
         po.pol_name, po.package
  FROM LBACSYS.ols$prog l, LBACSYS.ols$pol po
  where l.pol#=po.pol#;

CREATE OR REPLACE VIEW LBACSYS.ols$policy_columns
   (owner, table_name, column_name, column_data_type)
AS
SELECT u.name, o.name,
       c.name,
       decode(c.type#, 2, decode(c.scale, null,
                                 decode(c.precision#, null, 'NUMBER'),
                                 'NUMBER'),
                       58, 'OPAQUE')
FROM sys.col$ c, sys.obj$ o, sys."_BASE_USER" u,
     sys.coltype$ ac, sys.obj$ ot
WHERE o.obj# = c.obj#
  AND o.owner# = u.user#
  AND c.obj# = ac.obj#(+) AND c.intcol# = ac.intcol#(+)
  AND ac.toid = ot.oid$(+)
  AND ot.type#(+) = 13
  AND o.type# =  2;

delete from sys.impcalloutreg$ where tag = 'LABEL_SECURITY'
/

insert into sys.impcalloutreg$ (package, schema, tag, class, level#, flags,
                tgt_schema, tgt_object, tgt_type, cmnt) values
                ('OLS$DATAPUMP', 'LBACSYS', 'LABEL_SECURITY', 3, 1, 1,
                 'LBACSYS', 'LBAC$%', 2,'Oracle Label Security');
  
insert into sys.impcalloutreg$ (package, schema, tag, class, level#, flags,
                tgt_schema, tgt_object, tgt_type, cmnt) values
                ('OLS$DATAPUMP', 'LBACSYS', 'LABEL_SECURITY', 3, 2, 1,
                 'LBACSYS', 'SA$%', 2, 'Oracle Label Security');
-- Bug 13656227: Change level# for OLS$ table imports, so that OLS metadata
-- tables are imported before AUD$. This will help in importing OLS hidden 
-- column values in AUD$ while importing audit records.
insert into sys.impcalloutreg$ (package, schema, tag, class, level#, flags,
                tgt_schema, tgt_object, tgt_type, cmnt) values
                ('OLS$DATAPUMP', 'LBACSYS', 'LABEL_SECURITY', 3, 1, 1,
                 'LBACSYS', 'OLS$%', 2, 'Oracle Label Security');

-- In 11.2.0.3, type definitions upon which registered tables depend are 
-- incorrectly being exported. This causes problems for transportable network
-- imports. So, explicitly register LBACSYS types so that the 
-- instance_callout_imp() in pkg. OLS$DATAPUMP will return SKIP for these.
-- The exclude flag is also specified so they are not exported in 12.1 onwards.

insert into sys.impcalloutreg$ (package, schema, tag, class, level#, flags,
                tgt_schema, tgt_object, tgt_type, cmnt) values
                ('OLS$DATAPUMP', 'LBACSYS', 'LABEL_SECURITY', 3, 3, 1+8,
                 'LBACSYS', '%', 13, 'Oracle Label Security');
insert into sys.impcalloutreg$ (package, schema, tag, class, level#, flags,
                tgt_schema, tgt_object, tgt_type, cmnt) values
                ('OLS$DATAPUMP', 'LBACSYS', 'LABEL_SECURITY', 1, 1, 0,
                 '', '', 0, 'Oracle Label Security');
                
commit;

@?/rdbms/admin/sqlsessend.sql
