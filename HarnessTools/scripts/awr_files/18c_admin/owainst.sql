Rem
Rem $Header: wwg_src_1/admin/owa/owainst.sql /main/34 2017/02/16 09:45:11 cvanes Exp $
Rem
Rem owainst.sql
Rem
Rem Copyright (c) 2001, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      owainst.sql - OWA pkg installation script
Rem
Rem    DESCRIPTION
Rem      This file is a driver file that installs the OWA packages
Rem      bundled with the database.  If you are directly invoking
Rem      the script you must run this script as SYS.
Rem
Rem      Note: this script also gets used during upgrades.
Rem      If the OWA packages already loaded in the database (if any) 
Rem      are more recent (based on OWA_UTIL.get_version() value), 
Rem      then this script will not reload the shipped OWA packages.
Rem
Rem    NOTES
Rem      This script can automatically install OWA packages in databases 
Rem      version 8.0.x and higher and is normally invoked via owaload.sql
Rem      Here is what the script does
Rem      - For 9.0.x and above, installs owacomm.sql
Rem      - For 8.1.x and above, installs wpiutl.sql and owacomm8i.sql
Rem      - For 8.0.x and above, installs wpiutl.sql and owacomm8.sql
Rem      To install the OWA packages in a 7.x database (not certified,
Rem      but should work), manually install wpiutl7.sql and owacomm7.sql
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    cvanes      01/17/17 - 23633556 Bump the version number 11.2.0.0.1
Rem    cvanes      01/23/12 - 13619141 Bump main version to 11.2.0.0.0
Rem    cvanes      06/14/11 - Bump version number to 10.1.2.2.0
Rem    cvanes      05/31/11 - 12607131: Update version number to 10.1.2.0.10
Rem    mmuppago    04/07/09 - bumping up ship version 
Rem    aimmanue    01/24/08 - Bump up the version
Rem    pkapasi     01/04/08 - Support db > 10.2.x only - bug#6160589
Rem    pkapasi     11/03/06 - Bump up owa version for next release
Rem    pkapasi     10/12/06 - Increment version number
Rem    mmuppago    04/27/06 - bumping up ship version 
Rem    mmuppago    03/21/06 - bumping up ship version 
Rem    mmuppago    11/01/05 - fix: 3434804 - OWA packages should not 
Rem                           overwrite customers OWA_CUSTOM packages
Rem    mmuppago    10/03/05 - Bump up the version
Rem    ehlee       04/25/05 - Bump up version
Rem    ehlee       09/02/04 - Bump up version
Rem    dnonkin     09/01/04 - Bump up version
Rem    pkapasi     11/27/03 - Bump up version
Rem    pkapasi     05/29/03 - Fix bugs and bump up version
Rem    ehlee       11/01/02 - Bump up version
Rem    ehlee       10/31/02 - Bump up version
Rem    pkapasi     10/09/02 - Bump up version
Rem    pkapasi     08/07/02 - Bump up version
Rem    ehlee       06/10/02 - Bump up version
Rem    ehlee       12/03/01 - Bump up version
Rem    ehlee       10/15/01 - Bump up version
Rem    pkapasi     09/21/01 - Bump up version
Rem    skwong      08/20/01 - Add owacomm8i.sql for 8i.
Rem    pkapasi     08/02/01 - Remove recompile of owa_util. causes invalidations
Rem    ehlee       07/11/01 - Change version to 3.0.0.0.6
Rem    pkapasi     06/14/01 - Change script to work for all 8.x databases
Rem    pkapasi     06/12/01 - Cleanup logic to figure which file is installed
Rem    pkapasi     06/12/01 - Add logic to install based on database version
Rem    kmuthukk    04/27/01 - version check based OWA pkg install
Rem    kmuthukk    04/27/01 - Created
Rem

variable owa_file_name   varchar2(200);
variable privcust_file   varchar2(200);
variable pubcust_file    varchar2(200);
variable owa_dbg_msg     varchar2(1000);
variable db_version      number;


Rem
Rem always initialize owa_file_name to some dummy value.
Rem
begin :owa_file_name := 'dummy_value'; end;
/
begin :privcust_file := 'owadummy.sql'; end;
/
begin :pubcust_file := 'owadummy.sql'; end;
/

