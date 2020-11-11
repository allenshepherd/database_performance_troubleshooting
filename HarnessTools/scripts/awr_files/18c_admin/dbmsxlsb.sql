Rem
Rem $Header: rdbms/admin/dbmsxlsb.sql /main/11 2015/09/08 20:04:02 tojhuan Exp $
Rem
Rem dbmsxlsb.sql
Rem
Rem Copyright (c) 2010, 2015, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbmsxlsb.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/dbmsxlsb.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/dbmsxlsb.sql
Rem SQL_PHASE: DBMSXLSB
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catqm_int.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    tojhuan     09/08/15 - 21618836: signature change for SaveAcl
Rem    tojhuan     09/08/15 - 21608034/21656322: signature change for
Rem                           UpdateContentXob for update of OR res/metadata
Rem    tojhuan     09/08/15 - signature change for InsertToUserHTab for 
Rem                           backward compatibility
Rem    tojhuan     07/30/15 - 21185636: new arg [resoid] for InsertToUserHTab
Rem    tojhuan     03/22/15 - 20529144: xdb.dbms_xlsb.InsertToUserHTab now
Rem                           takes element name rather than element ID
Rem    surman      01/23/14 - 13922626: Update SQL metadata
Rem    yinlu       10/29/13 - bug 17229885: add method InsertToUserHTab
Rem    qyu         03/18/13 - Common start and end scripts
Rem    yinlu       11/13/12 - bug 15865179: add pragma
Rem    yinlu       09/21/12 - bug 14584497: add InsertResourceNXobClob
Rem    yinlu       12/09/11 - change parameter names to match the ones passed
Rem                           to krvplsqlai
Rem    yinlu       10/20/11 - handle qmkmflush
Rem    yinlu       10/05/11 - update updateAclXob to handle resconfig as well
Rem    yinlu       08/03/11 - update SetRefcount to handle RC precommit buffer
Rem                           flush
Rem    yinlu       07/29/11 - remove arg type from InsertRes
Rem    yinlu       07/26/11 - pass type (for qmePreSave) to insertres
Rem    yinlu       07/25/11 - qmxlsbSLInsertHTable
Rem    yinlu       07/15/11 - handle name locks
Rem    yinlu       07/08/11 - handle lock
Rem    yinlu       06/17/11 - saveacl
Rem    yinlu       05/24/11 - add updateresource
Rem    yinlu       05/23/11 - remove arg parent_oid from UnlinkResource
Rem    yinlu       05/23/11 - add src_path to linkresource
Rem    yinlu       05/19/11 - log qmeSetRefcount and qmeQueueTouchHdl
Rem    yinlu       05/17/11 - handle sym and weak link
Rem    yinlu       05/10/11 - handle ref-based resource
Rem    yinlu       05/05/11 - add insertRes for xob-based resource
Rem    yinlu       04/20/11 - update InsertResource w/ more args
Rem    ataracha    12/23/10 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

CREATE OR REPLACE PACKAGE xdb.dbms_xlsb AUTHID CURRENT_USER IS 

PROCEDURE InsertResourceNXob(oid IN RAW, res IN CLOB, 
                             flags IN NUMBER,
                             content IN BLOB);
PRAGMA SUPPLEMENTAL_LOG_DATA(InsertResourceNXob, AUTO);

PROCEDURE InsertResourceNXobClob(oid IN RAW, res IN CLOB, 
                             flags IN NUMBER,
                             content IN CLOB);
PRAGMA SUPPLEMENTAL_LOG_DATA(InsertResourceNXobClob, AUTO);

PROCEDURE InsertResource(oid IN RAW, res IN CLOB, 
                         flags IN NUMBER,
                         content IN CLOB);
PRAGMA SUPPLEMENTAL_LOG_DATA(InsertResource, AUTO);

PROCEDURE InsertResourceRef(oid IN RAW, res IN CLOB, 
                            flags IN NUMBER,
                            content IN RAW);
PRAGMA SUPPLEMENTAL_LOG_DATA(InsertResourceRef, AUTO);

PROCEDURE LinkResource(parent_path IN VARCHAR2, name IN VARCHAR2,
                       child_path IN VARCHAR2, oid IN RAW, 
                       linksn IN RAW, acloid IN RAW, 
                       owner IN VARCHAR2, owner_format IN NUMBER,
                       flags IN NUMBER, types IN NUMBER);
PRAGMA SUPPLEMENTAL_LOG_DATA(LinkResource, AUTO);

