Rem
Rem $Header: rdbms/admin/utlpwdmg.sql /main/14 2017/05/28 22:46:12 stanaya Exp $
Rem
Rem utlpwdmg.sql
Rem
Rem Copyright (c) 2006, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      utlpwdmg.sql - script for Default Password Resource Limits
Rem
Rem    DESCRIPTION
Rem      This is a script for enabling the password management features
Rem      by setting the default password resource limits.
Rem
Rem    NOTES
Rem      This file contains a function for minimum checking of password
Rem      complexity. This is more of a sample function that the customer
Rem      can use to develop the function for actual complexity checks that the 
Rem      customer wants to make on the new password.
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/utlpwdmg.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/utlpwdmg.sql
Rem    SQL_PHASE: UTILITY
Rem    SQL_STARTUP_MODE: NORMAL
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    END SQL_FILE_METADATA
Rem    
Rem    MODIFIED   (MM/DD/YY)
Rem    sumkumar    12/15/15 - Bug 22369990: Make all PVFs as common objects
Rem                           so as to make them available inside PDBs
Rem    yanlili     09/18/15 - Fix bug 20603202: Handle quoted usernames if
Rem                           called directly
Rem    hmohanku    02/17/15 - bug 20460696: add long identifier support
Rem    sumkumar    12/26/14 - Proj 46885: set inactive account time to
Rem                           UNLIMITED for DEFAULT profile
Rem    jkati       10/16/13 - bug#17543726 : remove complexity_check,
Rem                           string_distance, ora12c_strong_verify_function
Rem                           since we now provide them by default with new db
Rem                           creation
Rem    skayoor     10/26/12 - Bug 14671375: Execute privilege on pwd verify
Rem                           func
Rem    jmadduku    07/30/12 - Bug 13536142: Re-organize the code
Rem    jmadduku    12/02/11 - Bug 12839255: Compliant Password Verify functions
Rem    jmadduku    01/21/11 - Proj 32507: Add a new password verify function
Rem                           STIG_verify_function and enhance functionality of
Rem                           code that checks distance between old and new
Rem                           password
Rem    asurpur     05/30/06 - fix - 5246666 beef up password complexity check 
Rem    nireland    08/31/00 - Improve check for username=password. #1390553
Rem    nireland    06/28/00 - Fix null old password test. #1341892
Rem    asurpur     04/17/97 - Fix for bug479763
Rem    asurpur     12/12/96 - Changing the name of password_verify_function
Rem    asurpur     05/30/96 - New script for default password management
Rem    asurpur     05/30/96 - Created
Rem


-- This script sets the default password resource parameters
-- This script needs to be run to enable the password features.
-- However the default resource parameters can be changed based 
-- on the need.
-- A default password complexity function is provided.

Rem *************************************************************************
Rem BEGIN Password Management Parameters
Rem *************************************************************************

-- This script alters the default parameters for Password Management
-- This means that all the users on the system have Password Management
-- enabled and set to the following values unless another profile is 
-- created with parameter values set to different value or UNLIMITED 
-- is created and assigned to the user.

ALTER PROFILE DEFAULT LIMIT
PASSWORD_LIFE_TIME 180
PASSWORD_GRACE_TIME 7
PASSWORD_REUSE_TIME UNLIMITED
PASSWORD_REUSE_MAX  UNLIMITED
FAILED_LOGIN_ATTEMPTS 10
PASSWORD_LOCK_TIME 1
INACTIVE_ACCOUNT_TIME UNLIMITED
PASSWORD_VERIFY_FUNCTION ora12c_verify_function;

/** 
The below set of password profile parameters would take into consideration
recommendations from Center for Internet Security[CIS Oracle 11g].

ALTER PROFILE DEFAULT LIMIT
PASSWORD_LIFE_TIME 90 
PASSWORD_GRACE_TIME 3
PASSWORD_REUSE_TIME 365
PASSWORD_REUSE_MAX  20
FAILED_LOGIN_ATTEMPTS 3
PASSWORD_LOCK_TIME 1
PASSWORD_VERIFY_FUNCTION ora12c_verify_function;
*/

/** 
The below set of password profile parameters would take into 
consideration recommendations from Department of Defense Database 
Security Technical Implementation Guide[STIG v8R1]. 

ALTER PROFILE DEFAULT LIMIT
PASSWORD_LIFE_TIME 60
PASSWORD_REUSE_TIME 365 
PASSWORD_REUSE_MAX  5
FAILED_LOGIN_ATTEMPTS 3
PASSWORD_VERIFY_FUNCTION ora12c_strong_verify_function;
*/

Rem *************************************************************************
Rem END Password Management Parameters
Rem *************************************************************************
