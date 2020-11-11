Rem
Rem $Header: rdbms/admin/dbmsgwmfx.sql /main/7 2017/10/25 18:01:32 raeburns Exp $
Rem
Rem dbmsgwmfx.sql
Rem
Rem Copyright (c) 2011, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbmsgwmfx.sql - DBMS package for GWM fixed operationsRem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/dbmsgwmfx.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/dbmsgwmfx.sql
Rem SQL_PHASE: DBMSGWMFX 
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/dbmsgwm.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    raeburns    10/20/17 - RTI 20225108: correct SQLPHASE
Rem    saratho     04/12/17 - Bug 25816781: cross-validation for replace shard
Rem    dcolello    10/20/16 - bug 23152783: implement set dataguard_property
Rem    dcolello    04/27/16 - bug 22530860: validate character set of shard
Rem    dcolello    03/25/16 - lrg 19364619: fix typo
Rem    dcolello    03/21/16 - add validateShard()
Rem    dcolello    03/08/16 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

--*****************************************************************************
-- Package Declaration
--*****************************************************************************

create or replace package dbms_gsm_fix AS

-- DE-HEAD  <- tell SED where to cut when generating fixed package

  -----------------------------------------------------------------------------
  --
  -- PROCEDURE     validateDatabase
  --
  -- Description:  
  --    Validate database existence and return local DB info
  -- 
  -- Parameters:   
  --   dbpool - dbpool that database existis in
  --   db_unique_name - unique name of database
  --   instances - number of instances database currently has configured
  --   charset - catalog character set for validation
  --   ncharset - catalog national character set for validation
  --
  -- Notes:
  --   Called from GDSCTL during 'add shard'.
  --    
  -----------------------------------------------------------------------------

  PROCEDURE validateDatabase( dbpool         IN  varchar2,
                              db_unique_name OUT varchar2,
                              instances      OUT number,
                              cloud_name     IN varchar2 default NULL);

  PROCEDURE validateDatabase( dbpool              IN  varchar2,
                              db_unique_name      OUT varchar2,
                              instances           OUT number,
                              cloud_name          IN varchar2 default NULL,
                              hostname            OUT varchar2,
                              agent_port          OUT number,
                              db_sid              OUT varchar2,
                              oracle_home         OUT varchar2,
                              html_port           IN  number DEFAULT NULL,
                              registration_pass   IN varchar2 DEFAULT NULL,
                              cat_host            IN varchar2 DEFAULT NULL,
                              dbid                OUT number,
                              conversion_status   OUT varchar2,
                              gg_service          IN varchar2 DEFAULT NULL,
                              charset             IN varchar2 DEFAULT NULL,
                              ncharset            IN varchar2 DEFAULT NULL);

  -----------------------------------------------------------------------------
  -- PROCEDURE      crossValidateDatabase
  --
  -- Description:
  --     Validate that database being replaced is the correct one by comparing
  --     input parametes with parameters on this database.
  --     Parameters minobj_num and maxobj_number should be sufficient to check
  --     to detect accidental wrong input.
  --     DBID of the standby must match the primary in Data Guard replication
  --
  -- Parameters:
  --    minobj_num - old minobj_number for this database  
  --    maxobj_num - old maxobj_number for this database
  --    dbid       - old dbid for this database
  -----------------------------------------------------------------------------
  PROCEDURE crossValidateDatabase( minobj_num     IN number,
                                   maxobj_num     IN number,
                                   dbid           IN number);

  -----------------------------------------------------------------------------
  --
  -- PROCEDURE     validateShard
  --
  -- Description:  
  --    Validate parameters on database to-be-added to configuration by user
  -- 
  -- Parameters:   
  --    reptype - either 'dg' or 'ogg' (case-insensitive)
  --
  --
  -- Notes:
  --   Called by users manually to validate a database prior to being added
  --   via 'add shard'.  Will display output with warnings and errors that
  --   can be corrected by user prior to 'add shard'.
  --    
  -----------------------------------------------------------------------------

  PROCEDURE validateShard(reptype IN varchar2 DEFAULT 'DG');

  -----------------------------------------------------------------------------
  --
  -- PROCEDURE     setDGProperty
  --
  -- Description:  
  --    Set Data Guard property in response to AQ 41 or AQ 42.
  -- 
  -- Parameters:   
  --    params - AQ params as passed from dbms_gsm_pooladmin.setDGProperty
  --    err_num - output error number
  --    err_string - output error text
  --    
  -----------------------------------------------------------------------------

  PROCEDURE setDGProperty(params     IN  varchar2,
		          err_num    OUT number,
		          err_string OUT varchar2);

end;

-- CUT_HERE    <- tell sed where to chop off the rest

/

GRANT EXECUTE ON dbms_gsm_fix TO dba
/

GRANT EXECUTE ON dbms_gsm_fix TO sysdg
/


show errors;


@?/rdbms/admin/sqlsessend.sql
