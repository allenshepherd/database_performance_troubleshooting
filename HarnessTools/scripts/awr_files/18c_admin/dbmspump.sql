Rem
Rem $Header: rdbms/admin/dbmspump.sql /main/16 2017/04/19 10:54:35 bwright Exp $
Rem
Rem dbmspump.sql
Rem
Rem Copyright (c) 2000, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbmspump.sql - DBMS procedures for dataPUMP
Rem
Rem    DESCRIPTION
Rem      objects used by datapump
Rem
Rem    NOTES
Rem      none
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/dbmspump.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/dbmspump.sql
Rem SQL_PHASE: DBMSPUMP
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catpexec.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    bwright     04/03/17 - Bug 25808867: Add FORCE, NOT PERSISTABLE to type
Rem                           definitions
Rem    dvekaria    06/21/16 - 23604553 Fix ORA-22308 in upgrade from pre-12.1
Rem    abrumm      04/01/14 - rename ORACLE_BIGSQL to ORACLE_BIGDATA
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    abrumm      12/18/13 - exadoop: add raw attribute to
Rem                           qxxq[Open,Fetch,Populate,Close]
Rem    jstenois    12/05/13 - add infrastructure for exadoop
Rem    achaudhr    11/22/13 - 17793123: Make oracle_loader deterministic
Rem                           to enable RC
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    jstenois    03/08/12 - 13725431: use different duration for self context
Rem    jstenois    04/20/11 - 5560282: fix memory leak and use NOCOPY
Rem    msakayed    05/29/08 - Remove exec grants on sys.oracle_loader/datapump
Rem    msakayed    04/25/07 - Bug #5119713: Memleak - use "LANGUAGE C" callspec
Rem    hsbedi      07/30/02 - 
Rem    hsbedi      06/29/02 - External table populate
Rem    abrumm      02/05/01 - add 'AUTHID CURRENT_USER' clause
Rem    rphillip    02/08/01 - support DPAPI stream versions
Rem    abrumm      10/11/00 - use ODCIColInfoList2
Rem    jstenois    08/30/00 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

rem create type for external tables

-- CREATE EXTERNAL TABLE IMPLEMENTATION TYPE   (SYS.ORACLE_LOADER)
CREATE OR REPLACE TYPE sys.oracle_loader FORCE AUTHID CURRENT_USER AS OBJECT 
(
  xtctx  RAW(4),
  STATIC FUNCTION ODCIGetInterfaces(ifclist OUT NOCOPY SYS.ODCIObjectList)
         RETURN NUMBER DETERMINISTIC,

  STATIC FUNCTION ODCIExtTableOpen(lctx   IN OUT NOCOPY oracle_loader,
                                   xti    IN            SYS.ODCIExtTableInfo,
                                   xri       OUT NOCOPY SYS.ODCIExtTableQCInfo,
                                   pcl       OUT NOCOPY SYS.ODCIColInfoList2,
                                   flag   IN OUT        number,
                                   strv   IN OUT        number,
                                   env    IN            SYS.ODCIEnv,
                                   xtArgs IN OUT        raw)
         RETURN number DETERMINISTIC,

-- Fetch data for the given granule.  Note that cnverr is the number
-- of conversion errors that occurred while fetching and converting rows
-- for the current granule, gnum is the current granule number.

  MEMBER FUNCTION ODCIExtTableFetch(gnum   IN     number,
                                    cnverr IN OUT number,
                                    flag   IN OUT number,
                                    env    IN     SYS.ODCIEnv,
                                    xtArgs IN OUT raw)
         RETURN number DETERMINISTIC,

  MEMBER FUNCTION ODCIExtTablePopulate(flag   IN OUT number,
                                       env    IN     SYS.ODCIEnv,
                                       xtArgs IN OUT raw)
         RETURN number DETERMINISTIC,

  MEMBER FUNCTION ODCIExtTableClose(flag   IN OUT number,
                                    env    IN     SYS.ODCIEnv,
                                    xtArgs IN OUT raw)
         RETURN number DETERMINISTIC
) NOT PERSISTABLE;
/

