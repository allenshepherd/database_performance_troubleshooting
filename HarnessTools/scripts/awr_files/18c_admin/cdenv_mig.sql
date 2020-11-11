Rem
Rem $Header: rdbms/admin/cdenv_mig.sql /main/13 2017/01/14 06:00:09 skayoor Exp $
Rem
Rem cdenv_mig.sql
Rem
Rem Copyright (c) 2015, 2016, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      cdenv_mig.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      Creates DBA_USERS and USER_USERS views whose definitions are 
Rem      dependent on columns in bootstrap tables.
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/cdenv_mig.sql 
Rem    SQL_SHIPPED_FILE: rdbms/admin/cdenv_mig.sql
Rem    SQL_PHASE: CDENV_MIG
Rem    SQL_STARTUP_MODE: NORMAL 
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: rdbms/admin/cdenv.sql
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    skayoor     09/29/16 - Proj 34974: User with no authentication
Rem    zzeng       06/17/16 - Bug 23186171: add all_shard column to dba_users
Rem    sumkumar    02/10/16 - 22700426: Handle faux MD5 verifiers
Rem    pknaggs     12/23/15 - 22176897: no password_versions for ANONYMOUS
Rem    akruglik    12/17/15 - (21933150) change definition of
Rem                           user/dba_users.common
Rem    akruglik    11/16/15 - (21193922): App Common users/roles/rpofiles will
Rem                           have both COMMON and APP_COMMON bits set
Rem    jerrede     08/28/15 - Remove catctl tags sql fails in database versions
Rem                           lower than 12
Rem    jerrede     08/18/15 - Add Tags to Generate Upgrade Sql
Rem    thbaby      08/04/15 - 21554213: add column IMPLICIT to DBA_USERS
Rem    akruglik    07/17/15 - Get rid of scope column
Rem    drosash     07/17/15 - 21465985: Eliminate duplicated code from view definitions
Rem    drosash     04/08/15 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

-- view "USER_USERS"
declare
  obj_id number;
  column_exists_12_2 number;
  propsrow_exists number;
  new_col_str varchar2(100);
  use_new_cols boolean := FALSE;
  success_with_error exception;
  pragma exception_init(success_with_error, -24344);
