Rem
Rem $Header: rdbms/admin/catggshard.sql /main/10 2017/10/25 18:01:33 raeburns Exp $
Rem
Rem catggshard.sql
Rem
Rem Copyright (c) 2015, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catggshard.sql - GG SHARDing
Rem
Rem    DESCRIPTION
Rem      GGSYS schema
Rem
Rem    NOTES
Rem      .
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/catggshard.sql 
Rem    SQL_SHIPPED_FILE: rdbms/admin/catggshard.sql 
Rem    SQL_PHASE: CATGGSHARD
Rem    SQL_STARTUP_MODE: NORMAL 
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE:  rdbms/admin/catpend.sql
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    raeburns    10/20/17 - RTI 20225108: Fix SQL_METADATA
Rem    sdball      03/09/16 - ddl_requests is now in sys schema
Rem    ralekra     02/15/16 - Bug 22346603 remove dbms_system privilege
Rem    ralekra     12/18/15 - grant network privileges to ggsys
Rem    ralekra     12/10/15 - Bug 22297600 revoke inherit privileges from public
Rem    vidgovin    12/07/15 - Bug 22204627
Rem    ralekra     11/23/15 - revisit ggsys grants and privileges 
Rem    dcolello    11/02/15 - schema name changes for production
Rem    jorgrive    03/19/15 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

-------------------------------------------------------------------------------
-- create GGSYS user
-------------------------------------------------------------------------------
CREATE USER ggsys IDENTIFIED BY ggsys 
account lock password expire
DEFAULT TABLESPACE sysaux;

-------------------------------------------------------------------------------
-- grants required: roles and system privileges
-------------------------------------------------------------------------------
GRANT connect, resource     TO ggsys;
ALTER USER ggsys QUOTA unlimited ON sysaux;
GRANT unlimited tablespace  TO ggsys;

GRANT create database link  TO ggsys;
GRANT select ANY dictionary TO ggsys;  
GRANT select ANY table      TO ggsys; 
GRANT create ANY table      TO ggsys; 
GRANT alter  ANY table      TO ggsys; 
GRANT alter  ANY index      TO ggsys; 

-------------------------------------------------------------------------------
-- grants required: SYS object privileges
-------------------------------------------------------------------------------
GRANT execute ON sys.dbms_lock           TO ggsys;
GRANT execute ON sys.dbms_sys_error      TO ggsys;
GRANT execute ON sys.dbms_logrep_util    TO ggsys;
GRANT execute ON sys.dbms_goldengate_adm TO ggsys;
GRANT execute ON sys.dbms_gsm_fixed      TO ggsys;
GRANT execute ON sys.dbms_network_acl_admin TO ggsys;

GRANT select, references, insert, update, delete ON sys.ddl_requests     TO ggsys;
GRANT select, references, insert, update, delete ON sys.ddl_requests_pwd TO ggsys;

-------------------------------------------------------------------------------
-- grants required: GSMADMIN_INTERNAL object privileges
-------------------------------------------------------------------------------
GRANT select ON gsmadmin_internal.gsm                         TO ggsys;
GRANT select ON gsmadmin_internal.cloud                       TO ggsys;
GRANT select ON gsmadmin_internal.database_pool_admin         TO ggsys;
GRANT select ON gsmadmin_internal.files                       TO ggsys;
GRANT select ON gsmadmin_internal.vncr                        TO ggsys;
GRANT select ON gsmadmin_internal.broker_configs              TO ggsys;
GRANT select ON gsmadmin_internal.credential                  TO ggsys;
GRANT select ON gsmadmin_internal.service                     TO ggsys;
GRANT select ON gsmadmin_internal.service_preferred_available TO ggsys;
GRANT select ON gsmadmin_internal.shardkey_columns            TO ggsys;
GRANT select ON gsmadmin_internal.partition_set               TO ggsys;
GRANT select ON gsmadmin_internal.tablespace_set              TO ggsys;
GRANT select ON gsmadmin_internal.shard_ts                    TO ggsys;
GRANT select ON gsmadmin_internal.global_table                TO ggsys;
GRANT select ON gsmadmin_internal.table_family                TO ggsys;
GRANT select ON gsmadmin_internal.ts_set_table                TO ggsys;
GRANT select ON gsmadmin_internal.ddlid$                      TO ggsys;
GRANT select ON gsmadmin_internal.verify_history              TO ggsys;