-- CREATE EXTERNAL TABLE IMPLEMENTATION TYPE   (SYS.ORACLE_DATAPUMP)
CREATE OR REPLACE TYPE sys.oracle_datapump FORCE AUTHID CURRENT_USER AS OBJECT
(
  xtctx  RAW(4),
  STATIC FUNCTION ODCIGetInterfaces(ifclist OUT NOCOPY SYS.ODCIObjectList)
         RETURN NUMBER,

  STATIC FUNCTION ODCIExtTableOpen(lctx   IN OUT NOCOPY oracle_datapump,
                                   xti    IN            SYS.ODCIExtTableInfo,
                                   xri       OUT NOCOPY SYS.ODCIExtTableQCInfo,
                                   pcl       OUT NOCOPY SYS.ODCIColInfoList2,
                                   flag   IN OUT        number,
                                   strv   IN OUT        number,
                                   env    IN            SYS.ODCIEnv,
                                   xtArgs IN OUT        raw)
         RETURN number,

-- Fetch data for the given granule.  Note that cnverr is the number
-- of conversion errors that occurred while fetching and converting rows
-- for the current granule, gnum is the current granule number.

  MEMBER FUNCTION ODCIExtTableFetch(gnum   IN     number,
                                    cnverr IN OUT number,
                                    flag   IN OUT number,
                                    env    IN     SYS.ODCIEnv,
                                    xtArgs IN OUT raw)
         RETURN number,
  MEMBER FUNCTION ODCIExtTablePopulate(flag   IN OUT number,
                                       env    IN     SYS.ODCIEnv,
                                       xtArgs IN OUT raw)
         RETURN number,

  MEMBER FUNCTION ODCIExtTableClose(flag   IN OUT number,
                                    env    IN     SYS.ODCIEnv,
                                    xtArgs IN OUT raw)
         RETURN number
) NOT PERSISTABLE;
/

-- CREATE EXTERNAL TABLE IMPLEMENTATION TYPE   (SYS.ORACLE_HIVE)
CREATE OR REPLACE TYPE sys.oracle_hive FORCE AUTHID CURRENT_USER AS OBJECT
(
  xtctx  RAW(4),
  STATIC FUNCTION ODCIGetInterfaces(ifclist OUT NOCOPY SYS.ODCIObjectList)
         RETURN NUMBER DETERMINISTIC,

  STATIC FUNCTION ODCIExtTableOpen(lctx   IN OUT NOCOPY oracle_hive,
                                   xti    IN            SYS.ODCIExtTableInfo,
                                   xri       OUT NOCOPY SYS.ODCIExtTableQCInfo,
                                   pcl       OUT NOCOPY SYS.ODCIColInfoList2,
                                   flag   IN OUT        number,
                                   strv   IN OUT        number,
                                   env    IN            SYS.ODCIEnv,
                                   xtArgs IN OUT        raw)
         RETURN number DETERMINISTIC,

-- Fetch data for the given granule.  Note that cnverr is the number
-- of conversion errors that occurred while fetching and converting rows
-- for the current granule, gnum is the current granule number.

  MEMBER FUNCTION ODCIExtTableFetch(gnum   IN     number,
                                    cnverr IN OUT number,
                                    flag   IN OUT number,
                                    env    IN     SYS.ODCIEnv,
                                    xtArgs IN OUT raw)
         RETURN number DETERMINISTIC,

  MEMBER FUNCTION ODCIExtTablePopulate(flag   IN OUT number,
                                       env    IN     SYS.ODCIEnv,
                                       xtArgs IN OUT raw)
         RETURN number DETERMINISTIC,

  MEMBER FUNCTION ODCIExtTableClose(flag   IN OUT number,
                                    env    IN     SYS.ODCIEnv,
                                    xtArgs IN OUT raw)
         RETURN number DETERMINISTIC
) NOT PERSISTABLE;
/


