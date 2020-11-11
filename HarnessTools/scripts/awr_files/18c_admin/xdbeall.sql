Rem
Rem $Header: rdbms/admin/xdbeall.sql /main/2 2017/05/28 22:45:59 stanaya Exp $
Rem
Rem xdbeall.sql
Rem
Rem Copyright (c) 2004, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      xdbeall.sql - common downgrade actions before every downgrade
Rem
Rem    DESCRIPTION
Rem      There are some actions which need to be done before every downgrade,
Rem      just like every actions before upgrade. These actions are done by
Rem      xdbdbmig.sql in upgrade and xdbeall.sql in downgrade.
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/xdbeall.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/xdbeall.sql
Rem    SQL_PHASE: DOWNGRADE
Rem    SQL_STARTUP_MODE: UPGRADE
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    END SQL_FILE_METADATA
Rem    
Rem    MODIFIED   (MM/DD/YY)
Rem    spannala    10/05/04 - spannala_bug-3897563
Rem    spannala    09/27/04 - Created
Rem

-- drop the functional index on resource table. Fix for LRG#1739351
disassociate statistics from indextypes xdb.xdbhi_idxtyp force;
disassociate statistics from packages xdb.xdb_funcimpl force;
drop index xdb.xdbhi_idx;
