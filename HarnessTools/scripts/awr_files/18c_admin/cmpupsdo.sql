Rem
Rem $Header: rdbms/admin/cmpupsdo.sql /main/4 2017/04/11 17:07:31 welin Exp $
Rem
Rem cmpupsdo.sql
Rem
Rem Copyright (c) 2006, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      cmpupsdo.sql - CoMPonent UPgrade sdo components
Rem
Rem    DESCRIPTION
Rem      Upgrade Spatial
Rem
Rem    NOTES
Rem      
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/cmpupsdo.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/cmpupsdo.sql
Rem SQL_PHASE: UPGRADE
Rem SQL_STARTUP_MODE: UPGRADE
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/cmpupgrd.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    welin       03/23/17 - Bug 25790099: Add SQL_METADATA
Rem    raeburns    12/20/14 - enable SDO parallel upgrade
Rem    jerrede     06/17/13 - Fix Error Logging
Rem    jerrede     04/13/13 - Move Spatial to its own
Rem                           component file to assure it was run by
Rem                           itself during an CDB upgrade.
Rem    jerrede     04/13/13 - Created
Rem

Rem =========================================================================
Rem Exit immediately if there are errors in the initial checks
Rem =========================================================================

Rem Setup component script filename variables
COLUMN dbmig_name NEW_VALUE dbmig_file NOPRINT;

set serveroutput off

Rem First check if SDO is not loaded and if an XE database
Rem where the MDSYS schema exists.
Rem If all these are true, then call locdbmig.sql
Rem to invoke locator upgrade script
VARIABLE loc_name VARCHAR2(30);
DECLARE
   p_name VARCHAR(128);
   p_edition VARCHAR2 (128);
BEGIN
   :loc_name := '@nothing.sql';
   IF dbms_registry.is_loaded('SDO') IS NOT NULL THEN
       NULL;  -- Loaded already just fall through and execute nothing.sql
   ELSE
       EXECUTE IMMEDIATE
          'SELECT edition FROM registry$ WHERE cid=''CATPROC'''
       INTO p_edition;

      IF p_edition = 'XE' THEN 
         BEGIN  -- is XE, check for MDSYS schema
            SELECT name INTO p_name FROM user$ WHERE name='MDSYS';
             :loc_name := '?/md/admin/locdbmig.sql';
            EXCEPTION WHEN NO_DATA_FOUND THEN NULL;  -- no MDSYS with XE;
         END;
      END IF;
   END IF;
-- Exception handler for all other cases
--   dbms_registry.is_loaded
--   selecting edition column
--   selecting name where error is not NO_DATA_FOUND
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

Rem No timestamps for locator, but errors
Rem will be associated with SDO
SET ERRORLOGGING ON TABLE SYS.REGISTRY$ERROR IDENTIFIER 'SDO';

SELECT :loc_name AS dbmig_name FROM DUAL;
@&dbmig_file

