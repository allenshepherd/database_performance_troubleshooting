Rem Copyright (c) 1987, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem NAME
Rem    CATMETTYPES.SQL - Object types of the Oracle dictionary for
Rem                      Metadata API.
Rem  FUNCTION
Rem     Creates an object types of the Oracle dictionary for use by the
Rem     DataPump Metadata API.
Rem  NOTES
Rem     Must be run when connected to SYS or INTERNAL.
Rem     IMPORTANT! Keep the files catnomtt.sql and catnomta.sql in synch with
Rem     this file. These are invoked by catnodp.sql during downgrade.
Rem
Rem     All types must have EXECUTE granted to PUBLIC.
Rem     All top-level views used by the mdAPI to actually fetch full object
Rem     metadata (eg, KU$_TABLE_VIEW) must have SELECT granted to PUBLIC, but
Rem     must have CURRENT_USERID checking security clause.
Rem     All views subordinate to the top level views (eg, KU$_SCHEMAOBJ_VIEW)
Rem     must have SELECT granted to SELECT_CATALOG_ROLE.
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catmettypes.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catmettypes.sql
Rem SQL_PHASE: CATMETTYPES
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catpdeps.sql
Rem END SQL_FILE_METADATA
Rem
Rem  MODIFIED      MM/DD/YY
Rem     jjanosik   09/14/17 - Bug 26721864: Get memoptimize info into
Rem                           constraint
Rem     sdavidso   08/29/17 - bug25453685 move chunk - domain index
Rem     jjanosik   07/24/17 - Bug 26303869: add info to nested tables
Rem     bwright    07/17/17 - Bug 25651930: Fix ku_XmlColSet_t synonym def
Rem     tbhukya    07/17/17 - Bug 22104291: Add ext_location
Rem     jjanosik   06/22/17 - Bug 24719359: Add support for RADM Policy
Rem                           Expressions
Rem     jjanosik   05/05/17 - Bug 25239237: Update tablespace comments
Rem     jjanosik   04/19/17 - Bug 25364071: get encalg and intalg for nested
Rem                           tables
Rem     tbhukya    04/10/17 - Bug 25556006: Partitioned Databound 
Rem                           Collation support
Rem     bwright    03/31/17 - Bug 25808867: Add FORCE, NOT PERSISTABLE to type
Rem                           definitions
Rem     mjangir    03/27/17 - 23181020: ORA-01427 in ku$_xspolicy_view
Rem     qinwu      01/19/17 - proj 70151: support db capture and replay auth
Rem     sdavidso   01/19/17 - bug25225293 make procact_instance work with CBO
Rem     sfeinste   01/05/17 - Proj 70791: add dyn_all_cache to
Rem                           ku$_analytic_view_t
Rem     mjangir    12/22/16 - bug 25297023: add unique id for ku$ views
Rem     jjanosik   10/03/16 - Bug 24661809: translate extensibility callout
Rem                           packages to tags
Rem     rapayne    08/09/16 - bug 24435630: Fetch IM clause for ILM policies.
Rem                           note: this is a fwd merge from 12.2.0.1
Rem     almurphy   09/13/16 - add REFERENCES DISTINCT to ANALYTIC VIEW
Rem     sdavidso   08/30/16 - bug-24386897 list partition limit fo 4000 chars
Rem     jjanosik   08/18/16 - bug 23625494 - split flags in ku$_tab_tsubpart_t
Rem     mjangir    06/28/16 - bug 19450444: support regexp data redaction
Rem     drosash    05/11/16 - Bug 23245222: change RIM for LEAF
Rem     sdavidso   05/01/16 - bug23179975 app table data exported twice.
Rem     mjangir    04/04/16 - bug 22763372: resolve ORA-01427
Rem     sdavidso   02/20/16 - bug22151959 fix xlm schema-element name
Rem     youyang    02/15/16 - bug22672722:dv support for index functions
Rem     mstasiew   02/04/16 - Bug 22658620: hcs partitioned/missing tables
Rem     beiyu      01/19/16 - Bug 21365797: add owner_in_ddl col to HCS types
Rem     beiyu      12/21/15 - Bug 20619944: add level_type column
Rem     sdavidso   12/10/15 - bug22264616 more move chunk subpart
Rem     sogugupt   11/26/15 - Remove ku$_find_hidden_cons_t
Rem     smesropi   11/24/15 - Bug 21910928: Modify all_member_name to be clob
Rem     rapayne    11/16/15 - bug 22165030: imc distribute for subpartition
Rem                           templates.
Rem     tbhukya    11/10/15 - Bug 21747321: Add tfstatus in ku$_file_t
Rem     smesropi   11/08/15 - Bug 21171628: Rename HCS views
Rem     tbhukya    11/04/15 - Bug 22125304: Add org_col_name 
Rem     sdavidso   11/03/15 - bug21869037 chunk move w/subpartitions
Rem     jibyun     11/01/15 - support DIAGNOSTIC auth for Database Vault
Rem     jjanosik   09/28/15 - bug 21798129: Support Local Temp Tablespace in
Rem                           user type
Rem     mstasiew   09/25/15 - Bug 21867527: hier cube measure cache
Rem     mstasiew   08/27/15 - Bug 21384694: hier hier attr classifications
Rem     tbhukya    08/17/15 - Bug 21555645: Partitioned mapping io table
Rem     rapayne    08/01/15 - Bug 21147617: expand IM related queries to include
Rem                           new FOR SERVICE syntax for DISTRIBUTE clause.
Rem     yanchuan   07/27/15 - Bug 21299533: support for Database Vault
Rem                           Authorization
Rem     sdavidso   07/21/15 - bug-20756759: lobs, indexes, droppped tables
Rem                         added new 12.2 columns for ku$_schemaobj_t
Rem     sogugupt   07/11/15 - bug 21312469: add missing coulmns in ilm_policy_t 
Rem     sdavidso   07/01/15 - bug20864693: read only partition support
Rem     tbhukya    06/24/15 - Bug 21276592: Partitioned cluster
Rem     mjangir    06/21/15 - bug 18506065: check guard col in
Rem                           ku$_10_2_strmcol_t
Rem     mstasiew   06/03/15 - Bug 20845805: hierarchy cube improvements
Rem     sanbhara   06/01/15 - Bug 21158282 - adding ku$_dummy_comm_rule_alts_t.
Rem     tbhukya    05/26/15 - Bug 21143649: Long identifier fix
Rem     rapayne    05/20/15 - External table enhancements for partition
Rem                           locations.
Rem     mstasiew   05/16/15 - Bug 20845789 hierarchy dimension get_ddl fixes
Rem     tbhukya    05/06/15 - Bug 21038781: DBC support for MV
Rem     bwright    03/24/15 - Bug 20771546: Support for scalable sequence
Rem     tbhukya    03/24/15 - Bug 20746362: Correct the attributes length 
Rem                           and support long identifier in several types
Rem     rmacnico   03/15/15 - Proj 47506: CELLCACHE
Rem     tbhukya    02/25/15 - Proj 47173: Data bound collation
Rem     tbhukya    03/12/15 - Bug 20682834: Long identifiers support
Rem     tbhukya    03/10/15 - Bug 20651426: Long identifier in ku$_objgrant_t 
Rem     sdavidso   03/07/15 - Parallel metadata export
Rem     bwright    02/23/15 - Bug 20307940: Long identifiers for cube tables
Rem     bwright    02/11/15 - Proj 49143: Add auto-list (sub)partitioning and
Rem                           range interval subpartitioning w/ transition
Rem     sdavidso   02/08/15 - proj 56220-2 - partition transportable
Rem     rapayne    02/01/15 - proj 47411: local temporary tablespaces.
Rem     beiyu      01/09/15 - Proj 47091: add types for new HCS objects
Rem     htseng     01/08/15 - increase owner_name to 128 in ku$_xmlschema_t  
Rem     rapayne    10/20/14 - bug 20164836: support for RAS schema level priv
Rem                           grants.
Rem     rapayne    10/20/14 - support for RAS schema level priv grants.
Rem     kaizhuan   11/11/14 - Project 46812: support for Database Vault policy
Rem     bwright    11/05/14 - Support 'audit policy by granted roles'
Rem     tbhukya    08/26/14 - Bug 19688579: Add org_property2 and new spares
Rem     tbhukya    08/27/14 - Bug 18117024: Add flags, storage, clus_tab 
Rem                           to ku$_qtab_storage_t
Rem     jibyun     08/06/14 - Project 46812: support for Database Vault policy
Rem     sdavidso   05/23/14 - backport bug18760457 from MAIN
Rem     sdavidso   05/15/14 - bug18760457: missing SUBPARTITION BY clause
Rem     lbarton    04/30/14 - bug 18449519: multiple valid time periods
Rem     sdavidso   02/10/14 - bug14821907: find tablespaces: table
Rem                           transportable
Rem     lbarton    06/05/13 - project 35786: longer identifiers
Rem     surman     12/29/13 - 13922626: Update SQL metadata
Rem     dvekaria   12/20/13 - Bug17494709: Add encryptionalg to ku$_tablespace_t
Rem     mjangir    12/19/13 - bug 17500493: AQ storage_clause with lob column
Rem     rapayne    11/24/13 - Bug 15916457: add objgrant_t to ku$_pfhtable_t
Rem     sdavidso   11/03/13 - bug17718297 - IMC selective column
Rem     bwright    10/18/13 - Bug 17627666: Add COL_SORTKEY for consistent
Rem                           column ordering with stream and exttbl metadata
Rem     rapayne    09/22/13 - Bug 17321518: RAS policy support.
Rem     minx       09/20/13 - Bug 17478619: Add description to xs$instset_rule
Rem     bwright    08/14/13 - Bug 17312600: Remove hard tabs from DP src code
Rem     gclaborn   07/31/13 - 17247965: Add version support for import callouts
Rem     dvekaria   07/18/13 - Bug 15962071: Modify ku$_prim_column_t to hold
Rem                           DEFAULT_VAL expression as varchar or clob.
Rem     pradeshm   07/15/13 - Proj#46908: new columns in RAS principal table
Rem     lbarton    06/27/13 - bug 16800820: valid-time temporal
Rem     lbarton    04/24/13 - bug 16716831: functional index expression as
Rem                           varchar or clob
Rem     sdavidso   04/06/13 - proj42352: DP In-memory columnar
Rem     lbarton    04/04/13 - bug 11769638: property in exttab_t
Rem     bwright    03/07/13 - Bug14075699: Add PROPERTY2 to STRMTABLE_T
Rem     rapayne    10/03/12 - lrg 7256879: modify Triton views to use new
Rem                           Oracle Supplied bit.
Rem     lbarton    10/02/12 - bug 10350062: ILM compression and storage tiering
Rem     traney     09/26/12 - move unusable from index to column
Rem     traney     08/02/12 - 14407652: support editions enhancements
Rem     lbarton    07/26/12 - bug 13454387: long varchar
Rem     ssonawan   07/12/12 - bug 13843068: modify ku$_psw_hist_item_t.password
Rem                           column to varchar2(4000)
Rem     rapayne    06/12/12 - lrg 6886730: guard/nullable column support 
Rem     rapayne    03/31/12 - Proj 39632: support for create library extensions
Rem     traney     03/29/12 - bug 13715632: add agent to library$
Rem     surman     03/27/12 - 13615447: Add SQL patching tags
Rem     snadhika   03/12/12 - Bug 13240543, Session privilege check
Rem     lbarton    02/14/12 - project 37414: ILM support
Rem     taahmed    02/07/12 - remove defacl from xs$seccls
Rem     rapayne    01/30/12 - bug 13646476: add policy_schema to xsolap_policy_t
Rem     ssonawan   01/13/12 - bug 13582041: Remove handler from aud_policy$
Rem     lbarton    01/26/12 - gravipat_bug-12667763: view property2
Rem     sdavidso   01/19/12 - bug 13568859: add obj flag def (comments)
Rem     sdavidso   11/30/11 - long indentifiers for procedural objects
Rem     rapayne    11/20/11 - Project 36780: Invisible column support. Add
Rem                           property2 to simple_col_t definition.
Rem     ebatbout   11/09/11 - Project 36951: On_User_Grant support
Rem     ebatbout   11/23/11 - Proj. 36950 Code Based Roles
Rem     lbarton    10/27/11 - 36954_dpump_tabcluster_zonemap
Rem     rapayne    10/24/11 - minor changes to XS objects types to support 
Rem                           modify/remap.
Rem     ebatbout   10/14/11 - 12781157: Unpacked Opaque type support (Anydata)
Rem     lbarton    10/13/11 - bug 13092452: hygiene
Rem     dgagne     09/20/11 - add new stats types
Rem     dgagne     09/08/11 - add histgram changes to stats types
Rem     sdavidso   09/07/11 - get TABLE_DATA for options tables
Rem     rapayne    08/01/11 - Project 36780: Identity Column support.
Rem     jerrede    09/07/11 - Created for Parallel Upgrade Project #23496
Rem
Rem     mjangir    08/22/11 - bug 12687642: bug 10649822: do not use RBO for
Rem                           ku$_trigger_view
Rem     sdavidso   08/10/11 - FORCE_UNIQUE transform support
Rem     rapayne    07/25/11 - Project 32274: add schema based support for XDS
Rem                           objs.
Rem     lbarton    07/22/11 - bug 12780993: speed up estimate=stats
Rem     aramappa   07/18/11 - Project 31942: Add DBMS_RLS.OLS type to
Rem                           ku$_rls_policy_view
Rem     lbarton    07/13/11 - 32948_lob_storage
Rem     lbarton    07/12/11 - 32135_table_compression_clause
Rem     ebatbout   06/23/11 - proj 32404: Add physical part number (phypart#)
Rem                           to type/view, ku$_tab_part_t/ku$_tab_part_view.
Rem     sdavidso   06/17/11 - Parse item for hierarchy enabled xmltype
Rem     ebatbout   06/09/11 - bug 9796431: Call rtn, get_strm_minver, to
Rem                           determine stream metadata minor version for
Rem                           view, ku$_strmtable_view.
Rem     dahlim     06/07/11 - proj 32006: Import/Export support for RADM
Rem                           masking policies and fixed point table.
Rem     sdavidso   05/25/11 - proj_31238_bl3 fix nested table store as iot
Rem     rapayne    05/25/11 - add unsupported_index parse item.
Rem     mjangir    05/25/11 - bug 12384373: bad performance due to call of
Rem                           long2clob for non virtual cols in index export.
Rem     sdavidso   05/19/11 - bug 12545084 export acloid/userid for HET
Rem     lbarton    05/11/11 - bug 10186633: virtual column
Rem     rapayne    05/05/11 - proj 30924: add DISABLE_ARCHIVE_LOGGING transform
Rem                           parameter.
Rem     mjangir    04/23/11 - bug 10649822: do not use RBO for
Rem                           ku$_table_objnum_view
Rem     ebatbout   04/22/11 - Bug 9223960: Take into account that type,
Rem                           ku$_source_t, has new field, post_atname_off.
Rem     aamirish   04/20/11 - Proj 35490: Import/Export support for Attribute
Rem                           Associations of RLS Policies.
Rem     lbarton    04/18/11 - bug 10186633: virtual column
Rem     lbarton    04/13/11 - bug 12346384: no relational operator exporting
Rem                           view as table
Rem     tbhukya    04/12/11 - Bug 11828367: Get nls_length_semantics value
Rem     slynn      04/11/11 - Project 25215: Sequence Enhancements.
Rem     sdavidso   04/04/11 - Merge full transportable from 11.2.0.3
Rem     dgagne     03/30/11 - add datapump_paths_version
Rem     dgagne     03/23/11 - add parse items
Rem     sdavidso   03/23/11 - extract BHIBOUNDVAL for partitioned tables
Rem     lbarton    03/07/11 - bug 10363497: performance of nested tables
Rem     rapayne    03/01/11 - bug 11780551: add STREAMSXML transform params.
Rem     gclaborn   03/01/11 - Move user mapping view to catdpb.sql
Rem     lbarton    02/28/11 - get_vat_xml
Rem     sdavidso   02/22/11 - add marker -> ddl transform (test)
Rem     lbarton    02/21/11 - bug 9650574:  ROLE_GRANTs of
Rem                           DATAPUMP_EXP(IMP)_FULL_DATABASE should not
Rem                           be exported to 10g.
Rem     gclaborn   02/17/11 - Our post-import sys. callout should run last
Rem     sdavidso   02/16/11 - new flags for impcalloutreg
Rem     gclaborn   02/14/11 - Change comments on our registrations;
Rem                           remove unused views
Rem     gclaborn   02/07/11 - Register system callout impcalloutreg$
Rem     mjangir    02/01/11 - bug 8467379: Export object auditing on pl/sql
Rem                           packages
Rem     ebatbout   01/26/11 - Bug 11063664: if col# is zero, then return
Rem                           null for base_col_name field in ku$_strmcol_view
Rem     sdavidso   01/20/11 - merge project 37216 bl1
Rem     ebatbout   01/19/11 - bug 9119809: For views of partitioned tables,
Rem                           call dbms_metadata_util.has_tstz_cols routine
Rem                           to determine the value for the field, tstz_cols.
Rem     gclaborn   01/11/11 - Register our user mapping view in impcalloutreg$
Rem     gclaborn   12/14/10 - add tgt_type to impcalloutreg$
Rem     gclaborn   10/01/10 - Add type and views for import callouts

@@?/rdbms/admin/sqlsessstart.sql

-- Types used by the mdAPI interface:
-------------------------------------
-- SET_PARSE_ITEM specifies that an attribute of an object be parsed from
-- the output and returned separately by FETCH_XML, FETCH_DDL or CONVERT.
-- Since multiple items can be parsed, they are returned in a nested table,
-- ku$_parsed_items.

CREATE OR REPLACE TYPE sys.ku$_parsed_item FORCE AS OBJECT
        (       item            VARCHAR2(30),   -- item to be parsed
                value           VARCHAR2(4000), -- item's value
                object_row      NUMBER          -- object row of item
        )
NOT PERSISTABLE
/
GRANT EXECUTE ON sys.ku$_parsed_item TO PUBLIC;
CREATE OR REPLACE PUBLIC SYNONYM ku$_parsed_item FOR sys.ku$_parsed_item;

CREATE OR REPLACE TYPE sys.ku$_parsed_items FORCE
IS TABLE OF (sys.ku$_parsed_item) NOT PERSISTABLE;
/
GRANT EXECUTE ON sys.ku$_parsed_items TO PUBLIC;
CREATE OR REPLACE PUBLIC SYNONYM ku$_parsed_items FOR sys.ku$_parsed_items;

-- The FETCH_DDL function returns creation DDL for an object.
-- Some database objects require multiple creation DDL statements, e.g.,
-- full types and packages (a header and a body) and tables (create plus alters
-- for constraints). ku$_ddl contains a single DDL statement.
-- ku$_ddls contains all the DDL statements returned by a call to FETCH_DDL.
-- Most object types will have only one row.
-- Each row of ku$_ddls itself contains a ku$_parsed_items nested table
-- for parsed items for that DDL statement.

CREATE OR REPLACE TYPE sys.ku$_ddl FORCE AS OBJECT
        (       ddltext         CLOB,                   -- The DDL text
                parsedItems     sys.ku$_parsed_items    -- the parsed items
        )
NOT PERSISTABLE
/
GRANT EXECUTE ON sys.ku$_ddl TO PUBLIC;
CREATE OR REPLACE PUBLIC SYNONYM ku$_ddl FOR sys.ku$_ddl;

CREATE OR REPLACE TYPE sys.ku$_ddls FORCE IS TABLE OF (sys.ku$_ddl)
NOT PERSISTABLE;
/
GRANT EXECUTE ON sys.ku$_ddls TO PUBLIC;
CREATE OR REPLACE PUBLIC SYNONYM ku$_ddls FOR sys.ku$_ddls;

CREATE OR REPLACE TYPE sys.ku$_multi_ddl FORCE AS OBJECT
        (       object_row      NUMBER,         -- object row of object
                ddls            sys.ku$_ddls    -- 1-N DDLs for the object
        )
NOT PERSISTABLE
/
GRANT EXECUTE ON sys.ku$_multi_ddl TO PUBLIC;
CREATE OR REPLACE PUBLIC SYNONYM ku$_multi_ddl FOR sys.ku$_ddl;

CREATE OR REPLACE TYPE sys.ku$_multi_ddls FORCE IS TABLE OF (sys.ku$_multi_ddl)
NOT PERSISTABLE;
/
GRANT EXECUTE ON sys.ku$_multi_ddls TO PUBLIC;
CREATE OR REPLACE PUBLIC SYNONYM ku$_multi_ddls FOR sys.ku$_multi_ddls;


-- types used by the OPENW/CONVERT/PUT interface

CREATE OR REPLACE TYPE sys.ku$_ErrorLine FORCE AS OBJECT 
        (       errorNumber     NUMBER,
                errorText       VARCHAR2(2000) )
NOT PERSISTABLE
/
GRANT EXECUTE ON sys.ku$_ErrorLine TO PUBLIC;
CREATE OR REPLACE PUBLIC SYNONYM ku$_ErrorLine FOR sys.ku$_ErrorLine;
CREATE OR REPLACE TYPE sys.ku$_ErrorLines FORCE AS TABLE OF (sys.ku$_ErrorLine)
NOT PERSISTABLE
/
GRANT EXECUTE ON sys.ku$_ErrorLines TO PUBLIC;
CREATE OR REPLACE PUBLIC SYNONYM ku$_ErrorLines FOR sys.ku$_ErrorLines;
-- Submit result will have the DDL text, error msgs and parsed items so it's
-- easy to see which object had a problem.
CREATE OR REPLACE TYPE sys.ku$_SubmitResult FORCE AS OBJECT
        (       ddl             sys.ku$_ddl,
                errorLines      sys.ku$_ErrorLines )
NOT PERSISTABLE
/
GRANT EXECUTE ON sys.ku$_SubmitResult TO PUBLIC;
CREATE OR REPLACE PUBLIC SYNONYM ku$_SubmitResult FOR sys.ku$_SubmitResult;
CREATE OR REPLACE TYPE sys.ku$_SubmitResults FORCE
AS TABLE OF (sys.ku$_SubmitResult)
NOT PERSISTABLE
/
GRANT EXECUTE ON sys.ku$_SubmitResults TO PUBLIC;
CREATE OR REPLACE PUBLIC SYNONYM ku$_SubmitResults FOR sys.ku$_SubmitResults;

-- ku$_vcnt (vcnt = VarChar2 Nested Table) is used to hold
--  large amounts of text data.
-- It is used for the PLSQL code returned by GET_DOMIDX_METADATA
-- and for LONG values whose length > 4000
-- ku$_vcntbig is the same except each element is 32k. Used in network fetches

CREATE OR REPLACE TYPE sys.ku$_vcnt FORCE AS TABLE OF (VARCHAR2(4000))
NOT PERSISTABLE
/
GRANT EXECUTE ON sys.ku$_vcnt TO PUBLIC;
CREATE OR REPLACE PUBLIC SYNONYM ku$_vcnt FOR sys.ku$_vcnt;

CREATE OR REPLACE TYPE ku$_ObjNum FORCE IS object(obj_num NUMBER)
NOT PERSISTABLE;
/
GRANT EXECUTE ON sys.ku$_ObjNum TO PUBLIC;
CREATE OR REPLACE TYPE ku$_ObjNumSet FORCE IS TABLE OF (ku$_ObjNum)
NOT PERSISTABLE;
/
GRANT EXECUTE ON sys.ku$_ObjNumSet TO PUBLIC;
CREATE OR REPLACE PUBLIC SYNONYM ku$_ObjNumSet FOR sys.ku$_ObjNumSet;

CREATE OR REPLACE TYPE ku$_ObjNumNam force as
 object (obj_num NUMBER,name VARCHAR2(128)) not persistable;
/
GRANT EXECUTE ON sys.ku$_ObjNumNam TO PUBLIC;
CREATE OR REPLACE PUBLIC SYNONYM ku$_ObjNumNam FOR sys.ku$_ObjNumNam;

CREATE OR REPLACE TYPE ku$_ObjNumNamSet FORCE IS TABLE OF  (ku$_ObjNumNam)
NOT PERSISTABLE;
/
GRANT EXECUTE ON sys.ku$_ObjNumNamSet TO PUBLIC;
CREATE OR REPLACE PUBLIC SYNONYM ku$_ObjNumNamSet FOR sys.ku$_ObjNumNamSet;

CREATE OR REPLACE TYPE ku$_ObjNumPair FORCE AS OBJECT (
  num1          NUMBER,
  num2          NUMBER
)
NOT PERSISTABLE
/
GRANT EXECUTE ON sys.ku$_ObjNumPair TO PUBLIC;
CREATE OR REPLACE PUBLIC SYNONYM ku$_ObjNumPair FOR sys.ku$_ObjNumPair;
CREATE OR REPLACE TYPE ku$_ObjNumPairList FORCE IS TABLE OF (ku$_ObjNumPair)
NOT PERSISTABLE
/
GRANT EXECUTE ON sys.ku$_ObjNumPairList TO PUBLIC;
CREATE OR REPLACE PUBLIC SYNONYM ku$_ObjNumPairList
 FOR sys.ku$_ObjNumPairList;

-- UDTs for procedural objects/actions
-- sys.ku$_procobj_loc:
--  newblock    -  0 = line_of_code continues the current block
--                -2 = append line_of_code to previous line
--                 1 = end previous PL/SQL block, start a new block
--  line_of_code-  A line of PL/SQL code
-- sys.ku$_procobj_locs:
--  a nested table of the above
-- sys.ku$_procobj_line (name retained for historical reasons):
--  locs        -  a sys.ku$_procobj_locs object containing some lines of
--                  PLSQL code; these constitute a single anonymous PLSQL
--                  block; a COMMIT will be inserted at the end
--  grantor     -  non-null: the user to connect to before executing
--                  the PLSQL block
-- sys.ku$_procobj_lines:
--  a nested table of the above

CREATE OR REPLACE TYPE sys.ku$_procobj_loc FORCE AS OBJECT
        (       newblock        NUMBER,
                line_of_code    VARCHAR2(32767) )
NOT PERSISTABLE
/
GRANT EXECUTE ON sys.ku$_procobj_loc TO PUBLIC;
CREATE OR REPLACE PUBLIC SYNONYM ku$_procobj_loc FOR sys.ku$_procobj_loc;

CREATE OR REPLACE TYPE sys.ku$_procobj_locs FORCE
AS TABLE OF (sys.ku$_procobj_loc)
NOT PERSISTABLE
/
GRANT EXECUTE ON sys.ku$_procobj_locs TO PUBLIC;
CREATE OR REPLACE PUBLIC SYNONYM ku$_procobj_locs FOR sys.ku$_procobj_locs;

CREATE OR REPLACE TYPE sys.ku$_procobj_line FORCE AS OBJECT
        (       grantor         VARCHAR2(128),
                locs            sys.ku$_procobj_locs )
NOT PERSISTABLE
/
GRANT EXECUTE ON sys.ku$_procobj_line TO PUBLIC;
CREATE OR REPLACE PUBLIC SYNONYM ku$_procobj_line FOR sys.ku$_procobj_line;

CREATE OR REPLACE TYPE sys.ku$_procobj_lines FORCE
AS TABLE OF (sys.ku$_procobj_line)
NOT PERSISTABLE
/
GRANT EXECUTE ON sys.ku$_procobj_lines TO PUBLIC;
CREATE OR REPLACE PUBLIC SYNONYM ku$_procobj_lines FOR sys.ku$_procobj_lines;

CREATE OR REPLACE TYPE sys.ku$_procobj_lines_tab FORCE
AS TABLE OF (sys.ku$_procobj_lines)
NOT PERSISTABLE
/
GRANT EXECUTE ON sys.ku$_procobj_lines_tab TO PUBLIC;
CREATE OR REPLACE PUBLIC SYNONYM ku$_procobj_lines_tab
   FOR sys.ku$_procobj_lines_tab;

-- UDTs for Java

CREATE OR REPLACE TYPE sys.ku$_chunk_t FORCE AS OBJECT
(
  text  varchar2(4000),
  length        number
)
NOT PERSISTABLE
/
GRANT EXECUTE ON sys.ku$_chunk_t TO PUBLIC;
CREATE OR REPLACE PUBLIC SYNONYM ku$_chunk_t FOR sys.ku$_chunk_t;

CREATE OR REPLACE TYPE sys.ku$_chunk_list_t FORCE IS TABLE OF (sys.ku$_chunk_t)
NOT PERSISTABLE
/ 
GRANT EXECUTE ON sys.ku$_chunk_list_t TO PUBLIC;
CREATE OR REPLACE PUBLIC SYNONYM ku$_chunk_list_t FOR sys.ku$_chunk_list_t;

CREATE OR REPLACE TYPE sys.ku$_java_t FORCE AS OBJECT
(
  type_num              number,
  flags                 number,
  properties            number,
  raw_chunk_count       number,
  total_raw_byte_count  number, 
  text_chunk_count      number,
  total_text_byte_count number,
  raw_chunk             sys.ku$_chunk_list_t,
  text_chunk            sys.ku$_chunk_list_t
)
NOT PERSISTABLE
/
GRANT EXECUTE ON sys.ku$_java_t TO PUBLIC;
CREATE OR REPLACE PUBLIC SYNONYM ku$_java_t FOR sys.ku$_java_t;

-- UDTs for pre/post-table action code

CREATE OR REPLACE TYPE sys.ku$_taction_t FORCE AS OBJECT
(
  text  varchar2(32000)
)
NOT PERSISTABLE
/
GRANT EXECUTE ON sys.ku$_taction_t TO PUBLIC;
CREATE OR REPLACE PUBLIC SYNONYM ku$_taction_t FOR sys.ku$_taction_t;

CREATE OR REPLACE TYPE sys.ku$_taction_list_t FORCE
IS TABLE OF (sys.ku$_taction_t)
NOT PERSISTABLE
/ 
GRANT EXECUTE ON sys.ku$_taction_list_t TO PUBLIC;
CREATE OR REPLACE PUBLIC SYNONYM ku$_taction_list_t FOR sys.ku$_taction_list_t;

-- Types used internally by mdAPI
---------------------------------
-- Schema object audit settings are stored in tab$, etc. as a 38-byte
-- field named audit$ where each byte corresponds to a different access
-- type. This encoding is difficult for xsl to decode and process, 
-- so the function GET_AUDIT in this package unpacks the field into
-- a nested table of ku$_audobj_t objects, each of which has the setting
-- for one access type.

CREATE OR REPLACE TYPE sys.ku$_audobj_t FORCE AS OBJECT
(
  name          VARCHAR2(31),   -- operation to be audited, e.g., ALTER
  value         CHAR(1),        -- 'S' = by session
                                -- 'A' = by access
                                -- '-' = no auditing
  type          CHAR(1)         -- 'S' = when successful
                                -- 'F' = when not successful
)
NOT PERSISTABLE
/
GRANT EXECUTE ON sys.ku$_audobj_t TO PUBLIC;
CREATE OR REPLACE PUBLIC SYNONYM ku$_audobj_t FOR sys.ku$_audobj_t;

CREATE OR REPLACE TYPE sys.ku$_audit_list_t FORCE IS TABLE OF (sys.ku$_audobj_t)
NOT PERSISTABLE
/
GRANT EXECUTE ON sys.ku$_audit_list_t TO public;
CREATE OR REPLACE PUBLIC SYNONYM ku$_audit_list_t FOR sys.ku$_audit_list_t;

-- For storing default auditing options 

CREATE OR REPLACE TYPE sys.ku$_auddef_t FORCE AS OBJECT
(
  name          VARCHAR2(31),   -- operation to be audited, e.g., ALTER
  value         CHAR(1),        -- 'S' = by session
                                -- 'A' = by access
                                -- '-' = no auditing
  type          CHAR(1)         -- 'S' = when successful
                                -- 'F' = when not successful
)
NOT PERSISTABLE
/
GRANT EXECUTE ON sys.ku$_auddef_t TO PUBLIC;
CREATE OR REPLACE PUBLIC SYNONYM ku$_auddef_t FOR sys.ku$_auddef_t;

CREATE OR REPLACE TYPE sys.ku$_audit_default_list_t FORCE
IS TABLE OF (sys.ku$_auddef_t)
NOT PERSISTABLE
/
GRANT EXECUTE ON sys.ku$_audit_default_list_t TO public;
CREATE OR REPLACE PUBLIC SYNONYM ku$_audit_default_list_t FOR sys.ku$_audit_default_list_t;

-- ADT for list of columns for OR storage of xmltype
CREATE OR REPLACE TYPE ku$_XmlColSet_t FORCE IS TABLE OF (NUMBER)
NOT PERSISTABLE
/
GRANT EXECUTE ON sys.ku$_XmlColSet_t TO PUBLIC;
CREATE OR REPLACE PUBLIC SYNONYM ku$_XmlColSet_t FOR sys.ku$_XmlColSet_t;

-- ADT for list of type names for Anydata column stored unpacked
CREATE OR REPLACE TYPE sys.ku$_Unpacked_AnyData_t FORCE
IS TABLE OF (varchar2(2000)) NOT PERSISTABLE;
/
GRANT EXECUTE ON sys.ku$_Unpacked_AnyData_t TO PUBLIC;
CREATE OR REPLACE PUBLIC SYNONYM ku$_Unpacked_AnyData_t FOR sys.ku$_Unpacked_AnyData_t;

-- UDTs for lines of source
CREATE OR REPLACE TYPE sys.ku$_source_t FORCE AS OBJECT
(
  obj_num       number,                                     /* object number */
  line          number,                                       /* line number */
  --
  -- The next 2 attributes are used by XSL scripts to edit the source line.
  -- E.g., in a type definition, the line might be 'type foobar as object' --
  -- 'foobar' is the object name.  Since the xsl script has already
  -- generated CREATE OR REPLACE TYPE FOOBAR, it uses 'post_name_off'
  -- to extract the useful part of the line.  If the source were
  -- create type /* this is a comment
  --  that continues on the next line */
  --  foobar
  -- which is rare but legal, the xsl script knows from 'pre_name' which
  -- lines are prior to the name and can safely be discarded.
  -- See bug 2844111 and rdbms/xml/xsl/kusource.xsl.
  pre_name      number,    /* 1 = this line is prior to line containing name */
  post_name_off number,   /* 1-based offset of 1st non-space char after name */
  post_keyw     number,   /* the offset of post keyword */
  pre_name_len  number,   /* length between keyword and name */
  --
  -- The next attribute is needed for appending the SQL terminator.
  -- If the last line ends in a newline, we simply add the "/";
  -- otherwise, we must insert a newline before the "/".
  -- This attribute is NULL for all but the last line; for the last
  -- line it is "Y" if the line ends in a newline, "N" otherwise.
  trailing_nl   char(1),
  -- The next field is part of the fix for bug #9223960.  Since the alter
  -- type statement will execute separately from the create type statement,
  -- the 'alter type name' part of the statement is replaced with the following
  -- 'alter type schema.typename' followed by the rest of the statement.
  post_atname_off number,        /* 1st non-space char after alter type name */
  -- Improve fix for bug #9223960 (bug #17952171) requires two more fields:
  atname_off    number,           /* offset of 1st char of alter type 'name' */
  new_version   number,   /* 1: if 1st line from new version of type, else 0 */
  source        varchar2(4000)                                /* source line */
)
NOT PERSISTABLE
/
GRANT EXECUTE ON sys.ku$_source_t TO PUBLIC
/
CREATE OR REPLACE PUBLIC SYNONYM ku$_source_t FOR sys.ku$_source_t;
CREATE OR REPLACE TYPE ku$_source_list_t FORCE AS TABLE OF (sys.ku$_source_t)
NOT PERSISTABLE;
/
GRANT EXECUTE ON ku$_source_list_t TO PUBLIC
/
CREATE OR REPLACE PUBLIC SYNONYM ku$_source_list_t FOR sys.ku$_source_list_t;


-------------------------------------------------------------------------------
--                              SCHEMA OBJECTS
-------------------------------------------------------------------------------

-- UDT for schema objects.  Based on obj$
create or replace type ku$_schemaobj_t force as object
(
  obj_num       number,                                     /* object number */
  dataobj_num   number,                          /* data layer object number */
  owner_num     number,                                 /* owner user number */
  owner_name    varchar2(128),                                 /* owner name */
  name          varchar2(128),                                /* object name */
  namespace     number,                               /* namespace of object */
  subname       varchar2(128),                    /* subordinate to the name */
  type_num      number,                                       /* object type */
  type_name     varchar2(128),                           /* object type name */
  ctime         varchar2(19),                        /* object creation time */
  mtime         varchar2(19),                       /* DDL modification time */
  stime         varchar2(19),           /* specification timestamp (version) */
  status        number,                                  /* status of object */
  remoteowner   varchar2(128),          /* remote owner name (remote object) */
  linkname      varchar2(128),                  /* link name (remote object) */
  flags         number,                                             /* flags */
    /* flag definitions from kqd.h */
    /* KQDOBFDOM  0x01                                                      */
    /* KQDOBTMP   0x02                                  object is temporary */
    /* KQDOBFGEN  0x04                           object is system generated */
    /* KQDOBFUNB  0x08              object is unbound (has invokers rights) */
    /* KQDOBSCO   0x10                                   secondary object - */
                                   /* currently only used for domain indexes */
    /* KQDOBIMT   0x20                                 in-memory temp table */
    /* KQDOBFPKJ  0x40                          permanently kept java class */
    /* KQDOBRBO   0x80                                Object in Recycle Bin */
    /* KQDOBSYP   0x100                            synonym has VPD policies */
    /* KQDOBGRP   0x200                              synonym has VPD groups */
    /* KQDOBCVX   0x400                             synonym has VPD context */
    /* KQDOBCRD   0x800                           object is cursor duration */
/* NOTE: Flags 0x1000 - 0xf000 are reserved for object invalidation reasons */
    /* KQDOBFITE  0x1000               object's dependency type has evolved */
    /* KQDOBDFV   0x2000                            Disable fast validation */

                                    /*Using these two flags for misc purposes*/
    /* KQDOBNTP   0x4000                  object is a nested table parition */
    /* KQDOBOBERR 0x8000                           object has objerror$ row */

    /* KQDOBF_MD_LINK  0x10000    Metadata Link or a Metadata-Linked Object */
    /* KQDOBF_OBJ_LINK 0x20000        Object Link or a Object-Linked Object */
    /* KQDOBF_COMMON_OBJECT (KQDOBF_MD_LINK | KQDOBF_OBJ_LINK)

    /* KQDOBLID   0x40000                     object uses a long identifier */
    /* KQDOBFASTTABUPG 0x80000               allow fast alter table upgrade */
    /* KQDOBNE    0x100000            object marked not editionable by user */
    /* KQDOSIVK   0x200000                special invoker rights: see kkxrca */
    /* KQDOBORCL  0x400000                      is an Oracle-supplied object */
    /* KQDONFD    0x800000                    no fine-grained dep for object */
  oid           raw(16),        /* OID for typed table, typed view, and type */
  spare1        number,
  spare2        number,
  spare3        number,                              /* 11.2 original owner# */
  spare4        varchar2(1000),
  spare5        varchar2(1000),
  spare6        varchar2(19),
  owner_name2   varchar2(128),                   /* 11.2 original owner_name */
/* columns added in 12.1 */
  signature     raw(16),
  spare7        number,
  spare8        number,
  spare9        number,
/* columns added in 12.2 */
  dflcollname   varchar2(128),            /* unit-level default collation id */
  spare10       number,
  spare11       number,
  spare12       varchar2(1000),
  spare13       varchar2(1000),
  spare14       timestamp
)
not persistable
/

-------------------------------------------------------------------------------
--                              STORAGE
-------------------------------------------------------------------------------

-- ADT for storage characteristics
create or replace type ku$_storage_t force as object
(
  file_num      number,                        /* segment header file number */
  block_num     number,                       /* segment header block number */
  type_num      number,                                      /* segment type */
  ts_num        number,                       /* tablespace for this segment */
  transportable number,       /* 1 if tablspace in transportable set, else 0 */
  blocks        number,                /* blocks allocated to segment so far */
                                           /* zero for bitmapped tablespaces */
  extents       number,               /* extents allocated to segment so far */
  iniexts       number,                               /* initial extent size */
  minexts       number,                         /* minimum number of extents */
  maxexts       number,                         /* maximum number of extents */
  extsize       number,                          /* current next extent size */
                                           /* zero for bitmapped tablespaces */
  extpct        number,                             /* percent size increase */
  user_num      number,                        /* user who owns this segment */
  lists         number,                        /* freelists for this segment */
  groups        number,                  /* freelist groups for this segment */
  bitmapranges  number,                          /* ranges per bit map entry */
  cachehint     number,                                 /* hints for caching */
  scanhint      number,                                /* hints for scanning */
  hwmincr       number,                      /* Amount by which HWM is moved */
  flags         number,                                     /* Segment flags */
  /* These flags are defined in ktscts.h. Significant flags are        */
                   /* #define KTSSEGM_FLAG_COMPRESSED 0x0800    (2048) */
                   /* #define KTSSEGM_FLAG_OLTP  0x1000000  (16777216) */
                   /* #define KTSSEGM_FLAG_ARCH1 0x2000000  (33554432) */
                   /* #define KTSSEGM_FLAG_ARCH2 0x4000000  (67108864) */
                   /* #define KTSSEGM_FLAG_ARCH3 0x8000000 (134217728) */
  flags2        number,                                     /* various flags */
  spare2        number
)
not persistable
/

-- UDT for deferred storage characteristics
-- (from dcore.bsq)
create or replace type ku$_deferred_stg_t force as object
(
  obj_num       number,                            /* object number */
  pctfree_stg   number,                                  /* PCTFREE */
  pctused_stg   number,                                  /* PCTUSED */
  size_stg      number,                                     /* SIZE */
  initial_stg   number,                                  /* INITIAL */
  next_stg      number,                                     /* NEXT */
  minext_stg    number,                               /* MINEXTENTS */
  maxext_stg    number,                               /* MAXEXTENTS */
  maxsiz_stg    number,                                  /* MAXSIZE */
  lobret_stg    number,                             /* LOBRETENTION */
  mintim_stg    number,                                  /* MIN tim */
  pctinc_stg    number,                              /* PCTINCREASE */
  initra_stg    number,                                 /* INITRANS */
  maxtra_stg    number,                                 /* MAXTRANS */
  optimal_stg   number,                                  /* OPTIMAL */
  maxins_stg    number,                             /* MAXINSTANCES */
  frlins_stg    number,                           /* LISTS/instance */
  flags_stg     number,                                    /* flags */
  bfp_stg       number,                              /* BUFFER_POOL */
  enc_stg       number,                               /* encryption */
  cmpflag_stg   number,                         /* compression type */
  cmplvl_stg    number,                        /* compression level */
  imcflag_stg   number,            /* in-memory columnar (IMC) flag */
  ccflag_stg    number,                 /* columnar cache (CC) flag */
  flags2_stg    number                          /* additional flags */
)
not persistable
/

-------------------------------------------------------------------------------
--                              FILESPEC
-------------------------------------------------------------------------------

-- ADT for filespec

create or replace type ku$_file_t force as object
(
  name          varchar2(923),   /* raw fname:limited to 923 bytes (max OID) */
  fname         varchar2(2050),  /* fixed filename with sgl. ' escaped as '' */
  fsize         number,                            /* size of file in blocks */
  resize        number,                          /* resize of file in blocks */
  maxextend     number,                                 /* maximum file size */
  inc           number,                                 /* increment ammount */
  ts_num        number,                                 /* tablespace number */
  tfstatus      number,                                 /* Temp file status  */
  is_omf        number                   /* 1 if file is an OMF, 0 otherwise */
)
not persistable
/


create or replace type ku$_file_list_t
 force as table of (ku$_file_t)
not persistable
/

-------------------------------------------------------------------------------
--                              TABLESPACE
-------------------------------------------------------------------------------

-- ADT for tablespaces
create or replace type ku$_tablespace_t force as object
(
  vers_major    char(1),                              /* UDT major version # */
  vers_minor    char(2),                              /* UDT minor version # */
  ts_num        number,                      /* tablespace identifier number */
  name          varchar2(128),                         /* name of tablespace */
  owner_num     number,                               /* owner of tablespace */
  status        number,                                            /* status */
                      /* 1 = ONLINE, 2 = OFFLINE, 3 = INVALID, 4 = READ ONLY */
  contents      number,                      /* TEMPORARY = 1 / PERMANENT = 0*/
  undofile_num  number,  /* undo_off segment file number (status is OFFLINE) */
  undoblock_num number,               /* undo_off segment header file number */
  blocksize     number,                            /* size of block in bytes */
  inc_num       number,                      /* incarnation number of extent */
  scnwrp        number,     /* clean offline scn - zero if not offline clean */
  scnbas        number,              /* scnbas - scn base, scnwrp - scn wrap */
  dflminext     number,                 /* default minimum number of extents */
  dflmaxext     number,                 /* default maximum number of extents */
  dflinit       number,                       /* default initial extent size */
  dflincr       number,                          /* default next extent size */
  dflminlen     number,                       /* default minimum extent size */
  dflextpct     number,              /* default percent extent size increase */
  dflogging     number,                         /* default logging attribute */
  affstrength   number,                                 /* Affinity strength */
  bitmapped     number,      /* If not bitmapped, 0 else unit size in blocks */
  plugged       number,                                        /* If plugged */
  directallowed number,    /* Operation which invalidate standby are allowed */
  flags         number,                       /* various flags -  see ktt3.h */
                                     /* 0x01 = system managed allocation     */
                                     /* 0x02 = uniform allocation            */
                                /* if above 2 bits not set then user managed */
                                     /* 0x04 = migrated tablespace           */
                                     /* 0x08 = tablespace being migrated     */
                                     /* 0x10 = undo tablespace               */
                                     /* 0x20 = auto segment space management */
                       /* if above bit not set then freelist segment managed */
                                     /* 0x40 (64) = COMPRESS                 */
                                     /* 0x80 = ROW MOVEMENT                  */
                                     /* 0x100 = SFT                          */
                                     /* 0x200 = undo retention guarantee     */
                                    /* 0x400 = tablespace belongs to a group */
                                  /* 0x800 = this actually describes a group */
                                   /* 0x1000 = tablespace has MAXSIZE set */
                                   /* 0x2000 = enc property initialized */
                                   /* 0x4000 = encrypted tablespace */
            /* 0x8000 = has its own key and not using the default DB enc key */
                                  /* 0x10000 = OLTP Compression */
                                  /* 0x20000 (131072) = ARCH1_COMPRESSION */
                                  /* 0x40000 (262144) = ARCH2_COMPRESSION */
                                  /* 0x80000 (524288) = ARCH3_COMPRESSION */
  flags2        number,                                    /*  flags <63:32> */
                   /* 0x800000000000 = 140737488355328 (32768) LOCAL_ON_LEAF */
                    /* 0x1000000000000= 281474976710656 (65536) LOCAL_ON_ALL */
                                                              /* from ktt3.h */
                                       /* Lost write protection status flags */
  /* #define KTT_LOST_ENABLED  ((ub8)0x20000000 00000000) lost write enabled */
  /* #define KTT_LOST_SUSPEND  ((ub8)0x40000000 00000000) lost write suspend */
  /* #define KTT_LOST_DISABLED ((ub8)0x0)                lost write disabled */
  svcname       varchar(1000),            /* service name for IMC DISTRIBUTE */
  svcflags      number,                  /* service flags for IMC DISTRIBUTE */
  pitrscnwrp    number,                      /* scn wrap when ts was created */
  pitrscnbas    number,                      /* scn base when ts was created */
  ownerinstance varchar(128),                         /* Owner instance name */
  backupowner   varchar(128),                  /* Backup owner instance name */
  groupname     varchar(128),                                  /* Group name */
  spare1        number,                                  /* plug-in SCN wrap */
  spare2        number,                                  /* plug-in SCN base */
  spare3        varchar2(1000),
  spare4        varchar2(19),
  filespec      ku$_file_list_t,
  encryptionalg varchar2(128)                        /* encryption algorithm */
)
not persistable
/

--
-------------------------------------------------------------------------------
--                      SQL COMPILER SWITCHES 
-------------------------------------------------------------------------------
--
create or replace type ku$_switch_compiler_t force as object
(
  obj_num       number,                                     /* object number */
  optlevel      VARCHAR2(4000),
  codetype      VARCHAR2(4000),
  debug         VARCHAR2(4000),
  ccflags       VARCHAR2(4000),
  plscope       VARCHAR2(4000),
  nlsemnt       VARCHAR2(4000)
)
not persistable
/

-------------------------------------------------------------------------------
--                              TYPE
-------------------------------------------------------------------------------
-- 
-- from type$ (dobj.bsq)
create or replace type ku$_simple_type_t force as object
(
  toid          raw(16),                                             /* toid */
  version_num   number,                                /* internal version # */
  version       varchar2(128),                        /* UDT minor version # */
  type_num      number,                      /* type encoding (see sqldef.h) */
  properties    number,                                   /* type properties */
  attribute_num number,                              /* number of attributes */
  local_attrs   number,                        /* number of local attributes */
  method_num    number,                                 /* number of methods */
  hidmethod_num number,                         /* number of hiddend methods */
  typeid        raw(16), /* short typeid value (for non final and sub types) */
  roottoid      raw(16),          /* TOID of root type (null if not subtype) */
  hashcode      raw(17),                                 /* Version hashcode */
  schema_obj    ku$_schemaobj_t,                            /* schema object */
  type_name     varchar2(128)                                   /* type name */
)
not persistable
/

-- from collection$ (dobj.bsq)
create or replace type ku$_collection_t force as object
(
  toid          raw(16),                                             /* TOID */
  version       number,                      /* internal type version number */
  coll_toid     raw(16),            /* collection TOID (TABLE, VARRAY, etc.) */
  coll_version  number,         /* collection type's internal version number */
  elem_toid     raw(16),                                   /* element's TOID */
  elem_version  number,          /* element's type's internal version number */
  synobj        number,                              /* obj# of type synonym */
  properties    number,                             /* element's properties: */
  /* 0x4000 =   16384 = is a PONTER element */
  /* 0x8000 =   32768 = is a REF element */
  /* 0x10000 =  65536  = no NULL is stored with each element */
  /* 0x20000 =  131072 = number/float elements stored in min. fixed size */
  /* 0x40000 =  262144 = number/float elements stored in varying size    */
  charsetid     number,                                  /* character set id */
  charsetform   number,                                /* character set form */
  /* 1 = implicit: for CHAR, VARCHAR2, CLOB w/o a specified set */
  /* 2 = nchar: for NCHAR, NCHAR VARYING, NCLOB */
  /* 3 = explicit: for CHAR, etc. with "CHARACTER SET ..." clause */
  /* 4 = flexible: for PL/SQL "flexible" parameters */
  length        number,                  /* fixed character string length or */
                                  /* maximum varying character string length */
  precision     number,       /* fixed- or floating-point numeric precision */
  scale         number,                         /* fixed-point numeric scale */
  upper_bound   number,     /* fixed array size or varying array upper bound */
  spare1        number,                      /* fractional seconds precision */
  spare2        number,                  /* interval leading field precision */
  spare3        number,
  coll_type     ku$_simple_type_t,           /* type info for the collection */
  typemd        ku$_simple_type_t        /* type info for collection element */
)
not persistable
/

-- type info for Method arguments
--    from argument$ (dplsql.bsq)
create or replace type ku$_argument_t force as object
(
  obj_num        number,                                    /* object number */
  procedure_val  varchar2(128),      /* procedure name (if within a package) */
  overload_num   number,
                /* 0 - not overloaded, n - unique id of overloaded procedure */
  procedure_num  number,                       /* procedure or method number */
  position_num   number,           /* argument position (0 for return value) */
  sequence_num   number,
  level_num      number,
  argument       varchar2(128),     /* argument name (null for return value) */
  type_num       number,                                    /* argument type */
  charsetid      number,                                 /* character set id */
  charsetform    number,                               /* character set form */
  /* 1 = implicit: for CHAR, VARCHAR2, CLOB w/o a specified set */
  /* 2 = nchar: for NCHAR, NCHAR VARYING, NCLOB */
  /* 3 = explicit: for CHAR, etc. with "CHARACTER SET ..." clause */
  /* 4 = flexible: for PL/SQL "flexible" parameters */
  default_num    number,   /* null - no default value, 1 - has default value */
  in_out         number,                   /* null - IN, 1 - OUT, 2 - IN/OUT */
  properties     number,                           /* argument's properties: */
  /* 0x0100 =     256 = IN parameter (pass by value, default) */
  /* 0x0200 =     512 = OUT parameter */
  /* 0x0400 =    1024 = pass by reference parameter */
  /* 0x0800 =    2048 = required parameter (no default) */
  /* 0x4000 =   16384 = is a PONTER parameter */
  /* 0x8000 =   32768 = is a REF parameter */
  length         number,                                      /* data length */
  precision_num  number,                                /* numeric precision */
  scale          number,                                    /* numeric scale */
  radix          number,                                    /* numeric radix */
  deflength      number,             /* default value expression text length */
  default_val    varchar2(4000),            /* default value expression text */
--  default$       long,                    /* default value expression text */
  type_owner     varchar2(128),         /* owner name component of type name */
  type_name      varchar2(128),                                 /* type name */
  type_subname   varchar2(128),            /* subname component of type name */
  type_linkname  varchar2(128),            /* db link component of type name */
  pls_type       varchar2(128)                           /* pl/sql type name */
)
not persistable
/
create or replace type ku$_argument_list_t
 force as table of (ku$_argument_t)
not persistable
/

-- type info for Procedures
--     from method$ (dplsql.bsq)
create or replace type ku$_procinfo_t force as object
(
  obj_num       number,
  procedure_num number,
  objerload_num number,
  procedurename varchar2(128),                             /* procedure name */
  properties    number,                              /* procedure properties */
                /* 0x00001 =     1 = HIDDEN (internally generated) procedure */
                /* 0x00002 =     2 = C implementation (in spec)              */
                /* 0x00004 =     4 = Java implementation (in spec)           */
                /* 0x00008 =     8 = Aggregate function                      */
                /* 0x00010 =    16 = Pipelined function                      */
                /* 0x00020 =    32 = Parallel enabled                        */
                /* 0x00040 =    64 = Retrun Self as result (SQLJ)            */
                /* 0x00080 =   128 = Constructor function (SQLJ)             */
                /* 0x00100 =   256 = deterministic                           */
                /* 0x00200 =   512 = Pipelined func; interface impl          */
                /* 0x00400 =  1024 = Function with invokers rights           */
                /* 0x00800 =  2048 = Func with partitioned argument(s)       */
                /* 0x01000 =  4096 = Func with clustered argument(s)         */
                /* 0x02000 =  8192 = Func with ordered i/p argument(s)       */
                /* 0x04000 =  16384 = Partitioned arg: Hash partitioning     */
                /* 0x08000 = 32768 = Partitioned arg: Range partitioning     */
                /* 0x10000 = 65536 = Partitioned using any partitioning      */
  /* The following field is relevant only for aggregate and pipelined        */
  /*  functions that are implemented using an implementation type            */
  itypeobj_num  number,                 /* implementation type object number */
  spare1        number,
  spare2        number,
  spare3        number,
  spare4        number
)
not persistable
/

-- from dplsql.bsql
create or replace type ku$_procjava_t force as object
( obj_num       number,                 /* spec/body object number */
  procedure_num number,                  /* procedure# or position */
  ownername     varchar2(128),           /* class owner name */
  ownerlength   number,              /* length of class owner name */
  usersignature varchar2(4000),              /* User signature for java */
  usersiglen    number,                /* Length of user signature for java */
  classname     varchar2(4000),           /* method class name */
  classlength   number,             /* length of method class name */
  methodname    varchar2(4000),            /* java method name */
  methodlength  number,              /* length of java method name */
  flags         varchar2(4000),              /* internal flags */
  flagslength   number,                /* length of internal flags */
  cookiesize    number)                                      /* cookie size */
not persistable
/

create or replace type ku$_procc_t force as object
( obj_num        number,                 /* spec/body object number */
  procedure_num   number,                  /* procedure# or position */
  entrypoint_num number)                 /* entrypoint table entry# */
not persistable
/

create or replace type ku$_procplsql_t force as object
( obj_num          number,                 /* spec/body object number */
  procedure_num    number,                  /* procedure# or position */
  entrypoint_num   number)                 /* entrypoint table entry# */
not persistable
/

-- type info for Methods
--     from method$ (dobj.bsq)
create or replace type ku$_method_t force as object
(
  toid           raw(16),                                            /* TOID */
  version_num    number,                     /* internal type version number */
  method_num     number,                        /* method number or position */
  name           varchar2(128),                               /* method name */
  properties     number,                             /* method's properties: */
  /* 0x00001 =      1 = PRIVATE method */
  /* 0x00002 =      2 = PUBLIC method (default) */
  /* 0x00004 =      4 = INLINE method */
  /* 0x00008 =      8 = VIRTUAL method => NOT FINAL */
  /* 0x00010 =     16 = CONSTANT method */
  /* 0x00020 =     32 = contructor method */
  /* 0x00040 =     64 = destructor method */
  /* 0x00080 =    128 = operator method */
  /* 0x00100 =    256 = selfish method */
  /* 0x00200 =    512 = MAP method */
  /* 0x00800 =   2048 = ORDER method */
  /* 0x01000 =   4096 = Read No Data State method (default) */
  /* 0x02000 =   8192 = Write No Data State method */
  /* 0x04000 =  16384 = Read No Process State method */
  /* 0x08000 =  32768 = Write No Process State method */
  /* 0x10000 =  65536 = Not Instantiable method */
  /* 0x20000 = 131072 = Overriding method */
  /* 0x40000 = 262144 = Returns SELF as result */
  parameters_num number,                             /* number of parameters */
  results        number,                                /* number of results */
  xflags         number,                          /* Flags not stored in TDO */
  /* 0x01 - Inherited method */
  spare1         number,                                         /* reserved */
  spare2         number,                                         /* reserved */
  spare3         number,                                         /* reserved */
  externVarName  varchar2(4000),  /*"M_VCSZ" external variable name for SQLJ */
  argument_list  ku$_argument_list_t,            /* argument list for method */
  procedureinfo  ku$_procinfo_t,                           /* procedure info */
  procjava       ku$_procjava_t,                       /*java procedure info */
  procplsql      ku$_procplsql_t,                     /*plsql procedure info */
  procc          ku$_procc_t,                             /*C procedure info */
  obj_num        number
)
not persistable
/
create or replace type ku$_method_list_t
 force as table of (ku$_method_t)
not persistable
/


-- Type attribute info:
--      from attribute$
create or replace type ku$_type_attr_t force as object
(
  toid          raw(16),                                             /* TOID */
  version_num   number,                      /* internal type version number */
  name          varchar2(128),                             /* attribute name */
  attribute_num number,                       /* attribute identifier number */
  attr_vers_num number,        /* attribute's type's internal version number */
  attr_toid     raw(16),                                 /* attribute's TOID */
  synobj_num    number,                              /* obj# of type synonym */
  properties    number,                           /* attribute's properties: */
  /* 0x4000 =   16384 = is a PONTER attribute */
  /* 0x8000 =   32768 = is a REF attribute */
  charsetid     number,                                  /* character set id */
  charsetform   number,                                /* character set form */
  length        number,                  /* fixed character string length or */
                                  /* maximum varying character string length */
  precision_num number,        /* fixed- or floating-point numeric precision */
  scale         number,                         /* fixed-point numeric scale */
  externname    varchar2(4000),        /* field in java class for SQLJ types */
  xflags        number,                           /* flags not stored in TDO */
  /* 0x01 - inherited attribute */
  spare1        number,                      /* fractional seconds precision */
  spare2        number,                  /* interval leading field precision */
  spare3        number,                                          /* reserved */
  spare4        number,                                          /* reserved */
  spare5        number,                                          /* reserved */
  setter        number,                        /* Setter function no. (SQLJ) */
  getter        number,                        /* Getter function no. (SQLJ) */
  typemd        ku$_simple_type_t                           /* schema object */
)
not persistable
/


create or replace type ku$_type_attr_list_t
 force as table of (ku$_type_attr_t)
not persistable
/

-- udt for types
-- Note: ku$_source_list_t is defined in dbmsmetu.sql
create or replace type ku$_type_t force as object
(
  vers_major    char(1),                              /* UDT major version # */
  vers_minor    char(2),                              /* UDT minor version # */
  obj_num       number,                                     /* object number */
  schema_obj    ku$_schemaobj_t,                            /* schema object */
  oid           raw(16),                                             /* toid */
  typeid        raw(16), /* short typeid value (for non final and sub types) */
  version       number,                      /* internal type version number */
  hashcode      raw(17),                                 /* Version hashcode */
  type_num      number,                      /* type encoding (see sqldef.h) */
  properties    number,                                   /* type properties */
  attribute_num number,                              /* number of attributes */
  method_num    number,                                 /* number of methods */
  hidmethod_num number,                         /* number of hiddend methods */
  externtype    number,                                     /* external type */
                                                    /* 1 = SQLData SQLJ type */
                                                /* 2 = CustomDatum SQLJ type */
                                               /* 3 = serializable SQLJ type */
                                      /* 4 = internal serializable SQLJ type */
                                                    /* 5 = ORAData SQLJ type */
  externname    varchar(4000),   /* (M_VCSZ)java class implementing the type */
  source_lines  ku$_source_list_t,                           /* source lines */
  compiler_info ku$_switch_compiler_t,
  supertype_obj ku$_schemaobj_t,                    /* supertype object info */
  collection    ku$_collection_t,                        /* collection$ data */
  attr_list     ku$_type_attr_list_t,                      /* attribute list */
  method_list   ku$_method_list_t
)
not persistable
/



create or replace type ku$_type_body_t force as object
(
  vers_major    char(1),                              /* UDT major version # */
  vers_minor    char(2),                              /* UDT minor version # */
  obj_num       number,                                     /* object number */
  schema_obj    ku$_schemaobj_t,                            /* schema object */
  source_lines  ku$_source_list_t,                           /* source lines */
  compiler_info ku$_switch_compiler_t
)
not persistable
/

create or replace type ku$_full_type_t force as object
(
  vers_major    char(1),                              /* UDT major version # */
  vers_minor    char(2),                              /* UDT minor version # */
  obj_num       number,                                     /* object number */
  schema_obj    ku$_schemaobj_t,                            /* schema object */
  type_t        ku$_type_t,                                   /* type object */
  type_body_t   ku$_type_body_t                          /* type body object */
)
not persistable
/

-- type and view used by export
-- includes base_obj_num (obj# of the type_spec) so that the base_obj_num
-- can be used as a filter

create or replace type ku$_exp_type_body_t force as object
(
  vers_major    char(1),                              /* UDT major version # */
  vers_minor    char(2),                              /* UDT minor version # */
  base_obj_num  number,                                /* base object number */
  obj_num       number,                                     /* object number */
  schema_obj    ku$_schemaobj_t,                            /* schema object */
  source_lines  ku$_source_list_t,                          /* source lines */
  compiler_info ku$_switch_compiler_t
)
not persistable
/

-------------------------------------------------------------------------------
--                              SIMPLE COLUMNS
-------------------------------------------------------------------------------

-- UDT for simple column info. This is the foundation for a number of different
-- column variants and is sufficient for simple column name lists.

create or replace type ku$_simple_col_t force as object
(
  obj_num       number,                      /* object number of base object */
  col_num       number,                          /* column number as created */
  intcol_num    number,                            /* internal column number */
  segcol_num    number,                          /* column number in segment */
  property      number,                     /* column properties (bit flags) */
  property2     number,                /* more column properties (bit flags) */
                   /* the column property bits are defined in qcdl.h        */
                   /* with names beginning "KQLDCOP_" and "KQLDCOP2_"       */
                   /* e.g., KQLDCOP_ATT, KQLDCOP2_ILM   */
  name          varchar2(128),                             /* name of column */
  attrname      varchar2(4000),/* name of type attr. column: null if != type */
  type_num      number,                               /* data type of column */
  deflength     number,    /* virtual column text length (for func. indexes) */
  default_val   varchar2(4000),            /* virtual column expression text */
  default_valc  clob,                      /* virtual column expression text */
  col_expr      sys.xmltype,           /* parsed functional index expression */
  org_colname   varchar2(128)        /* Original partitioned column name for 
                                                           partitioned table */
)
not persistable
/
create or replace type ku$_simple_col_list_t
 force as table of (ku$_simple_col_t)
not persistable
/

-------------------------------------------------------------------------------
--                              INDEX COLUMNS
-------------------------------------------------------------------------------

-- ADT for index columns
create or replace type ku$_index_col_t force as object
(
  obj_num       number,                               /* index object number */
  bo_num        number,                                /* base object number */
  intcol_num    number,                            /* internal column number */
  col           ku$_simple_col_t,                                  /* column */
  pos_num       number,                 /* column position number as created */
  segcol_num    number,                          /* column number in segment */
  segcollen     number,                      /* length of the segment column */
  offset        number,                                  /* offset of column */
  flags         number,                                             /* flags */
  spare2        number,
  spare3        number,
  spare4        varchar2(1000),
  spare5        varchar2(1000),
  spare6        varchar2(19),
  oid_or_setid  number,   /* !0 = hidden unique constraint on OID column (1) */
                                  /* or nested tbl column's SETID column (2) */
  org_col_name  varchar2(128) /* original col name for collation Virtual col */
)
not persistable
/

create or replace type ku$_index_col_list_t force as table of (ku$_index_col_t)
not persistable;
/

-------------------------------------------------------------------------------
--                              LOB COLUMNS
-------------------------------------------------------------------------------
-- UDT for lob/lobfrag index
create or replace type ku$_lobindex_t force as object
(
  obj_num       number,                                          /* object # */
  schema_obj    ku$_schemaobj_t,                            /* schema object */
  ts_name       varchar2(128),                                 /* tablespace */
  blocksize     number,                            /* size of block in bytes */
  storage       ku$_storage_t,                                    /* storage */
  deferred_stg  ku$_deferred_stg_t,                      /* deferred storage */
  dataobj_num   number,                          /* data layer object number */
  cols          number,                                 /* number of columns */
  pct_free      number,          /* minimum free space percentage in a block */
  initrans      number,                     /* initial number of transaction */
  maxtrans      number,                    /* maximum number of transactions */
  pct_thres     number,           /* iot overflow threshold, null if not iot */
  type_num      number,                       /* what kind of index is this? */
  flags         number,                                     /* mutable flags */
  property      number,             /* immutable flags for life of the index */
  blevel        number,                                       /* btree level */
  leafcnt       number,                                  /* # of leaf blocks */
  distkey       number,                                   /* # distinct keys */
  lblkkey       number,                          /* avg # of leaf blocks/key */
  dblkkey       number,                          /* avg # of data blocks/key */
  clufac        number,                                 /* clustering factor */
  analyzetime   varchar2(19),                /* timestamp when last analyzed */
  samplesize    number,                 /* number of rows sampled by Analyze */
  rowcnt        number,                       /* number of rows in the index */
  intcols       number,                        /* number of internal columns */
  degree        number,           /* # of parallel query slaves per instance */
  instances     number,             /* # of OPS instances for parallel query */
  trunccnt      number,                        /* re-used for iots 'inclcol' */
  numcolsdep    number,  /*spare1: number of columns depended on, >= intcols */
  numkeycols    number,       /*spare2 # of key columns in compressed prefix */
  spare3        number,
  spare4        varchar2(1000),     /* used for parameter str for domain idx */
  spare5        varchar2(1000),
  spare6        varchar2(19),
/* columns from ku$_lobfrag_index */
  base_obj_num  number,                                        /* base index */
  part_num      number,                                  /* partition number */
  inclcol       number                     /* iot include col#, null if !iot */
)
not persistable
/

-- ADT for LOB columns
create or replace type ku$_lob_t force as object
(
  obj_num       number,                                /* obj# of base table */
  col_num       number,                                     /* column number */
  intcol_num    number,                            /* internal column number */
  schema_obj    ku$_schemaobj_t,                        /* LOB schema object */
  storage       ku$_storage_t,                          /* LOB storage       */
  deferred_stg  ku$_deferred_stg_t,                      /* deferred storage */
  ts_name       varchar2(128),                            /* tablespace name */
  blocksize     number,                            /* size of block in bytes */
  ind_num       number,                                 /* LOB index obj #   */
  lobindex      ku$_lobindex_t,                          /* LOB index object */
  chunk         number,                    /* oracle blocks in one lob chunk */
  pctversion    number,                                      /* version pool */
  flags         number,                                             /* flags */
                                                 /* 0x0001 = NOCACHE LOGGING */
                                               /* 0x0002 = NOCACHE NOLOGGING */
                                             /* 0x0008 = CACHE READS LOGGING */
                                           /* 0x0010 = CACHE READS NOLOGGING */
  property      number,                    /* 0x00 = user defined lob column */
                                    /* 0x01 = kernel column(s) stored as lob */
                                     /* 0x02 = user lob column with row data */
                                            /* 0x04 = partitioned LOB column */
                                   /* 0x0008 = LOB In Global Temporary Table */
                                          /* 0x0010 = Session-specific table */
  retention     number,                              /* LOB Retention period */
  freepools     number,                             /* LOB segment FREEPOOLS */
  spare1        number,
  spare2        number,
  spare3        varchar2(255),
  /* attributes from lobfarg (partitioned) */
  parent_obj_num number,                             /* parent object number */
  part_obj_num  number,                           /* partition object number */
  base_obj_num  number,                                /* obj# of base table */
  part_num      number                                   /* partition number */
)
not persistable
/
create or replace type ku$_lobfrag_list_t force as table of (ku$_lob_t)
not persistable;
/
-- ADT for table level defaults for LOBs (from partlob$)
create or replace type ku$_partlob_t force as object
(
  obj_num       number,                                /* obj# of base table */
  intcol_num    number,                            /* internal column number */
  schema_obj    ku$_schemaobj_t,            /* LOB schema object (for lobj#) */
  defts_name    varchar2(128),                    /* default tablespace name */
  defblocksize  number,                    /* default size of block in bytes */
  defchunk      number,                    /* oracle blocks in one lob chunk */
  defpctversion number,                              /* default version pool */
  defflags      number,                                             /* flags */
                                                 /* 0x0001 = NOCACHE LOGGING */
                                               /* 0x0002 = NOCACHE NOLOGGING */
                                             /* 0x0008 = CACHE READS LOGGING */
                                           /* 0x0010 = CACHE READS NOLOGGING */
  defpro        number,                        /* default partition property */
                                             /* 0x02 = enable storage in row */
  definiexts    number,  /* default INITIAL extent size; NULL if unspecified */
  defextsize    number,     /* default NEXT extent size; NULL if unspecified */
  defminexts    number,           /* default MINEXTENTS; NULL if unspecified */
  defmaxexts    number,           /* default MAXEXTENTS; NULL if unspecified */
  defextpct     number,          /* default PCTINCREASE; NULL if unspecified */
  deflists      number,      /* default FREELISTS value; NULL if unspecified */
  defgroups     number,      /* default FREELIST GROUPS; NULL if unspecified */
  defbufpool    number,          /* default BUFFER_POOL; NULL if unspecified */
  spare1        number,
  spare2        number,
  spare3        number,
  defmaxsize    number,              /* default MAXSIZE; NULL if unspecified */
  defretention  number,            /* default RETENTION; NULL if unspecified */
  defmintime    number    /* default MIN retention time; NULL if unspecified */
)
not persistable
/

-- UDT for lobfrag index
-- ADT for actual partition- or subpartition-level LOB attributes
-- ADT for partition-level defaults in composite partitioned tables
-- (from lobcomppart$)
create or replace type ku$_lobcomppart_t force as object
(
  obj_num       number,                             /* obj# of LOB partition */
  part_obj_num  number,                     /* table partition object number */
  part_num      number,                                  /* partition number */
  intcol_num    number,                            /* internal column number */
  schema_obj    ku$_schemaobj_t,            /* LOB schema object (for lobj#) */
  defts_name    varchar2(128),                    /* default tablespace name */
  defblocksize  number,                    /* default size of block in bytes */
  defchunk      number,                    /* oracle blocks in one lob chunk */
  defpctversion number,                              /* default version pool */
  defflags      number,                                             /* flags */
                                                           /* 0x0000 = CACHE */
                                                 /* 0x0001 = NOCACHE LOGGING */
                                               /* 0x0002 = NOCACHE NOLOGGING */
                                             /* 0x0008 = CACHE READS LOGGING */
                                           /* 0x0010 = CACHE READS NOLOGGING */
  defpro        number,                        /* default partition property */
                                             /* 0x02 = enable storage in row */
  definiexts    number,  /* default INITIAL extent size; NULL if unspecified */
  defextsize    number,     /* default NEXT extent size; NULL if unspecified */
  defminexts    number,           /* default MINEXTENTS; NULL if unspecified */
  defmaxexts    number,           /* default MAXEXTENTS; NULL if unspecified */
  defextpct     number,          /* default PCTINCREASE; NULL if unspecified */
  deflists      number,      /* default FREELISTS value; NULL if unspecified */
  defgroups     number,      /* default FREELIST GROUPS; NULL if unspecified */
  defbufpool    number,          /* default BUFFER_POOL; NULL if unspecified */
  spare1        number,
  spare2        number,
  spare3        number,
  defmaxsize    number,              /* default MAXSIZE; NULL if unspecified */
  defretention  number,            /* default RETENTION; NULL if unspecified */
  defmintime    number    /* default MIN retention time; NULL if unspecified */
)
not persistable
/

create or replace type ku$_lobcomppart_list_t force
as table of (ku$_lobcomppart_t)
not persistable
/

Rem
Rem Lob information for template subpartition lob store as clause
Rem
create or replace type ku$_tlob_comppart_t force as object
(
  base_objnum    number,                           /* object number of table */
  colname        varchar2(128),
  intcol_num     number,                      /* column number of lob column */
  spart_pos      number,                            /* subpartition position */
  flags          number,          /* Type of lob column - 1 varray, 2 opaque */
  lob_spart_name varchar2(132),         /* segment name for lob subpartition */
  ts_name        varchar2(128),         /* tablespace name (if any) assigned */
  ts_num         number                      /* tablespace (if any) assigned */
)
not persistable
/

create or replace type ku$_tlob_comppart_list_t force
as table of (ku$_tlob_comppart_t)
not persistable
/


-------------------------------------------------------------------------------
-- for Checking sub-partition were created via 
--the tables's subpartition template clause.
-- using for function check_match_template 
-------------------------------------------------------------------------------
create or replace type ku$_temp_subpart_t force as object
(
  obj_num       number,                             /* obj# of subpartition */
  ts_num        number,
  pobj_num      number,     /* object# of partition containing subpartition */
  subpartno     number,
  bhiboundval   blob
)
not persistable
/
create or replace type ku$_temp_subpartdata_t force as object
(
  obj_num       number,
  spts  number,
  dspts number,
  pdefts number,
  tdefts number,
  udefts number,
  spbnd  blob, -- varchar2(4000),
  dspbnd blob  -- varchar2(4000)
)
not persistable
/
/

create or replace type ku$_temp_subpartlobfrg_t force as object
(
  obj_num     number,  /* parentobj num */
  ts_num      number,
  fragobj_num   number,
  frag_num        number,
  tabfragobj_num  number
)
not persistable
/
create or replace type ku$_temp_subpartlob_t force as object
(
  obj_num         number,
  lpdefts number,
  lfts    number,
  lcdefts number,
  lspdefts number,
  spts     number
)
not persistable
/

-------------------------------------------------------------------------------
--                              ILM POLICIES
-------------------------------------------------------------------------------
-- defined here because used in table (sub)partitions
-- based on dictionary tables ilmpolicy$ and ilmobj$

create or replace type ku$_ilm_policy_t force as object
(
  obj_num       number,                            /* object number of table */
  obj_typ       number,                 /* object type (see KQD.H for types) */
  obj_typ_orig  number,    /* object type on which policy originally defined */
                                                   /* or ts# of tablespace   */
  policy_num    number,                                     /* policy number */
  ilmobj_flag   number,         /* ilmobj$.flag                              */
                                /* 0x0001 - policy on object disabled        */
                                /* 0x0002 - inherited from schema (not used) */
                                /* 0x0003 - inherited from tablespace        */
                                /* also ilm$.flag if object is tablespace    */
                                /* 0x0001 - policy disabled                  */
                                /* 0x0002 - schema-level policy              */
                                /* 0x0008 - tablespace-level policy          */
                                /* 0x0010 - default policy                   */
  actionc       varchar2(100),                              /* action clause */
  ctype         number,         /* compression type: 2 = OLTP; 3 = row level */
  clevel        number,         /* compression level                         */
                                /*  1 = query low                            */
                                /*  2 = query high                           */
                                /*  3 = archive low                          */
                                /*  4 = archive high                         */
  cindex        number,         /* index compression level                   */
                                               /*  0x0001 prefix compression */
                                          /*  0x0002 OLTP compression high   */
                                          /*  0x0003 OLTP compression low    */
  cprefix       number,   /* Number of columns in case of prefix compression */
  clevlob       number,                             /* LOB compression level */
                                                               /* 0x0001 LOW */
                                                            /* 0x0002 MEDIUM */
                                                              /* 0x0003 HIGH */
  tier_tbs      varchar2(128),                      /* Tablespace to tier to */
  action        number,                            /* type of ILM action     */
                                                   /* 0x0001 Compression     */
                                                   /* 0x0002 Storage tiering */
  type          number,                            /* type code  ??????? */
  condition     number,                   /* condition policy is based on    */
                                          /* 0x0000 - last access time       */
                                          /* 0x0001 - low access             */
                                          /* 0x0002 - last modification time */
                                          /* 0x0003 - creation time          */
  days          number,                                    /* number of days */
  scope         number,                                 /* policy scope      */
                                                        /* 0x0001 -  segment */
                                                        /* 0x0002 -  group   */
                                                        /* 0x0003 -  row     */
  custfunc      varchar2(128),                           /* cust. func. name */
  flag          number,                                      /* policy flags */
                                                      /* 0x0001 -  READ-ONLY */
                                                         /* 0x0002 -  unused */
                                                         /* 0x0004 - inplace */
                                                         /* 0x0008 -  custom */
                                                           /* 0x0010 - GROUP */
                                               /* 0x0020 - Row level locking */
  flag2         number,                             /* flag2 - fields unused */
  spare1        number,                                             /* spare */
  spare2        number,                                             /* spare */
  spare3        number,                                             /* spare */
  spare4        varchar2(4000),                                     /* spare */
  spare5        varchar2(4000),                                     /* spare */
  spare6        timestamp,
  pol_subtype   number,
  actionc_clob  clob,
  tier_to       number
)
not persistable
/

create or replace type ku$_ilm_policy_list_t force 
as table of (ku$_ilm_policy_t)
not persistable
/

-- UDT for ALTER TABLESPACE for default ILM policie
create or replace type ku$_tbs_ilm_policy_t force as object
(
  ts_num        number,                      /* tablespace identifier number */
  name          varchar2(128),                         /* name of tablespace */
  ilm_policies  ku$_ilm_policy_list_t                /* default ilm policies */
)
not persistable
/

-------------------------------------------------------------------------------
--                              NESTED TABLE PARTITION
-------------------------------------------------------------------------------

-- UDT for table partition data for partitioned heap nested table
create or replace type ku$_hntp_t force as object
(
  obj_num       number,                              /* obj# of nested table */
  property      number,                                  /* table properties */
  storage       ku$_storage_t,                                    /* storage */
  deferred_stg  ku$_deferred_stg_t,                      /* deferred storage */
  ts_name       varchar2(128),                            /* tablespace name */
  blocksize     number,                            /* size of block in bytes */
  pct_free      number,                   /* min. free space %age in a block */
  pct_used      number,                   /* min. used space %age in a block */
  initrans      number,                     /* initial number of transaction */
  maxtrans      number,                     /* maximum number of transaction */
  flags         number                                              /* flags */
)
not persistable
/

-- UDT for nested table partition
create or replace type ku$_ntpart_t force as object
(
  obj_num       number,                                /* obj# of base table */
  part_num      number,                               /* part# of base table */
  intcol_num    number,              /* internal column number in base table */
  ntab_num      number,              /* object number of nested table object */
  schema_obj    ku$_schemaobj_t,           /* schema object for nested table */
  col           ku$_simple_col_t,                                  /* column */
  property      number,                           /* nested table properties */
  flags         number,                                /* nested table flags */
  hnt           ku$_hntp_t                      /* heap table partition data */
)
not persistable
/
create or replace type ku$_ntpart_list_t force as table of (ku$_ntpart_t)
not persistable
/

-- UDT for collection of nested table partitions of a parent table
create or replace type ku$_ntpart_parent_t force as object
(
  obj_num       number,                                /* obj# of base table */
  part_num      number,                     /* part# of base table partition */
  nts           ku$_ntpart_list_t                 /* nested table partitions */
)
not persistable
/

-- for external tables
-- Note: This must be defined before partition related stuff because in v12.2
--       external tables now support partition with locations.

create or replace type ku$_extloc_t force as object
(
  obj_num       number,                          /* base table object number */
  position      number,                               /* this location index */
  dir           varchar2(128),                  /* location directory object */
  name          varchar2(4000)                              /* location name */
)
not persistable
/

create or replace type ku$_extloc_list_t
 force as table of (ku$_extloc_t)
not persistable
/

create or replace type ku$_exttab_t force as object
(
  obj_num       number,                          /* base table object number */
  default_dir   varchar2(128),                          /* default directory */
  type          varchar2(128),                         /* access driver type */
  nr_locations  number,                               /* number of locations */
  reject_limit  number,                                      /* reject limit */
  par_type      number,             /* access parameter type: blob=1, clob=2 */
  param_clob    clob,                      /* access parameters in clob form */
  property      number,            /* 0x01 all cols, 0x02 referenced columns */
  location      ku$_extloc_list_t                      /* external locations */
)
not persistable
/
-------------------------------------------------------------------------------
--                              PARTITIONS
-------------------------------------------------------------------------------

-- ADT for index partitions and subpartitions.  Based on indpart$/indsubpart$
create or replace type ku$_ind_part_t force as object
(
  obj_num       number,                                 /* obj# of partition */
  schema_obj    ku$_schemaobj_t,                            /* schema object */
  ts_num        number,                                 /* tablespace number */
  ts_name       varchar2(128),                                 /* tablespace */
  blocksize     number,                            /* size of block in bytes */
  storage       ku$_storage_t,                    /* storage characteristics */
  deferred_stg  ku$_deferred_stg_t,                      /* deferred storage */
  dataobj_num   number,                          /* data layer object number */
-- only for partitions
  base_obj_num  number,                                        /* base index */
  part_num      number,                                  /* partition number */
  tab_part_name varchar2(128),                       /* table partition name */
  hiboundlen    number,                     /* len. of high bound val. expr. */
  hiboundval    varchar2(4000),                        /* text of high bound */
  hiboundvalc   clob,                             /* clob text of high bound */
  pct_thres     number,                 /* iot overflow thresh. null if !iot */
  inclcol       number,                    /* iot include col#, null if !iot */
  parameters    varchar2(1000),                       /* from indpart_param$ */
-- only for subpartitions
  pobj_num      number,                              /* parent object number */
  subpart_num   number,                               /* subpartition number */
  tab_subpart_name varchar2(128),                 /* table subpartition name */
--
  flags         number,                                             /* flags */
  pct_free      number,                   /* min. free space %age in a block */
  initrans      number,                         /* initial # of transactions */
  maxtrans      number,                            /* max. # of transactions */
  analyzetime   varchar2(19),                     /* timestamp last analyzed */
  samplesize    number,                                     /* for histogram */
  rowcnt        number,                                         /* # of rows */
  blevel        number,                                      /* B-tree level */
  leafcnt       number,                             /* number of leaf blocks */
  distkey       number,                                /* # of distinct keys */
  lblkkey       number,                      /* av. # of leaf blocks per key */
  dblkkey       number,                      /* av. # of data blocks per key */
  clufac        number,                                 /* clustering factor */
  spare1        number,
  spare2        number,
  spare3        number
)
not persistable
/


create or replace type ku$_ind_part_list_t force as table of (ku$_ind_part_t)
not persistable
/

-- ADT for PIOT partitions.  Based on indpart$
create or replace type ku$_piot_part_t force as object
(
  obj_num       number,                                 /* obj# of partition */
  schema_obj    ku$_schemaobj_t,                            /* schema object */
  ts_name       varchar2(128),                                 /* tablespace */
  blocksize     number,                            /* size of block in bytes */
  storage       ku$_storage_t,                    /* storage characteristics */
  deferred_stg  ku$_deferred_stg_t,                      /* deferred storage */
  dataobj_num   number,                          /* data layer object number */
  base_obj_num  number,                                        /* base index */
  part_num      number,                                  /* partition number */
  hiboundlen    number,                     /* len. of high bound val. expr. */
  hiboundval    varchar2(4000),                                 /* text of " */
  hiboundvalc   clob,                                           /* text of " */
  lobs          ku$_lobfrag_list_t,                                  /* lobs */
  flags         number,                                   /* (indpart) flags */
  tp_flags      number,                                     /* tabpart flags */
  pct_free      number,                   /* min. free space %age in a block */
  pct_thres     number,                 /* iot overflow thresh. null if !iot */
  initrans      number,                         /* initial # of transactions */
  maxtrans      number,                            /* max. # of transactions */
  analyzetime   varchar2(19),                     /* timestamp last analyzed */
  samplesize    number,                                     /* for histogram */
  rowcnt        number,                                         /* # of rows */
  blevel        number,                                      /* B-tree level */
  leafcnt       number,                             /* number of leaf blocks */
  distkey       number,                                /* # of distinct keys */
  lblkkey       number,                      /* av. # of leaf blocks per key */
  dblkkey       number,                      /* av. # of data blocks per key */
  clufac        number,                                 /* clustering factor */
  spare1        number,
  spare2        number,
  spare3        number,
  inclcol       number                     /* iot include col#, null if !iot */
)
not persistable
/


create or replace type ku$_piot_part_list_t force as table of (ku$_piot_part_t)
not persistable
/

-- ADT for table partitions.  Based on tabpart$
create or replace type ku$_tab_part_t force as object
(
  obj_num       number,                                     /* object number */
  schema_obj    ku$_schemaobj_t,                            /* schema object */
  ts_name       varchar2(128),                                 /* tablespace */
  blocksize     number,                            /* size of block in bytes */
  storage       ku$_storage_t,                    /* storage characteristics */
  deferred_stg  ku$_deferred_stg_t,                      /* deferred storage */
  dataobj_num   number,                          /* data layer object number */
  base_obj_num  number,                                 /* base table object */
  part_num      number,                                  /* partition number */
  hiboundlen    number,                   /* length of high bound value expr */
  hiboundval    varchar2(4000),             /* text of high bound value expr */
  hiboundvalc   clob,                                           /* text of " */
  lobs          ku$_lobfrag_list_t,                                  /* lobs */
  nt            ku$_ntpart_parent_t,              /* nested table partitions */
  ilm_policies  ku$_ilm_policy_list_t,               /* ilm policies, if any */
  pct_free      number,                   /* min. free space %age in a block */
  pct_used      number,                   /* min. used space %age in a block */
  initrans      number,                         /* initial # of transactions */
  maxtrans      number,                            /* max. # of transactions */
  flags         number,                                             /* flags */
  analyzetime   varchar2(19),                     /* timestamp last analyzed */
  samplesize    number,                          /* samplesize for histogram */
  rowcnt        number,                                    /* number of rows */
  blkcnt        number,                                  /* number of blocks */
  empcnt        number,                            /* number of empty blocks */
  avgspc        number,                      /* average available free space */
  chncnt        number,                            /* number of chained rows */
  avgrln        number,                                /* average row length */
  spare1        number,
  spare2        number,
  spare3        number,
  bhiboundval   blob,                                   /* binary hiboundval */
  phypart_num   number,                         /* physical partition number */
  ext_location  ku$_exttab_t,          /* locations for ext table partitions */
  svcname       varchar(1000),            /* service name for IMC DISTRIBUTE */
  svcflags      number                   /* service flags for IMC DISTRIBUTE */
)
not persistable
/

create or replace type ku$_tab_part_list_t force as table of (ku$_tab_part_t)
not persistable
/

-- ADT for table subpartitions.  Based on tabsubpart$.  These hang off
-- of their parents: table composite partitions.
create or replace type ku$_tab_subpart_t force as object
(
  obj_num       number,                              /* obj# of subpartition */
  schema_obj    ku$_schemaobj_t,                            /* schema object */
  ts_name       varchar2(128),                            /* tablespace name */
  blocksize     number,                            /* size of block in bytes */
  storage       ku$_storage_t,                    /* storage characteristics */
  deferred_stg  ku$_deferred_stg_t,                      /* deferred storage */
  dataobj_num   number,                                   /* data layer obj# */
  pobj_num      number,                          /* obj# of parent partition */
  subpart_num   number,                                     /* subpartition# */
  lobs          ku$_lobfrag_list_t,                                  /* lobs */
  ilm_policies  ku$_ilm_policy_list_t,               /* ilm policies, if any */
  flags         number,                                             /* flags */
  pct_free      number,                      /* min. free space % in a block */
  pct_used      number,                      /* min. used spare % in a block */
  initrans      number,                         /* initial # of transactions */
  maxtrans      number,                            /* max. # of transactions */
  analyzetime   varchar2(19),                /* timestamp when last analyzed */
  samplesize    number,                      /* # of rows sampled by analyze */
  rowcnt        number,                                    /* number of rows */
  blkcnt        number,                                  /* number of blocks */
  empcnt        number,                            /* number of empty blocks */
  avgspc        number,                      /* average available free space */
  chncnt        number,                            /* number of chained rows */
  avgrln        number,                                /* average row length */
  spare1        number,
  spare2        number,
  spare3        number,
  hiboundlen    number,                     /* len. of high bound val. expr. */
  hiboundval    varchar2(4000),                                 /* text of " */
  hiboundvalc   clob,                                      /* clob text of " */
  bhiboundval   blob,                                   /* binary hiboundval */
  phypart_num   number,                      /* physical subpartition number */
  svcname       varchar(1000),            /* service name for IMC DISTRIBUTE */
  svcflags      number,                  /* service flags for IMC DISTRIBUTE */
  ext_location  ku$_exttab_t           /* locations for ext table partitions */
)
not persistable
/


create or replace type ku$_tab_subpart_list_t force
as table of (ku$_tab_subpart_t)
not persistable
/

-- ADT for table template subpartitions.  Based on defsubpart$.  These hang off
-- of their parents: table template subpartitions.
create or replace type ku$_tab_tsubpart_t force as object
(
  base_objnum   number,                            /* Object number of table */
  spart_pos     number,                             /* subpartition position */
  spart_name    varchar2(132),                      /* name assigned by user */
  ts_name       varchar2(128),                            /* tablespace name */
  ts_num        number,                   /* Default tablespace NULL if none */
  flags         number,                             /* as defined in kkpac.h */
  flags2        number,                             /* as defined in kkpac.h */
  hiboundlen    number,              /* high bound text of this subpartition */
  hiboundval    varchar2(4000),                        /* length of the text */
  hiboundvalc   clob,                                      /* clob text of " */
  tlobs         ku$_tlob_comppart_list_t,                            /* lobs */
  bhiboundval   blob,                                   /* binary hiboundval */
  svcname       varchar(1000),            /* service name for IMC DISTRIBUTE */
  svcflags      number                   /* service flags for IMC DISTRIBUTE */
)
not persistable
/

create or replace type ku$_tab_tsubpart_list_t force
as table of (ku$_tab_tsubpart_t)
not persistable
/

-- ADT for table composite partitions.  Based on tabcompart$
create or replace type ku$_tab_compart_t force as object
(
  obj_num       number,                           /* obj# of comp. partition */
  schema_obj    ku$_schemaobj_t,                            /* schema object */
  dataobj_num   number,                          /* data layer object number */
  base_obj_num  number,                                     /* obj# of table */
  part_num      number,                                  /* partition number */
  hiboundlen    number,             /* length of high bound value expression */
  hiboundval    varchar2(4000),       /* text of high-bound value expression */
  hiboundvalc   clob,                                      /* clob text of " */
  ilm_policies  ku$_ilm_policy_list_t,               /* ilm policies, if any */
  subpartcnt    number,                           /* number of subpartitions */
  smatch_tpl    number,                  /* 1 = subpartitions match template */
  subparts      ku$_tab_subpart_list_t,                     /* subpartitions */
  lmatch_tpl    number,                           /* 1 = lobs match template */
  lobs          ku$_lobcomppart_list_t,                              /* lobs */
  flags         number,                                             /* flags */
  defts_name    varchar2(128),                         /* default TABLESPACE */
  defblocksize  number,          /* blocksize in bytes of default TABLESPACE */
  defpctfree    number,                                   /* default PCTFREE */
  defpctused    number,                                   /* default PCTUSED */
  definitrans   number,                                  /* default INITRANS */
  defmaxtrans   number,                                  /* default MAXTRANS */
  definiexts    number,  /* default INITIAL extent size; NULL if unspecified */
  defextsize    number,     /* default NEXT extent size; NULL if unspecified */
  defminexts    number,           /* default MINEXTENTS; NULL if unspecified */
  defmaxexts    number,           /* default MAXEXTENTS; NULL if unspecified */
  defextpct     number,          /* default PCTINCREASE; NULL if unspecified */
  deflists      number,      /* default FREELISTS value; NULL if unspecified */
  defgroups     number,      /* default FREELIST GROUPS; NULL if unspecified */
  deflogging    number,                        /* default LOGGING attribute  */
  defbufpool    number,                         /* default BUFFER_POOL value */
  analyzetime   varchar2(19),                /* timestamp when last analyzed */
  samplesize    number,                          /* samplesize for histogram */
  rowcnt        number,                                    /* number of rows */
  blkcnt        number,                                  /* number of blocks */
  empcnt        number,                            /* number of empty blocks */
  avgspc        number,                      /* average available free space */
  chncnt        number,                            /* number of chained rows */
  avgrln        number,                                /* average row length */
  spare1        number,
  spare2        number,                                  /* compression info */
  /* from dpart.bsq:                              */
  /* Only 2 bytes of spare2 are currently spoken for */
  /* byte 0   : compression attribute of the partition */
  /*            following bit patterns are possible: */
  /*            00000000 : Compression not specified */
  /*            00000001 : Compression enabled for direct load operations */
  /*            00000010 : Compression disabled      */
  /*            00000101 : Compression enabled for all operations */
  /*            00001001 : Archive Compression: level 1 */
  /*            00010001 : Archive Compression: level 2 */
  /*            00011001 : Archive Compression: level 3 */
  /*            00100001 : Archive Compression: level 4 */
  /*            00101001 : Archive Compression: level 5 */
  /*            00110001 : Archive Compression: level 6 */
  /*            00111001 : Archive Compression: level 7 */
  /*            All other bit patterns are incorrect. */
  /* byte 1   : segment creation attributes of the partition */
  /*            00000001 : Deferred segment creation is the default */
  /*            00000010 : Immediate segment creation is the default */
  /*            Other bits can be used as needed */
  spare3        number,
  defmaxsize    number,              /* default MAXSIZE; NULL if unspecified */
  bhiboundval   blob,
  svcname       varchar(1000),            /* service name for IMC DISTRIBUTE */
  svcflags      number,                  /* service flags for IMC DISTRIBUTE */
  ext_location  ku$_exttab_t           /* locations for ext table partitions */
)
not persistable
/

create or replace type ku$_tab_compart_list_t force
as table of (ku$_tab_compart_t)
not persistable
/

-- ADT for index composite partitions.  Based on indcompart$
create or replace type ku$_ind_compart_t force as object
(
  obj_num       number,                           /* obj# of comp. partition */
  schema_obj    ku$_schemaobj_t,                            /* schema object */
  dataobj_num   number,                          /* data layer object number */
  base_obj_num  number,                                     /* obj# of table */
  part_num      number,                                  /* partition number */
  hiboundlen    number,             /* length of high bound value expression */
  hiboundval    varchar2(4000),       /* text of high-bound value expression */
  hiboundvalc   clob,                                      /* clob text of " */
  subpartcnt    number,                           /* number of subpartitions */
  subparts      ku$_ind_part_list_t,                        /* subpartitions */
  flags         number,                                     /* for any flags */
  defts_name    varchar2(128),    /* default TABLESPACE; NULL if unspecified */
  defblocksize  number,          /* blocksize in bytes of default TABLESPACE */
  defpctfree    number,                                   /* default PCTFREE */
  definitrans   number,                                  /* default INITRANS */
  defmaxtrans   number,                                  /* default MAXTRANS */
  definiexts    number,  /* default INITIAL extent size; NULL if unspecified */
  defextsize    number,     /* default NEXT extent size; NULL if unspecified */
  defminexts    number,           /* default MINEXTENTS; NULL if unspecified */
  defmaxexts    number,           /* default MAXEXTENTS; NULL if unspecified */
  defextpct     number,          /* default PCTINCREASE; NULL if unspecified */
  deflists      number,      /* default FREELISTS value; NULL if unspecified */
  defgroups     number,         /* default FREELIST GROUPS (N/A for indexes) */
  deflogging    number,                         /* default LOGGING attribute */
  defbufpool    number,                         /* default BUFFER_POOL value */
  analyzetime   varchar2(19),                /* timestamp when last analyzed */
  samplesize    number,                          /* samplesize for histogram */
  rowcnt        number,                                    /* number of rows */
  blevel        number,                                      /* B-tree level */
  leafcnt       number,                             /* number of leaf blocks */
  distkey       number,                           /* number of distinct keys */
  lblkkey       number,             /* average number of leaf blocks per key */
  dblkkey       number,             /* average number of data blocks per key */
  clufac        number,                                 /* clustering factor */
  spare1        number,
  spare2        number,
  spare3        number,
  defmaxsize    number               /* default MAXSIZE; NULL if unspecified */
)
not persistable
/

create or replace type ku$_ind_compart_list_t force
as table of (ku$_ind_compart_t)
not persistable
/

-- ADT for partitioning columns.  Based on partcol$
create or replace type ku$_part_col_t force as object
(
  obj_num       number,                      /* object number of base object */
  intcol_num    number,                            /* internal column number */
  col           ku$_simple_col_t,       /* the column object */
  pos_num       number,                 /* position of col. in key */
  spare1        number                  /* spare column */
)
not persistable
/

create or replace type ku$_part_col_list_t force as table of (ku$_part_col_t)
not persistable
/

-- insert_tsn_list$: for the store-in clause for interval partitioned tables.
-- see dpart.bsq
create or replace type ku$_insert_ts_t force as object
(
  base_obj_num  number,           /* object number of base partitioned table */
  position_num  number,          /* position of tablespace specified by user */
  ts_num        number,                                 /* tablespace number */
  name          varchar2(128)                          /* name of tablespace */
)
not persistable
/
create or replace type ku$_insert_ts_list_t force as table of (ku$_insert_ts_t)
not persistable
/

-- ADT for partitioned objects; included in table/index-specific types.
-- Based on partobj$

create or replace type ku$_partobj_t force as object
(
  obj_num       number,                 /* obj# of partitioned tab. or index */
  parttype      number,                                 /* partitioning type */
             /* 1 = range, 2 = hash, 3 = system 4 = List, 5 = Ref;           */
             /* If range/list/hash, subparttype may be non-zero to indicate  */
             /* type of composite partitioning method.                       */
             /* see subparttype(spare1) for form of subpartitioning used.    */
  partcnt       number,                              /* number of partitions */
  partkeycols   number,                  /* # of columns in partitioning key */
  flags         number,                                             /* flags */
                                    /* 0x01 = local      index      */
                                    /* 0x02 = prefixed   index      */
                                    /* 0x04 = no-align   index      */
                                    /* 0x08 = domain     index      */
                                    /* 0x10 = compressed index      */
                                    /* 0x20 = table has ref ptn'ed children */
                                    /* 0x40 = table is interval partitioned */
                                    /* 0x80 = System managed domain index   */
                                   /* 0x100 = IOT Top index         */
                                   /* 0x200 = LOB column index      */
                                   /* 0x400 = Tracked Table IOT Top index  */
                                   /* 0x800 = Segment creation deferred */
                                  /* 0x1000 = Segment creation immediate */
                /* from kkpac.h:                                             */
                /* LOCAL_INDEX          0x0001 = local partitioned index     */
                /* PREFIXED_INDEX       0x0002 = prefixed index              */
                /* NOALIGN_INDEX        0x0004 = local system part. index    */
                /*                               (alignment means nothing    */
                /*                                because there are          */
                /*                                no part. columns)          */
                /* DOMAIN_INDEX         0x0008 = local domain index          */
                /* COMPRESSED_INDEX     0x0010 = index partitions            */
                /*                               compressed by default       */
  defts_name    varchar2(128),                    /* default tablespace name */
  defblocksize  number,          /* blocksize in bytes of default TABLESPACE */
  defpctfree    number,                                   /* default PCTFREE */
  defpctused    number,                 /* default PCTUSED (N/A for indexes) */
  defpctthres   number,             /* default PCTTHRESHOLD (N/A for tables) */
  definitrans   number,                                  /* default INITRANS */
  defmaxtrans   number,                                  /* default MAXTRANS */
  definiexts    number,                       /* default INITIAL extent size */
  defextsize    number,                          /* default NEXT extent size */
  defminexts    number,                                /* default MINEXTENTS */
  defmaxexts    number,                                /* default MAXEXTENTS */
  defextpct     number,                               /* default PCTINCREASE */
  deflists      number,                           /* default FREELISTS value */
  defgroups     number,         /* default FREELIST GROUPS (N/A for indexes) */
  deflogging    number,           /* default logging attribute of the object */
  defbufpool    number,                         /* default BUFFER_POOL value */
  spare2        number,                    /* subpartitioning info bytes 0-3 */
  /* from dpart.bsq:                              */
  /* 5 bytes of spare2 are currently spoken for */
  /* byte 0   : subparttype - non-zero implies Composite partitioning */
  /*            (1 - Range, 2 - Hash, 3 - System, 4 - List); */
  /* byte 1   : subpartkeycols; */
  /* bytes 2-3: defsubpartcnt */
  /* byte 4   : compression attribute of the partition */
  /*            following bit patterns are possible: */
  /*            00000000 : Compression not specified */
  /*            00000001 : Compression enabled for direct load operations */
  /*            00000010 : Compression disabled      */
  /*            00000101 : Compression enabled for all operations */
  /*            00001001 : Archive Compression: level 1 */
  /*            00010001 : Archive Compression: level 2 */
  /*            00011001 : Archive Compression: level 3 */
  /*            00100001 : Archive Compression: level 4 */
  /*            00101001 : Archive Compression: level 5 */
  /*            00110001 : Archive Compression: level 6 */
  /*            00111001 : Archive Compression: level 7 */
  /*            All other bit patterns are incorrect. */
  imc_flags     number,
  /* Bytes 5 and above from spare2 are now stored in imc_flags.             */
  /*  modular arithmetic used for decoding flags fail wiht large numbers,   */
  /*  due to using floating point.                                          */
  spare3        number,                                     /* spare column  */
  /* byte 1 of spare3 stores dtydef of interval (either DTYNUM, DTYIYM, or
   *  DTYIDS)
   */
  definclcol    number,                          /* default iot include col# */
  defparameters varchar2(1000),                       /* from indpart_param$ */
  /* interval_str and interval_bival new in 11g                              */
  interval_str varchar2(1000),                   /* string of interval value */
  interval_bival raw(200),              /* binary representation of interval */
  insert_ts_list ku$_insert_ts_list_t,      /* store-in list for interval pt */
  defmaxsize    number,                                   /* default MAXSIZE */
  /* New for 12.2, interval support at subpartition level */
  subinterval_str varchar2(1000),        /* string of subpart interval value */
  subinterval_bival raw(200),   /* binary representation of subpart interval */
  svcname       varchar(1000),            /* service name for IMC DISTRIBUTE */
  svcflags      number                   /* service flags for IMC DISTRIBUTE */
)
not persistable
/

-- ADT for partitioned tables

create or replace type ku$_tab_partobj_t force as object
(
  obj_num       number,                         /* obj# of partitioned table */
  partobj       ku$_partobj_t,                     /* Base partitioning info */
  partcols      ku$_part_col_list_t,         /* list of partitioning columns */
  subpartcols   ku$_part_col_list_t,      /* list of subpartitioning columns */
  part_list     ku$_tab_part_list_t,                 /* table partition list */
  compart_list  ku$_tab_compart_list_t,    /* table composite partition list */
  tsubparts     ku$_tab_tsubpart_list_t        /* template subpartition list */
)
not persistable
/

-- ADT for partitioned indexes;

create or replace type ku$_ind_partobj_t force as object
(
  obj_num       number,                 /* obj# of partitioned table */
  partobj       ku$_partobj_t,          /* Base partitioning info */
  partcols      ku$_part_col_list_t,         /* list of partitioning columns */
  subpartcols   ku$_part_col_list_t,      /* list of subpartitioning columns */
  part_list     ku$_ind_part_list_t,                 /* index partition list */
  compart_list  ku$_ind_compart_list_t    /* index composite partition list */
)
not persistable
/

-------------------------------------------------------------------------------
--                              DOMAIN INDEX
-------------------------------------------------------------------------------
-- UDT for domain index's secondary tables
create or replace type ku$_domidx_2ndtab_t force as object
(
  obj_num       number,                            /* object number of index */
  secobj_num    number,                 /* object number of secondary object */
  schema_obj    ku$_schemaobj_t                          /* secondary object */
)
not persistable
/

create or replace type ku$_domidx_2ndtab_list_t
 force as table of (ku$_domidx_2ndtab_t)
not persistable
/

-- ADT for domain index plsql code
create or replace type ku$_domidx_plsql_t force as object
(
  obj_num       number,                 /* object # */
  plsql         ku$_procobj_lines       /* plsql code */
)
not persistable
/

-------------------------------------------------------------------------------
--                              INDEX
-------------------------------------------------------------------------------

-- UDTs for bitmap join index information

create or replace type ku$_jijoin_table_t force as object
(
  obj_num       number,                                          /* object # */
  tabobj_num    number,                                  /* table obj number */
  owner_name    varchar2(128),                                /* table owner */
  name          varchar2(128)                                /* table name  */
)
not persistable
/

create or replace type ku$_jijoin_table_list_t force
as table of  (ku$_jijoin_table_t)
not persistable
/

create or replace type ku$_jijoin_t force as object
(
  obj_num       number,                                          /* object # */
  tab1obj_num   number,                                /* table 1 obj number */
  tab1col_num   number,                /* internal column number for table 1 */
  tab2obj_num   number,                                /* table 2 obj number */
  tab2col_num   number,                /* internal column number for table 2 */
  tab1col       ku$_simple_col_t,                          /* table 1 column */
  tab2col       ku$_simple_col_t,                          /* table 2 column */
  joinop        number,                /* Op code as defined in opndef.h (=) */
  flags         number,                                        /* misc flags */
  tab1inst_num  number,           /* instance of table 1 (for multiple refs) */
  tab2inst_num  number            /* instance of table 2 (for multiple refs) */
)
not persistable
/

create or replace type ku$_jijoin_list_t force as table of (ku$_jijoin_t)
not persistable
/

-- UDT for indexes
create or replace type ku$_index_t force as object
(
  vers_major    char(1),                              /* UDT major version # */
  vers_minor    char(2),                              /* UDT minor version # */
  obj_num       number,                                          /* object # */
  schema_obj    ku$_schemaobj_t,                            /* schema object */
  col_list      ku$_index_col_list_t,               /* list of index columns */
  ts_name       varchar2(128),                                 /* tablespace */
  blocksize     number,                            /* size of block in bytes */
  storage       ku$_storage_t,                                    /* storage */
  deferred_stg  ku$_deferred_stg_t,                      /* deferred storage */
  dataobj_num   number,                          /* data layer object number */
  base_obj_num  number,                                     /* base object # */
  base_obj      ku$_schemaobj_t,                              /* base object */
  anc_obj       ku$_schemaobj_t,           /* Ancestor object - if available */
  indmethod_num number,             /* object # for cooperative index method */
  indtype_name  varchar2(128),                             /* indextype name */
  indtype_owner varchar2(128),                            /* indextype owner */
  secobjs       ku$_domidx_2ndtab_list_t,                /* secondary tables */
  plsql_code    ku$_domidx_plsql_t,               /* domain index plsql code */
  jijoin_tabs   ku$_jijoin_table_list_t, /* jijoin tables if bitmap join idx */
  jijoin        ku$_jijoin_list_t,       /* jijoin data if bitmap join index */
  cols          number,                                 /* number of columns */
  pct_free      number,          /* minimum free space percentage in a block */
  initrans      number,                     /* initial number of transaction */
  maxtrans      number,                    /* maximum number of transactions */
  pct_thres     number,           /* iot overflow threshold, null if not iot */
  type_num      number,                       /* what kind of index is this? */
  flags         number,                                     /* mutable flags */
  property      number,             /* immutable flags for life of the index */
  blevel        number,                                       /* btree level */
  leafcnt       number,                                  /* # of leaf blocks */
  distkey       number,                                   /* # distinct keys */
  lblkkey       number,                          /* avg # of leaf blocks/key */
  dblkkey       number,                          /* avg # of data blocks/key */
  clufac        number,                                 /* clustering factor */
  analyzetime   varchar2(19),                /* timestamp when last analyzed */
  samplesize    number,                 /* number of rows sampled by Analyze */
  rowcnt        number,                       /* number of rows in the index */
  intcols       number,                        /* number of internal columns */
  degree        number,           /* # of parallel query slaves per instance */
  instances     number,             /* # of OPS instances for parallel query */
  trunccnt      number,                        /* re-used for iots 'inclcol' */
  numcolsdep    number,         /* number of columns depended on, >= intcols */
  numkeycols    number,             /* # of key columns in compressed prefix */
  part_obj      ku$_ind_partobj_t,                /* null if not partitioned */
  spare3        number,
  spare4        varchar2(1000),     /* used for parameter str for domain idx */
  spare5        varchar2(1000),
  spare6        varchar2(19),
  for_pkoid     number,                     /* 1 = enabled index for a pkoid */
  for_refpar    number,      /* 1 = used for ref partition parent constraint */
  oid_or_setid  number,        /* !0 = hidden unique index on OID column (1) */
                                  /* or nested tbl column's SETID column (2) */
  base_property number,             /* property flags of base object (table) */
  base_property2 number,
  /* The following fields are used only for {sub}partition promotion (shard) */
  ind_part      ku$_ind_part_t,                /* p2t - index partition info */
  ind_subpart   ku$_ind_part_t,            /* sp2t - index subpartition info */
  tabpart_obj_num number,    /* obj_num of correspoding table {sub}partition */
  ind_part_name varchar(128)   /* index partition for domain_index_partition */
)
not persistable
/

create or replace type ku$_index_list_t force as table of (ku$_index_t)
not persistable;
/

-------------------------------------------------------------------------------
--                              CONSTRAINTS
-------------------------------------------------------------------------------
-- type for columns in constraint.  Only includes attributes
-- required to generate appropriate DDL.
create or replace type ku$_constraint_col_t force as object
(
  con_num       number,                                 /* constraint number */
  obj_num       number,                      /* object number of base object */
  intcol_num    number,                            /* internal column number */
  pos_num       number,                 /* column position number as created */
  spare1        number,                       /* additional constraint flags */
  oid_or_setid  number,   /* !0 = hidden unique constraint on OID column (1) */
                                  /* or nested tbl column's SETID column (2) */
  col           ku$_simple_col_t                                   /* column */
)
not persistable
/

create or replace type ku$_constraint_col_list_t
 force as TABLE of (ku$_constraint_col_t) not persistable;
/

-- Types for non REF/pkREF table/view constraints. Based on con$ and cdef$.
--  (Does not include the spare columns in con$).
-- Ignored types: view WITH READ ONLY(6), cluster hash expr.(8), and
--                REF/pkREF (9,10,13) constraints.
-- We distinguish 3 types of table/view constraint:
-- (1) those which don't need key information to generate DDL
--     (column Not NULL, View WITH CHECK OPTION);
-- (2) those with one set of keys (columns) or a condition expression
--     (primary key, unique key, CHECK, SUpplemental Log Groups) --
--     this kind of constraint is implemented with an index for prim/unique.
--     (also includes the (keyless) Supplemental Log Data 'constraints').
-- (3) those with 2 sets of keys (columns) - referential.

create or replace type ku$_constraint0_t force as object
(
  owner_num     number,                                      /* owner user # */
  name          varchar2(128),                            /* constraint name */
  con_num       number,                                 /* constraint number */
  obj_num       number,                  /* object number of base table/view */
  numcols       number,                   /* number of columns in constraint */
  contype       number,                                   /* constraint type */
                                              /* 5 = view with CHECK OPTION, */
               /* 7 - table check constraint associated with column NOT NULL */
                                  /* 11 - REF/ADT column with NOT NULL const */
  enabled       number,           /* is constraint enabled? NULL if disabled */
  intcols       number,              /* #  of internal columns in constraint */
  mtime         varchar2(19),               /* date this constraint was last
                                                            enabled-disabled */
  flags         number                                              /* flags */
                  /* 0x01 constraint is deferrable */
                  /* 0x02 constraint is deferred */
                  /* 0x04 constraint has been system validated */
                  /* 0x08 constraint name is system generated */
                  /* 0x10 (16) constraint is BAD, depends on current century */
                  /* 0x20 (32) optimizer should RELY on this constraint */
                  /* 0x40 (64) Log Group ALWAYS option */
                  /* 0x80 (128) (view related) constraint is invalid */
                  /* 0x100 (256) constraint depends on a view */
                  /* 0x200 (512) partitioning constraint on FK */
                  /* 0x400 (1024) partitioning constraint on PK/UK */
)
not persistable
/

create or replace type ku$_constraint0_list_t force
as table of (ku$_constraint0_t) not persistable;
/

-- keyed/condition constraint

create or replace type ku$_constraint1_t force as object
(
  owner_num     number,                                      /* owner user # */
  name          varchar2(128),                            /* constraint name */
  con_num       number,                                 /* constraint number */
  obj_num       number,                  /* object number of base table/view */
  property      number,                     /* properties of base table/view */
  property2     number,                     /* properties of base table/view */
  property3     number,                     /* properties of base table/view */
  numcols       number,                   /* number of columns in constraint */
  contype       number,                                   /* constraint type */
                               -- table check (condition-no keys) (1),
                               -- primary key (2),
                               -- unique key (3),
                               -- supplemental log groups (w/ keys) (12),
                               -- supplemental log data (no keys) (14,15,16,17)
  enabled       number,           /* is constraint enabled? NULL if disabled */
  condlength    number,                 /* table check condition text length */
  condition     clob,                          /* table check condition text */
  parsed_cond   sys.xmltype,                 /* parsed table check condition */
  intcols       number,              /* #  of internal columns in constraint */
  mtime         varchar2(19), /* date this constraint was last enabled-disabled */
  flags         number,                                             /* flags */
                   /* see ku$_constraint0_t for flag bit definitions */
  oid_or_setid  number,   /* !0 = hidden unique constraint on OID column (1) */
                                  /* or nested tbl column's SETID column (2) */
  col_list      ku$_constraint_col_list_t,                        /* columns */
  ind           ku$_index_t                                /* index metadata */
)
not persistable
/

create or replace type ku$_constraint1_list_t force
as table of (ku$_constraint1_t) not persistable;
/

-- referential constraint

create or replace type ku$_constraint2_t force as object
(
  owner_num     number,                                      /* owner user # */
  name          varchar2(128),                            /* constraint name */
  con_num       number,                                 /* constraint number */
  obj_num       number,                  /* object number of base table/view */
  numcols       number,                   /* number of columns in constraint */
  contype       number,                                   /* constraint type */
                                                     /* only 4 = referential */
  robj_num      number,                 /* object number of referenced table */
  rcon_num      number,                 /* constraint# of referenced columns */
  rrules        varchar2(3),                 /* future: use this for pendant */
  match_num     number,                 /* referential constraint match type */
  refact        number,                                /* referential action */
  enabled       number,           /* is constraint enabled? NULL if disabled */
  intcols       number,              /* #  of internal columns in constraint */
  mtime         varchar2(19),                    /* date this constraint was */
                                                   /*  last enabled-disabled */
  flags         number,                                             /* flags */
                   /* see ku$_constraint0_t for flag bit definitions */
  schema_obj    ku$_schemaobj_t,                  /* referenced table object */
  src_col_list  ku$_constraint_col_list_t,                 /* source columns */
  tgt_col_list  ku$_constraint_col_list_t                  /* target columns */
)
not persistable
/

create or replace type ku$_constraint2_list_t force
as table of (ku$_constraint2_t) not persistable;
/

-- REF/pkREF constraints
create or replace type ku$_pkref_constraint_t force as object
(
  obj_num       number,                      /* object number of base object */
  col_num       number,                                     /* column number */
  intcol_num    number,                            /* internal column number */
  reftyp        number,                                     /* REF type flag */
                                                     /* 0x01 = REF is scoped */
                                             /* 0x02 = REF stored with rowid */
                                             /* 0x04 = Primary key based ref */
                            /* 0x08 = Unscoped primary key based ref allowed */
        /* 0x10 (16) = ref generated for xdb:SQLInline="false" (bug 6676049) */
  property      number,                     /* column properties (bit flags) */
  name          varchar2(128),                             /* name of column */
  attrname      varchar2(4000),/* name of type attr. column: null if != type */
  schema_obj    ku$_schemaobj_t,                         /* referenced table */
  foreignkey    number,               /* 1= scoped REF is also a foreign key */
  pk_col_list   ku$_simple_col_list_t   /* any pkREF refd. pkey constr. cols */
)
not persistable
/

create or replace type ku$_pkref_constraint_list_t
 force as table of (ku$_pkref_constraint_t) not persistable;
/

create or replace type ku$_constraint_t force as object
(
  vers_major    char(1),                              /* UDT major version # */
  vers_minor    char(1),                              /* UDT minor version # */
  con_num       number,                                 /* constraint number */
  owner_name    varchar2(128),                        /* owner of constraint */
  name          varchar2(128),                         /* name of constraint */
  flags         number,                                             /* flags */
  type_num      number,                                  /* constraint type: */
                            /* 1 = table check, 2 = primary key, 3 = unique, */
                             /* 4 = referential, 5 = view with CHECK OPTION, */
                                                 /* 6 = view READ ONLY check */
               /* 7 - table check constraint associated with column NOT NULL */
                                   /* 8 - hash expressions for hash clusters */
                                         /* 9 - Scoped REF column constraint */
                                    /* 10 - REF column WITH ROWID constraint */
                                  /* 11 - REF/ADT column with NOT NULL const */
                                 /* 12 - Log Groups for supplemental logging */
                                    /* 14 - Primary key supplemental logging */
                                     /* 15 - Unique key supplemental logging */
                                    /* 16 - Foreign key supplemental logging */
                                     /* 17 - All column supplemental logging */
  base_obj_num  number,                                     /* base object # */
  base_obj      ku$_schemaobj_t,            /* base table/view schema object */
  col           ku$_simple_col_t,        /* column info for con 0 constraint */
  con0          ku$_constraint0_t,                       /* con 0 constraint */
  con1          ku$_constraint1_t                        /* con 1 constraint */
)
not persistable
/

-- For stand alone (ALTER TABLE) referential (foreign key) constraints
create or replace type ku$_ref_constraint_t force as object
(
  vers_major    char(1),                              /* UDT major version # */
  vers_minor    char(1),                              /* UDT minor version # */
  con_num       number,                                 /* constraint number */
  owner_name    varchar2(128),                        /* owner of constraint */
  name          varchar2(128),                         /* name of constraint */
  flags         number,                                             /* flags */
  base_obj_num  number,                                     /* base object # */
  base_obj      ku$_schemaobj_t,            /* base table/view schema object */
  con2          ku$_constraint2_t                       /* type 2 constraint */
)
not persistable
/

-------------------------------------------------------------------------------
--                              SEQUENCE
-------------------------------------------------------------------------------
-- 
create or replace type ku$_sequence_t force as object
(
  vers_major    char(1),                              /* UDT major version # */
  vers_minor    char(1),                              /* UDT minor version # */
  obj_num       number,                            /* sequence object number */
  schema_obj    ku$_schemaobj_t,                   /* sequence schema object */
  incre         number,                     /* the sequence number increment */
  minvalue      varchar2(28),                   /* minimum value of sequence */
  maxvalue      varchar2(28),                   /* maximum value of sequence */
  cycle         number,                               /* 0 = FALSE, 1 = TRUE */
  seq_order     number,                               /* 0 = FALSE, 1 = TRUE */
  cache         number,                          /* how many to cache in sga */
  highwater     varchar2(29),                        /* disk high water mark */
  seq_audit     varchar2(38),                            /* auditing options */
  flags         number                               /* 0x08 LOGICAL STANDBY */
                                                           /* 0x16 [NO]SCALE */
                                       /* 0x2048 [NO]EXTEND (only for SCALE) */
)
not persistable
/
---
-------------------------------------------------------------------------------
--                                      IDENTITY COLUMNS
-------------------------------------------------------------------------------
-- Define adt and view for Identity Column support.
create or replace type ku$_identity_col_t force as object
(
  vers_major    char(1),                              /* UDT major version # */
  vers_minor    char(2),                              /* UDT minor version # */
  obj_num       number,                           /* obj# of identity column */
  name          varchar(128),                     /* Name of Identity column */
  property2     number,                    /* identity column property flags */
  intcol_num    number,
  seqobj_num    number,
  start_with    number,
  sequence      ku$_sequence_t
)
not persistable
/
grant execute on ku$_identity_col_t to public
/

-- Identity Column Object type structures;
create or replace type ku$_identity_colobj_t force as object
(
  vers_major    char(1),                              /* UDT major version # */
  vers_minor    char(2),                              /* UDT minor version # */
  obj_num       number,                      /* object number of base object */
  base_obj      ku$_schemaobj_t,                            /* schema object */
  property      number,                     /* column properties (bit flags) */
  property2     number,                        /*    more column properties  */
  identity_col  ku$_identity_col_t               /* Identity Col information */
)
not persistable
/
grant execute on ku$_identity_colobj_t to public
/

-------------------------------------------------------------------------------
--                              TYPED COLUMNS
-------------------------------------------------------------------------------

-- UDTs for typed columns

create or replace type ku$_subcoltype_t force as object
(
  obj_num       number,                               /* obj# of base object */
  intcol_num    number,                            /* internal column number */
  toid          raw(16),                                             /* toid */
  schema_obj    ku$_schemaobj_t,                            /* schema object */
  version       number,                      /* internal type version number */
  hashcode      raw(17),                                 /* Version hashcode */
  typeid        raw(16), /* short typeid value (for non final and sub types) */
  intcols       number,                        /* number of internal columns */
                                          /* storing the exploded ADT column */
  intcol_nums   raw(2000),            /* list of intcol#s of columns storing */
                          /* the unpacked ADT column; stored in packed form; */
                                          /* each intcol# is stored as a ub2 */
  flags         number)                                            /* flags */
                          /* 0x01 - This type was stated in the IS OF clause */
                          /* 0x02 - This type has ONLY in the IS OF clause   */
not persistable
/

create or replace type ku$_subcoltype_list_t force 
as table of (ku$_subcoltype_t)
not persistable
/

create or replace type ku$_coltype_t force as object
(
  obj_num       number,                               /* obj# of base object */
  col_num       number,                                     /* column number */
  intcol_num    number,                            /* internal column number */
  flags         number,                                             /* flags */
  toid          raw(16),                                             /* toid */
  version       number,                      /* internal type version number */
  packed        number,                          /* 0 = unpacked, 1 = packed */
  intcols       number,                        /* number of internal columns */
                                          /* storing the exploded ADT column */
  intcol_nums   raw(2000),            /* list of intcol#s of columns storing */
                          /* the unpacked ADT column; stored in packed form; */
                                          /* each intcol# is stored as a ub2 */
  hashcode      raw(17),                                 /* Version hashcode */
  has_tstz      char(1),        /* 'Y' = this is a varray with TSTZ elements */
  typidcol_num  number,           /* intcol# of the type discriminant column */
  synobj_num    number,              /* obj# of type synonym of the col type */
  syn_name      varchar2(128),                      /* type synonym (if any) */
  syn_owner     varchar2(128),                              /* synonym owner */
  subtype_list  ku$_subcoltype_list_t,                   /* subtype metadata */
  schema_obj    ku$_schemaobj_t,                            /* schema object */
  anydata_list  ku$_Unpacked_AnyData_t      /* types in unpacked anydata col */
)
not persistable
/

-------------------------------------------------------------------------------
--                              XML SCHEMA / OPAQUE TYPE
-------------------------------------------------------------------------------

-- For reasons having to do with compatibility, the XDB objects
-- can't be created by catproc.sql; they must instead be created
-- by a separate script catqm.sql.  Since catmeta.sql is run
-- by catproc.sql, we here create real UDTs for ku$_xmlschema_t
-- and ku$_xmlschema_elmt_t but the corresponding object views
-- are fake.  The real object views are defined in catmetx.sql
-- which is invoked by catqm.sql.

-- UDT for XML Schema

create or replace type ku$_xmlschema_t force as object
(
  vers_major    char(1),                              /* UDT major version # */
  vers_minor    char(2),                              /* UDT minor version # */
  owner_num     number,                                 /* owner user number */
  owner_name    varchar2(128 char),                             /* owner name */
  url           varchar2(700 char),                            /* schema URL */
-- The int_objname will be needed when Data Pump supports XML schemas
-- Fetched by (see catxdbv.sql)
--   xdb.xdb$Extname2Intname(s.xmldata.schema_url,s.xmldata.schema_owner)
--  int_objname varchar2(30),                         /* object name in obj$ */
  schemaoid     raw(16),                                       /* schema OID */
  local         number,        /* used as flags: 1 = set if local            */
                               /*                2 = set if stored as binary */
  schema_level  number,          /* depth of dependence on other xml schemas */
  schema_val    clob,                                /* the XMLSchema itself */
  stripped_val  clob                 /* the XMLSchema with username stripped */
)
not persistable
/

-- UDT for XML Schema element in opaque column

create or replace type ku$_xmlschema_elmt_t force as object
(
  obj_num       number,                                 /* owning table obj# */
  intcol_num    number,                             /* owning column intcol# */
  schemaoid     raw(16),                                   /* schema oid col */
  xmlschema     varchar2(700),                     /* The name of the schema */
  elemnum       number,                                    /* element number */
  element_name  varchar2(256)                     /* The name of the element */
)
not persistable
/

-- UDT for opaque type
create or replace type ku$_opqtype_t force as object
(
  obj_num       number,                               /* obj# of base object */
  intcol_num    number,                            /* internal column number */
  type          number,                            /* The opaque type - type */
                                                           /* 0x01 - XMLType */
  flags         number,                         /* flags for the opaque type */
                              /* -------------- XMLType flags ---------
                               * 0x0001 (1) -- XMLType stored as object
                               * 0x0002 (2) -- XMLType schema is specified
                               * 0x0004 (4) -- XMLType stored as lob
                               * 0x0008 (8) -- XMLType stores extra column
                               *
                               * 0x0020 (32)-- XMLType table is out-of-line
                               * 0x0040 (64)-- XMLType stored as binary
                               * 0x0080 (128)- XMLType binary ANYSCHEMA
                               * 0x0100 (256)- XMLType binary NO non-schema
                               */
  /* Flags for XMLType (type == 0x01). Override them when necessary  */
  lobcol        number,                                        /* lob column */
  objcol        number,                                    /* obj rel column */
  extracol      number,                                    /* extra info col */
  schemaoid     raw(16),                                   /* schema oid col */
  elemnum       number,                                    /* element number */
  schema_elmt   ku$_xmlschema_elmt_t
)
not persistable
/

-------------------------------------------------------------------------------
--                              OID INDEX
-------------------------------------------------------------------------------

-- ADT for OID index (for object tables)
create or replace type ku$_oidindex_t force as object
(
  obj_num       number,                              /* obj# of owning table */
  intcol_num    number,                            /* internal column number */
  name          varchar2(128),                                 /* index name */
  flags         number,                     /* psuedo constraint defer flags */
  storage       ku$_storage_t,                                    /* storage */
  deferred_stg  ku$_deferred_stg_t,                      /* deferred storage */
  ts_name       varchar2(128),                            /* tablespace name */
  blocksize     number,                            /* size of block in bytes */
  pct_free      number,                   /* min. free space %age in a block */
  initrans      number,                     /* initial number of transaction */
  maxtrans      number                      /* maximum number of transaction */
)
not persistable
/

---
-------------------------------------------------------------------------------
--                              TABLE COLUMNS
-------------------------------------------------------------------------------
-- ADT for table columns (column data for COL_LISTtable meatdata)
--   there is a single type, but there are 3 views:
--    ku$_prim_column_view - primitive columns (builtin datatypes except LOBs)
--    ku$_column_view - columns, including LOBs
--    ku$_pcolumn_view -  columns, including LOBs and lob partition info
create or replace type ku$_tab_column_t force as object
(
-- col_comm 
  obj_num       number,                      /* object number of base object */
  col_num       number,                          /* column number as created */
  intcol_num    number,                            /* internal column number */
  segcol_num    number,                          /* column number in segment */
  segcollength  number,                      /* length of the segment column */
  offset        number,                                  /* offset of column */
  property      number,                     /* column properties (bit flags) */
  property2     number,                        /*    more column properties  */
  /* The low 32 bits of col$.property are in "property"; "property2" has     */
  /* the high-order bits. Here are the bit definitions of col$.property:     */
                /* 0x0001 =       1 = ADT attribute column                   */
                /* 0x0002 =       2 = OID column                             */
                /* 0x0004 =       4 = nested table column                    */
                /* 0x0008 =       8 = virtual column                         */
                /* 0x0010 =      16 = nested table's SETID$ column           */
                /* 0x0020 =      32 = hidden column                          */
                /* 0x0040 =      64 = primary-key based OID column           */
                /* 0x0080 =     128 = column is stored in a lob              */
                /* 0x0100 =     256 = system-generated column                */
                /* 0x0200 =     512 = rowinfo column of typed table/view     */
                /* 0x0400 =    1024 = nested table columns setid             */
                /* 0x0800 =    2048 = column not insertable                  */
                /* 0x1000 =    4096 = column not updatable                   */
                /* 0x2000 =    8192 = column not deletable                   */
                /* 0x4000 =   16384 = dropped column                         */
                /* 0x8000 =   32768 = unused column - data still in row      */
            /* 0x00010000 =   65536 = virtual column                         */
            /* 0x00020000 =  131072 = place DESCEND operator on top          */
            /* 0x00040000 =  262144 = virtual column is NLS dependent        */
            /* 0x00080000 =  524288 = ref column (present as oid col)        */
            /* 0x00100000 = 1048576 = hidden snapshot base table column      */
            /* 0x00200000 = 2097152 = attribute column of a user-defined ref */
            /* 0x00400000 = 4194304 = export hidden column,RLS on hidden col */
            /* 0x00800000 = 8388608 = string column measured in characters   */
           /* 0x01000000 = 16777216 = virtual column expression specified    */
           /* 0x02000000 = 33554432 = typeid column                          */
           /* 0x04000000 = 67108864 = Column is encrypted                    */
          /* 0x20000000 = 536870912 = Column is encrypted without salt       */
  /* property2:                                                              */
      /* 0x000800000000 = 34359738368 (8) = default with sequence            */
      /* 0x001000000000 = 68719476736 (16) = default on null                 */
      /* 0x002000000000 = 137438953472 (32) = generated always identity col  */
      /* 0x004000000000 = 274877906944 (64)= generated by default iden col   */
      /* 0x008000000000 = (128)= guard column                                */
  name          varchar2(128),                             /* name of column */
  type_num      number,                               /* data type of column */
  length        number,                         /* length of column in bytes */
  fixedstorage  number,             /* flags: 0x01 = fixed, 0x02 = read-only */
  precision_num number,                                         /* precision */
  scale         number,                                             /* scale */
  not_null      number,                               /* 0 = nulls permitted */
                                                 /* > 0 = no NULLs permitted */
  deflength     number,                   /* default value expr. text length */
  default_val   varchar2(4000),     /* default value expression text <= 4000 */
  default_valc  clob,                /* default value expression text > 4000 */
  parsed_def    sys.xmltype,                    /* parsed default expression */
  binarydefval  clob,                    /* default replace null with clause */
  guard_id      number,                              /* guard col identifier */
  charsetid     number,                              /* NLS character set id */
  charsetform   number,
  con           ku$_constraint0_t,                    /* not null constraint */
  spare1        number,                      /* fractional seconds precision */
  spare2        number,                  /* interval leading field precision */
  spare3        number,
  spare4        varchar2(1000),          /* NLS settings for this expression */
  spare5        varchar2(1000),
  spare6        varchar2(19),
  identity_col  ku$_identity_col_t,              /* Identity Col information */
  evaledition_num number,                       /* evaluation edition number */
  unusablebef_num number,                  /* unusable before edition number */
  unusablebeg_num number,          /* unusable beginning with edition number */
  attrname2     varchar2(4000),  /* Unpacked anydata attrib w/o sys gen name */
  col_sortkey   number,                              /* sort key for columns */
  collname      varchar2(128),                             /* Collation name */
  collintcol_num number,       /* Reference to actual collated column number */
-- col_full / col_prim
  attrname      varchar2(4000),/* name of type attr. column: null if != type */
  fullattrname  varchar2(4000),      /* expanded attrname for DTYNAR columns */
  base_intcol_num number,    /* internal column number of base column, i.e., */
                           /* the intcol# of the first column with this col# */
  base_col_type number, /* base column type: 1 = UDT, 2 = XMLType OR or CSX, */
                        /*                   3 = XMLType as CLOB,  0 = other */
  base_col_name varchar2(128),     /* for any xmltype, name of xmltype column*/

  typemd        ku$_coltype_t,     /* type metadata. null if not a typed col */
  oidindex      ku$_oidindex_t,   /*oidindex if col is OID$ col of obj table */
-- lobs
  lobmd         ku$_lob_t,            /* lob metadata. null if not a lob col */
  opqmd         ku$_opqtype_t,   /* opaque metadata. null if not type opaque */
  plobmd        ku$_partlob_t,   /* part lob metadata. null if not a lob col */
  part_objnum   number                 /* for p2t, original partition objnum */
)
not persistable
/       

create or replace type ku$_tab_column_list_t force
as table of (ku$_tab_column_t)
not persistable
/

-------------------------------------------------------------------------------
-- datapump support for 12c project 32006 
-- Realtime Application-controlled Data Masking (RADM)
-------------------------------------------------------------------------------

-- UDT for the 'RADM_POLICY_EXPR' homogeneous type,
create or replace type ku$_radm_policy_expr_t force as object
(
  vers_major   char(1),                               /* UDT major version # */
  vers_minor   char(1),                               /* UDT minor version # */
  obj_num      number,                           /* expression object number */
  def_onum     number,            /* default policy expression object number */
  ename        varchar2(128),                             /* expression name */
  expr         varchar2(4000),                                 /* expression */
  version      varchar2(30),               /* version that created expression*/
  descr        varchar2(4000),                                /* description */
  compat       varchar2(30),         /* Value of COMPATIBLE at creation time */
  spare1       varchar2(1000),
  spare2       date,
  spare3       timestamp,
  spare4       number,
  spare5       number,
  spare6       number
)
not persistable
/

-- UDT for the 'RADM_MC' homogeneous type,
-- part of 'RADM_POLICY_T' as a list,
-- representing the column specific information for data masking policies 
-- supplied by means of the ALTER_POLICY api.
create or replace type ku$_radm_mc_t force as object
(
  vers_major  char(1),                                /* UDT major version # */
  vers_minor  char(1),                                /* UDT minor version # */
  obj_num     number,                      /* object number of table or view */
  intcol_num  number,                                       /* column number */
  col_name    varchar2(128),                                  /* column name */
  pname       varchar2(128),                                  /* policy name */
  mfunc       number,                   /* RADM masking function (KZRADMMF_) */
  regexp_patt varchar2(512),              /* Data Redaction reg expr pattern */
  regexp_repl Varchar2(4000),      /* Data Redaction reg expr replace string */ 
  regexp_posi number,                    /* Data Redaction reg expr position */
  regexp_occu number,                  /* Data Redaction reg expr occurrence */
  regexp_matc varchar2(10),                 /* Data Redaction reg expr match */
  mparams     varchar2(1000),                     /* RADM masking parameters */
  pe_name     varchar2(128)                   /* RADM policy expression name */
)
not persistable
/

create or replace type ku$_radm_mc_list_t force as table of (ku$_radm_mc_t)
not persistable
/

-- UDT for the 'RADM_POLICY' homogeneous type,
-- xmltag: 'RADM_POLICY_T', XSLT: rdbms/xml/xsl/kuradmp.xsl,
-- representing data masking policies created using DBMS_RADM.ADD_POLICY,
-- and possibly updated using ALTER_POLICY, ENABLE_POLICY, and 
-- DISABLE_POLICY api.

create or replace type ku$_radm_policy_t force as object
(
  vers_major   char(1),                               /* UDT major version # */
  vers_minor   char(1),                               /* UDT minor version # */
  base_obj_num number,                               /* parent object number */
  base_obj     ku$_schemaobj_t,                             /* schema object */
  pname        varchar2(128),                                 /* policy name */
  pexpr        varchar2(4000),                          /* policy expression */
  enable_flag  number,  /* whether the policy is enabled (1) or disabled (0) */
  mc_list      ku$_radm_mc_list_t                    /* column specific data */
)
not persistable
/


-- UDT and object-view for the 'RADM_FPTM' homogeneous type,
-- xmltag: 'RADM_FPTM_T', XSLT: rdbms/xml/xsl/kuradmf.xsl,
-- representing the fixed point values in radm_ftpm$, which are 
-- used to mask the corresponding datatypes.

create or replace type ku$_radm_fptm_t force as object
(
  vers_major   char(1),                               /* UDT major version # */
  vers_minor   char(1),                               /* UDT minor version # */
  numbercol    number,                                             /* number */
  binfloatcol  binary_float,                                 /* binary float */
  bindoublecol binary_double,                               /* binary double */
  charcol      char(1),                              /* fixed-size character */
  varcharcol   varchar2(1),                       /* variable-size character */
  ncharcol     nchar(1),                    /* fixed-size national character */
  nvarcharcol  nvarchar2(1),             /* variable-size national character */
  datecol      date,                                                 /* date */
  ts_col       timestamp,                                       /* timestamp */
  tswtz_col    timestamp with time zone,         /* timestamp with time zone */
  fpver        number               /* version of default fixed point values */
)
not persistable
/

------------------------------------------------------------------------------
--              bug 6938028: Database Vault Protected Schema.
--              Database Vault Protected Schema (DVPS) Interface
--                       for Datapump export/import
--
-- The real Database Vault object views can't be created by catproc.sql; they 
-- must instead be created during the Database Vault installation, because
-- they must be created within the Protected Schema.  Since catmeta.sql is 
-- run by catproc.sql, here we create dummy UDTs (with the names:
-- ku$_dummy_isr_t, ku$_dummy_isrm_t, ku$_dummy_realm_t, 
-- ku$_dummy_realm_member_t, ku$_dummy_realm_auth_t, ku$_dummy_rule_t,
-- ku$_dummy_rule_set_t, ku$_dummy_rule_set_member_t, 
-- ku$_dummy_command_rule_t, ku$_dummy_role_t, ku$_dummy_factor_t,
-- ku$_dummy_factor_link_t, ku$_dummy_factor_type_t, ku$_dummy_identity_t 
-- and ku$_dummy_identity_map_t) and the corresponding dummy object views.
-- The real object views are defined in catmacc.sql, which is invoked by 
-- the Database Vault installation, and are registered in metaview$ by
-- $SRCHOME/rdbms/admin/catmacdd.sql.
-- Note: it's necessary to grant select privilege to the SELECT_CATALOG_ROLE,
-- otherwise the short regression will fail when tkzdicz1.sql runs. This
-- privilege will not be granted on the real views (created by catmacc.sql),
-- as they myst remain accessible only to users with the DV_OWNER role.
-- Project 46812: add ku$_dummy_policy_t, ku$_dummy_policy_obj_r_t,
-- ku$_dummy_policy_obj_c_t, and ku$_dummy_policy_owner_t
-- ku$_dummy_policy_obj_c_alts_t
-- Bug 21299533: add ku$_dummy_dv_auth_dp_t, ku$_dummy_dv_auth_tts_t,
-- ku$_dummy_dv_auth_job_t, ku$_dummy_dv_auth_proxy_t, ku$_dummy_dv_auth_ddl_t,
-- ku$_dummy_dv_auth_prep_t, ku$_dummy_dv_auth_maint_t, ku$_dummy_dv_oradebug_t,
-- and ku$_dummy_dv_accts_t
-- Add ku$_dummy_dv_auth_diag_t for Diagnostic
-- Add ku$_dummy_dv_index_func_t for index functions.
-- Add ku$_dummy_dv_auth_dbcapture_t for DB Replay
-- Add ku$_dummy_dv_auth_dbreplay_t for DB Replay
------------------------------------------------------------------------------
create or replace type ku$_dummy_isr_t force as object
(
  vers_major    char(1),                             /* UDT major version # */
  vers_minor    char(1)                              /* UDT minor version # */
)
not persistable
/

-- The attribute "schema_name" must be included in type ku$_dummy_isrm_t,
-- as we have an entry in the metafilter$ table for the 
-- DVPS_STAGING_REALM_MEMBERSHIP type.
create or replace type ku$_dummy_isrm_t force as object
(
  vers_major    char(1),                             /* UDT major version # */
  vers_minor    char(1),                             /* UDT minor version # */
  schema_name   varchar2(128)    /* schema to be protected by Staging Realm */
)
not persistable
/

-- The attribute "name" must be included in type ku$_dummy_realm_t,
-- as we have an entry in the metafilter$ table for the DVPS_REALM type.
create or replace type ku$_dummy_realm_t force as object
(
  vers_major    char(1),                             /* UDT major version # */
  vers_minor    char(1),                             /* UDT minor version # */
  name          varchar2(128)               /* name of database vault realm */
)
not persistable
/

-- The attribute "name" must be included in type ku$_dummy_realm_member_t,
-- as we have an entry in the metafilter$ table for 
-- the DVPS_REALM_MEMBERSHIP type.
create or replace type ku$_dummy_realm_member_t force as object
(
  vers_major    char(1),                             /* UDT major version # */
  vers_minor    char(1),                             /* UDT minor version # */
  name          varchar2(128)               /* name of database vault realm */
)
not persistable
/

-- The attribute "realm_name" must be included in type ku$_dummy_realm_auth_t,
-- as we have an entry in the metafilter$ table for 
-- the DVPS_REALM_AUTHORIZATION type.
create or replace type ku$_dummy_realm_auth_t force as object
(
  vers_major    char(1),                             /* UDT major version # */
  vers_minor    char(1),                             /* UDT minor version # */
  realm_name    varchar2(128)               /* name of database vault realm */
)
not persistable
/

-- The attribute "rule_name" must be included in type ku$_dummy_rule_t,
-- as we have an entry in the metafilter$ table for the DVPS_RULE type.
create or replace type ku$_dummy_rule_t force as object
(
  vers_major    char(1),                             /* UDT major version # */
  vers_minor    char(1),                             /* UDT minor version # */
  rule_name     varchar2(128)                               /* name of Rule */
)
not persistable
/

-- Attribute "rule_set_name" must be included in type ku$_dummy_rule_set_t,
-- as we have an entry in the metafilter$ table for the DVPS_RULE_SET type.
create or replace type ku$_dummy_rule_set_t force as object
(
  vers_major      char(1),                           /* UDT major version # */
  vers_minor      char(1),                           /* UDT minor version # */
  rule_set_name   varchar2(128)                         /* name of Rule Set */
)
not persistable
/

-- The attribute "rule_set_name" must be included in 
-- type ku$_dummy_rule_set_member_t, as we have an entry in 
-- the metafilter$ table for the DVPS_RULE_SET_MEMBERSHIP type.
create or replace type ku$_dummy_rule_set_member_t force as object
(
  vers_major      char(1),                           /* UDT major version # */
  vers_minor      char(1),                           /* UDT minor version # */
  rule_set_name   varchar2(128)                         /* name of Rule Set */
)
not persistable
/

-- The attribute "rule_set_name" must be included in 
-- type ku$_dummy_command_rule_t, as we have an entry in 
-- the metafilter$ table for the DVPS_COMMAND_RULE type.
create or replace type ku$_dummy_command_rule_t force as object
(
  vers_major      char(1),                           /* UDT major version # */
  vers_minor      char(1),                           /* UDT minor version # */
  rule_set_name   varchar2(128)                         /* name of Rule Set */
)
not persistable
/

create or replace type ku$_dummy_comm_rule_alts_t force as object
(
  vers_major      char(1),                           /* UDT major version # */
  vers_minor      char(1),                           /* UDT minor version # */
  rule_set_name   varchar2(90)                          /* name of Rule Set */
)
not persistable
/

-- The attribute "role" must be included in
-- type ku$_dummy_role_t, as we have an entry in
-- the metafilter$ table for the DVPS_ROLE type.
create or replace type ku$_dummy_role_t force as object
(
  vers_major           char(1),                      /* UDT major version # */
  vers_minor           char(1),                      /* UDT minor version # */
  role                 varchar2(128)                           /* Role name */
)
not persistable
/

-- The attribute "factor_name" must be included in 
-- type ku$_dummy_factor_t, as we have an entry in 
-- the metafilter$ table for the DVPS_FACTOR type.
create or replace type ku$_dummy_factor_t force as object
(
  vers_major           char(1),                      /* UDT major version # */
  vers_minor           char(1),                      /* UDT minor version # */
  factor_name          varchar2(128)                         /* Factor name */
)
not persistable
/

-- The attribute "parent_factor_name" must be included in 
-- type ku$_dummy_factor_link_t, as we have an entry in 
-- the metafilter$ table for the DVPS_FACTOR_LINK type.
create or replace type ku$_dummy_factor_link_t force as object
(
  vers_major           char(1),                      /* UDT major version # */
  vers_minor           char(1),                      /* UDT minor version # */
  parent_factor_name   varchar2(128)                  /* Parent Factor name */
)
not persistable
/

-- The attribute "name" must be included in 
-- type ku$_dummy_factor_type_t, as we have an entry in 
-- the metafilter$ table for the DVPS_FACTOR_TYPE type.
create or replace type ku$_dummy_factor_type_t force as object
(
  vers_major           char(1),                      /* UDT major version # */
  vers_minor           char(1),                      /* UDT minor version # */
  name                 varchar2(128)                    /* Factor type name */
)
not persistable
/

-- The attribute "factor_name" must be included in 
-- type ku$_dummy_identity_t, as we have an entry in 
-- the metafilter$ table for the DVPS_IDENTITY type.
create or replace type ku$_dummy_identity_t force as object
(
  vers_major           char(1),                      /* UDT major version # */
  vers_minor           char(1),                      /* UDT minor version # */
  factor_name          varchar2(128)                    /* Factor type name */
)
not persistable
/

-- The attribute "identity_factor_name" must be included in 
-- type ku$_dummy_identity_map_t, as we have an entry in 
-- the metafilter$ table for the DVPS_IDENTITY_MAP type.
create or replace type ku$_dummy_identity_map_t force as object
(
  vers_major               char(1),                  /* UDT major version # */
  vers_minor               char(1),                  /* UDT minor version # */
  identity_factor_name     varchar2(128)           /* Factor the map is for */
)
not persistable
/

-- For DVPS_DV_POLICY
create or replace type ku$_dummy_policy_t force as object
(
  vers_major               char(1),                  /* UDT major version # */
  vers_minor               char(1),                  /* UDT minor version # */
  name                     varchar2(128)                     /* Policy Name */
)
not persistable
/
-- For DVPS_DV_POLICY_OBJ_R
create or replace type ku$_dummy_policy_obj_r_t force as object
(
  vers_major               char(1),                  /* UDT major version # */
  vers_minor               char(1),                  /* UDT minor version # */
  name                     varchar2(128)                     /* Policy Name */
)
not persistable
/
-- For DVPS_DV_POLICY_OBJ_C
create or replace type ku$_dummy_policy_obj_c_t force as object
(
  vers_major               char(1),                  /* UDT major version # */
  vers_minor               char(1),                  /* UDT minor version # */
  name                     varchar2(128)                     /* Policy Name */
)
not persistable
/
-- For DVPS_DV_POLICY_OWNER
create or replace type ku$_dummy_policy_owner_t force as object
(
  vers_major               char(1),                  /* UDT major version # */
  vers_minor               char(1),                  /* UDT minor version # */
  name                     varchar2(128)                     /* Policy Name */
)
not persistable
/
-- For DVPS_DV_POLICY_OBJ_C_ALTS
create or replace type ku$_dummy_policy_obj_c_alts_t force as object
(
  vers_major               char(1),                  /* UDT major version # */
  vers_minor               char(1),                  /* UDT minor version # */
  name                     varchar2(128)                     /* Policy Name */
)
not persistable
/
-- For DVPS_DV_AUTH_DP
create or replace type ku$_dummy_dv_auth_dp_t force as object
(
  vers_major               char(1),                  /* UDT major version # */
  vers_minor               char(1),                  /* UDT minor version # */
  grantee_name             varchar2(128)                    /* Grantee Name */
)
not persistable
/
-- For DVPS_DV_AUTH_TTS
create or replace type ku$_dummy_dv_auth_tts_t force as object
(
  vers_major               char(1),                  /* UDT major version # */
  vers_minor               char(1),                  /* UDT minor version # */
  grantee_name             varchar2(128)                    /* Grantee Name */
)
not persistable
/
-- For DVPS_DV_AUTH_JOB
create or replace type ku$_dummy_dv_auth_job_t force as object
(
  vers_major               char(1),                  /* UDT major version # */
  vers_minor               char(1),                  /* UDT minor version # */
  grantee_name             varchar2(128)                    /* Grantee Name */
)
not persistable
/
-- For DVPS_DV_AUTH_PROXY
create or replace type ku$_dummy_dv_auth_proxy_t force as object
(
  vers_major               char(1),                  /* UDT major version # */
  vers_minor               char(1),                  /* UDT minor version # */
  grantee_name             varchar2(128)                    /* Grantee Name */
)
not persistable
/
-- For DVPS_DV_AUTH_DDL
create or replace type ku$_dummy_dv_auth_ddl_t force as object
(
  vers_major               char(1),                  /* UDT major version # */
  vers_minor               char(1),                  /* UDT minor version # */
  grantee_name             varchar2(128)                    /* Grantee Name */
)
not persistable
/
-- For DVPS_DV_AUTH_PREP
create or replace type ku$_dummy_dv_auth_prep_t force as object
(
  vers_major               char(1),                  /* UDT major version # */
  vers_minor               char(1),                  /* UDT minor version # */
  grantee_name             varchar2(128)                    /* Grantee Name */
)
not persistable
/
-- For DVPS_DV_AUTH_MAINT
create or replace type ku$_dummy_dv_auth_maint_t force as object
(
  vers_major               char(1),                  /* UDT major version # */
  vers_minor               char(1),                  /* UDT minor version # */
  grantee_name             varchar2(128)                    /* Grantee Name */
)
not persistable
/
-- For DVPS_DV_ORADEBUG
create or replace type ku$_dummy_dv_oradebug_t force as object
(
  vers_major               char(1),                  /* UDT major version # */
  vers_minor               char(1),                  /* UDT minor version # */
  state                    varchar2(128)                           /* state */
)
not persistable
/
-- For DVPS_DV_ACCTS
create or replace type ku$_dummy_dv_accts_t force as object
(
  vers_major               char(1),                  /* UDT major version # */
  vers_minor               char(1),                  /* UDT minor version # */
  state                    varchar2(128)                           /* state */
)
not persistable
/
-- For DVPS_DV_AUTH_DIAG
create or replace type ku$_dummy_dv_auth_diag_t force as object
(
  vers_major               char(1),                  /* UDT major version # */
  vers_minor               char(1),                  /* UDT minor version # */
  grantee_name             varchar2(128)                    /* Grantee Name */
)
not persistable
/

-- For DVPS_DV_INDEX_FUNC
create or replace type ku$_dummy_dv_index_func_t force as object
(
  vers_major    char(1),                             /* UDT major version # */
  vers_minor    char(1),                             /* UDT minor version # */
  object_name   varchar2(128)                           /* name of function */
)
not persistable
/

-- For DVPS_DV_AUTH_DBCAPTURE
create or replace type ku$_dummy_dv_auth_dbcapture_t force as object
(
  vers_major               char(1),                  /* UDT major version # */
  vers_minor               char(1),                  /* UDT minor version # */
  grantee_name             varchar2(128)                    /* Grantee Name */
)
not persistable
/

-- For DVPS_DV_AUTH_DBREPLAY
create or replace type ku$_dummy_dv_auth_dbreplay_t force as object
(
  vers_major               char(1),                  /* UDT major version # */
  vers_minor               char(1),                  /* UDT minor version # */
  grantee_name             varchar2(128)                    /* Grantee Name */
)
not persistable
/

-------------------------------------------------------------------------------
--                              CLUSTERED TABLE
-------------------------------------------------------------------------------
-- UDT for table clustering info
create or replace type ku$_tabcluster_t force as object
(
  obj_num       number,                            /* object number of table */
  schema_obj    ku$_schemaobj_t,                  /* cluster's schema object */
  col_list      ku$_simple_col_list_t           /* list of clustered columns */
)
not persistable
/

-------------------------------------------------------------------------------
--                              TABLE CLUSTERING
-------------------------------------------------------------------------------

-- based on dictionary tables clst$, clstkey$

-- clustering column
create or replace type ku$_clstcol_t force as object
(
  obj_num       number,                            /* object number of table */
  tabobj_num    number,          /* object number of clustering column table */
  schema_obj    ku$_schemaobj_t,                  /* Clustering column table */
  position      number,           /* Position of column in clustering clause */
  groupid       number,                           /* Identifier of the Group */
  col_num       number,                          /* column number as created */
  intcol_num    number,                            /* internal column number */
  segcol_num    number,                          /* column number in segment */
  property      number,                     /* column properties (bit flags) */
  property2     number,                        /*    more column properties  */
  name          varchar2(128),                             /* name of column */
  type_num      number                                /* data type of column */
)
not persistable
/
create or replace type ku$_clstcol_list_t force as table of (ku$_clstcol_t)
not persistable
/

-- cluster join
create or replace type ku$_clstjoin_t force as object
(
  obj_num       number,                                          /* object # */
  tab1obj_num   number,                                /* table 1 obj number */
  int1col_num   number,                /* internal column number for table 1 */
  tab2obj_num   number,                                /* table 2 obj number */
  int2col_num   number,                /* internal column number for table 2 */
  tab1          ku$_schemaobj_t,
  tab2          ku$_schemaobj_t,
  tab1col       ku$_simple_col_t,                          /* table 1 column */
  tab2col       ku$_simple_col_t                           /* table 2 column */
)
not persistable
/

create or replace type ku$_clstjoin_list_t force as table of (ku$_clstjoin_t)
not persistable
/

create or replace type ku$_clst_zonemap_t force as object
(
  obj_num       number,                       /* object number of base table */
  zmowner       varchar2(128),                              /* zonemap owner */
  zmname        varchar2(128)                                /* zonemap name */
)
not persistable
/

-- table clustering
create or replace type ku$_clst_t force as object
(
  obj_num       number,                            /* object number of table */
  clstfunc      number,              /* Clustering Function                  */
                                     /* 1 - Hilbert                          */
                                     /* 2 - Order                            */
  flags         number,            
                                     /* 0x00000001 - Load                    */
                                     /* 0x00000002 - Data Movement           */
  clstcols      ku$_clstcol_list_t,                        /* clustering key */
  clstjoin      ku$_clstjoin_list_t,                         /* cluster join */
  zonemap       ku$_clst_zonemap_t                                /* zonemap */
)
not persistable
/

-- minimal UDT for a table and its clustering info
-- used by data pump to export clustering info separately from table
create or replace type ku$_tabclst_t force as object
(
  base_obj_num  number,                                     /* base object # */
  base_obj      ku$_schemaobj_t,                              /* base object */
  clst          ku$_clst_t                  /* table clustering info, if any */
)
not persistable
/

-------------------------------------------------------------------------------
--                              NESTED TABLE
-------------------------------------------------------------------------------


-- ADT for IOT overflow table
create or replace type ku$_ov_table_t force as object
(
  obj_num       number,                                              /* obj# */
  dataobj_num   number,                                /* data layer object# */
  bobj_num      number,                           /* base obj# (cluster/iot) */
  storage       ku$_storage_t,                                    /* storage */
  deferred_stg  ku$_deferred_stg_t,                      /* deferred storage */
  ts_name       varchar2(128),                            /* tablespace name */
  blocksize     number,                            /* size of block in bytes */
  pct_free      number,                   /* min. free space %age in a block */
  pct_used      number,                   /* min. used space %age in a block */
  initrans      number,                     /* initial number of transaction */
  maxtrans      number,                     /* maximum number of transaction */
  flags         number                                              /* flags */
)
not persistable
/

-- ADT for IOT MAPPING table
create or replace type ku$_map_table_t force as object
(
  obj_num       number,                                              /* obj# */
  dataobj_num   number,                                /* data layer object# */
  bobj_num      number,                           /* base obj# (cluster/iot) */
  part_num      number,                                  /* partition number */
  storage       ku$_storage_t,                                    /* storage */
  ts_name       varchar2(128),                            /* tablespace name */
  blocksize     number,                            /* size of block in bytes */
  pct_free      number,                   /* min. free space %age in a block */
  pct_used      number,                   /* min. used space %age in a block */
  initrans      number,                     /* initial number of transaction */
  maxtrans      number,                     /* maximum number of transaction */
  flags         number                                              /* flags */
)
not persistable
/

-- UDT for table data for heap nested table
create or replace type ku$_hnt_t force as object
(
  obj_num       number,                              /* obj# of nested table */
  partobj       ku$_partobj_t,                     /* Base partitioning info */
  property      number,                                  /* table properties */
  storage       ku$_storage_t,                                    /* storage */
  deferred_stg  ku$_deferred_stg_t,                      /* deferred storage */
  ts_name       varchar2(128),                            /* tablespace name */
  blocksize     number,                            /* size of block in bytes */
  pct_free      number,                   /* min. free space %age in a block */
  pct_used      number,                   /* min. used space %age in a block */
  initrans      number,                     /* initial number of transaction */
  maxtrans      number,                     /* maximum number of transaction */
  flags         number,                                             /* flags */
  con0_list     ku$_constraint0_list_t,               /* list of constraints */
  con1_list     ku$_constraint1_list_t,               /* list of constraints */
  con2_list     ku$_constraint2_list_t,               /* list of constraints */
  pkref_list    ku$_pkref_constraint_list_t  /* list of table ref constraints*/
)
not persistable
/

-- UDT for table data for index organized nested table
create or replace type ku$_iont_t force as object
(
  obj_num       number,                              /* obj# of nested table */
  property      number,                                  /* table properties */
  storage       ku$_storage_t,                                    /* storage */
  deferred_stg  ku$_deferred_stg_t,                      /* deferred storage */
  ts_name       varchar2(128),                            /* tablespace name */
  blocksize     number,                            /* size of block in bytes */
  pct_free      number,                   /* min. free space %age in a block */
  initrans      number,                     /* initial number of transaction */
  maxtrans      number,                     /* maximum number of transaction */
  flags         number,                                             /* flags */
  pct_thresh    number,                            /* pctthreshold for IOTs. */
  numkeycols    number,      /* # of key columns in compressed prefix (IOTs) */
  inclcol_name  varchar(128),/*column where IOT splits into overflow segment */
  con0_list     ku$_constraint0_list_t,               /* list of constraints */
  con1_list     ku$_constraint1_list_t,               /* list of constraints */
  con2_list     ku$_constraint2_list_t,               /* list of constraints */
  pkref_list    ku$_pkref_constraint_list_t, /* list of table ref constraints*/
  iov           ku$_ov_table_t                             /* overflow table */
)
not persistable
/

-- UDT for nested table
create or replace type ku$_nt_t force as object
(
  obj_num       number,                                /* obj# of base table */
  intcol_num    number,              /* internal column number in base table */
  ntab_num      number,              /* object number of nested table object */
  schema_obj    ku$_schemaobj_t,           /* schema object for nested table */
  col           ku$_simple_col_t,                                  /* column */
  property      number,                                  /* table properties */
  flags         number,                                             /* flags */
  trigflag      number,                                     /* trigger flags */
  clst          ku$_clst_t,                 /* table clustering info, if any */
  hnt           ku$_hnt_t,                                /* heap table data */
  iont          ku$_iont_t,                                      /* iot data */
  encalg        number,  /* encryption algorithm id if a column is encrypted */
  intalg        number,   /* integrity algorithm id if a column is encrypted */
  col_list      ku$_tab_column_list_t                     /* list of columns */
)
not persistable
/

create or replace type ku$_nt_list_t force as table of (ku$_nt_t)
not persistable
/

-- UDT for collection of nested tables of a parent table
create or replace type ku$_nt_parent_t force as object
(
  obj_num       number,                                /* obj# of base table */
  nts           ku$_nt_list_t                               /* nested tables */
)
not persistable
/

-------------------------------------------------------------------------------
--                              InMemory COLumn SELective
-------------------------------------------------------------------------------
-- ADT for in memory column selective
create or replace type ku$_im_colsel_t force as object
(
  obj_num       number,                                     /* object number */
  inst_id       number,                                      /* RAC instance */
  column_name   varchar2(129),                                /* Column name */
  compression   varchar2(26),  /* NO INMEMORY or inmemory memcompress clause */
  con_id        number                           /* multitenent container ID */
)
not persistable
/

create or replace type ku$_im_colsel_list_t force as table of (ku$_im_colsel_t)
not persistable
/

-------------------------------------------------------------------------------
--                              TABLE
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Specialized table UDTs/views
-------------------------------------------------------------------------------

-- ORGANIZATION CUBE Tables
create or replace type ku$_cube_fact_t force as object
(
  obj_num  number,                                  /* Parent table object # */
  colname  varchar2(128),                     /* SQL column name (col$.name) */
  pcolname varchar2(128),              /* Parent SQL column name (col$.name) */
  ccolname varchar2(128),               /* COUNT SQL column name (col$.name) */
  obj      varchar2(512),              /* Mapped AW object (aw_obj$.objname) */
  qdr      varchar2(512),       /* QDRing dimension object (aw_obj$.objname) */
  qdrval   varchar2(100),                                     /* QDRed value */
  flags    number                                                   /* Flags */
)
not persistable
/

create or replace type ku$_cube_fact_list_t
 force as table of (ku$_cube_fact_t)
not persistable
/

create or replace type ku$_cube_hier_t force as object
(
  obj_num  number,                                  /* Parent table object # */
  rel      varchar2(512),            /* Mapped AW relation (aw_obj$.objname) */
  qdr      varchar2(512),       /* QDRing dimension object (aw_obj$.objname) */
  qdrval   varchar2(100),                                     /* QDRed value */
  levels   ku$_cube_fact_list_t,                      /* Levels in hierarchy */
  inhier   ku$_cube_fact_list_t,                   /* Mapped AW IN Hierarchy */
  flags    number                                                   /* Flags */
)
not persistable
/

create or replace type ku$_cube_hier_list_t
 force as table of (ku$_cube_hier_t)
not persistable
/

create or replace type ku$_cube_dim_t force as object
(
  obj_num       number,                             /* Parent table object # */
  colname       varchar2(128),               /* Base data column (col$.name) */
  obj           varchar2(512),         /* Mapped AW object (aw_obj$.objname) */
  dimusing      varchar2(512),  /* USING rel for native dt (aw_obj$.objname) */
  gid           ku$_cube_fact_list_t,                                 /* GID */
  pgid          ku$_cube_fact_list_t,                          /* Parent GID */
  attrs         ku$_cube_fact_list_t,                          /* Attributes */
  levels        ku$_cube_fact_list_t,                              /* Levels */
  hiers         ku$_cube_hier_list_t,                         /* Hierarchies */
  flags         number                                              /* Flags */
)
not persistable
/

create or replace type ku$_cube_dim_list_t
 force as table of (ku$_cube_dim_t)
not persistable
/

create or replace type ku$_cube_tab_t force as object
(
  obj_num       number,                             /* Parent table object # */
  awname        varchar2(128),              /* Underlying AW name (aw$.name) */
  flags         number,                                             /* Flags */
  dims          ku$_cube_dim_list_t,                           /* Dimensions */
  facts         ku$_cube_fact_list_t,                            /* Measures */
  cgid          ku$_cube_fact_list_t                             /* Cube GID */
)
not persistable
/

-- flashback archived table info for a table
-- (a subset of info from sys_fba_fa and sys_fba_trackedtables)

create or replace type ku$_fba_t force as object
(
  vers_major    char(1),                              /* UDT major version # */
  vers_minor    char(2),                              /* UDT minor version # */
  obj_num       number,                                        /* table obj# */
  fa_num        number,                               /* flashback archive # */
  fa_name       varchar2(255)                      /* flashback archive name */
)
not persistable
/

-- valid-time temporal information

create or replace type ku$_fba_period_t force as object
(
  vers_major    char(1),                              /* UDT major version # */
  vers_minor    char(2),                              /* UDT minor version # */
  obj_num       number,                                        /* table obj# */
  periodname    varchar2(255),                                /* period name */
  flags         number,
  periodstart   varchar2(255),
  periodend     varchar2(255),
  spare         number
)
not persistable
/

create or replace type ku$_fba_period_list_t
 force as table of (ku$_fba_period_t)
not persistable
/

-------------------------------------------------------------------------------
--                              OBJECT_GRANT
-------------------------------------------------------------------------------

create or replace type ku$_objgrant_t force as object
(
  vers_major    char(1),                              /* UDT major version # */
  vers_minor    char(2),                              /* UDT minor version # */
  obj_num       number,                                 /* obj# of base obj. */
  base_obj      ku$_schemaobj_t,                           /* base obj. info */
  long_name     varchar2(4000),
  grantor       varchar2(128),
  grantee       varchar2(128),
  privname      varchar2(128),
  sequence      number,                        /* Unique seq# for this grant */
  wgo           number,                             /* with grant option = 1 */
                                                /* with hierarchy option = 2 */
  colname       varchar2(128),          /* column name if col grant else null */
  user_spare1   number)
not persistable
/

create or replace type ku$_objgrant_list_t
 force as table of (ku$_objgrant_t)
not persistable
/

-------------------------------------------------------------------------------
--                              SYSTEM_GRANT
-------------------------------------------------------------------------------

create or replace type ku$_sysgrant_t force as object
(
  vers_major    char(1),                              /* UDT major version # */
  vers_minor    char(1),                              /* UDT minor version # */
  privilege     number,                       /* numeric privilege type code */
  grantee       varchar2(128),
  privname      varchar2(128),
  sequence      number,
  wgo           number,
  user_spare1   number)
not persistable
/

create or replace type ku$_on_user_grant_t force as object
(
  vers_major    char(1),                              /* UDT major version # */
  vers_minor    char(2),                              /* UDT minor version # */
  user_name     varchar2(128),                             
  grantor       varchar2(128),
  grantee       varchar2(128),
  sequence      number)                        /* Unique seq# for this grant */
not persistable
/

create or replace type ku$_code_base_grant_t force as object
(
  vers_major    char(1),                              /* UDT major version # */
  vers_minor    char(2),                              /* UDT minor version # */
  role          varchar2(128),                             
  grantee       varchar2(128),          /* Owner of package, procedure, etc. */
  type_name     varchar2(128),         /* Name of code type, ie package name */
  code_type     varchar2(128),      /* Function, Procedure, Package, or Type */
  obj_num       number,                /* Object number of func, proced, etc */
  priv_num      number)                  /* Privilege number, ie role number */

not persistable
/

-------------------------------------------------------------------------------
--                              types for tables
-------------------------------------------------------------------------------

-- ADT for partitioned IOT overflow table partition

create or replace type ku$_ov_tabpart_t force as object
(
  obj_num       number,                                              /* obj# */
  dataobj_num   number,                                /* data layer object# */
  bobj_num      number,                           /* base obj# (cluster/iot) */
  part_num      number,                                  /* partition number */
  storage       ku$_storage_t,                                    /* storage */
  deferred_stg  ku$_deferred_stg_t,                      /* deferred storage */
  ts_name       varchar2(128),                            /* tablespace name */
  blocksize     number,                            /* size of block in bytes */
  pct_free      number,                   /* min. free space %age in a block */
  pct_used      number,                   /* min. used space %age in a block */
  initrans      number,                     /* initial number of transaction */
  maxtrans      number,                     /* maximum number of transaction */
  flags         number                                              /* flags */
)
not persistable
/

create or replace type ku$_ov_tabpart_list_t force
as table of (ku$_ov_tabpart_t) not persistable;
/

create or replace type ku$_map_tabpart_list_t force
as table of (ku$_map_table_t) not persistable;
/
-- ADT for partitioned IOTs

create or replace type ku$_iot_partobj_t force as object
(
  obj_num       number,                                     /* obj# of table */

  tabpartobj    ku$_partobj_t,                       /* table partition info */
  partcols      ku$_part_col_list_t,         /* list of partitioning columns */
  subpartcols   ku$_part_col_list_t,      /* list of subpartitioning columns */



  indpartobj    ku$_partobj_t,                       /* index partition info */
  ovpartobj     ku$_partobj_t,                    /* overflow partition info */
  part_list     ku$_piot_part_list_t,                      /* partition list */
  iov_list      ku$_ov_tabpart_list_t,           /* overflow part table list */
  imap_list     ku$_map_tabpart_list_t            /* mapping part table list */
)
not persistable
/

-------------------------------------------------------------------------------
--                     TABLE
-------------------------------------------------------------------------------

-- create ADTs for tables
-- note on history:
-- we used to have 6 type definitions:
--    htable   simple heap (non-iot) table
--   fhtable   heap table with non-simple columns (mostly ADTs)
--   phtable   partitioned heap table, only simple columns
--  pfhtable   partitioned heap table with non-simple columns
--   iotable    partitioned iot (index organized table)
--  piotable    partitioned iot
-- each type was fully/explicitly defined, with considerable duplication, making
-- implementation of new feature mor cumbersome and error prone.
--
-- We now create just 2 types ku$_table_t and ku$_io_table_t, which differ only
-- for the partition information used. We construct and execute 'create type'
-- statments to reduce code duplication - and have a single place for adding
-- new ADT attributes.
-- With 12.2, we also export of a partition as a table (shard chunk migration).
-- this ueses a 3rd variant of the table type - ku$_partition_t 

declare
  stmt1 varchar(32000);
  stmt2 varchar(32000);
  success_with_error exception;
  pragma exception_init(success_with_error, -24344);
begin
  stmt1 := q'!
 as object
(
  vers_major    char(1),                              /* UDT major version # */
  vers_minor    char(2),                              /* UDT minor version # */
  obj_num       number,                                              /* obj# */
  schema_obj    ku$_schemaobj_t,                            /* schema object */
  base_obj      ku$_schemaobj_t,         /* base object (if secondary table) */
  anc_obj       ku$_schemaobj_t,     /* ancestor object (if secondary table) */
  bobj_num      number,                           /* base obj# (cluster/iot) */
  tab_num       number,                  /* # in cluster, null if !clustered */
  cols          number,                                      /* # of columns */
  clucols       number,                 /* # of clustered cols, if clustered */
  tabcluster    ku$_tabcluster_t,        /* cluster info, null if !clustered */
  fba           ku$_fba_t, /* flashback archive info, null if not fb enabled */
  fba_periods   ku$_fba_period_list_t,                    /* valid-time info */
  clst          ku$_clst_t,                 /* table clustering info, if any */
  ilm_policies  ku$_ilm_policy_list_t,               /* ilm policies, if any */
  flags         number,                                             /* flags */
  audit_val     varchar2(128),                           /* auditing options */
  rowcnt        number,                                    /* number of rows */
  blkcnt        number,                                  /* number of blocks */
  empcnt        number,                            /* number of empty blocks */
  avgspc        number,                      /* average available free space */
  chncnt        number,                            /* number of chained rows */
  avgrln        number,                                /* average row length */
  avgspc_flb    number,       /* avg avail free space of blocks on free list */
  flbcnt        number,                             /* free list block count */
  analyzetime   varchar2(19),                /* timestamp when last analyzed */
  samplesize    number,                 /* number of rows sampled by Analyze */
  degree        number,                       /* # of PQ slaves per instance */
  instances     number,                         /* # of OPS instances for PQ */
  intcols       number,                             /* # of internal columns */
  kernelcols    number,                   /* number of REAL (kernel) columns */
  tstz_cols     char(1),                        /* 'Y' = table has TSTZ data */
  trigflag      number,                              /* inline trigger flags */
  spare1        number,                       /* used to store hakan_kqldtvc */
  spare2        number,         /* committed partition # used by drop column */
  spare3        number,                           /* summary sequence number */
  spare4        varchar2(1000),         /* committed RID used by drop column */
  spare5        varchar2(1000),
  spare6        varchar2(19),                               /* dml timestamp */
  spare7        number,
  spare8        number,
  spare9        varchar2(1000),
  spare10       varchar2(1000),
  encalg        number,  /* encryption algorithm id if a column is encrypted */
  intalg        number,   /* integrity algorithm id if a column is encrypted */
  im_colsel     ku$_im_colsel_list_t,           /* inmemory selective column */
  con0_list     ku$_constraint0_list_t,               /* list of constraints */
  con2_list     ku$_constraint2_list_t,               /* list of constraints */
  exttab        ku$_exttab_t,                     /* external table metadata */
  cubetab       ku$_cube_tab_t,                /* organization cube metadata */
  svcname       varchar(1000),            /* service name for IMC DISTRIBUTE */
  svcflags      number,                  /* service flags for IMC DISTRIBUTE */
  /* table storage (differs for p2t)
     NOTE - properties must also change for p2t */
  property      number,                                  /* table properties */
  property2     number,                             /* more table properties */
            /* the table property bits are defined in qcdl.h and kqld.h      */
            /* with names beginning "KQLDTVCP_" and "KQLDTVCP2_"             */
            /* e.g., KQLDTVCP_TTV,  KQLDTVCP2_ILM_MODTR                      */
  /* The low 32 bits of tab$.property are in "property"; "property2" has     */
  /* the high-order bits. Here are the bit definitions of tab$.property:     */
                   /* 0x01 = typed table */
                   /* 0x02 = has ADT columns, */
                   /* 0x04 = has nested-TABLE columns */
                   /* 0x08 = has REF columns, */
                   /* 0x10     (16) = has array columns */
                   /* 0x20     (32) = partitioned table, */
                   /* 0x40     (64) = index-only table (IOT) */
                   /* 0x80    (128) = IOT w/ row OVerflow, */
                   /* 0x100   (256) = IOT w/ row CLustering */
                   /* 0x200   (512) = IOT OVeRflow segment, */
                   /* 0x400  (1024) = clustered table */
                   /* 0x800  (2048) = has internal LOB columns, */
                   /* 0x1000 (4096) = has primary key-based OID$ column */
                   /* 0x2000 (8192) = nested table */
                   /* 0x4000 (16384) = View is Read Only */
                   /* 0x8000 (32768) = has FILE columns */
                   /* 0x10000 (65536) = obj view OID is sys-generated */
                   /* 0x20000 (131072) = used as AQ table */
                   /* 0x40000 (262144)= has user-defined lob columns */
                   /* 0x80000 (524288)= table contains unused columns */
                   /* 0x100000 (1048576)= has an on-commit materialized view */
                   /* 0x200000 (2097152)= has system-generated column names */
                   /* 0x400000 (4194304)= global temporary table */
                   /* 0x800000 (8388608)= session-specific temporary table */
                   /* 0x8000000 (134217728)= table is a sub table */
                   /* 0x20000000 (536870912) = pdml itl invariant */
                   /* 0x80000000 (2147483648)= table is external  */
  /* property2: High-order bits of tab$.property                             */
  /*  0x000000100000000 (1) - table is a CUBE table                          */
  /*  0x000000400000000 (4) = delayed segment creation                       */
  /*  0x000020000000000 (512) = result cache mode FORCE enabled on this tbl  */
  /*  0x000040000000000 (1024) = result cache mode MANUAL enabled on this tbl*/
  /*  0x000080000000000 (2048) = result cache mode AUTO enabled on this tbl */
  /*  0x020000000000000 (2097152) -                         long varchar col */
  /*  0x00040000000000000   (4194304)-    this table has a clustering clause */
  /*                                        (applies only to the fact table).*/
  /*  0x00080000000000000   (8388608)-   this table has one or more zonemaps */
  /*                                                           defined on it.*/
  /*  0x00400000000000000  (67108864)= has identity column                   */
  /*  0x01000000000000000 (268435456)-     this table appears as a dimension */
  /*                                       in one or more clustering clauses.*/
            /* the table property bits are defined in qcdl.h and kqld.h      */
            /* with names beginning "KQLDTVCP_" and "KQLDTVCP2_"             */
            /* e.g., KQLDTVCP_TTV,  KQLDTVCP2_ILM_MODTR                      */
  property3 number,
           /* the table property bits are defined in qcdl.h and kqld.h       */   
           /* With names beginning KQLDTVCP3_                                */
           /* Here are the bit definitions of tab$.property2:                */
                /* 0x00000001 (1) = Binary XML table uses granular token set */
                /* 0x00000002 (2) = Table is a Binary XML Token Set entity   */
  storage       ku$_storage_t,                                    /* storage */
  deferred_stg  ku$_deferred_stg_t,                      /* deferred storage */
  ts_name       varchar2(128),                            /* tablespace name */
  blocksize     number,                            /* size of block in bytes */
  dataobj_num   number,                                /* data layer object# */
  pct_free      number,                   /* min. free space %age in a block */
  pct_used      number,                   /* min. used space %age in a block */
  initrans      number,                     /* initial number of transaction */
  maxtrans      number,                     /* maximum number of transaction */
  con1_list     ku$_constraint1_list_t,               /* list of constraints */
  /* col_list */
  col_list      ku$_tab_column_list_t,                   /* list of columns */
  /* used for 'full' tables (ADTs and such)  */
  nt            ku$_nt_parent_t,                            /* nested tables */
  pkref_list    ku$_pkref_constraint_list_t, /* list of table ref constraints*/
  /*   xml metadata */
  xmlschemacols char(1),          /* 'Y' = table has xmlschema-based columns */
  xmlcolset     ku$_XmlColSet_t,        /* OR intcolnums for xmltype stoarge */
  xmlhierarchy  char(1),             /* 'Y' = table is xml hierarchy enabled */
  /* reference partition child only */
  parent_obj    ku$_schemaobj_t,          /* parent object (if refpar child) */
  refpar_level  number,                         /* reference partition level */
  /* used for partitioned tables */
  objgrant_list ku$_objgrant_list_t,/* grants required, refpar parent access */
  /* used for IOTs  */
  pct_thresh    number,                            /* pctthreshold for IOTs. */
  numkeycols    number,      /* # of key columns in compressed prefix (IOTs) */
  inclcol_name  varchar(128),/*column where IOT splits into overflow segment */
  iov           ku$_ov_table_t,                            /* overflow table */
  maptab        ku$_map_table_t,                            /* mapping table */
!';
-- '
  begin
  -- include heap table partition info 
  stmt2 := 'create or replace type ku$_table_t force ' || stmt1 ||
           '  part_obj      ku$_tab_partobj_t ) not persistable';
  execute immediate stmt2;
 exception
  when success_with_error then
    null;
 end;
 begin
  -- include io table partition info 
  execute immediate 'create or replace type ku$_io_table_t force' || stmt1 ||
  '  part_obj      ku$_iot_partobj_t ) not persistable';
 exception
  when success_with_error then
    null;
 end;
 begin
  -- include sharding partition info 
  stmt2 := 'create or replace type ku$_partition_t force' || stmt1 ||
  '  tabpart       ku$_tab_part_t,                    /* table partition */
  subpart       ku$_tab_subpart_t                  /* table subpartition */) 
  not persistable';
  execute immediate stmt2;
 exception
  when success_with_error then
    null;
 end;
end;
/

-------------------------------------------------------------------------------
--                     TABLE_OBJNUM, TABLE_TYPES, DOMIDX_OBJNUM
-------------------------------------------------------------------------------

create or replace type ku$_table_objnum_t force as object
(
  obj_num       number,                                              /* obj# */
  objnum_name   varchar(128),                 /* name associated with objnum */
  table_type    varchar2(1),         /* 'T' = base table, 'N' = nested table */
                                  /* 'X' = nested table belonging to XMLtype */
  property      number,                                    /* table property */
  property2     number,                                    /* table property */
  ts_num        number,                                          /* tab$.ts# */
  schema_obj    ku$_schemaobj_t,                            /* schema object */
  base_obj      ku$_schemaobj_t             /* base object (if nested table) */
)
not persistable
/

-------------------------------------------------------------------------------
--                     INDEX_OBJNUM
-------------------------------------------------------------------------------

create or replace type ku$_index_objnum_t force as object
(
  obj_num       number,                                              /* obj# */
  schema_obj    ku$_schemaobj_t,                            /* schema object */
  ts_name       varchar2(128),                                 /* tablespace */
  ts_num        number,                                          /* tab$.ts# */
  type_num      number,                       /* what kind of index is this? */
  flags         number,                                     /* mutable flags */
  property      number,             /* immutable flags for life of the index */
  for_pkoid     number,                     /* 1 = enabled index for a pkoid */
  for_refpar    number,      /* 1 = used for ref partition parent constraint */
  base_obj_num  number,                                         /* base obj# */
  base_obj      ku$_schemaobj_t             /* base object (if nested table) */
)
not persistable
/

-------------------------------------------------------------------------------
--                     OPTION_OBJNUM
-------------------------------------------------------------------------------

create or replace type ku$_option_objnum_t force as object
(
  obj_num       number,                                              /* obj# */
  table_type    varchar2(1),         /* 'T' = base table, 'N' = nested table */
                                  /* 'X' = nested table belonging to XMLtype */
  schema_obj    ku$_schemaobj_t,                            /* schema object */
  tgt_type      number,                                             /* type# */
  impc_flags    number,           /* export processing flags: See dtools.bsq */
  tag           varchar2(128),                  /* optional group identifier */
  beginning_tgt_version varchar2(14),    /* 1st RDBMS version for which this */
        /* registration applies; i.e, applies to this and all later versions */
  ending_tgt_version    varchar2(14),    /* 1st RDBMS version for which this */
      /* registration does *not* apply; i.e, applies to all earlier versions */
  alt_name      varchar2(128),     /* alt name for tgt_object at import time */
  alt_schema    varchar2(128)    /* alt schema for tgt_object at import time */
)
not persistable
/

-------------------------------------------------------------------------------
--                     MARKER
-------------------------------------------------------------------------------

create or replace type ku$_marker_t force as object
(
  vers_major    char(1),                              /* UDT major version # */
  vers_minor    char(2),                              /* UDT minor version # */
  marker        number                                        /* marker type */
)
not persistable
/

-------------------------------------------------------------------------------
--                     MV_DEPTBL_OBJNUM
-- mv_deptbl_objnum view is used to find materialized view temp log tables
--  which must be exported with mv logs in transportable mode.
-------------------------------------------------------------------------------

create or replace type ku$_mv_deptbl_objnum_t force as object
(
  obj_num       number                                             /* obj# */
)
not persistable
/

-------------------------------------------------------------------------------
--                              TABLE DATA
-------------------------------------------------------------------------------

-- global temporary table for x$ktfbue data
--  for use in computing bytes allocated
-- using the temporary table is much faster than going 
--  against sys.x$ktfbue directly

create global temporary table sys.ku$xktfbue (
 ktfbuesegtsn                                       number,
 ktfbuesegfno                                       number,
 ktfbuesegbno                                       number,
 ktfbueblks                                         number
) on commit preserve rows;

create index sys.ku$xktfbue_i
  on sys.ku$xktfbue(ktfbuesegtsn,ktfbuesegfno,ktfbuesegbno);

--  UDT for bytes allocated/table or partition

create or replace type ku$_bytes_alloc_t force as object
(
  file_num      number,                        /* segment header file number */
  block_num     number,                       /* segment header block number */
  ts_num        number,                       /* tablespace for this segment */
  bytes_alloc   number                     /* total number of bytes allocated */
)
not persistable
/

create or replace type ku$_tab_bytes_alloc_t force as object
(
  obj_num       number,                                /* table object number */
  bytes_alloc   number                     /* total number of bytes allocated */
)
not persistable
/

-- UDTs for the TABLE_DATA object type.

create or replace type ku$_table_data_t force as object
(
  vers_major    char(1),                              /* UDT major version # */
  vers_minor    char(2),                              /* UDT minor version # */
  obj_num       number,                                              /* obj# */
  dataobj_num   number,                                /* data layer object# */
                                       /* hashed partitioned tables use obj# */
  name          varchar2(128),                                /* object name */
  part_name     varchar2(128),/* partition name (if object is a subpartition)*/
  parttype      number,                               /* (sub)partition type */
  property      number,                                    /* table property */
  property2     number,                                    /* table property */
  trigflag      number,                   /* the other table property column */
  xmltype_fmts  number,  /* formats of XMLType columns: 0x01=CLOB; 0x02=BLOB */
  xmlschemacols char(1),          /* 'Y' = table has xmlschema-based columns */
  xml_outofline char(1),          /* 'Y' = table has xmlschema-based columns
                                    and table data is out of line (max is 1) */
  longcol       char(1),         /* 'Y' = table has a long column (max is 1) */
  nft_varray    char(1), /*'Y' = table has varray column with non-final type */
  nonscoped_ref char(1),       /* 'Y' = table has column with non-scoped ref */
  tstz_cols     char(1),                        /* 'Y' = table has TSTZ data */
  schema_obj    ku$_schemaobj_t,                            /* schema object */
  ts_name       varchar2(128),                            /* tablespace name */
  ts_num        number,                                 /* tablespace number */
  blocksize     number,                            /* size of block in bytes */
  bytes_alloc   number,                   /* total number of bytes allocated */
  base_obj      ku$_schemaobj_t,            /* base table/view schema object */
  domidx_obj    ku$_schemaobj_t,        /* domain index (if secondary table) */
  anc_obj       ku$_schemaobj_t, /* base obj of dom idx (if secondary table) */
  unload_method number,              /* Direct Path preferred or ET required */
  et_parallel   number,                /* ET parallel unload possible or not */
  fgac          number,                               /* FGAC enabled or not */
  refpar_level  number,                      /* reference partitioning level */
  read_only     char(1)                      /* Y if table_data is read_only */
)
not persistable
/

-------------------------------------------------------------------------------
--                              POST_DATA_TABLE
-------------------------------------------------------------------------------

-- Do Post Data Table properties
--  initially, this is the 'minimize records_per_block' table property,
--      which affects bitmap indexes
--   metadata for this feature is bit 0x8000 set in tab$/spare1.
--
-- BUT! (based on mail 7/28/2009)
--  spare1 in tab$ stores the hakan flag . It is also overloaded (for reasons
--  that escape me) to store the obj# of the parent IOT for an IOT transient
--  table (a temporary IOT table created during ddl's on IOTs). So if flag
--  value 0x00100000 (KQLDTVNTF_IOTPMO) is not set in tab$/trigflag then
--  checking for 0x8000 set in tab$/spare1 is the way to know if minimize
--  records per block has been done.

create or replace type ku$_post_data_table_t force as object
(
  vers_major    char(1),                              /* UDT major version # */
  vers_minor    char(2),                              /* UDT minor version # */
  obj_num       number,                                 /* obj# of base obj. */
  schema_obj    ku$_schemaobj_t,                           /* base obj. info */
  spare1        number   /* 32768 (0x8000) set if minimize records per block */
)
not persistable
/

-------------------------------------------------------------------------------
--                              DPSTREAM_TABLE
-------------------------------------------------------------------------------

-- Table metadata needed for the DataPump data layer.

create or replace type ku$_strmsubcoltype_t force as object
(
  obj_num       number,                               /* obj# of base object */
  intcol_num    number,                            /* internal column number */
  owner_name    varchar2(128),                                 /* owner name */
  name          varchar2(128),                                /* object name */
  toid          raw(16),                                             /* toid */
  version       number,                      /* internal type version number */
  hashcode      raw(17),                                 /* Version hashcode */
  typeid        raw(16)  /* short typeid value (for non final and sub types) */
)
not persistable
/

create or replace type ku$_strmsubcoltype_list_t
 force as table of (ku$_strmsubcoltype_t)
not persistable
/

create or replace type ku$_strmcoltype_t force as object
(
  obj_num       number,                               /* obj# of base object */
  col_num       number,                                     /* column number */
  intcol_num    number,                            /* internal column number */
  owner_name    varchar2(128),                                 /* owner name */
  name          varchar2(128),                                /* object name */
  flags         number,                                             /* flags */
                     /* flags to indicate whether column type is ADT, Array, */
                                                      /* REF or Nested table */
                           /* 0x02 - adt column                              */
                           /* 0x04 - nested table column                     */
                           /* 0x08 - varray column                           */
                           /* 0x10 - ref column                              */
                           /* 0x20 - retrieve collection out-of-line         */
                           /* 0x20 - don't strip the null image              */
                           /* 0x40 - don't chop null image                   */
                           /* 0x40 - collection storage specified            */
                           /* 0x80 - column stores an old (8.0) format image */
                          /* 0x100 - data for this column not yet upgraded   */
                          /* 0x200 - ADT column is substitutable             */
                          /* 0x400 - NOT SUBSTITUTABLE specified explicitly  */
                          /* 0x800 - SUBSTITUTABLE specified explicitly      */
                         /* 0x1000 - implicitly not substitutable            */
                         /* 0x2000 - The typeid column stores the toid       */
                         /* 0x4000 - The column is an opaque type column     */
                         /* 0x8000 - nested table name is system generated   */
  opqflags      number,                         /* flags for the opaque type */
                              /* -------------- XMLType flags ---------
                               * 0x0001 (1) -- XMLType stored as object
                               * 0x0002 (2) -- XMLType schema is specified
                               * 0x0004 (4) -- XMLType stored as lob
                               * 0x0008 (8) -- XMLType stores extra column
                               * 0x0020 (32)-- XMLType table is out-of-line
                               * 0x0040 (64)-- XMLType store as binary xml
                               */
  toid          raw(16),                                             /* toid */
  version       number,                      /* internal type version number */
  hashcode      raw(17),                                 /* Version hashcode */
  typidcol_num  number,           /* intcol# of the type discriminant column */
  subtype_list  ku$_strmsubcoltype_list_t,               /* subtype metadata */
  anydata_list  ku$_Unpacked_AnyData_t      /* types in unpacked anydata col */
)
not persistable
/
--
-- strmcoltype for 10g compatibility
--
create or replace type ku$_10_2_strmcoltype_t force as object
(
  obj_num       number,                               /* obj# of base object */
  col_num       number,                                     /* column number */
  intcol_num    number,                            /* internal column number */
  owner_name    varchar2(128),                                 /* owner name */
  name          varchar2(128),                                /* object name */
  flags         number,                                             /* flags */
                     /* flags to indicate whether column type is ADT, Array, */
                                                      /* REF or Nested table */
                           /* 0x02 - adt column                              */
                           /* 0x04 - nested table column                     */
                           /* 0x08 - varray column                           */
                           /* 0x10 - ref column                              */
                           /* 0x20 - retrieve collection out-of-line         */
                           /* 0x20 - don't strip the null image              */
                           /* 0x40 - don't chop null image                   */
                           /* 0x40 - collection storage specified            */
                           /* 0x80 - column stores an old (8.0) format image */
                          /* 0x100 - data for this column not yet upgraded   */
                          /* 0x200 - ADT column is substitutable             */
                          /* 0x400 - NOT SUBSTITUTABLE specified explicitly  */
                          /* 0x800 - SUBSTITUTABLE specified explicitly      */
                         /* 0x1000 - implicitly not substitutable            */
                         /* 0x2000 - The typeid column stores the toid       */
                         /* 0x4000 - The column is an opaque type column     */
                         /* 0x8000 - nested table name is system generated   */
  /* opqflags not present in 10g */
  toid          raw(16),                                             /* toid */
  version       number,                      /* internal type version number */
  hashcode      raw(17),                                 /* Version hashcode */
  typidcol_num  number,           /* intcol# of the type discriminant column */
  subtype_list  ku$_strmsubcoltype_list_t                /* subtype metadata */
)
not persistable
/

create or replace type ku$_strmcol_t force as object
(
  obj_num       number,                      /* object number of base object */
  col_num       number,                          /* column number as created */
  intcol_num    number,                            /* internal column number */
  segcol_num    number,                          /* column number in segment */
  col_sortkey   number,                              /* sort key for columns */
  base_intcol_num number,    /* internal column number of base column, i.e., */
                           /* the intcol# of the first column with this col# */
  base_col_type number, /* base column type: 1 = UDT, 2 = XMLType OR or CSX, */
                        /*                   3 = XMLType as CLOB,  4 = NTB,
                                             0 = other */
  property      number,                     /* column properties (bit flags) */
                /* 0x0400 =    1024 = nested table columns setid             */
            /* 0x00800000 = 8388608 = string column measured in characters   */
  property2     number,                /* more column properties (bit flags) */
  name          varchar2(128),                             /* name of column */
  attrname      varchar2(4000),/* name of type attr. column: null if != type */
  type_num      number,                               /* data type of column */
  length        number,                         /* length of column in bytes */
  precision_num number,                                         /* precision */
  scale         number,                                             /* scale */
  not_null      number,                               /* 0 = nulls permitted */
                                                 /* > 0 = no NULLs permitted */
  charsetid     number,                              /* NLS character set id */
  charsetform   number,
  charlength    number,            /* maximum number of characters in string */
  lob_property  number,                    /* lob$.property if column is lob */
                                /* 0x0200 = LOB data in little endian format */
  typemd        ku$_strmcoltype_t,
  base_col_name varchar2(128),
  attrname2     varchar2(4000)
)
not persistable
/

create or replace type ku$_strmcol_list_t force as table of (ku$_strmcol_t)
not persistable
/
--
-- strmcol for 10g compatibility
--
create or replace type ku$_10_2_strmcol_t force as object
(
  obj_num       number,                      /* object number of base object */
  col_num       number,                          /* column number as created */
  intcol_num    number,                            /* internal column number */
  segcol_num    number,                          /* column number in segment */
  /* col_sortkey, base_intcol_num not present on 10g */
  /* base_col_type, base_col_name added for bug fix on 10g */
  base_col_type number, /* base column type: 1 = UDT, 2 = XMLType OR or CSX, */
                        /*                   3 = XMLType as CLOB,  0 = other */
  base_col_name varchar2(128),     /* for any xmltype, name of xmltype column*/
  property      number,                     /* column properties (bit flags) */
                /* 0x0400 =    1024 = nested table columns setid             */
            /* 0x00800000 = 8388608 = string column measured in characters   */
  property2     number,                /* more column properties (bit flags) */
  name          varchar2(128),                             /* name of column */
  attrname      varchar2(4000),/* name of type attr. column: null if != type */
  type_num      number,                               /* data type of column */
  length        number,                         /* length of column in bytes */
  precision_num number,                                         /* precision */
  scale         number,                                             /* scale */
  not_null      number,                               /* 0 = nulls permitted */
                                                 /* > 0 = no NULLs permitted */
  charsetid     number,                              /* NLS character set id */
  charsetform   number,
  charlength    number,            /* maximum number of characters in string */
  lob_property  number,                    /* lob$.property if column is lob */
                                /* 0x0200 = LOB data in little endian format */
  typemd        ku$_10_2_strmcoltype_t
)
not persistable
/

create or replace type ku$_10_2_strmcol_list_t force
as table of (ku$_10_2_strmcol_t)
not persistable
/

create or replace type ku$_strmtable_t force as object
(
  vers_major    char(1),                              /* UDT major version # */
  vers_minor    char(2),                              /* UDT minor version # */
  vers_dpapi    number,                           /* direct path API version */
  endianness    number,                 /* 1 = big-endian, 2 = little-endian */
  charset       varchar2(128),                           /* db character set */
  ncharset      varchar2(128),                          /* db ncharacter set */
  dbtimezone    varchar2(64),                          /* database time zone */
  fdo           raw(100),               /* platform Format Descriptor Object */
  obj_num       number,                                              /* obj# */
  owner_name    varchar2(128),                                 /* owner name */
  name          varchar2(128),                                /* object name */
  pname         varchar2(128),                             /* partition name */
  property      number,                                  /* table properties */
  property2     number,                             /* more table properties */
  col_list      ku$_strmcol_list_t                        /* list of columns */
)
not persistable
/

--
-- strmtable for 10g:
--   use 10g strmcol list
--
create or replace type ku$_10_2_strmtable_t force as object
(
  vers_major    char(1),                              /* UDT major version # */
  vers_minor    char(2),                              /* UDT minor version # */
  vers_dpapi    number,                           /* direct path API version */
  endianness    number,                 /* 1 = big-endian, 2 = little-endian */
  charset       varchar2(128),                           /* db character set */
  ncharset      varchar2(128),                          /* db ncharacter set */
  dbtimezone    varchar2(64),                          /* database time zone */
  fdo           raw(100),               /* platform Format Descriptor Object */
  obj_num       number,                                              /* obj# */
  owner_name    varchar2(128),                                 /* owner name */
  name          varchar2(128),                                /* object name */
  pname         varchar2(128),                             /* partition name */
  property      number,                                  /* table properties */
  col_list      ku$_10_2_strmcol_list_t                   /* list of columns */
)
not persistable
/

-------------------------------------------------------------------------------
--                              PROC./FUNC./PACKAGE
-------------------------------------------------------------------------------

-- common adt for procedures, functions, packages and package bodies
create or replace type ku$_proc_t force as object
(
  vers_major    char(1),                              /* UDT major version # */
  vers_minor    char(2),                              /* UDT minor version # */
  obj_num       number,                                     /* object number */
  type_num      number,                                       /* type number */
  schema_obj    ku$_schemaobj_t,                            /* schema object */
  source_lines  ku$_source_list_t                           /* source lines */
)
not persistable
/

create or replace type ku$_proc_objnum_t force as object
(
  vers_major    char(1),                              /* UDT major version # */
  vers_minor    char(2),                              /* UDT minor version # */
  obj_num       number,                                     /* object number */
  type_num      number,                                       /* type number */
  schema_obj    ku$_schemaobj_t                             /* schema object */
)
not persistable
/

create or replace type ku$_full_pkg_t force as object
(
  vers_major            char(1),                      /* UDT major version # */
  vers_minor            char(2),                      /* UDT minor version # */
  obj_num               number,                             /* object number */
  schema_obj            ku$_schemaobj_t,                    /* schema object */
  package_t             ku$_proc_t,                        /* package header */
  package_body_t        ku$_proc_t                           /* package body */
)
not persistable
/

-- type used by export
-- includes base_obj_num (obj# of the pkg_spec) so that the base_obj_num
-- can be used as a filter

create or replace type ku$_exp_pkg_body_t force as object
(
  vers_major    char(1),                              /* UDT major version # */
  vers_minor    char(2),                              /* UDT minor version # */
  base_obj_num  number,                                /* base object number */
  obj_num       number,                                     /* object number */
  type_num      number,                                       /* type number */
  schema_obj    ku$_schemaobj_t,                            /* schema object */
  source_lines  ku$_source_list_t,                           /* source lines */
  compiler_info ku$_switch_compiler_t
)
not persistable
/

-- UDT for alter procedure/function/package compile ...

create or replace type ku$_alter_proc_t force as object
(
  vers_major    char(1),                              /* UDT major version # */
  vers_minor    char(2),                              /* UDT minor version # */
  obj_num       number,                                     /* object number */
  type_num      number,                                       /* type number */
  schema_obj    ku$_schemaobj_t,                            /* schema object */
  compiler_info ku$_switch_compiler_t
)
not persistable
/


-------------------------------------------------------------------------------
--                              OPERATOR
-------------------------------------------------------------------------------

-- ADT for operator arguments

create or replace type ku$_oparg_t force as object
(
  obj_num       number,                            /* operator object number */
  bind_num      number,                      /* binding this arg. belongs to */
  position      number,                   /* position of the arg in the bind */
  type          varchar2(61)                          /* datatype of the arg */
)
not persistable
/

create or replace type ku$_oparg_list_t force as TABLE of (ku$_oparg_t)
not persistable
/

-- Simplified ADT for listing primary operators for ancillary operators
create or replace type ku$_opancillary_t force as object
(
  obj_num       number,                  /* object number of ANCILLARY oper. */
  bind_num      number,                  /* bind number for the ancillary op */
  primop_num    number,          /* object number of PRIMARY for this ancil. */
  primop_obj    ku$_schemaobj_t,                /* schema object for PRIMARY */
  args          ku$_oparg_list_t               /* arguments for this primary */
)
not persistable
/

create or replace type ku$_opancillary_list_t force
as TABLE of (ku$_opancillary_t)
not persistable
/

-- ADT for operator bindings
create or replace type ku$_opbinding_t force as object
(
  obj_num       number,                            /* operator object number */
  bind_num      number,                            /* number of this binding */
  functionname  varchar2(386),               /* func that impl. this binding */
  returnschema  varchar2(128),             /* schema of return type (if ADT) */
  returntype    varchar2(128),                    /* return type of function */
  impschema     varchar2(128),            /* indextype implementation schema */
  imptype       varchar2(128),              /* indextype implementation type */
  property      number,                                    /* property flags */
  spare1        varchar2(128),
  spare2        varchar2(128),
  spare3        number,
  args          ku$_oparg_list_t,              /* arguments for this binding */
  ancillaries   ku$_opancillary_list_t  /* list of primary ops for this ancil*/
)
not persistable
/

create or replace type ku$_opbinding_list_t force as TABLE of (ku$_opbinding_t)
not persistable
/

-- ADT for operators
create or replace type ku$_operator_t force as object
(
  vers_major    char(1),                              /* UDT major version # */
  vers_minor    char(2),                              /* UDT minor version # */
  obj_num       number,                            /* operator object number */
  schema_obj    ku$_schemaobj_t,                    /* base schema obj. info */
  property      number,                                    /* property flags */
  bindings      ku$_opbinding_list_t       /* List of bindings for this oper */
)
not persistable
/

-------------------------------------------------------------------------------
--                              INDEXTYPE OPERATORS
-------------------------------------------------------------------------------

-- ADT for operators supported by indextypes. This is significantly
-- simplified from the full-blown ku$_operator_t above.
create or replace type ku$_indexop_t force as object
(
  obj_num       number,                          /* obj# of parent indextype */
  oper_num      number,                 /* obj# of operator for this binding */
  bind_num      number,                            /* number of this binding */
  property      number,                                    /* property flags */
                                          /* 0x01 - INEXACT match use filter */
                        /* 0x02 -  invoke rewrite when indexed join is found */
                                    /* 0x04 - this is an "order-by" operator */
  oper_obj      ku$_schemaobj_t,             /* sch. info. for this operator */
  args          ku$_oparg_list_t           /* arguments for this op. binding */
)
not persistable
/

create or replace type ku$_indexop_list_t force as TABLE of (ku$_indexop_t)
not persistable
/

create or replace type ku$_indarraytype_t force as object
(
  obj_num       number,                                 /* obj# of indextype */
  type_num      number,                       /* data type of indexed column */
                                           /* for ADT column, type# = DTYADT */
  basetype_obj  ku$_schemaobj_t,                        /* user-defined type */
  arraytype_obj ku$_schemaobj_t                           /* collection type */
)
not persistable
/

create or replace type ku$_indarraytype_list_t force
as table of (ku$_indarraytype_t)
not persistable
/

create or replace type ku$_indextype_t force as object
(
  vers_major    char(1),                              /* UDT major version # */
  vers_minor    char(2),                              /* UDT minor version # */
  obj_num       number,                                 /* obj# of indextype */
  schema_obj    ku$_schemaobj_t,                    /* base schema obj. info */
  impl_obj      ku$_schemaobj_t,        /* sch. info for implementation type */
  property      number,                                         /* property */
                                              /* 0x0001 WITHOUT_COLUMN_DATA */
                                                   /* 0x0002 WITH_ARRAY_DML */
                                              /* 0x0004 WITH_REBUILD_ONLINE */
                                                     /* 0x0008 HAS_ORDER_BY */
                                       /* 0x0010 WITH LOCAL_RANGE_PARTITION */
                                        /* 0x0020 WITH LOCAL_HASH_PARTITION */
                                                      /* 0x0040 WITHOUT_DML */
                                              /* 0x0080 AUTHID_CURRENT_USER */
  operators     ku$_indexop_list_t,
  indarray      ku$_indarraytype_list_t
)
not persistable
/

-------------------------------------------------------------------------------
--                              TRIGGERS
-------------------------------------------------------------------------------
create or replace type ku$_triggercol_t force as object
(
  vers_major    char(1),                              /* UDT major version # */
  vers_minor    char(2),                              /* UDT minor version # */
  obj_num       number,                                   /* obj# of trigger */
  col_num       number,                                     /* column number */
  type_num      number,                          /* type of column reference */
     /* 6 = OLD IN-ARG, 5 = NEW IN-ARG, 9 = NEW OUT-VAR, 13 = NEW IN/OUT-VAR */
                                                  /* 0x14 = 20 PARENT IN-ARG */
  position_num  number,                               /* position in trigger */
  intcol_num    number,                            /* internal column number */
  name          varchar2(128),                             /* name of column */
  attrname      varchar2(4000) /* name of type attr. column: null if != type */
)
not persistable
/

create or replace type ku$_triggercol_list_t
 force as table of (ku$_triggercol_t)
not persistable
/

create or replace type ku$_triggerdep_t force as object
(
  vers_major  char(1),                                /* UDT major version # */
  vers_minor  char(2),                                /* UDT minor version # */
  obj_num     number,                                     /* obj# of trigger */
  p_trgowner  varchar2(128),                         /* parent trigger owner */
  p_trgname   varchar2(128),                          /* parent trigger name */
  flag        number                              /* 0x01 FOLLOWS dependency */
                                                 /* 0x02 PRECEDES dependency */
                                  /* 0x04 - schema user not specified in ddl */
)
not persistable
/

create or replace type ku$_triggerdep_list_t
 force as table of (ku$_triggerdep_t)
not persistable
/

create or replace type ku$_trigger_t force as object
(
  vers_major    char(1),                              /* UDT major version # */
  vers_minor    char(2),                              /* UDT minor version # */
  obj_num       number,                                   /* obj# of trigger */
  schema_obj    ku$_schemaobj_t,                 /* object info. for trigger */
  base_obj_num  number,                                  /* obj# of base obj */
  base_obj_schema varchar2(128),        /* schema name - for schema triggers */
  base_obj      ku$_schemaobj_t,    /* object info. for base obj: May be null*/
  tab_property2 number,       /* table property bits if base object is table */
  xdb_generated number,                     /* 1 if xdb generated, else NULL */
  type_num      number,                                     /* trigger type: */
   /* 0=before table, 1=before row, 2=after table, 3=after row, 4=instead of */
  act_update    number,                                    /* fire on update */
  act_insert    number,                                    /* fire on insert */
  act_delete    number,                                    /* fire on delete */
  refoldname    varchar2(128),                       /* old referencing name */
  refnewname    varchar2(128),                       /* new referencing name */
  defschema_exst number,       /* Flag to identifify schema existance in def */
  definition    varchar2(4000),                /* text of trigger definition */
  parsed_def    ku$_source_t,          /* definition with name offset/length */
  whenclause    varchar2(4000),                       /* text of when clause */
  body          clob,                                /* text of trigger body */
  body_vcnt     ku$_vcnt,                            /* text of trigger body */
  body_len      number,                            /* length of trigger body */
  enabled       number,                         /* 0 = DISABLED, 1 = ENABLED */
  property      number,                                /* trigger properties */
                                                /* 0x01 = baseobject is view */
                                                /* 0x02 = Call style trigger */
                                                /* 0x04 = Java Trigger       */
                                            /* 0x08 = baseobject is database */
                                              /* 0x10 = baseobject is schema */
                                              /* 0x20 = Nested table trigger */
                                                 /* 0x40 = baseobject is IOT */
                              /* 0x80 = fire-once-only (fire one place only) */
  sys_evts      number,                         /* system events for trigger */
  nttrigcol     number,               /* intcol# on which trigger is defined */
  nttrigatt     number,                    /* attribute number within column */
  ntname        varchar2(128),                  /* nested table trigger name */
  refprtname    varchar2(128),                    /* PARENT referencing name */
  actionlineno  number,                         /* action line number offset */
  cols          ku$_triggercol_list_t,      /* columns referenced by trigger */
  trigdeps      ku$_triggerdep_list_t,               /* trigger dependencies */
  compiler_info ku$_switch_compiler_t
)
not persistable
/

-------------------------------------------------------------------------------
--                              VIEWS
-------------------------------------------------------------------------------

create or replace type ku$_view_t force as object
(
  vers_major    char(1),                              /* UDT major version # */
  vers_minor    char(2),                              /* UDT minor version # */
  obj_num       number,                                              /* obj# */
  schema_obj    ku$_schemaobj_t,                            /* schema object */
  audit_val     varchar2(128),                           /* auditing options */
  cols          number,                                      /* # of columns */
  intcols       number,                             /* # of internal columns */
  property      number,                                  /* table properties */
                /* 0x0001 =       1 = this is typed view                     */
                /* 0x0002 =       2 = view has ADT column(s)                 */
                /* 0x0004 =       4 = view has nested table column(s)        */
                /* 0x0008 =       8 = view has REF column(s)                 */
                /* 0x0010 =      16 = view has array column(s)               */
                /* 0x1000 =    4096 = view has primary key-based oid         */
                /* 0x4000 =   16384 = view is read-only                      */
            /* 0x08000000 =         = view is a sub view                     */
            /* 0x10000000 =         = view is packed object view             */
  property2     number,                                  /* table properties */
            /* see kqld.h KQLDTVCP2 flags */
  flags         number,                                             /* flags */
                /* 0x0800 =    2048 = view/table has security policy         */
                /* 0x1000 =    4096 = view is insertable via trigger         */
                /* 0x2000 =    8192 = view is updatable via trigger          */
                /* 0x4000 =   16384 = view is deletable via trigger          */
             /* 0x0400000 =         = view has sub views defined under it    */
  textlength    number,                               /* length of view text */
  text          clob,                                           /* view text */
  parsed_text   sys.xmltype,                             /* parsed view text */
  with_option   ku$_constraint0_t,      /* check with option constraint name */
  textvcnt      ku$_vcnt,            /* (retained for backward compatibility */
  col_list      ku$_simple_col_list_t,    /* list of relational view columns */
  col_list2     ku$_tab_column_list_t,        /* list of object view columns */
  owner_name    varchar2(128),                          /* owner of row type */
  name          varchar2(128),                           /* name of row type */
  typetextlength  number,                         /* length of row type text */
  typetext        varchar2(4000),                               /* type text */
  oidtextlength   number,                              /* length of oid text */
  oidtext         varchar2(4000),                                /* oid text */
  transtextlength number,                 /* length of transformed view text */
  transtext       varchar2(4000),
  undertextlength number,       /* length of under clause text for sub-views */
  undertext       varchar2(4000),         /* under clause text for sub-views */
  con1_list     ku$_constraint1_list_t,               /* list of constraints */
  con2_list     ku$_constraint2_list_t                /* list of constraints */
)
not persistable
/

-------------------------------------------------------------------------------
--                              OUTLINES
-------------------------------------------------------------------------------
-- Types to support OUTLINEs

create or replace type ku$_outline_hint_t force as object
( name              varchar2(128),                          /* outline name */
  hint              number,               /* which hint for a given outline */
  category          varchar2(128),              /* collection/grouping name */
  hint_type         number,                                 /* type of hint */
  hint_text         varchar2(512),             /* hint specific information */
  stage             number,            /* stage of hint generation/applic'n */
  node              number,                                  /* QBC node id */
  table_name        varchar2(128),                      /* for ORDERED hint */
  table_tin         number,                        /* table instance number */
  table_pos         number,                             /* for ORDERED hint */
  ref_id            number,        /* node id that this hint is referencing */
  user_table_name   varchar2(128), /* table name to which this hint applies */
  cost              double precision,    /* optimizer estimated cost of the
                                                           hinted operation */
  cardinality       double precision,    /* optimizer estimated cardinality
                                                    of the hinted operation */
  bytes             double precision,     /* optimizer estimated byte count
                                                    of the hinted operation */
  hint_textoff      number,             /* offset into the SQL statement to
                                                    which this hint applies */
  hint_textlen      number,     /* length of SQL to which this hint applies */
  join_pred         varchar2(2000)      /* join predicate (applies only for
                                                         join method hints) */
)
not persistable
/

create or replace type ku$_outline_hint_list_t
 force as table of (ku$_outline_hint_t)
not persistable
/

create or replace type ku$_outline_node_t force as object
(
  name          varchar2(128),                             /* outline name  */
  category      varchar2(128),                          /* outline category */
  node          number,                              /* qbc node identifier */
  parent        number,      /* node id of the parent node for current node */
  node_type     number,                                    /* qbc node type */
  node_textlen  number,         /* length of SQL to which this node applies */
  node_textoff  number       /* offset into the SQL statement to which this
                                                               node applies */
)
not persistable
/

create or replace type ku$_outline_node_list_t
 force as table of (ku$_outline_node_t)
not persistable
/

create or replace type ku$_outline_t force as object
(
  vers_major        char(1),                          /* UDT major version # */
  vers_minor        char(1),                          /* UDT minor version # */
  name              varchar2(128),        /* named is potentially generated */
  sql_text          clob,          /* the SQL stmt being outlined */
  textlen           number,                           /* length of SQL stmt */
  signature         raw(16),                       /* signature of sql_text */
  hash_value        number,                  /* KGL's calculated hash value */
  category          varchar2(128),                         /* category name */
  version           varchar2(64),          /* db version @ outline creation */
  creator           varchar2(128),        /* user from whom outline created */
  timestamp         varchar2(19),                       /* time of creation */
  flags             number,              /* e.g. everUsed, bindVars, dynSql */
  hintcount         number,               /* number of hints on the outline */
  hints             ku$_outline_hint_list_t,/* list of hints for this outln */
  nodes             ku$_outline_node_list_t           /* list of qbc blocks */
)
not persistable
/

-------------------------------------------------------------------------------
--                              SYNONYMS
-------------------------------------------------------------------------------
-- 
create or replace type ku$_synonym_t force as object
(
  vers_major    char(1),                              /* UDT major version # */
  vers_minor    char(2),                              /* UDT minor version # */
  obj_num       number,                             /* synonym object number */
  schema_obj    ku$_schemaobj_t,                    /* synonym schema object */
  syn_long_name varchar2(4000),                         /* synonym long name */
  db_link       varchar2(128),                                /* object node */
  owner_name    varchar2(128),                               /* object owner */
  name          varchar2(128),                                /* object name */
  obj_long_name varchar2(4000)                           /* object long name */
)
not persistable
/

-------------------------------------------------------------------------------
--                              DIRECTORY
-------------------------------------------------------------------------------
-- 
create or replace type ku$_directory_t force as object
(
  vers_major    char(1),                              /* UDT major version # */
  vers_minor    char(1),                              /* UDT minor version # */
  obj_num       number,                           /* directory object number */
  schema_obj    ku$_schemaobj_t,                  /* directory schema object */
  audit_val     varchar2(128),                           /* auditing options */
  os_path       varchar2(4000)                             /* OS path string */
)
not persistable
/

-------------------------------------------------------------------------------
--                           ROLLBACK SEGMENTS
-------------------------------------------------------------------------------
-- 
create or replace type ku$_rollback_t force as object
(
  vers_major    char(1),                              /* UDT major version # */
  vers_minor    char(1),                              /* UDT minor version # */
  us_num        number,                               /* undo segment number */
  name          varchar2(128),                      /* rollback segment name */
  user_num      number,                /* Owner: 0 = SYS(PRIVATE) 1 = PUBLIC */
  optimal       number,                                     /* optimal value */
  iniexts       number,                               /* initial extent size */
  minexts       number,                         /* minimum number of extents */
  maxexts       number,                         /* maximum number of extents */
  extsize       number,                          /* current next extent size */
                                           /* zero for bitmapped tablespaces */
  tablespace    ku$_tablespace_t                   /* tablespace information */
)
not persistable
/

-------------------------------------------------------------------------------
--                           DATABASE LINKS
-------------------------------------------------------------------------------
-- 
create or replace type ku$_dblink_t force as object
(
  vers_major    char(1),                              /* UDT major version # */
  vers_minor    char(1),                              /* UDT minor version # */
  owner_name    varchar2(128),
  owner_num     number,
  name          varchar2(128),
  ctime         varchar2(19),
  host          varchar2(2000),
  userid        varchar2(128),
  password      varchar2(128),
  flag          number,
  authusr       varchar2(128),
  authpwd       varchar2(128),
  passwordx     raw(128),
  authpwdx      raw(128)
)
not persistable
/

-------------------------------------------------------------------------------
--                           TRUSTED LINKS
-------------------------------------------------------------------------------
-- 
create or replace type ku$_trlink_t force as object
(
  vers_major    char(1),                              /* UDT major version # */
  vers_minor    char(1),                              /* UDT minor version # */
  name          varchar2(132),                          /* trusted link name */
  function      varchar2(45),                                    /* function */
  type          number                               /* type of trusted link */
)
not persistable
/

-------------------------------------------------------------------------------
--                           Fine Grained Auditing
-------------------------------------------------------------------------------
-- 

-- Each FGA relevant Column type
create or replace type ku$_fga_rel_col_t force as object
(
    audit_column varchar2(128)
)
not persistable
/

-- FGA relevant column LIST
create or replace type ku$_fga_rel_col_list_t
 force as table of (ku$_fga_rel_col_t) not persistable;
/

create or replace type ku$_fga_policy_t force as object
(
  vers_major    char(1),                              /* UDT major version # */
  vers_minor    char(1),                              /* UDT minor version # */
  obj_num       number,                              /* parent object number */
  name          varchar2(128),                             /* name of policy */
  ptxt          clob,                                    /* policy predicate */
  pfschema      varchar2(128),                    /* schema of event handler */
  ppname        varchar2(128),                         /* event package name */
  pfname        varchar2(128),                        /* event funciton name */
  pcol          ku$_fga_rel_col_list_t,              /* relevent column List */
  enable_flag   number,                         /* 0 = disabled, 1 = enabled */
  stmt_type     number,              /* statement type default is 1 = select */
  audit_trail   number,              /* audit trail 0 = DB_EXTENDED, 64 = DB */
  pcol_opt      number,           /* audit_column_options 0 = any, 128 = all */
  base_obj      ku$_schemaobj_t,                       /* base Schema object */
  powner        varchar2(128)                             /* owner of policy */
)
not persistable
/

-------------------------------------------------------------------------------
--              Fine Grained Access Control Administrative Interface
-------------------------------------------------------------------------------

create or replace type ku$_rls_sec_rel_col_t force as object
(
  sec_rel_col varchar2(128)
)
not persistable
/

create or replace type ku$_rls_sec_rel_col_list_t
 force as table of (ku$_rls_sec_rel_col_t) not persistable;
/

create or replace type ku$_rls_associations_t force as object
(
  obj_num       number,                              /* parent object number */
  gname         varchar2(128),                       /* name of policy group */
  name          varchar2(128),                             /* name of policy */
  namespace     varchar2(128),                                  /* namespace */
  attribute     varchar2(128)                                   /* attribute */
)
not persistable
/

create or replace type ku$_rls_assoc_list_t
 force as table of (ku$_rls_associations_t) not persistable;
/

create or replace type ku$_rls_policy_objnum_t force as object
(
  obj_num       number,                              /* parent object number */
  name          varchar2(128),                             /* name of policy */
  pfschma       varchar2(128),             /* name of policy function schema */
  ppname        varchar2(128),                     /* name of policy package */
  pfname        varchar2(128),               /* name of policy function name */
  base_obj      ku$_schemaobj_t                        /* base schema object */
)
not persistable
/

create or replace type ku$_rls_policy_t force as object
(
  vers_major    char(1),                              /* UDT major version # */
  vers_minor    char(1),                              /* UDT minor version # */
  base_obj      ku$_schemaobj_t,                       /* base schema object */
  obj_num       number,                              /* parent object number */
  gname         varchar2(128),                       /* name of policy group */
  name          varchar2(128),                             /* name of policy */
  stmt_type     number,                        /* applicable statement type: */
  check_opt     number,                                 /* with check option */
  enable_flag   number,                         /* 0 = disabled, 1 = enabled */
  pfschma       varchar2(128),                  /* schema of policy function */
  ppname        varchar2(128),                        /* policy package name */
  pfname        varchar2(128),                       /* policy function name */
  policy_type   varchar2(35),                                 /* policy type */
  long_pred     number,                           /* 32K long predicate size */
  rel_cols      ku$_rls_sec_rel_col_list_t,     /* security relevant columns */
  rel_cols_opt  number,                  /* security relevant columns option */
  rls_assoc_list ku$_rls_assoc_list_t              /* attribute associations */
)
not persistable
/

create or replace type ku$_rls_policy_list_t force
as table of (ku$_rls_policy_t) not persistable;
/

create or replace type ku$_rls_group_t force as object
(
  vers_major    char(1),                              /* UDT major version # */
  vers_minor    char(1),                              /* UDT minor version # */
  base_obj      ku$_schemaobj_t,                       /* base schema object */
  obj_num       number,                              /* parent object number */
  name          varchar2(128)                        /* name of policy group */
)
not persistable
/

create or replace type ku$_rls_context_t force as object
(
  vers_major    char(1),                              /* UDT major version # */
  vers_minor    char(1),                              /* UDT minor version # */
  base_obj      ku$_schemaobj_t,                       /* base schema object */
  obj_num       number,                              /* parent object number */
  name          varchar2(128),                                  /* namespace */
  attr          varchar2(128)                                   /* attribute */
)
not persistable
/

-------------------------------------------------------------------------------
--                           Materialized View
-------------------------------------------------------------------------------
--
create or replace type ku$_m_view_scm_t force as object
(
  snacol            varchar2(128),                /* name of snapshot column */
  mascol            varchar2(128),                     /* master column name */
  maspos            number,            /* position of master column (intcol) */
  colrole           number,                       /* how is this column used */
  snapos            integer             /* position of col in snapshot table */
)
not persistable
/

create or replace type ku$_m_view_scm_list_t
 force as table of (ku$_m_view_scm_t)
not persistable
/

create or replace type ku$_m_view_srt_t force as object
(
  tablenum          number,           /* order of Master table in snap query */
  snaptime          varchar2(21),          /* time of last refresh for table */
  mowner            varchar2(128),                    /* owner of this table */
  master            varchar2(128),                     /* name of this table */
  masflag           number,                 /* additional master information */
  masobj_num        number,                    /* obj number of master table */
  loadertime        varchar2(21),      /* last refresh w.r.t. SQL*Loader log */
  refscn            number, /* scn of latest info used to refresh this table */
  lastsuccess       varchar2(21),   /* time of last known successful refresh */
  fcmaskvec         raw(255),                  /* filter columns mask vector */
  ejmaskvec         raw(255),               /* equi-join columns mask vector */
  sub_handle        number,            /* subscription handle (if using CDC) */
  change_view       varchar2(128),        /* change view name (if using CDC) */
  scm_count         number,
  scm_list          ku$_m_view_scm_list_t
)
not persistable
/

create or replace type ku$_m_view_srt_list_t
 force as table of (ku$_m_view_srt_t)
not persistable
/

create or replace type ku$_m_view_t force as object
(
  vers_major        char(1),                          /* UDT major version # */
  vers_minor        char(1),                          /* UDT minor version # */
  oidval            raw(16),                                    /* unique id */
  sowner            varchar2(128),                      /* Owner of snapshot */
  vname             varchar2(128),                       /* name of snapshot */
  tname             varchar2(128),                             /* Table name */
  mowner            varchar2(128),                        /* owner of master */
  master            varchar2(128),                         /* name of master */
  mlink             varchar2(128),           /* database link to master site */
  dflcollname       varchar2(128),                 /* Default collation name */
  base_obj_num      number,                                /* obj# of master */
  snapshot          varchar2(21), /* used by V7 masters to identify snapshot */
  snapid            integer,  /* used by V8 masters to identify the snapshot */
  auto_fast         varchar2(8),      /* date function for automatic refresh */
  auto_fun          varchar2(200),                  /* next time for refresh */
  auto_date         varchar2(19),                  /* start time for refresh */
  uslog             varchar2(128),            /* log for updatable snapshots */
  status            integer,                           /* refresh operations */
  master_version    integer,            /* Oracle version of the master site */
  tables            integer,                 /* Number of tables in snapshot */
  flag              number,
  flag2             number,
  flag3             number,
  lobmaskvec        raw(255),                     /* lob columns mask vector */
  mas_roll_seg      varchar2(128),           /* master-side rollback segment */
  rscn              number,                              /* last refresh scn */
  instsite          integer,                           /* instantiating site */
  flavor_id         number,                                     /* flavor id */
  objflag           number,                 /* object properties of snapshot */
  sna_type_owner    varchar2(128),                   /* object MV type owner */
  sna_type_name     varchar2(128),                    /* object MV type name */
  mas_type_owner    varchar2(128),         /* master object table type owner */
  mas_type_name     varchar2(128),          /* master object table type name */
  parent_sowner     varchar2(128),                  /* parent snapshot owner */
  parent_vname      varchar2(128),                   /* parent snapshot name */
  query_len         number,                                  /* query length */
  query_txt         clob,              /* query which this view instantiates */
  parsed_query_txt  sys.xmltype,                         /* parsed query_txt */
  query_vcnt        ku$_vcnt,          /* store the query when length > 4000 */
  rel_query         clob,              /* relational transformation of query */
  loc_roll_seg      varchar2(128),            /* local side rollback segment */
  global_db_name    varchar2(4000),                  /* Global database Name */
  syn_count         number,                /* Number of synonyms in snapshot */
  srt_list          ku$_m_view_srt_list_t,
                             /* fields from sum$: */
  mflags            number,                                       /*  mflags */
  xpflags           number,                           /* extension to pflags */
  zmapscale         number,                         /* zone map scale factor */
  evaledition_num   number,                     /* evaluation edition number */
  unusablebef_num   number,                /* unusable before edition number */
  unusablebeg_num   number         /* unusable beginning with edition number */
)
not persistable
/

create or replace type ku$_m_view_h_t force as object
(
  vers_major        char(1),                          /* UDT major version # */
  vers_minor        char(1),                          /* UDT minor version # */
  obj_num           number,                    /* object number of the mview */
  sowner            varchar2(128),                      /* Owner of snapshot */
  vname             varchar2(128),                       /* name of snapshot */
  mview             ku$_m_view_t,
  mview_tab         ku$_table_t,
  mview_idx_list    ku$_index_list_t
)
not persistable
/

create or replace type ku$_m_view_ph_t force as object
(
  vers_major        char(1),                          /* UDT major version # */
  vers_minor        char(1),                          /* UDT minor version # */
  obj_num           number,                    /* object number of the mview */
  sowner            varchar2(128),                      /* Owner of snapshot */
  vname             varchar2(128),                       /* name of snapshot */
  mview             ku$_m_view_t,
  mview_tab         ku$_table_t,
  mview_idx_list    ku$_index_list_t
)
not persistable
/

create or replace type ku$_m_view_fh_t force as object
(
  vers_major        char(1),                          /* UDT major version # */
  vers_minor        char(1),                          /* UDT minor version # */
  obj_num           number,                    /* object number of the mview */
  sowner            varchar2(128),                      /* Owner of snapshot */
  vname             varchar2(128),                       /* name of snapshot */
  mview             ku$_m_view_t,
  mview_tab         ku$_table_t,
  mview_idx_list    ku$_index_list_t
)
not persistable
/

create or replace type ku$_m_view_pfh_t force as object
(
  vers_major        char(1),                          /* UDT major version # */
  vers_minor        char(1),                          /* UDT minor version # */
  obj_num           number,                    /* object number of the mview */
  sowner            varchar2(128),                      /* Owner of snapshot */
  vname             varchar2(128),                       /* name of snapshot */
  mview             ku$_m_view_t,
  mview_tab         ku$_table_t,
  mview_idx_list    ku$_index_list_t
)
not persistable
/

create or replace type ku$_m_view_iot_t force as object
(
  vers_major        char(1),                          /* UDT major version # */
  vers_minor        char(1),                          /* UDT minor version # */
  obj_num           number,                    /* object number of the mview */
  sowner            varchar2(128),                      /* Owner of snapshot */
  vname             varchar2(128),                       /* name of snapshot */
  mview             ku$_m_view_t,
  mview_tab         ku$_io_table_t,
  mview_idx_list    ku$_index_list_t
)
not persistable
/

create or replace type ku$_m_view_piot_t force as object
(
  vers_major        char(1),                          /* UDT major version # */
  vers_minor        char(1),                          /* UDT minor version # */
  obj_num           number,                    /* object number of the mview */
  sowner            varchar2(128),                      /* Owner of snapshot */
  vname             varchar2(128),                       /* name of snapshot */
  mview             ku$_m_view_t,
  mview_tab         ku$_io_table_t,
  mview_idx_list    ku$_index_list_t
)
not persistable
/

-------------------------------------------------------------------------------
--                             Materialized View Log
-------------------------------------------------------------------------------
--
create or replace type ku$_refcol_t force as object
(
  colname         varchar2(128),                 /* master table column name */
  oldest          varchar2(21),  /* maximum age of information in the column */
  flag            number                          /* column meta information */
)
not persistable
/

create or replace type ku$_refcol_list_t
 force as table of (ku$_refcol_t)
not persistable
/

create or replace type ku$_slog_t force as object
(
  snapid          integer,                        /* identifies V8 snapshots */
  snaptime        varchar2(21),                       /* when last refreshed */
  tscn            number                                 /* last refresh scn */
)
not persistable
/

create or replace type ku$_slog_list_t
 force as table of (ku$_slog_t)
not persistable
/

create or replace type ku$_m_view_log_t force as object
(
  vers_major      char(1),                            /* UDT major version # */
  vers_minor      char(1),                            /* UDT minor version # */
  mowner          varchar2(128),                          /* owner of master */
  master          varchar2(128),                           /* name of master */
  oldest          varchar2(19),/*maximum age of rowid information in the log */
  oldest_pk       varchar2(21),  /* maximum age of PK information in the log */
  oscn            number,                                   /* scn of oldest */
  youngest        varchar2(21),             /* most recent snaptime assigned */
  yscn            number,                                      /* set-up scn */
  log             varchar2(128),                              /* name of log */
  trig            varchar2(128),                /* trigger on master for log */
  flag            number,    /* 0x01, rowid         0x02, primary key values */
                             /* 0x04, column values 0x08, log is imported    */
                             /* 0x10, log is created with temp table         */
  mtime           varchar2(21),                     /* DDL modification time */
  temp_log        varchar2(128),     /* temp table as updatable snapshot log */
  oldest_oid      varchar2(21), /* maximum age of OID information in the log */
  oldest_new      varchar2(21),      /* maximum age of new values in the log */
  oldest_seq      varchar2(21), /* maximum age of sequence values in the log */
  global_db_name  varchar2(4000),                    /* Global database Name */
  purge_start     varchar2(21),                          /* purge start date */
  purge_next      varchar2(200),               /* purge next date expression */
  fc_count        number,                        /* number of filter columns */
  fc_list         ku$_refcol_list_t,                   /* filter column list */
  lm_count        number,                         /* number of local masters */
  lm_list         ku$_slog_list_t                       /* local master list */
)
not persistable
/

create or replace type ku$_m_view_log_h_t force as object
(
  vers_major        char(1),                          /* UDT major version # */
  vers_minor        char(1),                          /* UDT minor version # */
  tabobj_num        number,                       /* log table object number */
  mviewlog          ku$_m_view_log_t,
  mviewlog_tab      ku$_table_t
)
not persistable
/

create or replace type ku$_m_view_log_ph_t force as object
(
  vers_major        char(1),                          /* UDT major version # */
  vers_minor        char(1),                          /* UDT minor version # */
  tabobj_num        number,                       /* log table object number */
  mviewlog          ku$_m_view_log_t,
  mviewlog_tab      ku$_table_t
)
not persistable
/

create or replace type ku$_m_view_log_fh_t force as object
(
  vers_major        char(1),                          /* UDT major version # */
  vers_minor        char(1),                          /* UDT minor version # */
  tabobj_num        number,                       /* log table object number */
  mviewlog          ku$_m_view_log_t,
  mviewlog_tab      ku$_table_t
)
not persistable
/

create or replace type ku$_m_view_log_pfh_t force as object
(
  vers_major        char(1),                          /* UDT major version # */
  vers_minor        char(1),                          /* UDT minor version # */
  tabobj_num        number,                       /* log table object number */
  mviewlog          ku$_m_view_log_t,
  mviewlog_tab      ku$_table_t
)
not persistable
/

-------------------------------------------------------------------------------
--                              LIBRARY
-------------------------------------------------------------------------------
-- 
create or replace type ku$_credential_t force as object
(
  vers_major    char(1),                              /* UDT major version # */
  vers_minor    char(1),                              /* UDT minor version # */
  obj_num       number,                          /* credential object number */
  schema_obj    ku$_schemaobj_t,                 /* credential schema object */
  password      varchar2(255),                                   /* password */
  domain        varchar2(128),                                     /* domain */
  flags         number
)
not persistable
/

create or replace type ku$_library_t force as object
(
  vers_major    char(1),                              /* UDT major version # */
  vers_minor    char(1),                              /* UDT minor version # */
  obj_num       number,                             /* library object number */
  schema_obj    ku$_schemaobj_t,                    /* library schema object */
  filespec      varchar2(2000),                                  /* filename */
  lib_audit     varchar2(2000),
  property      number,
  agent         varchar2(128),                  /* network agent for library */
  directory     varchar2(128),          /* directory object for library file */
  filename      varchar2(2000),                   /* filename of the library */
  credential    ku$_credential_t
)
not persistable
/

-------------------------------------------------------------------------------
--                        TRITION SECURITY (TS)
-------------------------------------------------------------------------------
-- 

-- Triton Security object (xs$obj + xs$prin)

create or replace type ku$_xsprin_t force as object
(
  vers_major    char(1),                             /* UDT major version # */
  vers_minor    char(1),                             /* UDT minor version # */
  prin_id       number,
  type          number,
  guid          raw(16),
  ext_src       varchar2(128),
  start_date    timestamp(6) with time zone,
  end_date      timestamp(6) with time zone,
  schema        varchar2(128),
  tablespace    varchar2(128),
  profile_num   number,
  credential    varchar2(128),
  failedlogins  number,
  enable        number,
  duration      number,
  system        number,
  scope         number,
  powner        varchar2(128),
  pname         varchar2(128),
  pfname        varchar2(128),
  objacl_num    number,
  note          varchar2(4000),
  status        number,                             /* 1=ACTIVE, 2=INACTIVE */
  ctime         timestamp(6),
  mtime         timestamp(6),
  ptime         date,
  exptime       date,
  ltime         date,
  lslogontime   date,
  astatus       number,                   /* password policy account status */
  verifier      varchar2(256),                               /* XS Verifier */
  verifier_type number,                                 /* XS Verifier Type */
                                                      /* XS_SHA512      = 1 */
                                                      /* XS_SALTED_SHA1 = 2 */
  description   varchar2(4000)
)
not persistable
/

create or replace type ku$_xsobj_t force as object
(
  vers_major    char(1),                             /* UDT major version # */
  vers_minor    char(1),                             /* UDT minor version # */
  name          varchar2(128),                              /* name of user */
  ws            varchar2(128),                         /* name of workspace */
  owner_name    varchar2(128),                              /* owner of ACL */
  tenant        varchar2(128),                                    /* Tenant */
  id            number,                                           /* TS id  */
  type          number,                                         /* TS type  */
                                                             /* 1=principal */
                                                             /* 2=sc        */
                                                             /* 3=acl       */
                                                             /* 4=priv      */
                                                             /* 5=dse       */
                                                             /* 6=roleset   */
                                                             /* 7=nstemplate*/
  status       number,                                /* 0=invalid, 1=valid */
  flags        number,                                         /* flag bits */
  early_depcnt number,
  late_depcnt  number,
  aclid        number,
  xs_prin      ku$_xsprin_t                                      /* xs$prin */
)
not persistable
/

create or replace type ku$_xsobj_list_t force as table of (ku$_xsobj_t)
not persistable;
/

-- Triton Security User
-- same to ku$_xsobj_view except contains a where clause to fetch only users.
create or replace type ku$_xsuser_t force as object
(
  vers_major    char(1),                             /* UDT major version # */
  vers_minor    char(1),                             /* UDT minor version # */
  name          varchar2(128),                              /* name of user */
  ws            varchar2(128),                         /* name of workspace */
  owner         varchar2(128),                              /* owner of ACL */
  tenant        varchar2(128),                                    /* Tenant */
  id            number,                                           /* TS id  */
  type          number,                                         /* TS type  */
                                                             /* 1=principal */
                                                             /* 2=sc        */
                                                             /* 3=acl       */
                                                             /* 4=priv      */
                                                             /* 5=dse       */
                                                             /* 6=roleset   */
                                                             /* 7=nstemplate*/
  status       number,                                /* 0=invalid, 1=valid */
  xs_prin      ku$_xsprin_t                                      /* xs$prin */
)
not persistable
/

-- Triton Security related to grants/privs 
-- This udt is used to generate a call into xs_admin_util package to grant a
-- RAS admin  priv to a specific schema (see admin/xsutil.sql)
-- PROCEDURE grant_system_privilege(
--   priv_name  IN VARCHAR2,           -- admin priv to grant
--   user_name  IN VARCHAR2,           -- grantee
--   user_type  IN PLS_INTEGER := XS_ADMIN_UTIL.PTYPE_DB,
--   schema     IN VARCHAR2 := NULL);  -- schema to whom priv user can affect
create or replace type ku$_xsgrant_t force as object
(
  vers_major    char(1),                             /* UDT major version # */
  vers_minor    char(1),                             /* UDT minor version # */
  name          varchar2(128),                                 /* Privilege */
  grantee       varchar2(128),                         /* receiver of grant */
  user_type     number,                   /* type of grantee: XS, DB,DN,EXT */
  schema        varchar2(128)
)
not persistable
/

-- Triton Security Roles related objects
create or replace type ku$_xsrole_grant_t force as object
(
  vers_major    char(1),                             /* UDT major version # */
  vers_minor    char(1),                             /* UDT minor version # */
  grantee_num   number,
  grantee       varchar2(128),
  role_num      number,
  name          varchar2(128),
  granter_num   number,
  granter       varchar2(128),
  start_date    timestamp with time zone,
  end_date      timestamp with time zone
)
not persistable
/

create or replace type ku$_xsrgrant_list_t force
as table of (ku$_xsrole_grant_t) not persistable;
/

create or replace type ku$_xsrole_t force as object
(
  vers_major    char(1),                             /* UDT major version # */
  vers_minor    char(1),                             /* UDT minor version # */
  xs_obj        ku$_xsobj_t,                              /* XS object info */
  xs_grant_list ku$_xsrgrant_list_t
)
not persistable
/

-- Triton Rolesets
create or replace type ku$_xsroleset_t force as object
(
  vers_major    char(1),                             /* UDT major version # */
  vers_minor    char(1),                             /* UDT minor version # */
  rsid          number,                                       /* Roleset id */
  ctime         timestamp,
  mtime         timestamp,
  description   varchar2(4000),                      /* Roleset description */
  xs_obj        ku$_xsobj_t,                         /* Roleset object info */
  role_list     ku$_xsobj_list_t                /* Roles assoc with roleset */
)
not persistable
/

-- Triton Privileges
create or replace type ku$_xsaggpriv_t force as object
(
  vers_major     char(1),                             /* UDT major version # */
  vers_minor     char(1),                             /* UDT minor version # */
  scid           number,                                /* Security Class id */
  aggr_privid    number,
  implied_privid number,
  name           varchar2(128),
  owner_name     varchar2(128)
)
not persistable
/

create or replace type ku$_xsaggpriv_list_t force as table of (ku$_xsaggpriv_t)
not persistable;
/

create or replace type ku$_xspriv_t force as object
(
  vers_major    char(1),                              /* UDT major version # */
  vers_minor    char(1),                              /* UDT minor version # */
  privid        number,                                     /*  Privilege id */
  scid          number,                                 /* Security Class id */
  ctime         timestamp,
  mtime         timestamp,
  description   varchar2(4000),
  name          varchar2(128),
  owner_name    varchar2(128),
  aggr_priv_list ku$_xsaggpriv_list_t
)
not persistable
/

create or replace type ku$_xspriv_list_t force as table of (ku$_xspriv_t)
not persistable;
/

create or replace type ku$_xsacepriv_t force as object
(
  vers_major    char(1),                              /* UDT major version # */
  vers_minor    char(1),                              /* UDT minor version # */
  aclid         number,                                           /*  ACL id */
  ace_order     number,                                      /*  ACE Order # */
  privid        number,                                     /*  Privilege id */
  xs_obj        ku$_xsobj_t                                /* XS object info */
)
not persistable
/

create or replace type ku$_xsacepriv_list_t force as table of (ku$_xsacepriv_t)
not persistable;
/

-- Triton Security class

create or replace type ku$_xssecclsh_t force as object
(
  vers_major    char(1),                              /* UDT major version # */
  vers_minor    char(1),                              /* UDT minor version # */
  scid          number,                                 /* Security Class id */
  parent_scid   number,
  parent_name   varchar2(128),
  parent_owner  varchar2(128)
)
not persistable
/

create or replace type ku$_xssecclsh_list_t force as table of (ku$_xssecclsh_t)
not persistable;
/

create or replace type ku$_xssclass_t force as object
(
  vers_major    char(1),                              /* UDT major version # */
  vers_minor    char(1),                              /* UDT minor version # */
  scid          number,                                 /* Security Class id */
  ctime         timestamp,
  mtime         timestamp,
  description   varchar2(4000),
  xs_obj        ku$_xsobj_t,                               /* XS object info */
  priv_list     ku$_xspriv_list_t,
  parent_list   ku$_xssecclsh_list_t
)
not persistable
/

-- Triton Security ACL (including ACEs, ACLParams, etc) views/types

create or replace type ku$_xsace_t force as object
(
  vers_major    char(1),                              /* UDT major version # */
  vers_minor    char(1),                              /* UDT minor version # */
  aclid         number,
  order_num     number,
  ace_type      number,                      /* 1 = GRANT(default), 0 = DENY */
  prin_id       number,
  prin_name     varchar2(132),
  prin_type     number,                                  /* 1=XS, 2=DB, 3=DN */
  prin_invert   number,                      /* 0 = FALSE(default), 1 = TRUE */
  start_date    timestamp,
  end_date      timestamp,
  priv_list     ku$_xsacepriv_list_t,
  xs_obj        ku$_xsobj_t,                               /* XS object info */
  xs_flag       number                                /* 2 - Oracle supplied */
)
not persistable
/

create or replace type ku$_xsace_list_t force as table of (ku$_xsace_t)
not persistable;
/

create or replace type ku$_xsaclparam_t force as object
(
  vers_major    char(1),                              /* UDT major version # */
  vers_minor    char(1),                              /* UDT minor version # */
  xdsid         number,
  policy_name   varchar2(128),
  policy_owner  varchar2(128),
  aclid         number,
  name          varchar2(128),
  pvalue1       number,                                     /* number values */
  pvalue2       varchar2(4000),                             /* string values */
  type          number           /* 1=NUMBER; 2=VARCHAR; 3=DATE; 4=Timestamp */
)
not persistable
/

create or replace type ku$_xsaclparam_list_t force
as table of (ku$_xsaclparam_t) not persistable;
/

create or replace type ku$_xsacl_t force as object
(
  vers_major    char(1),                              /* UDT major version # */
  vers_minor    char(1),                              /* UDT minor version # */
  aclid         number,
  name          varchar2(128),
  owner_name    varchar2(128),
  scid          number,
  sclass_name   varchar2(128),
  sclass_owner  varchar2(128),
  parent_aclid  number,
  parent_name   varchar2(128),
  parent_owner  varchar2(128),
  flag          number,
  ctime         timestamp,
  mtime         timestamp,
  description   varchar2(4000),
  xs_obj        ku$_xsobj_t,                               /* XS object info */
  xs_scl        ku$_xssclass_t,                      /* Security Class info */
  ace_list      ku$_xsace_list_t,
  param_list    ku$_xsaclparam_list_t
)
not persistable
/

------------------------------------------------------
--  Triton Data Security/Policy related types
-------
create or replace type ku$_xspolicy_param_t force as object
(
  vers_major    char(1),                              /* UDT major version # */
  vers_minor    char(1),                              /* UDT minor version # */
  xdsid         number,
  policy_name   varchar2(128),
  policy_owner  varchar2(128),
  name          varchar2(128),
  type          number           /* 1=NUMBER; 2=VARCHAR; 3=DATE; 4=Timestamp */
)
not persistable
/

create or replace type ku$_xsinst_acl_t force as object
(
  vers_major    char(1),                              /* UDT major version # */
  vers_minor    char(1),                              /* UDT minor version # */
  xdsid         number,
  order_num     number,
  aclid         number,
  acl_order_num number,
  xs_obj        ku$_xsobj_t                                /* XS object info */
)
not persistable
/

create or replace type ku$_xsinstacl_list_t force
as table of (ku$_xsinst_acl_t)
not persistable;
/

create or replace type ku$_xsinst_rule_t force as object
(
  vers_major    char(1),                              /* UDT major version # */
  vers_minor    char(1),                              /* UDT minor version # */
  xdsid         number,
  order_num     number,
  rule          varchar2(4000),
  static_flg    number,               /* 0=dynamic instset; 1=static instset */
  flags         number,     /* 0x1=rule is parameterized, 0x2=has denies,etc */
  description   varchar2(4000),                              /* default null */
  instacl_list  ku$_xsinstacl_list_t
)
not persistable
/

create or replace type ku$_xsinst_inhkey_t force as object
(
  vers_major    char(1),                              /* UDT major version # */
  vers_minor    char(1),                              /* UDT minor version # */
  xdsid         number,
  order_num     number,
  pkey          varchar2(128),
  fkey          varchar2(4000),
  fkey_type     number
)
not persistable
/

create or replace type ku$_xsinstinhkey_list_t force
as table of (ku$_xsinst_inhkey_t) not persistable;
/

create or replace type ku$_xsinst_inh_t force as object
(
  vers_major    char(1),                              /* UDT major version # */
  vers_minor    char(1),                              /* UDT minor version # */
  xdsid         number,
  order_num     number,
  parent_owner  varchar2(128),
  parent_name   varchar2(128),
  when_cl       varchar2(4000),
  inhkey_list   ku$_xsinstinhkey_list_t
)
not persistable
/


create or replace type ku$_xsinstinh_list_t force
as table of (ku$_xsinst_inh_t)
not persistable;
/

create or replace type ku$_xsattrsec_t force as object
(
  xdsid         number,
  priv_num      number,
  priv_name     varchar2(128),
  priv_owner    varchar2(128),
  name          varchar(128)
)
not persistable
/

create or replace type ku$_xsattrsec_list_t force as table of (ku$_xsattrsec_t)
not persistable;
/

create or replace type ku$_xsinstset_t force as object
(
  vers_major    char(1),                              /* UDT major version # */
  vers_minor    char(1),                              /* UDT minor version # */
  xdsid         number,
  order_num     number,
  type          number,  /* 1=rule-based instance set; 2=inheritant inst set */
  instrule      ku$_xsinst_rule_t,
  inst_inh      ku$_xsinstinh_list_t
)
not persistable
/

create or replace type ku$_xsinstset_list_t force as table of (ku$_xsinstset_t)
not persistable;
/

--  OLAP specific Data Security related types
create or replace type ku$_xsolap_policy_t force as object
(
  vers_major    char(1),                              /* UDT major version # */
  vers_minor    char(1),                              /* UDT minor version # */
  olap_schema   varchar2(128),                           /* OLAP schema_name */
  logical_name  varchar2(128),                /* xs$olap_policy.logical_name */
  owner_name    varchar2(128),               /* xs$olap_policy.policy_schema */
  name          varchar2(128),                 /* xs$olap_policy.policy_name */
  enable        number
)
not persistable
/


create or replace type ku$_xsolap_policy_list_t force 
as table of (ku$_xsolap_policy_t)
not persistable;
/

create or replace type ku$_xspolicy_t force as object
(
  vers_major       char(1),                           /* UDT major version # */
  vers_minor       char(1),                           /* UDT minor version # */
  xdsid            number,
  ctime            timestamp,
  mtime            timestamp,
  description      varchar2(4000),
  xs_obj           ku$_xsobj_t,                            /* XS object info */
  instset_list     ku$_xsinstset_list_t,
  attr_sec_list    ku$_xsattrsec_list_t,
  olap_policy_list ku$_xsolap_policy_list_t,
  rls_list         ku$_rls_policy_list_t
)
not persistable
/

-------
--  Triton Security Namespace related types
-------
create or replace type ku$_xsnstmpl_attr_t force as object
(
  vers_major    char(1),                              /* UDT major version # */
  vers_minor    char(1),                              /* UDT minor version # */
  ns_num        number,
  attr_name     varchar2(4000),
  def_value    varchar2(4000),
  event_cbk     number
  -- 0=no event callback, 1=first-read event,
  -- 2=update event, 3=both first read and update
)
not persistable
/

create or replace type ku$_xsnstmpl_attr_list_t force
as table of (ku$_xsnstmpl_attr_t) not persistable;
/

create or replace type ku$_xsnspace_t force as object
(
  vers_major     char(1),                            /* UDT major version # */
  vers_minor     char(1),                            /* UDT minor version # */
  xs_obj         ku$_xsobj_t,
  ns_num         number,
  aclid          number,
  handler_schema varchar2(128),                      /* handler schema name */
  handler_pkg    varchar2(128),                     /* handler package name */
  handler_func   varchar2(128),                    /* handler function name */
  ctime          timestamp,
  mtime          timestamp,
  description    varchar2(4000),
  attr_list      ku$_xsnstmpl_attr_list_t
)
not persistable
/

-------------------------------------------------------------------------------
--                              USER
-------------------------------------------------------------------------------
-- 
create or replace type ku$_user_editioning_t force as object
(
  user_id   number,
  type_name varchar2(128)
)
not persistable
/

create or replace type ku$_user_editioning_list_t
 force as TABLE of (ku$_user_editioning_t)
not persistable
/

create or replace type ku$_user_t force as object
(
  vers_major    char(1),                              /* UDT major version # */
  vers_minor    char(1),                              /* UDT minor version # */
  user_id       number,                                          /* user id  */
  name          varchar2(128),                               /* name of user */
  type_num      number ,                               /* 0 = role, 1 = user */
  password      varchar2(128),                         /* encrypted password */
  datats        varchar2(128),                   /* user default tablespace  */
  tempts        varchar2(128),    /* default tablespace for temporary tables */
  ltempts       varchar2(128),                      /* local temp tablespace */
  ctime         varchar2(19),                  /* user account creation time */
  ptime         varchar2(19),                        /* password change time */
  exptime       varchar2(19),             /* actual password expiration time */
  ltime         varchar2(19),                 /* time when account is locked */
  profnum       number,                                 /* resource profile# */
  profname      varchar2(128),                              /* profile name  */
  user_audit    varchar2(128),                         /* user audit options */
  defrole       number,                           /* default role indicator: */
  defgrp_num    number,                                /* default undo group */
  defgrp_seq_num   number,             /* global sequence number for the grp */
  astatus       number,                             /* status of the account */
  astatus_12    number,              /* status of the account for version 12 */
  lcount        number,                    /* count of failed login attempts */
  defschclass   varchar2(128),                     /* initial consumer group */
  ext_username  varchar2(400),                          /* external username */
  spare1        number,
  spare2        number,
  spare3        varchar2(128),                     /* Default collation name */
  spare4        varchar2(1000),           /* indentfier with only version 10 */
  spare4_12     varchar2(1000),     /* indentfier with version 10, 11 and 12 */
  spare5        varchar2(1000),
  spare6        varchar2(19),
  edn_types     ku$_user_editioning_list_t         /* editions-enabled types */
)
not persistable
/

-------------------------------------------------------------------------------
--                              ROLE
-------------------------------------------------------------------------------
-- 
create or replace type ku$_role_t force as object
(
  vers_major    char(1),                              /* UDT major version # */
  vers_minor    char(1),                              /* UDT minor version # */
  user_id       number,                                          /* role id  */
  name          varchar2(128),                               /* name of role */
  type_num      number ,                              /* 0 = role, 1 = user */
  password      varchar2(128),                                  /*  password */
  ctime         varchar2(19),                  /* user account creation time */
  ptime         varchar2(19),                        /* password change time */
  exptime       varchar2(19),             /* actual password expiration time */
  ltime         varchar2(19),                 /* time when account is locked */
  profnum       number,                                 /* resource profile# */
  user_audit        varchar2(38),                     /* user audit options */
  defrole       number,                           /* default role indicator: */
  defgrp_num       number,                             /* default undo group */
  defgrp_seq_num   number,             /* global sequence number for the grp */
  astatus       number,                             /* status of the account */
  lcount        number,                    /* count of failed login attempts */
  ext_username  varchar2(400),                          /* external username */
  spare1        number,
  spare2        number,
  spare3        number,
  spare4        varchar2(1000),
  spare5        varchar2(1000),
  spare6        varchar2(19),
  schema        varchar2(128),                                     /* schema */
  package       varchar2(128)                                     /* package */
)
not persistable
/

-------------------------------------------------------------------------------
--                              PROFILE
-------------------------------------------------------------------------------
-- 
create or replace type ku$_profile_attr_t force as object
(
  profile_id    number,                                       /* profile id  */
  resource_num  number,                                        /* resource id*/
  resname       varchar2(128),                              /* resource name */
  type_num              number,                                      /* type */
  limit_num             number                                      /* limit */
)
not persistable
/

create or replace type ku$_profile_list_t force 
as table of (ku$_profile_attr_t)
not persistable
/

create or replace type ku$_profile_t force as object
(
  vers_major    char(1),                              /* UDT major version # */
  vers_minor    char(1),                              /* UDT minor version # */
  profile_id    number,                                       /* profile id  */
  profile_name  varchar2(128),                               /* profile name */
  pass_func_name varchar2(128),                  /* password verify function */
  profile_list  ku$_profile_list_t                     /* profile attributes */
)
not persistable
/

-------------------------------------------------------------------------------
--                              DEFAULT_ROLE
-------------------------------------------------------------------------------
--
create or replace type ku$_defrole_item_t force as object
(
  user_id       number,                                          /* user id  */
  user_name     varchar2(128),                                  /* user name */
  role          varchar2(128),                           /* role source name */
  role_id       number                                            /* role id */
)
not persistable
/

create or replace type ku$_defrole_list_t force
as TABLE of (ku$_defrole_item_t)
not persistable
/

create or replace type ku$_defrole_t force as object
(
  vers_major    char(1),                              /* UDT major version # */
  vers_minor    char(1),                              /* UDT minor version # */
  user_id       number,                                       /* profile id  */
  user_name     varchar2(128),                                  /* user name */
  user_type     number,                                /* 0 = role, 1 = user */
  defrole       number,                                 /* default role type */
  role_list     ku$_defrole_list_t                              /* role list */
)
not persistable
/

-------------------------------------------------------------------------------
--                              PROXY
-------------------------------------------------------------------------------
--
create or replace type ku$_proxy_role_item_t force as object
(
  role_id       number,                                           /* role id */
  client        varchar2(128),                                /* client name */
  proxy         varchar2(128),                                 /* proxy name */
  role          varchar2(128)                                /* role context */
)
not persistable
/

create or replace type ku$_proxy_role_list_t force
as TABLE of (ku$_proxy_role_item_t)
not persistable
/

create or replace type ku$_proxy_t force as object
(
  user_id       number,                                           /* role id */
  client_name   varchar2(128),                                /* client name */
  proxy_name    varchar2(128),                                 /* proxy name */
  flags         number,               /* Mask flags of associated with entry */
  cred_type     number,                /* Type of credential passed by proxy */
  proxy_role_list  ku$_proxy_role_list_t                  /* proxy role list */
)
not persistable
/

-- 
-------------------------------------------------------------------------------
--                              ROLE_GRANT
-------------------------------------------------------------------------------
--
create or replace type ku$_rogrant_t force as object
(
  vers_major    char(1),                              /* UDT major version # */
  vers_minor    char(1),                              /* UDT minor version # */
  grantee_id    number,                                         /* user id  */
  grantee       varchar2(128),                                   /* grantee */
  role          varchar2(128),                                      /* role */
  role_id       number,                                          /* role id */
  admin         number,                                    /*  admin option */
  sequence      number,                            /* unique grant sequence */
  user_spare1   number
)
not persistable
/

-------------------------------------------------------------------------------
--                              TABLESPACE_QUOTA
-------------------------------------------------------------------------------
-- 
create or replace type ku$_tsquota_t force as object
(
  vers_major    char(1),                              /* UDT major version # */
  vers_minor    char(1),                              /* UDT minor version # */
  user_id       number,                                          /* user id  */
  user_name     varchar2(128),                               /* name of user */
  ts_name       varchar2(128),                            /* tablespace name */
  ts_id         number,                                     /* tablespace id */
  maxblocks     number,                                        /* max blocks */
  blocksize     number,                                       /* blocks size */
  grantor_num   number,                                        /* grantor id */
  grantor       varchar2(128),                               /* grantor name */
  blocks        number,                  /* number of blocks charged to user */
  priv1         number,                     /* reserved for future privilege */
  priv2         number,                     /* reserved for future privilege */
  priv3         number                      /* reserved for future privilege */
)
not persistable
/

-------------------------------------------------------------------------------
--                              RESOURCE_COST 
-------------------------------------------------------------------------------
-- 
create or replace type ku$_resocost_item_t force as object
(
  resource_id       number,                                   /* resource id */
  resource_name     varchar2(128),                               /* resource */
  resource_type     number,                                          /* type */
  unit_cost         number                                      /* unit cost */
)
not persistable
/

create or replace type ku$_resocost_list_t force
as TABLE of (ku$_resocost_item_t)
not persistable
/

create or replace type ku$_resocost_t force as object
(
  vers_major    char(1),                             /* UDT major version # */
  vers_minor    char(1),                             /* UDT minor version # */
  cost_list     ku$_resocost_list_t                   /* resource cost info */
)
not persistable
/

-------------------------------------------------------------------------------
--                              CONTEXT
-------------------------------------------------------------------------------
-- 
create or replace type ku$_context_t force as object
(
  vers_major    char(1),                              /* UDT major version # */
  vers_minor    char(1),                              /* UDT minor version # */
  obj_num       number,                            /* context object number */
  schema_obj    ku$_schemaobj_t,                   /* context schema object */
  schema_name   varchar2(128),                                /* schema name */
  package_name  varchar2(128),                               /* package name */
  flags         number
)
not persistable
/

-------------------------------------------------------------------------------
--                              DIMENSION
-------------------------------------------------------------------------------
-- 
create or replace type ku$_dimension_t force as object
(
  vers_major    char(1),                              /* UDT major version # */
  vers_minor    char(1),                              /* UDT minor version # */
  obj_num       number,                           /* dimension object number */
  schema_obj    ku$_schemaobj_t,                  /* dimension schema object */
  dimtextlen    number,                                 /* length of dimtext */
  dimtext       clob                      /* store the dimension when length */
)
not persistable
/

-------------------------------------------------------------------------------
--                              ASSOCIATION
-------------------------------------------------------------------------------
create or replace type ku$_assoc_t force as object
(
  vers_major    char(1),                              /* UDT major version # */
  vers_minor    char(1),                              /* UDT minor version # */
  obj_num       number,                              /* association object # */
  base_obj      ku$_schemaobj_t,                              /* base object */
  obj_type      number,                                  /* association type */
  objcol        varchar2(128),                         /* association column */
  stats_obj     ku$_schemaobj_t,                            /* statistic obj */
  selectivity   number,                                       /* selectivity */
  cpu_cost      number,                                           /* cpu cost*/
  io_cost       number,                                           /* io cost */
  net_cost      number,                                          /* net cost */
  interface_version number,
  spare2        number
)
not persistable
/

-------------------------------------------------------------------------------
--                              COMMENT
-------------------------------------------------------------------------------
-- 
create or replace type ku$_comment_t force as object
(
  vers_major    char(1),                              /* UDT major version # */
  vers_minor    char(1),                              /* UDT minor version # */
  obj_num       number,                                     /* object number */
  base_obj      ku$_schemaobj_t,                       /* base schema object */
  property      number,                                  /* table properties */
  colno         number,                                         /* column id */
  colname       varchar2(128),                                /* column name */
  cmnt          clob                                         /* comment text */
)
not persistable
/

-------------------------------------------------------------------------------
--                              CLUSTER
-------------------------------------------------------------------------------
--
create or replace type ku$_cluster_t force as object
(
  vers_major    char(1),                              /* UDT major version # */
  vers_minor    char(1),                              /* UDT minor version # */
  obj_num       number,                                  /* cluster object # */
  schema_obj    ku$_schemaobj_t,                       /* cluster schema obj */
  col_list      ku$_tab_column_list_t,
  ts_name       varchar2(128),                                 /* tablespace */
  blocksize     number,                            /* size of block in bytes */
  tsno          number,                                 /* tablespace number */
  fileno        number,                        /* segment header file number */
  blockno       number,                       /* segment header block number */
  pct_free      number,          /* minimum free space percentage in a block */
  pct_used      number,          /* minimum used space percentage in a block */
  initrans      number,                     /* initial number of transaction */
  maxtrans      number,                     /* maximum number of transaction */
  size_t        number,
  hashfunc      varchar2(128),             /* if hashed, function identifier */
  hashkeys      number,                                    /* hash key count */
  function      number, /* function: 0 (key is function), 1 (system default) */
  extind        number,             /* extent index value of fixed hash area */
  flags         number,                                      /* 0x08 = CACHE */
                                          /* 0x010000 = Single Table Cluster */
                                                /* 0x00800000 = DEPENDENCIES */
  degree        number,      /* number of parallel query slaves per instance */
  instances     number,       /*  number of OPS instances for parallel query */
  avgchn        number,          /* average chain length - previously spare4 */
  funclen       number,
  functxt       varchar2(4000),
  func_vcnt     ku$_vcnt,
  func_clob     clob,
  storage       ku$_storage_t,
  spare1        number,
  spare2        number,
  spare3        number,
  spare4        number,
  spare5        varchar2(1000),
  spare6        varchar2(1000),
  spare7        varchar2(19),
  part_obj      ku$_tab_partobj_t                        /* Partitioned info */
)
not persistable
/

-------------------------------------------------------------------------------
--                              AUDIT
-------------------------------------------------------------------------------
create or replace type ku$_audit_t force as object
(
  vers_major    char(1),
  vers_minor    char(1),
  user_num      number,                            /* user identifier number */
  user_name     varchar2(128),                                  /* user name */
  proxy_num     number,                             /* UID of the proxy user */
  audit_option  varchar2(128),                            /* auditing option */
  property      number,                   /* 0x01 = do not export this audit */
  success       number,                                 /* audit on success? */
  failure       number,                                 /* audit on failure? */
  option_num    number                              /* option# in option map */
)
not persistable
/

-------------------------------------------------------------------------------
--                              AUDIT_OBJ
-------------------------------------------------------------------------------
create or replace type ku$_audit_obj_t force as object
(
  vers_major    char(1),
  vers_minor    char(1),
  obj_num       number,                                     /* object number */
  base_obj      ku$_schemaobj_t,                          /* base obj schema */
  audit_val     varchar2(128),                           /* auditing options */
  audit_list    sys.ku$_audit_list_t                           /* audit list */
)
not persistable
/

-------------------------------------------------------------------------------
--                              AUDIT_DEFAULT
-------------------------------------------------------------------------------
create or replace type ku$_audit_default_t force as object
(
  vers_major       char(1),
  vers_minor       char(1),
  obj_num          number,                                /* object number */
  audit_val        varchar2(128),                      /* auditing options */
  aud_default_list sys.ku$_audit_default_list_t              /* audit list */
)
not persistable
/

-------------------------------------------------------------------------------
--                              AUDIT_POLICY
-------------------------------------------------------------------------------
create or replace type ku$_audit_sys_priv_t force as object (
        PRIVILEGE     number,
        NAME          varchar2(128),
        PROPERTY      number          /* 0x01 = do not export this privilege */
                                      /* using sql statements */
  )
not persistable
/
create or replace type ku$_audit_sys_priv_list_t
 force as table of (ku$_audit_sys_priv_t)
not persistable
/

create or replace type ku$_audit_act_t force as object (
        ACTION        number,
        NAME          varchar2(128)
  )
not persistable
/
create or replace type ku$_audit_act_list_t
 force as table of (ku$_audit_act_t)
not persistable
/

create or replace type ku$_auditp_obj_t force as object (
        ACTION        number,
        audit_obj     ku$_schemaobj_t,              /* object being auditede */
        NAME          varchar2(128)
  )
not persistable
/
create or replace type ku$_auditp_obj_list_t
 force as table of (ku$_auditp_obj_t)
not persistable
/

create or replace type ku$_audit_pol_role_t force as object (
  role_num        number,
  role_name       varchar2(128)
  )
not persistable
/
create or replace type ku$_audit_pol_role_list_t
 force as table of (ku$_audit_pol_role_t)
not persistable
/

create or replace type ku$_audit_policy_t force as object (
  policy_num    number,
  schema_obj    ku$_schemaobj_t,                            /* policy object */
  type          number,            /*     0 - Invalid
                                    *  0x01 - System Privilgege options
                                    *  0x02 - System Action options
                                    *  0x04 - Object Action options
                                    *  0x08 - Local Audit Policy in case of 
                                    *         Consolidated Database
                                    *  0x10 - Common Audit Policy in case of 
                                    *         Consolidated Database
                                    *  0x20 - Role Privilege options 
                                    */
  condition         varchar2(4000),
  condition_eval    number,
  privilege_options  ku$_audit_sys_priv_list_t,
  sys_action_options ku$_audit_act_list_t,
  xs_action_options  ku$_audit_act_list_t,
  ols_action_options ku$_audit_act_list_t,
  obj_action_options ku$_auditp_obj_list_t,
  role_options       ku$_audit_pol_role_list_t
  )
not persistable
/  
-------------------------------------------------------------------------------
--                              AUDIT_POLICY_ENABLE
-------------------------------------------------------------------------------
create or replace type ku$_audit_policy_enable_t force as object (
  policy_num    number,
  schema_obj    ku$_schemaobj_t,                            /* policy object */
  "USER"        varchar2(128),    /* Name of user/role, NULL for 'ALL USERS' */
  when_opt      number,                /* 1 - Success, 2 - Failure, 3 - Both */
  how_opt       number) /* 1 - By User, 2 - Except User, 3 - By Granted Role */
not persistable
/
-------------------------------------------------------------------------------
--                              AUDIT_CONTEXT
-------------------------------------------------------------------------------
create or replace type ku$_audit_attr_list_t
 force as table of (varchar2(128))
not persistable
/

create or replace type ku$_audit_namespace_t force as object (
  namespace     varchar2(128),
  aud_attr      ku$_audit_attr_list_t)
not persistable
/
create or replace type ku$_audit_namespace_list_t
 force as table of (ku$_audit_namespace_t)
not persistable
/
create or replace type ku$_audit_context_t force as object (
  "USER"        varchar2(128),
  aud_context   ku$_audit_namespace_list_t)
not persistable
/

-------------------------------------------------------------------------------
--                              JAVA_SOURCE
-------------------------------------------------------------------------------
-- 
create or replace type ku$_java_source_t force as object
(
  vers_major    char(1),                              /* UDT major version # */
  vers_minor    char(1),                              /* UDT minor version # */
  obj_num       number,                         /* java source object number */
  schema_obj    ku$_schemaobj_t,                /* java source schema object */
  long_name     varchar2(4000),                              /* synlong name */
  source_lines  ku$_source_list_t,                           /* source lines */
  java_resource sys.ku$_java_t                             /* export source  */
)
not persistable
/

-------------------------------------------------------------------------------
--                              AQ_QUEUE_TABLE
-------------------------------------------------------------------------------
--
-- QUEUE_TABLE storage clause info 

create or replace type ku$_qtab_storage_t force as object
(
  obj_num       number,                         /* queue table object number */
  property      number,
  ts_num        number,
  ts_name       varchar2(128),
  pct_free      number,
  pct_used      number,
  initrans      number,
  maxtrans      number,
  flags         number,                                     /* Row movement */
  storage       ku$_storage_t,                              /* Storage info */
  col_list      ku$_tab_column_list_t,                   /* list of columns */
  clus_tab      ku$_tabcluster_t                        /* Table clustering */
)
not persistable
/

create or replace type ku$_queue_table_t force as object
(
  vers_major    char(1),                              /* UDT major version # */
  vers_minor    char(1),                              /* UDT minor version # */
  obj_num       number,                         /* queue table object number */
  schema_obj    ku$_schemaobj_t,                    /* object of queue table */
  storage_clause ku$_qtab_storage_t,                  /* storage_clause info */
  udata_type    number,                                     /* userdata type */
  object_type   varchar2(257),                         /* userdata type name */
  sort_cols     number,                            /* sort order for dequeue */
  flags         number,                            /* queue table properties */
  table_comment         varchar2(2000),                      /* user comment */
  primary_instance      number,                /*  primary owner instance-id */
  secondary_instance    number,               /* secondary owner instance-id */
  owner_instance        number                  /* current owner instance-id */
)
not persistable
/

-------------------------------------------------------------------------------
--                              AQ_QUEUE
-------------------------------------------------------------------------------
-- 
create or replace type ku$_queues_t force as object
(
  vers_major    char(1),                              /* UDT major version # */
  vers_minor    char(1),                              /* UDT minor version # */
  obj_num       number,                         /* queue table object number */
  qid           number,                            /* queue obj number */
  schema_obj    ku$_schemaobj_t,                      /* queue object schema */
  base_obj      ku$_schemaobj_t,                   /* queue table obj schema */
  tflags        number,                            /* queue table properties */
  usage         number,                                /* usage of the queue */
  max_retries   number,                         /* maximum number of retries */
  retry_delay   number,                      /* delay before retrying (secs) */
  enqueue_enabled number,                                 /*  queue enabled? */
  properties    number,                      /*  various properties of queue */
  retention     number,                       /* retention time (in seconds) */
  queue_comment  varchar2(2000)                              /* user comment */
)
not persistable
/

--
-------------------------------------------------------------------------------
--                              AQ_TRANSFORM
-------------------------------------------------------------------------------
-- 
create or replace type ku$_qtrans_t force as object
(
  vers_major    char(1),                              /* UDT major version # */
  vers_minor    char(1),                              /* UDT minor version # */
  transformation_id    number,                          /* transformation id */
  schema_name          varchar2(128),                              /* schema */
  transform_name       varchar2(128),                 /* transformation name */
  from_obj             ku$_schemaobj_t,                   /* from obj schema */
  to_obj               ku$_schemaobj_t,                     /* to obj schema */
  attribute_num        number,
  sql_expression       clob
)
not persistable
/

--
-------------------------------------------------------------------------------
--                              JOB
-------------------------------------------------------------------------------
-- 
create or replace type ku$_job_t force as object
(
  vers_major    char(1),                              /* UDT major version # */
  vers_minor    char(1),                              /* UDT minor version # */
  powner_id     number,                                          /* owner id */
  powner        varchar2(128),                                 /* owner name */
  lowner        varchar2(128),                             /* logged in user */
  cowner        varchar2(128),                                   /* parsing  */
  job_id        number,                                           /* job id  */
  last_date     varchar2(19),                /* when this job last succeeded */
  this_date     varchar2(19),   /* when current execute started,usually null */
  next_date     varchar2(19),                /* when to execute the job next */
  flag          number,                          /* 0x01, this job is broken */
  failures      number,             /* number of failures since last success */
  interval_num  varchar2(400),                /* function for next next_date */
  what          clob,                        /* PL/SQL text, what is the job */
  nlsenv        clob,                                      /* nls parameters */
  env           raw(32),                      /* other environment variables */
  field1        number,            /* instance number restricted to run  job */
  charenv       varchar2(4000)                /* Reserved for Trusted Oracle */
)
not persistable
/

--
-------------------------------------------------------------------------------
--                      TABLE/INDEX/CLUSTER STATISTICS
-------------------------------------------------------------------------------
--
create or replace type ku$_histgrm_t force as object
(
  obj_num           number,             -- histogram object number
  intcol_num        number,             -- internal object number
  bucket            number,             -- bucket information
  endpoint          number,             -- endpoint value
  epvalue           VARCHAR2(4000),     -- ep value
  epvalue_raw       RAW(1000),          -- ep value in raw type (12g)
  ep_repeat_count   NUMBER,             -- ep repeat count (12g)
  spare1            number              -- sample number of distinct values
)
not persistable
/

create or replace type ku$_histgrm_list_t
 force as table of (ku$_histgrm_t)
not persistable
/

--
-- type for column statistics
--
create or replace type ku$_col_stats_t force as object
(
  obj_num           number,             -- table/partition/subpartition objnum
  intcol_num        number,             -- internal column number
  distcnt           number,             -- distinct count
  lowval            raw(32),            -- low value
  lowval_1000       raw(1000),          -- low value - raw 1000 (12g)
  hival             raw(32),            -- high value
  hival_1000        raw(1000),          -- high value - raw 1000 (12g)
  density           number,             -- density
  null_cnt          number,             -- null count
  avgcln            number,             -- average column length
  cflags            number,             -- flags
  eav               number,
  sample_size       number,
  minimum           number,
  maximum           number,
  spare1            number,             -- sample number of distinct values
  hist_gram_list    ku$_histgrm_list_t  -- histogram list
)
not persistable
/

create or replace type ku$_col_stats_list_t
 force as table of (ku$_col_stats_t)
not persistable
/

--
-- type for column statistics for 10_1 compatiblity
--
create or replace type ku$_10_1_col_stats_t force as object
(
  tab_obj_num       number,             -- table object number
  p_obj_num         number,             -- partition object number
  colname           VARCHAR2(30),       -- column name
  intcol_num        number,             -- internal column number
  distcnt           number,             -- distinct count
  lowval            raw(32),            -- low value
  hival             raw(32),            -- high value
  density           number,             -- density
  null_cnt          number,             -- null count
  avgcln            number,             -- average column length
  cflags            number,             -- flags
  eav               number,             --
  hist_gram_list    ku$_histgrm_list_t, -- histogram list
  hist_gram_min     ku$_histgrm_t,      -- minimum histogram
  hist_gram_max     ku$_histgrm_t       -- maximum histogram
)
not persistable
/

create or replace type ku$_10_1_col_stats_list_t
 force as table of (ku$_10_1_col_stats_t)
not persistable
/

create or replace type ku$_cached_stats_t force as object
(
  obj_num       number,
  cachedblk     number,
  cachehit      number
)
not persistable
/

--
-- table and partition specific statistic data
--
create or replace type ku$_tab_ptab_stats_t force as object
(
  obj_num           number,             -- table object number
  trigflag          number,             -- table trigflag
  tabname           VARCHAR2(128),      -- table/nested table name
  partname          VARCHAR2(128),      -- Partition name
  subpartname       VARCHAR2(128),      -- subpartition name
  bobj_num          number,             -- base object number for part. tabs
  sysgen_cols       number,             -- system generated columns?
  blkcnt            number,             -- block count
  rowcnt            number,             -- row count
  avgrln            number,             -- average row length
  flags             number,             -- global/user spec. stats
  sample_size       number,             -- number of rows sampled by Analyze
  analyzetime       varchar2(19),       -- timestamp when last analyzed
  cache_info        ku$_cached_stats_t, -- cached stats information
  col_stats         ku$_col_stats_list_t-- column stats list for table (part)
)
not persistable
/

--
-- Type list for partition specific statistic data
--
create or replace type ku$_ptab_stats_list_t
 force as table of (ku$_tab_ptab_stats_t)
not persistable
/

--
-- table and partition specific statistic data for 10.1 compatibility
--
create or replace type ku$_10_1_tab_ptab_stats_t force as object
(
  obj_num           number,             -- table object number
  trigflag          number,             -- table trigflag
  schema_obj        ku$_schemaobj_t,    -- table schema object
  bobj_num          number,             -- base object number for part. tabs
  sysgen_cols       number,             -- system generated columns?
  blkcnt            number,             -- block count
  rowcnt            number,             -- row count
  avgrln            number,             -- average row length
  flags             number,             -- global/user spec. stats
  cache_info        ku$_cached_stats_t, -- cached stats information
  col_stats         ku$_10_1_col_stats_list_t
                                        -- column stats list for table (part)
)
not persistable
/

--
-- Type list for partition specific statistic data for 10.1 compatibility
--
create or replace type ku$_10_1_ptab_stats_list_t
 force as table of (ku$_10_1_tab_ptab_stats_t)
not persistable
/

--
-- This type changed in 11.1.0.7, but just added columns that won't be used
-- in anything prior to 11.1.0.7, so it can be used when compatibility is set
-- prior to 11.1.0.7.
--
create or replace type ku$_tab_col_t force as object
(
  obj_num           number,             -- histogram object number
  colname           VARCHAR2(128),      -- column name
  name              VARCHAR2(128),      -- column name (backward compatibility)
  intcol_num        number,             -- internal column number
  col_num           number,             -- column number
  property          number,             -- column property
  nested_table      number,             -- 0 if no, 1 if yes
  attr_colname      varchar2(4000),     -- col name from attrcol$
  default_val       varchar2(4000)      -- virtual column expression text
)
not persistable
/

create or replace type ku$_tab_col_list_t
 force as table of (ku$_tab_col_t)
not persistable
/

--
-- type for full table statistics
--
create or replace type ku$_tab_stats_t force as object
(
  vers_major        char(1),                    -- UDT major version #
  vers_minor        char(1),                    -- UDT minor version #
  obj_num           number,                     -- object number for table
  base_obj          ku$_schemaobj_t,            -- table information
  nested_tab_name   varchar2(128)               -- nested table name
)
not persistable
/

create or replace type ku$_11_2_tab_stats_t force as object
(
  vers_major        char(1),                    -- UDT major version #
  vers_minor        char(1),                    -- UDT minor version #
  obj_num           number,                     -- object number for table
  base_obj          ku$_schemaobj_t,            -- table information
  nested_tab_name   varchar2(30),               -- nested table name
  column_list       ku$_tab_col_list_t,         -- column list
  tab_info          ku$_tab_ptab_stats_t,       -- table statistics
  ptab_info_list    ku$_ptab_stats_list_t       -- partitioned statistics
)
not persistable
/

--
-- type for full table statistics for 10.1 compatibility
--
create or replace type ku$_10_1_tab_stats_t force as object
(
  vers_major        char(1),                    -- UDT major version #
  vers_minor        char(1),                    -- UDT minor version #
  obj_num           number,                     -- object number for table
  base_obj          ku$_schemaobj_t,            -- table information
  tab_info          ku$_10_1_tab_ptab_stats_t,  -- table statistics
  ptab_info_list    ku$_10_1_ptab_stats_list_t  -- partitioned statistics
)
not persistable
/

--
-- type for index stats values
--
-- type for subpartition portion of index information
--
create or replace type ku$_spind_stats_t force as object
(
  obj_num           number,
  partname          varchar2(128),
  subpartname       varchar2(128),
  bobj_num          number,
  rowcnt            number,
  leafcnt           number,
  distkey           number,
  lblkkey           number,
  dblkkey           number,
  clufac            number,
  blevel            number,
  ind_flags         number,
  obj_flags         number,
  sample_size       number,
  analyzetime       varchar2(19),       -- timestamp when last analyzed
  cache_info        ku$_cached_stats_t              -- cached stats information
)
not persistable
/

create or replace type ku$_spind_stats_list_t
 force as table of (ku$_spind_stats_t)
not persistable
/

--
-- type for subpartition portion of index information for 10.1 compatibility
--
create or replace type ku$_10_1_spind_stats_t force as object
(
  obj_num           number,
  schema_obj        ku$_schemaobj_t,
  bobj_num          number,
  rowcnt            number,
  leafcnt           number,
  distkey           number,
  lblkkey           number,
  dblkkey           number,
  clufac            number,
  blevel            number,
  ind_flags         number,
  obj_flags         number,
  cache_info        ku$_cached_stats_t              -- cached stats information
)
not persistable
/

create or replace type ku$_10_1_spind_stats_list_t
 force as table of (ku$_10_1_spind_stats_t)
not persistable
/

--
-- type for partition portion of index information
--
create or replace type ku$_pind_stats_t force as object
(
  obj_num           number,
  partname          VARCHAR2(128),
  bobj_num          number,
  rowcnt            number,
  leafcnt           number,
  distkey           number,
  lblkkey           number,
  dblkkey           number,
  clufac            number,
  blevel            number,
  ind_flags         number,
  obj_flags         number,
  sample_size       number,
  analyzetime       varchar2(19),       -- timestamp when last analyzed
  cache_info        ku$_cached_stats_t, -- cached stats information
  subpartition_list ku$_spind_stats_list_t
)
not persistable
/

create or replace type ku$_pind_stats_list_t
 force as table of (ku$_pind_stats_t)
not persistable
/

--
-- type for partition portion of index information for 10.1 compatibility
--
create or replace type ku$_10_1_pind_stats_t force as object
(
  obj_num           number,
  schema_obj        ku$_schemaobj_t,
  bobj_num          number,
  rowcnt            number,
  leafcnt           number,
  distkey           number,
  lblkkey           number,
  dblkkey           number,
  clufac            number,
  blevel            number,
  ind_flags         number,
  obj_flags         number,
  cache_info        ku$_cached_stats_t, -- cached stats information
  subpartition_list ku$_10_1_spind_stats_list_t
)
not persistable
/

create or replace type ku$_10_1_pind_stats_list_t
 force as table of (ku$_10_1_pind_stats_t)
not persistable
/

create or replace type ku$_ind_stats_t force as object
(
  vers_major        char(1),                          /* UDT major version # */
  vers_minor        char(1),                          /* UDT minor version # */
  obj_num           number,                                   /* Index obj # */
  base_obj_num      number,                                   /* Table obj # */
  base_tab_obj      ku$_schemaobj_t,
  base_ind_obj      ku$_schemaobj_t,
  type_num          number,                   /* what kind of index is this? */
  property          number         /* immutable flags for life of the index */
)
not persistable
/

create or replace type ku$_11_2_ind_stats_t force as object
(
  vers_major        char(1),                          /* UDT major version # */
  vers_minor        char(1),                          /* UDT minor version # */
  obj_num           number,                                   /* Index obj # */
  base_obj_num      number,                                   /* Table obj # */
  base_tab_obj      ku$_schemaobj_t,
  base_ind_obj      ku$_schemaobj_t,
  type_num          number,                   /* what kind of index is this? */
  property          number,         /* immutable flags for life of the index */
  cols              number,
  rowcnt            number,
  leafcnt           number,
  distkey           number,
  lblkkey           number,
  dblkkey           number,
  clufac            number,
  blevel            number,
  ind_flags         number,
  obj_flags         number,
  sample_size       number,
  analyzetime       varchar2(19),       -- timestamp when last analyzed
  cache_info        ku$_cached_stats_t, -- cached stats information
  partition_list    ku$_pind_stats_list_t,
  cnst_col_list     ku$_tab_col_list_t
)
not persistable
/

-- type for 10.1 compatibility
create or replace type ku$_10_1_ind_stats_t force as object
(
  vers_major        char(1),                          /* UDT major version # */
  vers_minor        char(1),                          /* UDT minor version # */
  obj_num           number,                                   /* Index obj # */
  base_obj_num      number,                                   /* Table obj # */
  base_tab_obj      ku$_schemaobj_t,
  base_ind_obj      ku$_schemaobj_t,
  type_num          number,                   /* what kind of index is this? */
  property          number,         /* immutable flags for life of the index */
  cols              number,
  rowcnt            number,
  leafcnt           number,
  distkey           number,
  lblkkey           number,
  dblkkey           number,
  clufac            number,
  blevel            number,
  ind_flags         number,
  obj_flags         number,
  cache_info        ku$_cached_stats_t, -- cached stats information
  partition_list    ku$_10_1_pind_stats_list_t,
  cnst_col_list     ku$_tab_col_list_t
)
not persistable
/

--
-- These types are used in the kustat.xsl style sheet to determine
-- the index name when an index is system generated.
--

--
-- type for system generated index column information
--
create or replace type ku$_sgi_col_t force as object
(
  obj_num           number,                 -- index object number
  con_num           number,                 -- constraint number if constraint
  name              varchar2(128)           -- column name
)
not persistable
/

create or replace type ku$_sgi_col_list_t
 force as table of (ku$_sgi_col_t)
not persistable
/

create or replace type ku$_find_sgc_t force as object
(
  obj_num               number,                           /* index obj # */
  num_cols              number,                           /* #cols in index */
  index_owner           varchar2(128),
  index_name            varchar2(128),
  table_owner           varchar2(128),
  table_name            varchar2(128),
  col_list              ku$_sgi_col_list_t
)
not persistable
/

-------------------------------------------------------------------------------
--                              USER PREFERENCE STATS
-------------------------------------------------------------------------------
-- 
create or replace type ku$_up_stats_t force as object
(
  obj_num            number,                    -- object number for table
  pname              varchar2(128),
  valnum             number,
  valchar            varchar2(4000),
  chgtime            varchar2(19),
  spare1             NUMBER)
not persistable
/

create or replace type ku$_up_stats_list_t
 force as table of (ku$_up_stats_t)
not persistable
/

create or replace type ku$_user_pref_stats_t force as object
(
  vers_major        char(1),                    -- UDT major version #
  vers_minor        char(1),                    -- UDT minor version # */
  obj_num            number,                    -- object number for table
  base_obj           ku$_schemaobj_t,           -- table information
  up_stats_list      ku$_up_stats_list_t) not persistable;
/

-------------------------------------------------------------------------------
--                              JAVA_CLASS
-------------------------------------------------------------------------------
-- 
create or replace type ku$_java_class_t force as object
(
  vers_major    char(1),                              /* UDT major version # */
  vers_minor    char(1),                              /* UDT minor version # */
  obj_num       number,                         /* java source object number */
  schema_obj    ku$_schemaobj_t,                /* java source schema object */
  long_name     varchar2(4000),                         /* synonym long name */
  java_resource sys.ku$_java_t                               /* source lines */
)
not persistable
/

-------------------------------------------------------------------------------
--                              JAVA_RESOURCE
-------------------------------------------------------------------------------
-- 
create or replace type ku$_java_resource_t force as object
(
  vers_major    char(1),                              /* UDT major version # */
  vers_minor    char(1),                              /* UDT minor version # */
  obj_num       number,                         /* java source object number */
  schema_obj    ku$_schemaobj_t,                /* java source schema object */
  long_name     varchar2(4000),                         /* synonym long name */
  java_resource sys.ku$_java_t                               /* source lines */
)
not persistable
/

-------------------------------------------------------------------------------
--                      REFRESH_GROUP
-------------------------------------------------------------------------------
create or replace type ku$_add_snap_t force as object
(
  REFGROUP       number,                          /* number of refresh group */
  ref_add_user   varchar2(2000),          /* dbms_refresh.add execute string */
  ref_add_dba    varchar2(2000)          /* dbms_irefresh.add execute string */
)
not persistable
/

create or replace type ku$_add_snap_list_t force as TABLE of (ku$_add_snap_t)
not persistable;
/

create or replace type ku$_refgroup_t force as object
(
  vers_major    char(1),                              /* UDT major version # */
  vers_minor    char(1),                              /* UDT minor version # */
  refname       varchar2(128),                      /* name of refresh group */
  owner_num     number,                                 /* owner user number */
  refowner      varchar2(128),                     /* owner of refresh group */
  refgroup      number,                           /* number of refresh group */
  ref_make_user varchar2(2000),     /* executing string of dbms_refresh.make */
  ref_make_dba  varchar2(2000),    /* executing string of dbms_irefresh.make */
  ref_child     ku$_add_snap_list_t              /* refresh group child info */
                                          /* dbms_refresh.add execute string */
)
not persistable
/

-- 
-------------------------------------------------------------------------------
--                      MONITORING
-------------------------------------------------------------------------------
create or replace type ku$_monitor_t force as object
(
  vers_major    char(1),                              /* UDT major version # */
  vers_minor    char(2),                              /* UDT minor version # */
  obj_num       number,                                /* base object number */
  base_obj      ku$_schemaobj_t,                       /* base schema object */
  monitor       number                              /* 1: enable, 0: disable */
)
not persistable
/

--
-------------------------------------------------------------------------------
--                      RMGR_PLAN
-------------------------------------------------------------------------------
-- 
create or replace type ku$_rmgr_plan_t force as object
(
  vers_major    char(1),                              /* UDT major version # */
  vers_minor    char(1),                              /* UDT minor version # */
  obj_num       number,
  schema_obj    ku$_schemaobj_t,
  cpu_method    varchar2(128),/* CPU resource allocation method for the plan */
  mast_method   varchar2(128),    /* maximum active sessions target resource */
                                  /* allocation method for the plan          */
  pdl_method    varchar2(128),             /* parallel degree limit resource */
                                           /* allocation method for the plan */
  num_plan_directives   number,    /* Number of plan directives for the plan */
  description   varchar2(2000),                  /* Text comment on the plan */
  que_method    varchar2(128),                 /* queueing method for groups */
  status        varchar2(128),                          /* PENDING or ACTIVE */
  mandatory     number                      /* Whether the plan is mandatory */
)
not persistable
/

--
-------------------------------------------------------------------------------
--                      RMGR_PLAN_DIRECTIVE
-------------------------------------------------------------------------------
-- 
create or replace type ku$_rmgr_plan_direct_t force as object
(
  vers_major    char(1),                              /* UDT major version # */
  vers_minor    char(1),                              /* UDT minor version # */
  obj_num       number,
  base_obj      ku$_schemaobj_t,
  group_or_subplan  varchar2(128),   /* Name of the consumer group or sub-plan
                                                                 referred to */
  type          number,                     /* 1: plan , 0: GROUP_OR_SUBPLAN */
  cpu_p1        number,           /* 1st parameter for CPU allocation method */
  cpu_p2        number,           /* 2nd parameter for CPU allocation method */
  cpu_p3        number,           /* 3rd parameter for CPU allocation method */
  cpu_p4        number,           /* 4th parameter for CPU allocation method */
  cpu_p5        number,           /* 5th parameter for CPU allocation method */
  cpu_p6        number,           /* 6th parameter for CPU allocation method */
  cpu_p7        number,           /* 7th parameter for CPU allocation method */
  cpu_p8        number,           /* 8th parameter for CPU allocation method */
  active_sess_pool_p1   number,       /* 1st parameter for max active sessions
                                                    target allocation method */
  queueing_p1           number,     /* 1st parameter for the queueing method */
  parallel_degree_limit_p1 number,   /* 1st parameter for the parallel degree
                                            limit resource allocation method */
  switch_group          varchar2(128),  /* group to switch to once switch time
                                                                  is reached */
  switch_time           number,       /* switch time limit for execution within
                                                                     a group */
  switch_estimate       number,   /* use execution estimate to determine
                                                                      group? */
  max_est_exec_time     number,      /* use of max. estimated execution time */
  undo_pool             number,  /* max. undo allocation for consumer groups */
  comments              varchar(2000), /* Text comment on the plan directive */
  status                varchar2(128),                /* PENDING  or ACTIVE  */
  mandatory             number                               /* 1 yes, 0 no  */
)
not persistable
/

--
-------------------------------------------------------------------------------
--                      RMGR_CONSUMER_GROUP
-------------------------------------------------------------------------------
-- 
create or replace type ku$_rmgr_consumer_t force as object
(
  vers_major    char(1),                              /* UDT major version # */
  vers_minor    char(1),                              /* UDT minor version # */
  obj_num       number,
  schema_obj    ku$_schemaobj_t,
  cpu_method    varchar2(128),     /* CPU resource alloc method for the plan */
  description   varchar2(2000),        /* Text comment on the consumer group */
  status        varchar2(128),                          /* pending or active */
  mandatory     number                                      /* 1:yes , 0: no */
)
not persistable
/

--
-------------------------------------------------------------------------------
--                      RMGR_INITIAL_CONSUMER_GROUP
-------------------------------------------------------------------------------
-- 
create or replace type ku$_rmgr_init_consumer_t force as object
(
  vers_major    char(1),                              /* UDT major version # */
  vers_minor    char(1),                              /* UDT minor version # */
  user_num      number,
  grantee       varchar2(128),
  granted_group varchar2(128),/*consumer groups to which the user can switch */
  grant_option  number,                  /* mod(a.option$) =1 yes, others no */
                       /* whether the user can grant the privilege to others */
  defschclass   VARCHAR2(128)                               /* initial group */
)
not persistable
/

--
-------------------------------------------------------------------------------
--                      PASSWORD_HISTORY
-------------------------------------------------------------------------------
-- 
create or replace type ku$_psw_hist_item_t force as object
(
  user_id       number,                    /* pws history user object number */
  uname         varchar2(128),                                  /* user name */
  password      varchar2(4000),                                  /* password */
  password_date varchar2(19)                                   /* start date */
)
not persistable
/

create or replace type ku$_psw_hist_list_t force
as TABLE of (ku$_psw_hist_item_t)
not persistable
/

create or replace type ku$_psw_hist_t force as object
(
  vers_major    char(1),                             /* UDT major version # */
  vers_minor    char(1),                             /* UDT minor version # */
  user_id       number,
  name          varchar2(128),
  hist_list     ku$_psw_hist_list_t                     /* password history */
)
not persistable
/

--
-------------------------------------------------------------------------------
--                      PROC_SYSTEM_GRANT
-- (procedural system privilege grant)
-- corresponds to the grant_sysprivs_exp function of a package in exppkgobj$
-------------------------------------------------------------------------------
--
create or replace type ku$_objpkg_t force as object
(
  tag           varchar2(128),                             /* procedural tag */
  cmnt          varchar2(2000),                        /* procedural comment */
  package       varchar2(128),                    /* procedural package name */
  schema        varchar2(128)                              /* package schema */
)
not persistable
/

create or replace type ku$_objpkg_privs_t force as object
(
  vers_major    char(1),                              /* UDT major version # */
  vers_minor    char(1),                              /* UDT minor version # */
  tag           varchar2(128),                             /* procedural tag */
  cmnt          varchar2(2000),                        /* procedural comment */
  package       varchar2(128),                 /* procedural package objects */
  schema        varchar2(128),                             /* package schema */
  plsql         ku$_procobj_lines      /* PL/SQL code for proc sys privilege */
)
not persistable
/

--
-------------------------------------------------------------------------------
--                      PROCOBJ
-- (system/schema procedural objects) - corresponds to the create_exp function
-- of a package in exppkgobj$ where the class is 1 (system) or 2 (schema)
-------------------------------------------------------------------------------
--
create or replace type ku$_procobj_t force as object
(
  vers_major    char(1),                              /* UDT major version # */
  vers_minor    char(1),                              /* UDT minor version # */
  obj_num       number,                              /* schema object number */
  schema_obj    ku$_schemaobj_t,                            /* schema object */
  class         number,                         /* 1:sys,2:schema,3:instance */
  prepost       number,                         /* 0:preaction, 1:postaction */
  type_num      number,                                           /* type id */
  level_num     number,                                             /* level */
  tag           varchar2(128),                             /* procedural tag */
  cmnt          varchar2(2000),                        /* procedural comment */
  package       varchar2(128),                         /* procedural package */
  pkg_schema    varchar2(128),                             /* package schema */
  plsql         ku$_procobj_lines      /* PL/SQL code for procedural objects */
)
not persistable
/

--
-------------------------------------------------------------------------------
--                      PROCOBJ_GRANT
-- (grants on system/schema procedural objects) - corresponds to the
-- grant_exp function of a package in exppkgobj$ where the class is 1 (system)
-- or 2 (schema).
-------------------------------------------------------------------------------
--
create or replace type ku$_procobj_grant_t force as object
(
  vers_major    char(1),                              /* UDT major version # */
  vers_minor    char(1),                              /* UDT minor version # */
  obj_num       number,                              /* schema object number */
  base_obj      ku$_schemaobj_t,                            /* schema object */
  class         number,                         /* 1:sys,2:schema,3:instance */
  prepost       number,                         /* 0:preaction, 1:postaction */
  type_num      number,                                           /* type id */
  level_num     number,                                             /* level */
  tag           varchar2(128),                             /* procedural tag */
  cmnt          varchar2(2000),                        /* procedural comment */
  package       varchar2(128),                         /* procedural package */
  pkg_schema    varchar2(128),                             /* package schema */
  plsql         ku$_procobj_lines      /* PL/SQL code for procedural objects */
)
not persistable
/

--
-------------------------------------------------------------------------------
--                      PROCOBJ_AUDIT
-- (audits on system/schema procedural objects) - corresponds to the
-- audit_exp function of a package in exppkgobj$ where the class is 1 (system)
-- or 2 (schema).
-------------------------------------------------------------------------------
--
create or replace type ku$_procobj_audit_t force as object
(
  vers_major    char(1),                              /* UDT major version # */
  vers_minor    char(1),                              /* UDT minor version # */
  obj_num       number,                              /* schema object number */
  base_obj      ku$_schemaobj_t,                            /* schema object */
  class         number,                      /* 1: sys, 2:schema, 3:instance */
  prepost       number,                          /* 0:praction, 1:postaction */
  type_num      number,                                           /* type id */
  level_num     number,                                             /* level */
  tag           varchar2(128),                             /* procedural tag */
  cmnt          varchar2(2000),                        /* procedural comment */
  package       varchar2(128),                         /* procedural package */
  pkg_schema    varchar2(128),                             /* package schema */
  plsql         ku$_procobj_lines      /* PL/SQL code for procedural objects */
)
not persistable
/

--
-------------------------------------------------------------------------------
--                      PROCDEPOBJ
-- (instance procedural objects) - corresponds to the create_exp function
-- of a package in exppkgobj$ where the class is 3 (instance)
-- and where there is a corresponding row in expdepobj$.
-------------------------------------------------------------------------------
--
create or replace type ku$_procdepobj_t force as object
(
  vers_major    char(1),                              /* UDT major version # */
  vers_minor    char(1),                              /* UDT minor version # */
  obj_num       number,                                     /* object number */
  schema_obj    ku$_schemaobj_t,                            /* schema object */
  class         number,                                             /* class */
  prepost       number,                         /* 0:preaction, 1:postaction */
  type_num      number,                                              /* type */
  level_num     number,                                             /* level */
  tag           varchar2(128),                                        /* tag */
  cmnt          varchar2(2000),                                   /* comment */
  package       varchar2(128),                                    /* package */
  pkg_schema    varchar2(128),                             /* package schema */
  base_obj_num  number,                                /* base object number */
  base_obj      ku$_schemaobj_t,                          /* base schema obj */
  plsql         ku$_procobj_lines      /* PL/SQL code for procedural objects */
)
not persistable
/

--
-------------------------------------------------------------------------------
--                      PROCDEPOBJ_GRANT
-- (grants on instance procedural objects) - corresponds to the
-- grant_exp function of a package in exppkgobj$ where the class is 3 (instance)
-- and where there is a corresponding row in expdepobj$.
-------------------------------------------------------------------------------
--
create or replace type ku$_procdepobjg_t force as object
(
  vers_major    char(1),                              /* UDT major version # */
  vers_minor    char(1),                              /* UDT minor version # */
  obj_num       number,                                     /* object number */
  base_obj      ku$_schemaobj_t,                            /* base object */
  class         number,                                             /* class */
  prepost       number,                         /* 0:preaction, 1:postaction */
  type_num      number,                                              /* type */
  level_num     number,                                             /* level */
  tag           varchar2(128),                                        /* tag */
  cmnt          varchar2(2000),                                   /* comment */
  package       varchar2(128),                                    /* package */
  pkg_schema    varchar2(128),                             /* package schema */
  anc_obj       ku$_schemaobj_t,                      /* ancestor schema obj */
  plsql         ku$_procobj_lines      /* PL/SQL code for procedural objects */
)
not persistable
/

--
-------------------------------------------------------------------------------
--                      PROCDEPOBJ_AUDIT
-- (audits on instance procedural objects) - corresponds to the
-- audit_exp function of a package in exppkgobj$ where the class is 3 (instance)
-- and where there is a corresponding row in expdepobj$.
-------------------------------------------------------------------------------
--
create or replace type ku$_procdepobja_t force as object
(
  vers_major    char(1),                              /* UDT major version # */
  vers_minor    char(1),                              /* UDT minor version # */
  obj_num       number,                                     /* object number */
  base_obj      ku$_schemaobj_t,                            /* base object */
  class         number,                                             /* class */
  prepost       number,                         /* 0:preaction, 1:postaction */
  type_num      number,                                              /* type */
  level_num     number,                                             /* level */
  tag           varchar2(128),                                        /* tag */
  cmnt          varchar2(2000),                                   /* comment */
  package       varchar2(128),                                    /* package */
  pkg_schema    varchar2(128),                             /* package schema */
  anc_obj       ku$_schemaobj_t,                      /* ancestor schema obj */
  plsql         ku$_procobj_lines      /* PL/SQL code for procedural objects */
)
not persistable
/

--
-------------------------------------------------------------------------------
--                      PROCACT_SYSTEM
-- (system procedural actions) - corresponds to the system_info_exp function
-- of a package in exppkgact$ where the class is 1 (system).
------------------------------------------------------------------------------
--
create or replace type ku$_procobjact_t force as object
(
  package       varchar2(128),                    /* procedural package name */
  schema        varchar2(128)                              /* package schema */
)
not persistable
/

create or replace type ku$_procact_t force as object
(
  vers_major    char(1),                              /* UDT major version # */
  vers_minor    char(1),                              /* UDT minor version # */
  tag           varchar2(128),                             /* procedural tag */
  cmnt          varchar2(2000),                        /* procedural comment */
  package       varchar2(128),                         /* procedural package */
  schema        varchar2(128),                             /* package schema */
  level_num     number,                                             /* level */
  class         number,                                             /* class */
  prepost       number,                         /* 0:preaction, 1:postaction */
  plsql         ku$_procobj_lines      /* PL/SQL code for procedural objects */
)
not persistable
/

--
------------------------------------------------------------------------------
---                     PROCACT_SCHEMA
-- (schema procedural actions) - corresponds to the schema_info_exp function
-- of a package in exppkgact$ where the class is 2 (schema)
-------------------------------------------------------------------------------
--
create or replace type ku$_procact_schema_t force as object
(
  vers_major    char(1),                              /* UDT major version # */
  vers_minor    char(1),                              /* UDT minor version # */
  user_name     varchar2(128),                                  /* user name */
  tag           varchar2(128),                             /* procedural tag */
  cmnt          varchar2(2000),                        /* procedural comment */
  package       varchar2(128),                         /* procedural package */
  schema        varchar2(128),                           /* procedual schema */
  level_num     number,                                             /* level */
  class         number,                                             /* class */
  prepost       number,                         /* 0:preaction, 1:postaction */
  plsql         ku$_procobj_lines      /* PL/SQL code for procedural objects */
)
not persistable
/

--
-------------------------------------------------------------------------------
--                      PROCACT_INSTANCE
-- (instance procedural actions) - corresponds to the instance_info_exp function
-- of a package in exppkgact$ where the class is 3 (instance) and where there is
-- a corresponding row in expdepact$.  
-------------------------------------------------------------------------------
--
create or replace type ku$_procact_instance_t force as object
(
  vers_major    char(1),                              /* UDT major version # */
  vers_minor    char(1),                              /* UDT minor version # */
  obj_num       number,                                     /* object number */
  base_obj      ku$_schemaobj_t,                            /* schema object */
  schema_obj    ku$_schemaobj_t,                            /* schema object */
  level_num     number,                                             /* level */
  tag           varchar2(128),                             /* procedural tag */
  cmnt          varchar2(2000),                        /* procedural comment */
  package       varchar2(128),                         /* procedural package */
  pkg_schema    varchar2(128),                             /* package schema */
  class         number,                                             /* class */
  prepost       number,                        /* 0: preaction, 1:postaction */
  plsql         ku$_procobj_lines      /* PL/SQL code for procedural objects */
)
not persistable
/
create or replace type ku$_procact_instance_tbl_t force as
 table OF (sys.ku$_procact_instance_t)
not persistable
/

--
-------------------------------------------------------------------------------
--                      PRE_TABLE_ACTION
-------------------------------------------------------------------------------
--
create or replace type ku$_prepost_table_t force as object
(
  vers_major    char(1),                              /* UDT major version # */
  vers_minor    char(1),                              /* UDT minor version # */
  obj_num       number,
  base_obj      ku$_schemaobj_t,
  action_str    sys.ku$_taction_list_t
)
not persistable
/

-------------------------------------------------------------------------------
--                      (SYSTEM, SCHEMA, INSTANCE) CALLOUT
--                      TRANSPORTABLE CALLS TO DBMS_PLUGTS
------------------------------------------------------------------------------

-- views use a common UDT

create or replace type ku$_callout_t force as object
(
  vers_major    char(1),                              /* UDT major version # */
  vers_minor    char(1),                              /* UDT minor version # */
  user_name     varchar2(128),                                  /* user name */
  obj_num       number,                                     /* object number */
  base_obj      ku$_schemaobj_t,                            /* schema object */
  tag           varchar2(128),             /* used for extensibility tracing */
  package       varchar2(128),                         /* procedural package */
  pkg_schema    varchar2(128),                             /* package schema */
  level_num     number,                                             /* level */
  class         number,                                             /* class */
  prepost       number,                         /* 0:preaction, 1:postaction */
  -- for dbms_plugts
  ts_name       varchar2(128),                            /* tablespace name */
  ts_num        number,                                 /* tablespace number */
  incl_const    number,
  incl_trig     number,
  incl_grant    number,
  tts_full_chk  number,
  tts_closure_chk number,
  idx_prop      number               /* index properties - for plugts_tsname */
)
not persistable
/

-- PLUGTS_BLK

create or replace type ku$_plugts_blk_t force as object
(
  vers_major    char(1),                              /* UDT major version # */
  vers_minor    char(1),                              /* UDT minor version # */
  prepost       number,                        /* 0: preaction, 1:postaction */
  plsql         ku$_procobj_lines      /* PL/SQL code for procedural objects */
)
not persistable
/

-- View for fetching tablespace name and other characteristics
--  intended for selection by a set of tsnum's

create or replace type ku$_plugts_tablespace_t force as object
(
  vers_major    char(1),                              /* UDT major version # */
  vers_minor    char(1),                              /* UDT minor version # */
  ts_num        number,                                 /* tablespace number */
  bitmapped     number,      /* If not bitmapped, 0 else unit size in blocks */
  flags         number,                                     /* various flags */
                                     /* 0x01 = system managed allocation     */
                                     /* 0x02 = uniform allocation            */
                                /* if above 2 bits not set then user managed */
                                     /* 0x04 = migrated tablespace           */
                                     /* 0x08 = tablespace being migrated     */
                                     /* 0x10 = undo tablespace               */
                                     /* 0x20 = auto segment space management */
                       /* if above bit not set then freelist segment managed */
                                     /* 0x40 (64) = COMPRESS                 */
                                     /* 0x80 = ROW MOVEMENT                  */
                                     /* 0x100 = SFT                          */
                                     /* 0x200 = undo retention guarantee     */
                                    /* 0x400 = tablespace belongs to a group */
                                  /* 0x800 = this actually describes a group */
                                   /* 0x1000 = tablespace has MAXSIZE set */
                                   /* 0x2000 = enc property initialized */
                                   /* 0x4000 = encrypted tablespace */
            /* 0x8000 = has its own key and not using the default DB enc key */
                                  /* 0x10000 = OLTP Compression */
                                  /* 0x20000 (131072) = ARCH1_COMPRESSION */
                                  /* 0x40000 (262144) = ARCH2_COMPRESSION */
                                  /* 0x80000 (524288) = ARCH3_COMPRESSION */
  ts_name       varchar2(128)                             /* tablespace name */
)
not persistable
/


-------------------------------------------------------------------------------
--            HCS ATTRIBUTE DIMENSION / HIERARCHY / ANALYTIC VIEW 
-------------------------------------------------------------------------------

-- source for hier dim or analytic view
create or replace type ku$_hcs_src_t force as object
(
  hcs_obj#       number,            /* obj# of the hier dim or analytic view */
  src_id         number,    /* id of the source in hier dim or analytic view */
  owner          varchar2(128),      /* owner of the source (hcs_src$.owner) */
  owner_in_ddl   number(1),                      /* whether owner was in DDL */
  name           varchar2(128),        /* name of the source (hcs_src$.name) */
  alias          varchar2(128),      /* alias of the source (hcs_src$.alias) */
  order_num      number                        /* order number of the soruce */
)
not persistable
/ 

create or replace type ku$_hcs_src_list_t force as table of (ku$_hcs_src_t)
not persistable
/

-- source column for attribute dim or analytic view 
create or replace type ku$_hcs_src_col_t force as object
(
  obj#           number,          /* top lvl object id containing the srcCol */
  src_col#       number,                          /* id of the source column */
  obj_type       number,                /* object type containing the srcCol */
  table_alias    varchar2(128),/* owner of column (hcs_src_col$.table_alias) */
  src_col_name   varchar2(128) /* name of column (hcs_src_col$.src_col_name) */
)
not persistable
/

create or replace type ku$_hcs_src_col_list_t force
as table of (ku$_hcs_src_col_t)
not persistable
/

-- classification
create or replace type ku$_hcs_clsfctn_t force as object
(
  obj#            number, /* top lvl object id containing the classification */
  sub_obj#        number,    /*  sub object id containing the classification */
  obj_type        number,                                  /* type of object */
  clsfction_name  varchar2(128),  /* classification name (from hcs_clsfctn$) */
  clsfction_lang  varchar2(64),          /* optional classification language */
  clsfction_value clob,                              /* classification value */
  order_num       number                   /* order number of classification */
)
not persistable
/

create or replace type ku$_hcs_clsfctn_list_t force
as table of (ku$_hcs_clsfctn_t)
not persistable
/

-- hier dim join path
create or replace type ku$_attr_dim_join_path_t force as object
(
  dim_obj#       number,                             /* obj# of the hier dim */
  join_path_id   number,                     /* join path id in the hier dim */
  name           varchar2(128),  /* name (hcs_dim_join_path$.join_path_name) */
  on_condition   varchar2(4000),      /* condition of the hier dim join path */
  order_num      number                        /* order number of attributes */
)
not persistable
/

create or replace type ku$_attr_dim_join_path_list_t 
 force as table of (ku$_attr_dim_join_path_t)
not persistable
/

-- hier join path
create or replace type ku$_hier_join_path_t force as object
(
  hier_obj#      number,                                 /* obj# of the hier */
  name           varchar2(128), /* name (hcs_hier_join_path$.join_path_name) */
  order_num      number                        /* order number of attributes */
)
not persistable
/

create or replace type ku$_hier_join_path_list_t 
 force as table of (ku$_hier_join_path_t)
not persistable
/

-- attribute dimension attr
create or replace type ku$_attr_dim_attr_t force as object
(
  dim_obj#       number,                             /* obj# of the hier dim */
  attr_id        number,                          /* attr id in the hier dim */
  name           varchar2(128),       /* attr name (hcs_dim_attr$.attr_name) */
  table_alias    varchar2(128),/* owner of column (hcs_src_col$.table_alias) */
  src_col_name   varchar2(128),/* name of column (hcs_src_col$.src_col_name) */
  clsfctn_list   ku$_hcs_clsfctn_list_t,                  /* classifications */
  order_num      number                        /* order number of attributes */
)
not persistable
/

create or replace type ku$_attr_dim_attr_list_t 
 force as table of (ku$_attr_dim_attr_t)
not persistable
/

-- attribute dim level key
create or replace type ku$_attr_dim_lvl_key_t force as object
(
  dim_obj#       number,                             /* obj# of the hier dim */
  lvl_id         number,               /* level number within this dimension */
  key_id         number,                       /* lvl key id in the hier dim */
  attr_list      ku$_attr_dim_attr_list_t,                  /* list of attrs */
  order_num      number                       /* order number of the lvl key */
)
not persistable
/

create or replace type ku$_attr_dim_lvl_key_list_t 
 force as table of (ku$_attr_dim_lvl_key_t)
not persistable
/

-- attribute dim level order by
create or replace type ku$_attr_dim_lvl_ordby_t force as object
(
  dim_obj#       number,                             /* obj# of the attr dim */
  lvl_id         number,                         /* level id in the attr dim */
  agg_func       varchar2(3),             /* aggregation function MIN or MAX */
  attribute_name varchar2(128),                            /* attribute name */
  order_num      number,                                     /* order number */
  criteria       varchar2(4),                       /* criteria: ASC or DESC */
  nulls_position varchar2(5)                          /* NULLS FIRST or LAST */
)
not persistable
/  

create or replace type ku$_attr_dim_lvl_ordby_list_t 
 force as table of (ku$_attr_dim_lvl_ordby_t)
not persistable
/

-- attribute dim level
create or replace type ku$_attr_dim_lvl_t force as object
(
  dim_obj#       number,                             /* obj# of the attr dim */
  lvl_id         number,                         /* level id in the attr dim */
  name           varchar2(128),        /* level name (hcs_dim_lvl$.lvl_name) */
  member_name    clob,              /* member name (hcs_dim_lvl$.member_name */
  member_caption clob,        /* member caption (hcs_dim_lvl$.member_caption */
  member_desc    clob,/* member description (hcs_dim_lvl$.member_description */
  skip_when_null varchar2(1),                              /* skip when null */
  level_type     varchar2(16),                                 /* level type */
  clsfctn_list   ku$_hcs_clsfctn_list_t,                  /* classifications */
  key_list       ku$_attr_dim_lvl_key_list_t,          /* list of level keys */
  ordby_list     ku$_attr_dim_lvl_ordby_list_t,                 /* order bys */
  dtm_attr_list  ku$_attr_dim_attr_list_t,       /* list of determined attrs */
  order_num      number                         /* order number of the level */
)
not persistable
/  

create or replace type ku$_attr_dim_lvl_list_t 
 force as table of (ku$_attr_dim_lvl_t)
not persistable
/

-- hier level
create or replace type ku$_hier_lvl_t force as object
(
  hier_obj#      number,                                 /* obj# of the hier */
  name           varchar2(128),         /* level name (hcs_hr_lvl$.lvl_name) */
  order_num      number                         /* order number of the level */
)
not persistable
/

create or replace type ku$_hier_lvl_list_t 
 force as table of (ku$_hier_lvl_t)
not persistable
/

-- hier attr
create or replace type ku$_hier_hier_attr_t force as object
(
  hier_obj#      number,                                 /* obj# of the hier */
  name           varchar2(128), /* attr name (hcs_hier_attr$.hier_attr_name) */
  expr           clob,             /* expression (NULL for system-generated) */
  clsfctn_list   ku$_hcs_clsfctn_list_t,                  /* classifications */
  order_num      number                          /* order number of the attr */
)
not persistable
/

create or replace type ku$_hier_hier_attr_list_t 
 force as table of (ku$_hier_hier_attr_t)
not persistable
/

-- analytic view keys
create or replace type ku$_analytic_view_keys_t force as object
(
  av_obj#         number,                       /* obj# of the analytic view */
  dim_obj#        number,                            /* obj# of the hier dim */
  key_col_name    varchar2(128),/* key column name(hcs_src_col$.src_col_name)*/
  ref_attr_name   varchar2(128),/* ref attr name (hcs_av_key$.ref_attr_name) */
  order_num       number                   /* order number of the key column */
)
not persistable
/

create or replace type ku$_analytic_view_keys_list_t 
 force as table of (ku$_analytic_view_keys_t)
not persistable
/

-- analytic view hiers
create or replace type ku$_analytic_view_hiers_t force as object
(
  av_obj#         number,                       /* obj# of the analytic view */
  dim_obj#        number,                            /* obj# of the hier dim */
  hier_owner      varchar2(128),     /* hier owner (hcs_av_hier$.hier_owner) */
  owner_in_ddl    number(1),                     /* whether owner was in DDL */
  hier_name       varchar2(128),       /* hier name (hcs_av_hier$.hier_name) */
  hier_alias      varchar2(128),    /* hier alias  (hcs_av_hier$.hier_alias) */
  is_default      varchar2(1),                                 /* is default */
  order_num       number                         /* order number of the hier */
)
not persistable
/

create or replace type ku$_analytic_view_hiers_list_t 
 force as table of (ku$_analytic_view_hiers_t)
not persistable
/

-- analytic view dim
create or replace type ku$_analytic_view_dim_t force as object
(
  av_obj#         number,                       /* obj# of the analytic view */
  dim_obj#        number,                            /* obj# of the hier dim */
  dim_owner       varchar2(128),         /* dim owner (hcs_av_dim$.dim_owner */
  owner_in_ddl    number(1),                     /* whether owner was in DDL */
  name            varchar2(128),          /* dim name (hcs_av_dim$.dim_name) */
  dim_alias       varchar2(128),            /* alias name (hcs_av_dim$.alias */
  ref_distinct    number(1),                      /* is references distinct? */
  key_list        ku$_analytic_view_keys_list_t,       /* analytic view keys */
  hier_list       ku$_analytic_view_hiers_list_t,                   /* hiers */
  clsfctn_list    ku$_hcs_clsfctn_list_t,                 /* classifications */
  order_num       number                          /* order number of the dim */
)
not persistable
/  

create or replace type ku$_analytic_view_dim_list_t 
 force as table of (ku$_analytic_view_dim_t)
not persistable
/

-- analytic view measures
create or replace type ku$_analytic_view_meas_t force as object
(
  av_obj#         number,                       /* obj# of the analytic view */
  meas_id         number,                               /* id of the measure */
  meas_type       number,                                    /* base or calc */
  name            varchar2(128),    /* measure name (hcs_av_meas$.meas_name) */
  src_col_name    varchar2(128),  /* column name (hcs_src_col$.src_col_name) */
  expr            clob,                     /* calculated measure expression */
  aggr            varchar2(128),        /* aggr_function (hcs_av_meas$.aggr) */
  clsfctn_list    ku$_hcs_clsfctn_list_t,                 /* classifications */
  order_num       number                      /* order number of the measure */
)
not persistable
/  

create or replace type ku$_analytic_view_meas_list_t 
 force as table of (ku$_analytic_view_meas_t)
not persistable
/

-- analytic view cache

-- measures in measure lists
create or replace type ku$_hcs_av_cache_meas_t force as object
(
  av_obj#         number,                       /* obj# of the analytic view */
  measlst#        number,                                   /* id of measlst */
  meas_name       varchar2(128),                      /* name of the measure */
  order_num       number                      /* order number of the measure */
)
not persistable
/

create or replace type ku$_hcs_av_cache_meas_list_t 
 force as table of (ku$_hcs_av_cache_meas_t)
not persistable
/

-- levels in level groups
create or replace type ku$_hcs_av_cache_lvl_t force as object
(
  av_obj#         number,                       /* obj# of the analytic view */
  lvlgrp#         number,                                    /* id of lvlgrp */
  dim_alias       varchar2(128),                    /* name of the dim alias */
  hier_alias      varchar2(128),                   /* name of the hier alias */
  level_name      varchar2(128),                        /* name of the level */
  order_num       number                        /* order number of the level */
)
not persistable
/

create or replace type ku$_hcs_av_cache_lvl_list_t 
 force as table of (ku$_hcs_av_cache_lvl_t)
not persistable
/

-- level groups
create or replace type ku$_hcs_av_cache_lvgp_t force as object
(
  av_obj#         number,                       /* obj# of the analytic view */
  measlst#        number,                                   /* id of measlst */
  lvlgrp#         number,                                /* id of the lvlgrp */
  cache_type      varchar2(128),                               /* cache type */
  lvl_list        ku$_hcs_av_cache_lvl_list_t,                     /* levels */
  order_num       number                              /* order of the lvlgrp */
)
not persistable
/

create or replace type ku$_hcs_av_cache_lvgp_list_t 
 force as table of (ku$_hcs_av_cache_lvgp_t)
not persistable
/

-- measure lists
create or replace type ku$_hcs_av_cache_mlst_t force as object
(
  av_obj#         number,                       /* obj# of the analytic view */
  measlst#        number,                                   /* id of measlst */
  meas_list       ku$_hcs_av_cache_meas_list_t,                  /* measures */
  lvlgrp_list     ku$_hcs_av_cache_lvgp_list_t               /* level groups */
)
not persistable
/

create or replace type ku$_hcs_av_cache_mlst_list_t 
 force as table of (ku$_hcs_av_cache_mlst_t)
not persistable
/

-- end analytic view cache

-- hier dim
create or replace type ku$_attribute_dimension_t force as object
(
  obj_num            number,           /* object number of the attribute dim */
  schema_obj         ku$_schemaobj_t,                       /* schema object */
  dimension_type     varchar2(8),                          /* dimension type */
  all_member_name    clob,                                /* all member name */
  all_member_caption clob,                             /* all member caption */
  all_member_desc    clob,                         /* all member description */
  src_list           ku$_hcs_src_list_t,                  /* list of sources */
  attr_list          ku$_attr_dim_attr_list_t,        /* dimension attr list */
  lvl_list           ku$_attr_dim_lvl_list_t,        /* dimension level list */
  clsfctn_list       ku$_hcs_clsfctn_list_t,              /* classifications */
  join_path_list     ku$_attr_dim_join_path_list_t             /* join paths */
)
not persistable
/

-- hierarchy
create or replace type ku$_hierarchy_t force as object
(
  obj_num         number,                       /* object number of the hier */
  schema_obj      ku$_schemaobj_t,                          /* schema object */
  dim_owner       varchar2(128),                          /* dimension owner */
  owner_in_ddl    number(1),                     /* whether owner was in DDL */
  dim_name        varchar2(128),                           /* dimension name */
  lvl_list        ku$_hier_lvl_list_t,           /* list of hierarchy levels */
  clsfctn_list    ku$_hcs_clsfctn_list_t,                 /* classifications */
  join_path_list  ku$_hier_join_path_list_t,                   /* join paths */
  hr_attr_list    ku$_hier_hier_attr_list_t   /* hier attr w/classifications */
)
not persistable
/

-- analytic view
create or replace type ku$_analytic_view_t force as object
(
  obj_num         number,              /* object number of the analytic view */
  schema_obj      ku$_schemaobj_t,                          /* schema object */
  def_meas        varchar2(128),                          /* default measure */
  def_aggr        varchar2(128),                      /* default aggregation */
  src_list        ku$_hcs_src_list_t,                     /* list of sources */
  dim_list        ku$_analytic_view_dim_list_t,                /* dimensions */
  meas_list       ku$_analytic_view_meas_list_t,                 /* measures */
  clsfctn_list    ku$_hcs_clsfctn_list_t,                 /* classifications */
  cache_meas_list ku$_hcs_av_cache_mlst_list_t,           /* cache meas list */
  dyn_all_cache   number(1)                     /* dynamic all cache enabled */
)
not persistable
/

@?/rdbms/admin/sqlsessend.sql
