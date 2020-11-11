Rem
Rem
Rem Copyright (c) 2004, 2016, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem    NAME
Rem      catmact.sql
Rem
Rem    DESCRIPTION
Rem      Create the MACSEC triggers
Rem
Rem    NOTES
Rem      Run as DVSYS
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catmact.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catmact.sql
Rem SQL_PHASE: CATMACT
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catmac.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED (MM/DD/YY)
Rem    jibyun    02/15/16  - Bug 22296366: qualify objects referenced
Rem                          internally
Rem    jibyun    02/04/15  - Bug 20398212: support longer identifier
Rem    aketkar   04/29/14  - sql patch metadata seed
Rem    yanchuan  08/05/13  - Bug 17072781: pass the factor name to
Rem                          create_factor_function
Rem    jsamuel   01/12/09  - move audit statements to catmaca.sql
Rem    youyang   10/21/08  - Remove DDL triggers
Rem    clei      09/03/08  - bug 6435192: trigger driven by enforcement status 
Rem    clei      05/09/08  - bug 7025501
Rem    pyoun     05/25/07  - fix bug 6001677
Rem    rvissapr  12/08/06  - figure correct current user for DV triggers
Rem    clei      12/07/06  - DV no longer needs VPD policies
Rem    jciminsk  05/02/06  - cleanup embedded file boilerplate 
Rem    jciminsk  05/02/06  - created admin/catmact.sql 
Rem    ayalaman  04/03/06  - post DDL trigger for dict maint 
Rem    sgaetjen  02/22/06  - XbranchMerge sgaetjen_dvopt2 from 
Rem                          st_rdbms_10.2audit 
Rem    sgaetjen  02/13/06  - add CREATE VIEW,TABLE,SYN synch logic 
Rem    sgaetjen  01/16/06  - remove commented init_session 
Rem    sgaetjen  01/03/06  - remove login trigger 
Rem    sgaetjen  08/18/05  - Disable triggers until last step in install 
Rem    sgaetjen  08/11/05  - sgaetjen_dvschema
Rem    sgaetjen  08/08/05  - Remove table DML 
Rem    sgaetjen  07/30/05  - separate DVSYS and SYS commands 
Rem    sgaetjen  07/28/05  - dos2unix
Rem    raustin   11/11/04  - Created
Rem
Rem
Rem 
Rem
Rem
Rem    DESCRIPTION
Rem      Creates functions data for DVF account based on factor$ table.
Rem


@@?/rdbms/admin/sqlsessstart.sql

SET SERVEROUT ON SIZE 1000000
DECLARE
    l_exp dvsys.dv$factor.get_expr%TYPE;
    l_name dvsys.dv$factor.name%TYPE;
    l_canon_name dvsys.dv$factor.name%TYPE;
    l_sql VARCHAR2(1000);

BEGIN
    FOR c99 IN (
        SELECT id# , name, get_expr
        FROM dvsys.factor$
        --FROM dvsys.dv$factor
        ) LOOP
        -- WHERE get_expr IS NOT NULL
        l_exp := c99.get_expr;
        l_name := c99.name;

        BEGIN
            -- if invalid factor name,
            -- then no need to create the factor function
            IF (LENGTH(l_name) > 126) THEN
               DVSYS.DBMS_MACUTL.RAISE_ERROR(47951,'factor_name');
            END IF;

            sys.dbms_utility.canonicalize(SYS.DBMS_ASSERT.SIMPLE_SQL_NAME(
                               dvsys.dbms_macutl.to_oracle_identifier(l_name)),
                                      l_canon_name, 126);
            IF (LENGTH(l_canon_name) > 126) THEN
               DVSYS.DBMS_MACUTL.RAISE_ERROR(47951,'factor_name');
            END IF;

            dvf.dbms_macsec_function.create_factor_function(l_name);
        EXCEPTION
            WHEN OTHERS THEN
                sys.dbms_output.put_line ('sddvffnc: factor=' || l_name
                                          || ',error=' || sqlerrm );
        END;

    END LOOP;
END;
/

SET SERVEROUT OFF;


@?/rdbms/admin/sqlsessend.sql

