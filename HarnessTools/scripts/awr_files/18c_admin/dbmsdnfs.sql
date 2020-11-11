Rem
Rem $Header: rdbms/admin/dbmsdnfs.sql /main/6 2017/10/26 23:18:47 rankalik Exp $
Rem
Rem dbmsdnfs.sql
Rem
Rem Copyright (c) 2009, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbmsdnfs.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/dbmsdnfs.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/dbmsdnfs.sql
Rem SQL_PHASE: DBMSDNFS
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catpdbms.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    rankalik    10/13/17 - Bug 26749279: add procedure to restore perm on df
Rem    aksshah     06/16/15 - Bug 20720667: Add dnfs_unmountvolume
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    msusaira    07/13/10 - make dbms_dnfs a fixed package
Rem    msusaira    06/03/09 - dNFS utility procedure
Rem    msusaira    06/03/09 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

--*****************************************************************************
-- Package Declaration
--*****************************************************************************

create or replace package dbms_dnfs AUTHID CURRENT_USER AS

-- DE-HEAD  <- tell SED where to cut when generating fixed package


  -- Renames files in the dNFS test database to the new name. The new file
  -- points to the original file for reads.
  -- 
  -- srcfile - source data file name in the control file
  -- destfile - destination file
  --
  PROCEDURE clonedb_renamefile (srcfile  IN varchar2,
                                destfile  IN varchar2
                                );

  -- This is the equivalent of the unmount command used to unmount an NFS
  -- volume. unmountvolume cleans up the cached mount handles in the
  -- database SGA. If volumes are deleted and recreated with the same name,
  -- this will prevent false cache hits and stale file handle errors.
  --
  -- server - NFS server that hosts the volume to be unmounted.
  -- volume - Volume that needs to be unmounted.
  --

  PROCEDURE unmountvolume(server IN varchar2, volume IN varchar2);


  procedure restore_datafile_permissions(pdb_name IN varchar2 DEFAULT NULL);
  -- NAME:
  -- restore_datafile_permissions - Restore datafile permissions to Read/Write
  --
  -- DESCRIPTION:
  --   This procedure restores a PDB's datafile permissions to Read/Write.
  --
  -- PARAMETERS:
  -- pdb_name - name of the PDB for which datafile permissions are to be 
  --            restored. If null, datafile permissions for current PDB 
  --            connection will be restored.

-------------------------------------------------------------------------------

pragma TIMESTAMP('2010-07-08:12:00:00');

-------------------------------------------------------------------------------


end;

-- CUT_HERE    <- tell sed where to chop off the rest

/
CREATE OR REPLACE PUBLIC SYNONYM dbms_dnfs FOR sys.dbms_dnfs
/
GRANT EXECUTE ON dbms_dnfs TO dba
/

show errors;

@?/rdbms/admin/sqlsessend.sql
