Rem
Rem dbmsspd.sql
Rem
Rem Copyright (c) 2011, 2016, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbmsspd.sql - DBMS Sql Plan Directives
Rem
Rem    DESCRIPTION
Rem      Please see the description at the beginning of the package spec.
Rem
Rem    NOTES
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/dbmsspd.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/dbmsspd.sql
Rem SQL_PHASE: DBMSSPD
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catpdbms.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    schakkap    06/28/16 - #(22182203) datapump support across versions
Rem    schakkap    05/30/16 - #(23498802): Check current user name
Rem    karpurus    04/10/15 - #(20826932) change signature of
Rem                           pack/create/unpack_stgtab_directive.
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    schakkap    05/31/13 - #(16571451) allow altering ENABLED state
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    schakkap    03/01/12 - #(9316756) add transfer_spd_for_dp
Rem    schakkap    10/02/11 - project SPD (31794): more procedures
Rem    schakkap    07/20/11 - project SPD (31794): add flush_sql_plan_directive
Rem                           pack, unpack
Rem    schakkap    03/31/11 - project SPD (31794): add dbms_spd package
Rem    schakkap    03/04/11 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

create  or replace package dbms_spd authid current_user is

  ---------------------------------------------------------------------------
  ---------------------------------------------------------------------------
  /*
    Package: DBMS_SPD

    This package provides subprograms for managing Sql Plan
    Directives(SPD). SPD are objects generated automatically by Oracle
    server. For example, if server detects that the single table cardinality 
    estimated by optimizer is off from the actual number of rows returned
    when accessing the table, it will automatically create a directive to
    do dynamic sampling for the table. When any Sql statement referencing
    the table is compiled, optimizer will perform dynamic sampling for the
    table to get more accurate estimate. 

    Notes:

    DBMSL_SPD is a invoker-rights package. The invoker requires ADMINISTER
    SQL MANAGEMENT OBJECT privilege for executing most of the subprograms of
    this package. Also the subprograms commit the current transaction (if any), 
    perform the operation and commit it again.
    
    DBA view dba_sql_plan_directives shows all the directives created in
    the system and the view dba_sql_plan_dir_objects displays the objects that
    are included in the directives.

  */
  ---------------------------------------------------------------------------
  ---------------------------------------------------------------------------


  ---------------------------------------------------------------------------
  --                           TYPES AND CONSTANTS
  ---------------------------------------------------------------------------

  -- Default value for SPD_RETENTION_WEEKS
  SPD_RETENTION_WEEKS_DEFAULT  CONSTANT varchar2(4)    := '53';


  -- Objects in the directive
  type ObjectElem is record (
    owner       dbms_quoted_id,     -- owner of the object
    object_name dbms_quoted_id,     -- name of the object
    object_type varchar2(6)         -- 'TABLE'
  );
  type ObjectTab is table of ObjectElem;

  ---------------------------------------------------------------------------
  --                           EXCEPTIONS                                  
  ---------------------------------------------------------------------------
  /*
     Exception: insufficient_privilege
    
      The user does not have proper privilege to perform the operation
  */
  insufficient_privilege exception;
  pragma exception_init(insufficient_privilege, -38171);

  /*
    Exception: object_does_not_exist

      The specified object does not exist.
  */
  object_does_not_exist exception;
  pragma exception_init(object_does_not_exist, -13158);


  /*
    Exception: invalid_input

      The input value is not valid
  */
  invalid_input exception;
  pragma exception_init(invalid_input, -28104);

  /*
    Exception: invalid_schema

      The input schema does not exist
  */
  invalid_schema exception;
  pragma exception_init(invalid_schema, -44001);

  /*
    Exception: table_already_exists

      The specified table already exists. 
  */
  table_already_exists exception;
  pragma exception_init(table_already_exists, -13159);

  /*
    Exception: tablespace_missing

      The specified tablespace does not exist. 
  */
  tablespace_missing exception;
  pragma exception_init(tablespace_missing, -29304);

  /*
    Exception: invalid_stgtab

      The specified staging table is invalid or does not exist
  */
  invalid_stgtab exception;
  pragma exception_init(invalid_stgtab, -19374);

  ---------------------------------------------------------------------------
  --                           SUBPROGRAMS
  ---------------------------------------------------------------------------

  /*
    Procedure: alter_sql_plan_directive

      This procedure can be used to change different attributes of a 
      SQL Plan Directive.
  
    Parameters:
      directive_id     - SQL Plan Directive id
      attribute_name   - One of the attribute names as below
      attribute_value  - Values of the above attributes as below
  
    The following attribute(s) are supported.

 
    | Attribute_name : Attribute_value : Description

    | ENABLED        : YES             : Directive is enabled and may 
    |                                    be used.
    |                  NO              : Directive is not enabled and will 
    |                                    not be used.
    |
    | AUTO_DROP      : YES             : Directive will be dropped 
    |                                    automatically if not 
    |                                    used for SPD_RETENTION_WEEKS.
    |                                    This is the default behavior.
    |                  NO              : Directive will not be dropped 
    |                                    automatically.

    Exceptions:
      - <insufficient_privilege>
      - <object_does_not_exist>
      - <invalid_input>
  
    Notes:
      "Administer SQL Management Object" privilege is required to execute
      this procedure.

    Examples:
    | begin  
    |   dbms_spd.alter_sql_plan_directive(12345, 'STATE', 'PERMANENT');
    | end;

    Returns:
      Nothing.
  */
  procedure alter_sql_plan_directive(
              directive_id    number,
              attribute_name  varchar2,
              attribute_value varchar2);

  /*
    Procedure: drop_sql_plan_directive

      This procedure can be used to drop a SQL Plan Directive.
  
    Parameters:
      directive_id     - SQL Plan Directive id
  
    Exceptions:
      - <insufficient_privilege>
      - <object_does_not_exist>
      - <invalid_input>

    Notes:
      "Administer SQL Management Object" privilege is required to execute
      this procedure.

      If null is passed for directive_id, it will drop all directives not
      used for last SPD_RETENTION_WEEKS. The directives with AUTO_DROP set to
      NO will not be dropped.

    Examples:
    | begin  
    |   dbms_spd.drop_sql_plan_directive(12345);
    | end;

    Returns:
      Nothing.
  */
  procedure drop_sql_plan_directive(
              directive_id    number);

  /*
    Procedure: flush_sql_plan_directive

      This procedure allows manually flushing the Sql Plan directives that 
      are automatically recorded in SGA memory while executing sql 
      statements. The information recorded in SGA are periodically flushed
      by oracle background processes. This procedure just provides a way to
      flush the information manually.

    Parameters:
  
    Exceptions:
      - <insufficient_privilege>

    Notes:
      "Administer SQL Management Object" privilege is required to execute
      this procedure.

    Examples:
    | begin  
    |   dbms_spd.flush_sql_plan_directive;
    | end;

    Returns:
      Nothing.
  */
  procedure flush_sql_plan_directive;

  /*
    Procedure: create_stgtab_directive

      This procedure creates a staging table to pack (export) Sql Plan 
      directives into it.

    Parameters:
      table_name       - Name of staging table.
      table_owner      - Name of schema owner of staging table.
                         Default is current schema.
      tablespace_name  - Name of tablespace.
                         Default NULL means create staging table in the
                         default tablespace.
    Exceptions:
      - <insufficient_privilege>
      - <invalid_input>
      - <invalid_schema>
      - <table_already_exists>
      - <tablespace_missing>

    Notes:
      "Administer SQL Management Object" privilege is required to execute 
      this procedure.

    Examples:
    | begin  
    |   dbms_spd.create_stgtab_directive('mydirtab');
    | end;

    Returns:
      Nothing
  */
  procedure create_stgtab_directive(table_name       in varchar2,
                                    table_owner      in varchar2 := 
                                      dbms_assert.enquote_name(
                                        sys_context('USERENV', 'CURRENT_USER'),
                                        FALSE),
                                    tablespace_name  in varchar2 := null);

  /*
    Procedure: pack_stgtab_directive

      This procedure packs (exports) SQL Plan Directives into a staging 
      table.

    Parameters:
      table_name       - Name of staging table.
      table_owner      - Name of schema owner of staging table.
                         Default is current schema.
      directive_id     - SQL Plan Directive id
                         Default NULL means all directives in the system.
      obj_list         - This argument can be used to filter the 
                         directives to be packed based on the objects used in
                         directives. if obj_list is not null, a directive is 
                         packed only if all the objects in the directive 
                         exists in obj_list. 

    Exceptions:
      - <insufficient_privilege>
      - <object_does_not_exist>
      - <invalid_input>
      - <invalid_schema>
      - <invalid_stgtab>   

    Notes:
      "Administer SQL Management Object" privilege is required to execute 
      this procedure.

    Examples:
    | -- Pack all directives in the system
    | select dbms_spd.pack_stgtab_directive('mydirtab') from dual;
    |
    | set serveroutput on;
    | -- Pack directives relevant to objects in SH schema
    | declare
    |   my_list  dbms_spd.objecttab := dbms_spd.ObjectTab();
    |   dir_cnt  number;
    | begin
    |   my_list.extend(1);
    |   my_list(1).owner := 'SH';           -- schema name
    |   my_list(1).object_name := null;     -- all tables in SH
    |   my_list(1).object_type := 'TABLE';  -- type of object
    |
    |   dir_cnt :=
    |     dbms_spd.pack_stgtab_directive('mydirtab', obj_list => my_list);
    |   dbms_output.put_line('dir_cnt = ' || dir_cnt);
    | end;
    |
    | -- Pack directives relevant to tables SALES and CUSTOMERS in SH schema
    | declare
    |   my_list  dbms_spd.objecttab := dbms_spd.ObjectTab();
    |   dir_cnt  number;
    | begin
    |   my_list.extend(2);
    |
    |   -- SALES table
    |   my_list(1).owner := 'SH';
    |   my_list(1).object_name := 'SALES';
    |   my_list(1).object_type := 'TABLE';
    |   
    |   -- CUSTOMERS table
    |   my_list(2).owner := 'SH';
    |   my_list(2).object_name := 'CUSTOMERS';
    |   my_list(2).object_type := 'TABLE';
    |   
    |   dir_cnt :=
    |     dbms_spd.pack_stgtab_directive('mydirtab', obj_list => my_list);
    |   dbms_output.put_line('dir_cnt = ' || dir_cnt);
    | end;
    |

    Returns:
      Number of Sql Plan Directives packed.
  */
  function pack_stgtab_directive(table_name            in varchar2,
                                 table_owner           in varchar2 := 
                                   dbms_assert.enquote_name(
                                     sys_context('USERENV', 'CURRENT_USER'),
                                     FALSE),
                                 directive_id          in number := null,
                                 obj_list              in ObjectTab := null)
  return number;

  /*
    Procedure: unpack_stgtab_directive

      This procedure unpacks (imports) SQL Plan Directives from a staging 
      table.

    Parameters:
      table_name       - Name of staging table.
      table_owner      - Name of schema owner of staging table.
                         Default is current schema.
      directive_id     - SQL Plan Directive id
                         Default NULL means all directives in the staging 
                         table.
      obj_list         - This argument can be used to filter the 
                         directives to be unpacked based on the objects used in
                         directives. if obj_list is not null, a directive is 
                         unpacked only if all the objects in the directive 
                         exists in obj_list. 

    Exceptions:
      - <insufficient_privilege>
      - <object_does_not_exist>
      - <invalid_input>
      - <invalid_schema>
      - <invalid_stgtab>   

    Notes:
      "Administer SQL Management Object" privilege is required to execute 
      this procedure.

    Examples:
    | -- Unack all directives in the staging table
    | select dbms_spd.unpack_stgtab_directive('mydirtab') from dual;
    |
    | set serveroutput on;
    | -- Unpack directives relevant to objects in SH schema
    | declare
    |   my_list  dbms_spd.objecttab := dbms_spd.ObjectTab();
    |   dir_cnt  number;
    | begin
    |   my_list.extend(1);
    |   my_list(1).owner := 'SH';           -- schema name
    |   my_list(1).object_name := null;     -- all tables in SH
    |   my_list(1).object_type := 'TABLE';  -- type of object
    |
    |   dir_cnt :=
    |     dbms_spd.unpack_stgtab_directive('mydirtab', obj_list => my_list);
    |   dbms_output.put_line('dir_cnt = ' || dir_cnt);
    | end;
    |
    | -- Unpack directives relevant to tables SALES and CUSTOMERS in SH schema
    | declare
    |   my_list  dbms_spd.objecttab := dbms_spd.ObjectTab();
    |   dir_cnt  number;
    | begin
    |   my_list.extend(2);
    |
    |   -- SALES table
    |   my_list(1).owner := 'SH';
    |   my_list(1).object_name := 'SALES';
    |   my_list(1).object_type := 'TABLE';
    |   
    |   -- CUSTOMERS table
    |   my_list(2).owner := 'SH';
    |   my_list(2).object_name := 'CUSTOMERS';
    |   my_list(2).object_type := 'TABLE';
    |   
    |   dir_cnt :=
    |     dbms_spd.unpack_stgtab_directive('mydirtab', obj_list => my_list);
    |   dbms_output.put_line('dir_cnt = ' || dir_cnt);
    | end;
    |

    Returns:
      Number of Sql Plan Directives unpacked.
  */
  function unpack_stgtab_directive(table_name            in varchar2,
                                   table_owner           in varchar2 := 
                                     dbms_assert.enquote_name(
                                       sys_context('USERENV', 'CURRENT_USER'),
                                       FALSE),
                                   directive_id          in number := null,
                                   obj_list              in ObjectTab := null)
  return number;

  /*
    Procedure: set_prefs

      This procedures allows setting different preferences for Sql
      Plan Directives.

    Parameters:

      pname          - preference name
      pvalue         - preference value
 
    Exceptions:
      - <insufficient_privilege>
      - <invalid_input>

    Notes:
      "Administer SQL Management Object" privilege is required to execute
      this procedure.

      The procedure supports the following preference.

        SPD_RETENTION_WEEKS - Sql Plan Directives are purged if not used for 
          more than the value set for this preference. Default is 53 
          (SPD_RETENTION_WEEKS_DEFAULT) weeks, which means a directive is
          purged if it has been left unused for little over a year. It can be
          set to any value greater than or  equal to 0. Also value null can be
          passed to set the preference to default.

    Examples:
    | begin  
    |   dbms_spd.set_prefs('SPD_RETENTION_WEEKS', '4');
    | end;

    Returns:
      Nothing.
  */
  procedure set_prefs(pname in varchar2,
                      pvalue  in varchar2);

  /*
    Function: get_prefs

      This function gets the values for preferences for Sql Plan
      Directives.

    Parameters:

      pname          - preference name
 
    Exceptions:
      - <insufficient_privilege>
      - <invalid_input>

    Notes:
      "Administer SQL Management Object" privilege is required to execute
      this function.

      The function supports the following preference.

        SPD_RETENTION_WEEKS - Sql Plan Directives are purged if not used for 
          more than the value set for this preference. 

    Examples:
    | 
    |  select dbms_spd.get_prefs('SPD_RETENTION_WEEKS') from dual;
    | 

    Returns:
      Preference value
  */
  function get_prefs(pname in varchar2) return varchar2;

 ------------------- FOR INTERNAL USE OF DATAPUMP ONLY --------------------

 procedure transfer_spd_for_dp(
              objlist_tabf   varchar2,
              dblinkf        varchar2,
              fin_sc         number,
              db_sc          number,
              operation      number);

 ------------------- FOR INTERNAL USE OF DATAPUMP ONLY --------------------

end dbms_spd;
/
show errors;

/* Create a synonym for general public */
create or replace public synonym dbms_spd for sys.dbms_spd
/
grant execute on dbms_spd to public
/
show errors;

/* Create the trusted pl/sql callout library */
create or replace library dbms_spd_lib trusted as static
/
show errors;

@?/rdbms/admin/sqlsessend.sql