-- CREATE EXTERNAL TABLE IMPLEMENTATION TYPE   (SYS.ORACLE_HDFS)
CREATE OR REPLACE TYPE sys.oracle_hdfs FORCE AUTHID CURRENT_USER AS OBJECT
(
  xtctx  RAW(4),
  STATIC FUNCTION ODCIGetInterfaces(ifclist OUT NOCOPY SYS.ODCIObjectList)
         RETURN NUMBER DETERMINISTIC,

  STATIC FUNCTION ODCIExtTableOpen(lctx   IN OUT NOCOPY oracle_hdfs,
                                   xti    IN            SYS.ODCIExtTableInfo,
                                   xri       OUT NOCOPY SYS.ODCIExtTableQCInfo,
                                   pcl       OUT NOCOPY SYS.ODCIColInfoList2,
                                   flag   IN OUT        number,
                                   strv   IN OUT        number,
                                   env    IN            SYS.ODCIEnv,
                                   xtArgs IN OUT       raw)
         RETURN number DETERMINISTIC,

-- Fetch data for the given granule.  Note that cnverr is the number
-- of conversion errors that occurred while fetching and converting rows
-- for the current granule, gnum is the current granule number.

  MEMBER FUNCTION ODCIExtTableFetch(gnum   IN     number,
                                    cnverr IN OUT number,
                                    flag   IN OUT number,
                                    env    IN     SYS.ODCIEnv,
                                    xtArgs IN OUT raw)
         RETURN number DETERMINISTIC,

  MEMBER FUNCTION ODCIExtTablePopulate(flag   IN OUT number,
                                       env    IN     SYS.ODCIEnv,
                                       xtArgs IN OUT raw)
         RETURN number DETERMINISTIC,

  MEMBER FUNCTION ODCIExtTableClose(flag IN OUT number,
                                    env    IN     SYS.ODCIEnv,
                                    xtArgs IN OUT raw)
         RETURN number DETERMINISTIC
) NOT PERSISTABLE;
/


-- CREATE EXTERNAL TABLE IMPLEMENTATION TYPE   (SYS.ORACLE_BIGDATA)
CREATE OR REPLACE TYPE sys.oracle_bigdata FORCE AUTHID CURRENT_USER AS OBJECT
(
  xtctx  RAW(4),
  STATIC FUNCTION ODCIGetInterfaces(ifclist OUT NOCOPY SYS.ODCIObjectList)
         RETURN NUMBER DETERMINISTIC,

  STATIC FUNCTION ODCIExtTableOpen(lctx   IN OUT NOCOPY oracle_bigdata,
                                   xti    IN            SYS.ODCIExtTableInfo,
                                   xri       OUT NOCOPY SYS.ODCIExtTableQCInfo,
                                   pcl       OUT NOCOPY SYS.ODCIColInfoList2,
                                   flag   IN OUT        number,
                                   strv   IN OUT        number,
                                   env    IN            SYS.ODCIEnv,
                                   xtArgs IN OUT        raw)
         RETURN number DETERMINISTIC,

-- Fetch data for the given granule.  Note that cnverr is the number
-- of conversion errors that occurred while fetching and converting rows
-- for the current granule, gnum is the current granule number.

  MEMBER FUNCTION ODCIExtTableFetch(gnum   IN     number,
                                    cnverr IN OUT number,
                                    flag   IN OUT number,
                                    env    IN     SYS.ODCIEnv,
                                    xtArgs IN OUT raw)
         RETURN number DETERMINISTIC,

  MEMBER FUNCTION ODCIExtTablePopulate(flag   IN OUT number,
                                       env    IN     SYS.ODCIEnv,
                                       xtArgs IN OUT raw)
         RETURN number DETERMINISTIC,

  MEMBER FUNCTION ODCIExtTableClose(flag   IN OUT number,
                                    env    IN     SYS.ODCIEnv,
                                    xtArgs IN OUT raw)
         RETURN number DETERMINISTIC
) NOT PERSISTABLE;
/


---------------------------------
--  CREATE IMPLEMENTATION UNIT --
---------------------------------
-- CREATE LIBRARY
CREATE OR REPLACE LIBRARY QXXQLIB TRUSTED AS STATIC;
/

-- CREATE TYPE BODY
CREATE OR REPLACE TYPE BODY sys.oracle_loader
IS
--
-- ODCIGetInterfaces - returns supported interface and stream version.
--
  STATIC FUNCTION ODCIGETINTERFACES(ifclist OUT NOCOPY SYS.ODCIOBJECTLIST) 
       RETURN NUMBER DETERMINISTIC IS
  BEGIN
      ifclist := SYS.ODCIOBJECTLIST
                        (
                          SYS.ODCIOBJECT('SYS','ODCIEXTTABLE1'),
                          SYS.ODCIOBJECT('SYS','ODCIEXTTABLE_STREAM1')
                        );
      RETURN ODCICONST.SUCCESS;
  END ODCIGETINTERFACES;
