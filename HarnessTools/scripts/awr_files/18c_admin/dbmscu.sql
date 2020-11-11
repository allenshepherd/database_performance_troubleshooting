Rem
Rem $Header: rdbms/admin/dbmscu.sql /main/6 2014/02/20 12:45:45 surman Exp $
Rem
Rem dbmscu.sql
Rem
Rem Copyright (c) 2007, 2014, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbmscu.sql - Misc cache layer PL/SQL functions
Rem
Rem    DESCRIPTION
Rem      Declaration of misc cache layer PL/SQL functions
Rem
Rem    NOTES
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/dbmscu.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/dbmscu.sql
Rem SQL_PHASE: DBMSCU
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catpdbms.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    phsieh      01/08/14 - active_drm
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    adalee      11/11/08 - add object_downconvert
Rem    adalee      07/03/08 - add grab_index parameter
Rem    adalee      06/20/08 - add dissolve functions
Rem    adalee      09/27/07 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

CREATE OR REPLACE PACKAGE dbms_cacheutil AS

-- DE-HEAD  <- tell SED where to cut when generating fixed package

--*****************************************************************************
-- Package Public Exceptions
--*****************************************************************************

--*****************************************************************************
-- Package Public Types
--*****************************************************************************
-------------------------------------------------------------------------------
--
-- PROCEDURE     grab_affinity
--
-- Description:  try to grab object affinity in RAC environment
--
-- Parameters:   
--
-------------------------------------------------------------------------------
PROCEDURE grab_affinity( schema     IN varchar2,
                         obj        IN varchar2,
                         partition  IN varchar2 := null,
                         grab_index IN boolean := TRUE,
                         active_drm IN boolean := FALSE);

-------------------------------------------------------------------------------
--
-- PROCEDURE     grab_readmostly
--
-- Description:  try to grab object readmostly in RAC environment
--
-- Parameters:   
--
-------------------------------------------------------------------------------
PROCEDURE grab_readmostly( schema     IN varchar2,
                           obj        IN varchar2,
                           partition  IN varchar2 := null,
                           grab_index IN boolean := TRUE);

-------------------------------------------------------------------------------
--
-- PROCEDURE     dissolve_affinity
--
-- Description:  try to dissolve object affinity in RAC environment
--
-- Parameters:   
--
-------------------------------------------------------------------------------
PROCEDURE dissolve_affinity( schema         IN varchar2,
                             obj            IN varchar2,
                             partition      IN varchar2 := null,
                             dissolve_index IN boolean := TRUE,
                             active_drm     IN boolean := FALSE);

-------------------------------------------------------------------------------
--
-- PROCEDURE     dissolve_readmostly
--
-- Description:  try to dissolve object readmostly in RAC environment
--
-- Parameters:   
--
-------------------------------------------------------------------------------
PROCEDURE dissolve_readmostly( schema         IN varchar2,
                               obj            IN varchar2,
                               partition      IN varchar2 := null,
                               dissolve_index IN boolean := TRUE);

-------------------------------------------------------------------------------
--
-- PROCEDURE     list_readmostly
--
-- Description:  list objects have readmostly property set
--
-- Parameters:   
--
-------------------------------------------------------------------------------
PROCEDURE list_readmostly;

-------------------------------------------------------------------------------
--
-- PROCEDURE     object_downconvert
--
-- Description:  try to downconvert object locks to shared mode in RAC
--
-- Parameters:   
--
-------------------------------------------------------------------------------
PROCEDURE object_downconvert( schema            IN varchar2,
                              obj               IN varchar2,
                              partition         IN varchar2 := null,
                              downconvert_index IN boolean := TRUE);


END;

-- CUT_HERE    <- tell sed where to chop off the rest

/
CREATE OR REPLACE PUBLIC SYNONYM dbms_cacheutil FOR sys.dbms_cacheutil
/

GRANT EXECUTE ON dbms_cacheutil TO dba
/

@?/rdbms/admin/sqlsessend.sql
