Rem
Rem $Header: rdbms/admin/catreplt.sql /main/4 2015/02/22 15:53:06 jorgrive Exp $
Rem
Rem catreplt.sql
Rem
Rem Copyright (c) 2006, 2015, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catreplt.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catreplt.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catreplt.sql
Rem SQL_PHASE: CATREPLT
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catptyps.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    jorgrive    01/22/15 - bug 20400097: remove repcat$_object_null_vector
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    elu         10/23/06 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

Rem ==========================================================================
Rem TYPES
Rem ==========================================================================

-- Define a type which will be used to perfom bitors of raw columns
CREATE OR REPLACE TYPE MVAggRawBitOr_typ AS OBJECT (
 current_bitvec        RAW(255),
 current_bitvec_len    NUMBER,
 
 STATIC FUNCTION odciaggregateinitialize(sctx OUT MVAggRawBitOr_typ)
    RETURN NUMBER,

 MEMBER FUNCTION odciaggregateiterate(self    IN OUT MVAggRawBitOr_typ,
                                      bitvec  IN     RAW)
    RETURN NUMBER,

 MEMBER FUNCTION odciaggregateterminate(self    IN OUT MVAggRawBitOr_typ,
                                        bitvec  OUT    RAW,
                                        flags   IN     NUMBER)
    RETURN NUMBER,

 MEMBER FUNCTION odciaggregatemerge(self     IN OUT MVAggRawBitOr_typ,
                                    agg_obj  IN     MVAggRawBitOr_typ)
    RETURN NUMBER
);
/

CREATE OR REPLACE FUNCTION MVAggRawBitOr(bitvec RAW) RETURN RAW
PARALLEL_ENABLE
AGGREGATE USING MVAggRawBitOr_typ;
/

GRANT EXECUTE ON MVAggRawBitOr TO PUBLIC;
/

@?/rdbms/admin/sqlsessend.sql