--
-- ODCIExtTableOpen
--
  STATIC FUNCTION ODCIEXTTABLEOPEN(LCTX IN OUT NOCOPY oracle_loader,
                                   xti    IN            SYS.ODCIEXTTABLEINFO,
                                   xri       OUT NOCOPY SYS.ODCIEXTTABLEQCINFO,
                                   pcl       OUT NOCOPY SYS.ODCICOLINFOLIST2,
                                   flag   IN OUT        NUMBER,
                                   strv   IN OUT        NUMBER,
                                   env    IN            SYS.ODCIENV,
                                   xtArgs IN OUT        RAW)
    RETURN NUMBER DETERMINISTIC AS LANGUAGE C
    NAME "QXXQ_OPEN"
    LIBRARY QXXQLIB     
    WITH CONTEXT
    PARAMETERS
    (
      CONTEXT,
      lctx,
      lctx   INDICATOR STRUCT,
      lctx   duration,
      xti,
      xti    INDICATOR STRUCT,
      xri,
      xri    INDICATOR STRUCT,
      pcl,
      pcl    INDICATOR,
      flag,
      flag   INDICATOR,
      strv,
      strv   INDICATOR,
      env,
      env    INDICATOR STRUCT,
      xtArgs, xtArgs INDICATOR, xtArgs LENGTH,
      RETURN OCINUMBER
    );
--
-- ODCIExtTableFetch
--
  MEMBER FUNCTION ODCIEXTTABLEFETCH(gnum     IN     NUMBER,
                                    cnverr   IN OUT NUMBER,
                                    flag     IN OUT NUMBER,
                                    env      IN     SYS.ODCIENV,
                                    xtArgs   IN OUT RAW)
    RETURN NUMBER DETERMINISTIC AS LANGUAGE C
    NAME "QXXQ_FETCH"
    LIBRARY QXXQLIB
    WITH CONTEXT
    PARAMETERS
    (
      CONTEXT,
      SELF,
      SELF   INDICATOR STRUCT,
      gnum,
      gnum   INDICATOR,
      cnverr,
      cnverr INDICATOR,
      flag,
      flag   INDICATOR,
      env,
      env    INDICATOR STRUCT,
      xtArgs, xtArgs INDICATOR, xtArgs LENGTH,
      RETURN OCINUMBER
    );
--
-- ODCIExtTablePopulate
--
  MEMBER FUNCTION ODCIEXTTABLEPOPULATE(flag   IN OUT NUMBER,
                                       env    IN     SYS.ODCIENV,
                                       xtArgs IN OUT RAW)
    RETURN NUMBER DETERMINISTIC AS LANGUAGE C
    NAME "QXXQ_POPULATE"
    LIBRARY QXXQLIB
    WITH CONTEXT
    PARAMETERS
    (
      CONTEXT,
      SELF,
      SELF   INDICATOR STRUCT,
      flag,
      flag   INDICATOR,
      env,
      env    INDICATOR STRUCT,
      xtArgs, xtArgs INDICATOR, xtArgs LENGTH,
      RETURN OCINUMBER
    );
--
-- ODCIExtTableClose
--
  MEMBER FUNCTION ODCIEXTTABLECLOSE(flag   IN OUT NUMBER,
                                    env    IN     SYS.ODCIENV,
                                    xtArgs IN OUT RAW)
    RETURN NUMBER DETERMINISTIC AS LANGUAGE C
    NAME "QXXQ_CLOSE"
    LIBRARY QXXQLIB
    WITH CONTEXT
    PARAMETERS
    (
      CONTEXT,
      SELF,
      SELF   INDICATOR STRUCT,
      flag,
      flag   INDICATOR,
      env,
      env    INDICATOR STRUCT,
      xtArgs, xtArgs INDICATOR, xtArgs LENGTH,
      RETURN OCINUMBER
    );
END;
/

-- CREATE TYPE BODY
CREATE OR REPLACE TYPE BODY sys.oracle_datapump
IS
--
-- ODCIGetInterfaces - returns supported interface and stream version.
--
  STATIC FUNCTION ODCIGETINTERFACES(ifclist OUT NOCOPY SYS.ODCIOBJECTLIST)
       RETURN NUMBER IS
  BEGIN
      ifclist := SYS.ODCIOBJECTLIST
                        (
                          SYS.ODCIOBJECT('SYS','ODCIEXTTABLE1'),
                          SYS.ODCIOBJECT('SYS','ODCIEXTTABLE_STREAM1')
                        );
      RETURN ODCICONST.SUCCESS;
  END ODCIGETINTERFACES;
