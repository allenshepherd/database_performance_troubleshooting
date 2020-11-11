Rem
Rem $Header: rdbms/admin/javdbmig.sql /main/12 2017/04/11 17:07:31 welin Exp $
Rem
Rem javdbmig.sql
Rem
Rem Copyright (c) 2001, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      javdbmig.sql - CATalog DataBase MIGration script
Rem
Rem    DESCRIPTION
Rem      This script upgrades the RDBMS java classes
Rem
Rem    NOTES
Rem      It is invoked by the cmpdbmig.sql script after JAVAVM 
Rem      has been upgraded.

Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/javdbmig.sql 
Rem    SQL_SHIPPED_FILE: rdbms/admin/javdbmig.sql 
Rem    SQL_PHASE: UPGRADE
Rem    SQL_STARTUP_MODE: UPGRADE
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: rdbms/admin/cmpupgrd.sql
Rem    END SQL_FILE_METADATA

Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    raeburns    03/25/17 - Bug 25752691: Use SQL_PHASE UPGRADE
Rem    welin       03/23/17 - Bug 25790099: move Bug 8687981: drop appctx package here
Rem    sramakri    06/09/16 - remove CDC from 12.2
Rem    rafsanto    04/07/16 - Bug 22983537 - remove ODCI%$_Ctx types
Rem    frealvar    02/10/16 - Bug 22649453 adding extra logic to the status of catjava
Rem    rakkushw    04/12/2013 - removing obsolete java class files introduced in old releases 
Rem    gssmith     12/11/07 - Fix bug 6445932
Rem    gssmith     02/12/07 - Remove Summary Advisor objects
Rem    cdilling    11/10/05 - remove 817 and 901 code 
Rem    rburns      05/17/04 - rburns_single_updown_scripts
Rem    rburns      11/12/02 - use dbms_registry.check_server_instance
Rem    rburns      03/30/02 - restructure queries
Rem    rburns      01/12/02 - Merged rburns_catjava
Rem    rburns      12/18/01 - Created
Rem

Rem *************************************************************************
Rem Check instance version and status; set session attributes
Rem *************************************************************************

WHENEVER SQLERROR EXIT;
EXECUTE dbms_registry.check_server_instance;
WHENEVER SQLERROR CONTINUE;

Rem Indicate that the upgrade of CATJAVA has started
execute dbms_registry.upgrading('CATJAVA');


Rem *************************************************************************
Rem Remove obsolete Summary Advisor java classes for upgrading to 12c release
Rem *************************************************************************

declare
  droplist dbms_sql.varchar2_table;
  l_buf varchar2(4000);
begin
  droplist(1) := 'oracle/jms/AQjmsReflect$AQjmsClassReflect';
  droplist(2) := 'oracle/jms/AQjmsReflect$AQjmsThreadReflect';
  droplist(3) := 'oracle/jms/AQjmsReflect';
  droplist(4) := 'oracle/jms/ASCII_CharStream';
  droplist(5) := 'oracle/jms/JJAQjmsParserCalls';
  droplist(6) := 'oracle/jms/AQjmsMessages_ca';
  droplist(7) := 'oracle/jms/AQjmsHttpRcv';
  droplist(8) := 'oracle/jms/AQjmsEventListener';
  droplist(9) := '/6381387c_AQjmsEventListenerPo';
  droplist(10) := '/1e1edbae_AQjmsEventListenerPo';
  droplist(11) := '/5d83c9b7_AQjmsEventListenerCo';
  droplist(12) := '/9d925bfe_AQjmsEventListenerCo';
  droplist(13) := 'oracle/ODCI/ODCIArgDesc$_Ctx';
  droplist(14) := 'oracle/ODCI/ODCIColInfo$_Ctx';
  droplist(15) := 'oracle/ODCI/ODCICost$_Ctx';
  droplist(16) := 'oracle/ODCI/ODCIFuncInfo$_Ctx';
  droplist(17) := 'oracle/ODCI/ODCIIndexCtx$_Ctx';
  droplist(18) := 'oracle/ODCI/ODCIIndexInfo$_Ctx';
  droplist(19) := 'oracle/ODCI/ODCIObject$_Ctx';
  droplist(20) := 'oracle/ODCI/ODCIPredInfo$_Ctx';
  droplist(21) := 'oracle/ODCI/ODCIQueryInfo$_Ctx';
  droplist(22) := 'oracle/ODCI/ODCIStatsOptions$_Ctx';

  FOR i IN droplist.FIRST .. droplist.LAST
  loop
      dbms_output.put_line(droplist(i));
      begin
        dbms_output.put_line(droplist(i));
        initjvmaux.drop_sys_class(droplist(i)); 
      end;
  end loop;
