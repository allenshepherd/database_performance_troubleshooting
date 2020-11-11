Rem
Rem $Header: rdbms/admin/utlpitl.sql /main/2 2017/05/28 22:46:12 stanaya Exp $
Rem
Rem utlpitl.sql
Rem
Rem Copyright (c) 2000, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      utlpitl.sql - UTiLity to reset Pdml ITL
Rem
Rem    DESCRIPTION
Rem      This script needs to be executed to remove PDML ITL 
Rem      incompatibilities before you issue the 
Rem      ALTER DATABASE RESET COMPATIBILITY statement to lower
Rem      compatibility from 9.0 to 8.1.
Rem
Rem    NOTES
Rem      Must be run AS SYSDBA
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/utlpitl.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/utlpitl.sql
Rem    SQL_PHASE: UTILITY
Rem    SQL_STARTUP_MODE: NORMAL
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    END SQL_FILE_METADATA
Rem    
Rem    MODIFIED   (MM/DD/YY)
Rem    rburns      12/15/00 - renamed
Rem    dpotapov    06/28/00 - Created
Rem

update tab$ set property = property - bitand( property, 536870912 )
where bitand( property, 536870912 ) > 0;

commit;
