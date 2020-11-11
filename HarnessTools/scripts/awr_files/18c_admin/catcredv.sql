Rem
Rem $Header: rdbms/admin/catcredv.sql /main/7 2017/06/26 16:01:18 pjulsaks Exp $
Rem
Rem catcredv.sql
Rem
Rem Copyright (c) 2011, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catcredv.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catcredv.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catcredv.sql
Rem SQL_PHASE: CATCREDV
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catpdeps.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    pjulsaks    06/26/17 - Bug 25688154: Uppercase create_cdbview's input
Rem    sankejai    03/13/17 - Bug 25715301: fix privilege id in ALL_CREDENTIALS
Rem    skayoor     11/30/14 - Proj 58196: Change Select priv to Read Priv
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    talliu      06/28/13 - Add CDB view for DBA view
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    paestrad    05/17/11 - View definitions for DBMS_CREDENTIAL
Rem    paestrad    05/17/11 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

CREATE OR REPLACE VIEW dba_credentials
  (OWNER, CREDENTIAL_NAME, USERNAME, WINDOWS_DOMAIN, COMMENTS, ENABLED) AS
  SELECT u.name, o.name, c.username, c.domain, c.comments,
  DECODE(bitand(c.flags, 4), 0, 'FALSE', 4, 'TRUE')
  FROM obj$ o, user$ u, sys.scheduler$_credential c
  WHERE c.obj# = o.obj# AND u.user# = o.owner#
/
COMMENT ON TABLE dba_credentials IS
'All credentials in the database'
/
COMMENT ON COLUMN dba_credentials.credential_name IS
'Name of the credential'
/
COMMENT ON COLUMN dba_credentials.owner IS
'Owner of the credential'
/
COMMENT ON COLUMN dba_credentials.username IS
'User to run as'
/
COMMENT ON COLUMN dba_credentials.windows_domain IS
'Windows domain to use when logging in'
/
COMMENT ON COLUMN dba_credentials.comments IS
'Comments on the credential'
/
COMMENT ON COLUMN dba_credentials.enabled IS
'Is this credential enabled'
/
CREATE OR REPLACE PUBLIC SYNONYM dba_credentials
  FOR sys.dba_credentials
/
GRANT SELECT ON dba_credentials TO select_catalog_role
/


execute CDBView.create_cdbview(false,'SYS','DBA_CREDENTIALS','CDB_CREDENTIALS');
grant select on SYS.CDB_credentials to select_catalog_role
/
create or replace public synonym CDB_credentials for SYS.CDB_credentials
/

CREATE OR REPLACE VIEW user_credentials
  (CREDENTIAL_NAME, USERNAME, WINDOWS_DOMAIN,
   COMMENTS, ENABLED) AS
  SELECT o.name, c.username,
  c.domain, c.comments,
  DECODE(bitand(c.flags, 4), 0, 'FALSE', 4, 'TRUE')
  FROM obj$ o, sys.scheduler$_credential c
  WHERE o.owner# = USERENV('SCHEMAID') AND c.obj# = o.obj#
/
COMMENT ON TABLE user_credentials IS
'Credentials owned by the current user'
/
COMMENT ON COLUMN user_credentials.credential_name IS
'Name of the credential'
/
COMMENT ON COLUMN user_credentials.username IS
'User to run as'
/
COMMENT ON COLUMN user_credentials.windows_domain IS
'Windows domain to use when logging in'
/
COMMENT ON COLUMN user_credentials.comments IS
'Comments on the credential'
/
COMMENT ON COLUMN user_credentials.enabled IS
'Is this credential enabled'
/
CREATE OR REPLACE PUBLIC SYNONYM user_credentials
  FOR sys.user_credentials
/
GRANT READ ON user_credentials TO public WITH GRANT OPTION
/

CREATE OR REPLACE VIEW all_credentials
  (OWNER, CREDENTIAL_NAME, USERNAME, WINDOWS_DOMAIN,
   COMMENTS, ENABLED) AS
  SELECT u.name, o.name, c.username,
  c.domain, c.comments,
  DECODE(bitand(c.flags,4), 0, 'FALSE', 4, 'TRUE')
  FROM obj$ o, user$ u, sys.scheduler$_credential c
  WHERE c.obj# = o.obj# AND u.user# = o.owner# AND
    (o.owner# = userenv('SCHEMAID')
       or o.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               )
            )
       or /* user has system privileges */
         (exists (select null from v$enabledprivs
                 where priv_number in (-388 /* CREATE ANY CREDENTIAL*/)
                 )
          and o.owner#!=0)
      )
/
COMMENT ON TABLE all_credentials IS
'All credentials visible to the user'
/
COMMENT ON COLUMN all_credentials.credential_name IS
'Name of the credential'
/
COMMENT ON COLUMN all_credentials.owner IS
'Owner of the credential'
/
COMMENT ON COLUMN all_credentials.username IS
'User to run as'
/
COMMENT ON COLUMN all_credentials.windows_domain IS
'Windows domain to use when logging in'
/
COMMENT ON COLUMN all_credentials.comments IS
'Comments on the credential'
/
COMMENT ON COLUMN all_credentials.enabled IS
'Is this credential enabled'
/
CREATE OR REPLACE PUBLIC SYNONYM all_credentials
  FOR sys.all_credentials
/
GRANT READ ON all_credentials TO public WITH GRANT OPTION
/

@?/rdbms/admin/sqlsessend.sql