--
-- ODCIExtTableOpen
--
  STATIC FUNCTION ODCIEXTTABLEOPEN(LCTX IN OUT NOCOPY oracle_datapump,
                                   xti    IN            SYS.ODCIEXTTABLEINFO,
                                   xri       OUT NOCOPY SYS.ODCIEXTTABLEQCINFO,
                                   pcl       OUT NOCOPY SYS.ODCICOLINFOLIST2,
                                   flag   IN OUT NUMBER,
                                   strv   IN OUT NUMBER,
                                   env    IN     SYS.ODCIENV,
                                   xtArgs IN OUT RAW)
    RETURN NUMBER AS LANGUAGE C
    NAME "QXXQ_OPEN"
    LIBRARY QXXQLIB
    WITH CONTEXT
    PARAMETERS
    (
      CONTEXT,
      lctx,
      lctx   INDICATOR STRUCT,
      lctx   duration,
      xti,
      xti    INDICATOR STRUCT,
      xri,
      xri    INDICATOR STRUCT,
      pcl,
      pcl    INDICATOR,
      flag,
      flag   INDICATOR,
      strv,
      strv   INDICATOR,
      env,
      env    INDICATOR STRUCT,
      xtArgs, xtArgs INDICATOR, xtArgs LENGTH,
      RETURN OCINUMBER
    );
--
-- ODCIExtTableFetch
--
  MEMBER FUNCTION ODCIEXTTABLEFETCH(gnum   IN     NUMBER,
                                    cnverr IN OUT NUMBER,
                                    flag   IN OUT NUMBER,
                                    env    IN     SYS.ODCIENV,
                                    xtArgs IN OUT RAW)
    RETURN NUMBER AS LANGUAGE C
    NAME "QXXQ_FETCH"
    LIBRARY QXXQLIB
    WITH CONTEXT
    PARAMETERS
    (
      CONTEXT,
      SELF,
      SELF   INDICATOR STRUCT,
      gnum,
      gnum   INDICATOR,
      cnverr,
      cnverr INDICATOR,
      flag,
      flag   INDICATOR,
      env,
      env    INDICATOR STRUCT,
      xtArgs, xtArgs INDICATOR, xtArgs LENGTH,
      RETURN OCINUMBER
    );
--
-- ODCIExtTablePopulate
--
  MEMBER FUNCTION ODCIEXTTABLEPOPULATE(flag   IN OUT NUMBER,
                                       env    IN     SYS.ODCIENV,
                                       xtArgs IN OUT RAW)
    RETURN NUMBER AS LANGUAGE C
    NAME "QXXQ_POPULATE"
    LIBRARY QXXQLIB
    WITH CONTEXT
    PARAMETERS
    (
      CONTEXT,
      SELF,
      SELF   INDICATOR STRUCT,
      flag,
      flag   INDICATOR,
      env,
      env    INDICATOR STRUCT,
      xtArgs, xtArgs INDICATOR, xtArgs LENGTH,
      RETURN OCINUMBER
    );

--
-- ODCIExtTableClose
--
  MEMBER FUNCTION ODCIEXTTABLECLOSE(flag   IN OUT NUMBER,
                                    env    IN     SYS.ODCIENV,
                                    xtArgs IN OUT RAW)
    RETURN NUMBER AS LANGUAGE C
    NAME "QXXQ_CLOSE"
    LIBRARY QXXQLIB
    WITH CONTEXT
    PARAMETERS
    (
      CONTEXT,
      SELF,
      SELF   INDICATOR STRUCT,
      flag,
      flag   INDICATOR,
      env,
      env    INDICATOR STRUCT,
      xtArgs, xtArgs INDICATOR, xtArgs LENGTH,
      RETURN OCINUMBER
    );
END;
/

-- CREATE TYPE BODY
CREATE OR REPLACE TYPE BODY sys.oracle_hive
IS
--
-- ODCIGetInterfaces - returns supported interface and stream version.
--
  STATIC FUNCTION ODCIGETINTERFACES(ifclist OUT NOCOPY SYS.ODCIOBJECTLIST) 
       RETURN NUMBER DETERMINISTIC IS
  BEGIN
      ifclist := SYS.ODCIOBJECTLIST
                        (
                          SYS.ODCIOBJECT('SYS','ODCIEXTTABLE1'),
                          SYS.ODCIOBJECT('SYS','ODCIEXTTABLE_STREAM1')
                        );
      RETURN ODCICONST.SUCCESS;
  END ODCIGETINTERFACES;
