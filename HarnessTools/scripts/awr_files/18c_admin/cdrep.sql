Rem
Rem $Header: rdbms/admin/cdrep.sql /main/5 2016/12/09 14:02:12 sramakri Exp $
Rem
Rem cdrep.sql
Rem
Rem Copyright (c) 2006, 2016, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      cdrep.sql - Catalog DREP.bsq views
Rem
Rem    DESCRIPTION
Rem      sumdelta objects
Rem
Rem    NOTES
Rem      This script contains catalog views for objects in drep.bsq.
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/cdrep.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/cdrep.sql
Rem SQL_PHASE: CDREP
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catalog.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    sramakri    06/10/16 - remove CDC from 12.2
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    cdilling    08/03/06 - add catcdc.sql
Rem    cdilling    05/04/06 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql


@?/rdbms/admin/sqlsessend.sql