begin
  select obj# into obj_id from obj$
   where owner#=0 and name='USER$' and linkname is null;
  select count(*) into column_exists_12_2 from col$
   where obj# = obj_id and name='SPARE9';
  select count(*) into propsrow_exists from props$ where
   name='BOOTSTRAP_UPGRADE_ERROR';

  if (column_exists_12_2 = 1 or propsrow_exists = 1) then
    use_new_cols := TRUE;
  end if;

  execute immediate q'!
    create or replace force view USER_USERS
      (USERNAME, USER_ID, ACCOUNT_STATUS, LOCK_DATE, EXPIRY_DATE,
       DEFAULT_TABLESPACE, TEMPORARY_TABLESPACE, LOCAL_TEMP_TABLESPACE, CREATED,
       INITIAL_RSRC_CONSUMER_GROUP, EXTERNAL_NAME, PROXY_ONLY_CONNECT, COMMON,
       ORACLE_MAINTAINED, INHERITED, DEFAULT_COLLATION, IMPLICIT, ALL_SHARD)
    as 
    select u.name, u.user#,
     m.status,
     decode(mod(u.astatus, 16), 4, u.ltime,
                                5, u.ltime,
                                6, u.ltime,
                                8, u.ltime,
                                9, u.ltime,
                                10, u.ltime, to_date(NULL)),
     decode(mod(u.astatus, 16),
            1, u.exptime,
            2, u.exptime,
            5, u.exptime,
            6, u.exptime,
            9, u.exptime,
            10, u.exptime,
            decode(u.password, 'GLOBAL', to_date(NULL),
                               'EXTERNAL', to_date(NULL),
              decode(u.ptime, '', to_date(NULL),
                decode(p.limit#, 2147483647, to_date(NULL),
                 decode(p.limit#, 0,
                   decode(dp.limit#, 2147483647, to_date(NULL), u.ptime +
                     dp.limit#/86400),
                   u.ptime + p.limit#/86400))))),
     dts.name, tts.name,  !' || 
     case when use_new_cols then 'ltts.name, '
     else '''null'', ' end || q'! 
     u.ctime,
     nvl(cgm.consumer_group, 'DEFAULT_CONSUMER_GROUP'),
     u.ext_username,
     decode(bitand(u.spare1, 10272),
            32, 'Y', 2048, 'Y',  2080, 'Y',
          8192, 'Y', 8224, 'Y', 10240, 'Y',
         10272, 'Y',
                'N'),
     decode(bitand(u.spare1, 128), 0, 'NO', 'YES'),
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
         left outer join sys.resource_group_mapping$ cgm
         on (cgm.attribute = 'ORACLE_USER' and 
              cgm.status = 'ACTIVE' and
              cgm.value = u.name) !' ||
         case when use_new_cols then 'left outer join sys.ts$ ltts
                                      on (u.spare9 = ltts.ts#),'
         else ',' end || q'!
     sys.ts$ dts, sys.ts$ tts, sys.user_astatus_map m,
     profile$ p, profile$ dp
    where u.datats# = dts.ts#
    and u.tempts# = tts.ts#
    and ((u.astatus = m.status#) or
         (u.astatus = (m.status# + 16 - BITAND(m.status#, 16))))
    and u.type# = 1
    and u.user# = userenv('SCHEMAID')
    and u.resource$ = p.profile#
    and dp.profile# = 0
    and dp.type# = 1
    and dp.resource# = 1
    and p.type# = 1
    and p.resource# = 1!';

exception
  when success_with_error then
  if use_new_cols then 
    null;
  else
    raise;
  end if;
end;
/

-- view "DBA_USERS"
Rem
Rem 13502546: Add SHA-512 hash "12C" to the DBA_USERS.PASSWORD_VERSIONS.
Rem Update the view comment to explain that the PASSWORD_VERSIONS column
Rem shows the list of versions of the password hashes (also known as
Rem "verifiers") existing for the user account.
Rem The PASSWORD_VERSIONS column value includes "10G" if an old 
Rem case-insensitive ORCL hash exists, "11G" if a SHA-1 hash exists, 
Rem and "12C" if a new SHA-2 based SHA-512 hash exists.  Note that any
Rem combination of these verifiers could exist for a given account.
Rem
Rem 14490021: Remember that user$.spare4 can also contain the HTTP digest 
Rem verifier (prefixed by "H:"), so checking if spare4 is non-NULL is not a
Rem proper check for the 11G (SHA-1) verifier, we need to check specifically
Rem for the presence of the "S:" prefix which marks 11G verifiers.
Rem
Rem 22176897: Make sure the dummy verifiers for the ANONYMOUS and XS$NULL
Rem users are not reported in the PASSWORD_VERSIONS column.
Rem Add "HTTP" in PASSWORD_VERSIONS for the "H:" HTTP Digest verifier.
Rem
Rem 22700426: In 12.2 release, all DB users will have their HTTP Digest
Rem verifiers disabled by default at the time of creation.
Rem A separate [HTTP] DIGEST [ENABLE|DISABLE] clause has been added to
Rem [CREATE|ALTER] USER DDLs to support generation of these verifiers on a
Rem per-user basis. However, enabling HTTP DIGEST verifiers only populates
Rem a faux MD5 verifier (H:00000000000000000000000000000000) in user$.
Rem For such users, we should not show "HTTP" in PASSWORD_VERSIONS column.
Rem

declare
  obj_id number;
  column_exists_12_2 number;
  propsrow_exists number;
  new_col_str varchar2(100);
  use_new_cols boolean := FALSE;
  success_with_error exception;
  pragma exception_init(success_with_error, -24344);
begin
  select obj# into obj_id from obj$
   where owner#=0 and name='USER$' and linkname is null;
  select count(*) into column_exists_12_2 from col$
   where obj# = obj_id and name='SPARE9';
  select count(*) into propsrow_exists from props$ where
   name='BOOTSTRAP_UPGRADE_ERROR';

  if (column_exists_12_2 = 1 or propsrow_exists = 1) then
    use_new_cols := TRUE;
  end if;

  execute immediate q'!
    create or replace force view DBA_USERS
      (USERNAME, USER_ID, PASSWORD, ACCOUNT_STATUS, LOCK_DATE, EXPIRY_DATE,
        DEFAULT_TABLESPACE, TEMPORARY_TABLESPACE, LOCAL_TEMP_TABLESPACE, CREATED, PROFILE,
        INITIAL_RSRC_CONSUMER_GROUP,EXTERNAL_NAME,PASSWORD_VERSIONS,
        EDITIONS_ENABLED, AUTHENTICATION_TYPE, PROXY_ONLY_CONNECT, 
        COMMON, LAST_LOGIN, ORACLE_MAINTAINED, INHERITED, DEFAULT_COLLATION,
        IMPLICIT, ALL_SHARD)
    as
    select u.name, u.user#,
     decode(u.password, 'GLOBAL', u.password,
                        'EXTERNAL', u.password,
                        NULL), 
     m.status,
     decode(mod(u.astatus, 16), 4, u.ltime,
                                5, u.ltime,
                                6, u.ltime,
                                8, u.ltime,
                                9, u.ltime,
                                10, u.ltime, to_date(NULL)),
     decode(mod(u.astatus, 16),
            1, u.exptime,
            2, u.exptime,
            5, u.exptime,
            6, u.exptime,
            9, u.exptime,
            10, u.exptime,
            decode(u.password, 'GLOBAL', to_date(NULL),
                               'EXTERNAL', to_date(NULL),
              decode(u.ptime, '', to_date(NULL),
                decode(pr.limit#, 2147483647, to_date(NULL),
                 decode(pr.limit#, 0,
                   decode(dp.limit#, 2147483647, to_date(NULL), u.ptime +
                     dp.limit#/86400),
                   u.ptime + pr.limit#/86400))))),
     dts.name, tts.name, !' || 
     case when use_new_cols then 'ltts.name, '
     else '''null'', ' end || q'! 
     u.ctime, p.name,
     nvl(cgm.consumer_group, 'DEFAULT_CONSUMER_GROUP'),
     u.ext_username,
     decode(bitand(u.spare1, 65536), 65536, NULL, decode(
       REGEXP_INSTR(
         NVL2(u.password, u.password, ' '),
         '^                $'
       ),
       0,
       decode(length(u.password), 16, '10G ', NULL),
       ''
     ) ||
     decode(
       REGEXP_INSTR(
         REGEXP_REPLACE(
           NVL2(u.spare4, u.spare4, ' '),
           'S:000000000000000000000000000000000000000000000000000000000000',
           'not_a_verifier'
         ),
         'S:'
       ),
       0, '', '11G '
     ) ||
     decode(
       REGEXP_INSTR(
         NVL2(u.spare4, u.spare4, ' '),
         'T:'
       ),
       0, '', '12C '
     ) ||
     decode(
       REGEXP_INSTR(
         REGEXP_REPLACE(
           NVL2(u.spare4, u.spare4, ' '),
           'H:00000000000000000000000000000000',
           'not_a_verifier'
         ),
         'H:'
       ),
       0, '', 'HTTP '
     )),
     decode(bitand(u.spare1, 16),
            16, 'Y',
                'N'),
     decode(bitand(u.spare1,65536), 65536, 'NONE',
                   decode(u.password, 'GLOBAL',   'GLOBAL',
                                      'EXTERNAL', 'EXTERNAL',
                                      'PASSWORD')),
     decode(bitand(u.spare1, 10272),
            32, 'Y', 2048, 'Y',  2080, 'Y',
          8192, 'Y', 8224, 'Y', 10240, 'Y',
         10272, 'Y',
                'N'),
     decode(bitand(u.spare1, 128), 0, 'NO', 'YES'),
    from_tz(to_timestamp(to_char(u.spare6, 'DD-MON-YYYY HH24:MI:SS'),
                          'DD-MON-YYYY HH24:MI:SS'), '0:00') 
     at time zone sessiontimezone,
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
          left outer join sys.resource_group_mapping$ cgm
          on (cgm.attribute = 'ORACLE_USER' and cgm.status = 'ACTIVE' and
              cgm.value = u.name) !' ||
          case when use_new_cols then 'left outer join sys.ts$ ltts
                                       on (u.spare9 = ltts.ts#),'
          else ',' end || q'!
          sys.ts$ dts, sys.ts$ tts, sys.profname$ p,
          sys.user_astatus_map m, sys.profile$ pr, sys.profile$ dp
    where u.datats# = dts.ts#
     and u.resource$ = p.profile#
     and u.tempts# = tts.ts#
     and ((u.astatus = m.status#) or
          (u.astatus = (m.status# + 16 - BITAND(m.status#, 16))))
     and u.type# = 1
     and u.resource$ = pr.profile#
     and dp.profile# = 0
     and dp.type#=1
     and dp.resource#=1
     and pr.type# = 1
     and pr.resource# = 1!';

exception
  when success_with_error then
  if use_new_cols then 
    null;
  else
    raise;
  end if;
end;
/

@?/rdbms/admin/sqlsessend.sql