end;
/

Rem ******************************************************************************
Rem Remove obsolete Change Data Capture java classes for upgrading to 12.2 release
Rem *******************************************************************************

declare
  droplist dbms_sql.varchar2_table;
  l_buf varchar2(4000);
begin
  droplist(1) := 'oracle/CDC/AdvanceChangeSet';
  droplist(2) := 'oracle/CDC/CDCConnection';
  droplist(3) := 'oracle/CDC/CDCException';
  droplist(4) := 'oracle/CDC/CDCLock';
  droplist(5) := 'oracle/CDC/CDCSystem';
  droplist(6) := 'oracle/CDC/ChangeSet';
  droplist(7) := 'oracle/CDC/ChangeSource';
  droplist(8) := 'oracle/CDC/ChangeTable';
  droplist(9) := 'oracle/CDC/ChangeTableTrigger';
  droplist(10) := 'oracle/CDC/ChangeView';
  droplist(11) := 'oracle/CDC/ColumnList';
  droplist(12) := 'oracle/CDC/ControlColumns';
  droplist(13) := 'oracle/CDC/NNUString';
  droplist(14) := 'oracle/CDC/ONBString';
  droplist(15) := 'oracle/CDC/PublishApi';
  droplist(16) := 'oracle/CDC/Purge';
  droplist(17) := 'oracle/CDC/PurgeTable';
  droplist(18) := 'oracle/CDC/SubscribeApi';
  droplist(19) := 'oracle/CDC/Subscription';
  droplist(20) := 'oracle/CDC/SubscriptionHandle';
  droplist(21) := 'oracle/CDC/SubscriptionWindow';
  droplist(22) := 'oracle/CDC/YNString';

  FOR i IN droplist.FIRST .. droplist.LAST
  loop
      dbms_output.put_line(droplist(i));
      begin
        dbms_output.put_line(droplist(i));
        initjvmaux.drop_sys_class(droplist(i)); 
      end;
  end loop;
end;
/

Rem =====================================================================
Rem BEGIN: Bug 8687981: drop appctx package
Rem =====================================================================

Rem Bug 17384626:
Rem   Use 'DROP JAVA' ddl to drop AppCtx java classes.
Rem   Earlier these java classes were dropped using dbms_java.dropjava() call,
Rem   which takes the corresponding .jar filename 'rdbms/jlib/appctxapi.jar'
Rem   as an argument. In 12.1.0.1, this AppCtx jar file is removed completely.
Rem   Due to this following previous statement fails during 12.1.0.2 upgrade -
Rem     execute immediate
Rem        'call sys.dbms_java.dropjava(''-s rdbms/jlib/appctxapi.jar'')';
Rem   This is now fixed by replacing dbms_java.dropjava() by 'DROP JAVA' ddl.
DECLARE
  CURSOR AppCtxClassCur IS
    SELECT object_name FROM dba_objects
    WHERE object_type = 'JAVA CLASS' AND
          (object_name LIKE '%AppCtxMessages%' OR
           object_name LIKE '%AppCtxPermit' OR
           object_name LIKE '%AppCtxUtil' OR
           object_name LIKE '%AppCtxException' OR
           object_name LIKE '%AppCtxManager');
BEGIN
  IF dbms_registry.is_valid('JAVAVM',dbms_registry.release_version) = 1 THEN
    FOR AppCtxClass IN AppCtxClassCur LOOP
      execute immediate 'DROP JAVA CLASS ' ||
                     dbms_assert.enquote_name(AppCtxClass.object_name, FALSE);
    END LOOP;
  END IF;
END;
/

Rem =====================================================================
Rem END: Bug 8687981: drop appctx package
Rem =====================================================================

Rem *************************************************************************
Rem Reload current version of Java Classes
Rem *************************************************************************

@@catjava

Rem *************************************************************************
Rem Bug 22649453 CATJAVA COMP MUST PRINT UPGRADED STATUS AFTER DATABASE UPGRADE
Rem *************************************************************************

begin
  sys.dbms_registry.upgraded('CATJAVA');
  if sys.dbms_registry.count_errors_in_registry('CATJAVA') > 0 then
    sys.dbms_registry.invalid('CATJAVA');
  end if;
end;
/
