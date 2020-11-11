Rem
Rem $Header: rdbms/admin/dbmsqopi.sql /main/16 2017/10/25 10:57:00 sspulava Exp $
Rem
Rem dbmsqopi.sql
Rem
Rem Copyright (c) 2011, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbmsqopi.sql - dbms_opatch package specification
Rem
Rem    DESCRIPTION
Rem      Creation of dbms_opatch package specification and sequences
Rem
Rem    NOTES
Rem      .
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/dbmsqopi
Rem SQL_SHIPPED_FILE: rdbms/admin/dbmsqopi
Rem SQL_PHASE: DBMSQOPI
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catpdbms.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    sspulava    10/22/17 - move xslt variable to package body B#26370219
Rem    surman      07/27/17 - 26517122: Make build_header a constant
Rem    surman      03/08/17 - 25425451: Intelligent bootstrap
Rem    dkoppar     10/01/15 - #21052918 support RO-RW for bigsql
Rem    dkoppar     07/20/15 - #21471484 image store-restore support
Rem    dkoppar     12/23/14 - #19938082 add additional APIs
Rem    dkoppar     04/01/15 - #20379970 add cleanup API
Rem    surman      01/23/14 - 13922626: Update SQL metadata
Rem    dkoppar     09/23/13 - #17344263 check internal testing
Rem    dkoppar     10/04/12 - add sqlpatch API
Rem    dkoppar     09/19/12 - #14633786 add xslt
Rem    tbhukya     09/18/12 - Add set_debug
Rem    tbhukya     07/13/12 - Add new apis
Rem    tbhukya     05/08/12 - Add opatch_run_stop_job() api
Rem    tbhukya     06/19/11 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

-- Creation of package dbms_qopatch
CREATE OR REPLACE PACKAGE dbms_qopatch AUTHID DEFINER AS

  -- 25425451: For intelligent bootstrap
  build_header CONSTANT VARCHAR2(200) := '$Header: rdbms/admin/dbmsqopi.sql /main/16 2017/10/25 10:57:00 sspulava Exp $';
  FUNCTION body_build_header RETURN VARCHAR2;


   --Provides ORACLE_HOME details
  function  get_opatch_install_info   return xmltype;

  --Provides top level patch info for patch
  function  GET_OPATCH_DATA           (pnum IN varchar2) return xmltype;

  --Provides bugs list in a patch or all the patches
  function  GET_OPATCH_BUGS           (pnum IN varchar2 DEFAULT NULL) return xmltype;

  --Provides list of files modified by a patch or all the patches
  function  GET_OPATCH_FILES          (pnum IN varchar2) return xmltype;

  --Provides installed patches total count
  function  GET_OPATCH_COUNT           return xmltype;

  -- Get list of patches installed
  function  GET_OPATCH_LIST           return xmltype;

  --Provides prerequisite patches for a patch
  function  GET_OPATCH_PREQS          (pnum IN varchar2) return xmltype;

  --Provides overlay patches for a patch
  function  GET_OPATCH_OLAYS          (pnum IN varchar2) return xmltype;

  --Detects patch conflicts for given files
  function  PATCH_CONFLICT_DETECTION   (fileName IN varchar2) return xmltype;

  --  Provides list of patches installed
  function  IS_PATCH_INSTALLED        (pnum IN VARCHAR2) return xmltype;

  -- Get sql patch status of all RAC instances
  function GET_PENDING_ACTIVITY return xmltype;

  -- Set current node, instance name in case of RAC
  PROCEDURE set_current_opinst(node_name IN VARCHAR2 DEFAULT NULL,
                               inst_name IN VARCHAR2 DEFAULT NULL);

  -- To call job to refresh the inventory
  PROCEDURE opatch_inv_refresh_job;

  -- To get the stylesheet for result presentation
  function  get_opatch_xslt return xmltype;

  --To get the full opatch lsinventory
  function get_opatch_lsinventory return xmltype;

  -- To create job on newly added node
  FUNCTION add_oinv_job(nname VARCHAR2, iname VARCHAR2) RETURN BOOLEAN;

  -- To drop job on deleted node
  FUNCTION drop_oinv_job(nname VARCHAR2, iname VARCHAR2) RETURN BOOLEAN;

  -- Replaces log ans script directories with correct path
  PROCEDURE replace_logscrpt_dirs;
  PROCEDURE replace_dirs_int(pf_id  NUMBER);

  -- sqlpatch description from sql registry
  PROCEDURE get_sqlpatch_status(pnum varchar2 default NULL);

  -- Turn on debug 
  PROCEDURE set_debug(debug IN BOOLEAN);

  -- FLAG for internal testing
  PROCEDURE skip_sanity_check(skip IN BOOLEAN);

  -- get the details of a specific patch
  FUNCTION  get_patch_details (patch VARCHAR2) return XMLTYPE;

  -- check if patch is installed
  FUNCTION check_patch_installed( bugs qopatch_list ) return VARCHAR2;

  -- compare the list of bugs with the connected node
  FUNCTION opatch_compare_current( bugs qopatch_list) return VARCHAR2;

  -- compare all nodes of rac or a specific given node
  FUNCTION opatch_compare_nodes(node varchar2 DEFAULT NULL, inst varchar2 DEFAULT NULL) return VARCHAR2; 

  -- create inventory image
  PROCEDURE opatch_create_image (filename IN varchar2);

  -- compare with the gold_image
  FUNCTION  opatch_compare_gold_image (gold_image_file IN VARCHAR2) return VARCHAR2;

  -- get the inventory image
  FUNCTION get_opatch_image(filename  IN VARCHAR2) return XMLTYPE;

  -- API for cleanup the metadata in case of inconsistency
  PROCEDURE clean_metadata;

  PROCEDURE LOAD_SQL_PATCHES(patch_count OUT NUMBER);

END dbms_qopatch;
/

@?/rdbms/admin/sqlsessend.sql
