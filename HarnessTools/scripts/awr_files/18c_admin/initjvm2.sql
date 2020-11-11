Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: javavm/install/initjvm2.sql
Rem    SQL_SHIPPED_FILE: javavm/install/initjvm2.sql
Rem    SQL_PHASE: INITJVM2
Rem    SQL_STARTUP_MODE: NORMAL
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    END SQL_FILE_METADATA

-- subscript for initjvm.sql and ilk

-- Java Sanity check for installation
-- If the following query returns 0, then the Java installation
-- did not succeed
select count(*) from all_objects where object_type like 'JAVA%';

-- Define package dbms_java
@@initdbj

