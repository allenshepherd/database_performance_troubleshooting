Rem
Rem $Header: rdbms/admin/catproft.sql /main/9 2015/08/19 11:54:51 raeburns Exp $
Rem
Rem catproft.sql
Rem
Rem Copyright (c) 2011, 2015, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catproft.sql - privilege Capture Types
Rem
Rem    DESCRIPTION
Rem      Types used for privilege capture
Rem
Rem    NOTES
Rem      Invoked in catptyps.sql
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catproft.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catproft.sql
Rem SQL_PHASE: CATPROFT
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catptyps.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    raeburns    06/09/15 - Remove OR REPLACE for types with table dependents
Rem    youyang     05/27/14 - add cbac packages array
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    jheng       07/31/13 - Bug 17251375: add type rolename_array
Rem    jheng       08/06/13 - Bug 16931220: change grant_path to varray
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    jheng       01/03/12 - Change profile to capture
Rem    jheng       12/11/11 - Bug 12903158
Rem    jheng       03/14/11 - Proj 32973: type used for privilege capture
Rem    jheng       03/14/11 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

create type sys.role_id_list as varray(10) of number
/
create or replace public synonym role_id_list for sys.role_id_list;
/


/* max enabled roles KZSROLMAX=150 */
create type sys.role_array as varray(150) of number;
/
create or replace public synonym role_array for sys.role_array;
/
create type sys.rolename_array as varray(150) of varchar2(128);
/
create or replace public synonym rolename_array for sys.rolename_array;
/
create type sys.grant_path AS VARRAY(150) OF VARCHAR2(128);
/
create or replace PUBLIC synonym grant_path for sys.grant_path;
/

CREATE TYPE sys.role_name_list IS VARRAY(10) OF varchar(128);
/
CREATE OR REPLACE PUBLIC SYNONYM role_name_list FOR sys.role_name_list;
/

create type sys.package_array as varray(1024) of number;
/
create or replace public synonym package_array for sys.package_array;
/

grant execute on role_id_list to PUBLIC;
grant execute on role_array to PUBLIC;
grant execute on rolename_array to PUBLIC;
grant execute on grant_path to PUBLIC;
grant execute on role_name_list to PUBLIC;
grant execute on package_array to PUBLIC;


@?/rdbms/admin/sqlsessend.sql