GRANT select ON gsmadmin_internal.cat_sequence                TO ggsys;
GRANT select ON gsmadmin_internal.gsm_sequence                TO ggsys;
GRANT select ON gsmadmin_internal.region_sequence             TO ggsys;
GRANT select ON gsmadmin_internal.shardgroup_sequence         TO ggsys;
GRANT select ON gsmadmin_internal.shardspace_sequence         TO ggsys;
GRANT select ON gsmadmin_internal.cs_chunk_id                 TO ggsys;
GRANT select ON gsmadmin_internal.int_dbnum_sequence          TO ggsys;
GRANT select ON gsmadmin_internal.sid_sequence                TO ggsys;
GRANT select ON gsmadmin_internal.files_sequence              TO ggsys;
GRANT select ON gsmadmin_internal.family_sequence             TO ggsys;
GRANT select ON gsmadmin_internal.credential_sequence         TO ggsys;
GRANT select ON gsmadmin_internal.verify_run_number           TO ggsys;

GRANT select, references, insert, update, delete ON gsmadmin_internal.region           TO ggsys;
GRANT select, references, insert, update, delete ON gsmadmin_internal.database_pool    TO ggsys;
GRANT select, references, insert, update, delete ON gsmadmin_internal.database         TO ggsys;
GRANT select, references, insert, update, delete ON gsmadmin_internal.shard_group      TO ggsys;
GRANT select, references, insert, update, delete ON gsmadmin_internal.shard_space      TO ggsys;
GRANT select, references, insert, update, delete ON gsmadmin_internal.chunks           TO ggsys;
GRANT select, references, insert, update, delete ON gsmadmin_internal.chunk_loc        TO ggsys;
GRANT select, references, insert, update, delete ON gsmadmin_internal.gsm_requests     TO ggsys;
GRANT select, references, insert, update, delete ON gsmadmin_internal.catalog_requests TO ggsys;

GRANT execute ON gsmadmin_internal.name_list          TO ggsys;
GRANT execute ON gsmadmin_internal.number_list        TO ggsys;
GRANT execute ON gsmadmin_internal.gsm_change_message TO ggsys;

GRANT execute ON gsmadmin_internal.dbms_gsm_common    TO ggsys;
GRANT execute ON gsmadmin_internal.dbms_gsm_utility   TO ggsys;
GRANT execute ON gsmadmin_internal.dbms_gsm_dbadmin   TO ggsys;
GRANT execute ON gsmadmin_internal.dbms_gsm_pooladmin TO ggsys;

-------------------------------------------------------------------------------
-- grants required: network privileges
-------------------------------------------------------------------------------
BEGIN
    DBMS_NETWORK_ACL_ADMIN.append_host_ace(
        host => '*',
        ace  =>  xs$ace_type(privilege_list => xs$name_list('resolve'),
                             principal_name => 'ggsys',
                             principal_type => xs_acl.ptype_db)); 
END;
/
show errors

-------------------------------------------------------------------------------
-- revoke inherit privileges from public
-------------------------------------------------------------------------------
DECLARE                                                                       
    already_revoked EXCEPTION;
    PRAGMA exception_init (already_revoked,-01927);
BEGIN 
    execute immediate 'REVOKE inherit privileges ON USER ggsys FROM public'; 
EXCEPTION
    WHEN already_revoked THEN
        NULL;                                                                          
END;
/                                                                                  
show errors
                                                                                  
-------------------------------------------------------------------------------
-- create role ggsys_role
-------------------------------------------------------------------------------
CREATE ROLE ggsys_role;


@?/rdbms/admin/sqlsessend.sql