DECLARE
  /*
   * This next line must be updated whenever 
   * OWA_UTIL.owa_version is updated.
   */
  shipped_owa_version    VARCHAR2(80) := '11.2.0.0.1';
  installed_owa_version  VARCHAR2(80);
  db_version_str         VARCHAR2(32);
  db_comp_version_str    VARCHAR2(32);
  new_line               VARCHAR2(4)  := '
';
  install_pkgs           BOOLEAN;
  is_supported_db_ver    boolean;

  -- procedure executes a DDL and ignores errors if any.
  PROCEDURE execute_ddl(ddl_statement VARCHAR2) IS
    ddl_cursor INTEGER;
  BEGIN
    -- try to execute DDL
    ddl_cursor := dbms_sql.open_cursor;

    -- issue the DDL statement
    dbms_sql.parse (ddl_cursor, ddl_statement, dbms_sql.native);
    dbms_sql.close_cursor (ddl_cursor);
  EXCEPTION
    -- ignore exceptions
    when others then
      if (dbms_sql.is_open(ddl_cursor)) then
        dbms_sql.close_cursor(ddl_cursor);
      end if;
  END;

 --
 -- takes a string of the form 'num1.num2.num3.....'
 -- returns "num1" AND updates string to 'num2.num3...'
 --
 FUNCTION get_next_int_and_advance(str IN OUT varchar2)
      RETURN PLS_INTEGER is
  loc pls_integer;
  ans pls_integer;
 BEGIN
  loc := instr(str, '.', 1);
  if (loc > 0) then
   ans := to_number(substr(str, 1, loc - 1));
   str := substr(str, loc + 1, length(str) - loc);
  else
   ans := to_number(str);
   str := '';
  end if;
  return ans;
 END;

 --
 -- Determines the database version and returns a number like 80500, 81700 etc
 --
 FUNCTION get_db_version 
      RETURN NUMBER is
    ans            NUMBER;
    l_version      VARCHAR2(32);
    l_comp_version VARCHAR2(32);
 BEGIN
   -- Get the version of the backend database
   dbms_utility.db_version(l_version, l_comp_version);

   -- Convert string to a number
   ans := 0;
   FOR i in 1..5 LOOP 
     ans := 10 * ans + get_next_int_and_advance(l_version);
   END LOOP;

   RETURN ans;

 END;

  --
  -- If shipped version of OWA packages is higher than the 
  -- pre-installed version of the OWA packages, then
  -- we need to reinstall the OWA packages.
  -- 
  FUNCTION needs_reinstall(shipped_owa_version   IN VARCHAR2,
                           installed_owa_version IN VARCHAR2) 
        RETURN BOOLEAN is

     shp_str VARCHAR2(80) := shipped_owa_version;
     shp_vsn PLS_INTEGER;
     ins_str VARCHAR2(80) := installed_owa_version;
     ins_vsn PLS_INTEGER;

  BEGIN
    --
    -- either OWA pkgs are not already installed (as can happen
    -- with a new DB) or an older version of the pkg is installed
    -- where version numbering was not implemented.
    --
    IF (installed_owa_version is NULL) THEN
      return TRUE;
    END IF;

    -- If version is the same, then we don't install it again to avoid 
    -- recompiling all dependent packages.
    --
    IF (installed_owa_version = shipped_owa_version) THEN
      return FALSE;
    END IF;

    --
    -- Check if shipped version is higher.
    --
    -- The OWA_UTIL version number format is V1.V2.V3.V4.V5.
    -- Lets compare versions by comparing Vi's from left to right.
    --
    FOR i in 1..5 LOOP 

     -- parse "shipped_version" one int at a time, from L to R
     shp_vsn := get_next_int_and_advance(shp_str);

     -- parse "installed_version" one int at a time, from L to R
     ins_vsn := get_next_int_and_advance(ins_str);
 
     IF (shp_vsn > ins_vsn) THEN
       return TRUE;
     END IF;

     IF (shp_vsn < ins_vsn) THEN
       return FALSE;
     END IF;

    END LOOP;

    -- 
    -- Should never come here. Return TRUE in this case as well.
    --
    RETURN TRUE;
  END;

  FUNCTION get_installed_owa_version RETURN VARCHAR2 IS
    owa_version VARCHAR2(80);
    l_cursor    INTEGER;
    l_stmt      VARCHAR2(256);
    l_status    INTEGER;
  BEGIN

    --
    -- Run this block via dynamic SQL and not static SQL
    -- because compilation of this block could fail as OWA_UTIL
    -- might be non-existant. Doing it from dynamic SQL allows
    -- us to catch the compile error as a run-time exception
    -- and proceed.
    --
    l_stmt := 'select OWA_UTIL.get_version from dual';
    l_cursor := dbms_sql.open_cursor;
    dbms_sql.parse(l_cursor, l_stmt, dbms_sql.native);
    dbms_sql.define_column( l_cursor, 1, owa_version, 80 );
    l_status := dbms_sql.execute(l_cursor);

    loop
       if dbms_sql.fetch_rows (l_cursor) > 0 then
          dbms_sql.column_value(l_cursor, 1, owa_version);
       else
          exit; 
       end if;
    end loop;
    dbms_sql.close_cursor(l_cursor);

    return owa_version;

  EXCEPTION
    --
    -- Either OWA pkgs have not been preinstalled
    -- Or, they are older set of OWA pkgs which
    -- a.) did not implement the OWA_UTIL.get_version method
    -- b.) resulted in ORA-6571 : ignore it
    -- 
    WHEN OTHERS THEN
     if dbms_sql.is_open(l_cursor) then
         dbms_sql.close_cursor(l_cursor);
     end if;
     return NULL;
  END;