PROCEDURE UnlinkResource(parent_path IN VARCHAR2, 
                         name IN VARCHAR2, oid IN RAW, 
                         flags IN NUMBER);
PRAGMA SUPPLEMENTAL_LOG_DATA(UnlinkResource, AUTO);

PROCEDURE DeleteResource(oid IN RAW, flags IN NUMBER);
PRAGMA SUPPLEMENTAL_LOG_DATA(DeleteResource, AUTO);

PROCEDURE SetRefcount(oid IN RAW, refcount IN NUMBER, flags IN NUMBER);
PRAGMA SUPPLEMENTAL_LOG_DATA(SetRefcount, AUTO);

PROCEDURE TouchOid(oid IN RAW, owner IN VARCHAR2, owner_format IN NUMBER,
                   mod_date IN RAW);
PRAGMA SUPPLEMENTAL_LOG_DATA(TouchOid, AUTO);

PROCEDURE UpdateResource(res IN CLOB, 
                         flags IN NUMBER,
                         content IN CLOB, pref IN RAW);
PRAGMA SUPPLEMENTAL_LOG_DATA(UpdateResource, AUTO);

PROCEDURE UpdateResourceRef(res IN CLOB, 
                            flags IN NUMBER,
                            content IN RAW, pref IN RAW);
PRAGMA SUPPLEMENTAL_LOG_DATA(UpdateResourceRef, AUTO);

PROCEDURE UpdateContentXob(content IN CLOB,
                           pref    IN RAW,
                           flags   IN NUMBER, 
                           schema  IN NUMBER,
                           schoid  IN RAW      := NULL, /* 21608034,21656322 */
                           schurl  IN VARCHAR2 := NULL, /* 21608034,21656322 */
                           elname  IN VARCHAR2 := NULL);/* 21608034,21656322 */
PRAGMA SUPPLEMENTAL_LOG_DATA(UpdateContentXob, AUTO);

PROCEDURE SaveAcl(acloid       IN RAW, 
                  resoid       IN RAW,
                  flags        IN NUMBER,
                  schema       IN VARCHAR2,
                  name         IN VARCHAR2,
                  oid          IN RAW,
                  owner        IN VARCHAR2 := NULL,              /* 21618836 */
                  owner_format IN NUMBER   := 0);                /* 21618836 */
PRAGMA SUPPLEMENTAL_LOG_DATA(SaveAcl, AUTO);

PROCEDURE UpdateLocks(oid IN RAW, lock_list IN CLOB, next_seq IN NUMBER,
                      flags IN NUMBER);
PRAGMA SUPPLEMENTAL_LOG_DATA(UpdateLocks, AUTO);

PROCEDURE UpdateNameLocks(oid IN RAW, name IN VARCHAR2, 
                          token IN RAW, flags IN NUMBER);
PRAGMA SUPPLEMENTAL_LOG_DATA(UpdateNameLocks, AUTO);

PROCEDURE DelNameLocks(oid IN RAW, seq IN NUMBER, flags IN NUMBER);
PRAGMA SUPPLEMENTAL_LOG_DATA(DelNameLocks, AUTO);

PROCEDURE InsertToHTable(content IN CLOB, acloid IN RAW,
                         owner IN VARCHAR2, owner_format IN NUMBER,
                         oid IN RAW, flags IN NUMBER, schema IN NUMBER);
PRAGMA SUPPLEMENTAL_LOG_DATA(InsertToHTable, AUTO);

PROCEDURE InsertToUserHTab(content IN CLOB, acloid IN RAW,
                           owner IN VARCHAR2, owner_format IN NUMBER,
                           oid IN RAW, flags IN NUMBER,
                           schoid IN RAW,
                           schema IN VARCHAR2,
                           elnum  IN NUMBER   := 0,    /* backward compatible*/
                           elname IN VARCHAR2 := NULL,           /* 20529144 */
                           resoid IN RAW      := NULL);          /* 21185636 */
PRAGMA SUPPLEMENTAL_LOG_DATA(InsertToUserHTab, AUTO);

PROCEDURE UpdateRootInfo(content IN CLOB);
PRAGMA SUPPLEMENTAL_LOG_DATA(UpdateRootInfo, AUTO);

END dbms_xlsb;
/
show errors;

CREATE OR REPLACE PUBLIC SYNONYM DBMS_XLSB FOR XDB.DBMS_XLSB
/
GRANT EXECUTE ON XDB.DBMS_XLSB TO PUBLIC
/
show errors;


@?/rdbms/admin/sqlsessend.sql
