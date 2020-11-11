Rem
Rem $Header: rdbms/admin/execstat.sql /main/2 2014/02/20 12:45:44 surman Exp $
Rem
Rem execstat.sql
Rem
Rem Copyright (c) 2007, 2014, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      execstat.sql - EXECute STATs packages
Rem
Rem    DESCRIPTION
Rem      Executes the stats initialization procedure
Rem
Rem    NOTES
Rem      
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/execstat.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/execstat.sql
Rem SQL_PHASE: EXECSTAT
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catpexec.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    surman      01/23/14 - 13922626: Update SQL metadata
Rem    rburns      01/06/07 - initialize stats
Rem    rburns      01/06/07 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

begin
  dbms_stats.init_package;
end;
/


@?/rdbms/admin/sqlsessend.sql
