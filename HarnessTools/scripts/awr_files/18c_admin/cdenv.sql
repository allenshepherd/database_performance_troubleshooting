Rem
Rem $Header: rdbms/admin/cdenv.sql /main/45 2017/02/16 22:41:34 rthatte Exp $
Rem
Rem cdenv.sql
Rem
Rem Copyright (c) 2006, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      cdenv.sql - Catalog DENV.bsq views
Rem
Rem    DESCRIPTION
Rem      profiles, resources, etc.
Rem
Rem    NOTES
Rem      This script contains catalog views for objects in denv.bsq.   
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/cdenv.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/cdenv.sql
Rem SQL_PHASE: CDENV
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catalog.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    rthatte     01/19/17 - Bug 23753068: Reduce privileges to AUDIT_ADMIN
Rem    zzeng       06/17/16 - Bug 23186171: add column ALL_SHARD to ALL_USERS
Rem    sumkumar    06/12/16 - 23550113: Remove join against ts$ for ALL_USERS
Rem    sumkumar    02/05/16 - 22672305: Do not show roles in DBA_DIGEST_VERIFIER
Rem    akruglik    11/16/15 - (21193922): App Common users/roles/profiles will
Rem                           have both COMMON and APP_COMMON bits set
Rem    juilin      22/07/15 - Bug 21458522 rename syscontext IS_FEDERATION_ROOT
Rem    akruglik    08/21/15 - Bug 21386962: define DBA_PROFILES.IMPLICIT
Rem    thbaby      08/04/15 - 21554213: add column IMPLICIT to ALL_USERS
Rem    akruglik    06/30/15 - Get rid of scope column
Rem    akruglik    02/18/15 - Bug 20235347: change definition of DBA_PROFILES
Rem                           to handle displaying of PASSWORD_VERIFY_FUNCTION
Rem                           of a Federational Profile in a Federation PDB
Rem    drosash     02/12/15 - Proj 47411: Local temporary tablespaces
Rem    sumkumar    01/17/15 - Bug 20374934: show federational level proxy only
Rem                           connect flag in user_users and dba_users
Rem    sumkumar    12/26/14 - Proj 46885: inactive account time
Rem    wesmith     12/04/14 - Project 47511: data-bound collation
Rem    skayoor     11/30/14 - Proj 58196: Change Select priv to Read Priv
Rem    akruglik    11/05/14 - Project 47234: add USER|DBA|ALL_USERS.SCOPE
Rem    pradeshm    04/28/14 - Fix lrg 11793444 : Fix USER_PASSWORD_LIMITS
Rem                           view for common profiles
Rem    sragarwa    04/23/14 - Bug 18345206: USER_USERS will now reflect NULL
Rem                           as expiry date for GLOBAL/EXTERNAL users.
Rem    sragarwa    04/23/14 - LRG 11555727: Correcting expiry date in DBA_USERS
Rem    sragarwa    01/23/14 - Bug 17469815: DBA_USERS will now reflect NULL
Rem                           as expiry date for GLOBAL/EXTERNAL users.
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    thbaby      12/05/13 - 17788962: proxy_only_connect for common user
Rem    pradeshm    08/12/13 - Fix Bug 17196865: fix USER_PASSWORD_LIMITS for
Rem                           RAS user
Rem    talliu      06/28/13 - Add CDB view for DBA view
Rem    pyam        05/17/13 - 16825779: fix DBA_PROFILES
Rem    pyam        04/25/13 - 16709641: common pwd verify fn for DBA_PROFILES
Rem    pyam        02/06/13 - add ORACLE_MAINTAINED column
Rem    akruglik    01/22/13 - XbranchMerge akruglik_common_profiles from
Rem                           st_rdbms_12.1.0.1
Rem    surman      12/10/12 - XbranchMerge surman_bug-12876907 from main
Rem    akruglik    12/03/12 - (15926959): add DBA_PROFILES.COMMON
Rem    ssonawan    11/08/12 - Bug 15841138: fix expiry_date column of DBA_USERS
Rem    jmadduku    09/06/12 - Bug 14575301: Correct lock_date in DBA_USERS
Rem    pknaggs     08/13/12 - Bug #14490021: 11G in DBA_USERS.PASSWORD_VERSIONS
Rem    ssonawan    07/12/12 - bug 13843068: update dba_users and user_users
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    pknaggs     12/14/11 - 13502546: add 12C to DBA_USERS.PASSWORD_VERSIONS
Rem    jmadduku    12/14/10 - Proj 32507: Add LAST_LOGIN Column to DBA_USERS
Rem    amunnoli    02/24/11 - Proj 26873:Grant select on dba_users to 
Rem                           AUDIT_ADMIN role
Rem    spetride    06/09/10 - add DBA_DIGEST_VERIFIERS
Rem    krajaman    12/26/10 - krajaman_consolidated_database_phase6
Rem    akruglik    12/21/10 - DB Consolidation: add COMMON column to \*_USERS
Rem                           and DBA_ROLES
Rem    ssonawan    02/11/08 - bug 6757203: fix DBA_USERS view definition to
Rem                           correctly describe users authentication type 
Rem    srseshad    12/09/07 - Add column proxy_only_connect to dba_users
Rem    vigaur      01/25/07 - Bug 4758283 Changes
Rem    vigaur      12/18/06 - 
Rem    gviswana    08/25/06 - Use DECODE for EDITIONS_ENABLED
Rem    gviswana    07/27/06 - ALTER USER ENABLE EDITIONS 
Rem    rhanckel    05/19/06 - Modifing dba users. 
Rem    cdilling    05/04/06 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql


remark
remark These are table that actually enables the user to see his or her
remark limits
remark

create or replace view DBA_PROFILES
    (PROFILE, RESOURCE_NAME, RESOURCE_TYPE, LIMIT, COMMON, INHERITED, IMPLICIT)
as select
   n.name, m.name,
   decode(u.type#, 0, 'KERNEL', 1, 'PASSWORD', 'INVALID'),
   decode(u.limit#,
          0, 'DEFAULT',
          2147483647, decode(u.resource#,
                             4, decode(u.type#,
                                       1, 'NULL', 'UNLIMITED'),
                             'UNLIMITED'),
          decode(u.resource#,
                 4, decode(u.type#, 1, 
                           decode(nvl(SYS_CONTEXT('USERENV','CON_NAME'),
                                      'CDB$ROOT'), 'CDB$ROOT', o.name,
                                  decode(SYS_CONTEXT('USERENV', 
                                                     'IS_APPLICATION_ROOT'),
                                         'YES', o.name,
                                         decode(bitand(n.flags,3), 0,
                                                o.name, 'FROM ROOT'))),
                           u.limit#),
                 decode(u.type#,
                        0, u.limit#,
                        decode(u.resource#,
                               1, trunc(u.limit#/86400, 4),
                               2, trunc(u.limit#/86400, 4),
                               5, trunc(u.limit#/86400, 4),
                               6, trunc(u.limit#/86400, 4),
                               7, trunc(u.limit#/86400, 4),
                               u.limit#)))),
   decode(bitand(n.flags, 3), 0, 'NO', 'YES'),
   decode(bitand(n.flags, 3), 
          1, decode(SYS_CONTEXT('USERENV', 'CON_ID'), 1, 'NO', 'YES'),
          3, decode(SYS_CONTEXT('USERENV', 'IS_APPLICATION_PDB'), 
                    'YES', 'YES', 'NO'),
          'NO'),
  decode(bitand(n.flags, 4), 4, 'YES', 'NO')
  from sys.profile$ u, sys.profname$ n, sys.resource_map m, sys.obj$ o,
       sys.dual d
  where u.resource# = m.resource#
  and u.type#=m.type#
  and o.obj# (+) = u.limit#
  and n.profile# = u.profile#
/
create or replace public synonym DBA_PROFILES for DBA_PROFILES
/
grant select on DBA_PROFILES to select_catalog_role
/
comment on table DBA_PROFILES is
'Display all profiles and their limits'
/
comment on column DBA_PROFILES.PROFILE is
'Profile name'
/
comment on column DBA_PROFILES.RESOURCE_NAME is
'Resource name'
/
comment on column DBA_PROFILES.LIMIT is
'Limit placed on this resource for this profile'
/
comment on column DBA_PROFILES.COMMON is
'Is this a common profile?'
/

comment on column DBA_PROFILES.INHERITED is
'Was profile definition inherited from another container'
/

comment on column DBA_PROFILES.IMPLICIT is
'Was this profile created by an implicit application'
/

execute CDBView.create_cdbview(false,'SYS','DBA_PROFILES','CDB_PROFILES');
grant select on SYS.CDB_PROFILES to select_catalog_role
/
create or replace public synonym CDB_PROFILES for SYS.CDB_PROFILES
/

REM
REM  This view enables the user to see his own profile limits
REM
create or replace view USER_RESOURCE_LIMITS
    (RESOURCE_NAME, LIMIT)
as select m.name,
          decode (u.limit#, 2147483647, 'UNLIMITED',
                           0, decode (p.limit#, 2147483647, 'UNLIMITED',
                                               p.limit#),
                           u.limit#)
  from sys.profile$ u, sys.profile$ p,
       sys.resource_map m, user$ s
  where u.resource# = m.resource#
  and p.profile# = 0
  and p.resource# = u.resource#
  and u.type# = p.type#
  and p.type# = 0
  and m.type# = 0
  and s.resource$ = u.profile#
  and s.user# = userenv('SCHEMAID')
/
comment on table USER_RESOURCE_LIMITS is
'Display resource limit of the user'
/
comment on column USER_RESOURCE_LIMITS.RESOURCE_NAME is
'Resource name'
/
comment on column USER_RESOURCE_LIMITS.LIMIT is
'Limit placed on this resource'
/
create or replace public synonym USER_RESOURCE_LIMITS for USER_RESOURCE_LIMITS
/
grant read on USER_RESOURCE_LIMITS to PUBLIC with grant option
/

-- Fix Bug 17196865: USER_PASSWORD_LIMITS should be used only for DB user
-- we have different view USER_XS_PASSWORD_LIMITS for RAS user.
create or replace view USER_PASSWORD_LIMITS
    (RESOURCE_NAME, LIMIT)
as select
  m.name,
  decode(u.limit#,
         2147483647, decode(u.resource#, 4, 'NULL', 'UNLIMITED'),
         -1, 0,
         0, decode(p.limit#,
                   2147483647, decode(p.resource#, 4, 'NULL', 'UNLIMITED'),
                   -1, 0,
                   decode(p.resource#,
                          4, po.name,
                          1, trunc(p.limit#/86400, 4),
                          2, trunc(p.limit#/86400, 4),
                          5, trunc(p.limit#/86400, 4),
                          6, trunc(p.limit#/86400, 4),
                          7, trunc(p.limit#/86400, 4), p.limit#)),
         decode(u.resource#,
                4, decode(nvl(SYS_CONTEXT('USERENV','CON_NAME'),
                                'CDB$ROOT'), 'CDB$ROOT', uo.name,
                              decode(bitand(n.flags,1), 1,
                                 'FROM ROOT', uo.name)),
                1, trunc(u.limit#/86400, 4),
                2, trunc(u.limit#/86400, 4),
                5, trunc(u.limit#/86400, 4),
                6, trunc(u.limit#/86400, 4),
                7, trunc(u.limit#/86400, 4),
                u.limit#))
  from sys.profile$ u, sys.profile$ p, sys.obj$ uo, sys.obj$ po,
       sys.resource_map m, sys.user$ s, sys.profname$ n
  where u.resource# = m.resource#
  and p.profile# = 0
  and p.resource# = u.resource#
  and u.type# = p.type#
  and p.type# = 1
  and m.type# = 1
  and uo.obj#(+) = u.limit#
  and po.obj#(+) = p.limit#
  and s.resource$ = u.profile#
  and u.profile# = n.profile#
  and s.user# = userenv('SCHEMAID')
  and s.name <> 'XS$NULL';
/
comment on table USER_PASSWORD_LIMITS is
'Display password limits of the user'
/
comment on column USER_PASSWORD_LIMITS.RESOURCE_NAME is
'Resource name'
/
comment on column USER_PASSWORD_LIMITS.LIMIT is
'Limit placed on this resource'
/
create or replace public synonym USER_PASSWORD_LIMITS for USER_PASSWORD_LIMITS
/
grant read on USER_PASSWORD_LIMITS to PUBLIC with grant option
/

REM
REM  This view shows the resource cost of the system
REM
create or replace view RESOURCE_COST
    (RESOURCE_NAME, UNIT_COST)
as select m.name,c.cost
  from sys.resource_cost$ c, sys.resource_map m where
  c.resource# = m.resource#
  and m.type# = 0
  and c.resource# in (2, 4, 7, 8)
/
comment on table RESOURCE_COST is
'Cost for each resource'
/
comment on column RESOURCE_COST.RESOURCE_NAME is
'Name of resource'
/
comment on column RESOURCE_COST.UNIT_COST is
'Cost for resource'
/
create or replace public synonym RESOURCE_COST for RESOURCE_COST
/
grant read on RESOURCE_COST to PUBLIC
/

remark
remark  FAMILY "USERS"
remark  Users enrolled in the database.
remark

remark Define views that depend on new bootstrap table columns
remark USER_USERS and DBA_USERS
@@cdenv_mig.sql

Rem Comments for USER_USERS view

comment on table USER_USERS is
'Information about the current user'
/
comment on column USER_USERS.USERNAME is
'Name of the user'
/
comment on column USER_USERS.USER_ID is
'ID number of the user'
/
comment on column USER_USERS.DEFAULT_TABLESPACE is
'Default tablespace for data'
/
comment on column USER_USERS.TEMPORARY_TABLESPACE is
'Default tablespace for temporary tables'
/
comment on column USER_USERS.CREATED is
'User creation date'
/
comment on column USER_USERS.INITIAL_RSRC_CONSUMER_GROUP is
'User''s initial consumer group'
/
comment on column USER_USERS.EXTERNAL_NAME is
'User external name'
/
comment on column USER_USERS.PROXY_ONLY_CONNECT is
'Whether this user can connect only through a proxy'
/
comment on column USER_USERS.COMMON is
'Indicates whether this user is Common'
/
comment on column USER_USERS.ORACLE_MAINTAINED is
'Denotes whether the user was created, and is maintained, by Oracle-supplied scripts. A user for which this has the value Y must not be changed in any way except by running an Oracle-supplied script.'
/
comment on column USER_USERS.INHERITED is
'Was user definition inherited from another container'
/
comment on column USER_USERS.DEFAULT_COLLATION is
'User default collation'
/
comment on column USER_USERS.IMPLICIT is
'Is this user a common user created by an implicit application'
/
comment on column USER_USERS.ALL_SHARD is
'Is this user an all-shard user'
/

create or replace public synonym USER_USERS for USER_USERS
/
grant read on USER_USERS to PUBLIC with grant option
/

Rem Comments for DBA_USERS view

create or replace public synonym DBA_USERS for DBA_USERS
/
grant select on DBA_USERS to select_catalog_role
/
grant read on DBA_USERS to AUDIT_ADMIN
/
comment on table DBA_USERS is
'Information about all users of the database'
/
comment on column DBA_USERS.USERNAME is
'Name of the user'
/
comment on column DBA_USERS.USER_ID is
'ID number of the user'
/
comment on column DBA_USERS.PASSWORD is
'Deprecated from 11.2 -- use AUTHENTICATION_TYPE instead'
/
comment on column DBA_USERS.DEFAULT_TABLESPACE is
'Default tablespace for data'
/
comment on column DBA_USERS.TEMPORARY_TABLESPACE is
'Default tablespace for temporary tables'
/
Rem comment on column DBA_USERS.LOCAL_TEMP_TABLESPACE is
Rem 'Default local temporary tablespace for the user'
Rem /
comment on column DBA_USERS.CREATED is
'User creation date'
/
comment on column DBA_USERS.PROFILE is
'User resource profile name'
/
comment on column DBA_USERS.INITIAL_RSRC_CONSUMER_GROUP is
'User''s initial consumer group'
/
comment on column DBA_USERS.EXTERNAL_NAME is
'User external name'
/
comment on column DBA_USERS.PASSWORD_VERSIONS is
'List of versions of password hashes (e.g. 11G for SHA-1, 12C for SHA-512)'
/
comment on column DBA_USERS.EDITIONS_ENABLED is
'Whether editions are enabled for this user'
/
comment on column DBA_USERS.AUTHENTICATION_TYPE is
'Authentication mechanism for the user'
/
comment on column DBA_USERS.PROXY_ONLY_CONNECT is
'Whether this user can connect only through a proxy'
/
comment on column DBA_USERS.COMMON is
'Indicates whether this user is Common'
/
comment on column DBA_USERS.ORACLE_MAINTAINED is
'Denotes whether the user was created, and is maintained, by Oracle-supplied scripts. A user for which this has the value Y must not be changed in any way except by running an Oracle-supplied script.'
/
comment on column DBA_USERS.INHERITED is
'Was user definition inherited from another container'
/
comment on column DBA_USERS.DEFAULT_COLLATION is
'User default collation'
/
comment on column DBA_USERS.IMPLICIT is
'Is this user a common user created by an implicit application'
/
comment on column DBA_USERS.ALL_SHARD is
'Is this user an all-shard user'
/


execute CDBView.create_cdbview(false,'SYS','DBA_USERS','CDB_USERS');
grant select on SYS.CDB_USERS to select_catalog_role
/
create or replace public synonym CDB_USERS for SYS.CDB_USERS
/

create or replace view ALL_USERS
    (USERNAME, USER_ID, CREATED, COMMON, ORACLE_MAINTAINED, INHERITED, 
     DEFAULT_COLLATION, IMPLICIT, ALL_SHARD)
as
select u.name, u.user#, u.ctime,
       decode(bitand(u.spare1, 4224), 0, 'NO', 'YES'),
       decode(bitand(u.spare1, 256), 256, 'Y', 'N'),
       decode(bitand(u.spare1, 4224), 
              128, decode(SYS_CONTEXT('USERENV', 'CON_ID'), 1, 'NO', 'YES'),
              4224, decode(SYS_CONTEXT('USERENV', 'IS_APPLICATION_PDB'), 
                           'YES', 'YES', 'NO'),
              'NO'),
       nls_collation_name(nvl(u.spare3, 16382)),
       -- IMPLICIT
       decode(bitand(u.spare1, 32768), 32768, 'YES', 'NO'),
       -- ALL_SHARD
       decode(bitand(u.spare1, 16384), 16384, 'YES', 'NO')
from sys.user$ u
where u.type# = 1
/
comment on table ALL_USERS is
'Information about all users of the database'
/
comment on column ALL_USERS.USERNAME is
'Name of the user'
/
comment on column ALL_USERS.USER_ID is
'ID number of the user'
/
comment on column ALL_USERS.CREATED is
'User creation date'
/
comment on column ALL_USERS.COMMON is
'Indicates whether this user is Common'
/
comment on column ALL_USERS.ORACLE_MAINTAINED is
'Denotes whether the user was created, and is maintained, by Oracle-supplied scripts. A user for which this has the value Y must not be changed in any way except by running an Oracle-supplied script.'
/
comment on column ALL_USERS.INHERITED is
'Was user definition inherited from another container'
/
comment on column ALL_USERS.DEFAULT_COLLATION is
'User default collation'
/
comment on column ALL_USERS.IMPLICIT is
'Is this user a common user created by an implicit application'
/
comment on column ALL_USERS.ALL_SHARD is
'Is this user an all-shard user'
/
create or replace public synonym ALL_USERS for ALL_USERS
/
grant read on ALL_USERS to PUBLIC with grant option
/

REM
REM Bug 22672305: Since HTTP digest verifiers are not supported for roles,
REM exclude them from DBA_DIGEST_VERIFIERS. Also handle faux HTTT verifier
REM which gets populated in user$ when "HTTP DIGEST ENABLE" is executed
REM against a user account.
REM
create or replace view DBA_DIGEST_VERIFIERS
  (USERNAME, HAS_DIGEST_VERIFIERS, DIGEST_TYPE) as
select name,
     decode(
       REGEXP_INSTR(
         REGEXP_REPLACE(
           NVL2(u.spare4, u.spare4, ' '),
           'H:00000000000000000000000000000000',
           'not_a_verifier'
         ),
         'H:'
       ),
       0, 'NO', 'YES'
     ),
     decode(
       REGEXP_INSTR(
         REGEXP_REPLACE(
           NVL2(u.spare4, u.spare4, ' '),
           'H:00000000000000000000000000000000',
           'not_a_verifier'
         ),
         'H:'
       ),
       0, NULL, 'MD5'
     )
from user$ u
where type# = 1
/

create or replace public synonym DBA_DIGEST_VERIFIERS for DBA_DIGEST_VERIFIERS
/
grant select on DBA_DIGEST_VERIFIERS to select_catalog_role
/

comment on table DBA_DIGEST_VERIFIERS is 
'Information about which users have Digest verifiers and the verifier types'
/

comment on column DBA_DIGEST_VERIFIERS.USERNAME is
'Name of the user'
/

comment on column DBA_DIGEST_VERIFIERS.HAS_DIGEST_VERIFIERS is
'YES if Digest verifier exist, NO otherwise'
/

comment on column DBA_DIGEST_VERIFIERS.DIGEST_TYPE is
'The type of the Digest verifier'
/

execute CDBView.create_cdbview(false,'SYS','DBA_DIGEST_VERIFIERS','CDB_DIGEST_VERIFIERS');
grant select on SYS.CDB_DIGEST_VERIFIERS to select_catalog_role
/
create or replace public synonym CDB_DIGEST_VERIFIERS for SYS.CDB_DIGEST_VERIFIERS
/


@?/rdbms/admin/sqlsessend.sql
