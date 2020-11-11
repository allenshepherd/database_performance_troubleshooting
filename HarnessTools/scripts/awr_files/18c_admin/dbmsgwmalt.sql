Rem
Rem  $Header: rdbms/admin/dbmsgwmalt.sql /main/4 2017/10/25 18:01:33 raeburns Exp $ 
Rem
Rem dbmsgwmalt.sql
Rem
Rem Copyright (c) 2011, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbmsgwmalt.sql - Global Workload Management Alerts 
Rem
Rem    DESCRIPTION
Rem      Defines the dbms_gsm_alert package that is used for alerts 
Rem      definitions and procedures used for GDS.
Rem
Rem    NOTES
Rem      This package is for definitions and FUNCTIONs shared by the 
Rem      dbms_gsm_pooladmin and dbms_gsm_cloudadmin packages on the GSM
Rem      cloud catalog database, and for utility routines used by GSMCTL
Rem      when administering the cloud.
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/dbmsgwmalt.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/dbmsgwmalt.sql
Rem SQL_PHASE: DBMSGWMALT
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/dbmsgwm.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    raeburns    10/21/17 - RTI 20225108: Cleanup SQL_METADATA
Rem    dcolello    11/19/16 - always set schema to gsmadmin_internal
Rem    surman      01/23/14 - 13922626: Update SQL metadata
Rem    nbenadja    02/19/13 - GDS alert package 
Rem    nbenadja    02/19/13 - Created

@@?/rdbms/admin/sqlsessstart.sql

ALTER SESSION SET CURRENT_SCHEMA=GSMADMIN_INTERNAL
/

--*****************************************************************************
-- Database package for GSM utility FUNCTIONs and definitions.
--*****************************************************************************

-- So that we can use alerts 
grant execute on  sys.dbms_server_alert to gsmadmin_internal;
/
CREATE OR REPLACE PACKAGE dbms_gsm_alerts AS


--*****************************************************************************
-- Package Public Types
--*****************************************************************************


--*****************************************************************************
-- Package Public Constants
--*****************************************************************************
 yellow_level          constant  varchar2(7) := 'YELLOW';
 red_level             constant  varchar2(4) := 'RED';
 cpu_threshold         constant  varchar2(4) := 'CPU';
 disk_threshold        constant  varchar2(5) := 'DISK';

-------------------------------------------------------------------------------
-- Default Names
-------------------------------------------------------------------------------


-------------------------------------------------------------------------------
-- Identifier lengths
-------------------------------------------------------------------------------

--*****************************************************************************
-- Package Public Exceptions
--*****************************************************************************


--*****************************************************************************
-- Package Public Procedures
--*****************************************************************************
-------------------------------------------------------------------------------
--
-- PROCEDURE    post_alert 
--
-- Description:
--       post a GDS alert.      
--
-- Parameters:
--        reason_id  - 
--        severity -       
--        object_name -    
--        database_name   
--        pool_name -       
--        region_name - 
--        resource_name -     
--        thresh_level -    
--        expect_card -     
--        current_card -    
--        clear_old_alert - 
--    
------------------------------------------------------------------------------- 
procedure post_alert(reason_id      IN   dbms_server_alert.reason_id_t,
                           severity      IN   dbms_server_alert.severity_level_t,
                           object_name     IN   VARCHAR2,
                           instance_name   IN   VARCHAR2 default NULL,
                           database_name   IN   VARCHAR2 default NULL,
                           pool_name       IN   VARCHAR2 default NULL,
                           region_name     IN   VARCHAR2 default NULL,
                           resource_name   IN   VARCHAR2 default NULL,
                           thresh_level    IN   VARCHAR2 default NULL,
                           expect_card     IN   VARCHAR2  default NULL,
                           current_card    IN   VARCHAR2  default NULL);


-------------------------------------------------------------------------------
--
-- PROCEDURE    post_gsm_down
--
-- Description:
--       post a GDS alert : gsm down.      
--
-- Parameters:
--       gsm_name -    The name of gsm.
--       region_name - The region GSM belongs to.
--    
------------------------------------------------------------------------------- 
procedure post_gsm_down(gname     IN  VARCHAR2,
                        rname     IN   VARCHAR2 default NULL);

