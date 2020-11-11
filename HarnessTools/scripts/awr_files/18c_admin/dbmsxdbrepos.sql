Rem
Rem $Header: rdbms/admin/dbmsxdbrepos.sql /main/6 2017/06/30 17:23:02 dmelinge Exp $
Rem
Rem dbmsxdbrepos.sql
Rem
Rem Copyright (c) 2008, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbmsxdbrepos.sql - XDB Modular Repository
Rem
Rem    DESCRIPTION
Rem
Rem      This file contains functions for creating new
Rem      repositories. A repository is a self-contained
Rem      unit that manages path based acccess to content.
Rem      Repositories can be customized to support
Rem      ACLs, versioning, event handlers etc.
Rem
Rem    NOTES
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/dbmsxdbrepos.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/dbmsxdbrepos.sql
Rem SQL_PHASE: DBMSXDBREPOS
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catqm_int.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    dmelinge    06/29/17 - Bug 26370272: remove debug_mode
Rem    surman      01/23/14 - 13922626: Update SQL metadata
Rem    qyu         03/18/13 - Common start and end scripts
Rem    yinlu       01/05/12 - disable dbms_xdbrepos package
Rem    badeoti     03/20/09 - clean up 11.2 packages: remove public synonym for
Rem                           dbms_xdbrepos
Rem    sichandr    08/11/08 - Repository level operations
Rem    sichandr    08/11/08 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

CREATE OR REPLACE PACKAGE xdb.dbms_xdbrepos AUTHID CURRENT_USER IS

  ---------------------------------------------
  --  OVERVIEW
  --
  --  This package provides procedures to
  --  (*) create a self-contained repository
  --  (*) delete a previously registered repository
  --  (*) alter a previously created repository
  --
  ---------------------------------------------

------------
-- CONSTANTS
--
------------
ACL_SECURITY        CONSTANT NUMBER := 1;
EVENTS              CONSTANT NUMBER := 2;
VERSIONING          CONSTANT NUMBER := 4;
CONFIG_FILE         CONSTANT NUMBER := 8;
DOCUMENT_LINKS      CONSTANT NUMBER := 16;
NFS_LOCKS           CONSTANT NUMBER := 32;

FULL_FEATURED       CONSTANT NUMBER := 63;

---------------------------------------------
-- FUNCTION - CreateRepository
--     Creates a self-contained repository
-- PARAMETERS -
--  reposOwner
--     Owner of repository (database user)
--  reposName
--     Name of repository (same restrictions as table names)
--  reposOptions
--     Repository configuration options
---------------------------------------------
PROCEDURE CreateRepository(reposOwner IN VARCHAR2,
                  reposName IN VARCHAR2,
                  reposOptions IN PLS_INTEGER);

---------------------------------------------
-- FUNCTION - DropRepository
--     Drops repository and contents
-- PARAMETERS -
--  reposOwner
--     Owner of repository (database user)
--  reposName
--     Name of repository (same restrictions as table names)
---------------------------------------------
PROCEDURE DropRepository(reposOwner IN VARCHAR2,
                  reposName IN VARCHAR2);

---------------------------------------------
-- FUNCTION - SetCurrentRepository
--     Sets current repository for all subsequent resource
--     operations
-- PARAMETERS -
--  reposOwner
--     Owner of repository (database user)
--  reposName
--     Name of repository (same restrictions as table names)
---------------------------------------------
PROCEDURE SetCurrentRepository(reposOwner IN VARCHAR2,
                  reposName IN VARCHAR2);

---------------------------------------------
-- FUNCTION - MountRepository
--     Mounts specified repository at a given path in
--     source repository
-- PARAMETERS -
--  parentReposOwner
--     Owner of destination repository (database user)
--  parentReposName
--     Name of destination repository (same restrictions as table names)
--  parentMntPath
--     Path in the destination repository where mounting should occur
--  mountedReposOwner
--     Owner of source repository (database user)
--  mountedReposName
--     Name of source repository (same restrictions as table names)
--  mountedPath
--     Path in the source repository to mount
---------------------------------------------
PROCEDURE MountRepository(parentReposOwner IN VARCHAR2,
                  parentReposName IN VARCHAR2,
                  parentMntPath IN VARCHAR2,
                  mountedReposOwner IN VARCHAR2,
                  mountedReposName IN VARCHAR2,
                  mountedPath IN VARCHAR2  );

---------------------------------------------
-- FUNCTION - UnMountRepository
--     Unmounts repository from specified path
-- PARAMETERS -
--  parentReposOwner
--     Owner of destination repository (database user)
--  parentReposName
--     Name of destination repository (same restrictions as table names)
--  mountPath
--     Mount path in the destination repository to be removed
---------------------------------------------
PROCEDURE UnMountRepository(parentReposOwner IN VARCHAR2,
                  parentReposName IN VARCHAR2,
                  mountPath IN VARCHAR2  );

PROCEDURE Install_Repos(schema IN VARCHAR2, tables IN
                        XDB$STRING_LIST_T);
PROCEDURE Drop_Repos(schema IN VARCHAR2, tables IN
                     XDB$STRING_LIST_T);
end dbms_xdbrepos;
/

-- GRANT EXECUTE ON xdb.dbms_xdbrepos TO PUBLIC;



@?/rdbms/admin/sqlsessend.sql