--
-- ODCIExtTableOpen
--
  STATIC FUNCTION ODCIEXTTABLEOPEN(LCTX   IN OUT NOCOPY oracle_hive,
                                   xti    IN            SYS.ODCIEXTTABLEINFO,
                                   xri       OUT NOCOPY SYS.ODCIEXTTABLEQCINFO,
                                   pcl       OUT NOCOPY SYS.ODCICOLINFOLIST2,
                                   flag   IN OUT        NUMBER,
                                   strv   IN OUT        NUMBER,
                                   env    IN            SYS.ODCIENV,
                                   xtArgs IN OUT        RAW)
    RETURN NUMBER DETERMINISTIC AS LANGUAGE C
    NAME "QXXQ_OPEN"
    LIBRARY QXXQLIB     
    WITH CONTEXT
    PARAMETERS
    (
      CONTEXT,
      lctx,
      lctx   INDICATOR STRUCT,
      lctx   duration,
      xti,
      xti    INDICATOR STRUCT,
      xri,
      xri    INDICATOR STRUCT,
      pcl,
      pcl    INDICATOR,
      flag,
      flag   INDICATOR,
      strv,
      strv   INDICATOR,
      env,
      env    INDICATOR STRUCT,
      xtArgs, xtArgs INDICATOR, xtArgs LENGTH,
      RETURN OCINUMBER
    );
--
-- ODCIExtTableFetch
--
  MEMBER FUNCTION ODCIEXTTABLEFETCH(gnum     IN     NUMBER,
                                    cnverr   IN OUT NUMBER,
                                    flag     IN OUT NUMBER,
                                    env      IN     SYS.ODCIENV,
                                    xtArgs   IN OUT RAW)
    RETURN NUMBER DETERMINISTIC AS LANGUAGE C
    NAME "QXXQ_FETCH"
    LIBRARY QXXQLIB
    WITH CONTEXT
    PARAMETERS
    (
      CONTEXT,
      SELF,
      SELF   INDICATOR STRUCT,
      gnum,
      gnum   INDICATOR,
      cnverr,
      cnverr INDICATOR,
      flag,
      flag   INDICATOR,
      env,
      env    INDICATOR STRUCT,
      xtArgs, xtArgs INDICATOR, xtArgs LENGTH,
      RETURN OCINUMBER
    );
--
-- ODCIExtTablePopulate
--
  MEMBER FUNCTION ODCIEXTTABLEPOPULATE(flag   IN OUT NUMBER,
                                       env    IN     SYS.ODCIENV,
                                       xtArgs IN OUT        RAW)
    RETURN NUMBER DETERMINISTIC AS LANGUAGE C
    NAME "QXXQ_POPULATE"
    LIBRARY QXXQLIB
    WITH CONTEXT
    PARAMETERS
    (
      CONTEXT,
      SELF,
      SELF   INDICATOR STRUCT,
      flag,
      flag   INDICATOR,
      env,
      env    INDICATOR STRUCT,
      xtArgs, xtArgs INDICATOR, xtArgs LENGTH,
      RETURN OCINUMBER
    );
--
-- ODCIExtTableClose
--
  MEMBER FUNCTION ODCIEXTTABLECLOSE(flag   IN OUT NUMBER,
                                    env    IN     SYS.ODCIENV,
                                    xtArgs IN OUT        RAW)
    RETURN NUMBER DETERMINISTIC AS LANGUAGE C
    NAME "QXXQ_CLOSE"
    LIBRARY QXXQLIB
    WITH CONTEXT
    PARAMETERS
    (
      CONTEXT,
      SELF,
      SELF   INDICATOR STRUCT,
      flag,
      flag   INDICATOR,
      env,
      env    INDICATOR STRUCT,
      xtArgs, xtArgs INDICATOR, xtArgs LENGTH,
      RETURN OCINUMBER
    );
END;
/

-- CREATE TYPE BODY
CREATE OR REPLACE TYPE BODY sys.oracle_hdfs
IS
--
-- ODCIGetInterfaces - returns supported interface and stream version.
--
  STATIC FUNCTION ODCIGETINTERFACES(ifclist OUT NOCOPY SYS.ODCIOBJECTLIST) 
       RETURN NUMBER DETERMINISTIC IS
  BEGIN
      ifclist := SYS.ODCIOBJECTLIST
                        (
                          SYS.ODCIOBJECT('SYS','ODCIEXTTABLE1'),
                          SYS.ODCIOBJECT('SYS','ODCIEXTTABLE_STREAM1')
                        );
      RETURN ODCICONST.SUCCESS;
  END ODCIGETINTERFACES;