BEGIN

 -- Get the version of OWA packages installed in the database
 installed_owa_version := get_installed_owa_version;

 -- Get the version of the backend database
 dbms_utility.db_version(db_version_str, db_comp_version_str);

 -- Format a message for display
 IF (installed_owa_version is NULL) THEN
    :owa_dbg_msg := 'No older OWA packages detected or OWA packages too old';
    :pubcust_file := 'pubcust.sql';
    :privcust_file := 'privcust.sql';
 ELSE
    :owa_dbg_msg := 'Installed OWA version is: ' || installed_owa_version;
 END IF;
 :owa_dbg_msg := :owa_dbg_msg || ';' || new_line ||
                  'Shipped OWA version is  : ' || shipped_owa_version || ';';

 -- Get the version of the backend database in number format
 :db_version := get_db_version;

 -- Check if we have the right DB version (10.2.x or higher => needed for bug#6160589)
 if (:db_version < 102000) then
     is_supported_db_ver := false;
 else
     is_supported_db_ver := true;
 end if;

 -- Proceed with the install
 if (is_supported_db_ver) then
     -- Check if we need to install the OWA packages?
     install_pkgs := needs_reinstall(shipped_owa_version, installed_owa_version);

     IF (install_pkgs) THEN

       -- Setup the debug message
       :owa_dbg_msg := :owa_dbg_msg || new_line ||
                   'OWA version ' || shipped_owa_version ||
                   ' will be installed into your Oracle ' || 
                   db_version_str || ' database';

       -- Dealing with 10.2.x and above
       :owa_file_name := 'owacomm.sql';

       :owa_dbg_msg := :owa_dbg_msg || new_line || 'Will install ' ||
                   :owa_file_name;

     ELSE
       :owa_file_name := 'owadummy.sql';
       :owa_dbg_msg := :owa_dbg_msg || new_line || 
                   'You already have a newer version of the OWA packages' ||
                   new_line || 'No install is required';
     END IF;

 else
     -- DB version is not right, print message and exit
     :owa_dbg_msg := :owa_dbg_msg || new_line ||
         'OWA version ' || shipped_owa_version ||
         ' requires the database version to be at least 10.2.x.' ||
         ' Your Oracle database version is ' || db_version_str || 
         ', OWA packages will not be installed.';
     :owa_file_name := 'owadummy.sql';
 end if;
END;
/

print :owa_dbg_msg;

COLUMN :owa_file_name NEW_VALUE owa_file_var NOPRINT;
SELECT :owa_file_name FROM DUAL;
COLUMN :pubcust_file NEW_VALUE pubcust_var NOPRINT;
SELECT :pubcust_file FROM DUAL;
COLUMN :privcust_file NEW_VALUE privcust_var NOPRINT;
SELECT :privcust_file FROM DUAL;

alter session set events '10520 trace name context forever, level 10';
@@&pubcust_var;
@@&owa_file_var;
@@&privcust_var;

alter session set events '10520 trace name context off';


