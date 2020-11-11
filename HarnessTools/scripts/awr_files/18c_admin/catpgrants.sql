Rem
Rem $Header: rdbms/admin/catpgrants.sql /main/2 2014/02/20 12:45:39 surman Exp $
Rem
Rem catpgrants.sql
Rem
Rem Copyright (c) 2012, 2014, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catpgrants.sql - catproc grants creation
Rem
Rem    DESCRIPTION
Rem      This script creates grants privileges for users.
Rem
Rem    NOTES
Rem     
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catpgrants.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catpgrants.sql
Rem SQL_PHASE: CATPGRANTS
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catproc.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    surman      01/23/14 - 13922626: Update SQL metadata
Rem    jerrede     04/18/12 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

-- Sys is granted privileges through roles, which don't apply to
-- packages owned by sys.  Explicitly grant permissions.
grant select any table to sys with admin option
/
grant insert any table to sys
/
grant update any table to sys
/
grant delete any table to sys
/
grant analyze any to sys
/
grant select any sequence to sys
/
grant execute any type to sys
/
grant lock any table to sys
/

Rem
Rem END OF catpgrants.sql
Rem 
@?/rdbms/admin/sqlsessend.sql