--
-- ODCIExtTableOpen
--
  STATIC FUNCTION ODCIEXTTABLEOPEN(LCTX IN OUT NOCOPY oracle_hdfs,
                                   xti    IN          SYS.ODCIEXTTABLEINFO,
                                   xri    OUT NOCOPY  SYS.ODCIEXTTABLEQCINFO,
                                   pcl    OUT NOCOPY  SYS.ODCICOLINFOLIST2,
                                   flag   IN  OUT     NUMBER,
                                   strv   IN  OUT     NUMBER,
                                   env    IN          SYS.ODCIENV,
                                   xtArgs IN  OUT     RAW)
    RETURN NUMBER DETERMINISTIC AS LANGUAGE C
    NAME "QXXQ_OPEN"
    LIBRARY QXXQLIB     
    WITH CONTEXT
    PARAMETERS
    (
      CONTEXT,
      lctx,
      lctx   INDICATOR STRUCT,
      lctx   duration,
      xti,
      xti    INDICATOR STRUCT,
      xri,
      xri    INDICATOR STRUCT,
      pcl,
      pcl    INDICATOR,
      flag,
      flag   INDICATOR,
      strv,
      strv   INDICATOR,
      env,
      env    INDICATOR STRUCT,
      xtArgs, xtArgs INDICATOR, xtArgs LENGTH,
      RETURN OCINUMBER
    );
--
-- ODCIExtTableFetch
--
  MEMBER FUNCTION ODCIEXTTABLEFETCH(gnum     IN     NUMBER,
                                    cnverr   IN OUT NUMBER,
                                    flag     IN OUT NUMBER,
                                    env      IN     SYS.ODCIENV,
                                    xtArgs   IN OUT RAW)
    RETURN NUMBER DETERMINISTIC AS LANGUAGE C
    NAME "QXXQ_FETCH"
    LIBRARY QXXQLIB
    WITH CONTEXT
    PARAMETERS
    (
      CONTEXT,
      SELF,
      SELF   INDICATOR STRUCT,
      gnum,
      gnum   INDICATOR,
      cnverr,
      cnverr INDICATOR,
      flag,
      flag   INDICATOR,
      env,
      env    INDICATOR STRUCT,
      xtArgs, xtArgs INDICATOR, xtArgs LENGTH,
      RETURN OCINUMBER
    );
--
-- ODCIExtTablePopulate
--
  MEMBER FUNCTION ODCIEXTTABLEPOPULATE(flag   IN OUT NUMBER,
                                       env    IN     SYS.ODCIENV,
                                       xtArgs IN OUT        RAW)
    RETURN NUMBER DETERMINISTIC AS LANGUAGE C
    NAME "QXXQ_POPULATE"
    LIBRARY QXXQLIB
    WITH CONTEXT
    PARAMETERS
    (
      CONTEXT,
      SELF,
      SELF   INDICATOR STRUCT,
      flag,
      flag   INDICATOR,
      env,
      env    INDICATOR STRUCT,
      xtArgs, xtArgs INDICATOR, xtArgs LENGTH,
      RETURN OCINUMBER
    );
--
-- ODCIExtTableClose
--
  MEMBER FUNCTION ODCIEXTTABLECLOSE(flag   IN OUT NUMBER,
                                    env    IN     SYS.ODCIENV,
                                    xtArgs IN OUT        RAW)
    RETURN NUMBER DETERMINISTIC AS LANGUAGE C
    NAME "QXXQ_CLOSE"
    LIBRARY QXXQLIB
    WITH CONTEXT
    PARAMETERS
    (
      CONTEXT,
      SELF,
      SELF   INDICATOR STRUCT,
      flag,
      flag   INDICATOR,
      env,
      env    INDICATOR STRUCT,
      xtArgs, xtArgs INDICATOR, xtArgs LENGTH,
      RETURN OCINUMBER
    );
END;
/