-------------------------------------------------------------------------------
--
-- PROCEDURE    post_instance_down
--
-- Description:
--       post a GDS alert : instance down or not reachable.      
--
-- Parameters:
--       gsm_name -    The name of instance.
--       pool_name -   The pool the instance belongs to.
--       region_name - The region the instance belongs to.
--    
------------------------------------------------------------------------------- 
PROCEDURE post_instance_down (instance_name IN VARCHAR2,
                              pool_name      IN VARCHAR2 default NULL,
                              region_name    IN VARCHAR2 default NULL);

-------------------------------------------------------------------------------
--
-- PROCEDURE    post_database_down
--
-- Description:
--       post a GDS alert : database down or not reachable.      
--
-- Parameters:
--       database_name  - The name of the database.
--       pool_name      - The pool the database belongs to.
--       region_name    - The region the database belongs to.
--    
------------------------------------------------------------------------------- 
PROCEDURE post_database_down (database_name IN VARCHAR2,
                              pool_name      IN VARCHAR2 default NULL,
                              region_name    IN VARCHAR2 default NULL);

-------------------------------------------------------------------------------
--
-- PROCEDURE    post_threshold_hit
--
-- Description:
--       post a GDS alert : a CPU or a DISK threshold has been hit
--                          for a given service.     
--
-- Parameters:
--       service_name -  The name of the service.
--       pool_name -     The pool the service belongs to.
--       resource_name - The resource (CPU or DISK) hit by the threshold.
--       thresh_level -  The threshold level ('Yellow' or 'Red')
--    
------------------------------------------------------------------------------- 
procedure post_threshold_hit (instance_name  IN VARCHAR2,
                              pool_name      IN VARCHAR2,
                              region_name    IN VARCHAR2,
                              resource_name  IN VARCHAR2,
                              thresh_level   IN VARCHAR2);

-------------------------------------------------------------------------------
--
-- PROCEDURE    post_database_lagging
--
-- Description:
--       post a GDS alert : The replcated database is lagging 
--                          for a given service.     
--
-- Parameters:
--       service_name -  The name of the service.
--       pool_name -     The pool the service belongs to.
--       database_name - The name of the replicated database. 
--       region_name -   The region the database belongs to. 
------------------------------------------------------------------------------- 
procedure post_database_lagging (service_name  IN VARCHAR2,
                              pool_name     IN VARCHAR2,
                              database_name IN VARCHAR2,
                              region_name IN VARCHAR2);

-------------------------------------------------------------------------------
--
-- PROCEDURE    post_card_off
--
-- Description:
--       post a GDS alert : Service cardinality is off. 
--
-- Parameters:
--       service_name -  The name of the service.
--       pool_name -     The pool the service belongs to.
--       exp_card -      The expected cardinality.
--       curr_card -     The current cardinality.
--    
------------------------------------------------------------------------------- 
procedure post_card_off (service_name IN VARCHAR2,
                         pool_name    IN VARCHAR2,
                         exp_card     IN NUMBER,
                         curr_card    IN NUMBER);

-------------------------------------------------------------------------------
--
-- PROCEDURE    post_card_off
--
-- Description:
--       post a GDS alert : Service cardinality is off. 
--
-- Parameters:
--       service_name -  The name of the service.
--       pool_name -     The pool the service belongs to.
--       region_name  -  The region where the cardinality is off. 
--    
------------------------------------------------------------------------------- 
procedure post_card_off (service_name IN VARCHAR2,
                         pool_name    IN VARCHAR2,
                         region_name  IN VARCHAR2 default NULL);

-------------------------------------------------------------------------------
--
-- PROCEDURE    post_catalog_down
--
-- Description:
--       post a GDS alert : The catalog is down or not reachable. 
--
-- Parameters:
--       database_name - The name of the database where the catalog has 
--                       been created.
-- Note:
--       This will be posted on the cloud databases.    
------------------------------------------------------------------------------- 
procedure post_catalog_down (database_name IN VARCHAR2);



-------------------------------------------------------------------------------
--
-- FUNCTION   get_gsm_name 
--
-- Description:
--       Returns the GSM name associated with the alert.  
--
-- Parameters:
--       my_alert - The GDS alert. 
-- Note:
--       This will return the GSM name only if a GSM is involved in 
--       the GDS alert.
------------------------------------------------------------------------------- 
FUNCTION get_gsm_name (my_alert IN ALERT_TYPE
                 ) 
          return VARCHAR2;

