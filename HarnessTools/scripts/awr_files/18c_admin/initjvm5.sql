Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: javavm/install/initjvm5.sql
Rem    SQL_SHIPPED_FILE: javavm/install/initjvm5.sql
Rem    SQL_PHASE: INITJVM5
Rem    SQL_STARTUP_MODE: NORMAL
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    END SQL_FILE_METADATA

-- subscript for initjvm.sql and ilk

-- create USER|DBA|ALL_JAVA_* views
@@catjvm.sql

-- SQLJ initialization
@@initsqlj

-- XA JSP initialization
@@initxa

-- Preload these properties as SYS resources, see README in 
-- javavm/lib/logging.properties for details
begin if initjvmaux.startstep('LOAD_PROPS_AS_SYS_RESOURCES') then
  dbms_java.loadjava('-grant PUBLIC javavm/lib/logging.properties');
  dbms_java.loadjava('-grant PUBLIC javavm/lib/calendars.properties');
  dbms_java.loadjava('-grant PUBLIC javavm/lib/hijrah-config-umalqura.properties');
  initjvmaux.endstep;
end if; end;
/

-- Load some stuff that is mostly jars we got from sun
-- These used to be loaded by initjis, but that has gone away
begin if initjvmaux.startstep('LOAD_JIS_JARS') then
  -- noverify is suppressing a warning.
  dbms_java.loadjava('-noverify -resolve -install -synonym -grant PUBLIC lib/activation.jar lib/mail.jar');
  -- need to load this seperately so that resolution will take place
  dbms_java.loadjava('-v -noverify -resolve -install -synonym -grant PUBLIC -resolver ((* SYS) (* PUBLIC) (* -)) lib/http_client.jar');
  initjvmaux.endstep;
end if; end;
/
