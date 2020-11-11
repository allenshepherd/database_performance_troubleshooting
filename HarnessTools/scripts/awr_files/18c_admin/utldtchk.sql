Rem Copyright (c) 2006, 2016, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      utldtchk.sql - Dependency timestamp check utility
Rem
Rem    DESCRIPTION
Rem      This utility script verifies that a valid database object has
Rem      correct dependency$ timestamps for all its parent objects.
Rem
Rem      Violation of this invariant can show up as one of the following:
Rem      - Invalid dependency references [DEP/INV] in library cache
Rem        dumps
Rem      - ORA-06508: PL/SQL: could not find program unit being called
Rem      - PLS-00907: cannot load library unit %s (referenced by %s)
Rem      - ORA-00600[kksfbc-reparse-infinite-loop] 
Rem
Rem    NOTES
Rem      This script reports false positives in the following cases:
Rem      1. Circular synonyms: A chain of circular synonyms can leave a
Rem         valid synonym pointing to an invalid parent synonym. Such
Rem         synonyms are not common because they raise ORA-1775 errors when
Rem         they are used.
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/utldtchk.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/utldtchk.sql
Rem    SQL_PHASE: UTLDTCHK
Rem    SQL_STARTUP_MODE: NORMAL
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    SQL_CALLING_FILE: NONE
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    vperiwal    03/09/16 - 22901766: add type# and obj#
Rem    vperiwal    02/25/16 - 22351378: add file meta data info
Rem    brwolf      07/09/12 - add edition name
Rem    gviswana    08/21/06 - Created
Rem

SET ECHO ON
SET FEEDBACK 1
SET NUMWIDTH 10
SET LINESIZE 196
SET TRIMSPOOL ON
SET TAB OFF
SET PAGESIZE 99

column d_owner format a22
column p_owner format a22
column d_name format a22;
column p_name format a22;
column d_edition format a22;
column p_edition format a22;
column reason format a18;
column d_type# format 99999;
column p_type# format 99999;
column d_obj# format 9999999999;
column p_obj# format 9999999999;

select du.name d_owner, d.name d_name, d.type# d_type#,
       d.obj# d_obj#, d.defining_edition d_edition,
       pu.name p_owner, p.name p_name, p.type# p_type#,
       p.obj# p_obj#, p.defining_edition p_edition,
   case
      when p.status not in (1, 2, 4) then 'P Status: ' || to_char(p.status)
   else 'TS mismatch:      ' ||
      to_char(dep.p_timestamp, 'DD-MON-YY HH24:MI:SS') ||
      to_char(p.stime, 'DD-MON-YY HH24:MI:SS')
   end reason
   from sys."_ACTUAL_EDITION_OBJ" d, sys.user$ du, sys.dependency$ dep,
        sys."_ACTUAL_EDITION_OBJ" p, sys.user$ pu
   where d.obj# = dep.d_obj# and p.obj# = dep.p_obj#
     and d.owner# = du.user# and p.owner# = pu.user#
     and d.status = 1                                    -- Valid dependent
     and bitand(dep.property, 1) = 1                     -- Hard dependency
     and d.subname is null                               -- !Old type version
     and not(p.type# = 32 and d.type# = 1)               -- Index to indextype
     and not(p.type# = 29 and d.type# = 5)               -- Synonym to Java
     and not(p.type# in(5, 13) and d.type# in (2, 55))   -- TABL/XDBS to TYPE
     and (p.status not in (1, 2, 4) or p.stime != dep.p_timestamp);