-- CREATE TYPE BODY
CREATE OR REPLACE TYPE BODY sys.oracle_bigdata
IS
--
-- ODCIGetInterfaces - returns supported interface and stream version.
--
  STATIC FUNCTION ODCIGETINTERFACES(ifclist OUT NOCOPY SYS.ODCIOBJECTLIST) 
       RETURN NUMBER DETERMINISTIC IS
  BEGIN
      ifclist := SYS.ODCIOBJECTLIST
                        (
                          SYS.ODCIOBJECT('SYS','ODCIEXTTABLE1'),
                          SYS.ODCIOBJECT('SYS','ODCIEXTTABLE_STREAM1')
                        );
      RETURN ODCICONST.SUCCESS;
  END ODCIGETINTERFACES;
--
-- ODCIExtTableOpen
--
  STATIC FUNCTION ODCIEXTTABLEOPEN(LCTX IN OUT NOCOPY oracle_bigdata,
                                   xti    IN            SYS.ODCIEXTTABLEINFO,
                                   xri       OUT NOCOPY SYS.ODCIEXTTABLEQCINFO,
                                   pcl       OUT NOCOPY SYS.ODCICOLINFOLIST2,
                                   flag   IN OUT        NUMBER,
                                   strv   IN OUT        NUMBER,
                                   env    IN            SYS.ODCIENV,
                                   xtArgs IN OUT        RAW)
    RETURN NUMBER DETERMINISTIC AS LANGUAGE C
    NAME "QXXQ_OPEN"
    LIBRARY QXXQLIB     
    WITH CONTEXT
    PARAMETERS
    (
      CONTEXT,
      lctx,
      lctx   INDICATOR STRUCT,
      lctx   duration,
      xti,
      xti    INDICATOR STRUCT,
      xri,
      xri    INDICATOR STRUCT,
      pcl,
      pcl    INDICATOR,
      flag,
      flag   INDICATOR,
      strv,
      strv   INDICATOR,
      env,
      env    INDICATOR STRUCT,
      xtArgs, xtArgs INDICATOR, xtArgs LENGTH,
      RETURN OCINUMBER
    );
--
-- ODCIExtTableFetch
--
  MEMBER FUNCTION ODCIEXTTABLEFETCH(gnum     IN     NUMBER,
                                    cnverr   IN OUT NUMBER,
                                    flag     IN OUT NUMBER,
                                    env      IN     SYS.ODCIENV,
                                    xtArgs   IN OUT RAW)
    RETURN NUMBER DETERMINISTIC AS LANGUAGE C
    NAME "QXXQ_FETCH"
    LIBRARY QXXQLIB
    WITH CONTEXT
    PARAMETERS
    (
      CONTEXT,
      SELF,
      SELF   INDICATOR STRUCT,
      gnum,
      gnum   INDICATOR,
      cnverr,
      cnverr INDICATOR,
      flag,
      flag   INDICATOR,
      env,
      env    INDICATOR STRUCT,
      xtArgs, xtArgs INDICATOR, xtArgs LENGTH,
      RETURN OCINUMBER
    );
--
-- ODCIExtTablePopulate
--
  MEMBER FUNCTION ODCIEXTTABLEPOPULATE(flag   IN OUT NUMBER,
                                       env    IN     SYS.ODCIENV,
                                       xtArgs IN OUT        RAW)
    RETURN NUMBER DETERMINISTIC AS LANGUAGE C
    NAME "QXXQ_POPULATE"
    LIBRARY QXXQLIB
    WITH CONTEXT
    PARAMETERS
    (
      CONTEXT,
      SELF,
      SELF   INDICATOR STRUCT,
      flag,
      flag   INDICATOR,
      env,
      env    INDICATOR STRUCT,
      xtArgs, xtArgs INDICATOR, xtArgs LENGTH,
      RETURN OCINUMBER
    );
--
-- ODCIExtTableClose
--
  MEMBER FUNCTION ODCIEXTTABLECLOSE(flag   IN OUT NUMBER,
                                    env    IN     SYS.ODCIENV,
                                    xtArgs IN OUT        RAW)
    RETURN NUMBER DETERMINISTIC AS LANGUAGE C
    NAME "QXXQ_CLOSE"
    LIBRARY QXXQLIB
    WITH CONTEXT
    PARAMETERS
    (
      CONTEXT,
      SELF,
      SELF   INDICATOR STRUCT,
      flag,
      flag   INDICATOR,
      env,
      env    INDICATOR STRUCT,
      xtArgs, xtArgs INDICATOR, xtArgs LENGTH,
      RETURN OCINUMBER
    );
END;
/




@?/rdbms/admin/sqlsessend.sql