-------------------------------------------------------------------------------
--
-- FUNCTION   get_instance_name 
--
-- Description:
--       Returns the instance name associated with the alert.  
--
-- Parameters:
--       my_alert - The GDS alert. 
-- Note:
--       This will return the instance name only if an instance is involved in 
--       the GDS alert.
------------------------------------------------------------------------------- 
FUNCTION get_instance_name (my_alert IN ALERT_TYPE
                 ) 
          return VARCHAR2;

-------------------------------------------------------------------------------
--
-- FUNCTION   get_database_name 
--
-- Description:
--       Returns the database name associated with the alert.  
--
-- Parameters:
--       my_alert - The GDS alert. 
-- Note:
--       This will return the instance name only if a database is involved in 
--       the GDS alert.
------------------------------------------------------------------------------- 
FUNCTION get_database_name (my_alert IN ALERT_TYPE
                 ) 
          return VARCHAR2;

-------------------------------------------------------------------------------
--
-- FUNCTION   get_database_name 
--
-- Description:
--       Returns the database name associated with the alert.  
--
-- Parameters:
--       my_alert - The GDS alert. 
-- Note:
--       This will return the instance name only if a database is involved in 
--       the GDS alert.
------------------------------------------------------------------------------- 
FUNCTION get_service_name(my_alert IN ALERT_TYPE
                 ) 
          return VARCHAR2;

-------------------------------------------------------------------------------
--
-- FUNCTION   get_gdspool_name 
--
-- Description:
--       Returns the GDS pool name associated with the alert.  
--
-- Parameters:
--       my_alert - The GDS alert. 
-- Note:
--       This will return the GDS pool name only if a GDS pool is involved in 
--       the GDS alert.
------------------------------------------------------------------------------- 
FUNCTION get_gdspool_name (my_alert IN ALERT_TYPE
                 ) 
          return VARCHAR2;

-------------------------------------------------------------------------------
--
-- FUNCTION   get_region_name 
--
-- Description:
--       Returns the region name associated with the alert.  
--
-- Parameters:
--       my_alert - The GDS alert. 
-- Note:
--       This will return the region name only if a region is named in 
--       the GDS alert.
------------------------------------------------------------------------------- 
FUNCTION get_region_name (my_alert IN ALERT_TYPE
                 ) 
          return VARCHAR2;

-------------------------------------------------------------------------------
--
-- FUNCTION   get_resource_name 
--
-- Description:
--       Returns the resource name (CPU or DISK)  associated with the alert.  
--
-- Parameters:
--       my_alert - The GDS alert. 
-- Note:
--       This will return the resource name only if it is a treshold limit
--       GDS alert.
------------------------------------------------------------------------------- 
FUNCTION get_resource_name (my_alert IN ALERT_TYPE
                 ) 
          return VARCHAR2;

-------------------------------------------------------------------------------
--
-- FUNCTION   get_thresh_level
--
-- Description:
--       Returns the thresh level (Yellow, Red) associated with the alert.  
--
-- Parameters:
--       my_alert - The GDS alert. 
-- Note:
--       This will return the threshold level if it is a threshold 
--       GDS alert.
------------------------------------------------------------------------------- 
FUNCTION get_thresh_level (my_alert IN ALERT_TYPE
                 ) 
          return VARCHAR2;

-------------------------------------------------------------------------------
--
-- FUNCTION   get_expected_cardinality 
--
-- Description:
--       Returns the expected cardinality as mentioned in the alert.  
--
-- Parameters:
--       my_alert - The GDS alert. 
-- Note
--       This will return the expected cardinality if it is a cardinality miss
--       GDS alert.
------------------------------------------------------------------------------- 
FUNCTION get_expected_cardinality (my_alert IN ALERT_TYPE
                 ) 
          return BINARY_INTEGER;

-------------------------------------------------------------------------------
--
-- FUNCTION   get_current_cardinality 
--
-- Description:
--       Returns the current cardinality as mentioned in the alert.  
--
-- Parameters:
--       my_alert - The GDS alert. 
-- Note
--       This will return the current cardinality if it is a cardinality miss
--       GDS alert.
-------------------------------------------------------------------------------
FUNCTION get_current_cardinality (my_alert IN ALERT_TYPE
                 ) 
          return BINARY_INTEGER;

END dbms_gsm_alerts;

/

show errors

ALTER SESSION SET CURRENT_SCHEMA=SYS
/

@?/rdbms/admin/sqlsessend.sql
