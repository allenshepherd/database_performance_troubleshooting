Rem
Rem $Header: rdbms/admin/awrmacro.sql /st_rdbms_18.0/2 2018/02/07 20:26:29 kmorfoni Exp $
Rem
Rem awrmacro.sql
Rem
Rem Copyright (c) 2017, 2018, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      awrmacro.sql - AWR utility to define macros for SQL*Plus scripts
Rem
Rem    DESCRIPTION
Rem      Utility that defines macros to be used in SQL*Plus scripts.
Rem      Macros are implemented as substitution variables. The caller needs
Rem      to pass 2 required arguments, followed by any number of optional
Rem      arguments. The two required arguments are:
Rem        Argument 1: The macro name
Rem        Argument 2: The macro type
Rem        Argument 3-n: Optional arguments specific to the macro type
Rem
Rem      Currently supported macro types:
Rem        - SDM_TYPE: System Data Mask Type
Rem          Expects three additional arguments:
Rem           + scope of masking (MASK_IWD means mask only instance wide data
Rem                               MASK_ALL means mask all data)
Rem           + table alias
Rem           + column name
Rem
Rem    NOTES
Rem      None
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/awrmacro.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/awrmacro.sql
Rem    SQL_PHASE: UTILITY
Rem    SQL_STARTUP_MODE: NORMAL
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    kmorfoni    01/26/18 - Backport kmorfoni_bug-27259386 from
Rem                           st_rdbms_pt-dwcs
Rem    kmorfoni    12/21/17 - Bug 27259386: introduce scope of masking
Rem    kmorfoni    11/22/17 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql
set termout off

undefine &1
column &1 new_value &1 noprint

-- &1: macro name
-- &2: macro type
select
  case when '&2' = 'SDM_TYPE' then
  -- &3: scope of masking (MASK_IWD means mask only instance wide data
  --                       MASK_ALL means mask all data)
  -- &4: table alias
  -- &5: column name
    'case when SYS_CONTEXT(''USERENV'',''SYSTEM_DATA_VISIBLE'')=''YES'' '
               || decode('&3', 'MASK_IWD', 'or '
                                      || decode('&4', '', '', '&4' || '.')
                                      ||'per_pdb<>0 ',
                               'MASK_ALL', '',
                               'Unsupported input 3: &3 ')
               || 'then '
               || decode('&4', '', '', '&4' || '.')
               || '&5 else null end &5'
  else '' -- Unsupported macro type
  end &1
from dual;

set termout on

@?/rdbms/admin/sqlsessend.sql
 
