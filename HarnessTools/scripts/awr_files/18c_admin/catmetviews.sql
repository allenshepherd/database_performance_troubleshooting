Rem Copyright (c) 1987, 2018, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem NAME
Rem    CATMETVIEWS.SQL - Views of the Oracle dictionary for
Rem                      Metadata API.
Rem  FUNCTION
Rem     Create views of the Oracle dictionary for 
Rem     use by the DataPump Metadata API.
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
Rem SQL_SOURCE_FILE: rdbms/admin/catmetviews.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catmetviews.sql
Rem SQL_PHASE: CATMETVIEWS
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catpdeps.sql
Rem END SQL_FILE_METADATA
Rem
Rem  MODIFIED      MM/DD/YY
Rem     sdavidso   10/17/17 - lrg-20624856 - domain index on varray store as
Rem                           table
Rem     jstenois   09/30/17 - add DATAPUMP_CLOUD_EXP, DATAPUMP_CLOUD_IMP role
Rem     jjanosik   09/14/17 - Bug 26721864: Get memoptimize info into
Rem                           constraint
Rem     sdavidso   08/29/17 - bug25453685 move chunk - domain index
Rem     jjanosik   07/24/17 - Bug 26303869: add info to nested tables
Rem     tbhukya    07/17/17 - Bug 22104291: Fetch external partition attributes
Rem     jjanosik   06/22/17 - Bug 24719359: Add support for RADM Policy
Rem                           Expressions
Rem     tbhukya    04/21/17 - Bug 25436814: Support staging log for MVL
Rem     jjanosik   04/19/17 - Bug 25364071: get encalg and intalg for nested
Rem                           tables
Rem     tbhukya    04/10/17 - Bug 25556006: Partitioned Databound
Rem                           Collation support
Rem     jstenois   03/30/17 - 25410933: pass current user to PARSE functions
Rem     mjangir    03/27/17 - Bug 23181020: handle multi olap policy to
Rem                         -  avoid ORA-1427
Rem     tbhukya    03/24/17 - Bug 25715449: Fetch READ ONLY constraint in view
Rem     tbhukya    03/15/17 - Bug 25717130: Move ku$_viewprop_view to 
Rem                           catmetviews_mig
Rem     qinwu      02/22/17 - proj 70151: support db capture and replay auth
Rem     jjanosik   01/24/17 - Bug 25437491: fix DATAPUMP_PATHS_VERSION and
Rem                           *_EXPORT_PATHS to allow schema, table and
Rem                           transportable mode extensibiliy tag inclusion
Rem                           and exclusion
Rem     sdavidso   01/12/17 - bug25225293 make procact_instance work with CBO
Rem     bwright    01/11/17 - Bug 25336140: Don't (un)load partitions of exttbls
Rem     sfeinste   01/05/17 - Proj 70791: add dyn_all_cache to
Rem                           ku$_analytic_view
Rem     mjangir    12/22/16 - bug 25297023: add unique id for ku$ views
Rem     joalvizo   11/16/16 - Clear opq.flags when KKDOOPQF_BIN_DOM_IDX is set.
Rem     jjanosik   11/03/16 - Bug 24661809: translate extensibility callout
Rem                           packages to tags
Rem     rapayne    10/20/16 - bug 24926031: fix nls_sort ci problem
Rem     bwright    10/06/16 - Bug 24817502: Allow PDML for export of inner 
Rem                           nested table
Rem     sdavidso   09/29/16 - bug24744228 fix custom filter for sequence
Rem     rapayne    08/09/16 - bug 24435630: Fetch IM clause for ILM policies.
Rem                           note: this is a fwd merge from 12.2.0.1
Rem     almurphy   09/13/16 - add REFERENCES DISTINCT to ANALYTIC VIEW
Rem     bwright    09/08/16 - Bug 24513141: Remove project 30935 implementation
Rem     sdavidso   08/30/16 - bug-24386897 list partition limit fo 4000 chars
Rem     jjanosik   08/18/16 - bug 23625494 - split flags in ku$_tab_tsubpart_t
Rem     jjanosik   07/22/16 - bug 18083463 - use new metaaudit$ table for
Rem                           ku$_audit_view
Rem     mjangir    06/28/16 - bug 19450444: support regexp data redaction 
Rem     rapayne    06/14/16 - bug23699295: fix UID references in switch_compile
Rem                           view.
Rem     sdavidso   06/13/16 - bug23341988 - P2T import of disabled index
Rem     aumishra   05/12/16 - Bug 23185527: Modify ku$_im_colsel_view
Rem     sdavidso   05/01/16 - bug23179975 app table data exported twice.
Rem     rapayne    04/15/16 - bug 23087269: change session_user to current_user
Rem     rapayne    04/15/16 - lrg 19308563: prevent duplicate resource_plans
Rem     mjangir    04/04/16 - bug 22763372: resolve ORA-01427
Rem     sdavidso   04/04/16 - Bug22685703 flow control for procact_schema
Rem     sdavidso   03/11/16 - bug22535196 share=extended data
Rem     mjangir    03/05/16 - bug 22737974: use get_fullattrname from lob
Rem                           attributes
Rem     sogugupt   02/26/16 - Bug21944278 use condtional exp in comapre_edition
Rem     rapayne    02/22/16 - bug 22778159 - moved is_active_registration from
Rem                           prvtmetu to prvtmeta.
Rem     sdavidso   02/20/16 - bug22151959 fix xlm schema-element name
Rem     sdavidso   02/17/16 - bug22577904 shard P2T - missing constraint
Rem     youyang    02/16/16 - bug 22672722:add index functions for DV
Rem     mstasiew   02/04/16 - Bug 22658620: hcs partitioned/missing tables
Rem     jjanosik   02/02/16 - bug 20317926 - get rid of IS_SCHEMANAME_EXISTS
Rem     beiyu      01/19/16 - Bug 21365797: add owner_in_ddl col to HCS views
Rem     beiyu      01/06/16 - Bug 20619944: add level_type column
Rem     jjanosik   12/16/15 - bug 21844837 - use get_fullattrname() for nested
Rem                           tables as well as varrays
Rem     sogugupt   11/26/15 - Bug 22229581: Add segcol# for
Rem                           ku$_find_hidden_cons_view
Rem     sdavidso   11/24/15 - bug22264616 more move chunk subpart
Rem     sfeinste   11/19/15 - Bug 21465419: in_minimal = 1 predicate
Rem     rapayne    11/16/15 - bug 22165030: imc distribute for subpartition
Rem                           templates.
Rem     smesropi   11/13/15 - Bug 21171628: Rename HCS views
Rem     tbhukya    11/10/15 - Bug 21747321: Get offline tempfile size and status
Rem     jibyun     11/01/15 - support DIAGNOSTIC auth for Database Vault
Rem     sdavidso   10/30/15 - bug21869037 chunk move w/subpartitions
Rem     sdavidso   10/26/15 - bug19386381 find ts# for domain index
Rem     bwright    10/14/15 - Bug 19977893: Allow parallel unload w/ lobs
Rem     rapayne    10/12/15 - Bug 21853412: explicitly exclude table_data
Rem                           processing for CUBE ORGANIZATION tables. Data for
Rem                           these tables is move by dbms_aw procacts.
Rem     jjanosik   10/09/15 - bug 21798129: move ku$_user_base_view and 
Rem                           ku$_user_view to catmetviews_mig
Rem     mstasiew   10/08/15 - Bug 21867527: hier cube measure cache
Rem     tbhukya    09/29/15 - Bug 21880241: select higher, lower property 
Rem                           from ku$_deptable_objnum_view
Rem     sudurai    09/23/15 - Bug 21805805: Encrypt NUMBER data type in
Rem                           statistics tables
Rem     sdavidso   09/18/15 - bug20127810 plsql_optimize_level for older
Rem                           versions
Rem     mstasiew   08/27/15 - Bug 21384694: hier hier attr classifications
Rem     tbhukya    08/17/15 - Bug 21555645: Partitioned mapping io table
Rem     bwright    08/13/15 - Bug 20756134: STORE IN autolist part. table
Rem     mwjohnso   08/12/15 - Bug 21522663: unload method exttab
Rem                           required for partitioned clustered table
Rem     sogugupt   08/06/15 - Bug 18619083: Exclude 'invalid' tablespaces
Rem                           from tablespace export. 
Rem     rapayne    08/01/15 - Bug 21147617: expand IM related queries to include
Rem                           new FOR SERVICE syntax for DISTRIBUTE clause.
Rem     sdavidso   08/01/15 - bug21539111: include check constraint for P2T exp
Rem     tbhukya    07/27/15 - Bug 21249249: Get dependent table property
Rem     yanchuan   07/27/15 - Bug 21299533: support for Database Vault
Rem                           Authorization
Rem     sdavidso   07/21/15 - bug-20756759: lobs, indexes, droppped tables
Rem     sogugupt   07/17/15 - Bug 21312469: Add missing columns in 
Rem                           ku$_ilm_policy_view
Rem     sdavidso   07/01/15 - bug20864693: read only partition support
Rem     tbhukya    06/24/15 - Bug 21276592: Partitioned cluster
Rem     rapayne    06/24/15 - Bug 21290101: Fix type_name decode.
Rem                           Move ku$_edition_schemaobj_view to 
Rem                           catmetviews_mig.sql
Rem     mjangir    06/19/15 - bug 18506065: Exclude guard column in
Rem                           ku$_10_2_strmtable_view
Rem     tbhukya    06/08/15 - Bug 21117759: Move ku$_index_col_view 
Rem                           to catmetviews_mig.sql file.
Rem     sanbhara   06/01/15 - Bug 21158282 - adding ku$_dummy_comm_rule_alts_v.
Rem     mstasiew   05/22/15 - Bug 20845805: hierarchy cube improvements
Rem     rapayne    05/20/15 - external table enhancements for partitions.
Rem     mstasiew   05/16/15 - Bug 20845789 hierarchy dimension get_ddl fixes
Rem     tbhukya    05/06/15 - Bug 21038781: DBC support for MV
Rem     bwright    03/24/15 - Bug 20771546: Support for scalable sequence
Rem     dvekaria   03/20/15 - Bug 9570949: Replace chr(0) characters in job
Rem                           intervals.
Rem     tbhukya    03/19/15 - Bug 20722522: Donot select duplicate entries of 
Rem                           d_obj# from expdepobj$ for procedural calls and 
Rem                           donot export token tables.
Rem     sogugupt   03/07/15 - Bug:17871192 Invisible column support
Rem     sudurai    02/27/15 - proj 49581 - optimizer stats encryption
Rem     sdavidso   03/06/14 - Parallel metadata export
Rem     tbhukya    02/25/15 - Proj 47173: Data bound collation
Rem     mjangir    02/17/15 - bug 20476776: edition support for super types
Rem     bwright    02/11/15 - Proj 49143: Add auto-list (sub)partitioning and
Rem                           range interval subpartitioning w/ transition
Rem     sdavidso   02/08/15 - proj 56220-2 - partition transportable
Rem     rapayne    02/01/15 - proj 47411: local temporary tablespaces.
Rem     sdavidso   03/06/14 - Parallel metadata export
Rem     beiyu      01/09/15 - Proj 47091: add views for new HCS objects
Rem     sogugupt   12/23/14 - Bug 17535230: impdp fails with ora-6502 / lpx-217
Rem     rapayne    10/20/14 - bug 20164836: support for RAS schema level priv
Rem                           grants.
Rem     skayoor    11/30/14 - Proj 58196: Change Select priv to Read Priv
Rem     bwright    11/24/14 - Bug 20044870: Singleton select of
Rem                           ku$_simple_type_view
Rem     kaizhuan   11/11/14 - Project 46812: support for Database Vault policy
Rem     bwright    11/05/14 - Support 'audit policy by granted roles'
Rem     pknaggs    10/28/14 - Project 46864: multiple policy expressions (RADM)
Rem     dvekaria   10/23/14 - Bug 12920516 : Get schema of logged in user for
Rem                           Queue Tables.
Rem     tbhukya    08/26/14 - Bug 19688579: Move table views to catmetviews_mig
Rem                           .sql file
Rem     tbhukya    09/09/14 - Lrg 13217417 : Remove KU$_12_1_INDEX_VIEW
Rem     tbhukya    08/27/14 - Bug 18117024: Select AQ table storage clauses
Rem                           from ku$_qtab_storage_view.
Rem     gclaborn   08/18/14 - 30395: move plsql src as tables
Rem     jibyun     08/06/14 - Project 46812: support for Database Vault policy
Rem     rapayne    06/18/14 - proj 46816: support for new sysrac priv.
Rem     sdavidso   05/23/14 - backport bug18760457 from MAIN
Rem     sdavidso   05/15/14 - bug18760457: missing SUBPARTITION BY clause
Rem     apfwkr     05/05/14 - Backport lbarton_bug-18374198 from main
Rem     lbarton    04/30/14 - bug 18449519: multiple valid time periods
Rem     apfwkr     03/18/14 - Backport mjangir_bug-18271304 from main
Rem     lbarton    04/01/14 - bug 18374198: default on null
Rem     rphillip   03/19/14 - Bug 16236466 Allow network import of longs
Rem     mjangir    03/07/14 - Bug 18271304:look only local object
Rem     surman     12/29/13 - 13922626: Update SQL metadata
Rem     sdavidso   11/25/13 - bug14821907: find tablespaces: table transportable
Rem     bwright    12/23/13 - Bug 17952171: Fix type versioning source lines
Rem     dvekaria   12/20/13 - Bug17494709: Add encryptionalg to
Rem                           ku$_tablespace_view
Rem     mjangir    12/19/13 - bug 17500493: AQ storage_clause with lob column
Rem     tbhukya    12/11/13 - Bug 17803321: Donot export unique index from 12.2
Rem                           and later versions if it is created by constraint.
Rem     rapayne    11/24/13 - Bug 15916457: add objgrant_t to ku$_pfhtable_t
Rem     lbarton    11/06/13 - bug 17654567: row archival
Rem     lbarton    10/02/13 - Project 48787: views to document mdapi transforms
Rem     sdavidso   11/03/13 - bug17718297 - IMC selective column
Rem     mjangir    11/06/13 - bug 17654622: edition support for obj grants
Rem     bwright    10/18/13 - Bug 17627666: Add COL_SORTKEY for consistent
Rem                           column ordering with stream and exttbl metadata
Rem     dvekaria   09/30/13 - Bug 15922287: Use ku$_edition_schemaobj_view in
Rem                           ku$_coltype_view to fix ORA-1427 multiple rows.
Rem     sdavidso   09/23/13 - proj-47829 don`t export READ priv to pre 12.1.0.2
Rem     rapayne    09/22/13 - Bug 17321518: RAS policy support.
Rem     minx       09/18/13 - Bug 17478619: Add data realm description 
Rem     sdavidso   09/06/13 - bug 17379684: export objects invalid w/ editions
Rem     bwright    08/14/13 - Bug 17312600: Remove hard tabs from DP src code
Rem     dvekaria   08/09/13 - Bug 16918087: Remove duplicates from
Rem                           ku$_2ndtab_info_view.
Rem     lbarton    08/06/13 - bug 17250598: fix ku$_clst_zonemap_view
Rem     tbhukya    07/31/13 - Bug 16306688 : Include partitions as well 
Rem                           in ku$_tts_tabsubpartview
Rem     gclaborn   07/31/13 - 17247965: Add version support for import callouts
Rem     pradeshm   07/03/13 - Proj#46908: new columns in RAS principal table
Rem     talliu     06/28/13 - Add CDB view for DBA view
Rem     lbarton    06/27/13 - bug 16800820: valid-time temporal
Rem     mjangir    06/19/13 - handle NULL flags in ku$_sequence_view
Rem     lbarton    04/24/13 - bug 16716831: functional index expression as
Rem                           varchar or clob
Rem     rapayne    04/15/13 - bug 16310682: reduce memory for procact_schema
Rem     sdavidso   04/06/13 - proj42352: DP In-memory columnar
Rem     lbarton    04/04/13 - bug 11769638: property in exttab_t
Rem     bwright    03/21/13 - Bug 14762810: Use latest obj#s of types in type
Rem                           dependency
Rem     bwright    03/08/13 - Bug14075699: Add PROPERTY2 to STRMTABLE_T
Rem     lbarton    02/21/13 - bug 13386193: null byte in column default
Rem     dgagne     01/30/13 - fix bug for authpwdx
Rem     makataok   01/29/13 - bug 14490576: add a cond to ku$_comment_view
Rem     sdavidso   12/24/12 - XbranchMerge sdavidso_bug14490576-2 from
Rem                           st_rdbms_12.1.0.1
Rem     sdavidso   12/14/12 - bug14490576: 2ndary tables for
Rem                           full/transportable
Rem     lbarton    12/13/12 - bug 14239108: fix NAMED in _EXPORT_OBJECTS views
Rem     rapayne    11/06/12 - bug 15832675: create 11_2_view_view to exclude
Rem                           views with bequeath current_user.
Rem     dvekaria   10/29/12 - Bug 12851246: Retrieve only INITIAL_GROUP.
Rem     dgagne     10/18/12 - Bug #12866600: fix db link
Rem     lbarton    10/11/12 - bug 14358248: non-privileged parallel export of
Rem                           views-as-tables fails
Rem     rapayne    10/03/12 - lrg 7256879: modify Triton views to use new
Rem                           Oracle Supplied bit.
Rem     bwright    10/03/12 - Bug 14679947: Add import TYPE retry w/o evolution
Rem     lbarton    10/02/12 - bug 10350062: ILM compression and storage tiering
Rem     traney     09/26/12 - move unusable from index to column
Rem     rapayne    09/12/12 - bug 13899189: do not fetch tables with virtual
Rem                           columns when version < 11g.
Rem     traney     08/02/12 - 14407652: support editions enhancements
Rem     mjangir    08/23/12 - bug 14465787: edition support for comment 
Rem     sdavidso   08/13/12 - bug 12977174 - allow option tags for
Rem                           include/exclude
Rem     rapayne    08/10/12 - lrg 7071802: new mviews to support secondary
Rem                           materialized views.
Rem     lbarton    07/25/12 - bug 13454387: long varchar
Rem     bwright    07/16/12 - Bug 14331214: Include type even after dependency
Rem                           on it is dropped
Rem     ssonawan   07/12/12 - bug 13843068: add ku$_11_2_psw_hist_view
Rem     rapayne    04/04/12 - lrg 6886730: guard/nullable column support.
Rem     mjangir    06/20/12 - bug 14215851: fix ORA-01422
Rem     nijacob    06/19/12 - Lrg#6950246, 6950260
Rem     sdavidso   06/18/12 - more work on MDAPI performance for partitioned
Rem                           objects
Rem     lbarton    05/29/12 - bug 14054759: exclude indexes with stale entries
Rem                           and tables with online moved partitions
Rem     dgagne     05/24/12 - add oracle supplied view
Rem     rapayne    04/28/12 - proj 39632: support for create library extensions
Rem     dgagne     04/25/12 - use base table name for tab stats on iot mapping
Rem                           tables and index lobs.
Rem     mjangir    04/20/12 - bug 13898265: replace v$ view with table in 
Rem                           ku$_sublobfragindex_view, ku$_sublobfrag_view
Rem     amelidis   04/18/12 - 13914808: add push_pred to ku$_ind_subpart_view
Rem     traney     03/29/12 - bug 13715632: add agent to library$
Rem     surman     03/27/12 - 13615447: Add SQL patching tags
Rem     mjangir    03/26/12 - bug 13844935: performance issue with
Rem                           ku$_ind_subpart_view
Rem     sdavidso   03/23/12 - bug-13844935: use function for part# frag#
Rem     gclaborn   03/20/12 - Do not flag binary XMLtype cols as
Rem                           schema-dependent
Rem     snadhika   03/12/12 - Bug 13240543, Session privilege check
Rem     lbarton    02/14/12 - project 37414: ILM support
Rem     taahmed    02/07/12 - remove defacl from xs$seccls
Rem     rapayne    01/30/12 - bug 13646476: add policy_schema to xsolap_policy_view
Rem     mjangir    01/30/12 - bug 13573203: call get_index_intcol only for
Rem                         - functional index   
Rem     lbarton    01/26/12 - gravipat_bug-12667763: view property2
Rem     mjangir    01/23/12 - bug 11822439:  Wrong ddl of tablespace 
Rem     sdavidso   01/19/12 - bug 13568859: exclude Oracle objects from export
Rem     ssonawan   01/13/12 - bug 13582041: Remove handler from aud_policy$
Rem     jibyun     01/09/12 - Bug 9524209: Add SYS_OP_DV_CHECK to sensitive
Rem                           columns for Database Vault protection
Rem     sdavidso   12/22/11 - bug 11840083: reduce memory for procact_system
Rem     dgagne     12/21/11 - bug 12805876: hookup new ku_10_2_user_view for
Rem                           pre-12 USER_T queries.
Rem     spsundar   01/13/11 - Bug 13516582 : select index partition parameters
Rem                           based on flags value
Rem     rapayne    11/20/11 - Project 36780: Invisible column support. Add
Rem                           property2 to simple_col_view definition.
Rem     lbarton    10/27/11 - 36954_dpump_tabcluster_zonemap
Rem     spsundar   01/13/11 - Bug 13516582 : select index partition parameters
Rem                           based on flags value
Rem     sdavidso   11/03/11 - lrg 6000876: no export 12.1 privs to pre-12
Rem     sdavidso   10/11/11 - add audit policy objects
Rem     lbarton    10/13/11 - bug 13092452: hygiene
Rem     ebatbout   11/23/11 - Proj. 36950: Code based roles
Rem     rapayne    10/24/11 - minor changes to XS objects types to support 
Rem                           modify/remap.
Rem     ebatbout   10/15/11 - Proj. 36951: Add On_User_Grant support
Rem     ebatbout   10/14/11 - 12781157: Unpacked Opaque type support (Anydata)
Rem     sdavidso   09/28/11 - update ku\$_edition_obj_view for 12cr1
Rem     hxzhang    09/28/11 - make the view creation local
Rem     dgagne     09/20/11 - add v12 views for stats
Rem     lbarton    09/16/11 - project 32935: row level locking
Rem     rapayne    08/01/11 - Project 36780: Identity Column support.
Rem     jerrede    09/07/11 - Created for Parallel Upgrade Project #23496
Rem

@@?/rdbms/admin/sqlsessstart.sql

-- views dependent on bootstrap table columns
@@catmetviews_mig.sql
-------------------------------------------------------------------------------
--                              SCHEMA OBJECTS
-------------------------------------------------------------------------------

--ku$_schemaobj_view, ku$_edition_schemaobj_view, and ku$_edition_obj_view 
--moved to catmetviews_mig.sql

-- view for schema objects, filtered by object numbers
create or replace force view ku$_schemaobjnum_view of ku$_schemaobj_t
  with object identifier(obj_num) as
  select *
  from ku$_schemaobj_view ku$
  where ku$.obj_num in (select * from table(dbms_metadata.fetch_objnums));

-------------------------------------------------------------------------------
--                              STORAGE
-------------------------------------------------------------------------------

-- view for storage ADT
create or replace force view ku$_storage_view of ku$_storage_t
  with object identifier (file_num, block_num, ts_num) as
  select s.file#, s.block#, s.type#, s.ts#,
         dbms_metadata.in_tsnum(1,s.ts#),
         s.blocks, s.extents,
         s.iniexts, s.minexts, s.maxexts, s.extsize, s.extpct,
         s.user#,
-- SecureFiles use groups and lists for storing other information related
-- to RETENTION.  When we have a SecureFile column, the groups and
-- lists parameters need to be passed back as is.  However, if we
-- are attempting to import into a 10g compatible or earlier RDBMS via
-- DBLinks, then we need to interpret 0 as 1 for SecureFile because
-- the SecureFile will be created as a BasicFile, and in this case, the
-- groups and lists setting needs to be consistent with the BasicFile
-- behavior.  dbms_metadata.get_version tells us what version the
-- client in the DBLink is using as its compatible setting.
-- We can tell that the LOB segment is a SecureFile segment by looking
-- at seg$.spare1 bit 0x200000 (2097152 in decimal).
         case when dbms_metadata.get_version >= '11.00.00.00.00' then
                decode(bitand(s.spare1, 2097152), 2097152, s.lists,
                       (decode(s.lists, 0, 1, s.lists)))
              else
                decode(s.lists, 0, 1, s.lists)
         end,
         case when dbms_metadata.get_version >= '11.00.00.00.00' then
                decode(bitand(s.spare1, 2097152), 2097152, s.groups,
                       (decode(s.groups, 0, 1, s.groups)))
              else
                decode(s.groups, 0, 1, s.groups)
         end,
         decode(bitand(s.spare1, 4194304), 4194304, s.bitmapranges, NULL),
         case when dbms_metadata.get_version >= '11.02.00.00.00' then
                   s.cachehint
              else
                   decode(mod(s.cachehint,4),
                          1, 1,
                          2, 2,
                          0)
         end,
         s.scanhint, s.hwmincr,
         -- Convert 'flags' to a value that the pre-11.2 xsl stylesheet
         -- can process: if archive compressed and version < 11.2,
         -- turn off compression.  The block format for archive compression
         -- is not supported pre-11.2, so the compression bits must be
         -- set to NOCOMPRESS.
         -- (names defined in ktscts.h)
         -- #define KTSSEGM_FLAG_ARCH1 0x2000000  (33554432)
         -- #define KTSSEGM_FLAG_ARCH2 0x4000000  (67108864)
         -- #define KTSSEGM_FLAG_ARCH3 0x8000000 (134217728) 
         -- #define KTSSEGM_FLAG_HCC_ROW_LOCKING 0x80000000 (2147483648)
         case when bitand(s.spare1,33554432+67108864+134217728+2147483648)=0
                   then s.spare1
              when dbms_metadata.get_version >= '11.02.00.00.00' then s.spare1
              else s.spare1
                 - bitand(s.spare1,2048+33554432+67108864+134217728+2147483648)
         end,
         trunc(s.spare1 / power(2,32)),
         s.spare2
  from seg$ s
/


-------------------------------------------------------------------------------
--                              FILESPEC
-------------------------------------------------------------------------------

-- NOTE!! NOTE!! NOTE!!
--
-- Per bug-8467825 it is not recommended to use v$datafile view
-- if you need just name of datafile, then query x$kccfn and
-- if you need datafile information, then query x$kccfe and x$kcvfh.

create or replace force view ku$_file_view of ku$_file_t
       with object identifier (name) as
-- obj. IDs are currently limited to 923 chars. CORE increased SLMXFNMLEN to
-- 1025 around 8/21/02. OID is right-most 923 of 1025 bytes.
        select  substrb(fn.fnnam, -(least(lengthb(fn.fnnam),923)), 923),
                replace(fn.fnnam, '''', ''''''),
                f.blocks, fh.fhfsz, f.maxextend, f.inc, f.ts#,null,
                sys.dbms_metadata_util.is_omf(
                  substrb(fn.fnnam, -(least(lengthb(fn.fnnam),923)), 923))
        from    sys.x$kccfn fn, sys.file$ f, x$kcvfh fh
        where   f.file# = fn.fnfno AND
                fn.fnnam IS NOT NULL AND 
                fn.fnfno = fh.hxfil AND
                fn.fntyp = 4 AND                     /* For data files */
                f.spare1 is NULL
      union all
        select  substrb(fn.fnnam, -(least(lengthb(fn.fnnam),923)), 923),
                replace (fn.fnnam, '''', ''''''),
                f.blocks,
                DECODE(hc.ktfbhccval, 0, hc.ktfbhcsz, NULL),
                DECODE(hc.ktfbhccval, 0, hc.ktfbhcmaxsz, NULL),
                DECODE(hc.ktfbhccval, 0, hc.ktfbhcinc, NULL),
                ts.ts#,
                null,
                sys.dbms_metadata_util.is_omf(
                  substrb(fn.fnnam, -(least(lengthb(fn.fnnam),923)), 923))
        FROM    sys.x$kccfn fn, sys.file$ f, sys.x$ktfbhc hc, sys.ts$ ts
        WHERE   fn.fnfno = f.file# AND
                fn.fntyp = 4 AND                         /* For data files */
                fn.fnnam IS NOT NULL AND
                f.spare1 is NOT NULL AND
                fn.fnfno = hc.ktfbhcafno AND
                hc.ktfbhctsn = ts.ts#
      union all
        select                                       /*+ ordered use_nl(hc) +*/
                substrb(fn.fnnam, -(least(lengthb(fn.fnnam),923)), 923),
                replace (fn.fnnam, '''', ''''''),
                /* Bug 21747321: Temp tablespaces are writable in read only 
                   database. When ever temp tablespace state gets modifed 
                   then status can not be modified in ts$ and size value 
                   also becomes zero. So, fetch temp tablespace status and
                   tempfile status from x$kcctf */
                DECODE(hc.ktfthccval, 0, hc.ktfthcsz, 1, tf.tfcsz, -1),
                DECODE(hc.ktfthccval, 0, hc.ktfthcsz, 1, tf.tfcsz, -1),
                DECODE(hc.ktfthccval, 0, hc.ktfthcmaxsz, NULL),
                DECODE(hc.ktfthccval, 0, hc.ktfthcinc, NULL),
                ts.ts#,
                tf.tfsta,
                sys.dbms_metadata_util.is_omf(
                  substrb(fn.fnnam, -(least(lengthb(fn.fnnam),923)), 923))
        FROM    sys.x$kccfn fn, sys.x$ktfthc hc, sys.ts$ ts, sys.x$kcctf tf
        WHERE   fn.fntyp = 7 AND
                fn.fnnam IS NOT NULL AND
                fn.fnfno = hc.ktfthctfno AND
                ts.ts# = tf.tftsn AND
                tf.tffnh=fn.fnnum AND
                hc.ktfthctsn(+) = ts.ts#
/

-------------------------------------------------------------------------------
--                              TABLESPACE
-------------------------------------------------------------------------------

-- view for tablespaces
create or replace force view ku$_tablespace_view of ku$_tablespace_t
  with object identifier (ts_num) as
  select '1', '0',
          t.ts#, t.name,  t.owner#, t.online$, t.contents$, t.undofile#,
          t.undoblock#, t.blocksize, t.inc#, t.scnwrp, t.scnbas, t.dflminext,
          t.dflmaxext, t.dflinit, t.dflincr, t.dflminlen, t.dflextpct,
          t.dflogging, t.affstrength, t.bitmapped, t.plugged, t.directallowed,
          -- Convert 'flags' to a value that the pre-11.2 xsl stylesheet
          -- can process: if archive compressed and version < 11.2,
          -- turn off compression.  The block format for archive compression
          -- is not supported pre-11.2, so the compression bits must be
          -- set to NOCOMPRESS.
          --  #define KTT_COMPRESSED              0x40      (64)
          -- #define KTT_ARCH1_COMPRESSION  ((ub4)0x20000)  (131072)
          -- #define KTT_ARCH2_COMPRESSION  ((ub4)0x40000)  (262144)
          -- #define KTT_ARCH3_COMPRESSION  ((ub4)0x80000)  (524288)
          -- #define KTT_HCC_ROW_LOCKING    ((ub4)0x400000) (4194304)
          -- FLAGS<43:0> includes all InMemory bits and allows us to be backward compatible.
          -- FLAGS<63:32> InMemory bits as well as InMemory FOR_SERVICE flag
          -- Note: Versions <=11.2 only 32 bits worth of flags.
          case when bitand (t.flags,131072+262144+524288+4194304) = 0
                   then bitand(t.flags,4294967295)
               when dbms_metadata.get_version >= '11.02.00.00.00' then bitand(t.flags,4294967295)
               else bitand(t.flags - bitand(t.flags,64+131072+262144+524288+4194304),4294967295)
          end,
          trunc(t.flags / power(2, 32)),                     /* FLAGS<63:32> */
          (select svcname  from imsvcts$ svc where svc.ts# = t.ts#),
          (select svcflags from imsvcts$ svc where svc.ts# = t.ts#),
          t.pitrscnwrp, t.pitrscnbas, t.ownerinstance, t.backupowner,
          case bitand(t.flags,1024)
            when 1024 then
              (select t2.name
               from ts$ t2
               where t.dflmaxext  = t2.ts#)
            else NULL end,
          t.spare1, t.spare2, t.spare3, to_char(t.spare4,'YYYY/MM/DD HH24:MI:SS'),
          cast(multiset(select value(f) from ku$_file_view f
                       where f.ts_num = t.ts#
                      ) as ku$_file_list_t
             ),
          (select encryptionalg 
           from v$encrypted_tablespaces et
           where  et.ts# = t.ts#)
 from ts$ t
 where  t.online$  IN (1, 2, 4)
 and    bitand(t.flags,2048) = 0
 and    (SYS_CONTEXT('USERENV','CURRENT_USERID') = 0
        OR EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

--
-------------------------------------------------------------------------------
--                      SQL COMPILER SWITCHES 
-------------------------------------------------------------------------------
--
create or replace force view ku$_switch_compiler_view of ku$_switch_compiler_t
  with object identifier (obj_num) as
  select /*+ no_merge */
         b.obj#, to_char(dbms_metadata.get_plsql_optimize_level(b.value)),
         c.value, d.value, e.value, f.value, g.value
         FROM    sys.settings$ b, sys.settings$ c,  sys.settings$ d,
                 sys.settings$ e, sys.settings$ f,  sys.settings$ g,
                 sys.ku$_schemaobj_view o
         WHERE   o.obj_num  = b.obj# AND
                b.obj#  = c.obj# AND
                c.obj#  = d.obj# AND
                d.obj#  = e.obj# AND
                e.obj#  = f.obj# AND
                f.obj#  = g.obj# AND
                b.param = 'plsql_optimize_level'         AND
                c.param = 'plsql_code_type'              AND
                d.param = 'plsql_debug'                  AND
                e.param = 'plsql_ccflags'                AND
                f.param = 'plscope_settings'             AND
                g.param = 'nls_length_semantics'         AND
                (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (o.owner_num, 0) OR
                 EXISTS (
                    SELECT  role
                    FROM    sys.session_roles
                    WHERE   role = 'SELECT_CATALOG_ROLE'))
/

-------------------------------------------------------------------------------
--                              TYPE
-------------------------------------------------------------------------------
-- 
-- To ensure singleton select here, only return the latest version of the
-- type.  That is the type whose toid and tvoid are identical.  This will
-- also ensure that the version/version# returned is the highest/latest one.
-- NOTE: This 't.toid = t.tvoid' predicate works even with editionable
-- types because RDBMS does not allow editions on evolved types and does not
-- allow editioned types to evolve.  So as far as an editioned type is concerned 
-- there should only be one version.
--
create or replace force view ku$_simple_type_view of ku$_simple_type_t
  with object identifier (toid) as
  select
   toid,
   version#,
   version,
   typecode,
   properties,
   attributes,
   local_attrs,
   methods,
   hiddenMethods,
   typeid,
   roottoid,
   hashcode,
  (select value(so) from ku$_edition_schemaobj_view so
    where so.oid = toid and so.type_num = 13),
  (select name from obj$ o where o.oid$ = toid and o.type#=13)
  from type$ t
  where t.toid = t.tvoid
/

create or replace force view ku$_collection_view of ku$_collection_t
  with object identifier (toid) as
  select
  toid,                                                              /* TOID */
  version#,                                  /* internal type version number */
  coll_toid,                        /* collection TOID (TABLE, VARRAY, etc.) */
  coll_version#,                /* collection type's internal version number */
  elem_toid,                                               /* element's TOID */
  elem_version#,                 /* element's type's internal version number */
  synobj#,                                           /* obj# of type synonym */
  properties,                                       /* element's properties: */
  charsetid,                                             /* character set id */
  charsetform,                                         /* character set form */
  length,                                /* fixed character string length or */
                                  /* maximum varying character string length */
  precision,                   /* fixed- or floating-point numeric precision */
  scale,                                        /* fixed-point numeric scale */
  upper_bound,              /* fixed array size or varying array upper bound */
  spare1,                                    /* fractional seconds precision */
  spare2,                                /* interval leading field precision */
  spare3,
  (select value(st) from ku$_simple_type_View st where st.toid = c.coll_toid),
  (select value(st) from ku$_simple_type_View st where st.toid = c.elem_toid)
  FROM sys.collection$ c
/

create or replace force view ku$_argument_view of ku$_argument_t
  with object identifier (procedure_num) as
  select
   obj#,
   procedure$,
   overload#,
   procedure#,
   position#,
   sequence#,
   level#,
   argument,
   type#,
   charsetid,
   charsetform,
   default#,
   in_out,
   properties,
   length,
   precision#,
   scale,
   radix,
   deflength,
   sys.dbms_metadata_util.long2varchar(deflength,
                                        'SYS.ARGUMENT$',
                                        'DEFAULT$',
                                        rowid),
   type_owner,
   type_name,
   type_subname,
   type_linkname,
   pls_type
from sys.argument$
/

create or replace force view ku$_procinfo_view of ku$_procinfo_t
  with object identifier (obj_num) as
  select
  obj#,
  procedure#,
  overload#,
  procedurename,
  properties,
  itypeobj#,
  spare1,
  spare2,
  spare3,
  spare4
  from procedureinfo$
/

create or replace force view ku$_procjava_view of ku$_procjava_t
  with object identifier (obj_num) as
  select
  obj#,
  procedure#,
  ownername,
  ownerlength,
  usersignature,
  usersiglen,
  classname,
  classlength,
  methodname,
  methodlength,
  flags,
  flagslength,
  cookiesize
  from procedurejava$
/

create or replace force view ku$_procc_view of ku$_procc_t
  with object identifier (obj_num) as
  select
  obj#,
  procedure#,
  entrypoint#
  from procedurec$
/

create or replace force view ku$_procplsql_view of ku$_procplsql_t
  with object identifier (obj_num) as
  select
  obj#,
  procedure#,
  entrypoint#
  from procedureplsql$
/

create or replace force view ku$_method_view of ku$_method_t
  with object identifier (toid) as
  select
  m.toid,
  m.version#,
  m.method#,
  m.name,
  m.properties,
  m.parameters#,
  m.results,
  m.xflags,
  m.spare1,
  m.spare2,
  m.spare3,
  m.externVarName,
  cast(multiset(select * from  ku$_argument_view a
                where m.name = a.procedure_val and
                      a.obj_num = o.obj#
               ) as ku$_argument_list_t
      ),
  (select value(pi) from ku$_procinfo_view pi
   where pi.obj_num = o.obj# and
         pi.procedure_num = m.method#),
  (select value(pj) from ku$_procjava_view pj
   where pj.obj_num=o.obj# and
         pj.procedure_num = m.method#),
  (select value(pq) from ku$_procplsql_view pq
   where pq.obj_num=o.obj# and
         pq.procedure_num = m.method#),
  (select value(pc) from ku$_procc_view pc
   where pc.obj_num=o.obj# and
         pc.procedure_num = m.method#),
  o.obj#
from  sys.obj$ o, sys.method$ m
where m.toid = o.oid$
/

create or replace force view ku$_type_attr_view of ku$_type_attr_t
  with object identifier (toid) as
select
  a.toid,
  a.version#,
  a.name,
  a.attribute#,
  a.attr_version#,
  a.attr_toid,
  a.synobj#,
  a.properties,
  a.charsetid,
  a.charsetform,
  a.length,
  a.precision#,
  a.scale,
  a.externname,
  a.xflags,
  a.spare1,
  a.spare2,
  a.spare3,
  a.spare4,
  a.spare5,
  a.setter,
  a.getter,
  (select value(st) from ku$_simple_type_view st where a.attr_toid = st.toid)
from  sys.attribute$ a
/

create or replace force view ku$_type_view of ku$_type_t
  with object identifier (obj_num) as
  select '1','2',
         oo.obj#,
         value(o),
         oo.oid$,
         t.typeid, t.version#,
         sys.dbms_metadata.get_hashcode(o.owner_name,o.name),
         t.typecode, t.properties,
         t.attributes, t.methods, t.hiddenMethods,
         t.externtype, t.externname,
         sys.dbms_metadata_util.get_source_lines(oo.name,oo.obj#,oo.type#),
         (select value(c) from ku$_switch_compiler_view c
                 where c.obj_num =oo.obj#),
         (select value(stso) from ku$_edition_schemaobj_view stso
                 where stso.oid = t.supertoid),
         (select value(c) from ku$_collection_view c
              where oo.oid$ = c.toid),
         cast(multiset(select value(a)
                       from   sys.ku$_type_attr_view a
                       where  a.toid = oo.oid$)
                       as     ku$_type_attr_list_t),
         cast(multiset(select value(m)
                       from   sys.ku$_method_view m
                       where  m.toid = oo.oid$ and m.xflags=0 and m.obj_num=oo.obj#)
                       as     ku$_method_list_t)
  from sys.obj$ oo, sys.ku$_edition_schemaobj_view o, type$ t
  where oo.type# = 13
    and oo.obj#  = o.obj_num
    and oo.subname is null      /* latest type version */
    and oo.oid$ = t.toid
        /* type$ properties bits:
           262144=0     - latest type version
           other bits=0 - not system-generated type
        */
    and bitand(t.properties,262144+2048+64+16)=0
         AND (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (o.owner_num, 0) OR
              EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

-- bug 3995788: a dummy type body row is created in obj$ for SQLJ types
-- with no entries in source$. So for the type body view we exclude
-- type bodies where type_misc$.properties has either 0x10 or 0x20 set.

create or replace force view ku$_type_body_view of ku$_type_body_t
  with object identifier (obj_num) as
  select '1','1',
         oo.obj#,
         value(o),
         sys.dbms_metadata_util.get_source_lines(oo.name,oo.obj#,oo.type#),
         (select value(c) from ku$_switch_compiler_view c
                 where c.obj_num =oo.obj#)
  from sys.obj$ oo, sys.ku$_edition_schemaobj_view o, type_misc$ t
  where oo.type# = 14
    and oo.obj#  = o.obj_num
    and t.obj#   = o.obj_num
    and bitand(t.properties,16+32)=0  /* exclude SQLJ type bodies (see above)*/
         AND (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (o.owner_num, 0) OR
              EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

create or replace force view ku$_full_type_view of ku$_full_type_t
  with object identifier (obj_num) as
  select '1','2',
         oo.obj#,
         value(o),
         value(t),
         (select value(tb) from ku$_type_body_view tb
          where oo.name  = tb.schema_obj.name
          and o.owner_name  = tb.schema_obj.owner_name)
  from sys.obj$ oo, sys.ku$_edition_schemaobj_view o,
        ku$_type_view t
  where oo.type# = 13
    and oo.obj#  = o.obj_num
    and oo.obj#  = t.schema_obj.obj_num
         AND (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (o.owner_num, 0) OR
              EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

-- type and view used by export
-- includes base_obj_num (obj# of the type_spec) so that the base_obj_num
-- can be used as a filter

-- the no_merge optimizer hint is added to work around a 
-- sigsegv at evaopn2()+231, when processing a query on 
-- ku$_exp_type_body_view.
--
-- Sriram Krishnamurthy wrote:
--  Please give the hint  no_merge in the select statement of
--  ku$_exp_type_body_view and it works. The problem is that after view 
--  merge the 4th columns kafco doesn't get allocated.  Interestingly 
--  the 3rd operand point to same column and it does seem to have colkafco. 
-- Please file a bug if you are fine with workaround and fix can be done later.

create or replace force view ku$_exp_type_body_view of ku$_exp_type_body_t
  with object identifier (obj_num) as
  select /*+ no_merge */
         '1','1',
         o1.obj#,o2.obj#,
         (select value(o) from sys.ku$_edition_schemaobj_view o
                          where o.obj_num=o2.obj#),
       sys.dbms_metadata_util.get_source_lines(o2.name,o2.obj#,o2.type#),
       (select value(c) from sys.ku$_switch_compiler_view c
                 where c.obj_num = o2.obj#)
  from sys.ku$_edition_obj_view o1, sys.ku$_edition_obj_view o2,
       sys.type$ ty, type_misc$ tm
  where o1.type# = 13 and o2.type#=14
    and o1.name=o2.name and o1.owner#=o2.owner#
    and ty.toid=o1.oid$
    and o1.subname is null      /* latest type version */
        /* type$ properties bits:
           8388608=0    - not transient type
           262144=0     - latest type version
           other bits=0 - not system-generated type
        */
    and bitand(ty.properties,8388608+262144+2048+64+16)=0
    and tm.obj#  = o2.obj#
    and bitand(tm.properties,16+32)=0   /* exclude SQLJ type bodies */
         AND (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (o2.owner#, 0) OR
              EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

-- incomplete types: types that are targets of REF dependency from
-- some other type

create or replace force view ku$_inc_type_view of ku$_schemaobj_t
  with object identifier (obj_num) as
select value (oo)
  from sys.ku$_edition_schemaobj_view oo, sys.obj$ o, sys.obj$ do,
       sys.dependency$ d, sys.type$ ty
  where o.oid$ = ty.toid
    and oo.obj_num = o.obj#
    and o.owner# != 0                   /* not owned by SYS */
    and bitand(o.flags,16)!=16          /* not secondary object */
    and o.obj# = d.p_obj#
    and do.obj# = d.d_obj#
    and bitand(d.property,2)=2          /* only REF dependency */
    and do.type# = 13
    and bitand(ty.properties,8388608)=0 /* exclude transient types */
         AND (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (o.owner#, 0) OR
              EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/


-- This view provides the list of User Defined Type (UDT) objects on which 
-- other UDTs are dependent. These lists of obj#s are walked in prvtmeti's 
-- SORT_OBJECTS function to generate the dependency ordered list of UDT obj#s
-- which is used to order the creation of the types during import.  This view
-- is complicated by the need to locate dependencies between UDTs in all 
-- versions (original one created, and any altered).  This need became apparent
-- when we added support to recreate a type's version evolution during import
-- when we apply the initial create type and each subsequent alter type 
-- separately (Bug 9223960).  Each version of a UDT gets its own obj#.  The 
-- inner query that includes the DEPENDENCY$ table finds the list of type obj#s
-- on which other type obj#s are dependent, for all versions.  That is because
-- we are looking for all TVOIDs (version toids?).  If you only wanted to 
-- locate the latest version of each type (which is what this view used to do)
-- then you only look for obj#s whose TOID matches its TVOID.  This change was
-- first added for bug 14331214.
--
-- Now what really makes this view complicated is that the obj#s in the final
-- lists  need to be for the latest version of each type (this normalizes all
-- the dependencies to using the same obj# for each UDT).  This realization 
-- came from analyzing bug 14762810 when exporting/importing using a dump file.
-- This revealed that types were trying to be created in the wrong order.  So,
-- after finding the dependencies on types' versions, the outer query then
-- looks for the obj# whose TVOID matches its TOID and matches the TVOID of the
-- inner query.  This is what finally returns the lists that contain only the
-- obj#s of the latest version of each type referenced. With this being output,
-- the SORT_OBJECTS function correctly runs through the dependencies and builds
-- the correct dependency order in which to create the UDTs.
-- 
-- To make sure this view returns all UDTs, even ones that have no other types 
-- dependent on them, we union in all the current types that have no 
-- dependencies.  If this ever becomes a performance issue,  I think we could
-- union the entire list of the latest version of all types and the 
-- SORTED_OBJECTS function would generate the correct final list.

create or replace force view ku$_deptypes_base_view(
 typeobjno, typename, typeownerno, typeowner, typeobjflags, dobjno, dname)
as
 select o.obj#, o.name, o.owner#, bu.name, o.flags, bo.obj#, bo.name
 from
   (select
      oo.obj# as aobjnum, ot.toid as aobjoid,
      do.obj# as adobjnum, dt.toid as adobjoid
    from dependency$ d, obj$ oo, type$ ot, obj$ do, type$ dt, user$ u
    where oo.oid$ = ot.tvoid
      and bitand(ot.properties,8388608+2128)=0 /* not transient or sys-generated */
      and bitand(oo.flags,16)!=16          /* not secondary object */
      and oo.owner# != 0                   /* not owned by SYS */
      and oo.owner# = u.user#
      and oo.obj# = d.p_obj#
      and do.obj# = d.d_obj#
      and bitand(d.property,1)=1          /* only hard dependency */
      and do.type# = 13
      and do.oid$ = dt.tvoid) a, type$ at, obj$ ao, 
    ku$_edition_obj_view o, type$ bt, obj$ bo, user$ bu
  where a.aobjoid = at.tvoid and at.tvoid = at.toid and at.toid = ao.oid$ and 
      ao.obj# = o.obj# and
      a.adobjoid = bt.tvoid and bt.tvoid = bt.toid and bt.toid = bo.oid$ and
      o.owner# = bu.user#
union
 select o.obj#,o.name,o.owner#,u.name,o.flags,0,NULL
from ku$_edition_obj_view o, user$ u, type$ t
where o.oid$ = t.toid
  and bitand(t.properties,8388608+2128)=0 /* not transient or sys-generated */
  and bitand(o.flags,16)!=16          /* not secondary object */
  and o.owner# != 0                   /* not owned by SYS */
  and o.owner# = u.user#
  and not exists (select * from obj$ do, dependency$ d
                  where o.obj# = d.p_obj#
                  and do.obj# = d.d_obj#
                  and do.type# = 13
                  and bitand(d.property,1)=1 )
/

create or replace force view ku$_deptypes_view(
 typeobjno, typename, typeownerno, typeowner, typeobjflags, dobjno, dname)
as
 select b.typeobjno, b.typename, b.typeownerno, b.typeowner, b.typeobjflags,
        b.dobjno, b.dname
 from ku$_deptypes_base_view b
 where (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (b.typeownerno, 0) OR
              EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

-------------------------------------------------------------------------------
--                              SIMPLE COLUMNS
-------------------------------------------------------------------------------

-- View ku$_simple_col_view moved to catmetviews_mig.sql


-- view to get simple column information for a nested table setid column.
-- used solely for constraint and index column names - sets the column
-- name/attribute to the 'real' column/attribute name.
--
-- This is only valid for setid columns referenced from a foreign key
-- constraint (i.e. foreign key (nested_table_id) references <outer-table>
-- (<setid-column-name>)).  The 'resolved' column name is illegal when used
-- in a hidden setid constraint or index (i.e. unique (<setid-column-name>).
-- For those cases the only valid column name is the system generated one
-- (SYS_NCnnnnnmmmmm$).  However, the hidden setid constraint and index
-- info only appears with TABLE objects, and it is ignored except for
-- transportable mode, where the column names are not used. 

create or replace force view ku$_simple_setid_col_view of ku$_simple_col_t
  with object identifier (obj_num, intcol_num) as
  select c.obj#,
         c.col#,
         c.intcol#,
         c.segcol#,
         (bitand(c.property,4294967295) + BITAND(c2.property,1)),
         trunc(c.property / power(2,32)),
         c2.name,
         (select a.name
          from attrcol$ a
          where a.obj# = c2.obj# and
                a.intcol# = c2.intcol#),
         c.type#,
         c.deflength,
         case
           when c.deflength is null or bitand(c.property,32+65536)=0
                or c.deflength > 4000
           then null
           else
             sys.dbms_metadata_util.func_index_default(c.deflength,
                                                       c.rowid)
         end,
         case
           when c.deflength is null or bitand(c.property,32+65536)=0
                or c.deflength <= 4000
           then null
           when c.deflength <= 32000
           then
             sys.dbms_metadata_util.func_index_defaultc(c.deflength,
                                                        c.rowid)
           else
             sys.dbms_metadata_util.long2clob(c.deflength,
                                              'SYS.COL$',
                                              'DEFAULT$',
                                              c.rowid)
         end,
         case
           when c.deflength is null or bitand(c.property,32+65536)=0
           then null
           else
            (select sys.dbms_metadata.parse_default(
                                SYS_CONTEXT('USERENV','CURRENT_USERID'),
                                u.name, o.name, c.deflength,c.rowid)
             from obj$ o, user$ u
             where o.obj#=c.obj# and o.owner#=u.user#)
         end,
         NULL
  from col$ c, col$ c2
  where BITAND(c.property, 1024) = 1024 and                  /* SETID column */
        c2.obj# = c.obj# and
        c2.col# = c.col# and
        c2.intcol# = (c.intcol# - 1) and
        c2.segcol# = 0
/

-- view to get simple column information for a pkRef REF column.
-- used soley for constraint column name resolution - sets the constraint
-- column name/attribute to the 'real' column/attribute name for each
-- internal column referenced in the intcol#s ub2 intcol# array.
-- invoked only for columns with property REA (REF attribute).

create or replace force view ku$_simple_pkref_col_view of ku$_simple_col_t
  with object identifier (obj_num, intcol_num) as
  select c.obj#,
         c.col#,
         c.intcol#,
         c.segcol#,
         bitand(c.property, 4294967295),
         trunc(c.property / power(2,32)),
         c2.name,
         (select a.name
          from attrcol$ a
          where a.obj# = c2.obj# and
                a.intcol# = c2.intcol#),
         c.type#,
         c.deflength,
         case
           when c.deflength is null or bitand(c.property,32+65536)=0
                or c.deflength > 4000
           then null
           else
             sys.dbms_metadata_util.func_index_default(c.deflength,
                                                       c.rowid)
         end,
         case
           when c.deflength is null or bitand(c.property,32+65536)=0
                or c.deflength <= 4000
           then null
           when c.deflength <= 32000
           then
             sys.dbms_metadata_util.func_index_defaultc(c.deflength,
                                                        c.rowid)
           else
             sys.dbms_metadata_util.long2clob(c.deflength,
                                              'SYS.COL$',
                                              'DEFAULT$',
                                              c.rowid)
         end,
         case
           when c.deflength is null or bitand(c.property,32+65536)=0
           then null
           else
            (select sys.dbms_metadata.parse_default(
                                SYS_CONTEXT('USERENV','CURRENT_USERID'),
                                u.name, o.name, c.deflength,c.rowid)
             from obj$ o, user$ u
             where o.obj#=c.obj# and o.owner#=u.user#)
         end,
         NULL
  from  col$ c, col$ c2, ccol$ cc, cdef$ cd, coltype$ ct
  where cc.obj# = c.obj# and
        cc.intcol# = c.intcol# and
        cd.con# = cc.con# and
        ct.obj# = c.obj# and
        ct.col# = c.col# and
        ct.intcols = cd.intcols and
        UTL_RAW.CAST_TO_BINARY_INTEGER(
          SUBSTRB(ct.intcol#s, (cc.pos# * 2 - 1), 2), 3) = c.intcol# and
        c2.obj# = c.obj# and
        c2.intcol# = ct.intcol#
/

-------------------------------------------------------------------------------
--                              INDEX COLUMNS
-------------------------------------------------------------------------------

-- view for index columns
   -- Moved to catmetviews_mig.sql file

-------------------------------------------------------------------------------
--                              LOB COLUMNS
-------------------------------------------------------------------------------

-- view for lob indexes
create or replace force view ku$_lobindex_view of ku$_lobindex_t
  with object identifier(obj_num) as
  select i.obj#, value(o),
         ts.name, ts.blocksize,
         (select value(s) from ku$_storage_view s
          where i.file#  = s.file_num
          and   i.block# = s.block_num
          and   i.ts#    = s.ts_num),
         (select value(s) from ku$_deferred_stg_view s
          where s.obj_num = i.obj#),
         i.dataobj#, i.cols, 
         i.pctfree$, i.initrans, i.maxtrans, i.pctthres$, i.type#, i.flags, i.property,
         i.blevel, i.leafcnt, i.distkey, i.lblkkey, i.dblkkey, i.clufac,
         to_char(i.analyzetime,'YYYY/MM/DD HH24:MI:SS'), 
         i.samplesize, i.rowcnt, 
         i.intcols, i.degree, i.instances, i.trunccnt, 
         i.spare1, i.spare2, i.spare3,
         replace(i.spare4, chr(0)), i.spare5, 
         to_char(i.spare6,'YYYY/MM/DD HH24:MI:SS'),
         null, null, null
   from  ku$_schemaobj_view o, ind$ i, ts$ ts
   where o.obj_num = i.obj#
         AND  i.ts# = ts.ts#
/

-- view for lobs in nonpartitioned tables
create or replace force view ku$_lob_view of ku$_lob_t
  with object OID(obj_num, intcol_num)
  as select l.obj#, l.col#, l.intcol#,
        (select value(o) from ku$_schemaobj_view o
         where o.obj_num = l.lobj#),
        (select value(s) from ku$_storage_view s
         where s.file_num  = l.file#
         and   s.block_num = l.block#
         and   s.ts_num    = l.ts#),
         (select value(s) from ku$_deferred_stg_view s
          where s.obj_num = l.lobj#),
        (select ts.name from ts$ ts where l.ts# = ts.ts#),
        (select ts.blocksize from ts$ ts where l.ts# = ts.ts#),
        l.ind#,
        (select value(i) from ku$_lobindex_view i where i.obj_num=l.ind#),
        l.chunk, l.pctversion$, l.flags, l.property,
        l.retention, l.freepools, l.spare1, l.spare2, l.spare3,
  /* attributes only for lobfarg (partitioned) */
        null, null, null, null
  from lob$ l
/

-- view for lobfrag indexes
create or replace force view ku$_lobfragindex_view of ku$_lobindex_t
  with object identifier(obj_num) as
  select i.obj#, value(o),
         ts.name, ts.blocksize,
         (select value(s) from ku$_storage_view s
          where i.file#  = s.file_num
          and   i.block# = s.block_num
          and   i.ts#    = s.ts_num),
         (select value(s) from ku$_deferred_stg_view s
          where s.obj_num = i.obj#),
         i.dataobj#, null,
         i.pctfree$, i.initrans, i.maxtrans, i.pctthres$, null, i.flags, null,
         i.blevel, i.leafcnt, i.distkey, i.lblkkey, i.dblkkey, i.clufac,
         to_char(i.analyzetime,'YYYY/MM/DD HH24:MI:SS'), i.samplesize, i.rowcnt,
         null, null, null, null,
         i.spare1, i.spare2, i.spare3,
         null, null, null,   /* spare4, spare5, spare6 */
         i.bo#,
         dbms_metadata.get_partn(4,i.bo#,i.part#),
         i.inclcol
   from  ku$_schemaobj_view o, indpart$ i, ts$ ts
   where o.obj_num = i.obj#
         AND  i.ts# = ts.ts#
/

-- view for lobfrag indexes in subpartitions
-- 13898265: replace v$ view to improve performance, so now the partition
-- numbers may not correspond to 'absolute fragment numbers' as used elsewhere.
-- using these 'partition numbers' in relating partitions could be problematic.
create or replace force view ku$_sublobfragindex_view of ku$_lobindex_t
  with object identifier(obj_num) as
  select i.obj#, value(o),
         ts.name, ts.blocksize,
         (select value(s) from ku$_storage_view s
          where i.file#  = s.file_num
          and   i.block# = s.block_num
          and   i.ts#    = s.ts_num),
         (select value(s) from ku$_deferred_stg_view s
          where s.obj_num = i.obj#),
         i.dataobj#, null, 
         i.pctfree$, i.initrans, i.maxtrans, null, null, i.flags, null,
         i.blevel, i.leafcnt, i.distkey, i.lblkkey, i.dblkkey, i.clufac,
         to_char(i.analyzetime,'YYYY/MM/DD HH24:MI:SS'), i.samplesize, i.rowcnt,
         null, null, null, null,
         i.spare1, i.spare2, i.spare3,
         null, null, null,   /* spare4, spare5, spare6 */
         i.pobj#,
         dbms_metadata.get_partn(6,i.pobj#,i.subpart#),
         null
   from  ku$_schemaobj_view o, indsubpart$ i, ts$ ts
   where o.obj_num = i.obj#
         AND  i.ts# = ts.ts#
/

-- view for p2t lobs -- lobs from table partition promoted to table lobs
create or replace force view ku$_p2tlob_view of ku$_lob_t
  with object OID(obj_num, intcol_num)
  as select lf.fragobj#, l.col#, l.intcol#, 
        (select value(o) from ku$_schemaobj_view o
         where o.obj_num = lf.fragobj#),
        (select value(s) from ku$_storage_view s
         where s.file_num  = lf.file#
         and   s.block_num = lf.block#
         and   s.ts_num    = lf.ts#),
         (select value(s) from ku$_deferred_stg_view s
          where s.obj_num = lf.fragobj#),
        (select ts.name from ts$ ts where lf.ts# = ts.ts#),
        (select ts.blocksize from ts$ ts where lf.ts# = ts.ts#),
        lf.indfragobj#,
        (select value(i) from ku$_lobfragindex_view i
                 where i.obj_num=lf.indfragobj#),
        lf.chunk, lf.pctversion$, lf.fragflags, lf.fragpro,
        null, null, lf.spare1, lf.spare2, to_char(lf.spare3),
  /* attributes only for lobfarg (partitioned) */
        lf.parentobj#, lf.tabfragobj#, l.obj#, 
        dbms_metadata.get_partn(7,lf.parentobj#,lf.frag#)
  from lob$ l, lobfrag$ lf
        where l.lobj#=lf.parentobj#
/

-- view for sp2t lobs -- lobs from table subpartition promoted to table lobs
create or replace  view ku$_sp2tlob_view of ku$_lob_t
  with object OID(obj_num, intcol_num)
  as select lf.fragobj#, l.col#, l.intcol#, 
        (select value(o) from ku$_schemaobj_view o
         where o.obj_num = lf.fragobj#),
        (select value(s) from ku$_storage_view s
         where s.file_num  = lf.file#
         and   s.block_num = lf.block#
         and   s.ts_num    = lf.ts#),
         (select value(s) from ku$_deferred_stg_view s
          where s.obj_num = lf.fragobj#),
        (select ts.name from ts$ ts where lf.ts# = ts.ts#),
        (select ts.blocksize from ts$ ts where lf.ts# = ts.ts#),
        lf.indfragobj#,
        (select value(i) from ku$_sublobfragindex_view i
                 where i.obj_num=lf.indfragobj#),
        lf.chunk, lf.pctversion$, lf.fragflags, lf.fragpro,
        null, null, lf.spare1, lf.spare2, to_char(lf.spare3),
  /* attributes only for lobfarg (partitioned) */
        lf.parentobj#, lf.tabfragobj#, l.obj#, 
        dbms_metadata.get_partn(7,lf.parentobj#,lf.frag#)
--  from partlob$ pl, lob$ l, lobfrag$ lf, tab$ t, col$ c
  from lobcomppart$ lcp,  lob$ l, lobfrag$ lf
  where lcp.partobj#=lf.parentobj# and
        l.lobj# = lcp.lobj# 
/

-- view for table level defaults for LOBs (from partlob$)
create or replace force view ku$_partlob_view of ku$_partlob_t
  with object OID(obj_num, intcol_num)
  as select l.tabobj#, l.intcol#,
        (select value(o) from ku$_schemaobj_view o
         where o.obj_num = l.lobj#),
        (select ts.name from ts$ ts where l.defts# = ts.ts#),
        NVL(
          (select ts.blocksize from ts$ ts where l.defts# = ts.ts#),
          NVL(         /* should be avail. thru lobcompart, lobfrag if null */
            (select ts.blocksize
             from   ts$ ts, lobfrag$ lf
             where  l.lobj# = lf.parentobj# and
                    lf.ts# = ts.ts# and rownum < 2),
            (select ts.blocksize
             from   ts$ ts, lobcomppart$ lcp, lobfrag$ lf
             where  l.lobj# = lcp.lobj# and
                    lcp.partobj# = lf.parentobj# and
                    lf.ts# = ts.ts# and rownum < 2))),
        l.defchunk, l.defpctver$, l.defflags, l.defpro,
        l.definiexts, l.defextsize, l.defminexts, l.defmaxexts,
        l.defextpct, l.deflists, l.defgroups, l.defbufpool,
        l.spare1, l.spare2, l.spare3,
        l.defmaxsize, l.defretention, l.defmintime
  from partlob$ l
/

-- view for partition-level LOB attributes
create or replace force view ku$_lobfrag_view of ku$_lob_t
  with object OID(obj_num)
  as select lf.fragobj#, null, l.intcol#, 
        (select value(o) from ku$_schemaobj_view o
         where o.obj_num = lf.fragobj#),
        (select value(s) from ku$_storage_view s
         where s.file_num  = lf.file#
         and   s.block_num = lf.block#
         and   s.ts_num    = lf.ts#),
         (select value(s) from ku$_deferred_stg_view s
          where s.obj_num = lf.fragobj#),
        (select ts.name from ts$ ts where lf.ts# = ts.ts#),
        (select ts.blocksize from ts$ ts where lf.ts# = ts.ts#),
        lf.indfragobj#,
        (select value(i) from ku$_lobfragindex_view i
                 where i.obj_num=lf.indfragobj#),
        lf.chunk, lf.pctversion$, lf.fragflags, lf.fragpro,
        null, null, lf.spare1, lf.spare2, to_char(lf.spare3),
  /* attributes only for lobfarg (partitioned) */
        lf.parentobj#, lf.tabfragobj#, l.obj#, 
        dbms_metadata.get_partn(7,lf.parentobj#,lf.frag#)
  from  lob$ l, lobfrag$ lf
        where l.lobj#=lf.parentobj#
/

-- view for partition-level LOB attributes in partitioned IOTs
create or replace force view ku$_piotlobfrag_view of ku$_lob_t
  with object OID(obj_num)
  as select lf.fragobj#, null, l.intcol#, 
        (select value(o) from ku$_schemaobj_view o
         where o.obj_num = lf.fragobj#),
        (select value(s) from ku$_storage_view s
         where s.file_num  = lf.file#
         and   s.block_num = lf.block#
         and   s.ts_num    = lf.ts#),
        (select value(s) from ku$_deferred_stg_view s
         where s.obj_num = lf.fragobj#),
        (select ts.name from ts$ ts where lf.ts# = ts.ts#),
        (select ts.blocksize from ts$ ts where lf.ts# = ts.ts#),
        lf.indfragobj#,
        (select value(i) from ku$_lobfragindex_view i
                 where i.obj_num=lf.indfragobj#),
        lf.chunk, lf.pctversion$, lf.fragflags, lf.fragpro,
        null, null, lf.spare1, lf.spare2, to_char(lf.spare3),
  /* attributes only for lobfarg (partitioned) */
        lf.parentobj#, pl.tabobj#, l.obj#, 
        dbms_metadata.get_partn(7,lf.parentobj#,lf.frag#)
  from  lob$ l, partlob$ pl, lobfrag$ lf
        where l.lobj#=lf.parentobj# and pl.lobj#=lf.parentobj#
/

-- view for subpartition-level LOB attributes
-- 13898265: replace v$ view to improve performance, so now the partition
-- numbers may not correspond to 'absolute fragment numbers' as used elsewhere.
-- using these 'partition numbers' in relating partitions could be problematic.
create or replace force view ku$_sublobfrag_view of ku$_lob_t
  with object OID(obj_num)
  as select lf.fragobj#, null, l.intcol#,
        (select value(o) from ku$_schemaobj_view o
         where o.obj_num = lf.fragobj#),
        (select value(s) from ku$_storage_view s
         where s.file_num  = lf.file#
         and   s.block_num = lf.block#
         and   s.ts_num    = lf.ts#),
        (select value(s) from ku$_deferred_stg_view s
         where s.obj_num = lf.fragobj#),
        (select ts.name from ts$ ts where lf.ts# = ts.ts#),
        (select ts.blocksize from ts$ ts where lf.ts# = ts.ts#),
        lf.indfragobj#,
        (select value(i) from ku$_sublobfragindex_view i
                 where i.obj_num=lf.indfragobj#),
        lf.chunk, lf.pctversion$, lf.fragflags, lf.fragpro,
        null, null, lf.spare1, lf.spare2, to_char(lf.spare3),
  /* attributes only for lobfarg (partitioned) */
        lf.parentobj#, lf.tabfragobj#, l.obj#, lf.frag#
  from  lob$ l, lobcomppart$ lc, lobfrag$ lf
        where lc.partobj#=lf.parentobj#
          and l.lobj#=lc.lobj#
/

-- view for partition-level defaults in composite partitioned tables
create or replace force view ku$_lobcomppart_view of ku$_lobcomppart_t
  with object OID(obj_num)
  as select lc.partobj#, lc.tabpartobj#,
        dbms_metadata.get_partn(8,lc.lobj#, lc.part#),
        (select l.intcol# from lob$ l where l.lobj#=lc.lobj#),
        (select value(o) from ku$_schemaobj_view o
         where o.obj_num = lc.partobj#),
        (select ts.name from ts$ ts where lc.defts# = ts.ts#),
        (select ts.blocksize from ts$ ts where lc.defts# = ts.ts#),
        lc.defchunk, lc.defpctver$, lc.defflags, lc.defpro,
        lc.definiexts, lc.defextsize, lc.defminexts, lc.defmaxexts,
        lc.defextpct, lc.deflists, lc.defgroups, lc.defbufpool,
        lc.spare1, lc.spare2, lc.spare3,
        lc.defmaxsize, lc.defretention, lc.defmintime
  from lobcomppart$ lc
/

Rem Lob information for template subpartition lob store as clause

create or replace force view ku$_tlob_comppart_view of ku$_tlob_comppart_t
  with object OID(base_objnum)
  as select  dspl.bo#, '"'||c.name||'"', dspl.intcol#,
             dspl.spart_position, dspl.flags, dspl.lob_spart_name,
             (select(t.name) from sys.ts$ t where t.ts# = dspl.lob_spart_ts#),
             dspl.lob_spart_ts#
     from    sys.col$ c, sys.defsubpartlob$ dspl
     where   dspl.bo# = c.obj#
         and dspl.intcol# = c.col#
/

-------------------------------------------------------------------------------
-- for Checking sub-partition were created via 
--the tables's subpartition template clause.
-- using for function check_match_template 
-------------------------------------------------------------------------------
create or replace force view ku$_temp_subpart_view of ku$_temp_subpart_t
  with object identifier(obj_num) as
      SELECT
            tsp.obj#,
            tsp.ts#,
            tsp.pobj#,
            dbms_metadata.get_partn(3,tsp.pobj#,tsp.subpart#)-1,
            tsp.bhiboundval
        FROM tabsubpart$ tsp
/

create or replace force view  ku$_temp_subpartdata_view  of ku$_temp_subpartdata_t
  with object identifier(obj_num) as
        SELECT
              p.obj#,
              sp.ts_num,
              dsp.ts#,
              p.defts#,
              tpo.defts#,
              u.datats#,
              sp.bhiboundval,
              dsp.bhiboundval
        FROM sys.tabcompart$ p, sys.partobj$ tpo,  ku$_temp_subpart_view sp,
             sys.defsubpart$ dsp, sys.obj$ po, sys.obj$ spo, sys.user$ u
        WHERE
             p.bo# = tpo.obj# AND
             p.subpartcnt = MOD(TRUNC(tpo.spare2/65536), 65536) AND
             sp.pobj_num = p.obj# AND
             po.obj# = p.obj# AND
             spo.obj# = sp.obj_num AND
             sp.subpartno = dsp.spart_position AND
             dsp.bo# = p.bo# AND
             u.user# = po.owner# AND
             (spo.subname = (po.subname || '_' || dsp.spart_name) OR
                            (po.subname LIKE 'SYS_P%' AND
                             spo.subname LIKE 'SYS_SUBP%'))
/

create or replace force view ku$_temp_subpartlobfrg_view of
          ku$_temp_subpartlobfrg_t
  with object identifier(obj_num) as
        SELECT
              lf.parentobj#,
              lf.ts#,
              lf.fragobj#,
              row_number() OVER
                 (partition by lf.parentobj# order by lf.frag#) - 1,
              lf.tabfragobj#
        FROM sys.lobfrag$ lf
/

create or replace force view ku$_temp_subpartlob_view of
          ku$_temp_subpartlob_t
  with object identifier(obj_num) as
       SELECT
              tp.obj#,
              lp.defts#,
              lf.ts_num,
              lb.defts#,
              dsp.lob_spart_ts#,
              tsp.ts#
        FROM  sys.tabcompart$ tp, sys.lobcomppart$ lp, sys.partlob$ lb,
              sys.ku$_temp_subpartlobfrg_view lf, sys.defsubpartlob$ dsp,
              sys.obj$ lspo, sys.obj$ tpo, sys.tabsubpart$ tsp
        WHERE
              lp.tabpartobj# = tp.obj# AND
              lp.lobj# = lb.lobj# and
              lf.obj_num = lp.partobj# AND
              dsp.bo# = tp.bo# and
              dsp.intcol# = lb.intcol# AND
              lspo.obj# = lf.fragobj_num AND
              tpo.obj# = tp.obj# AND
              (lspo.subname = tpo.subname || '_' || dsp.lob_spart_name OR
               (tpo.subname LIKE 'SYS_P%' AND lspo.subname
                                 LIKE 'SYS_LOB_SUBP%')) AND
              dsp.spart_position = lf.frag_num AND
              tsp.obj# = lf.tabfragobj_num
     UNION   -- ALL
        SELECT tp.obj#,
               lp.defts#,
               lf.ts_num,
               lb.defts#,
               NULL,
               tsp.ts#
        FROM sys.tabcompart$ tp, sys.lobcomppart$ lp, sys.partlob$ lb,
             sys.ku$_temp_subpartlobfrg_view lf, sys.obj$ lspo, sys.obj$ tpo,
             sys.tabsubpart$ tsp
        WHERE lp.tabpartobj# = tp.obj# AND
              lp.lobj# = lb.lobj# AND
              lf.obj_num = lp.partobj# AND
              lb.intcol# NOT IN
                (SELECT distinct dsp.intcol#
                  FROM sys.defsubpartlob$ dsp
                  WHERE dsp.bo# = tp.bo#) AND
              lspo.obj# = lf.fragobj_num AND
              tpo.obj# = tp.obj# AND
              lspo.subname LIKE 'SYS_LOB_SUBP%' AND
              tsp.obj# = lf.tabfragobj_num
/

-------------------------------------------------------------------------------
--                              ILM POLICIES
-------------------------------------------------------------------------------

-- policy view for table
create or replace force view ku$_ilm_policy_view of ku$_ilm_policy_t
  with object OID(obj_num,policy_num) as
  select o.obj#, o.obj_typ, o.obj_typ_orig, o.policy#, o.flag,
         p.actionc, 
         p.ctype, p.clevel, p.cindex, p.cprefix, p.clevlob,
         p.tier_tbs, p.action, p.type, p.condition, p.days, p.scope,
         p.custfunc, p.flag, p.flag2, p.spare1, p.spare2,
         p.spare3, p.spare4, p.spare5, p.spare6,
         p.pol_subtype, p.actionc_clob, p.tier_to
  from sys.ilmpolicy$ p, sys.ilmobj$ o
  where p.policy#=o.policy#
/

-- policy view for tablespace
create or replace force view ku$_ilm_policy_view2 of ku$_ilm_policy_t
  with object OID(obj_num,policy_num) as
  select t.ts#, null, null, t.policy#, t.flag,
         p.actionc, p.ctype, p.clevel, p.cindex, p.cprefix, p.clevlob,
         p.tier_tbs, p.action, p.type, p.condition, p.days, p.scope,
         p.custfunc, p.flag, p.flag2, p.spare1, p.spare2,
         p.spare3, p.spare4, p.spare5, p.spare6,
         p.pol_subtype, p.actionc_clob, p.tier_to
  from sys.ilmpolicy$ p, sys.ilm$ t
  where p.policy#=t.policy#
/

create or replace force view ku$_tbs_ilm_policy_view of ku$_tbs_ilm_policy_t
  with object OID(ts_num) as
  select t.ts#,t.name,
         cast( multiset(select * from ku$_ilm_policy_view2 p
                        where p.obj_num = t.ts#
                        order by p.policy_num
                        ) as ku$_ilm_policy_list_t
              )
 from ts$ t
 where exists (select 1 from ku$_ilm_policy_view2 p where p.obj_num = t.ts#)
   and (SYS_CONTEXT('USERENV','CURRENT_USERID') = 0
        OR EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

-------------------------------------------------------------------------------
--                              NESTED TABLE PARTITION
-------------------------------------------------------------------------------

-- view for table partition data for partitioned heap nested table partition
create or replace force view ku$_hntp_view
  of ku$_hntp_t with object identifier(obj_num) as
  select tp.obj#, t.property,
        (select value(s) from ku$_storage_view s
         where     tp.file#  = s.file_num
             and   tp.block# = s.block_num
             and   tp.ts#    = s.ts_num),
        (select value(s) from ku$_deferred_stg_view s
         where s.obj_num = tp.obj#),
        (select ts.name from ts$ ts where tp.ts# = ts.ts#),
        (select ts.blocksize from ts$ ts where tp.ts# = ts.ts#),
        tp.pctfree$, tp.pctused$, tp.initrans, tp.maxtrans, tp.flags
  from tabpart$ tp, tab$ t
  where tp.bo# = t.obj# and
        bitand(t.property,64+512) = 0 -- skip IOT and overflow segs
/

-- view for nested table partition
create or replace force view ku$_ntpart_view
  of ku$_ntpart_t with object identifier(obj_num) as
  select
                nt.obj#, 
                dbms_metadata.get_partn(1,ntp.bo#,ntp.part#),
                nt.intcol#, nt.ntab#,
                (select value(o) from ku$_schemaobj_view o
                 where o.obj_num = ntp.obj#),
                (select value(c) from ku$_simple_col_view c
                 where c.obj_num = nt.obj#
                 and   c.intcol_num = nt.intcol#),
                (select t.property from tab$ t where t.obj# = nt.ntab#),
                (select ct.flags from coltype$ ct
                        where ct.obj# = nt.obj#
                        and   ct.intcol# = nt.intcol#),
                (select value(hntp) from ku$_hntp_view hntp
                 where hntp.obj_num = ntp.obj#)
            from ntab$ nt,
               tabpart$ ntp
            where ntp.bo#=nt.ntab#
/

-- view for collection of nested table partitions of a parent table
create or replace force view ku$_ntpart_parent_view
  of ku$_ntpart_parent_t with object identifier(obj_num) as
  select t.obj#,dbms_metadata.get_partn(1,tp.bo#,tp.part#),
    cast(multiset(select
                      obj_num,
                      part_num,
                      intcol_num,
                      ntab_num,
                      schema_obj,
                      col,
                      property,
                      flags,
                      hnt
            from  ku$_ntpart_view  ntp
            where ntp.part_num=dbms_metadata.get_partn(1,tp.bo#,tp.part#) and
                  ntp.obj_num in (
                    select obj# from ntab$ nt
                      start with nt.obj#=t.obj#
                        connect by prior nt.ntab#=nt.obj#)
                ) as ku$_ntpart_list_t
        )
  from tab$ t, tabpart$ tp
  where tp.bo# = t.obj# and
        bitand(t.property,32+4) = 32+4 -- has nested tables, and is partitioned
/

-------------------------------------------------------------------------------
-- for external tables
-------------------------------------------------------------------------------

create or replace force view ku$_exttab_view of ku$_exttab_t
  with object OID(obj_num)
  as select
        et.obj#,
        et.default_dir,
        et.type$,
        et.nr_locations,
        et.reject_limit,
        et.par_type,
        et.param_clob,
        et.property,
        cast( multiset(select el.obj#, el.position, el.dir, el.name
                       from   sys.external_location$ el
                       where  el.obj# = et.obj#
                       order by el.obj#,el.position
                      ) as ku$_extloc_list_t
              )
      from sys.external_tab$ et
/

-------------------------------------------------------------------------------
--                              PARTITIONS
-------------------------------------------------------------------------------

-- view for index partitions
create or replace force view ku$_ind_part_view of ku$_ind_part_t
  with object identifier(obj_num) as
  select ip.obj#,
         (select value(so) from ku$_schemaobj_view so
          where so.obj_num = ip.obj#),
         ts.ts#, ts.name, ts.blocksize,
         (select value(s) from ku$_storage_view s
          where ip.ts# = s.ts_num
          AND ip.file# = s.file_num
          AND ip.block# = s.block_num),
         (select value(s) from ku$_deferred_stg_view s
          where s.obj_num = ip.obj#),
         ip.dataobj#,
--part only
         ip.bo#, ip.part#,
         (select tpo.subname
           from obj$ tpo, tabpart$ tp, ind$ i
           where i.obj#=ip.bo# and
                 tp.bo#=i.bo# and
                 tp.part#=ip.part# and
                 tpo.obj#=tp.obj#),
         ip.hiboundlen,
         case
           when ip.hiboundlen is null or ip.hiboundlen > 4000
           then null
           else
             sys.dbms_metadata_util.long2varchar(ip.hiboundlen,
                                        'SYS.INDPART$',
                                        'HIBOUNDVAL',
                                         ip.rowid)
         end,
         case
           when ip.hiboundlen is null or ip.hiboundlen <= 4000
           then null
           else
             sys.dbms_metadata_util.long2clob(ip.hiboundlen,
                                        'SYS.INDPART$',
                                        'HIBOUNDVAL',
                                         ip.rowid)
         end,
         ip.pctthres$,
         ip.inclcol,
         (select decode(bitand(ipp.flags, 1), 1, ipp.parameters, null)
            from indpart_param$ ipp
          where ipp.obj#=ip.obj#),
--subpart only
         null,null,null,
--both
         ip.flags, ip.pctfree$,
         ip.initrans, ip.maxtrans,
         to_char(ip.analyzetime,'YYYY/MM/DD HH24:MI:SS'), ip.samplesize,
         ip.rowcnt, ip.blevel, ip.leafcnt, ip.distkey, ip.lblkkey,
         ip.dblkkey, ip.clufac, ip.spare1, ip.spare2, ip.spare3
  from  indpart$ ip, ts$ ts
  where ts.ts#=ip.ts#
/

-- view for PIOT partitions
create or replace force view ku$_piot_part_view of ku$_piot_part_t
  with object identifier(obj_num) as
  select ip.obj#,
         (select value(so) from ku$_schemaobj_view so
          where so.obj_num = ip.obj#),
         ts.name, ts.blocksize,
         (select value(s) from ku$_storage_view s
          where ip.file#  = s.file_num
          and   ip.block# = s.block_num
          and   ip.ts#    = s.ts_num),
         (select value(s) from ku$_deferred_stg_view s
          where s.obj_num = ip.obj#),
         ip.dataobj#, ip.bo#,
         dbms_metadata.get_partn(4,ip.bo#,ip.part#),
         ip.hiboundlen,
         case
           when ip.hiboundlen is null or ip.hiboundlen > 4000
           then null
           else
             sys.dbms_metadata_util.long2varchar(ip.hiboundlen,
                                        'SYS.INDPART$',
                                        'HIBOUNDVAL',
                                         ip.rowid)
         end,
         case
           when ip.hiboundlen is null or ip.hiboundlen <= 4000
           then null
           else
             sys.dbms_metadata_util.long2clob(ip.hiboundlen,
                                        'SYS.INDPART$',
                                        'HIBOUNDVAL',
                                         ip.rowid)
         end,
         cast(multiset(select lf.* from ind$ i, ku$_piotlobfrag_view lf
                        where lf.part_num=
                                dbms_metadata.get_partn(4,ip.bo#,ip.part#)
                          and ip.bo#=i.obj# and i.bo#=lf.base_obj_num
                        order by lf.intcol_num
                      ) as ku$_lobfrag_list_t
             ),
         ip.flags, 
         (select tp.flags from ind$ i, tabpart$ tp 
          where ip.bo#=i.obj# and tp.bo#=i.bo# and tp.part#=ip.part#),
         ip.pctfree$, ip.pctthres$,
         ip.initrans, ip.maxtrans,
         to_char(ip.analyzetime,'YYYY/MM/DD HH24:MI:SS'), ip.samplesize,
         ip.rowcnt, ip.blevel, ip.leafcnt, ip.distkey, ip.lblkkey,
         ip.dblkkey, ip.clufac, ip.spare1, ip.spare2, ip.spare3,
         ip.inclcol
  from  indpart$ ip, ts$ ts
  where ip.ts# = ts.ts#
/

-- view for table partitions
create or replace force view ku$_tab_part_view of ku$_tab_part_t
  with object identifier(obj_num) as
  select tp.obj#, value(o),
         ts.name, ts.blocksize,
         (select value(s) from ku$_storage_view s
          where tp.file#  = s.file_num
          and   tp.block# = s.block_num
          and   tp.ts#    = s.ts_num),
         (select value(s) from ku$_deferred_stg_view s
          where s.obj_num = tp.obj#),
         tp.dataobj#, tp.bo#,
         dbms_metadata.get_partn(1,tp.bo#,tp.part#), 
         tp.hiboundlen,
         case
           when tp.hiboundlen is null or tp.hiboundlen > 4000
           then null
           else
             sys.dbms_metadata_util.long2varchar(tp.hiboundlen,
                                        'SYS.TABPART$',
                                        'HIBOUNDVAL',
                                         tp.rowid)
         end,
         case
           when tp.hiboundlen is null or tp.hiboundlen <= 4000
           then null
           else
             sys.dbms_metadata_util.long2clob(tp.hiboundlen,
                                        'SYS.TABPART$',
                                        'HIBOUNDVAL',
                                         tp.rowid)
         end,
         cast(multiset(select * from ku$_lobfrag_view lf
                        where lf.part_obj_num=tp.obj#
                        order by lf.intcol_num
                      ) as ku$_lobfrag_list_t
             ),
         (select value(ntp) from ku$_ntpart_parent_view ntp
          where ntp.obj_num = tp.bo# and 
                ntp.part_num=(dbms_metadata.get_partn(1,tp.bo#,tp.part#))),
         cast( multiset(select * from ku$_ilm_policy_view p
                        where p.obj_num = tp.obj#
                        order by p.policy_num
                        ) as ku$_ilm_policy_list_t
              ),
         tp.pctfree$, tp.pctused$, tp.initrans,
         tp.maxtrans, tp.flags,
         to_char(tp.analyzetime,'YYYY/MM/DD HH24:MI:SS'),
         tp.samplesize, tp.rowcnt,
         tp.blkcnt, tp.empcnt, tp.avgspc, tp.chncnt, tp.avgrln, tp.spare1,
         tp.spare2, tp.spare3,
         bhiboundval,
         tp.part#,   -- <<< be carefull! this is 'physical' partition number
         (select value(etv) from ku$_exttab_view etv
                        where etv.obj_num = tp.obj#),
         (select svcname  from imsvc$ svc 
                 where svc.obj# = tp.obj# and svc.subpart# is null),
         (select svcflags from imsvc$ svc 
                 where svc.obj# = tp.obj# and svc.subpart# is null)
  from ku$_schemaobj_view o, tabpart$ tp, ts$ ts
  where tp.obj# = o.obj_num
        AND tp.ts# = ts.ts#
/

-- view for table subpartitions
create or replace force view ku$_tab_subpart_view of ku$_tab_subpart_t
  with object identifier(obj_num) as
  select tsp.obj#, value(o),
         ts.name, ts.blocksize,
         (select value(s) from ku$_storage_view s
          where tsp.file#  = s.file_num
          and   tsp.block# = s.block_num
          and   tsp.ts#    = s.ts_num),
         (select value(s) from ku$_deferred_stg_view s
          where s.obj_num = tsp.obj#),
         tsp.dataobj#,
         tsp.pobj#,
         dbms_metadata.get_partn(3,tsp.pobj#,tsp.subpart#),
         cast(multiset(select * from ku$_sublobfrag_view lf
                        where lf.part_obj_num=tsp.obj#
                        order by lf.intcol_num
                      ) as ku$_lobfrag_list_t
             ),
         cast( multiset(select * from ku$_ilm_policy_view p
                        where p.obj_num = tsp.obj#
                        order by p.policy_num
                        ) as ku$_ilm_policy_list_t
              ),
         tsp.flags, tsp.pctfree$, tsp.pctused$,
         tsp.initrans, tsp.maxtrans,
         to_char(tsp.analyzetime,'YYYY/MM/DD HH24:MI:SS'), tsp.samplesize,
         tsp.rowcnt, tsp.blkcnt, tsp.empcnt, tsp.avgspc, tsp.chncnt,
         tsp.avgrln, tsp.spare1, tsp.spare2, tsp.spare3, tsp.hiboundlen,
         case
           when tsp.hiboundlen is null or tsp.hiboundlen > 4000
           then null
           else
             sys.dbms_metadata_util.long2varchar(tsp.hiboundlen,
                                        'SYS.TABSUBPART$',
                                        'HIBOUNDVAL',
                                         tsp.rowid)
         end,
         case
           when tsp.hiboundlen is null or tsp.hiboundlen <= 4000
           then null
           else
             sys.dbms_metadata_util.long2clob(tsp.hiboundlen,
                                        'SYS.TABSUBPART$',
                                        'HIBOUNDVAL',
                                         tsp.rowid)
         end,
         tsp.bhiboundval,
         tsp.subpart#,   -- <<< be carefull! 'physical' subpartition number
         (select svcname  from imsvc$ svc
                 where svc.obj# = tsp.obj# and svc.subpart# is null),
         (select svcflags from imsvc$ svc
                 where svc.obj# = tsp.obj# and svc.subpart# is null),
         (select value(etv) from ku$_exttab_view etv
                        where etv.obj_num = tsp.obj#)
  from ku$_schemaobj_view o, tabsubpart$ tsp, ts$ ts
  where tsp.obj# = o.obj_num
        AND tsp.ts# = ts.ts#
/

-- view for table template subpartitions

create or replace force view ku$_tab_tsubpart_view of ku$_tab_tsubpart_t
  with object identifier (base_objnum,spart_name,spart_pos) as
  select  dsp.bo#, dsp.spart_position, dsp.spart_name,
          (select( ts.name) from sys.ts$ ts where ts.ts# = dsp.ts#),
          dsp.ts#,
          bitand(dsp.flags, 4294967295),      /* FLAGS<31:0>  */
          trunc(dsp.flags / power(2, 32)),    /* FLAGS<63:32> */
          dsp.hiboundlen,
          case
            when dsp.hiboundlen is null or dsp.hiboundlen > 4000
            then null
            else
              sys.dbms_metadata_util.long2varchar(dsp.hiboundlen,
                                         'SYS.DEFSUBPART$',
                                         'HIBOUNDVAL',
                                          dsp.rowid)
          end,
          case
            when dsp.hiboundlen is null or dsp.hiboundlen <= 4000
            then null
            else
              sys.dbms_metadata_util.long2clob(dsp.hiboundlen,
                                         'SYS.DEFSUBPART$',
                                         'HIBOUNDVAL',
                                          dsp.rowid)
          end,
          cast(multiset(select * from ku$_tlob_comppart_view tlcv
                        where  tlcv.base_objnum = dsp.bo#
                           and tlcv.spart_pos = dsp.spart_position
                        order by tlcv.intcol_num
                      ) as ku$_tlob_comppart_list_t),
          bhiboundval,
         (select svcname  from imsvc$ svc
               where svc.obj# = dsp.bo# and svc.subpart# = dsp.spart_position),
         (select svcflags from imsvc$ svc
               where svc.obj# = dsp.bo# and svc.subpart# = dsp.spart_position)
  from    sys.defsubpart$ dsp
/

-- view for table composite partitions
create or replace force view ku$_tab_compart_view of ku$_tab_compart_t
  with object identifier(obj_num) as
  select tcp.obj#, value(o), tcp.dataobj#, tcp.bo#,
         dbms_metadata.get_partn(2,tcp.bo#,tcp.part#),
         tcp.hiboundlen,
         case
           when tcp.hiboundlen is null or tcp.hiboundlen > 4000
           then null
           else
             sys.dbms_metadata_util.long2varchar(tcp.hiboundlen,
                                        'SYS.TABCOMPART$',
                                        'HIBOUNDVAL',
                                         tcp.rowid)
         end,
         case
           when tcp.hiboundlen is null or tcp.hiboundlen <= 4000
           then null
           else
             sys.dbms_metadata_util.long2clob(tcp.hiboundlen,
                                        'SYS.TABCOMPART$',
                                        'HIBOUNDVAL',
                                         tcp.rowid)
         end,
         cast( multiset(select * from ku$_ilm_policy_view p
                                 where p.obj_num = tcp.obj#
                                 order by p.policy_num
                                  ) as ku$_ilm_policy_list_t
             ), 
         tcp.subpartcnt,
         sys.dbms_metadata.check_match_template_par(tcp.obj#, tcp.subpartcnt),
         cast(multiset(select * from ku$_tab_subpart_view tsp
                       where tsp.pobj_num = tcp.obj#
                       order by tsp.subpart_num
                      ) as ku$_tab_subpart_list_t
                  ),
         sys.dbms_metadata.check_match_template_lob(tcp.obj#, tcp.subpartcnt),
         cast(multiset(select * from ku$_lobcomppart_view lc
                       where lc.part_obj_num = tcp.obj#
                        order by lc.intcol_num
                      ) as ku$_lobcomppart_list_t
                  ),
         tcp.flags, ts.name, ts.blocksize,
         tcp.defpctfree, tcp.defpctused, tcp.definitrans,
         tcp.defmaxtrans, tcp.definiexts, tcp.defextsize, tcp.defminexts,
         tcp.defmaxexts, tcp.defextpct, tcp.deflists, tcp.defgroups,
         tcp.deflogging, tcp.defbufpool, to_char(tcp.analyzetime,'YYYY/MM/DD HH24:MI:SS'), tcp.samplesize,
         tcp.rowcnt, tcp.blkcnt, tcp.empcnt, tcp.avgspc, tcp.chncnt,
         tcp.avgrln, tcp.spare1,
         -- Convert 'spare2' to a value that the pre-11.2 xsl stylesheet
         -- can process: if archive compressed and version < 11.2,
         -- turn off compression.  The block format for archive compression
         -- is not supported pre-11.2, so the compression bits must be
         -- set to NOCOMPRESS.
         case when bitand(tcp.spare2,8+16+32+64)=0 then tcp.spare2
              when dbms_metadata.get_version >= '11.02.00.00.00'
                   then tcp.spare2
              else 2
         end,
         tcp.spare3, tcp.defmaxsize,
         tcp.bhiboundval,
         (select svcname  from imsvc$ svc
                 where svc.obj# = tcp.obj# and svc.subpart# is null),
         (select svcflags from imsvc$ svc
                 where svc.obj# = tcp.obj# and svc.subpart# is null),
         (select value(etv) from ku$_exttab_view etv
                 where etv.obj_num = tcp.obj#)
  from ku$_schemaobj_view o, tabcompart$ tcp, ts$ ts
  where tcp.obj# = o.obj_num
        AND tcp.defts# = ts.ts#
/

-- view for index subpartitions
create or replace force view ku$_ind_subpart_view of ku$_ind_part_t
  with object identifier(obj_num) as
  select isp.obj#,
         (select value(so) from ku$_schemaobj_view so
          where so.obj_num = isp.obj#),
         ts.ts#, ts.name, ts.blocksize,
         (select value(s) from ku$_storage_view s
          where isp.ts# = s.ts_num
          AND isp.file# = s.file_num
          AND isp.block# = s.block_num),
         (select value(s) from ku$_deferred_stg_view s
          where s.obj_num = isp.obj#),
         isp.dataobj#,
--part only
         null,null,null, null,null,null, null,null,null,
--subpart only
         isp.pobj#, 
         isp.subpart#,
         (select /*+ ordered index_rs_asc(icp i_indcompart_bopart$)
                     push_pred(tcp) push_pred(tsp) */
              tspo.subname
            from indcompart$ icp, ind$ i, tabcompart$ tcp,
                 tabsubpart$ tsp, obj$ tspo
            where icp.obj#=opart.obj# and
                  icp.bo#=iobj.obj# and
                  i.obj#=icp.bo# and
                  tcp.bo#=i.bo# and
                  tcp.part#=icp.part# and
                  tsp.pobj#=tcp.obj# and
                  tsp.subpart#=isp.subpart# and
                  tspo.obj#=tsp.obj#),
--both
         isp.flags, isp.pctfree$, isp.initrans,
         isp.maxtrans, to_char(isp.analyzetime,'YYYY/MM/DD HH24:MI:SS'),
         isp.samplesize, isp.rowcnt,
         isp.blevel, isp.leafcnt, isp.distkey, isp.lblkkey, isp.dblkkey,
         isp.clufac, isp.spare1, isp.spare2, isp.spare3
  from indsubpart$ isp, ts$ ts, obj$ opart, obj$ iobj 
  where isp.ts# = ts.ts# and
        opart.obj#=isp.pobj# and
        iobj.name=opart.name and
        iobj.type#=1 and
        iobj.owner#=opart.owner#
/

-- view for index composite partitions
create or replace force view ku$_ind_compart_view of ku$_ind_compart_t
  with object identifier(obj_num) as
  select icp.obj#, value(o), icp.dataobj#, icp.bo#, 
         icp.part#,
         icp.hiboundlen,
         case
           when icp.hiboundlen is null or icp.hiboundlen > 4000
           then null
           else
             sys.dbms_metadata_util.long2varchar(icp.hiboundlen,
                                        'SYS.INDCOMPART$',
                                        'HIBOUNDVAL',
                                         icp.rowid)
         end,
         case
           when icp.hiboundlen is null or icp.hiboundlen <= 4000
           then null
           else
             sys.dbms_metadata_util.long2clob(icp.hiboundlen,
                                        'SYS.INDCOMPART$',
                                        'HIBOUNDVAL',
                                         icp.rowid)
         end,
         icp.subpartcnt,
         cast(multiset(select
           OBJ_NUM, SCHEMA_OBJ, TS_NUM, TS_NAME, BLOCKSIZE, 
           STORAGE, DEFERRED_STG,
           DATAOBJ_NUM, BASE_OBJ_NUM, PART_NUM, TAB_PART_NAME, 
           HIBOUNDLEN, HIBOUNDVAL, NULL, PCT_THRES,  --remove HIBOUNDVALC
           INCLCOL, PARAMETERS, POBJ_NUM, SUBPART_NUM, TAB_SUBPART_NAME,
           FLAGS, PCT_FREE, INITRANS, MAXTRANS, ANALYZETIME, SAMPLESIZE, 
           ROWCNT, BLEVEL, LEAFCNT, DISTKEY, LBLKKEY, DBLKKEY, CLUFAC,
           SPARE1, SPARE2, SPARE3 
                       from ku$_ind_subpart_view isp
                       where isp.pobj_num = icp.obj#
                       order by isp.subpart_num
                      ) as ku$_ind_part_list_t
             ),
          icp.flags,
          -- hoist the next 2 queries up here because icp.defts# may be null
          -- and this avoids an outer join which is slooooow
          (select ts.name from ts$ ts where icp.defts# = ts.ts#),
          (select ts.blocksize from ts$ ts where icp.defts# = ts.ts#),
          icp.defpctfree, icp.definitrans,
          icp.defmaxtrans, icp.definiexts, icp.defextsize, icp.defminexts,
          icp.defmaxexts, icp.defextpct, icp.deflists, icp.defgroups,
          icp.deflogging, icp.defbufpool, to_char(icp.analyzetime,'YYYY/MM/DD HH24:MI:SS'), icp.samplesize,
          icp.rowcnt, icp.blevel, icp.leafcnt, icp.distkey, icp.lblkkey,
          icp.dblkkey, icp.clufac, icp.spare1, icp.spare2, icp.spare3,
          icp.defmaxsize
  from ku$_schemaobj_view o, indcompart$ icp
  where icp.obj# = o.obj_num
/

-- view for table partitioning columns

create or replace force view ku$_tab_part_col_view of
  ku$_part_col_t with object identifier (obj_num, intcol_num) as
  select pc.obj#, pc.intcol#, value(c), pc.pos#, pc.spare1
  from ku$_simple_col_view c, partcol$ pc
  where   pc.obj#=c.obj_num
  and     pc.intcol#=c.intcol_num
/

-- view for table subpartitioning columns. Based on tabsubpart$. Also uses
-- ku$_part_col_t.

create or replace force view ku$_tab_subpart_col_view of
  ku$_part_col_t with object identifier(obj_num, intcol_num) as
  select sc.obj#, sc.intcol#, value(c), sc.pos#, sc.spare1
  from ku$_simple_col_view c, subpartcol$ sc
  where  sc.obj#=c.obj_num
  and    sc.intcol#=c.intcol_num
/

-- view for index partitioning columns

create or replace force view ku$_ind_part_col_view of
  ku$_part_col_t with object identifier (obj_num, intcol_num) as
  select pc.obj#, pc.intcol#, value(c), pc.pos#, pc.spare1
  from ku$_simple_col_view c, ind$ i, partcol$ pc
  where   pc.obj#=i.obj#
  and     i.bo#=c.obj_num
  and     pc.intcol#=c.intcol_num
/

-- view for index subpartitioning columns. Based on tabsubpart$. Also uses
-- ku$_part_col_t.

create or replace force view ku$_ind_subpart_col_view of
  ku$_part_col_t with object identifier(obj_num, intcol_num) as
  select sc.obj#, sc.intcol#, value(c), sc.pos#, sc.spare1
  from ku$_simple_col_view c, ind$ i, subpartcol$ sc
  where  sc.obj#=i.obj#
  and    i.bo#=c.obj_num
  and    sc.intcol#=c.intcol_num
/

-- view for the store-in clause for interval partitioned tables.
-- see dpart.bsq
create or replace force view ku$_insert_ts_view of
  ku$_insert_ts_t with object identifier (base_obj_num,position_num) as
  select itl.bo#, itl.position#, itl.ts#, ts.name
  from sys.ts$ ts, sys.insert_tsn_list$ itl
  where ts.ts#=itl.ts#
/

-- view for partitioned objects
create or replace force view ku$_partobj_view
  of ku$_partobj_t with object identifier (obj_num) as
  select po.obj#, po.parttype, po.partcnt,
         po.partkeycols,
         po.flags,
         -- hoist the next 2 queries up here because po.defts# may be null
         -- and this avoids an outer join which is slooooow
         (select ts.name from ts$ ts where po.defts# = ts.ts#),
         (select ts.blocksize from ts$ ts where po.defts# = ts.ts#),
         po.defpctfree, po.defpctused, po.defpctthres,
         po.definitrans, po.defmaxtrans, po.deftiniexts, po.defextsize,
         po.defminexts, po.defmaxexts, po.defextpct, po.deflists,
         po.defgroups, po.deflogging, po.spare1,
         -- Convert 'spare2' to a value that the pre-11.2 xsl stylesheet
         -- can process: if archive compressed and version < 11.2,
         -- turn off compression.  The block format for archive compression
         -- is not supported pre-11.2, so the compression bits must be
         -- set to NOCOMPRESS.
         -- also, exclude inmemory flags from exported 'spare2', as the flags
         -- value would excede the range xsl div/mod can handle. IMC flags
         -- are bytes 5 and above.
         case when (bitand(floor(po.spare2/power(2, 32)),8+16+32+64)=0) or
                   (dbms_metadata.get_version >= '11.02.00.00.00')
                then bitand(po.spare2, power(2, 40)-1)
              else bitand(po.spare2, power(2, 32)-1) + 2*power(2, 32)
         end,
         trunc(po.spare2 / power(2, 40)),
         po.spare3,
         po.definclcol, po.parameters,
         po.interval_str, po.interval_bival,
         -- Get list of tablespaces for STORE IN of interval and autolist part.
         case when (po.interval_str is not null) or
                   (po.parttype = 4 and bitand(po.flags,64) > 0) then
          cast( multiset( select * from ku$_insert_ts_view it
                          where it.base_obj_num=po.obj#
                          order by it.base_obj_num,it.position_num
                        ) as ku$_insert_ts_list_t
              )
         else null end,
         po.defmaxsize,
         po.subptn_interval_str, po.subptn_interval_bival,
         (select svcname  from imsvc$ svc
                 where svc.obj# = po.obj# and svc.subpart# is null),
         (select svcflags from imsvc$ svc
                 where svc.obj# = po.obj# and svc.subpart# is null)
  from partobj$ po
/

-- view for partitioned tables
create or replace force view ku$_tab_partobj_view
  of ku$_tab_partobj_t with object identifier (obj_num) as
  select po.obj_num, value(po),
         cast(multiset(select * from ku$_tab_part_col_view pc
                       where pc.obj_num = po.obj_num
                        order by pc.pos_num
                      ) as ku$_part_col_list_t
             ),
         cast(multiset(select * from ku$_tab_subpart_col_view sc
                       where sc.obj_num = po.obj_num
                        order by sc.pos_num
                      ) as ku$_part_col_list_t
             ),
         cast(multiset(select * from ku$_tab_part_view tp
                       where tp.base_obj_num = po.obj_num
                        order by tp.part_num
                      ) as ku$_tab_part_list_t
             ),
         cast(multiset(select * from ku$_tab_compart_view tcp
                       where tcp.base_obj_num = po.obj_num
                        order by tcp.part_num
                      ) as ku$_tab_compart_list_t
             ),
         cast(multiset(select * from ku$_tab_tsubpart_view ttsp
                       where ttsp.base_objnum = po.obj_num
                        order by ttsp.spart_pos
                      ) as ku$_tab_tsubpart_list_t
             )
  from ku$_partobj_view po
/

-- view for partitioned indexes;
create or replace force view ku$_ind_partobj_view
  of ku$_ind_partobj_t with object identifier (obj_num) as
  select po.obj_num, value(po),
         cast(multiset(select * from ku$_ind_part_col_view pc
                       where pc.obj_num = i.obj#
                        order by pc.pos_num
                      ) as ku$_part_col_list_t
             ),
         cast(multiset(select * from ku$_ind_subpart_col_view sc
                       where sc.obj_num = i.obj#
                        order by sc.pos_num
                      ) as ku$_part_col_list_t
             ),
         cast(multiset(select * from ku$_ind_part_view ip
                       where ip.base_obj_num = po.obj_num
                        order by ip.part_num
                      ) as ku$_ind_part_list_t
             ),
         cast(multiset(select * from ku$_ind_compart_view icp
                       where icp.base_obj_num = po.obj_num
                        order by icp.part_num
                      ) as ku$_ind_compart_list_t
             )
  from ind$ i, ku$_partobj_view po
        where i.obj#=po.obj_num
/

-------------------------------------------------------------------------------
--                              DOMAIN INDEX
-------------------------------------------------------------------------------
-- view for domain index's secondary tables
create or replace force view ku$_domidx_2ndtab_view of ku$_domidx_2ndtab_t
  with object identifier (obj_num, secobj_num) as
  select s.obj#, s.secobj#, value(o)
  from sys.ku$_schemaobj_view o, sys.secobj$ s
  where o.obj_num = s.secobj#
    and o.type_num = 2
    and dbms_metadata.oktoexp_2ndary_table(s.secobj#)!= 0
/

-- view to get good tablespace info for partitioned tables
--  tab$.ts# is not initialized for partitioned tables.
create or replace force view ku$_ptable_ts_view ( obj_num, ts_num )
 as select t.obj#,dbms_metadata_util.table_tsnum(t.obj#)
 from tab$ t
/

-- The next view is used by dbms_metadata.oktoexp_2ndary_table

-- Bug 16918087: Add 'distinct' to the 'UNION ALL' part of the query to 
-- eliminate duplicates which occur when partitioning with a spatial index.
-- This occurs when an export is imported whereby subsequent exports raise 
-- error ORA-39127 due to duplicates returned in that part of the query.
--   Bug 5730708 Was raised to address the issue of duplicates appearing in
--   secobj$ but was closed as duplicates could not be reproduced.
--   Bug 5515882 Addressed the issue of duplicates in the non-partition part of
--   the query effectively masking the real issue of duplicates there.
create or replace force view ku$_2ndtab_info_view (
  obj_num, index_name, index_schema, type_name, type_schema, ts_num,
  interface_vrsn, flags ) as
  select distinct
        o.obj#,
        o1.name,
        u1.name,
        o2.name,
        u2.name,
        ptts.ts_num,
        it.interface_version#,
        0
   from obj$ o, obj$ o1, obj$ o2, ind$ i, user$ u1, user$ u2, indtypes$ it,
        tab$ t, secobj$ s, ku$_ptable_ts_view ptts
   where o.obj#=s.secobj#
         AND o.obj#=t.obj#
         AND ptts.obj_num = o.obj#
         AND o1.obj#=s.obj#
         AND o1.obj# = i.obj#
         AND i.type# = 9
         AND o1.owner# = u1.user#
         AND i.indmethod# = it.obj#
         AND o2.obj# = it.implobj#
         AND o2.owner# = u2.user#
         AND bitand(i.property, 2) != 2         /* non-partitioned */
   UNION ALL
  select distinct
        o.obj#,
        o1.name,
        u1.name,
        o2.name,
        u2.name,
        ptts.ts_num,
        it.interface_version#,
        DECODE(BITAND (i.property, 512), 512, 64,0)+   /*0x200=iot di*/
        DECODE(BITAND(po.flags, 1), 1, 1, 0) +          /* 1 = local */
        DECODE(po.parttype, 1, 2, 2, 4, 0)    /* 1 = range, 2 = hash */
   from obj$ o, obj$ o1, obj$ o2, ind$ i, user$ u1, user$ u2,
        partobj$ po, indtypes$ it, tab$ t, secobj$ s, ku$_ptable_ts_view ptts
   where o.obj#=s.secobj#
         AND o.obj#=t.obj#
         AND ptts.obj_num = o.obj#
         AND o1.obj#=s.obj#
         AND o1.obj# = i.obj#
         AND i.type# = 9
         AND o1.owner# = u1.user#
         AND i.indmethod# = it.obj#
         AND o2.obj# = it.implobj#
         AND o2.owner# = u2.user#
         AND bitand(po.flags, 8) = 8            /* domain index */
         AND po.obj# = i.obj#
         AND bitand(i.property, 2) = 2          /* partitioned */
/

-- view for domain index plsql code
--  Note: bug-19386381
--   The domain index may not have storage (either allocated or deferred),
--   in particular, spacial domain indexes do not. So, it the index TS# is zero
--   (which may mean storage in SYSTEM, or no storage), we look for the parent
--   table tablespace. The TS# is used to determine if the domain index is 
--   moved using transportable. As transportable tablespace must be a closed 
--   set, any tablespace# for index or parent table is sufficient.
create or replace force view ku$_domidx_plsql_view of ku$_domidx_plsql_t
  with object identifier(obj_num) as
  select i.obj#,
        sys.dbms_metadata.get_domidx_metadata(o.name, u.name,
                o2.name, u2.name,
                case when i.ts#!=0 then i.ts#
                     when bitand((select t.property from tab$ t 
                                  where t.obj#=i.bo#),32) = 0
                      then (select t.ts# from tab$ t where t.obj#=i.bo#)
                     else dbms_metadata_util.table_tsnum(i.bo#)
                end,
                it.interface_version#, 0)
   from obj$ o, obj$ o2, ind$ i, user$ u, user$ u2, indtypes$ it
   where i.type# = 9
         AND o.obj# = i.obj#
         AND o.owner# = u.user#
         AND i.indmethod# = it.obj#
         AND o2.obj# = it.implobj#
         AND o2.owner# = u2.user#
         AND bitand(i.property, 2) != 2         /* non-partitioned */
   UNION ALL
  select i.obj#,
        sys.dbms_metadata.get_domidx_metadata(o.name, u.name,
              o2.name, u2.name, 
              case when i.ts#!=0 then i.ts#
                   when bitand((select t.property from tab$ t 
                                where t.obj#=i.bo#),32) = 0
                    then (select t.ts# from tab$ t where t.obj#=i.bo#)
                   else dbms_metadata_util.table_tsnum(i.bo#)
              end,
              it.interface_version#,
              DECODE(BITAND (i.property, 512), 512, 64,0)+   /*0x200=iot di*/
              DECODE(BITAND(po.flags, 1), 1, 1, 0) +          /* 1 = local */
              DECODE(po.parttype, 1, 2, 2, 4, 0)    /* 1 = range, 2 = hash */
              )
   from obj$ o, obj$ o2, ind$ i, user$ u, user$ u2, partobj$ po,
        indtypes$ it
   where i.type# = 9
         AND o.obj# = i.obj#
         AND o.owner# = u.user#
         AND i.indmethod# = it.obj#
         AND o2.obj# = it.implobj#
         AND o2.owner# = u2.user#
         AND bitand(po.flags, 8) = 8            /* domain index */
         AND po.obj# = i.obj#
         AND bitand(i.property, 2) = 2          /* partitioned */
/

-------------------------------------------------------------------------------
--                              INDEX
-------------------------------------------------------------------------------

-- views for bitmap join index information

create or replace force view ku$_jijoin_table_view of ku$_jijoin_table_t
  with object identifier(obj_num,tabobj_num)
  as select j.obj#, o.obj_num, o.owner_name, o.name
  from sys.ku$_schemaobj_view o, sys.jijoin$ j
  where o.obj_num in (j.tab1obj#, j.tab2obj#)
  group by j.obj#, o.obj_num, o.owner_name, o.name
  order by o.obj_num
/

create or replace force view ku$_jijoin_view of ku$_jijoin_t
  with object identifier(obj_num,tab1obj_num,tab1col_num,tab2obj_num,tab2col_num)
  as select j.obj#, j.tab1obj#, j.tab1col#, j.tab2obj#, j.tab2col#,
            (select value(c) from sys.ku$_simple_col_view c
             where c.obj_num = j.tab1obj# and c.intcol_num = j.tab1col#),
            (select value(c) from sys.ku$_simple_col_view c
             where c.obj_num = j.tab2obj# and c.intcol_num = j.tab2col#),
            j.joinop, j.flags, j.tab1inst#, tab2inst#
  from sys.jijoin$ j
  order by j.tab1obj#, j.tab1col#
/

-------------------------------------------------------------------------------
--                     INDEX_OBJNUM
-------------------------------------------------------------------------------

create or replace force view ku$_index_objnum_view of ku$_index_objnum_t
  with object identifier(obj_num) as
  select i.obj#,
         value(o),
         ts.name, ts.ts#,
         i.type#, i.flags, i.property,
         --  for_pkoid
         nvl((select 1 from cdef$ c
              where c.enabled = i.obj# and
                    c.type# = 2 and
                    (select 1 from tab$ t
                     where t.obj# = c.obj# and
                     bitand(t.property, 4096) = 4096) = 1) ,0),
         --  for_refpar
         nvl((select 1 from dual where
          (exists (select 1 from cdef$ c
              where c.enabled = i.obj# and
                    c.type# in(2, 3) and
                    (bitand(c.defer,1024)!=0)))),0),
         i.bo#,
         (select value(so) from ku$_schemaobj_view so
          where so.obj_num = i.bo#)
  from  ku$_schemaobj_view o, ind$ i, ts$ ts
  where  o.obj_num = i.obj#
         AND  i.ts# = ts.ts#
         AND (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (o.owner_num, 0) OR
              EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/
-------------------------------------------------------------------------------
-- view for indexes
create or replace force view ku$_all_index_view of ku$_index_t
  with object identifier(obj_num) as
  select '1','5',
         i.obj#, value(o),
         cast(multiset(select * from ku$_index_col_view ic
                       where ic.obj_num = i.obj#
                        order by ic.pos_num
                      ) as ku$_index_col_list_t
             ),
         ts.name, ts.blocksize,
         (select value(s) from ku$_storage_view s
          where i.file#  = s.file_num
          and   i.block# = s.block_num
          and   i.ts#    = s.ts_num),
         (select value(s) from ku$_deferred_stg_view s
          where s.obj_num = i.obj#),
         i.dataobj#, i.bo#,
         (select value(so) from ku$_schemaobj_view so
          where so.obj_num = i.bo#),
         (select value(ao) from ku$_schemaobj_view ao
          where ao.obj_num = dbms_metadata_util.get_anc(i.bo#,0)),
         i.indmethod#,
         (select o2.name from obj$ o2 where i.indmethod# = o2.obj#),
         (select u2.name from user$ u2
                where u2.user# = (select o3.owner# from obj$ o3
                                        where i.indmethod# = o3.obj#)),
         -- include domain index info if type# = 9 (cooperative index method)
         decode(i.type#, 9,
           cast(multiset(select * from ku$_domidx_2ndtab_view so
                        where so.obj_num=i.obj#
                        ) as ku$_domidx_2ndtab_list_t
                ),
           null),
         decode(i.type#, 9,
           (select value(pl) from ku$_domidx_plsql_view pl
                where pl.obj_num = i.obj#),
           null),
         -- include bitmap join index info if this is a bji
         decode(bitand(i.property, 1024), 1024,
           cast(multiset(select * from ku$_jijoin_table_view j
                        where j.obj_num = i.obj#
                        ) as ku$_jijoin_table_list_t
                ),
           null),
         decode(bitand(i.property, 1024), 1024,
           cast(multiset(select * from ku$_jijoin_view j
                        where j.obj_num = i.obj#
                        ) as ku$_jijoin_list_t
                ),
           null),
         i.cols, i.pctfree$,
         i.initrans, i.maxtrans, i.pctthres$, i.type#, i.flags, i.property,
         i.blevel, i.leafcnt, i.distkey, i.lblkkey, i.dblkkey, i.clufac,
         to_char(i.analyzetime,'YYYY/MM/DD HH24:MI:SS'), i.samplesize, i.rowcnt, i.intcols, i.degree,
         i.instances, i.trunccnt, i.spare1, i.spare2,
         (select value(po) from ku$_ind_partobj_view po
          where i.obj# = po.obj_num),
         i.spare3, replace(i.spare4, chr(0)), i.spare5, to_char(i.spare6,'YYYY/MM/DD HH24:MI:SS'),
         nvl((select 1 from cdef$ c
              where c.enabled = i.obj# and
                    c.type# = 2 and
                    (select 1 from tab$ t
                     where t.obj# = c.obj# and
                     bitand(t.property, 4096) = 4096) = 1) ,0),
         -- and index is used for reference partitioning if it is used
         --  for a primary or unique key constraint and 0x400 is set in
         --  defer (ref par parent).
         nvl((select 1 from dual where
          (exists (select 1 from cdef$ c
              where c.enabled = i.obj# and
                    c.type# in(2, 3) and
                    (bitand(c.defer,1024)!=0)))),0),
         nvl((select ic.oid_or_setid from ku$_index_col_view ic
              where i.type#=1
              and i.intcols=1
              and ic.obj_num=i.obj#),0),
          nvl((select bitand(t.property, 4294967295)
               from tab$ t where t.obj# = i.bo#),0),
          nvl((select trunc(t.property / power(2, 32))
               from tab$ t where t.obj# = i.bo#),0),
          NULL, NULL, NULL, NULL
   from  ku$_schemaobj_view o, ind$ i, ts$ ts
   where o.obj_num = i.obj#
         AND  i.ts# = ts.ts#
         AND (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (o.owner_num, 0) OR
              EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/
-- p2r/sp2t views for indexes
--spool indexes.sql
--set lines 8000 trimspool on serveroutput on termout off
declare
  stmt             varchar2(10000);
  select_clause    varchar2(1000);
  from_clause      varchar2(1000);
  where_clause     varchar2(1000);
  on_name          varchar2(1000);
  procedure cre_view(vname VARCHAR2) as
    begin
      stmt := q'!
create or replace force view !'||vname||q'! of ku$_index_t
  with object identifier(obj_num) as
  select '1','5',
         i.obj#, value(o),
         cast(multiset(select * from ku$_index_col_view ic
                       where ic.obj_num = i.obj#
                        order by ic.pos_num
                      ) as ku$_index_col_list_t
             ),
         ip.ts_name, ip.blocksize,
         ip.storage, ip.deferred_stg,
         ip.dataobj_num, i.bo#,
         (select value(so) from ku$_schemaobj_view so
          where so.obj_num = i.bo#),
         (select value(ao) from ku$_schemaobj_view ao
          where ao.obj_num = dbms_metadata_util.get_anc(i.bo#,0)),
         i.indmethod#,
         (select o2.name from obj$ o2 where i.indmethod# = o2.obj#),
         (select u2.name from user$ u2
                where u2.user# = (select o3.owner# from obj$ o3
                                        where i.indmethod# = o3.obj#)),
         -- include domain index info if type# = 9 (cooperative index method)
         decode(i.type#, 9,
           cast(multiset(select * from ku$_domidx_2ndtab_view so
                        where so.obj_num=i.obj#
                        ) as ku$_domidx_2ndtab_list_t
                ),
           null),
         decode(i.type#, 9,
           ku$_domidx_plsql_t(
            i.obj#,
            /* modification from ku$_domidx_plsql_view, adding partion name */
            (select 
                  sys.dbms_metadata.get_domidx_metadata(
                    o.name, o.owner_name,
                    o2.name, o2.owner_name, 
                    ip.ts_num, it.interface_version#,
                       /*0x200=iot di*/
                    DECODE(BITAND (i.property, 512), 512, 64,0)+
                       /* 1 = local */
                    DECODE(BITAND(po.flags, 1), 1, 1, 0) + 
                       /* 1 = range, 2 = hash */
                    DECODE(po.parttype, 1, 2, 2, 4, 0),
                    !'||on_name||q'! )
             from ku$_schemaobj_view o2, indtypes$ it
             where i.indmethod# = it.obj#
                   AND o2.obj_num = it.implobj#)),
          null),
         -- include bitmap join index info if this is a bji
         decode(bitand(i.property, 1024), 1024,
           cast(multiset(select * from ku$_jijoin_table_view j
                        where j.obj_num = i.obj#
                        ) as ku$_jijoin_table_list_t
                ),
           null),
         decode(bitand(i.property, 1024), 1024,
           cast(multiset(select * from ku$_jijoin_view j
                        where j.obj_num = i.obj#
                        ) as ku$_jijoin_list_t
                ),
           null),
         i.cols, ip.pct_free,
         ip.initrans, ip.maxtrans, ip.pct_thres, i.type#, 
         -- flags here are index flags, but we the UNUSABLE for the
         --  [sub]partition. Perhaps more flags need to be carried over?
         bitand(i.flags,to_number('FFFFFFFE','XXXXXXXX')) +
          bitand(ip.flags,1),
         -- we clear the 'partitioned' property
         i.property-(bitand(i.property,2)),
         i.blevel, i.leafcnt, i.distkey, i.lblkkey, i.dblkkey, i.clufac,
         to_char(i.analyzetime,'YYYY/MM/DD HH24:MI:SS'), i.samplesize, i.rowcnt, i.intcols, i.degree,
         i.instances, i.trunccnt, i.spare1, i.spare2,
         NULL, -- part_obj (ind_partobj_t) for partitioned indexes
--         (select value(po) from ku$_ind_partobj_view po
--          where i.obj# = po.obj_num),
         i.spare3, replace(i.spare4, chr(0)), i.spare5, to_char(i.spare6,'YYYY/MM/DD HH24:MI:SS'),
         nvl((select 1 from cdef$ c
              where c.enabled = i.obj# and
                    c.type# = 2 and
                    (select 1 from tab$ t
                     where t.obj# = c.obj# and
                     bitand(t.property, 4096) = 4096) = 1) ,0),
         -- and index is used for reference partitioning if it is used
         --  for a primary or unique key constraint and 0x400 is set in
         --  defer (ref par parent).
         nvl((select 1 from dual where
          (exists (select 1 from cdef$ c
              where c.enabled = i.obj# and
                    c.type# in(2, 3) and
                    (bitand(c.defer,1024)!=0)))),0),
         nvl((select ic.oid_or_setid from ku$_index_col_view ic
              where i.type#=1
              and i.intcols=1
              and ic.obj_num=i.obj#),0),
          nvl((select bitand(t.property, 4294967295)
               from tab$ t where t.obj# = i.bo#),0),
          nvl((select trunc(t.property / power(2, 32))
               from tab$ t where t.obj# = i.bo#),0),
         !'||select_clause||q'!
   from  ku$_schemaobj_view o, ind$ i, ts$ ts, ku$_partobj_view po,
         !'||from_clause||q'!
   where o.obj_num = i.obj#
         AND i.obj#=po.obj_num
         !'||where_clause||q'!
         AND  i.ts# = ts.ts#
         AND (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (o.owner_num, 0) OR
              EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))!';
      -- The folowing (put_line) can be very helpful in debug, but fails
      -- if execution is attemted during DB create (dbms_output not available)
      --   so enable as needed!
--      dbms_output.put_line('.. 
--'||stmt);
      execute immediate stmt;
    end;
begin
  -- index_partition_view
  select_clause := 'value(ip), null, ip.obj_num,null';
  from_clause := 'ku$_ind_part_view ip';
  where_clause := 'AND ip.base_obj_num = po.obj_num';
  on_name := 'NULL';
  cre_view('ku$_index_partition_view');
  -- index_subpartition_view
  select_clause := 'null, value(ip),
                (select tsp.obj#
                     from  ind$ i, tabcompart$ tcp, tabsubpart$ tsp
                     where i.obj#=icp.bo# and
                           tcp.bo#=i.bo# and tcp.part#=icp.part# and
                           tsp.pobj#=tcp.obj# and 
                           tsp.subpart#=ip.subpart_num ),null';
  from_clause := 'ku$_ind_subpart_view ip, indcompart$ icp ';
  where_clause := 'AND ip.pobj_num = icp.obj# 
         AND icp.bo# = po.obj_num';
  on_name := 'NULL';
  cre_view('ku$_index_subpartition_view');
  -- domain_index_partition_view
  select_clause := 'value(ip), null, ip.obj_num,onn.name';
  from_clause := 'ku$_ind_part_view ip,'||
                 ' TABLE(DBMS_METADATA.FETCH_OBJNUMS_NAMES) onn';
  where_clause := 'AND i.obj# = onn.obj_num AND '||
                  'ip.schema_obj.subname = onn.name AND '||
                  'ip.base_obj_num = po.obj_num';
  on_name := 'onn.name';
  cre_view('ku$_domidx_partition_view');
end;
/
--spool off
--set lines 80 serveroutput off  termout on

-- For 11g, allow func. indexes to be exported along with mv
create or replace force view ku$_index_view of ku$_index_t
  with object identifier(obj_num) as
    select * from ku$_all_index_view
/

-- For 10.2, restrict func. indexes from being exported along with mv
create or replace force view ku$_10_2_index_view of ku$_index_t
  with object identifier(obj_num) as
    select * from ku$_all_index_view i
        where  BITAND(i.property, 8208) != 8208      /* remove Fn Ind on MV */
/

-------------------------------------------------------------------------------
--                              CONSTRAINTS
-------------------------------------------------------------------------------
-- view to get columns in a constraint.
create or replace force view ku$_constraint_col_view of ku$_constraint_col_t
  with object identifier (obj_num,intcol_num) as
  select cc.con#, cc.obj#, cc.intcol#, cc.pos#, cc.spare1,
  decode(bitand(c.property,1024+2),0,0,2,1,1024,2,0),
  decode(bitand(c.property,2097152+1024),
         2097152,(select value(c1) from ku$_simple_pkref_col_view c1
                  where c1.obj_num    = cc.obj# and
                        c1.intcol_num = cc.intcol#),
            1024,(select value(c2) from ku$_simple_setid_col_view c2
                  where c2.obj_num    = cc.obj# and
                        c2.intcol_num = cc.intcol#),
            value(c))
  from ku$_simple_col_view c, ccol$ cc
  where c.obj_num    = cc.obj#
    and c.intcol_num = cc.intcol#
/

-- view for inmemory selective column
create or replace force view ku$_im_colsel_view of ku$_im_colsel_t
   with object identifier(obj_num, column_name) as
   select   obj_num, inst_id, column_name, inmemory_compression, con_id
   from sys.v$im_column_level
   where inmemory_compression != 'DEFAULT' 
     and inmemory_compression != 'UNSPECIFIED'
/

-- views for constraints
-- Non keyed constraints.
create or replace force view ku$_constraint0_view of ku$_constraint0_t
   with object identifier(con_num) as
   select c.owner#, c.name, c.con#, cd.obj#, cd.cols, cd.type#,
          NVL(cd.enabled,0),
          cd.intcols, to_char(cd.mtime,'YYYY/MM/DD HH24:MI:SS'), cd.defer
   from con$ c, cdef$ cd
   where c.con# = cd.con#
     and cd.type# in (5,6,7,11)  -- view WITH CHECK OPTION (5)
                                 -- view WITH READ ONLY (6)
                               -- NOT NULL on built-in datatyped column (7)
                               -- NOT NULL on ADT column (11)
/

-- Keyed (one key list or a condition) constraints.
-- includes index metadata for primary key and unique constraints.
create or replace force view ku$_constraint1_view of ku$_constraint1_t
   with object identifier(con_num) as
   select c.owner#, c.name, c.con#, cd.obj#,
          nvl((select bitand(t.property, 4294967295)
               from tab$ t where t.obj# = cd.obj#),0),
          nvl((select trunc(t.property / power(2, 32))
               from tab$ t where t.obj# = cd.obj#),0),
          nvl((select trunc(t.property / power(2, 64))
               from tab$ t where t.obj# = cd.obj#),0),
          cd.cols, cd.type#,
          nvl(cd.enabled,0),
          cd.condlength,
          sys.dbms_metadata_util.long2clob(cd.condlength,
                                        'SYS.CDEF$',
                                        'CONDITION',
                                        cd.rowid),
          case when cd.type#=1 then
            (select sys.dbms_metadata.parse_condition(
                                SYS_CONTEXT('USERENV','CURRENT_USERID'),
                                u.name, o.name, cd.condlength,cd.rowid)
             from obj$ o, user$ u
             where o.obj#=cd.obj# and o.owner#=u.user#)
          else null end,
          cd.intcols, to_char(cd.mtime,'YYYY/MM/DD HH24:MI:SS'), nvl(cd.defer,0),
          nvl((select cc.oid_or_setid
               from ku$_constraint_col_view cc
                 where cd.type#=3
                 and cd.intcols=1
                 and cc.con_num=cd.con#),0),
          cast( multiset(select * from ku$_constraint_col_view col
                        where col.con_num = c.con#
                        order by col.pos_num
                        ) as ku$_constraint_col_list_t
                ),
          ( select value(i) from ku$_all_index_view i
                where i.obj_num=cd.enabled )
--              where i.schema_obj.owner_num=c.owner#
--                and i.schema_obj.name=c.name )
   from  con$ c, cdef$ cd
   where c.con# = cd.con#
     and cd.type# in (1,2,3,12,14,15,16,17)
                               -- table check (condition-no keys) (1),
                               -- primary key (2),
                               -- unique key (3),
                               -- supplemental log groups (w/ keys) (12),
                               -- supplemental log data (no keys) (14,15,16,17)
/

-- Keyed constraints - 2 views created here...
--  for partition/subpartition export to import as a table (p2t/sp2t)
--  use separate component views for constraints with/without (partitioned) 
--  indexes
declare
  stmt             varchar2(10000);
  procedure cre_view(vname VARCHAR2, tname VARCHAR2) as
    begin
      stmt := q'!
create or replace force view !'||vname||q'! of ku$_constraint1_t
   with object identifier(con_num) as
   select c.owner#, c.name, c.con#, cd.obj#,
          nvl((select bitand(t.property, 4294967295)
               from tab$ t where t.obj# = cd.obj#),0),
          nvl((select trunc(t.property / power(2, 32))
               from tab$ t where t.obj# = cd.obj#),0),
          nvl((select trunc(t.property / power(2, 64))
               from tab$ t where t.obj# = cd.obj#),0),
          cd.cols, cd.type#,
          nvl(cd.enabled,0),
          cd.condlength,
          sys.dbms_metadata_util.long2clob(cd.condlength,
                                        'SYS.CDEF$',
                                        'CONDITION',
                                        cd.rowid),
          case when cd.type#=1 then
            (select sys.dbms_metadata.parse_condition(
                                SYS_CONTEXT('USERENV','CURRENT_USERID'),
                                u.name, o.name, cd.condlength,cd.rowid)
             from obj$ o, user$ u
             where o.obj#=cd.obj# and o.owner#=u.user#)
          else null end,
          cd.intcols, to_char(cd.mtime,'YYYY/MM/DD HH24:MI:SS'),
          -- cd.defer becomes <FLAGS>. We clear flags for refpar parent/child
          --  as we are cresating a non-ppartitioned table
          nvl((cd.defer-bitand(cd.defer,512+1024)),0),
          nvl((select cc.oid_or_setid
               from ku$_constraint_col_view cc
                 where cd.type#=3
                 and cd.intcols=1
                 and cc.con_num=cd.con#),0),
          cast( multiset(select * from ku$_constraint_col_view col
                        where col.con_num = c.con#
                        order by col.pos_num
                        ) as ku$_constraint_col_list_t
                ),
          value(i)
   from  con$ c, cdef$ cd, !'||tname||q'! i
   where c.con# = cd.con#
         and i.obj_num=cd.enabled
     and cd.type# in (2,3)     -- primary key (2) and unique key (3)
!';
      -- The folowing (put_line) can be very helpful in debug, but fails
      -- if execution is attemted during DB create (dbms_output not available)
      --   so enable as needed!
      --dbms_output.put_line('.. '||stmt);
      execute immediate stmt;
    end;
begin
  cre_view('ku$_p2t_con1a_view',  'ku$_index_partition_view');
  cre_view('ku$_sp2t_con1a_view', 'ku$_index_subpartition_view');
end;
/
-- type1 constraints other than primary key (2) and unique key (3)
--  (that is, constraints without indexes)
create or replace force view ku$_p2t_con1b_view of ku$_constraint1_t
   with object identifier(con_num) as
   select * 
   from  ku$_constraint1_view cv
   where cv.contype not in (2,3)
                               -- table check (condition-no keys) (1),
                               -- supplemental log groups (w/ keys) (12),
                               -- supplemental log data (no keys) (14,15,16,17)
/
create or replace force view ku$_p2t_constraint1_view of ku$_constraint1_t
   with object identifier(con_num) as
    select * from  ku$_p2t_con1a_view 
  UNION ALL
    select * from  ku$_p2t_con1b_view 
/

-- type1 constraints other than primary key (2) and unique key (3)
--  (that is, constraints without indexes) use ku$_p2t_con1b_view
create or replace force view ku$_sp2t_constraint1_view of ku$_constraint1_t
   with object identifier(con_num) as
    select * from  ku$_sp2t_con1a_view 
  UNION ALL
    select * from  ku$_p2t_con1b_view 
/

-- Referential constraints
declare
  stmt             varchar2(10000);
  procedure cre_view(vname VARCHAR2, flags VARCHAR2) as
    begin
      stmt := q'!
create or replace force view !'||vname||q'! of ku$_constraint2_t
   with object identifier(con_num) as
   select c.owner#, c.name, c.con#, cd.obj#, cd.cols, cd.type#,
          cd.robj#, cd.rcon#, cd.rrules, cd.match#, cd.refact,
          NVL(cd.enabled,0),
          cd.intcols, to_char(cd.mtime,'YYYY/MM/DD HH24:MI:SS'),
          !'||flags||q'!, -- cd.defer becomes <FLAGS>. 
          (select value(o) from ku$_schemaobj_view o
                where o.obj_num = cd.robj#),
          cast( multiset(select * from ku$_constraint_col_view col
                        where col.con_num = c.con#
                        order by col.pos_num
                        ) as ku$_constraint_col_list_t
                ),
          cast( multiset(select * from ku$_constraint_col_view col
                        where col.con_num = cd.rcon#
                        order by col.pos_num
                        ) as ku$_constraint_col_list_t
                )
   from con$ c, cdef$ cd
   where c.con# = cd.con#
     and cd.type# = 4           -- referential constraint
!';
      -- The folowing (put_line) can be very helpful in debug, but fails
      -- if execution is attemted during DB create (dbms_output not available)
      --   so enable as needed!
      --dbms_output.put_line('.. '||stmt);
      execute immediate stmt;
    end;
begin
  cre_view('ku$_constraint2_view','nvl(cd.defer,0)');
  -- for P2T Referential constraints we clear flags for refpar parent/child
  --  as we are cresating a non-ppartitioned table
  cre_view('ku$_p2t_constraint2_view','nvl((cd.defer-bitand(cd.defer,512+1024)),0)');
end;
/

-- REF/pkREF constraints
create or replace force view ku$_pkref_constraint_view
 of ku$_pkref_constraint_t with object identifier(obj_num, intcol_num) as
 select rf.obj#, rf.col#, rf.intcol#, rf.reftyp, c.property, c.name,
        (select a.name from attrcol$ a
                 where a.obj#=rf.obj# and a.intcol#=rf.intcol#),
        (select value(o) from ku$_schemaobj_view o, obj$ oo
                 where rf.stabid = oo.oid$
                    and oo.obj#  = o.obj_num),
        nvl((select 1
             from coltype$ fct, ccol$ fcc, cdef$ fcd
             where fct.obj# = rf.obj# and
                   fct.intcol# = rf.intcol# and
                   fcc.obj# = rf.obj# and
                   fcc.intcol# =
                     UTL_RAW.CAST_TO_BINARY_INTEGER(
                       SUBSTRB(fct.intcol#s, 1, 2), 3) and
                   fcd.con# = fcc.con# and
                   fcd.type# = 4), 0),
        decode(bitand(rf.reftyp,4),
                       4, cast(multiset
                                (select rc.*
                                 from   ku$_simple_col_view rc, ccol$ rcc
                                 where  rcc.con# =
                                            (select con#
                                             from   obj$ ro, cdef$ rcd
                                             where  ro.oid$ = rf.stabid and
                                                    rcd.obj# = ro.obj# and
                                                    rcd.type# = 2)       and
                                          rc.obj_num = rcc.obj# and
                                          rc.intcol_num = rcc.intcol#
                                  order by rcc.pos#
                                ) as ku$_simple_col_list_t),
                       null)
 from refcon$ rf, col$ c
 where c.obj#=rf.obj# and c.intcol#=rf.intcol#
/

create or replace force view ku$_constraint_view
  of ku$_constraint_t with object identifier(con_num) as
  select '1', '2',
         c.con#,
         u.name,
         c.name, cd.defer, cd.type#, cd.obj#,
         (select value(sov) from ku$_schemaobj_view sov
          where sov.obj_num=cd.obj#),
         (select value(col) from ku$_simple_col_view col, sys.ccol$ cc
          where col.obj_num=cd.obj#
          and cc.obj#=cd.obj#
          and cc.con#=c.con#
          and cc.intcol#=col.intcol_num
          and cd.type# in (7,11)             /* not null constr*/
          and (bitand(col.property,1+32)=0 /* not adt attr and hidden col */
           or (col.col_num=0))),  /* Fetch metadata of invisible column */
         (select value(con) from ku$_constraint0_view con
          where  con.con_num = c.con#),
         (select value(con) from ku$_constraint1_view con
          where  con.con_num = c.con#)
  from  obj$ o, con$ c, cdef$ cd, user$ u
  where cd.obj# = o.obj# and
        c.con# = cd.con# and
        u.user# = c.owner# and
        cd.type# in (1,2,3,7,11,12,14,15,16,17)
                                   -- table check (1), primary key (2),
                                   -- unique key (3),
                                   -- not null (7),
                                   -- ref/udt col with not-null (11),
                                   -- supplemental log groups (12),
                                   -- supplemental log data (14,15,16,17)
        AND (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (u.user#, 0)
        OR EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

-- For stand alone (ALTER TABLE) referential (foreign key) constraints
create or replace force view ku$_ref_constraint_view
  of ku$_ref_constraint_t with object identifier(con_num) as
  select '1', '1',
         c.con#,
         u.name,
         c.name, cd.defer, cd.obj#,
         (select value(sov) from ku$_schemaobj_view sov
          where sov.obj_num=cd.obj#),
         value(con)
  from  obj$ o, con$ c, cdef$ cd, user$ u,
        ku$_constraint2_view con
  where cd.obj# = o.obj# and
        c.con# = cd.con# and
        u.user# = c.owner# and
        con.con_num = c.con# and
        (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (u.user#, 0)
        OR EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

-- Import: Get hidden id constraints - name needed for ENABLE
create or replace force view ku$_find_hidden_cons_view(
con_num, constr_name, owner_name, table_name, segcol_num)
 as  select  cd.con#, cn.name, u.name, o.name, c.segcol#
  from    sys.obj$ o, sys.user$ u, sys.con$ cn, sys.ccol$ cc,
          sys.cdef$ cd, sys.col$ c
  where   cd.type#=3
          and cd.intcols=1
          and cn.con#=cd.con#
          and cc.con#=cd.con#
          and c.obj#=cd.obj#
          and c.intcol#=cc.intcol#
          and BITAND(c.property,1026)!=0
          and o.obj#=cd.obj#
          and u.user# = cn.owner#
          and (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (u.user#, 0) OR
                 EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

---
-------------------------------------------------------------------------------
--                              Identity Columns
-------------------------------------------------------------------------------
-- Sequence view definition specific for identity columns:
--   We can not use the ku$_sequence_view because when fetching sequence
--   metadata we need to exclude the seqs related to identity columns and
--   yet we need the sequence info for identity columns. This view is used
--   from table and identity object type collections.
create or replace force view  ku$_idcol_seq_view of ku$_sequence_t
  with object OID(obj_num)
  as select '1','1',
         s.obj#, value(o), 
         s.increment$, TO_CHAR(s.minvalue), TO_CHAR(s.maxvalue),
         s.cycle#, s.order$, s.cache, 
         TO_CHAR(s.highwater),  replace(s.audit$,chr(0),'-'), s.flags
  from  sys.ku$_schemaobj_view o, sys.seq$ s
  where s.obj# = o.obj_num AND
        (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (o.owner_num, 0) OR 
         EXISTS ( SELECT * FROM sys.session_roles 
                  WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/
grant read on ku$_idcol_seq_view to public
/

-- Identity column view definition. Used in table and identity_column object
-- type collections.
create or replace force view  ku$_identity_col_view of ku$_identity_col_t
  with object OID(obj_num)
  as select '1','1',
         obj#,
         (select name from col$ c where c.obj#=s.obj# and c.intcol#=s.intcol#),
         (select trunc(c.property / power(2,32)) 
          from col$ c where c.obj#=s.obj# and c.intcol#=s.intcol#),
         intcol#,
         seqobj#,
         startwith,
         (select value(sv) from ku$_idcol_seq_view sv where obj_num=s.seqobj#)
  from idnseq$ s
/
grant read on ku$_identity_col_view to public
/

-- IDENTITY_COLUMN object type view definition
create or replace force view ku$_identity_colobj_view of ku$_identity_colobj_t 
  with object identifier (obj_num)
  as select '2','5',
    t.obj#, 
    value(o),
    bitand(t.property, 4294967295),
    trunc(t.property / power(2, 32)),
    (select value(i) from ku$_identity_col_view i
                     where i.obj_num = t.obj#)
from ku$_schemaobj_view o, tab$ t
where  t.obj# = o.obj_num
        AND (bitand(t.property, 288230376151711744)!=0)
        AND (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (o.owner_num, 0) OR 
                EXISTS ( SELECT * FROM sys.session_roles 
                         WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/
grant read on ku$_identity_colobj_view to public
/
---
-------------------------------------------------------------------------------
--                              PRIMITIVE COLUMNS
-------------------------------------------------------------------------------
-- moved to catmetviews_mig.sql
alter view ku$_prim_column_view compile;

-------------------------------------------------------------------------------
--                              TYPED COLUMNS
-------------------------------------------------------------------------------

create or replace force view ku$_subcoltype_view of ku$_subcoltype_t
  with object identifier (obj_num,intcol_num,toid) as
  select sct.obj#, sct.intcol#,
         sct.toid,
         value(o),           /* always get schema object */
         t.version#,
         sys.dbms_metadata.get_hashcode(o.owner_name,o.name),
         t.typeid,
         sct.intcols, sct.intcol#s, sct.flags
    from ku$_schemaobj_view o, type$ t, subcoltype$ sct
    where o.oid=sct.toid
      and o.oid=t.toid
      and t.toid=t.tvoid     /* only the latest type */
/

-- BUG 15922287: use ku$_edition_schemaobj_view instead of ku$_schemaobj_view
-- for HASHCODE, HAS_TSTZ & SCHEMA_OBJ 
-- to resolve ORA-01427: single-row subquery returns more than one row.
create or replace force view ku$_coltype_view
  of ku$_coltype_t with object identifier(obj_num, intcol_num) as
  select ct.obj#, ct.col#, ct.intcol#, ct.flags, ct.toid,
         ct.version#, ct.packed, ct.intcols, ct.intcol#s,
         (select sys.dbms_metadata.get_hashcode(o.owner_name,o.name)
                 from ku$_edition_schemaobj_view o, obj$ oo
                 where ct.toid = oo.oid$
                 and o.obj_num = oo.obj#),
         (select sys.dbms_metadata_util.has_tstz_elements(o.owner_name,o.name)
                 from ku$_edition_schemaobj_view o, obj$ oo
                 where ct.toid = oo.oid$
                 and o.obj_num = oo.obj#),
         ct.typidcol#, ct.synobj#,
         (select sy.name from obj$ sy where sy.obj#=ct.synobj#),
         (select u.name from user$ u, obj$ o
          where o.obj#=ct.synobj# and u.user#=o.owner#),
         /* look up stuff in subcoltype$ only if column is substitutable */
         decode(bitand(ct.flags, 512), 512,
           cast(multiset(select sct.* from ku$_subcoltype_view sct
                where ct.obj#    = sct.obj_num
                and   ct.intcol# = sct.intcol_num
                       ) as ku$_subcoltype_list_t
                ),
           null),
        (select value(o) from ku$_edition_schemaobj_view o, obj$ oo
         where ct.toid = oo.oid$
         and o.obj_num = oo.obj#),
        -- If column is opaque and has internal columns, check for unpacked 
        --  anydata type 
        case when ((bitand(ct.flags, 16384)=16384) and (ct.intcols>0)) then
             (select dbms_metadata_util.get_anydata_colset(ct.obj#, ct.col#,
                                             ct.intcols,ct.intcol#s) from dual)
        else null end
    from coltype$ ct
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

-- fake object view
-- Need to specify a clob (versus NULL for the clobs, else an ora-00932
-- error occurs if you try to do a select of stripped_val or schema_val from
-- this view before xdb is installed. It works fine after xdb is installed.

create or replace force view ku$_xmlschema_view of ku$_xmlschema_t
  with object identifier (owner_name, url) as
  select '1','0', 0, NULL, NULL, NULL, 0, 0, et.param_clob, et.param_clob
    from dual, sys.external_tab$ et where 1=0
/

create or replace force view ku$_exp_xmlschema_view of ku$_xmlschema_t
  with object identifier (owner_name, url) as
  select '1','0', 0, NULL, NULL, NULL, 0, 0, et.param_clob, et.param_clob
    from dual, sys.external_tab$ et where 1=0
/

-- fake object view

create or replace force view ku$_xmlschema_elmt_view 
  of ku$_xmlschema_elmt_t with object identifier(schemaoid, elemnum) as
  select NULL, null, NULL, NULL, 0, NULL
    from dual where 1=0
/

-- Special view with xml document for a dummy xmlschema which is used by
-- Data Pump import and the metadata API to generate a special
-- registerschema call with bind arguments, versus the standard call
-- with the .xsd document as a string. This is necessary to handle .xsd
-- documents which exceed 32kb in size.

create or replace force view ku$_xmlschema_special_view as select
'<?xml version="1.0"?><ROWSET><ROW> <XMLSCHEMA_T> <VERS_MAJOR>1</VERS_MAJOR> <VERS_MINOR>0 </VERS_MINOR> </XMLSCHEMA_T> </ROW></ROWSET>'
xmlschema_xml_doc from dual
/

-- view for opaque type
create or replace force view ku$_opqtype_view of ku$_opqtype_t
  with object identifier(obj_num, intcol_num) as
  select opq.obj#, opq.intcol#, opq.type,
-- if KKDOOPQF_BIN_DOM_IDX is set, it means that the column was created 
-- during create index operation. Before I propaged KKDOOPQF_BINARY and
-- KKDOOPQF_LOB in kdic, opq.flags in this type of columns was 0, 
-- but it created a problem in datapump, to avoid this problem, 
-- clear flags when KKDOOPQF_BIN_DOM_IDX is enabled fixs the problem
         decode(bitand(opq.flags,65536), 65536, 0, opq.flags) flags, 
         opq.lobcol, opq.objcol, opq.extracol, opq.schemaoid, opq.elemnum,
         decode(bitand(opq.flags,2),0,NULL,
           (select value (xe) from ku$_xmlschema_elmt_view xe
                where opq.schemaoid = xe.schemaoid
                  and opq.elemnum   = xe.elemnum
                  and opq.obj#      = xe.obj_num
                  and opq.intcol#   = xe.intcol_num))
  from sys.opqtype$ opq
/

-------------------------------------------------------------------------------
-- datapump support for 12c project 32006 
-- Realtime Application-controlled Data Masking (RADM)
-------------------------------------------------------------------------------

-- object-view for the 'RADM_POLICY_EXPR' homogeneous type,
create or replace force view ku$_radm_policy_expr_view of ku$_radm_policy_expr_t
  with object identifier (obj_num) as
  select '1','0',
         rpe.pe#, 
         rpe.pe_obj#,
         rpe.pe_name,
         rpe.pe_pexpr,
         rpe.pe_version,
         rpe.pe_descrip,
         rpe.pe_compat,
         rpe.pe_spare1,
         rpe.pe_spare2,
         rpe.pe_spare3,
         rpe.pe_spare4,
         rpe.pe_spare5,
         rpe.pe_spare6
  from sys.radm_pe$ rpe
  where rpe.pe_name is not null and
        (SYS_CONTEXT('USERENV','CURRENT_USERID')=0 OR
        EXISTS ( SELECT * FROM sys.session_roles
                 WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

-- object-view for the 'RADM_MC' homogeneous type,
-- part of 'RADM_POLICY_T' as a list,
-- representing the column specific information for data masking policies 
-- supplied by means of the ALTER_POLICY api.

create or replace force view ku$_radm_mc_view of ku$_radm_mc_t
  with object identifier (obj_num, intcol_num) as
  select '1','0',
         m.obj#,
         m.intcol#,
         c.name,
         r.pname,
         m.mfunc,
         m.regexp_pattern,
         m.regexp_replace_string,
	 m.regexp_position,
         m.regexp_occurrence,
         m.regexp_match_parameter,
         m.mparams,
         rpe.pe_name
  from sys.radm_mc$ m, sys.radm$ r, col$ c,
       sys.radm_pe$ rpe
  where r.obj# = m.obj#
    and m.pe# = rpe.pe#
    and c.obj# = r.obj#
    and c.intcol# = m.intcol#
/

-- object-view for the 'RADM_POLICY' homogeneous type,
-- xmltag: 'RADM_POLICY_T', XSLT: rdbms/xml/xsl/kuradmp.xsl,
-- representing data masking policies created using DBMS_RADM.ADD_POLICY,
-- and possibly updated using ALTER_POLICY, ENABLE_POLICY, and 
-- DISABLE_POLICY api.

create or replace force view ku$_radm_policy_view of ku$_radm_policy_t
  with object identifier (base_obj_num,pname) as
  select '1','0',
         r.obj#,
         value(o),
         r.pname,
         rpe.pe_pexpr,
         r.enable_flag,
         cast( multiset(select * from ku$_radm_mc_view m
                        where m.obj_num = r.obj#
                       ) as ku$_radm_mc_list_t
             )
  from sys.radm$ r,
       ku$_schemaobj_view o,
       sys.radm_pe$ rpe
  where r.obj# = o.obj_num
    and r.obj# = rpe.pe_obj#
/


-- UDT and object-view for the 'RADM_FPTM' homogeneous type,
-- xmltag: 'RADM_FPTM_T', XSLT: rdbms/xml/xsl/kuradmf.xsl,
-- representing the fixed point values in radm_ftpm$, which are 
-- used to mask the corresponding datatypes.

create or replace force view ku$_radm_fptm_view
  of ku$_radm_fptm_t with object identifier (fpver) as
    select '1','0',
           numbercol, binfloatcol, bindoublecol,
           charcol, varcharcol, ncharcol, nvarcharcol,
           datecol,ts_col,tswtz_col, fpver
    from sys.radm_fptm$
    where fpver=1
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
-- Project 46812: Add ku$_dummy_policy_v, ku$_dummy_policy_obj_r_v,
-- ku$_dummy_policy_obj_c_v, ku$_dummy_policy_owner_v, 
-- ku$_dummy_policy_obj_c_alts_v
-- Bug 21299533: add ku$_dummy_dv_auth_dp_v, ku$_dummy_dv_auth_tts_v,
-- ku$_dummy_dv_auth_job_v, ku$_dummy_dv_auth_proxy_v, ku$_dummy_dv_auth_ddl_v,
-- ku$_dummy_dv_auth_prep_v, ku$_dummy_dv_auth_maint_v, ku$_dummy_dv_oradebug_v,
-- and ku$_dummy_dv_accts_v
-- Add ku$_dummy_dv_auth_diag_v for Diagnostic
-- Add ku$_dummy_dv_index_func_v for Diagnostic
-- Add ku$_dummy_dv_auth_dbcapture_v for DBCAPTURE
-- Add ku$_dummy_dv_auth_dbreplay_v for DBREPLAY
------------------------------------------------------------------------------
-- bug 6938028: Dummy object view for Database Vault Protected Schema.
create or replace force view ku$_dummy_isr_view
       of ku$_dummy_isr_t
  with object identifier (vers_major) as
  select '0','0'
    from dual
   where 1=0      -- return 0 rows, indicating no Import Staging Realm exists
/

-- bug 6938028: Dummy object view for Database Vault Protected Schema.
create or replace force view ku$_dummy_isrm_view
       of ku$_dummy_isrm_t
  with object identifier (vers_major) as
  select '0','0',NULL
    from dual
   where 1=0      -- return 0 rows
/

-- bug 6938028: Dummy object view for Database Vault Protected Schema.
create or replace force view ku$_dummy_realm_view
       of ku$_dummy_realm_t
  with object identifier (vers_major) as
  select '0','0',NULL
    from dual
   where 1=0      -- return 0 rows
/

-- bug 6938028: Dummy object view for Database Vault Protected Schema.
create or replace force view ku$_dummy_realm_member_view
       of ku$_dummy_realm_member_t
  with object identifier (vers_major) as
  select '0','0',NULL
    from dual
   where 1=0      -- return 0 rows
/

-- bug 6938028: Dummy object view for Database Vault Protected Schema.
create or replace force view ku$_dummy_realm_auth_view
       of ku$_dummy_realm_auth_t
  with object identifier (vers_major) as
  select '0','0',NULL
    from dual
   where 1=0      -- return 0 rows
/

-- bug 6938028: Dummy object view for Database Vault Protected Schema.
create or replace force view ku$_dummy_rule_view
       of ku$_dummy_rule_t
  with object identifier (vers_major) as
  select '0','0',NULL
    from dual
   where 1=0      -- return 0 rows
/

-- bug 6938028: Dummy object view for Database Vault Protected Schema.
create or replace force view ku$_dummy_rule_set_view
       of ku$_dummy_rule_set_t
  with object identifier (vers_major) as
  select '0','0',NULL
    from dual
   where 1=0      -- return 0 rows
/

-- bug 6938028: Dummy object view for Database Vault Protected Schema.
create or replace force view ku$_dummy_rule_set_member_view
       of ku$_dummy_rule_set_member_t
  with object identifier (vers_major) as
  select '0','0',NULL
    from dual
   where 1=0      -- return 0 rows
/

-- bug 6938028: Dummy object view for Database Vault Protected Schema.
create or replace force view ku$_dummy_command_rule_view
       of ku$_dummy_command_rule_t
  with object identifier (vers_major) as
  select '0','0',NULL
    from dual
   where 1=0      -- return 0 rows
/

create or replace force view ku$_dummy_comm_rule_alts_v
       of ku$_dummy_comm_rule_alts_t
  with object identifier (vers_major) as
  select '0','0',NULL
    from dual
   where 1=0      -- return 0 rows
/

-- bug 6938028: Dummy object view for Database Vault Protected Schema.
create or replace force view ku$_dummy_role_view
       of ku$_dummy_role_t
  with object identifier (vers_major) as
  select '0','0',NULL
    from dual
   where 1=0      -- return 0 rows
/

-- bug 6938028: Dummy object view for Database Vault Protected Schema.
create or replace force view ku$_dummy_factor_view
       of ku$_dummy_factor_t
  with object identifier (vers_major) as
  select '0','0',NULL
    from dual
   where 1=0      -- return 0 rows
/

-- bug 6938028: Dummy object view for Database Vault Protected Schema.
create or replace force view ku$_dummy_factor_link_view
       of ku$_dummy_factor_link_t
  with object identifier (vers_major) as
  select '0','0',NULL
    from dual
   where 1=0      -- return 0 rows
/

-- bug 6938028: Dummy object view for Database Vault Protected Schema.
create or replace force view ku$_dummy_factor_type_view
       of ku$_dummy_factor_type_t
  with object identifier (vers_major) as
  select '0','0',NULL
    from dual
   where 1=0      -- return 0 rows
/

-- bug 6938028: Dummy object view for Database Vault Protected Schema.
create or replace force view ku$_dummy_identity_view
       of ku$_dummy_identity_t
  with object identifier (vers_major) as
  select '0','0',NULL
    from dual
   where 1=0      -- return 0 rows
/

-- bug 6938028: Dummy object view for Database Vault Protected Schema.
create or replace force view ku$_dummy_identity_map_view
       of ku$_dummy_identity_map_t
  with object identifier (vers_major) as
  select '0','0',NULL
    from dual
   where 1=0      -- return 0 rows
/
-- for DVPS_DV_POLICY
create or replace force view ku$_dummy_policy_v
       of ku$_dummy_policy_t
  with object identifier (vers_major) as
  select '0','0',NULL
    from dual
   where 1=0      -- return 0 rows
/
-- for DVPS_DV_POLICY_OBJ_R
create or replace force view ku$_dummy_policy_obj_r_v
       of ku$_dummy_policy_obj_r_t
  with object identifier (vers_major) as
  select '0','0',NULL
    from dual
   where 1=0      -- return 0 rows
/
-- for DVPS_DV_POLICY_OBJ_C
create or replace force view ku$_dummy_policy_obj_c_v
       of ku$_dummy_policy_obj_c_t
  with object identifier (vers_major) as
  select '0','0',NULL
    from dual
   where 1=0      -- return 0 rows
/
-- for DVPS_DV_POLICY_OWNER
create or replace force view ku$_dummy_policy_owner_v
       of ku$_dummy_policy_owner_t
  with object identifier (vers_major) as
  select '0','0',NULL
    from dual
   where 1=0      -- return 0 rows
/
-- for DVPS_DV_POLICY_OBJ_C_ALTS
create or replace force view ku$_dummy_policy_obj_c_alts_v
       of ku$_dummy_policy_obj_c_alts_t
  with object identifier (vers_major) as
  select '0','0',NULL
    from dual
   where 1=0      -- return 0 rows
/
-- for DVPS_DV_AUTH_DP
create or replace force view ku$_dummy_dv_auth_dp_v
       of ku$_dummy_dv_auth_dp_t
  with object identifier (vers_major) as
  select '0','0',NULL
    from dual
   where 1=0      -- return 0 rows
/
-- for DVPS_DV_AUTH_TTS
create or replace force view ku$_dummy_dv_auth_tts_v
       of ku$_dummy_dv_auth_tts_t
  with object identifier (vers_major) as
  select '0','0',NULL
    from dual
   where 1=0      -- return 0 rows
/
-- for DVPS_DV_AUTH_JOB
create or replace force view ku$_dummy_dv_auth_job_v
       of ku$_dummy_dv_auth_job_t
  with object identifier (vers_major) as
  select '0','0',NULL
    from dual
   where 1=0      -- return 0 rows
/
-- for DVPS_DV_AUTH_PROXY
create or replace force view ku$_dummy_dv_auth_proxy_v
       of ku$_dummy_dv_auth_proxy_t
  with object identifier (vers_major) as
  select '0','0',NULL
    from dual
   where 1=0      -- return 0 rows
/
-- for DVPS_DV_AUTH_DDL
create or replace force view ku$_dummy_dv_auth_ddl_v
       of ku$_dummy_dv_auth_ddl_t
  with object identifier (vers_major) as
  select '0','0',NULL
    from dual
   where 1=0      -- return 0 rows
/
-- for DVPS_DV_AUTH_PREP
create or replace force view ku$_dummy_dv_auth_prep_v
       of ku$_dummy_dv_auth_prep_t
  with object identifier (vers_major) as
  select '0','0',NULL
    from dual
   where 1=0      -- return 0 rows
/
-- for DVPS_DV_AUTH_MAINT
create or replace force view ku$_dummy_dv_auth_maint_v
       of ku$_dummy_dv_auth_maint_t
  with object identifier (vers_major) as
  select '0','0',NULL
    from dual
   where 1=0      -- return 0 rows
/
-- for DVPS_DV_ORADEBUG
create or replace force view ku$_dummy_dv_oradebug_v
       of ku$_dummy_dv_oradebug_t
  with object identifier (vers_major) as
  select '0','0',NULL
    from dual
   where 1=0      -- return 0 rows
/
-- for DVPS_DV_ACCTS
create or replace force view ku$_dummy_dv_accts_v
       of ku$_dummy_dv_accts_t
  with object identifier (vers_major) as
  select '0','0',NULL
    from dual
   where 1=0      -- return 0 rows
/
-- for DVPS_DV_AUTH_DIAG
create or replace force view ku$_dummy_dv_auth_diag_v
       of ku$_dummy_dv_auth_diag_t
  with object identifier (vers_major) as
  select '0','0',NULL
    from dual
   where 1=0      -- return 0 rows
/
-- for DVPS_DV_INDEX_FUNC
create or replace force view ku$_dummy_dv_index_func_v
       of ku$_dummy_dv_index_func_t
  with object identifier (vers_major) as
  select '0','0',NULL
    from dual
   where 1=0      -- return 0 rows
/
-- for DVPS_DV_AUTH_DBCAPTURE
create or replace force view ku$_dummy_dv_auth_dbcapture_v
       of ku$_dummy_dv_auth_dbcapture_t
  with object identifier (vers_major) as
  select '0','0',NULL
    from dual
   where 1=0      -- return 0 rows
/
-- for DVPS_DV_AUTH_DBREPLAY
create or replace force view ku$_dummy_dv_auth_dbreplay_v
       of ku$_dummy_dv_auth_dbreplay_t
  with object identifier (vers_major) as
  select '0','0',NULL
    from dual
   where 1=0      -- return 0 rows
/
-------------------------------------------------------------------------------
--         view to identify xmlschemas for tables 
--          (for tablespace transportable of xmltype tables)
-------------------------------------------------------------------------------
create or replace force view ku$_table_xmlschema_view sharing=none as
  select opq.obj# tabobj_num, opq.schemaoid schemaoid, opq.schemaoid par_oid
  from sys.opqtype$ opq
/

-------------------------------------------------------------------------------
--                              OID INDEX
-------------------------------------------------------------------------------

-- view for OID index (for object tables)
create or replace force view ku$_oidindex_view
  of ku$_oidindex_t with object identifier(obj_num, intcol_num) as
       select i.bo#, ic.intcol#, o.name,
              decode(substr(o.name,1,5),'SYS_C',8,0),     -- mimic constr defer
              ( select value(s)
                from ku$_storage_view s
                where i.file#  = s.file_num
                and   i.block# = s.block_num
                and   i.ts#    = s.ts_num),
              (select value(s) from ku$_deferred_stg_view s
               where s.obj_num = i.obj#),
              ts.name, ts.blocksize,
              i.pctfree$,i.initrans,i.maxtrans
       from   sys.obj$ o, sys.ind$ i, sys.icol$ ic, sys.ts$ ts
       where  i.type# = 1
              and i.intcols = 1
              and ic.obj# = i.obj#
              and ic.intcol# = (select c.intcol#   -- Only 1 OID col per table
                                from sys.col$ c
                                where c.obj#=i.bo#
                                and bitand(c.property,2)=2)
              and o.obj# = i.obj#
              and ts.ts# = i.ts#
/

-------------------------------------------------------------------------------
--                              COLUMNS
-------------------------------------------------------------------------------

--views ku$_column_view and ku$_pcolumn_view moved to catmetviews_mig.sql
alter view ku$_column_view compile;
alter view ku$_pcolumn_view compile;


-------------------------------------------------------------------------------
--                              CLUSTERED TABLE
-------------------------------------------------------------------------------
-- view for table clustering info

create or replace force view ku$_tabcluster_col_view of ku$_simple_col_t
  with object identifier (obj_num,intcol_num) as
  select c.obj#,
         c.col#,
         c.intcol#,
         c.segcol#,
         bitand(c.property, 4294967295),
         trunc(c.property / power(2,32)),
         c.name,
         (select a.name from attrcol$ a where
                        a.obj#=c.obj# and a.intcol#=c.intcol#),
         c.type#,
         c.deflength, '', '', null, null
  from col$ c, col$ cc, tab$ t
  where c.obj#  = t.obj#
    and cc.obj# = t.bobj#
    and cc.segcol# = c.segcol#
/

create or replace force view ku$_tabcluster_view of ku$_tabcluster_t
  with object identifier (obj_num) as
  select t.obj#,
         value(cl),
         cast(multiset(select * from ku$_tabcluster_col_view c
                       where c.obj_num = t.obj#
                        order by c.segcol_num
                      ) as ku$_simple_col_list_t
             )
  from  ku$_schemaobj_view cl, sys.tab$ t
  where bitand(t.property,1024) = 1024          -- clustered table
    and cl.obj_num = t.bobj#
/

-------------------------------------------------------------------------------
--                              TABLE CLUSTERING
-------------------------------------------------------------------------------

-- clustering column
create or replace force view ku$_clstcol_view of ku$_clstcol_t
  with object identifier (obj_num,tabobj_num,intcol_num) as
  select k.clstobj#, k.tabobj#, value(o),
         k.position, k.groupid, c.col#, c.intcol#, c.segcol#,
         bitand(c.property, 4294967295),
         trunc(c.property / power(2,32)),
         c.name, c.type#
    from ku$_schemaobj_view o, col$ c, clstkey$ k
    where k.tabobj#=o.obj_num
      and c.obj#=k.tabobj#
      and c.intcol#=k.intcol#
/

-- clustering join

create or replace force view ku$_clstjoin_view of ku$_clstjoin_t
  with object identifier(obj_num,tab1obj_num,int1col_num,
                                 tab2obj_num,int2col_num)
  as select j.clstobj#, j.tab1obj#, j.int1col#, j.tab2obj#, j.int2col#,
            (select value(o) from sys.ku$_schemaobj_view o
             where o.obj_num = j.tab1obj#),
            (select value(o) from sys.ku$_schemaobj_view o
             where o.obj_num = j.tab2obj#),
            (select value(c) from sys.ku$_simple_col_view c
             where c.obj_num = j.tab1obj# and c.intcol_num = j.int1col#),
            (select value(c) from sys.ku$_simple_col_view c
             where c.obj_num = j.tab2obj# and c.intcol_num = j.int2col#)
  from sys.clstjoin$ j
  order by j.tab1obj#, j.int1col#
/

-- not all tables with clustering have zonemaps,
-- so put the zonemap information in its own view
-- which will return NULL if no zonemap

create or replace force view ku$_clst_zonemap_view of ku$_clst_zonemap_t
  with object identifier (obj_num) as
  select o.obj#, s.sowner, s.tname
  from obj$ o, user$ u, snap$ s
  where o.owner# = u.user#
    and s.mowner = u.name
    and s.master = o.name
    and bitand(s.flag3, 512) = 512                     /* snapshot = zonemap */
/

create or replace force view ku$_clst_view of ku$_clst_t
  with object identifier (obj_num) as
  select k.clstobj#, k.clstfunc, k.flags,
         cast(multiset(select c.* from ku$_clstcol_view c
              where c.obj_num=k.clstobj#
              order by c.position
                       ) as ku$_clstcol_list_t
             ),
         cast(multiset(select * from ku$_clstjoin_view j
               where j.obj_num = k.clstobj#
                        ) as ku$_clstjoin_list_t
             ),
         (select value(z) from ku$_clst_zonemap_view z
          where z.obj_num=k.clstobj#)
  from clst$ k
/

-- used by data pump to export clustering info separately from table
create or replace force view ku$_tabclst_view of ku$_tabclst_t
  with object identifier (base_obj_num) as
  select k.clstobj#, value(o), 
     (select value(cz) from ku$_clst_view cz where cz.obj_num = k.clstobj#)
  from ku$_schemaobj_view o, clst$ k
  where o.obj_num = k.clstobj#
        AND (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (o.owner_num, 0) OR
                EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/
   

-------------------------------------------------------------------------------
--                              NESTED TABLE
-------------------------------------------------------------------------------

-- view for IOT overflow table
create or replace force view ku$_ov_table_view of ku$_ov_table_t
  with object OID(obj_num)
  as select t.obj#, t.dataobj#, t.bobj#,
         (select value(s) from ku$_storage_view s
          where t.file# = s.file_num
          and t.block#  = s.block_num
          and t.ts#     = s.ts_num),
         (select value(s) from ku$_deferred_stg_view s
          where s.obj_num = t.obj#),
         ts.name, ts.blocksize,
         t.pctfree$, t.pctused$, t.initrans, t.maxtrans, t.flags
  from  tab$ t, ts$ ts
  where bitand(t.property,512) = 512
        and t.ts# = ts.ts#
/

-- view for IOT MAPPING table 
create or replace force view ku$_map_table_view of ku$_map_table_t
  with object OID(obj_num)
  as select t.obj#, t.dataobj#, t.bobj#,NULL,
         (select value(s) from ku$_storage_view s
          where t.file# = s.file_num
          and t.block#  = s.block_num
          and t.ts#     = s.ts_num),
         ts.name, ts.blocksize,
         t.pctfree$, t.pctused$, t.initrans, t.maxtrans, t.flags
  from  tab$ t, ts$ ts
  where bitand(t.flags,536870912) = 536870912
        and t.ts# = ts.ts#
/

-- view for table data for heap nested table
create or replace force view ku$_hnt_view
  of ku$_hnt_t with object identifier(obj_num) as
  select t.obj#,
        (select value(po) from ku$_partobj_view po
         where po.obj_num = t.obj#),
         t.property,
        (select value(s) from ku$_storage_view s
         where     t.file#  = s.file_num
             and   t.block# = s.block_num
             and   t.ts#    = s.ts_num),
        (select value(s) from ku$_deferred_stg_view s
         where s.obj_num = t.obj#),
        (select ts.name from ts$ ts where t.ts# = ts.ts#),
        (select ts.blocksize from ts$ ts where t.ts# = ts.ts#),
        t.pctfree$, t.pctused$, t.initrans, t.maxtrans, t.flags,
         cast( multiset(select * from ku$_constraint0_view con
                        where con.obj_num = t.obj#
                        and con.contype not in (7,11)
                       ) as ku$_constraint0_list_t
             ),
         cast( multiset(select * from ku$_constraint1_view con
                        where con.obj_num = t.obj#
                       ) as ku$_constraint1_list_t
             ),
         cast( multiset(select * from ku$_constraint2_view con
                        where con.obj_num = t.obj#
                       ) as ku$_constraint2_list_t
             ),
         cast( multiset(select * from ku$_pkref_constraint_view con
                        where con.obj_num = t.obj#
                       ) as ku$_pkref_constraint_list_t
             )
  from tab$ t where bitand(t.property,64+512) = 0 -- skip IOT and overflow segs
/

-- view for table data for index organized nested table
create or replace force view ku$_iont_view
  of ku$_iont_t with object identifier(obj_num) as
  select t.obj#, t.property,
        (select value(s) from ku$_storage_view s
         where     i.file#  = s.file_num
             and   i.block# = s.block_num
             and   i.ts#    = s.ts_num),
        (select value(s) from ku$_deferred_stg_view s
         where s.obj_num = i.obj#),
        (select ts.name from ts$ ts where i.ts# = ts.ts#),
        (select ts.blocksize from ts$ ts where i.ts# = ts.ts#),
        i.pctfree$, i.initrans, i.maxtrans, t.flags,
        mod(i.pctthres$,256), i.spare2,
        (select c.name from col$ c
                 where c.obj# = i.bo#
                 and   c.col# = i.trunccnt and i.trunccnt != 0),
         cast( multiset(select * from ku$_constraint0_view con
                        where con.obj_num = t.obj#
                        and con.contype not in (7,11)
                       ) as ku$_constraint0_list_t
             ),
         cast( multiset(select * from ku$_constraint1_view con
                        where con.obj_num = t.obj#
                       ) as ku$_constraint1_list_t
             ),
         cast( multiset(select * from ku$_constraint2_view con
                        where con.obj_num = t.obj#
                       ) as ku$_constraint2_list_t
             ),
         cast( multiset(select * from ku$_pkref_constraint_view con
                        where con.obj_num = t.obj#
                       ) as ku$_pkref_constraint_list_t
             ),
        (select value(ov) from ku$_ov_table_view ov
         where ov.bobj_num = t.obj#
         and bitand(t.property, 128) = 128)  -- IOT has overflow
  from tab$ t, ind$ i
  where bitand(t.property,64+512) = 64  -- IOT but not overflow
    and t.pctused$ = i.obj#             -- for IOTs, pctused has index obj#
/

-- view for collection of nested tables of a parent table
create or replace force view ku$_nt_parent_view
  of ku$_nt_parent_t with object identifier(obj_num) as
  select t.obj#,
    cast(multiset(select
                nt.obj#, nt.intcol#, nt.ntab#,
                (select value(o) from ku$_schemaobj_view o
                 where o.obj_num = nt.ntab#),
                (select value(c) from ku$_simple_col_view c
                 where c.obj_num = nt.obj#
                 and   c.intcol_num = nt.intcol#),
                (select t.property from tab$ t where t.obj# = nt.ntab#),
                (select ct.flags from coltype$ ct
                        where ct.obj# = nt.obj#
                        and   ct.intcol# = nt.intcol#),
                (select t.trigflag from tab$ t where t.obj# = nt.ntab#),
                (select value(cz) from ku$_clst_view cz 
                 where cz.obj_num = nt.ntab#),
                (select value(h) from ku$_hnt_view h
                 where h.obj_num = nt.ntab#),
                (select value(i) from ku$_iont_view i
                 where i.obj_num = nt.ntab#),
                (select e.encalg from sys.enc$ e, ku$_hnt_view h
                 where h.obj_num=nt.ntab# and e.obj#=h.obj_num),
                (select e.intalg from sys.enc$ e, ku$_hnt_view h
                 where h.obj_num=nt.ntab# and e.obj#=h.obj_num),
                (cast(multiset(select * from ku$_column_view c
                                where c.obj_num = nt.ntab#
                                order by c.col_num, c.intcol_num
                        ) as ku$_tab_column_list_t
                        ))
          from ntab$ nt start with nt.obj#=t.obj#
                        connect by prior nt.ntab#=nt.obj#
                ) as ku$_nt_list_t
        )
  from tab$ t where bitand(t.property,4) = 4    -- has nested table columns
/

-------------------------------------------------------------------------------
--                              OBJECT_GRANT
-------------------------------------------------------------------------------

-- view for object grants
create or replace force view ku$_objgrant_view of ku$_objgrant_t
  with object identifier (sequence) as
  select '1','2',
         g.obj#, value(o),
         (select j.longdbcs from sys.javasnm$ j where j.short = o.name),
         u1.name, u2.name, p.name, g.sequence#,
         NVL(g.option$,0),
         (select c.name from sys.col$ c where g.obj#=c.obj# and g.col#=c.col#
          and bitand(c.property, 1) = 0           -- exclude ADT attribute column
          and bitand(c.property, 1024) = 0        -- exclude Nested table column
          and bitand(c.property, 416) = 0),    /* exclude system generated,
                                               hidden and stored in lob cols */
         u2.spare1
  from sys.ku$_edition_schemaobj_view o, sys.objauth$ g, sys.user$ u1, sys.user$ u2,
       sys.table_privilege_map p
  where g.obj#=o.obj_num and
        g.grantor#=u1.user# and
        g.grantee#=u2.user# and
        g.privilege#=p.privilege and
        (o.type_num != 2 or                          /* not a table or...  */
         exists (select 1 from tab$ t                /* not a nested table */
                 where t.obj#=o.obj_num
                 and bitand(t.property,8192)!=8192))
        and
        (SYS_CONTEXT('USERENV','CURRENT_USERID')
                IN (g.grantor#, g.grantee#, o.owner_num, 0) OR
                g.grantee#=1 OR
                EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/
-- 12.1.0.2 introduced READ privilege for other than DIRECTORY objects - in
-- particular, READ on TABLE. We wish to filter that grant in export to
-- earlier versions
create or replace force view ku$_10_1_objgrant_view of ku$_objgrant_t
  with object identifier (sequence) as
  select g.* from ku$_objgrant_view g
  where g.privname!='READ' or g.base_obj.type_num=23;

-- The security clause allows a non-privileged user the same access
-- as the catalog views. Note comment on ALL_TAB_PRIVS:
-- 'Grants on objects for which the user is the grantor, grantee, owner, 
-- or an enabled role or PUBLIC is the grantee'


-------------------------------------------------------------------------------
--                              SYSTEM_GRANT
-------------------------------------------------------------------------------

create or replace force view ku$_sysgrant_view of ku$_sysgrant_t
  with object identifier (sequence) as
  select '1','1',
         p.privilege,
         u.name, p.name, g.sequence#, NVL(g.option$,0), u.spare1
  from sys.sysauth$ g, sys.user$ u, sys.system_privilege_map p
  where g.grantee#=u.user# and
        g.privilege#=p.privilege and
        bitand(p.property, 1) != 1         /* Don't show non-SQL sys. grants */
        and
        (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (g.grantee#, 0) OR
                g.grantee#=1 OR
                EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/
-- The security clause allows a non-privileged user *almost* the same access
-- as the catalog views DBA/USER_SYS_PRIVS: system privs granted to user
-- or to PUBLIC.
-- The exception is that the catalog views include grants with
-- the "no-export" property.

-- Do we need the roles enumerated in exu8spv in catexp excluded in
-- the above where clause?

-- 12_1 view excludes privileges unknown in 12.2 (proj 46816)
-- 11_2 view excludes privileges unknown in 11.2 (LRG 6000876)
-- 10_1 view excludes privileges unknown in 10.1 (bug 4338348)

create or replace force view ku$_12_1_sysgrant_view of ku$_sysgrant_t
  with object identifier (sequence) as
  select * from ku$_sysgrant_view t
  where t.privilege >  -398
/

create or replace force view ku$_11_2_sysgrant_view of ku$_sysgrant_t
  with object identifier (sequence) as
  select * from ku$_sysgrant_view t
  where t.privilege >  -351
/

create or replace force view ku$_10_1_sysgrant_view of ku$_sysgrant_t
  with object identifier (sequence) as
  select * from ku$_sysgrant_view t
  where t.privilege != -233
    and t.privilege >  -276
/

-------------------------------------------------------------------------------
--                          CODE BASED GRANTS
-------------------------------------------------------------------------------

create or replace force view ku$_code_base_grant_view of ku$_code_base_grant_t
  with object identifier (obj_num, priv_num) as
  select '1','1', r.name, u.name, o.name, decode(o.type#, 7,  'PROCEDURE',
                                                  8,  'FUNCTION',
                                                  9,  'PACKAGE',
                                                 13,  'TYPE',
                                                      'UNDEFINED'),
         c.obj#, c.privilege#
 from sys.obj$ o, sys.user$ u, sys.user$ r, sys.codeauth$ c
 where o.obj# = c.obj# and u.user# = o.owner# and 
       (c.privilege#=r.user# and r.type#=0)
/

-------------------------------------------------------------------------------
--                              TABLE
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Specialized table UDTs/views
-------------------------------------------------------------------------------

-- ORGANIZATION CUBE Tables
create or replace force view ku$_cube_fact_view
  as select ot.awseq#, ot.obj#, ao1.objname, oc.col#, oc.pcol#,
            (select col1.name from sys.col$ col1
             where col1.obj#=oc.obj# and col1.col#=oc.col#) colname,
            (select col2.name from sys.col$ col2
             where col2.obj#=oc.obj# and col2.col#=oc.pcol#) pcolname,
            oc.coltype,
            (select ao2.objname qdr
             from sys.aw_obj$ ao2,
             (select max(rowid) keep (dense_rank last order by gen#) rid
              from aw_obj$ group by awseq#, oid) aor2
             where ao2.oid = oc.qdroid and ao2.awseq#=ot.awseq#
               and ao2.rowid = aor2.rid) qdr, oc.qdrval, oc.hier#,
            oc.flags
     from sys.olap_tab$ ot, sys.olap_tab_col$ oc, sys.aw_obj$ ao1,
          (select max(rowid) keep (dense_rank last order by gen#) rid
           from aw_obj$ group by awseq#, oid) aor1
     where oc.obj# = ot.obj#
       and ao1.awseq#=ot.awseq# and ao1.rowid=aor1.rid and ao1.oid=oc.oid
     order by oc.col#
/

create or replace force view ku$_cube_tab_view of ku$_cube_tab_t
  with object OID(obj_num)
  as select ot.obj#, aw.awname, ot.flags,
    cast( multiset(select ofv.obj#, ofv.colname, ofv.objname,
                    (select ol.objname                     /*dimusing*/
                     from ku$_cube_fact_view ol
                     where ol.obj#=ot.obj#
                     and ol.coltype=10
                     and ol.pcol#=ofv.col#),
                    cast( multiset(select ol.obj#,              /*gid*/
                                          ol.colname, ol.pcolname, null,
                                          ol.objname, ol.qdr,
                                          ol.qdrval, ol.flags
                                     from ku$_cube_fact_view ol
                                     where ol.obj#=ot.obj#
                                     and ol.coltype=5
                                     and ol.pcol#=ofv.col#
                                   ) as ku$_cube_fact_list_t
                        ),
                    cast( multiset(select ol.obj#,              /*pgid*/
                                          ol.colname, ol.pcolname, null,
                                          ol.objname, ol.qdr,
                                          ol.qdrval, ol.flags
                                     from ku$_cube_fact_view ol
                                     where ol.obj#=ot.obj#
                                     and ol.coltype=6
                                     and ol.pcol#=ofv.col#
                                  ) as ku$_cube_fact_list_t
                        ),
                    cast( multiset(select ol.obj#,              /*attr*/
                                          ol.colname, ol.pcolname, null,
                                          ol.objname, ol.qdr,
                                          ol.qdrval, ol.flags
                                     from ku$_cube_fact_view ol
                                     where ol.obj#=ot.obj#
                                     and ol.coltype=4
                                     and ol.pcol#=ofv.col#
                                   ) as ku$_cube_fact_list_t
                        ),
                    cast( multiset(select ol.obj#,              /*lvls*/
                                          ol.colname, ol.pcolname, null,
                                          ol.objname, ol.qdr,
                                          ol.qdrval, ol.flags
                                     from ku$_cube_fact_view ol
                                     where ol.obj#=ot.obj#
                                     and ol.coltype=3
                                     and ol.pcol#=ofv.col#
                                  ) as ku$_cube_fact_list_t
                        ),
                    cast( multiset(select ol.obj#, ol.objname, ol.qdr,
                                          ol.qdrval,
                                          cast( multiset(select
                                                           lvl.obj#,
                                                           lvl.colname,
                                                           lvl.pcolname,
                                                           null,
                                                           lvl.objname,
                                                           lvl.qdr,
                                                           lvl.qdrval,
                                                           oh.flags
                                            from ku$_cube_fact_view lvl,
                                                 sys.olap_tab_hier$ oh
                                            where oh.hier#=ol.hier#
                                              and oh.obj#=ol.obj#
                                              and lvl.obj#=oh.obj#
                                              and (lvl.pcol#=ofv.col#
                                               or (lvl.col#=ofv.col#
                                               and (oh.flags=1)))
                                              and lvl.colname=
                           (select col.name from sys.col$ col
                              where col.obj#=oh.obj# and col.col#=oh.col#)
                                            order by oh.FLAGS desc, oh.ord
                                                ) as ku$_cube_fact_list_t
                                              ),
                                cast(multiset(select inh.obj#,  /* inhier */
                                                     inh.colname, inh.pcolname,
                                                     null, inh.objname,
                                                     inh.qdr, inh.qdrval,
                                                     inh.flags
                                               from ku$_cube_fact_view inh
                                               where inh.obj#=ot.obj#
                                                 and inh.coltype=11
                                                 and inh.hier#=ol.hier#
                                                 and inh.pcol#=ofv.col#
                                               ) as ku$_cube_fact_list_t
                                        ),
                                          ol.flags
                                     from ku$_cube_fact_view ol
                                     where ol.obj#=ot.obj#
                                     and ol.coltype=7
                                     and ol.pcol#=ofv.col#
                                   ) as ku$_cube_hier_list_t
                        ),
                    ofv.flags /* flags */
                    from ku$_cube_fact_view ofv
                    where ofv.coltype=2 and ofv.obj#=ot.obj#
                  ) as ku$_cube_dim_list_t
        ),
    /* FACTs */
    cast( multiset(select ofv.obj#, ofv.colname, ofv.pcolname,
                          (select col.name from sys.col$ col        /* COUNT */
                             where col.obj#=ofv.obj# and col.col#=
                               (select otc.col# from olap_tab_col$ otc
                                  where otc.obj#=ofv.obj# and
                                        otc.pcol#=ofv.col# and
                                        otc.coltype=9)),
                          ofv.objname, ofv.qdr, ofv.qdrval, ofv.flags
                     from ku$_cube_fact_view ofv
                     where ofv.coltype=1 and ofv.obj#=ot.obj#
                  ) as ku$_cube_fact_list_t
        ),
    /* CGID */
    cast( multiset(select ofv.obj#, ofv.colname, ofv.pcolname, null,
                          ofv.objname, ofv.qdr, ofv.qdrval, ofv.flags
                     from ku$_cube_fact_view ofv
                     where ofv.coltype=8 and ofv.obj#=ot.obj#
                     order by ofv.col#
                  ) as ku$_cube_fact_list_t
        )
  from sys.olap_tab$ ot, sys.aw$ aw
    where aw.awseq#=ot.awseq#
/

-- flashback archived table info for a table
-- (a subset of info from sys_fba_fa and sys_fba_trackedtables)

create or replace force view ku$_fba_view of ku$_fba_t
  with object OID(obj_num)
  as select '1','0',
            ft.obj#,
            ft.fa#,
            fba.faname
  from sys_fba_fa fba, sys_fba_trackedtables ft
  where ft.fa#=fba.fa#
/

-- valid-time temporal information

create or replace force view ku$_fba_period_view of ku$_fba_period_t
  with object OID(obj_num)
  as select '1','0',
            fb.obj#,
            fb.periodname,
            fb.flags,
            fb.periodstart,
            fb.periodend,
            fb.spare
      from sys.sys_fba_period fb
/

-- view for primitive, non-partitioned Heap TABLEs

--
-- Bug 6635956: Replace NULL chars in audit$ column with '-' when creating
-- object views since audit$ columns in tab$, view$, seq$, procedure$, dir$,
-- type_misc$, library$, or user$ can contain NULL chars in some cases.
-- We did the same for all object views which reference audit$ columns in
-- these tables.
--

--
-- Bug 19688579: Table views ku$_htable_view, ku$_phtable_view, 
--                 ku$_fhtable_view,ku$_pfhtable_view,ku$_acptable_view,
--                 ku$_iotable_view,ku$_piotable_view
--               moved to catmetviews_mig.sql to avoid upgrade failure
--               with new dictionary columns (eg tab$.property2)
--

-- 10_1 view excludes tables with encrypted columns.

create or replace force view ku$_10_1_htable_view of ku$_table_t
  with object OID(obj_num)
  as select t.* from ku$_htable_view t
  where bitand(t.trigflag,65536+131072)=0
/

-- 10_1 view excludes tables with encrypted columns.

create or replace force view ku$_10_1_phtable_view of ku$_table_t
  with object OID(obj_num)
  as select t.* from ku$_phtable_view t
  where bitand(t.trigflag,65536+131072)=0
/

-- 10_2_fhtable is identical fhtable_view, except for:
--    dbms_metadata.is_attr_valid_on_10(t.obj#,c.intcol_num)=1
-- 10_1 view excludes tables with encrypted columns.

create or replace force view ku$_10_1_fhtable_view of ku$_table_t
  with object OID(obj_num)
  as select t.* from ku$_fhtable_view t
  where bitand(t.trigflag,65536+131072)=0
/

-- 10_1 view excludes tables with encrypted columns.

create or replace force view ku$_10_1_pfhtable_view of ku$_table_t
  with object OID(obj_num)
  as select t.* from ku$_pfhtable_view t
  where bitand(t.trigflag,65536+131072)=0
/

-- view used for reference partition levels

create or replace force view ku$_ref_par_level_view
  (obj#,lvl)
  as select obj#, level
     from cdef$
     start with robj# IN (select obj# from partobj$
                         where parttype != 5 AND bitand(flags, 32) != 0)
                               AND type# = 4 AND bitand(defer, 512) != 0
     connect by prior obj# = robj#
                AND type# = 4 AND bitand(defer, 512) != 0
/

-- 10_1 view excludes tables with encrypted columns.

create or replace force view ku$_10_1_iotable_view of ku$_io_table_t
  with object OID(obj_num)
  as select t.* from ku$_iotable_view t
  where bitand(t.trigflag,65536+131072)=0
/

-- view for partitioned IOT overflow table partition

create or replace force view ku$_ov_tabpart_view of ku$_ov_tabpart_t
  with object OID(obj_num)
  as select t.obj#, t.dataobj#, t.bo#,
         dbms_metadata.get_partn(1,t.bo#,t.part#),
         (select value(s) from ku$_storage_view s
          where t.file# = s.file_num
          and t.block#  = s.block_num
          and t.ts#     = s.ts_num),
         (select value(s) from ku$_deferred_stg_view s
          where s.obj_num = t.obj#),
         ts.name, ts.blocksize,
         t.pctfree$, t.pctused$, t.initrans, t.maxtrans, t.flags
  from  tabpart$ t, ts$ ts
  where t.ts# = ts.ts#
/

-- view for partitioned IOT MAPPING table partition
create or replace force view ku$_map_tabpart_view of ku$_map_table_t
  with object OID(obj_num)
  as select t.obj#, t.dataobj#, t.bo#,
         dbms_metadata.get_partn(1,t.bo#,t.part#),
         (select value(s) from ku$_storage_view s
          where t.file# = s.file_num
          and t.block#  = s.block_num
          and t.ts#     = s.ts_num),
         ts.name, ts.blocksize,
         t.pctfree$, t.pctused$, t.initrans, t.maxtrans, t.flags
  from  tabpart$ t, ts$ ts
  where t.ts# = ts.ts#
/

-- view for partitioned IOTs

create or replace force view ku$_iot_partobj_view of ku$_iot_partobj_t
  with object identifier (obj_num) as
  select t.obj#,
         (select value (tpo) from ku$_partobj_view tpo
          where t.obj# = tpo.obj_num),
         cast(multiset(select * from ku$_tab_part_col_view pc
                       where pc.obj_num = t.obj#
                        order by pc.pos_num
                      ) as ku$_part_col_list_t
             ),
         cast(multiset(select * from ku$_tab_subpart_col_view sc
                       where sc.obj_num = t.obj#
                        order by sc.pos_num
                      ) as ku$_part_col_list_t
             ),
         (select value (ipo) from ku$_partobj_view ipo
          where i.obj# = ipo.obj_num),
         (select value (ovpo) from ku$_partobj_view ovpo
          where t.bobj# = ovpo.obj_num),
         cast(multiset(select * from ku$_piot_part_view ip
                       where ip.base_obj_num = i.obj#
                        order by ip.part_num
                      ) as ku$_piot_part_list_t
             ),
         cast(multiset(select * from ku$_ov_tabpart_view ovp
                       where ovp.bobj_num = t.bobj#
                        order by ovp.part_num
                      ) as ku$_ov_tabpart_list_t
             ),
         cast(multiset(select value(mp) from ku$_map_tabpart_view mp
                       -- Mapping table object number exists in tab$.pctfree$
                       where mp.bobj_num = t.pctfree$
                        order by mp.part_num
                      ) as ku$_map_tabpart_list_t
             )
  from tab$ t, ind$ i
  where i.bo#=t.obj#
    and i.type#=4                       -- iot index
    and bitand(t.property,32)=32        -- partitioned table
/

-- 10_1 view excludes tables with encrypted columns.

create or replace force view ku$_10_1_piotable_view of ku$_io_table_t
  with object OID(obj_num)
  as select t.* from ku$_piotable_view t
  where bitand(t.trigflag,65536+131072)=0
/


-------------------------------------------------------------------------------
--                     TABLE_OBJNUM, TABLE_TYPES, DOMIDX_OBJNUM
-------------------------------------------------------------------------------

-- Views for fetching table object numbers.

-- This view is used only for [datapump] heterogeneous object processing.
-- We select only "base tables"; dependent tables (e.g. nested and token
-- tables) are added later, if their parent table is being exported.
-- used by heterogeneous object types.

   -- FBA   : Flashback Archive
   -- ACLMV : Access Control List Materialized View 
create or replace force view ku$_table_objnum_view of ku$_table_objnum_t
  with object identifier(obj_num) as
  select t.obj#, NULL, 'T',
         bitand(t.property, 4294967295),
         trunc(t.property / power(2, 32)),
         t.ts#,
         value(o), value(o)
  from ku$_schemaobj_view o, sys.tab$ t
  where o.obj_num=t.obj#
  AND bitand(t.property,8192)=0                  /* is not a nested table */
  AND o.status != 5                  /* table is not invalid/unauthorized */
  AND bitand(t.flags,536870912)=0             /* not an IOT mapping table */
  AND bitand(trunc(t.property/power(2,32)),2)=0 /* not FBA internal table */
  AND bitand(t.property,power(2,44))=0    /* not an ACLMV container table */
  AND bitand(trunc(property / power(2, 64)),2)=0  /* Exclude token tables */
  AND (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (o.owner_num, 0)
        OR EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

create or replace force view ku$_2nd_table_objnum_view of ku$_table_objnum_t
  with object identifier(obj_num) as
  select t.obj#, NULL, 'T',
         bitand(t.property, 4294967295),
         trunc(t.property / power(2, 32)),
         t.ts#,
         value(o), value(o2)
  from ku$_schemaobj_view o, ku$_schemaobj_view o2, secobj$ s, sys.tab$ t
  where o.obj_num=t.obj#
  AND s.secobj#=o.obj_num
  AND s.obj#=o2.obj_num
  AND bitand(t.property,8192)=0      /* is not a nested table */
  AND bitand(t.flags,536870912)=0    /* not an IOT mapping table */
  AND bitand(trunc(t.property/power(2,32)),2)=0 /* not FBA internal table */
  AND bitand(t.property,power(2,44))=0  /* not an ACLMV container table */
  AND (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (o.owner_num, 0)
        OR EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

create or replace force view ku$_ntable_objnum_view of ku$_table_objnum_t
  with object identifier(obj_num) as
  select nt.ntab#, NULL,
   decode(dbms_metadata_util.isXml(nt.ntab#),0,'N','X'),
   bitand(t.property, 4294967295),
   trunc(t.property / power(2, 32)),
   NULL,                        -- ts# not needed
   value(o), value(bo)
  from ku$_schemaobj_view o, ku$_schemaobj_view bo, sys.tab$ t, sys.ntab$ nt
  where bo.obj_num=dbms_metadata_util.get_anc(nt.ntab#,0)
    and  o.obj_num=nt.ntab#
    and  t.obj#=nt.ntab#
    AND (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (o.owner_num, 0)
        OR EXISTS ( SELECT * FROM sys.session_roles
                    WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
  start with nt.obj#
        in (select * from table(dbms_metadata.fetch_objnums('T')))
  connect by prior nt.ntab#=nt.obj#
/

-- nested or ordered collection tables used for xmltype object
-- relational storage are not exported (table or table_data object types).
-- But other dependent object such as indexes should be exported -
-- this view is used to augment table object numbers with xdb storage tables.

create or replace force view ku$_xdb_ntable_objnum_view of ku$_table_objnum_t
  with object identifier(obj_num) as
  select nt.ntab#, NULL, 'X',
   bitand(t.property, 4294967295),
   trunc(t.property / power(2, 32)),
   NULL,                        -- ts# not needed
   value(o), value(bo)
  from ku$_schemaobj_view o, ku$_schemaobj_view bo, sys.tab$ t, sys.ntab$ nt
  where bo.obj_num=dbms_metadata_util.get_anc(nt.ntab#,0)
    and  o.obj_num=nt.ntab#
    and dbms_metadata_util.isXml(nt.ntab#)=1 and nt.ntab# != 0
    and  t.obj#=nt.ntab#
    and (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (o.owner_num, 0)
        OR EXISTS ( SELECT * FROM sys.session_roles
                    WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
  start with nt.obj#
        in (select * from table(dbms_metadata.fetch_objnums))
  connect by prior nt.ntab#=nt.obj#
/
--
-- when exporting to pre-12c, exclude tables with long varchar columns
--
create or replace force view ku$_11_2_table_objnum_view of ku$_table_objnum_t
  with object identifier(obj_num) as
  select t.* from ku$_table_objnum_view t
  where bitand(t.property2,2097152)=0
/
--
-- exclude tables with virtual cols (i.e., not supported in 10.*)
--
create or replace force view ku$_10_1_table_objnum_view of ku$_table_objnum_t
    with object identifier(obj_num) as
    select t.* from ku$_11_2_table_objnum_view t
    where
     NOT EXISTS (
       select property from col$ c /* exclude tabs with virtual cols */
       where c.obj# = t.obj_num
           and bitand(c.property, 65536) >= 65536            /* virtual cols */
           and bitand(c.property, 256) = 0               /* not a sysgen col */
           and bitand(c.property, 32768) = 0)                  /* not unused */
/

create or replace force view ku$_11_2_ntable_objnum_view of ku$_table_objnum_t
  with object identifier(obj_num) as
  select t.* from ku$_ntable_objnum_view t
  where bitand(t.property2,2097152)=0
/
create or replace force view ku$_11_2_xdb_ntbl_objnum_view of ku$_table_objnum_t
  with object identifier(obj_num) as
  select t.* from ku$_xdb_ntable_objnum_view t
  where bitand(t.property2,2097152)=0
/

-------------------------------------------------------------------------------
--                     DEPENDENT_TABLE_OBJNUM
-------------------------------------------------------------------------------


-- View for fetching dependent table object numbers -- used by heterogeneous
-- object types, adding to table objnum's.
-- The view is only for top-level tables; we get the nested tables
-- when we subsequently fetch from ku$_ntable_objnum_view (above).
-- Filter allowed are minimal (essentially, nonexistent), as the user
-- should be unaware of dependent tables.

create or replace force view ku$_deptable_objnum_view of ku$_table_objnum_t
  with object identifier(obj_num) as
  select exdo.d_obj#, NULL, 'T',
  bitand(t.property, 4294967295),    /* low order Property of dependent table */
  trunc(t.property / power(2, 32)), /* high order Property of dependent table */
  NULL, 
  value(po),  /*Parent object details as obj_num of po is used to filter obj# */
  NULL
  from expdepobj$ exdo, ku$_schemaobj_view po, ku$_schemaobj_view do, tab$ t
  where exdo.p_obj# = po.obj_num
  AND exdo.d_obj# = do.obj_num
  AND exdo.d_obj# = t.obj#
  AND ((SYS_CONTEXT('USERENV','CURRENT_USERID') IN (po.owner_num, 0) AND
        SYS_CONTEXT('USERENV','CURRENT_USERID') IN (do.owner_num, 0))
        OR EXISTS ( SELECT * FROM sys.session_roles
                    WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

-- for pre-v12 exclude tables with long varchar columns
create or replace force view ku$_11_2_deptbl_objnum_view of ku$_table_objnum_t
  with object identifier(obj_num) as
  select t.* from ku$_deptable_objnum_view t
  where bitand(t.property2,2097152)=0
/

-- View for fetching types of top level columns of a table
-- (used by transportable_export)

create or replace force view ku$_table_types_view (
 tabobjno, tabname, tabownerno, tabowner, typeobjno, typename, typeowner)
as
 select unique o.obj#,o.name,o.owner#,u.name, d.p_obj#, tyo.name, ou.name
from obj$ o, obj$ tyo, type$ dt, user$ u, user$ ou, dependency$ d, type$ t,
     sys.coltype$ c
where t.toid = c.toid
  and bitand(t.properties,2128)=0     /* not system-generated type */
  and o.obj# = c.obj#
  and o.type# = 2
  and o.owner# != 0                   /* not SYS-owned table */
  and o.owner# = u.user#
  and tyo.owner# = ou.user#
  and o.obj# = d.d_obj#
  and tyo.obj# = d.p_obj#
  and tyo.type# = 13
  and tyo.owner# != 0                 /* not SYS-owned type */
  and tyo.oid$ = dt.toid
  and dt.toid = dt.tvoid    /* only the latest type */
/

-- View for fetching types required for xmlschemas
--   Registering xmlschemas creates types, but on import we must import
--   the type, rather than allowing them to be recreated.
--   This is a dummy definition, which works if XDB is not loaded.
-- (used by transportable_export)

create or replace force view ku$_xmlschema_types_view sharing=none (
 tabobjno,  typeobjno, typename, typeowner)
as
 select 0, 0, NULL, NULL
    from dual where 1=0
/

-- View for fetching types required for transportable export
-- (used by transportable_export)

create or replace force view ku$_tts_types_view (
 tabobjno, typeobjno, typename, typeowner)
as
    select tabobjno, typeobjno, typename, typeowner
    from  ku$_table_types_view
  UNION ALL
    select tabobjno, typeobjno, typename, typeowner
    from  ku$_xmlschema_types_view
/


-- View for fetching domain index object numbers 
--   used by heterogeneous object types.
-- The p2t_domidx_objnum_view also deal with a partition name, for sharding
--  move chunk.

create or replace force view ku$_p2t_domidx_objnum_view of ku$_table_objnum_t
  with object identifier(obj_num) as
  select i.obj#,onn.name,NULL,
  NULL,NULL,                   -- property bits not needed
  NULL,                        -- ts# not needed
  value(o), value(bo)
  from ku$_schemaobj_view o, ku$_schemaobj_view bo, sys.ind$ i,
       TABLE(DBMS_METADATA.FETCH_OBJNUMS_NAMES) onn
  where o.obj_num=i.obj#
  and   i.bo# = onn.obj_num 
  and   bo.obj_num=i.bo#
  and   i.type#=9            /* domain index */
  AND (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (o.owner_num, 0)
        OR EXISTS ( SELECT * FROM sys.session_roles
                    WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/
create or replace force view ku$_domidx_objnum_view of ku$_table_objnum_t
  with object identifier(obj_num) as
  select i.obj#,NULL,NULL,
  NULL,NULL,                   -- property bits not needed
  NULL,                        -- ts# not needed
  value(o), value(bo)
  from ku$_schemaobj_view o, ku$_schemaobj_view bo, sys.ind$ i,
       TABLE(DBMS_METADATA.FETCH_OBJNUMS) onn
  where o.obj_num=i.obj#
  and   i.bo# = onn.obj_num 
  and   bo.obj_num=i.bo#
  and   i.type#=9            /* domain index */
  AND (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (o.owner_num, 0)
        OR EXISTS ( SELECT * FROM sys.session_roles
                    WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

-------------------------------------------------------------------------------
--                     OPTION_OBJNUM
-------------------------------------------------------------------------------

create or replace force view ku$_expreg as
  select *
  from impcalloutreg$ i
  where i.class=3
    AND (bitand(i.flags,16)=0 or dbms_metadata.is_xdb_trans=0)
    AND sys.dbms_metadata.is_active_registration(
                i.beginning_tgt_version, i.ending_tgt_version)=1
/

create or replace force view ku$_option_objnum_view
 of ku$_option_objnum_t
  with object identifier(obj_num) as
  select o.obj_num, 'T', value(o),i.tgt_type, i.flags, i.tag,
         i.beginning_tgt_version, i.ending_tgt_version,
         i.alt_name, i.alt_schema
  from ku$_expreg i, ku$_schemaobj_view o
  where ((bitand(i.flags,1)=0 and
          o.name=i.tgt_object and
          (bitand(i.flags,8)=0)) or
         (bitand(i.flags,1)=1 and
          o.name like i.tgt_object and
           -- check for excluded object
          (select count(*)
           from ku$_expreg xi
           where (bitand(xi.flags,8)=8)
                 and i.tgt_schema = xi.tgt_schema
                 and xi.tgt_object = o.name) = 0 ))
    AND o.owner_name=i.tgt_schema
    AND i.tgt_type=o.type_num
/

-- for exporting options views as tables
-- (need a relational view)

create or replace force view ku$_option_view_objnum_view(
  obj_num,owner,name,flags,tag,alt_name,alt_schema) as
  select oo.obj_num,oo.schema_obj.owner_name,oo.schema_obj.name,
        oo.impc_flags, oo.tag, oo.alt_name, oo.alt_schema
  from ku$_option_objnum_view oo
  where oo.tgt_type=4            /* type is 'view' */
/

-------------------------------------------------------------------------------
--                     MARKER
-------------------------------------------------------------------------------

-- View for fetching marker numbers

create or replace force view ku$_marker_view
 of ku$_marker_t
  with object identifier(marker) as
  select '1', '0', dbms_metadata_util.get_marker
  from dual
/

-------------------------------------------------------------------------------
--                     TABLE, MVIEW, MVIEW_LOG PROPERTIES
-------------------------------------------------------------------------------

-- View to retrieve table properties; dbms_metadata.get_object uses
--  this to figure out which object_flags to set for a table
-- Note that the order of tables in the from-clause is important:
-- putting tab$ last avoids a full scan of user$ for queries of
-- the form 'schema not in (...)'

create or replace force view ku$_tabprop_view
 (obj_num,name,schema,flags,property)
 as
 select o.obj#, o.name, u.name, o.flags, t.property
 from obj$ o, user$ u, tab$ t
 where o.owner# = u.user#
 and   o.obj#   = t.obj#
 and  (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (o.owner#,0) OR
                EXISTS ( SELECT * FROM sys.session_roles
                         WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

--
-- also part of views-as-tables validation;
--  this goes against obj$ and user$ ONLY; in a PDB Oracle-generated 
--  common objects do not appear in view$
--
create or replace force view ku$_view_exists_view
 (obj_num,name,schema)
 as
 select o.obj#, o.name, u.name
 from obj$ o, user$ u
 where o.owner# = u.user#
 and o.type# = 4
 and  (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (o.owner#,0) OR
                EXISTS ( SELECT * FROM sys.session_roles
                         WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/


-- need special views to account for reference partitioned tables

create or replace force view sys.ku$_pfhtabprop_view
 (obj_num,name,schema,flags,property)
 as
 select t.obj_num,t.name,t.schema,t.flags,t.property from ku$_tabprop_view t
 where bitand(t.property,32+64+128+256+512)=32
 and not exists( select * from partobj$ po
             where po.obj# = t.obj_num and po.parttype = 5)
/

create or replace force view sys.ku$_refparttabprop_view
 (obj_num,name,schema,flags,property)
 as
 select t.obj_num,t.name,t.schema,t.flags,t.property from ku$_tabprop_view t
 where bitand(t.property,32+64+128+256+512)=32
 and exists( select * from partobj$ po
             where po.obj# = t.obj_num and po.parttype = 5)
/

-- View to do the same for materialized views.

create or replace force view sys.ku$_mvprop_view
 (obj_num,name,schema,flags,property,flag2)
 as
 select o.obj#, o.name, u.name, o.flags, t.property,s.flag2
 from obj$ o, tab$ t, user$ u, snap$ s
 where o.owner# = u.user#
 and   o.obj#   = t.obj#
 and   s.sowner = u.name
 and   s.tname  = o.name
 and  (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (o.owner#,0) OR
                EXISTS ( SELECT * FROM sys.session_roles
                         WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

-- ...and for materialized view logs.

create or replace force view sys.ku$_mvlprop_view
 (obj_num,name,schema,flags,property)
 as
 select o.obj#, m.master, m.mowner, o.flags, t.property
 from obj$ o, tab$ t, user$ u, mlog$ m
 where o.owner# = u.user#
 and   o.obj#   = t.obj#
 and   m.mowner = u.name
 and   m.log = o.name
 and  (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (o.owner#,0) OR
                EXISTS ( SELECT * FROM sys.session_roles
                         WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
UNION ALL
 /* Get staging log details */
 select o2.obj#, u1.name, o2.name,o2.flags,0
 from sys.syncref$_table_info srt, sys.obj$ o1, sys.user$ u1,
      sys.obj$ o2
 where  dbms_metadata.get_version >= '12.02.00.02.00'
 and o1.owner# = u1.user#
 and o1.obj# = srt.staging_log_obj#
 and o2.obj# = srt.table_obj#
 and (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (o1.owner#,0) OR
               EXISTS ( SELECT * FROM sys.session_roles
                        WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

-- ...and for materialized zonemaps
--  o1 = MZ
--  o2 = base table
--  o3 = container table

create or replace force view sys.ku$_mzprop_view
 (base_obj_num,name,schema,flags,property)
 as
 select o2.obj#, o1.name, u1.name, o1.flags, t.property
 from obj$ o1, obj$ o2, obj$ o3, tab$ t, user$ u1, user$ u2, snap$ s
 where o2.owner# = u2.user#
 and   s.mowner = u2.name
 and   s.master = o2.name
 and   s.mlink  is null
 and   o2.type#  = 2
 and   o1.owner# = u1.user#
 and   s.sowner  = u1.name
 and   s.tname   = o1.name
 and   o1.type#  = 42
 and   s.sowner  = u1.name
 and   s.tname   = o3.name
 and   o3.type#  = 2
 and   o3.obj#   = t.obj#
 and  (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (o1.owner#,0) OR
                EXISTS ( SELECT * FROM sys.session_roles
                         WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

-- and for synonyms
create or replace force view sys.ku$_syn_exists_view
 (obj_num,schema)
 as
 select o.obj#,u.name
 from obj$ o, user$ u, syn$ s
 where o.owner#=u.user#
 and o.obj#=s.obj#
 and  (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (o.owner#,0) OR
                EXISTS ( SELECT * FROM sys.session_roles
                         WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

-- and for object grants

create or replace force view sys.ku$_objgrant_exists_view
 (obj_num,schema,owner,grantor,wgo)
 as
 select o.obj#,u.name,o.owner#,g.grantor#,NVL(g.option$,0)
 from obj$ o, user$ u, objauth$ g
 where o.owner#=u.user#
 and o.obj#=g.obj#
 and  (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (o.owner#,0) OR
                EXISTS ( SELECT * FROM sys.session_roles
                         WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

-- and for constraints
-- If this view returns no rows, then expdp would also return none.
-- The converse isn't true; this view may return rows which expdp would not,
--  e.g., primary key constraints for IOTs

create or replace force view sys.ku$_constraint_exists_view
 (base_obj_num,schema)
 as
 select o.obj#,u.name
 from obj$ o, user$ u, con$ c, cdef$ cd
 where o.owner#=u.user#
 and cd.obj# = o.obj#
 and c.con# = cd.con#
 and cd.type# in (1,2,3,12,14,15,16,17)
                               -- table check (condition-no keys) (1),
                               -- primary key (2),
                               -- unique key (3),
                               -- supplemental log groups (w/ keys) (12),
                               -- supplemental log data (no keys) (14,15,16,17)
 and  (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (o.owner#,0) OR
                EXISTS ( SELECT * FROM sys.session_roles
                         WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

-- and for ref_constraints

create or replace force view sys.ku$_ref_constraint_exists_view
 (base_obj_num,schema)
 as
 select o.obj#,u.name
 from obj$ o, user$ u, con$ c, cdef$ cd
 where o.owner#=u.user#
 and cd.obj# = o.obj#
 and c.con# = cd.con#
 and cd.type# = 4           -- referential constraint
 and  (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (o.owner#,0) OR
                EXISTS ( SELECT * FROM sys.session_roles
                         WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

-- and for indexes

create or replace force view sys.ku$_ind_exists_view
 (obj_num,base_obj_num,schema,type_num,property)
 as
 select i.obj#,i.bo#,u.name,i.type#,i.property
 from ind$ i, obj$ o, user$ u
 where o.obj# = i.obj#
 and o.owner#=u.user#
 and  (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (o.owner#,0) OR
                EXISTS ( SELECT * FROM sys.session_roles
                         WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

-- and for triggers

create or replace force view sys.ku$_trig_exists_view
 (obj_num,base_obj_num,schema)
 as
 select t.obj#,t.baseobject,u.name
 from trigger$ t, obj$ o, user$ u
 where o.obj# = t.obj#
 and o.owner#=u.user#
 and  (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (o.owner#,0) OR
                EXISTS ( SELECT * FROM sys.session_roles
                         WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

create or replace force view sys.ku$_edition_trig_exists_view
 (obj_num,base_obj_num,schema)
 as
 select t.obj#,t.baseobject,o.owner_name
 from   sys.ku$_edition_schemaobj_view o, sys.trigger$ t
  where  t.obj# = o.obj_num AND
         (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (o.owner_num, 0) OR
                EXISTS ( SELECT * FROM sys.session_roles
                         WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

-- and for procedures, functions and packages

create or replace force view sys.ku$_proc_exists_view
 (obj_num,schema,type_num)
 as
 select o.obj#,u.name,o.type#
 from obj$ o, user$ u
 where o.owner#=u.user#
 and  (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (o.owner#,0) OR
                EXISTS ( SELECT * FROM sys.session_roles
                         WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

create or replace force view sys.ku$_edition_proc_exists_view
 (obj_num,schema,type_num)
 as
 select oo.obj#, o.owner_name, oo.type#
  from  sys.ku$_edition_schemaobj_view o, sys.ku$_edition_obj_view oo
  where (oo.type# = 7 or oo.type# = 8 or oo.type# = 9 or oo.type# = 11)
    and oo.obj#  = o.obj_num and oo.linkname is NULL
 and  (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (oo.owner#,0) OR
                EXISTS ( SELECT * FROM sys.session_roles
                         WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

-- whether table has column with default expression containing a sequence
-- (not valid pre-V12)

create or replace force view sys.ku$_seq_in_default_view (obj_num)
 as
 select unique c.obj# 
 from sys.obj$ o, sys.col$ c
 where bitand(trunc(c.property / power(2,32)),8) != 0
 and o.obj#=c.obj#
 and  (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (o.owner#,0) OR
                EXISTS ( SELECT * FROM sys.session_roles
                         WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

-------------------------------------------------------------------------------
--                      TABLES (and other objects) BY TABLESPACE
-------------------------------------------------------------------------------

-- Partitioned and non-partitioned tables in tablespaces.
-- This view is used to implement the TABLESPACE filter.
--
-- tab$.property bits:
--      32      table is partitioned
--      64      index only table
--      512     IOT overflow segment

create or replace force view sys.ku$_tts_view ( owner_num, obj_num, ts_name ) as
  select o.owner#, t.obj#, ts.name              -- unpartitioned heap tables
  from   sys.obj$ o, sys.tab$ t, sys.ts$ ts
  where  t.ts#  = ts.ts#
  and    o.obj# = t.obj#
  and    bitand(t.property, 32+64+512) = 0
 UNION ALL
  select o.owner#, t.obj#, ts.name              -- simple partitions
  from   sys.obj$ o, sys.tab$ t, sys.tabpart$ tp, sys.ts$ ts
  where  tp.ts# = ts.ts#
  and    t.obj# = tp.bo#
  and    o.obj# = t.obj#
  and    bitand(t.property, 32+64+512) = 32
 UNION ALL
  select o.owner#, t.obj#, ts.name              -- composite partitions
  from   sys.obj$ o, sys.tab$ t,
         sys.tabcompart$ tcp, sys.tabsubpart$ tsp, sys.ts$ ts
  where  tsp.ts#  = ts.ts#
  and    tcp.obj# = tsp.pobj#
  and    t.obj#   = tcp.bo#
  and    o.obj# = t.obj#
  and    bitand(t.property, 32+64+512) = 32
 UNION ALL
  select o.owner#, t.obj#, ts.name              -- unpartitioned IOTs
  from   sys.obj$ o, sys.tab$ t, sys.ind$ i, sys.ts$ ts
  where  i.ts#    = ts.ts#
    and  i.obj#   = t.pctused$
  and    o.obj# = t.obj#
  and    bitand(t.property, 32+64+512) = 64
 UNION ALL
  select o.owner#, t.obj#, ts.name              -- PIOTs
  from   sys.obj$ o, sys.tab$ t, sys.indpart$ ip, sys.ts$ ts
  where  ip.ts#   = ts.ts#
    and  ip.bo#   = t.pctused$
  and    o.obj# = t.obj#
  and    bitand(t.property, 32+64+512) = 32 + 64
/

create or replace force view sys.ku$_tab_ts_view ( owner_num, obj_num, ts_name ) as
  select t.owner_num, t.obj_num, t.ts_name
  from   sys.ku$_tts_view t
  where  (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (t.owner_num,0) OR
                EXISTS ( SELECT * FROM sys.session_roles
                         WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

-- Partitioned and non-partitioned indexes in tablespaces.
-- This view is used to implement the TABLESPACE filter.
--
-- ind$.property bits:
--      2       index is partitioned

create or replace force view sys.ku$_tts_ind_view ( owner_num, obj_num, ts_name,
                                              ts_num ) as
  select o.owner#, i.obj#, ts.name, ts.ts#      -- unpartitioned indexes
  from   sys.obj$ o, sys.ind$ i, sys.ts$ ts
  where  i.ts#  = ts.ts#
  and    o.obj# = i.obj#
  and    bitand(i.property, 2) = 0
 UNION ALL
  select o.owner#, i.obj#, ts.name, ts.ts#      -- partitioned indexes
  from   sys.obj$ o, sys.ind$ i, sys.indpart$ ip, sys.ts$ ts
  where  ip.ts# = ts.ts#
  and    i.obj# = ip.bo#
  and    o.obj# = i.obj#
  and    bitand(i.property, 2) = 2
 UNION ALL
  select o.owner#, i.obj#, ts.name, ts.ts#      -- composite partitioned indexes
  from   sys.obj$ o, sys.ind$ i,
         sys.indcompart$ icp, sys.indsubpart$ isp, sys.ts$ ts
  where  isp.ts#  = ts.ts#
  and    icp.obj# = isp.pobj#
  and    i.obj#   = icp.bo#
  and    o.obj#   = i.obj#
  and    bitand(i.property, 2) = 2
/

create or replace force view sys.ku$_ind_ts_view ( owner_num, obj_num, ts_name ) as
  select i.owner_num, i.obj_num, i.ts_name
  from   sys.ku$_tts_ind_view i
  where  (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (i.owner_num,0) OR
                EXISTS ( SELECT * FROM sys.session_roles
                         WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

create or replace force view sys.ku$_clu_ts_view ( owner_num, obj_num, ts_name ) as
  select o.owner#, cl.obj#, ts.name
  from   sys.obj$ o, sys.clu$ cl, sys.ts$ ts
  where  cl.ts#  = ts.ts#
  and    o.obj# = cl.obj#
  and  (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (o.owner#,0) OR
                EXISTS ( SELECT * FROM sys.session_roles
                         WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

-- materialized views

create or replace force view sys.ku$_tts_mv_view ( owner_num, obj_num, ts_name ) as
  select o.owner#, t.obj#, ts.name              -- unpartitioned heap tables
  from   sys.obj$ o, sys.tab$ t, sys.user$ u, sys.snap$ s, sys.ts$ ts
  where  s.sowner = u.name
  and    s.tname  = o.name
  and    o.owner# = u.user#
  and    o.type#  = 2
  and    o.obj#   = t.obj#
  and    t.ts#    = ts.ts#
  and    bitand(t.property, 32+64+512) = 0
 UNION ALL
  select o.owner#, t.obj#, ts.name              -- simple partitions
  from   sys.obj$ o, sys.tab$ t, sys.tabpart$ tp,
         sys.user$ u, sys.snap$ s, sys.ts$ ts
  where  s.sowner = u.name
  and    s.tname  = o.name
  and    o.owner# = u.user#
  and    o.type#  = 2
  and    o.obj#   = t.obj#
  and    bitand(t.property, 32+64+512) = 32
  and    t.obj#   = tp.bo#
  and    tp.ts#   = ts.ts#
 UNION ALL
  select o.owner#, t.obj#, ts.name              -- composite partitions
  from   sys.obj$ o, sys.tab$ t,
         sys.tabcompart$ tcp, sys.tabsubpart$ tsp,
         sys.user$ u, sys.snap$ s, sys.ts$ ts
  where  s.sowner = u.name
  and    s.tname  = o.name
  and    o.owner# = u.user#
  and    o.type#  = 2
  and    o.obj#   = t.obj#
  and    bitand(t.property, 32+64+512) = 32
  and    t.obj#   = tcp.bo#
  and    tcp.obj# = tsp.pobj#
  and    tsp.ts#  = ts.ts#
 UNION ALL
  select o.owner#, t.obj#, ts.name              -- IOTs
  from   sys.obj$ o, sys.tab$ t, sys.ind$ i,
         sys.user$ u, sys.snap$ s, sys.ts$ ts
  where  s.sowner = u.name
  and    s.tname  = o.name
  and    o.owner# = u.user#
  and    o.type#  = 2
  and    o.obj#   = t.obj#
  and    bitand(t.property, 32+64+512) = 64
  and    i.ts#    = ts.ts#
  and    i.obj#   = t.pctused$
 UNION ALL
  select o.owner#, t.obj#, ts.name              -- PIOTs
  from   sys.obj$ o, sys.tab$ t, sys.indpart$ ip,
         sys.user$ u, sys.snap$ s, sys.ts$ ts
  where  s.sowner = u.name
  and    s.tname  = o.name
  and    o.owner# = u.user#
  and    o.type#  = 2
  and    o.obj#   = t.obj#
  and    bitand(t.property, 32+64+512) = 32 + 64
  and    ip.ts#   = ts.ts#
  and    ip.bo#   = t.pctused$
/

create or replace force view sys.ku$_mv_ts_view ( owner_num, obj_num, ts_name ) as
  select t.owner_num, t.obj_num, t.ts_name
  from   sys.ku$_tts_mv_view t
  where  (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (t.owner_num,0) OR
                EXISTS ( SELECT * FROM sys.session_roles
                         WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

-------------------------------------------------------------------------------
--                     MV_DEPTBL_OBJNUM
-- mv_deptbl_objnum view is used to find materialized view temp log tables
--  which must be exported with mv logs in transportable mode.
-------------------------------------------------------------------------------

create or replace force view sys.ku$_mv_deptbl_objnum_view of ku$_mv_deptbl_objnum_t
  with object identifier(obj_num) as
  select tlo.obj_num
  from sys.ku$_schemaobj_view mo, sys.ku$_schemaobj_view tlo, sys.mlog$ ml
  where mo.owner_name = ml.mowner and
        mo.name = ml.master and
        mo.owner_num = tlo.owner_num and
        tlo.name = ml.temp_log and
        mo.obj_num in (SELECT * FROM TABLE(DBMS_METADATA.FETCH_OBJNUMS)) and
        (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (mo.owner_num, 0) OR
              EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

-- materialized view logs

create or replace force view sys.ku$_tts_mvl_view ( owner_num, obj_num, ts_name ) as
  select o.owner#, t.obj#, ts.name              -- unpartitioned heap tables
  from   sys.obj$ o, sys.tab$ t, sys.user$ u, sys.mlog$ m, sys.ts$ ts
  where  m.mowner = u.name
  and    m.log    = o.name
  and    o.owner# = u.user#
  and    o.type#  = 2
  and    o.obj#   = t.obj#
  and    t.ts#    = ts.ts#
  and    bitand(t.property, 32) = 0
 UNION ALL
  select o.owner#, t.obj#, ts.name              -- simple partitions
  from   sys.obj$ o, sys.tab$ t, sys.tabpart$ tp,
         sys.user$ u, sys.mlog$ m, sys.ts$ ts
  where  m.mowner = u.name
  and    m.log    = o.name
  and    o.owner# = u.user#
  and    o.type#  = 2
  and    o.obj#   = t.obj#
  and    bitand(t.property, 32) = 32
  and    t.obj#   = tp.bo#
  and    tp.ts#   = ts.ts#
 UNION ALL
  select o.owner#, t.obj#, ts.name              -- composite partitions
  from   sys.obj$ o, sys.tab$ t,
         sys.tabcompart$ tcp, sys.tabsubpart$ tsp,
         sys.user$ u, sys.mlog$ m, sys.ts$ ts
  where  m.mowner = u.name
  and    m.log    = o.name
  and    o.owner# = u.user#
  and    o.type#  = 2
  and    o.obj#   = t.obj#
  and    bitand(t.property, 32) = 32
  and    t.obj#   = tcp.bo#
  and    tcp.obj# = tsp.pobj#
  and    tsp.ts#  = ts.ts#
/

create or replace force view sys.ku$_mvl_ts_view ( owner_num, obj_num, ts_name ) as
  select t.owner_num, t.obj_num, t.ts_name
  from   sys.ku$_tts_mvl_view t
  where  (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (t.owner_num,0) OR
                EXISTS ( SELECT * FROM sys.session_roles
                         WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

-------------------------------------------------------------------------------
--                              TABLE DATA
-------------------------------------------------------------------------------

-- View to determine if external tables unload method is required and if so, if
-- parallel ET will be allowed on unload.

create or replace force view ku$_unload_method_view
   (obj_num, unload_method, et_parallel)
   as select t.obj#,
      decode (
           -- Condition 1: Table has FGAC for SELECT enabled?
        (select count(*) from rls$ r where r.obj#=t.obj#
                and r.enable_flag=1 and bitand(r.stmt_type,1)=1)
        +  -- Condition 2 and 3: Encrypted cols or queue table?
        bitand(t.trigflag, 65536+8388608)
        + -- Condition 4a: BFILE columns?
        bitand(t.property, 32768)
        + -- Condition 4b: Opaque columns?
        (select count(*) FROM opqtype$ o where o.obj# = t.obj#)
        + -- Condition 5: Cols of evolved types that need upgrading?
        (select count(*) FROM coltype$ c where c.obj#=t.obj# and
                bitand(c.flags,256)>0)
--       Obsolete, now supported by direct unload.
--        + -- Condition 6: Any LONG or LONG RAW columns that are not last?
--        (select count(*) from col$ c where c.obj#=t.obj# and c.type# IN (8,24)
--                and c.segcol# !=
--                (select MAX(c2.segcol#) from col$ c2 where c2.obj#=t.obj#) )
        + -- Condition 7: Columns with embedded opaques?
        (select count(*) from coltype$ c, type$ ty where c.obj#=t.obj# and
                c.toid=ty.toid and bitand(ty.properties, 4096) > 0)
        + -- Condition 8: table with column added that has NOT NULL and
          -- DEFAULT VALUE specified
        (select count(*) from ecol$ e where e.tabobj# = t.obj#)
        + -- Condition 9: target is 10g instance and table contains subtype,
          -- sql_plan_allstat_row_type.  This subtype does not exist in 10.2.
        (select count(*) from subcoltype$ sc where sc.obj# = t.obj# and
                              sc.toid = '00000000000000000000000000020215' and
                              dbms_metadata.get_version < '11.00.00.00.00')
        + -- Condition 10: table with a RADM masking policy
        (select count(*) from radm$ r where r.obj# = t.obj#)
        + -- Condition 11: table is ILM enabled
          -- KQLDTVCP2_LIFECYCLE    0x00008000
        (bitand(t.property,(32768*4294967296)))
        + -- Condition 12: partitioned clustered table
          -- KQLDTVCP_PTI           0x00000020
          -- KQLDTVCP_CLU           0x00000400
        (decode (bitand(property,(32+1024)),(32+1024),1,0))
        + -- Condition 13: sharing=extended data
        (case when bitand(property,(1048576*power(2,32))) != 0 then 1
              else 0
         end)
       , 0, 1, 4),
--
-- NOTE: The values 1 and 4 from the decode above correspond to the constants
-- prefer_direct and require_external from the package kupd$data_int defined in
-- datapump/dml/prvthpdi. If these values ever change in the package, they must
-- be changed here as well. Can't use pkg's constants because catmeta executes
-- before pkg header is installed.
--
  --
  -- Ext. Tbls. cannot unload in parallel if:
  -- 1. FGAC (row level security) is enabled. Note: The data layer must execute
  --    as invoker's rights for unload on FGAC-enabled tables so the security 
  --    of the caller is enforced (security hole if SYS as definer unloaded the
  --    table). But, kxfp processes started in response to a parallel ET unload
  --    would also run as the unprived invoker and they then fail calling our
  --    internal definer's pkg's like queueing and file mgt. Forcing parallel=1
  --    in this case stays in the context of the worker process which *can* see
  --    the internal pkgs because they share the same owner (SYS).
  --
      decode (
        (select count(*) from rls$ r where r.obj#=t.obj# and r.enable_flag=1)
        , 0, 1, 0)  -- 1: Can do ET parallel unload  0: Can't
   from tab$ t
/
--  view for bytes allocated/table or partition

create or replace force view ku$_bytes_alloc_view of ku$_bytes_alloc_t
  with object OID(file_num,block_num,ts_num)
  as select s.file_num,s.block_num,ts.ts#,
       case when ts.bitmapped=0
            then ts.blocksize*s.blocks
            else dbms_metadata_util.bytes_alloc(ts.ts#,
                                                s.file_num,
                                                s.block_num,
                                                ts.blocksize)
        end
  from ku$_storage_view s, ts$ ts
  where ts.ts#     = s.ts_num
/

create or replace force view ku$_htable_bytes_alloc_view
                          of ku$_tab_bytes_alloc_t
  with object OID(obj_num)
  as select t.obj#,
            (select b.bytes_alloc from ku$_bytes_alloc_view b
             where b.ts_num = t.ts#
               and b.file_num = t.file#
               and b.block_num = t.block#)
          +decode(bitand(t.property,2048+262144),0,0,   -- add lob storage
            (select sum(b.bytes_alloc) from ku$_bytes_alloc_view b, lob$ l
             where b.ts_num = l.ts#
               and b.file_num = l.file#
               and b.block_num = l.block#
               and l.obj#=t.obj#))
  from tab$ t
/

-- views for the TABLE_DATA object type.

-- Heap TABLEs that are unpartitioned

create or replace force view ku$_htable_data_view of ku$_table_data_t
  with object OID(obj_num)
  as select '1','2',
         t.obj#, o.dataobj_num,
         o.name,
         NULL,
         0,  /* not partitioned */
         bitand(t.property, 4294967295),
         trunc(t.property / power(2, 32)),
         t.trigflag,
         dbms_metadata_util.get_xmltype_fmts(t.obj#),
         decode((select 1 from dual where
                 (exists (select q.obj# from sys.opqtype$ q
                          where q.obj#=t.obj#
                          and q.type=1                        /* xmltype col */
                          and bitand(q.flags,2+64)!=0))),       /* CSX or SB */
                1,'Y','N'),
         decode((select count(*)                      /* outofline xml table */
                    from sys.opqtype$ q
                    where q.obj# = t.obj# and
                          bitand(q.flags, 32) = 32 ),
                1,'Y','N'),
         decode((select count(*) from col$ where obj#=t.obj#
                 and type# in (8,24)),        /* long col - long or long raw */
                 1,'Y','N'),
         decode((select count(*) from sys.type$ ty, sys.coltype$ ct
                 where ty.toid=ct.toid and ty.version#=ct.version#
                 and ct.obj#=t.obj#
                 /* 0x00008000 =   32768 = contains varray attribute */
                 /* 0x00100000 = 1048576 = has embedded non final type */
                 and bitand(ty.properties,1081344)=1081344),
                 0,'N','Y'),
         decode((select count(*) from sys.refcon$ rf, sys.col$ c
                 where c.obj#=rf.obj# and c.intcol#=rf.intcol#
                 and c.obj#=t.obj#
                 and bitand(rf.reftyp,1)=0),            /* ref is non-scoped */
                 0,'N','Y'),
         (select sys.dbms_metadata_util.has_tstz_cols(t.obj#) from dual),
         value(o),
         ts.name, ts.ts#, ts.blocksize,
         (select dbms_metadata_util.block_estimate(t.obj#,1) from dual),
         value(o),
         -- if this is a secondary table, get domidx obj and ancestor obj
         decode(bitand(o.flags, 16), 16,
           (select value(oo) from ku$_schemaobj_view oo, secobj$ s
              where o.obj_num=s.secobj#
                and oo.obj_num=s.obj#
                and rownum < 2),
           null),
         decode(bitand(o.flags, 16), 16,
           (select value(oo) from ku$_schemaobj_view oo, ind$ i, secobj$ s
              where o.obj_num=s.secobj#
                and i.obj#=s.obj#
                and oo.obj_num=i.bo#
                and rownum < 2),
           null),
         um.unload_method,
         um.et_parallel,
         (select count(*) from rls$ r
          where r.obj#=t.obj# and r.enable_flag=1 and bitand(r.stmt_type,1)=1),
         0,
         decode(bitand(t.trigflag,2097152),0,'N','Y')   -- read-only (table)
  from  ku$_schemaobjnum_view o,
        ku$_unload_method_view um, tab$ t, ts$ ts
  where t.obj# = o.obj_num
        AND t.obj# = um.obj_num
        AND bitand(t.property,
                   32+64+128+256+512+8192+4194304+8388608+2147483648) = 0
                                                /* not IOT, partitioned,    */
                                                /* nested, temporary or     */
                                                /* external table           */
        AND bitand(trunc(t.property/power(2,32)),1)=0
                                                /* not cube organized table */
        AND bitand(trunc(t.property/power(2,32)),2)=0
                                                /* not FBA internal table   */
        AND bitand(t.flags,536870912)=0         /* not an IOT mapping table */
        AND t.ts# = ts.ts#
        AND (bitand(o.flags,16)!=16
             OR sys.dbms_metadata.oktoexp_2ndary_table(o.obj_num)=1)
        AND (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (o.owner_num, 0) OR
                EXISTS ( SELECT * FROM sys.session_roles
                         WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

-- partitions

create or replace force view ku$_htpart_bytes_alloc_view of ku$_tab_bytes_alloc_t
  with object OID(obj_num)
  as select tp.obj#,
            (select b.bytes_alloc from ku$_bytes_alloc_view b
             where b.ts_num = tp.ts#
               and b.file_num = tp.file#
               and b.block_num = tp.block#)
          +decode(bitand(t.property,2048+262144),0,0,   -- add lob storage
            (select sum(b.bytes_alloc) from ku$_bytes_alloc_view b, lobfrag$ l
             where b.ts_num = l.ts#
               and b.file_num = l.file#
               and b.block_num = l.block#
               and l.tabfragobj#=tp.obj#))
  from tab$ t, tabpart$ tp
  where t.obj#=tp.bo#
/

-- Note: bug #8692663
--   Heap Tables that are PARTitioned required obj# rather than dataobj#. This
--   is evident during network imports of a hpart table in which there has been
--   a partition added. To minimize the work (i.e., end of release cycle) we
--   return obj# in dataobj# field. This allows supporting pieces to work
--   without modification.
create or replace force view ku$_htpart_data_view of ku$_table_data_t
  with object OID(obj_num)
  as select '1','2',
         tp.obj#, tp.obj#,
         o.subname,
         NULL,
         po.parttype,
         bitand(t.property, 4294967295),
         trunc(t.property / power(2, 32)),
         t.trigflag,
         dbms_metadata_util.get_xmltype_fmts(t.obj#),
         decode((select 1 from dual where
                 (exists (select q.obj# from sys.opqtype$ q
                          where q.obj#=t.obj#
                          and q.type=1                        /* xmltype col */
                          and bitand(q.flags,2+64)!=0))),       /* CSX or SB */
                1,'Y','N'),
         decode((select count(*)                      /* outofline xml table */
                    from sys.opqtype$ q
                    where q.obj# = t.obj# and
                          bitand(q.flags, 32) = 32 ),
                1,'Y','N'),
         'N',     /* partitioned table cannot have column with LONG datatype */
         decode((select count(*) from sys.type$ ty, sys.coltype$ ct
                 where ty.toid=ct.toid and ty.version#=ct.version#
                 and ct.obj#=t.obj#
                 /* 0x00008000 =   32768 = contains varray attribute */
                 /* 0x00100000 = 1048576 = has embedded non final type */
                 and bitand(ty.properties,1081344)=1081344),
                 0,'N','Y'),
         decode((select count(*) from sys.refcon$ rf, sys.col$ c
                 where c.obj#=rf.obj# and c.intcol#=rf.intcol#
                 and c.obj#=t.obj#
                 and bitand(rf.reftyp,1)=0),            /* ref is non-scoped */
                 0,'N','Y'),
         (select sys.dbms_metadata_util.has_tstz_cols(t.obj#) from dual),
         value(o),
         ts.name, ts.ts#, ts.blocksize,
         (select dbms_metadata_util.block_estimate(tp.obj#,2) from dual),
         value(bo),
         -- if this is a secondary table, get domidx obj and ancestor obj
         decode(bitand(bo.flags, 16), 16,
           (select value(oo) from ku$_schemaobj_view oo, secobj$ s
              where bo.obj_num=s.secobj#
                and oo.obj_num=s.obj#
                and rownum < 2),
           null),
         decode(bitand(bo.flags, 16), 16,
           (select value(oo) from ku$_schemaobj_view oo, ind$ i, secobj$ s
              where bo.obj_num=s.secobj#
                and i.obj#=s.obj#
                and oo.obj_num=i.bo#
                and rownum < 2),
           null),
         um.unload_method,
         um.et_parallel,
         (select count(*) from rls$ r
          where r.obj#=t.obj# and r.enable_flag=1 and bitand(r.stmt_type,1)=1),
         sys.dbms_metadata_util.ref_par_level(bo.obj_num,t.property),
         decode(bitand(tp.flags,67108864),0,'N','Y')   -- read-only (partition)
  from ku$_schemaobj_view o,
       ku$_schemaobjnum_view bo, ku$_unload_method_view um,
       tab$ t, tabpart$ tp, ts$ ts, partobj$ po
  where tp.obj# = o.obj_num
        AND bo.obj_num = po.obj#
        AND t.obj#=tp.bo#
        AND t.obj# = um.obj_num
        AND bitand(t.property, 32+64+128+256+512+8192+2147483648) = 32
                                                /* partitioned (32)       */
                                                /* but not IOT            */
                                                /* or nested table        */
                                                /* or external table      */
        AND bitand(t.flags,536870912)=0         /* not an IOT mapping table */
        AND bitand(tp.flags,8388608)=0        /* not hidden for online move */
        AND tp.ts# = ts.ts#
        AND bo.obj_num=tp.bo#
        AND bitand(trunc(t.property/power(2,32)),1)=0
                                                /* not cube organized table */
        AND (bitand(bo.flags,16)!=16
             OR sys.dbms_metadata.oktoexp_2ndary_table(bo.obj_num)=1)
        AND (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (o.owner_num, 0) OR
                EXISTS ( SELECT * FROM sys.session_roles
                         WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

-- subpartitions

create or replace force view ku$_htspart_bytes_alloc_view
  of ku$_tab_bytes_alloc_t
  with object OID(obj_num)
  as select tsp.obj#,
            (select b.bytes_alloc from ku$_bytes_alloc_view b
             where b.ts_num = tsp.ts#
               and b.file_num = tsp.file#
               and b.block_num = tsp.block#)
          +decode(bitand(t.property,2048+262144),0,0,   -- add lob storage
            (select sum(b.bytes_alloc) from ku$_bytes_alloc_view b, lobfrag$ l
             where b.ts_num = l.ts#
               and b.file_num = l.file#
               and b.block_num = l.block#
               and l.tabfragobj#=tsp.obj#))
  from tab$ t, tabcompart$ tcp, tabsubpart$ tsp
  where t.obj#=tcp.bo#
    AND tcp.obj# = tsp.pobj#
/

-- Note: bug #8692663
--   Heap Tables that are SubPARTitioned required obj# rather than dataobj#.
--   This is evident during network imports of a hpart table in which there
--   has been a subpartition added. To minimize the work (i.e., end of release
--   cycle) we return obj# in dataobj# field. This allows supporting pieces
--   to work without modification.
create or replace force view ku$_htspart_data_view of ku$_table_data_t
  with object OID(obj_num)
  as select '1','2',
         tsp.obj#, tsp.obj#,
         o.subname,
         (select po.subname from obj$ po where po.obj#=tsp.pobj#),
         po.parttype,
         bitand(t.property, 4294967295),
         trunc(t.property / power(2, 32)),
         t.trigflag,
         dbms_metadata_util.get_xmltype_fmts(t.obj#),
         decode((select 1 from dual where
                 (exists (select q.obj# from sys.opqtype$ q
                          where q.obj#=t.obj#
                          and q.type=1                        /* xmltype col */
                          and bitand(q.flags,2+64)!=0))),       /* CSX or SB */
                1,'Y','N'),
         decode((select count(*)                      /* outofline xml table */
                    from sys.opqtype$ q
                    where q.obj# = t.obj# and
                          bitand(q.flags, 32) = 32 ),
                1,'Y','N'),
         'N',     /* partitioned table cannot have column with LONG datatype */
         decode((select count(*) from sys.type$ ty, sys.coltype$ ct
                 where ty.toid=ct.toid and ty.version#=ct.version#
                 and ct.obj#=t.obj#
                 /* 0x00008000 =   32768 = contains varray attribute */
                 /* 0x00100000 = 1048576 = has embedded non final type */
                 and bitand(ty.properties,1081344)=1081344),
                 0,'N','Y'),
         decode((select count(*) from sys.refcon$ rf, sys.col$ c
                 where c.obj#=rf.obj# and c.intcol#=rf.intcol#
                 and c.obj#=t.obj#
                 and bitand(rf.reftyp,1)=0),            /* ref is non-scoped */
                 0,'N','Y'),
         (select sys.dbms_metadata_util.has_tstz_cols(t.obj#) from dual),
         value(o),
         ts.name, ts.ts#, ts.blocksize,
         (select dbms_metadata_util.block_estimate(tsp.obj#,3) from dual),
         value(bo),
         -- if this is a secondary table, get domidx obj and ancestor obj
         decode(bitand(bo.flags, 16), 16,
           (select value(oo) from ku$_schemaobj_view oo, secobj$ s
              where bo.obj_num=s.secobj#
                and oo.obj_num=s.obj#
                and rownum < 2),
           null),
         decode(bitand(bo.flags, 16), 16,
           (select value(oo) from ku$_schemaobj_view oo, ind$ i, secobj$ s
              where bo.obj_num=s.secobj#
                and i.obj#=s.obj#
                and oo.obj_num=i.bo#
                and rownum < 2),
           null),
         um.unload_method,
         um.et_parallel,
         (select count(*) from rls$ r
          where r.obj#=t.obj# and r.enable_flag=1 and bitand(r.stmt_type,1)=1),
         sys.dbms_metadata_util.ref_par_level(bo.obj_num,t.property),
         decode(bitand(tsp.flags,67108864),0,'N','Y')   -- read-only (subpartition)
  from  ku$_schemaobj_view o, ku$_schemaobjnum_view bo,
        ku$_unload_method_view um, tab$ t, tabcompart$ tcp,
        tabsubpart$ tsp, ts$ ts, partobj$ po
  where tsp.obj# = o.obj_num
        AND bo.obj_num = po.obj#
        AND t.obj#=tcp.bo#
        AND t.obj# = um.obj_num
        AND bitand(t.property, 32+64+128+256+512+8192+2147483648) = 32
                                                /* partitioned (32)       */
                                                /* but not IOT            */
                                                /* or nested table        */
                                                /* or external table      */
        AND bitand(t.flags,536870912)=0         /* not an IOT mapping table */
        AND bitand(tsp.flags,8388608)=0       /* not hidden for online move */
        AND tsp.ts# = ts.ts#
        AND tcp.obj# = tsp.pobj#
        AND bo.obj_num=tcp.bo#
        AND bitand(trunc(t.property/power(2,32)),1)=0
                                                /* not cube organized table */
        AND (bitand(bo.flags,16)!=16
             OR sys.dbms_metadata.oktoexp_2ndary_table(bo.obj_num)=1)
        AND (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (o.owner_num, 0) OR
                EXISTS ( SELECT * FROM sys.session_roles
                         WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

-- IOTs

create or replace force view ku$_iotable_bytes_alloc_view
 of ku$_tab_bytes_alloc_t
  with object OID(obj_num)
  as select t.obj#,
            (select b.bytes_alloc from ku$_bytes_alloc_view b
             where b.ts_num = i.ts#
               and b.file_num = i.file#
               and b.block_num = i.block#)
          +decode(bitand(t.property,2048+262144),0,0,   -- add lob storage
            (select sum(b.bytes_alloc) from ku$_bytes_alloc_view b, lob$ l
             where b.ts_num = l.ts#
               and b.file_num = l.file#
               and b.block_num = l.block#
               and l.obj#=t.obj#))
  from ind$ i, tab$ t
  where t.pctused$ = i.obj#          -- For IOTs, pctused has index obj#
/

create or replace force view ku$_iotable_data_view of ku$_table_data_t
  with object OID(obj_num)
  as select '1','2',
         t.obj#, o.dataobj_num,
         o.name,
         NULL,
         0,
         bitand(t.property, 4294967295),
         trunc(t.property / power(2, 32)),
         t.trigflag,
         dbms_metadata_util.get_xmltype_fmts(t.obj#),
         decode((select 1 from dual where
                 (exists (select q.obj# from sys.opqtype$ q
                          where q.obj#=t.obj#
                          and q.type=1                        /* xmltype col */
                          and bitand(q.flags,2+64)!=0))),       /* CSX or SB */
                1,'Y','N'),
         decode((select count(*)                      /* outofline xml table */
                    from sys.opqtype$ q
                    where q.obj# = t.obj# and
                          bitand(q.flags, 32) = 32 ),
                1,'Y','N'),
         'N',                   /* IOT can't contain long or long raw column */
         decode((select count(*) from sys.type$ ty, sys.coltype$ ct
                 where ty.toid=ct.toid and ty.version#=ct.version#
                 and ct.obj#=t.obj#
                 /* 0x00008000 =   32768 = contains varray attribute */
                 /* 0x00100000 = 1048576 = has embedded non final type */
                 and bitand(ty.properties,1081344)=1081344),
                 0,'N','Y'),
         decode((select count(*) from sys.refcon$ rf, sys.col$ c
                 where c.obj#=rf.obj# and c.intcol#=rf.intcol#
                 and c.obj#=t.obj#
                 and bitand(rf.reftyp,1)=0),            /* ref is non-scoped */
                 0,'N','Y'),
         (select sys.dbms_metadata_util.has_tstz_cols(t.obj#) from dual),
         value(o),
         ts.name, ts.ts#, ts.blocksize,
         (select dbms_metadata_util.block_estimate(t.obj#,4) from dual),
         value(o),
         -- if this is a secondary table, get domidx obj and ancestor obj
         decode(bitand(o.flags, 16), 16,
           (select value(oo) from ku$_schemaobj_view oo, secobj$ s
              where o.obj_num=s.secobj#
                and oo.obj_num=s.obj#
                and rownum < 2),
           null),
         decode(bitand(o.flags, 16), 16,
           (select value(oo) from ku$_schemaobj_view oo, ind$ i, secobj$ s
              where o.obj_num=s.secobj#
                and i.obj#=s.obj#
                and oo.obj_num=i.bo#
                and rownum < 2),
           null),
         um.unload_method,
         um.et_parallel,
         (select count(*) from rls$ r
          where r.obj#=t.obj# and r.enable_flag=1 and bitand(r.stmt_type,1)=1),
         0,
         decode(bitand(t.trigflag,2097152),0,'N','Y')   -- read-only (table)
  from  ku$_schemaobjnum_view o, ku$_unload_method_view um, tab$ t, ind$ i,
        ts$ ts
  where t.obj# = o.obj_num
        AND t.obj# = um.obj_num
        and bitand(t.property, 64+512) = 64  -- IOT but not overflow
        and bitand(t.property, 32+8192) = 0     /* but not partitioned    */
                                                /* or nested table        */
        and t.pctused$ = i.obj#          -- For IOTs, pctused has index obj#
        AND i.ts# = ts.ts#
        AND bitand(trunc(t.property/power(2,32)),1)=0
                                                /* not cube organized table */
        AND (bitand(o.flags,16)!=16
             OR sys.dbms_metadata.oktoexp_2ndary_table(o.obj_num)=1)
        AND (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (o.owner_num, 0) OR
                EXISTS ( SELECT * FROM sys.session_roles
                         WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

-- PIOT partitions

create or replace force view ku$_iotpart_bytes_alloc_view
  of ku$_tab_bytes_alloc_t
  with object OID(obj_num)
  as select ip.obj#,
            (select b.bytes_alloc from ku$_bytes_alloc_view b
             where b.ts_num = ip.ts#
               and b.file_num = ip.file#
               and b.block_num = ip.block#)
          +decode(bitand(t.property,2048+262144),0,0,   -- add lob storage
            (select sum(b.bytes_alloc)
             from ku$_bytes_alloc_view b, lob$ l,lobfrag$ lf
             where lf.frag#=ip.part#
               and t.obj#=l.obj# and l.lobj#=lf.parentobj#
               and b.ts_num = lf.ts#
               and b.file_num = lf.file#
               and b.block_num = lf.block#))
  from ind$ i, indpart$ ip, tab$ t
  where i.bo#=t.obj#
    and ip.bo#=i.obj#
    and i.type#=4           -- iot index
/

-- dataobj_num is used in network mode to select a partition;
-- for IOTs this should be the obj# of the index partition whose
-- base object name = the table name (other data is for the index partition
-- whose base object name is the associated index)
-- Note: type# check is done to eliminate different object types which
--       have the same name as the baseobj.
create or replace force view ku$_iotpart_data_view of ku$_table_data_t
  with object OID(obj_num)
  as select '1','2',
         ip.obj#,
         (select o1.obj#
          from obj$ o1
          where o1.name=bo.name
            and o1.subname=o.subname
            and o1.owner#=o.owner_num
            and o1.type# in (19,34)),                         /* see note above */
         o.subname,
         NULL,
         po.parttype,
         bitand(t.property, 4294967295),
         trunc(t.property / power(2, 32)),
         t.trigflag,
         dbms_metadata_util.get_xmltype_fmts(t.obj#),
         decode((select 1 from dual where
                 (exists (select q.obj# from sys.opqtype$ q
                          where q.obj#=t.obj#
                          and q.type=1                        /* xmltype col */
                          and bitand(q.flags,2+64)!=0))),       /* CSX or SB */
                1,'Y','N'),
         decode((select count(*)                      /* outofline xml table */
                    from sys.opqtype$ q
                    where q.obj# = t.obj# and
                          bitand(q.flags, 32) = 32 ),
                1,'Y','N'),
         'N',     /* partitioned table cannot have column with LONG datatype */
         decode((select count(*) from sys.type$ ty, sys.coltype$ ct
                 where ty.toid=ct.toid and ty.version#=ct.version#
                 and ct.obj#=t.obj#
                 /* 0x00008000 =   32768 = contains varray attribute */
                 /* 0x00100000 = 1048576 = has embedded non final type */
                 and bitand(ty.properties,1081344)=1081344),
                 0,'N','Y'),
         decode((select count(*) from sys.refcon$ rf, sys.col$ c
                 where c.obj#=rf.obj# and c.intcol#=rf.intcol#
                 and c.obj#=t.obj#
                 and bitand(rf.reftyp,1)=0),            /* ref is non-scoped */
                 0,'N','Y'),
         (select sys.dbms_metadata_util.has_tstz_cols(t.obj#) from dual),
         value(o),
         ts.name, ts.ts#, ts.blocksize,
         (select dbms_metadata_util.block_estimate(ip.obj#,5) from dual),
         value(bo),
         -- if this is a secondary table, get domidx obj and ancestor obj
         decode(bitand(bo.flags, 16), 16,
           (select value(oo) from ku$_schemaobj_view oo, secobj$ s
              where bo.obj_num=s.secobj#
                and oo.obj_num=s.obj#
                and rownum < 2),
           null),
         decode(bitand(bo.flags, 16), 16,
           (select value(oo) from ku$_schemaobj_view oo, ind$ i, secobj$ s
              where bo.obj_num=s.secobj#
                and i.obj#=s.obj#
                and oo.obj_num=i.bo#
                and rownum < 2),
           null),
         um.unload_method,
         um.et_parallel,
         (select count(*) from rls$ r
          where r.obj#=t.obj# and r.enable_flag=1 and bitand(r.stmt_type,1)=1),
         0,   -- note: piot cannot be ref partitioned,
         decode(bitand((select tp.flags from tabpart$ tp 
                        where tp.part#=ip.part# and tp.bo#=i.bo#),
                       67108864),0,'N','Y')   -- read-only (partition)
  from  ku$_schemaobj_view o, ku$_schemaobjnum_view bo,
        ku$_unload_method_view um, tab$ t,
        ind$ i, indpart$ ip, ts$ ts, partobj$ po
  where ip.obj# = o.obj_num
        AND o.type_num = 20     -- index partition
        AND bo.obj_num = po.obj#
        AND ip.bo#=i.obj#
        AND i.type#=4           -- iot index
        AND i.bo#=t.obj#
        AND t.obj# = um.obj_num
        AND ip.ts# = ts.ts#
        AND bo.obj_num=i.bo#
        AND bitand(trunc(t.property/power(2,32)),1)=0
                                                /* not cube organized table */
        AND (bitand(bo.flags,16)!=16
             OR sys.dbms_metadata.oktoexp_2ndary_table(bo.obj_num)=1)
        AND (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (o.owner_num, 0) OR
                EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

-- nested tables
create or replace force view ku$_ntable_bytes_alloc_view
 of ku$_tab_bytes_alloc_t
  with object OID(obj_num)
  as select case when bitand(t.property,64)=0
                 then (select value(b1) from ku$_htable_bytes_alloc_view b1
                       where b1.obj_num = t.obj#)
                 else (select value(b2) from ku$_iotable_bytes_alloc_view b2
                       where b2.obj_num = t.obj#)
                 end
  from tab$ t
/

-- nested tables - not IOT
create or replace force view ku$_ntable_data_view of ku$_table_data_t
  with object OID(obj_num)
  as select '1','2',
         t.obj#, o.dataobj_num,
         o.name,
         NULL,
         0,
         bitand(t.property, 4294967295),
         trunc(t.property / power(2, 32)),
         t.trigflag,
         dbms_metadata_util.get_xmltype_fmts(t.obj#),
         decode((select 1 from dual where
                 (exists (select q.obj# from sys.opqtype$ q
                          where q.obj#=t.obj#
                          and q.type=1                        /* xmltype col */
                          and bitand(q.flags,2+64)!=0))),       /* CSX or SB */
                1,'Y','N'),
         decode((select count(*)                      /* outofline xml table */
                    from sys.opqtype$ q
                    where q.obj# = t.obj# and
                          bitand(q.flags, 32) = 32 ),
                1,'Y','N'),
         'N',                    /* nested table can't have long or long raw */
         decode((select count(*) from sys.type$ ty, sys.coltype$ ct
                 where ty.toid=ct.toid and ty.version#=ct.version#
                 and ct.obj#=t.obj#
                 /* 0x00008000 =   32768 = contains varray attribute */
                 /* 0x00100000 = 1048576 = has embedded non final type */
                 and bitand(ty.properties,1081344)=1081344),
                 0,'N','Y'),
         decode((select count(*) from sys.refcon$ rf, sys.col$ c
                 where c.obj#=rf.obj# and c.intcol#=rf.intcol#
                 and c.obj#=t.obj#
                 and bitand(rf.reftyp,1)=0),            /* ref is non-scoped */
                 0,'N','Y'),
         (select sys.dbms_metadata_util.has_tstz_cols(t.obj#) from dual),
         value(o),
         ts.name, ts.ts#, ts.blocksize,
        (select dbms_metadata_util.block_estimate(t.obj#,6) from dual),
         value(bo),
         -- if this is a secondary table, get domidx obj and ancestor obj
         decode(bitand(bo.flags, 16), 16,
           (select value(oo) from ku$_schemaobj_view oo, secobj$ s
              where bo.obj_num=s.secobj#
                and oo.obj_num=s.obj#
                and rownum < 2),
           null),
         decode(bitand(bo.flags, 16), 16,
           (select value(oo) from ku$_schemaobj_view oo, ind$ i, secobj$ s
              where bo.obj_num=s.secobj#
                and i.obj#=s.obj#
                and oo.obj_num=i.bo#
                and rownum < 2),
           null),
         um.unload_method,
         um.et_parallel,
         (select count(*) from rls$ r
          where r.obj#=t.obj# and r.enable_flag=1 and bitand(r.stmt_type,1)=1),
         0,
         decode(bitand(t.trigflag,2097152),0,'N','Y')   -- read-only (table)
  from  ku$_schemaobj_view o, ku$_schemaobjnum_view bo,
        ku$_unload_method_view um, tab$ t, ts$ ts
  where t.obj# = o.obj_num
        AND t.obj# in (select * from table(dbms_metadata.fetch_objnums('N')))
        AND t.obj# = um.obj_num
        AND bitand(t.property,8192)!=0      /* is a nested table */
        AND bitand(t.property, 64+512) = 0   /* IOT but not overflow */
        AND bitand(t.property,32) =0        /* is not partitioned */
        AND t.ts# = ts.ts#
        AND bitand(trunc(t.property/power(2,32)),1)=0
                                                /* not cube organized table */
        AND bo.obj_num = dbms_metadata_util.get_anc(t.obj#,0)
        AND (bitand(bo.flags,16)!=16
             OR sys.dbms_metadata.oktoexp_2ndary_table(bo.obj_num)=1)
        AND (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (o.owner_num, 0) OR
                EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

-- nested tables - index organized
create or replace force view ku$_niotable_data_view of ku$_table_data_t
  with object OID(obj_num)
  as select '1','2',
         t.obj#, o.dataobj_num,
         o.name,
         NULL,
         0,
         bitand(t.property, 4294967295),
         trunc(t.property / power(2, 32)),
         t.trigflag,
         dbms_metadata_util.get_xmltype_fmts(t.obj#),
         decode((select 1 from dual where
                 (exists (select q.obj# from sys.opqtype$ q
                          where q.obj#=t.obj#
                          and q.type=1                        /* xmltype col */
                          and bitand(q.flags,2+64)!=0))),       /* CSX or SB */
                1,'Y','N'),
         decode((select count(*)                      /* outofline xml table */
                    from sys.opqtype$ q
                    where q.obj# = t.obj# and
                          bitand(q.flags, 32) = 32 ),
                1,'Y','N'),
         'N',                    /* nested table can't have long or long raw */
         decode((select count(*) from sys.type$ ty, sys.coltype$ ct
                 where ty.toid=ct.toid and ty.version#=ct.version#
                 and ct.obj#=t.obj#
                 /* 0x00008000 =   32768 = contains varray attribute */
                 /* 0x00100000 = 1048576 = has embedded non final type */
                 and bitand(ty.properties,1081344)=1081344),
                 0,'N','Y'),
         decode((select count(*) from sys.refcon$ rf, sys.col$ c
                 where c.obj#=rf.obj# and c.intcol#=rf.intcol#
                 and c.obj#=t.obj#
                 and bitand(rf.reftyp,1)=0),            /* ref is non-scoped */
                 0,'N','Y'),
         (select sys.dbms_metadata_util.has_tstz_cols(t.obj#) from dual),
         value(o),
         ts.name, ts.ts#, ts.blocksize,
        (select b.bytes_alloc from ku$_iotable_bytes_alloc_view b
          where b.obj_num=t.obj#) bytes_alloc,
         value(bo),
         -- if this is a secondary table, get domidx obj and ancestor obj
         decode(bitand(bo.flags, 16), 16,
           (select value(oo) from ku$_schemaobj_view oo, secobj$ s
              where bo.obj_num=s.secobj#
                and oo.obj_num=s.obj#
                and rownum < 2),
           null),
         decode(bitand(bo.flags, 16), 16,
           (select value(oo) from ku$_schemaobj_view oo, ind$ i, secobj$ s
              where bo.obj_num=s.secobj#
                and i.obj#=s.obj#
                and oo.obj_num=i.bo#
                and rownum < 2),
           null),
         um.unload_method,
         um.et_parallel,
         (select count(*) from rls$ r
          where r.obj#=t.obj# and r.enable_flag=1 and bitand(r.stmt_type,1)=1),
         0,
         decode(bitand(t.trigflag,2097152),0,'N','Y')   -- read-only (table)
from  ku$_schemaobj_view o, ku$_schemaobjnum_view bo,
        ku$_unload_method_view um, tab$ t, ind$ i, ts$ ts
  where t.obj# = o.obj_num
        AND t.obj# in (select * from table(dbms_metadata.fetch_objnums('N')))
        AND t.obj# = um.obj_num
        AND bitand(t.property,8192)!=0           /* is a nested table */
        AND bitand(t.property, 64+512) = 64   /* IOT but not overflow */
        AND bitand(t.property,32) =0            /* is not partitioned */
        AND t.pctused$ = i.obj#   /* for IOTs, pctused has index obj# */
        AND i.ts# = ts.ts#
        AND bitand(trunc(t.property/power(2,32)),1)=0
                                                /* not cube organized table */
        AND bo.obj_num = dbms_metadata_util.get_anc(t.obj#,0)
        AND (bitand(bo.flags,16)!=16
             OR sys.dbms_metadata.oktoexp_2ndary_table(bo.obj_num)=1)
        AND (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (o.owner_num, 0) OR
                EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

-- equipartition nested table
create or replace force view ku$_eqntable_bytes_alloc_view
                        of ku$_tab_bytes_alloc_t
  with object OID(obj_num)
as select tp.obj#,
            (select b.bytes_alloc from ku$_bytes_alloc_view b
             where b.ts_num = tp.ts#
               and b.file_num = tp.file#
               and b.block_num = tp.block#)
  from tab$ t, tabpart$ tp
  where t.obj#=tp.bo#
        and bitand(t.property, 32+8192+536870912)=536879136

/

create or replace force view ku$_eqntable_data_view of ku$_table_data_t
  with object OID(obj_num)
  as select '1','2',
         tp.obj#,  o.dataobj_num,
         o.subname,
         NULL,
         0,
         bitand(t.property, 4294967295),
         trunc(t.property / power(2, 32)),
         t.trigflag,
         dbms_metadata_util.get_xmltype_fmts(t.obj#),
         decode((select 1 from dual where
                 (exists (select q.obj# from sys.opqtype$ q
                          where q.obj#=t.obj#
                          and q.type=1                        /* xmltype col */
                          and bitand(q.flags,2+64)!=0))),       /* CSX or SB */
                1,'Y','N'),
         decode((select count(*)                     /* outofline xml table */
                    from sys.opqtype$ q
                    where q.obj# = t.obj# and
                          bitand(q.flags, 32) = 32 ),
                1,'Y','N'),
         'N',                    /* nested table can't have long or long raw */
         decode((select count(*) from sys.type$ ty, sys.coltype$ ct
                 where ty.toid=ct.toid and ty.version#=ct.version#
                 and ct.obj#=t.obj#
                 /* 0x00008000 =   32768 = contains varray attribute */
                 /* 0x00100000 = 1048576 = has embedded non final type */
                 and bitand(ty.properties,1081344)=1081344),
                 0,'N','Y'),
         decode((select count(*) from sys.refcon$ rf, sys.col$ c
                 where c.obj#=rf.obj# and c.intcol#=rf.intcol#
                 and c.obj#=t.obj#
                 and bitand(rf.reftyp,1)=0),            /* ref is non-scoped */
                 0,'N','Y'),
         (select sys.dbms_metadata_util.has_tstz_cols(t.obj#) from dual),
         value(o),
         ts.name, ts.ts#, ts.blocksize,
        (select dbms_metadata_util.block_estimate(tp.obj#,7) from dual),
         value(bo),
         -- if this is a secondary table, get domidx obj and ancestor obj
         decode(bitand(bo.flags, 16), 16,
           (select value(oo) from ku$_schemaobj_view oo, secobj$ s
              where bo.obj_num=s.secobj#
                and oo.obj_num=s.obj#
                and rownum < 2),
           null),
         decode(bitand(bo.flags, 16), 16,
           (select value(oo) from ku$_schemaobj_view oo, ind$ i, secobj$ s
              where bo.obj_num=s.secobj#
                and i.obj#=s.obj#
                and oo.obj_num=i.bo#
                and rownum < 2),
           null),
         um.unload_method,
         um.et_parallel,
         (select count(*) from rls$ r
          where r.obj#=t.obj# and r.enable_flag=1 and bitand(r.stmt_type,1)=1),
         sys.dbms_metadata_util.ref_par_level(tp.bo#,t.property),
         decode(bitand(tp.flags,67108864),0,'N','Y')   -- read-only (partition)
  from ku$_schemaobj_view o,
       ku$_schemaobjnum_view bo, ku$_unload_method_view um,
       tab$ t, ntab$ nt, tabpart$ tp, ts$ ts
  where tp.obj# = o.obj_num
        AND t.obj# in (select * from table(dbms_metadata.fetch_objnums('N')))
        AND t.obj#=tp.bo#
        AND t.obj# = um.obj_num
        AND bitand(t.property, 32+8192+536870912)=536879136
        AND tp.ts# = ts.ts#
        AND nt.ntab#=tp.bo#
        AND bitand(trunc(t.property/power(2,32)),1)=0
                                                /* not cube organized table */
        AND bo.obj_num = dbms_metadata_util.get_anc(t.obj#,0)
        AND (bitand(bo.flags,16)!=16
            OR sys.dbms_metadata.oktoexp_2ndary_table(bo.obj_num)=1)
        AND (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (o.owner_num, 0) OR
                EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

-- UNION

create or replace force view ku$_table_data_view of ku$_table_data_t
  with object OID(obj_num)
  as
  select * from ku$_htable_data_view
  UNION ALL
  select * from ku$_htpart_data_view
  UNION ALL
  select * from ku$_htspart_data_view
  UNION ALL
  select * from ku$_ntable_data_view
  UNION ALL
  select * from ku$_niotable_data_view
  UNION ALL
  select * from ku$_eqntable_data_view
  UNION ALL
  select * from ku$_iotable_data_view
  UNION ALL
  select * from ku$_iotpart_data_view
/

-- 10_2 view excludes tables with reference partitioning
--  (but includes equipartitioned nested tables -- the user should
--   be able to move the data to a non-partitioned NT on the target;
--   nested table partitions always have refpar > 0)

create or replace force view ku$_10_2_table_data_view of ku$_table_data_t
  with object OID(obj_num)
  as
  select t.* from ku$_htable_data_view t
  where refpar_level = 0
  UNION ALL
  select t.* from ku$_htpart_data_view t
  where refpar_level = 0
  UNION ALL
  select t.* from ku$_htspart_data_view t
  where refpar_level = 0
  UNION ALL
  select t.* from ku$_ntable_data_view t
  where refpar_level = 0
  UNION ALL
  select * from ku$_eqntable_data_view
  UNION ALL
  select t.* from ku$_iotable_data_view t
  where refpar_level = 0
  UNION ALL
  select t.* from ku$_iotpart_data_view t
  where refpar_level = 0
/

-- 10_1 view excludes tables with encrypted columns.

create or replace force view ku$_10_1_table_data_view of ku$_table_data_t
  with object OID(obj_num)
  as
  select t.* from ku$_htable_data_view t
  where refpar_level = 0 and bitand(t.trigflag,65536+131072)=0
  UNION ALL
  select t.* from ku$_htpart_data_view t
  where refpar_level = 0 and bitand(t.trigflag,65536+131072)=0
  UNION ALL
  select t.* from ku$_htspart_data_view t
  where refpar_level = 0 and bitand(t.trigflag,65536+131072)=0
  UNION ALL
  select t.* from ku$_ntable_data_view t
  where refpar_level = 0 and bitand(t.trigflag,65536+131072)=0
  UNION ALL
  select t.* from ku$_eqntable_data_view t
  where bitand(t.trigflag,65536+131072)=0
  UNION ALL
  select t.* from ku$_iotable_data_view t
  where refpar_level = 0 and bitand(t.trigflag,65536+131072)=0
  UNION ALL
  select t.* from ku$_iotpart_data_view t
  where refpar_level = 0 and bitand(t.trigflag,65536+131072)=0
/

--
-- Create a view to fetch the partition and subpartition names of partitioned
-- and subpartitioned tables.
--
create or replace force view ku$_tab_subname_view (
    tab_owner, tab_name, tab_part_name, tab_subpart_name, tsname) as
  --
  -- Select partition names if the table is partitioned
  --
  SELECT sov.owner_name, sov.name, sov.subname, NULL, ts$.name
  FROM   sys.ku$_schemaobj_view sov, tabpart$ tp, ts$
  WHERE  sov.obj_num=tp.obj# AND
         tp.ts# = ts$.ts# AND
         (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (sov.owner_num, 0) OR
          EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
UNION ALL
  SELECT sov.owner_name, sov.name, bo.subname, sov.subname, ts$.name
  FROM   sys.ku$_schemaobj_view sov, sys.obj$ bo, tabsubpart$ tsp,
         tabcompart$ tcp, ts$
  WHERE  tsp.obj# = sov.obj_num AND
         tcp.obj# = tsp.pobj# AND
         tcp.obj# = bo.obj# AND
         tsp.ts# = ts$.ts# AND
         (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (sov.owner_num, 0) OR
          EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
UNION ALL
  SELECT sov.owner_name, sov.name, sov.subname, NULL, ts$.name
  FROM   sys.ku$_schemaobj_view sov, indpart$ ip, ind$ i, ts$
  WHERE  ip.obj# = sov.obj_num AND
         ip.bo# = i.obj# AND
         i.type# = 4 AND
         ip.ts# = ts$.ts# AND
         (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (sov.owner_num, 0) OR
          EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

--
-- Create a view to fetch the partition and subpartition names of partitioned
-- and subpartitioned global indexes.
--
create or replace force view ku$_ind_subname_view (
    tab_owner, ind_owner, tab_name, ind_name, tab_part_name, ind_part_name,
    tab_subpart_name, ind_subpart_name, tsname) as
  --
  -- Select partition names if the table is partitioned
  --
  SELECT tsov.owner_name, isov.owner_name, tsov.name, isov.name, tsov.subname,
         isov.subname, NULL, NULL, ts$.name
  FROM   sys.ku$_schemaobj_view tsov, sys.ku$_schemaobj_view isov, tabpart$ tp,
         ind$ i, indpart$ ip, ts$
  WHERE  tsov.obj_num=tp.obj# AND
         isov.obj_num=ip.obj# AND
         i.obj# = ip.bo# AND
         i.bo# = tp.bo# AND
         ip.ts# = ts$.ts# AND
         ip.part# = tp.part# AND
         (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (isov.owner_num, 0) OR
          EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
UNION ALL
  SELECT tsov.owner_name, isov.owner_name,  tsov.name, isov.name, tpo.subname,
         ipo.subname, tsov.subname, isov.subname, ts$.name
  FROM   sys.ku$_schemaobj_view tsov, sys.ku$_schemaobj_view isov,
         sys.obj$ tpo, sys.obj$ ipo, sys.tabsubpart$ tsp, sys.tabcompart$ tcp,
         sys.indcompart$ icp, sys.ind$ i, indsubpart$ isp, ts$
  WHERE  tsov.obj_num=tsp.obj# AND
         isov.obj_num=isp.obj# AND
         isp.pobj# = icp.obj# AND
         tsp.pobj# = tcp.obj# AND
         tpo.obj# = tcp.obj# AND
         isp.subpart# = tsp.subpart# AND
         icp.part# = tcp.part# AND
         icp.bo# = i.obj# AND
         i.bo# = tcp.bo# AND
         ipo.obj# = icp.obj# AND
         isp.ts# = ts$.ts# AND
         (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (isov.owner_num, 0) OR
          EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
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

-- view for post data table

create or replace force view ku$_post_data_table_view of ku$_post_data_table_t
  with object identifier (obj_num) as
  select '1','1',
         t.obj#, value(o),
         t.spare1
  from sys.ku$_schemaobj_view o, sys.tab$ t
  where t.obj#=o.obj_num and
        bitand(t.spare1,32768)!=0 and
        bitand(t.trigflag,1048576)=0 and
        (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (o.owner_num, 0) OR
                EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

-------------------------------------------------------------------------------
--                              DPSTREAM_TABLE
-------------------------------------------------------------------------------

-- Table metadata needed for the DataPump data layer.

create or replace force view ku$_strmsubcoltype_view of ku$_strmsubcoltype_t
  with object identifier (obj_num,intcol_num,toid) as
  select sct.obj#, sct.intcol#,
         o.owner_name, o.name,
         sct.toid,
         t.version#,
         sys.dbms_metadata.get_hashcode(o.owner_name,o.name),
         t.typeid
    from ku$_schemaobj_view o, type$ t, subcoltype$ sct
    where o.oid=sct.toid and o.oid=t.toid
/

create or replace force view ku$_strmcoltype_view
  of ku$_strmcoltype_t with object identifier(obj_num, intcol_num) as
  select ct.obj#, ct.col#, ct.intcol#,
         o.owner_name, o.name,
         ct.flags,
         (select opq.flags from sys.opqtype$ opq
          where opq.obj#=ct.obj# and opq.intcol#=ct.intcol#),
         ct.toid,
         ct.version#,
         sys.dbms_metadata.get_hashcode(o.owner_name,o.name),
         ct.typidcol#,
         /* look up stuff in subcoltype$ only if column is substitutable */
         decode(bitand(ct.flags, 512), 512,
           cast(multiset(select sct.* from ku$_strmsubcoltype_view sct
                where ct.obj#    = sct.obj_num
                and   ct.intcol# = sct.intcol_num
                       ) as ku$_strmsubcoltype_list_t
                ),
           null),
       -- If column is opaque and has internal columns, check for unpacked 
        --  anydata type 
        case when ((bitand(ct.flags, 16384)=16384) and (ct.intcols>0)) then
             (select dbms_metadata_util.get_anydata_colset(ct.obj#, ct.col#,
                                             ct.intcols,ct.intcol#s) from dual)
        else null end
    from ku$_schemaobj_view o, obj$ oo, coltype$ ct
         where ct.toid = oo.oid$
         and o.obj_num = oo.obj#
/

--
-- strmsubcoltype_view for 10g compatibility
-- Exclude subtype SYS.SQL_PLAN_ALLSTAT_ROW_TYPE from 10.2 dump file.
-- This subtype is not defined on 10.2, and including it in the stream metadata
-- will cause 10g import to fail.  
-- For a full description of the problem, see the routine header for 
-- dbms_metadata_int.is_att_valid_on_10 in prvtmeti.sql.
--
create or replace force view ku$_10_2_strmsubcoltype_view of
                                                     ku$_strmsubcoltype_t
  with object identifier (obj_num,intcol_num,toid) as
  select sct.obj#, sct.intcol#,
         o.owner_name, o.name,
         sct.toid,
         t.version#,
         sys.dbms_metadata.get_hashcode(o.owner_name,o.name),
         t.typeid
    from ku$_schemaobj_view o,type$ t, subcoltype$ sct
    where o.oid=sct.toid and o.oid=t.toid and
         NOT(o.name = 'SQL_PLAN_ALLSTAT_ROW_TYPE' and
             NLSSORT(o.owner_name, 'NLS_SORT=BINARY') = NLSSORT('SYS', 'NLS_SORT=BINARY'))
/

--
-- strmcoltype for 10g compatibility
--
create or replace force view ku$_10_2_strmcoltype_view
  of ku$_10_2_strmcoltype_t with object identifier(obj_num, intcol_num) as
  select ct.obj#, ct.col#, ct.intcol#,
         o.owner_name, o.name,
         ct.flags,
--
-- opq.flags not present in 10g
--         (select opq.flags from sys.opqtype$ opq
--          where opq.obj#=ct.obj# and opq.intcol#=ct.intcol#),
         ct.toid,
         ct.version#,
         sys.dbms_metadata.get_hashcode(o.owner_name,o.name),
         ct.typidcol#,
         /* look up stuff in subcoltype$ only if column is substitutable */
         decode(bitand(ct.flags, 512), 512,
           cast(multiset(select sct.* from ku$_10_2_strmsubcoltype_view sct
                where ct.obj#    = sct.obj_num
                and   ct.intcol# = sct.intcol_num
                       ) as ku$_strmsubcoltype_list_t
                ),
           null)
    from ku$_schemaobj_view o, obj$ oo, coltype$ ct
         where ct.toid = oo.oid$
         and o.obj_num = oo.obj#
/

create or replace force view ku$_strmcol_view of ku$_strmcol_t
  with object identifier (obj_num,intcol_num) as
  select c.obj#, c.col#, c.intcol#, c.segcol#,
         -- Column sortkey: in principle we want to sort by segcol#, but 
         -- segcol# for xmltype is 0 so replace it with the segcol# of its 
         -- underlying lob or object rel column that contains the actual
         -- data.  This query needs to be identical to the one for the 
         -- col_sorkey column in ku$_prim_column_view, ku$_pcolumn_view and
         -- ku$_column_view in order to ensure that lob columns are ordered
         -- identically when writing to and reading from dump files 
         -- (bug# 12998987, 17627666).
         case when (c.segcol# = 0 and c.type# = 58) then
          NVL((select cc.segcol# from col$ cc, opqtype$ opq
              where opq.obj#=c.obj#
                and opq.intcol#=c.intcol#
                and opq.type=1
                and cc.intcol#=opq.lobcol    -- xmltype stored as lob
                and cc.obj#=c.obj#),
                (NVL((select cc.segcol# from col$ cc, opqtype$ opq
                      where opq.obj#=c.obj#
                        and opq.intcol#=c.intcol#
                        and opq.type=1
                        and cc.intcol#=opq.objcol  -- xmltype stored obj rel
                        and bitand(opq.flags,1)=1
                        and cc.obj#=c.obj#),0)))
          else c.segcol# 
         end,
         case c.col# when c.intcol# then c.intcol#
                     when 0 then c.intcol#
          else sys.dbms_metadata_util.get_base_intcol_num(c.obj#,c.col#,
                                                          c.intcol#,c.type#)
         end,
        case c.col# when 0 then 0
          else
            sys.dbms_metadata_util.get_base_col_type(c.obj#,c.col#,
                                                          c.intcol#,c.type#)
         end,
         -- get column  properties
         sys.dbms_metadata_util.get_col_property(c.obj#,c.intcol#),
         trunc(c.property / power(2,32)),
         c.name,
         decode(bitand(c.property,1024),0,
         (select a.name from attrcol$ a where
                        a.obj#=c.obj# and a.intcol#=c.intcol#),
           (select a.name from attrcol$ a where c.intcol#>1 and
                        a.obj#=c.obj# and a.intcol#=c.intcol#-1)),
         c.type#, c.length,
         c.precision#, c.scale, c.null$,
         c.charsetid, c.charsetform, c.spare3,
         -- get lob property if type# = 112 (DTYCLOB)
         decode(c.type#,112,
                 sys.dbms_metadata_util.get_lob_property(c.obj#,c.intcol#),
                 null),
         -- get type metadata if type# = 121 (DTYADT)
         --                              123 (DTYNAR)
         --                               58 (DTYOPQ)
         ( select value(ctv) from ku$_strmcoltype_view ctv
                     where c.obj#  = ctv.obj_num
                     and   c.intcol# = ctv.intcol_num
           and   c.type# in (121,123,58) ),
        case c.col# when c.intcol# then NULL
                    when 0 then NULL
          else
            sys.dbms_metadata_util.get_base_col_name(c.obj#,c.col#,
                                                          c.intcol#,c.type#)
         end,
         -- If column has the properties ((ADT attribute, hidden, system
         -- generated) or (type id, ADT attribute, hidden)), then
         -- this column may be part of an unpacked anydata type. 
         case when (bitand(c.property,289) = 289  or
                    bitand(c.property,33554465) = 33554465) then 
            sys.dbms_metadata_util.get_attrname2(c.obj#, c.intcol#, c.col#)
          else
            NULL
         end
  from col$ c
/
--
-- strmcol for 10g compatibility
--
create or replace force view ku$_10_2_strmcol_view of ku$_10_2_strmcol_t
  with object identifier (obj_num,intcol_num) as
  select c.obj#, c.col#, c.intcol#, c.segcol#,
         -- col_sortkey, base_intcol_num not present on 10g
         -- base_col_type, base_col_name added for bug fix on 10g
         case c.col# when c.intcol# then 0
                     when 0 then 0
          else
            sys.dbms_metadata_util.get_base_col_type(c.obj#,c.col#,
                                                          c.intcol#,c.type#)
         end,
         case c.col# when c.intcol# then NULL
                     when 0 then NULL
          else
            sys.dbms_metadata_util.get_base_col_name(c.obj#,c.col#,
                                                          c.intcol#,c.type#)
         end,
         -- get column  properties
         sys.dbms_metadata_util.get_col_property(c.obj#,c.intcol#),
         trunc(c.property / power(2,32)),
         c.name,
         decode(bitand(c.property,1024),0,
         (select a.name from attrcol$ a where
                        a.obj#=c.obj# and a.intcol#=c.intcol#),
           (select a.name from attrcol$ a where c.intcol#>1 and
                        a.obj#=c.obj# and a.intcol#=c.intcol#-1)),
         c.type#, c.length,
         c.precision#, c.scale, c.null$,
         c.charsetid, c.charsetform, c.spare3,
         -- get lob property if type# = 112 (DTYCLOB)
         decode(c.type#,112,
                 sys.dbms_metadata_util.get_lob_property(c.obj#,c.intcol#),
                 null),
         -- get type metadata if type# = 121 (DTYADT)
         --                              123 (DTYNAR)
         --                               58 (DTYOPQ)
         ( select value(ctv) from ku$_10_2_strmcoltype_view ctv
                     where c.obj#  = ctv.obj_num
                     and   c.intcol# = ctv.intcol_num
           and   c.type# in (121,123,58) )
  from col$ c where dbms_metadata.is_attr_valid_on_10(c.obj#,c.intcol#)=1
/

create or replace force view ku$_strmtable_view of ku$_strmtable_t
  with object OID(obj_num)
  as select '1',
         (select dbms_metadata_util.get_strm_minver from dual),
         (select dbms_metadata_util.get_vers_dpapi from dual),
         (select dbms_metadata_util.get_endianness from dual),
         (select value from v$nls_parameters
                 where parameter='NLS_CHARACTERSET'),
         (select value from v$nls_parameters
                 where parameter='NLS_NCHAR_CHARACTERSET'),
         (select dbtimezone from dual),
         (select utl_xml.getfdo from dual),
         t.obj#,
         o.owner_name, o.name, o.subname,
         bitand(t.property, 4294967295),
         trunc(t.property / power(2, 32)),
         cast( multiset(select * from ku$_strmcol_view c
                        where c.obj_num = t.obj#
                        and bitand(c.property,32768)=0  -- unused column
                        /* bug 17654567: no longer exclude ILM columns */
                        /* exclude guard columns */
                        and bitand(c.property2,128)=0  
                        /* exclude storage columns for xmltype */
                        and sys.dbms_metadata_util.isXml(t.obj#,c.intcol_num)=0
                        /* prior to v12, exclude xmltype heirarchy enabled
                          table columns (XMLTYPE, and hidden columns)
                          named 'ACLOID' or 'OWNERID'. These have instance
                          specific content. In V12, full export can map the
                          content, so the columns are dealt with on import. */
                        and not
                            ((exists (select q.obj# from sys.opqtype$ q
                               where q.obj#=t.obj#
                                 and q.type=1)) and           /* xmltype col */
                             (bitand(c.property,32)!=0) and
                             (c.name IN ('OWNERID', 'ACLOID')) and
                             dbms_metadata.get_version < '12.00.00.00.00')
                        order by c.col_sortkey
                        ) as ku$_strmcol_list_t
              )
  from  ku$_schemaobj_view o, tab$ t
  where t.obj# = o.obj_num
        AND (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (o.owner_num, 0) OR
                EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

--
-- strmtable for 10g:
--   minor version # = 0
--   use 10g strmcol list
--
create or replace force view ku$_10_2_strmtable_view of ku$_10_2_strmtable_t
  with object OID(obj_num)
  as select '1','0',
         (select dbms_metadata_util.get_vers_dpapi from dual),
         (select dbms_metadata_util.get_endianness from dual),
         (select value from v$nls_parameters
                 where parameter='NLS_CHARACTERSET'),
         (select value from v$nls_parameters
                 where parameter='NLS_NCHAR_CHARACTERSET'),
         (select dbtimezone from dual),
         (select utl_xml.getfdo from dual),
         t.obj#,
         o.owner_name, o.name, o.subname,
         t.property,
         cast( multiset(select * from ku$_10_2_strmcol_view c
                        where c.obj_num = t.obj#
                        and bitand(c.property,32768)=0  -- unused column
                        /* exclude guard columns */
                        and bitand(c.property2,128)=0
                        -- 10.2 view does not have base_col_type
                        -- and c.base_col_type<2
                        order by c.segcol_num
                        ) as ku$_10_2_strmcol_list_t
              )
  from  ku$_schemaobj_view o, tab$ t
  where t.obj# = o.obj_num
        AND (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (o.owner_num, 0) OR
                EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

-------------------------------------------------------------------------------
--                              PROC./FUNC./PACKAGE
-------------------------------------------------------------------------------

-- base view for procedures, functions, packages and package bodies

create or replace force view ku$_base_proc_view of ku$_proc_t
  with object identifier (obj_num) as
  select '1','1',
         oo.obj#,
         oo.type#,
         value(o),
         sys.dbms_metadata_util.get_source_lines(oo.name,oo.obj#,oo.type#)
  from  sys.ku$_edition_schemaobj_view o, sys.ku$_edition_obj_view oo
  where (oo.type# = 7 or oo.type# = 8 or oo.type# = 9 or oo.type# = 11)
    and oo.obj#  = o.obj_num and oo.linkname is NULL
         AND (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (o.owner_num, 0) OR
              EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

-- base view for procedures, functions, packages and package bodies

create or replace force view ku$_base_proc_objnum_view of ku$_proc_objnum_t
  with object identifier (obj_num) as
  select '1','1',
         oo.obj#,
         oo.type#,
         value(o)
  from  sys.ku$_edition_schemaobj_view o, sys.ku$_edition_obj_view oo
  where (oo.type# = 7 or oo.type# = 8 or oo.type# = 9 or oo.type# = 11)
    and oo.obj#  = o.obj_num and oo.linkname is NULL
         AND (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (o.owner_num, 0) OR
              EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

-- particular views for procedures, functions, packages and package bodies

create or replace force view ku$_proc_view of ku$_proc_t
  with object identifier (obj_num) as
  select t.vers_major, t.vers_minor, t.obj_num, t.type_num,
         t.schema_obj, t.source_lines
  from ku$_base_proc_view t
  where t.type_num = 7
/

create or replace force view ku$_func_view of ku$_proc_t
  with object identifier (obj_num) as
  select t.vers_major, t.vers_minor, t.obj_num, t.type_num,
         t.schema_obj, t.source_lines
  from ku$_base_proc_view t
  where t.type_num = 8
/

create or replace force view ku$_pkg_objnum_view of ku$_proc_objnum_t
  with object identifier (obj_num) as
  select t.vers_major, t.vers_minor, t.obj_num, t.type_num,
         t.schema_obj
  from ku$_base_proc_objnum_view t
  where t.type_num = 9
/

create or replace force view ku$_pkg_view of ku$_proc_t
  with object identifier (obj_num) as
  select t.vers_major, t.vers_minor, t.obj_num, t.type_num,
         t.schema_obj, t.source_lines
  from ku$_base_proc_view t
  where t.type_num = 9
/

create or replace force view ku$_pkgbdy_view of ku$_proc_t
  with object identifier (obj_num) as
  select t.vers_major, t.vers_minor, t.obj_num, t.type_num,
         t.schema_obj, t.source_lines
  from ku$_base_proc_view t
  where t.type_num = 11
/

create or replace force view ku$_full_pkg_view of ku$_full_pkg_t
  with object identifier (obj_num) as
  select '1','1',
         oo.obj#,
         value(o),
         value(p),
         (select value(pb) from ku$_pkgbdy_view pb
          where oo.name  = pb.schema_obj.name
          and o.owner_name  = pb.schema_obj.owner_name)
  from   sys.ku$_edition_obj_view oo, ku$_edition_schemaobj_view o, ku$_pkg_view p
  where oo.type# = 9
    and oo.obj#  = o.obj_num
    and oo.obj#  = p.schema_obj.obj_num
         AND (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (o.owner_num, 0) OR
              EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

-- view used by export
-- includes base_obj_num (obj# of the pkg_spec) so that the base_obj_num
-- can be used as a filter

create or replace force view ku$_exp_pkg_body_view of ku$_exp_pkg_body_t
  with object identifier (obj_num) as
  select '1','1',
       (select o1.obj# from sys.ku$_edition_obj_view o1 where o1.type#=9
               and o1.name=o2.name and o1.owner#=o2.owner#
               and o1.linkname is NULL),
       o2.obj#,o2.type#,
       (select value(o) from sys.ku$_edition_schemaobj_view o where o.obj_num=o2.obj#),
       sys.dbms_metadata_util.get_source_lines(o2.name,o2.obj#,o2.type#),
       (select value(c) from sys.ku$_switch_compiler_view c
                 where c.obj_num = o2.obj#)
  from sys.ku$_edition_obj_view o2
  where o2.type#=11
         AND (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (o2.owner#, 0) OR
              EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

-- view for alter procedure/function/package compile ...

create or replace force view ku$_alter_proc_view of ku$_alter_proc_t
  with object identifier (obj_num) as
  select '1','0',
         oo.obj#,
         oo.type#,
         value(o),
         (select value (c)
                 from ku$_switch_compiler_view c where c.obj_num = oo.obj#)
  from  sys.ku$_edition_schemaobj_view o, sys.obj$ oo
  where oo.type# = 7
    and oo.obj#  = o.obj_num
         AND (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (o.owner_num, 0) OR
              EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

create or replace force view ku$_alter_func_view of ku$_alter_proc_t
  with object identifier (obj_num) as
  select '1','0',
         oo.obj#,
         oo.type#,
         value(o),
         (select value (c)
                 from ku$_switch_compiler_view c where c.obj_num = oo.obj#)
  from  sys.ku$_edition_schemaobj_view o, sys.obj$ oo
  where oo.type# = 8
    and oo.obj#  = o.obj_num
         AND (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (o.owner_num, 0) OR
              EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

create or replace force view ku$_alter_pkgspc_view of ku$_alter_proc_t
  with object identifier (obj_num) as
  select '1','0',
         oo.obj#,
         oo.type#,
         value(o),
         (select value (c)
                 from ku$_switch_compiler_view c where c.obj_num = oo.obj#)
  from  sys.ku$_edition_schemaobj_view o, sys.obj$ oo
  where oo.type# = 9
    and oo.obj#  = o.obj_num
         AND (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (o.owner_num, 0) OR
              EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

create or replace force view ku$_alter_pkgbdy_view of ku$_alter_proc_t
  with object identifier (obj_num) as
  select '1','0',
         oo.obj#,
         oo.type#,
         value(o),
         (select value (c)
                 from ku$_switch_compiler_view c where c.obj_num = oo.obj#)
  from  sys.ku$_edition_schemaobj_view o, sys.obj$ oo
  where oo.type# = 11
    and oo.obj#  = o.obj_num
         AND (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (o.owner_num, 0) OR
              EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/


-------------------------------------------------------------------------------
--                              OPERATOR
-------------------------------------------------------------------------------

-- views for operator arguments
-- NOTE: We don't need a view of ku$_oparg_t's because they're instantiated
-- directly from sys.oparg$ in the higher level views that follow.

-- View for primary operators for ancillary operators
create or replace force view ku$_opancillary_view of ku$_opancillary_t
  with object identifier (obj_num, bind_num, primop_num) as
  select oa.obj#, oa.bind#, oa.primop#,
         (select value(o) from sys.ku$_schemaobj_view o
                 where o.obj_num=oa.primop#),
         cast(multiset(select * from sys.oparg$ arg
                       where arg.obj#=oa.primop# and arg.bind#=oa.primbind#
                       order by arg.position
                      ) as ku$_oparg_list_t
             )
  from sys.opancillary$ oa
/

-- view for operator bindings
create or replace force view ku$_opbinding_view of ku$_opbinding_t
  with object identifier(obj_num, bind_num) as
  select ob.obj#, ob.bind#, ob.functionname, ob.returnschema,
         ob.returntype, ob.impschema, ob.imptype, ob.property,
         ob.spare1, ob.spare2, ob.spare3,
         cast(multiset(select * from sys.oparg$ oa
                       where oa.obj#=ob.obj# and oa.bind#=ob.bind#
                       order by oa.position
                      ) as ku$_oparg_list_t
             ),
         cast(multiset(select value(a) from sys.ku$_opancillary_view a
                       where ob.obj#=a.obj_num and ob.bind#=a.bind_num
                      ) as ku$_opancillary_list_t
             )
  from sys.opbinding$ ob
/

-- View for operators
create or replace force view ku$_operator_view of ku$_operator_t
  with object identifier(obj_num) as
  select '1','0',
         op.obj#, value(o), op.property,
         cast(multiset(select value(ob) from ku$_opbinding_view ob
                       where ob.obj_num=op.obj#
                       order by ob.bind_num
                      ) as ku$_opbinding_list_t
             )
  from  ku$_schemaobj_view o, sys.operator$ op
  where op.obj#=o.obj_num
        and (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (o.owner_num, 0) OR
              EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

-------------------------------------------------------------------------------
--                              INDEXTYPE OPERATORS
-------------------------------------------------------------------------------

-- view for operators supported by indextypes

create or replace force view ku$_indexop_view of ku$_indexop_t
  with object identifier(obj_num, oper_num, bind_num) as
  select io.obj#, io.oper#, io.bind#, io.property,
         (select value(o) from sys.ku$_schemaobj_view o
          where io.oper#=o.obj_num),
         cast(multiset(select * from sys.oparg$ oa
                       where oa.obj#=io.oper# and oa.bind#=io.bind#
                       order by oa.position
                      ) as ku$_oparg_list_t
             )
  from sys.indop$ io
/

create or replace force view ku$_indarraytype_view of ku$_indarraytype_t
  with object identifier(obj_num) as
  select ia.obj#, ia.type,
         (select value(o1) from ku$_schemaobj_view o1
               where o1.obj_num=ia.basetypeobj#),
         (select value(o2) from ku$_schemaobj_view o2
               where o2.obj_num=ia.arraytypeobj#)
  from sys.indarraytype$ ia
/

create or replace force view ku$_indextype_view of ku$_indextype_t
  with object identifier(obj_num) as
  select '1','1',
         it.obj#, value(o),
         (select value(oit) from sys.ku$_schemaobj_view oit
          where it.implobj#=oit.obj_num),
         it.property,
          cast(multiset(select value(io) from sys.ku$_indexop_view io
                        where it.obj#=io.obj_num
                        /* the following order-by clause exists solely
                           to assure repeatable regression tests results */
                        order by io.oper_obj.owner_name, io.oper_obj.name
                       ) as ku$_indexop_list_t
              ),
          cast(multiset(select value(ia) from sys.ku$_indarraytype_view ia
                        where it.obj#=ia.obj_num
                       ) as ku$_indarraytype_list_t
              )
  from  sys.ku$_schemaobj_view o, sys.indtypes$ it
  where it.obj#=o.obj_num
        AND (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (o.owner_num, 0) OR
              EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

-------------------------------------------------------------------------------
--                              TRIGGERS
-------------------------------------------------------------------------------

create or replace force view ku$_triggercol_view of ku$_triggercol_t
  with object identifier(obj_num,intcol_num,type_num) as
  select '1','0',
         tc.obj#, tc.col#, tc.type#, tc.position#, tc.intcol#, c.name,
         (select a.name from attrcol$ a where
                        a.obj#=tc.obj# and a.intcol#=tc.intcol#)
  from col$ c, triggercol$ tc, trigger$ t
  where tc.obj#=t.obj#
    and c.obj#=t.baseobject
    and c.intcol#=tc.intcol#
/

create or replace force view ku$_on_user_grant_view of ku$_on_user_grant_t
  with object identifier (sequence) as
  select '1','1',
         u.name, u1.name, u2.name, us.sequence#
  from sys.userauth$ us, sys.user$ u, sys.user$ u1, sys.user$ u2
  where us.user#=u.user# and us.grantor#= u1.user# and us.grantee#=u2.user# and
        (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (us.grantee#, 0) OR
                us.grantee#=1 OR
                EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

create or replace force view ku$_triggerdep_view of ku$_triggerdep_t
  with object identifier(obj_num, p_trgowner, p_trgname) as
  select '1','0', td.obj#, td.p_trgowner, td.p_trgname, td.flag
  from triggerdep$ td
/

-- trigger views
declare
  stmt varchar2(10000);
  procedure cre_trigger_views(vname VARCHAR2, version VARCHAR2,
                              is_schema VARCHAR2, definition VARCHAR2) as
    begin
      stmt := q'!
create or replace force view !'||vname||q'! of ku$_trigger_t
  with object identifier(obj_num) as
  select '1','!'||version||q'!',
         t.obj#, value(o), t.baseobject,
         (select u.name from user$ u
          where u.user#=t.baseobject
            and bitand(t.property,16)!=0),
         (select value(bo) from ku$_schemaobj_view bo
          where t.baseobject = bo.obj_num
            and bitand(t.property,8+16)=0),
         (select trunc(tb.property/power(2,32)) from sys.tab$ tb
          where tb.obj#=t.baseobject),
         (SELECT unique 1 FROM sys.rls$ r,  ku$_schemaobj_view bo
          WHERE t.baseobject = bo.obj_num and bo.TYPE_NAME='TABLE' AND
              r.obj# = t.baseobject and
              r.PFSCHMA = 'XDB' AND
              r.PPNAME='DBMS_XDBZ0' AND
              (o.NAME like '%$xd' or
               o.NAME like '%$dl')),
         t.type#, t.update$, t.insert$, t.delete$,
         t.refoldname, t.refnewname,
         !'||is_schema||q'!,
         !'||definition||q'!,
         sys.dbms_metadata_util.parse_trigger_definition(o.owner_name,o.name,
                                         replace(t.definition,chr(0))),
         replace(t.whenclause,chr(0)),
         sys.dbms_metadata_util.long2clob(t.actionsize,
                                        'SYS.TRIGGER$',
                                        'ACTION#',
                                        t.rowid),
         NULL,
         t.actionsize,
         t.enabled, t.property, t.sys_evts,
         t.nttrigcol, t.nttrigatt,
         (select ntcol.name from sys.viewtrcol$ ntcol
          where bitand(t.property, 63)>= 32 and t.baseobject = ntcol.obj#
          and t.nttrigcol = ntcol.intcol# and t.nttrigatt = ntcol.attribute#),
         t.refprtname, t.actionlineno,
         cast(multiset(select * from ku$_triggercol_view tv
                        where tv.obj_num=t.obj#
                      ) as ku$_triggercol_list_t
             ),
         cast(multiset(select * from ku$_triggerdep_view td
                        where td.obj_num=t.obj#
                      ) as ku$_triggerdep_list_t
             ),
         (select value(c) from ku$_switch_compiler_view c
                 where c.obj_num =o.obj_num)
 from   sys.ku$_edition_schemaobj_view o, sys.trigger$ t
  where  t.obj# = o.obj_num AND
         (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (o.owner_num, 0) OR
                EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))!';
      -- The folowing (put_line) can be very helpful in debug, but fails
      -- if execution is attemted during DB create (dbms_output not available)
      -- so enable as needed!
      -- dbms_output.put_line('*** trigger: ' || stmt);
      execute immediate stmt;
    end;
begin
  -- This version of the view no longer calls is_schemaname_exists()
  -- and does not carry around another copy of the definition
  cre_trigger_views('ku$_trigger_view','5','NULL', 'NULL');
  -- This version of the view uses long2clob to populate the body attribute.
  -- long2clob can return view text of arbitrary length;
  -- the old body_vcnt attribute is retained for compatibility
  -- but is always set to NULL.
  cre_trigger_views('ku$_12_1_trigger_view','4',
                    'sys.dbms_metadata_util.is_schemaname_exists(t.definition)',
                    'replace(t.definition,chr(0))');
end;
/

-- 11.2 view excludes triggers on tables with long varchar columns
--  sdavidso 12/301/2014 added 'not null' to type_name to get correct behavior.
--    why that is now needed is a mystery.
create or replace force view ku$_11_2_trigger_view of ku$_trigger_t
  with object identifier(obj_num) as
    select * from ku$_12_1_trigger_view t
    where not ( t.base_obj.type_name is not NULL AND
                t.base_obj.type_name='TABLE' AND
                bitand(t.tab_property2,2097152)!=0 )
/

-- 10.2 view excludes FORWARD, REVERSE, CROSSEDITION, FOLLOWS, and 
-- PRECEDES triggers
create or replace force view ku$_10_2_trigger_view of ku$_trigger_t
  with object identifier(obj_num) as
    select * from ku$_11_2_trigger_view t
    /* 8192 = crossedition, 16384 = follows, 32768 = precedes, 65536 = forward
       131072 = reverse */
    where bitand(t.property, 8192+16384+32768+65536+131072) = 0
    and t.type_num != 5                                  /* compound trigger */
/

-------------------------------------------------------------------------------
--                              VIEWS
-------------------------------------------------------------------------------

-- This version of the view uses long2clob to populate the text attribute.
-- long2clob can return view text of arbitrary length;
-- the old textvcnt attribute is retained for compatibility
-- but is always set to NULL.

create or replace force view ku$_view_view of ku$_view_t
  with object identifier (obj_num) as
  select '1','4',
         v.obj#,
         value(o),
         replace(v.audit$,chr(0),'-'),
         v.cols, v.intcols,
         bitand(v.property, 4294967295),
         trunc(v.property / power(2,32)),
         v.flags, v.textlength,
         case
           when v.textlength <= 32000
           then
             sys.dbms_metadata_util.func_view_defaultc(v.textlength,
                                                       v.rowid)
           else
	     sys.dbms_metadata_util.long2clob(v.textlength,
                                        'SYS.VIEW$',
                                        'TEXT',
                                        v.rowid)             
         end,
         sys.dbms_metadata.parse_query(SYS_CONTEXT('USERENV','CURRENT_USERID'),
                                       o.owner_name,
                                       v.textlength,
                                       'SYS.VIEW$',
                                       'TEXT',
                                       v.rowid,
                                       bitand(v.property,16384),
                                       (select
                                        case
                                         when exists
                                         (select cd.con# from cdef$ cd
                                          where cd.obj# = v.obj#
                                            and cd.type# in (5,6)) then 1
                                          else 0
                                        end from dual)),
         (select value (t)
                 from sys.ku$_constraint0_view t, cdef$ cd
                  where cd.obj# = v.obj# and
                        t.con_num = cd.con# and
                        cd.type# in (5,6)),
         NULL,
         cast(multiset(select * from ku$_simple_col_view c
                       where c.obj_num = v.obj#
                         and (bitand(v.property,1)=0)
                        order by c.intcol_num
                      ) as ku$_simple_col_list_t
             ),
         cast(multiset(select * from ku$_column_view c
                       where c.obj_num = v.obj#
                         and (bitand(v.property,1)=1)
                        order by c.intcol_num
                      ) as ku$_tab_column_list_t
             ),
         tv.typeowner, tv.typename, tv.typetextlength, tv.typetext,
         tv.oidtextlength, tv.oidtext, tv.transtextlength,
         sys.dbms_metadata_util.long2varchar(tv.transtextlength,
                                        'SYS.TYPED_VIEW$',
                                        'TRANSTEXT',
                                        tv.rowid),
         tv.undertextlength,
         sys.dbms_metadata_util.long2varchar(tv.undertextlength,
                                        'SYS.TYPED_VIEW$',
                                        'UNDERTEXT',
                                        tv.rowid),
         cast( multiset(select * from ku$_constraint1_view con
                        where con.obj_num = v.obj#
                       ) as ku$_constraint1_list_t
             ),
         cast( multiset(select * from ku$_constraint2_view con
                        where con.obj_num = v.obj#
                       ) as ku$_constraint2_list_t
             )
  from sys.ku$_edition_schemaobj_view o, sys.obj$ oo, sys.view$ v, sys.typed_view$ tv
  where oo.obj# = o.obj_num
    and oo.obj# = v.obj#
    and oo.obj# = tv.obj# (+)
         AND (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (o.owner_num, 0) OR
              EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

-- version < 12 excludes view objects which use bequeath current_user.
create or replace force view ku$_11_2_view_view of ku$_view_t
  with object identifier(obj_num) as
    select * from sys.ku$_view_view v
      where bitand(v.schema_obj.flags, 8) != 8
/

-- View for fetching view object numbers -- used by heterogeneous object types.
--
-- This view also excludes olap cube views. These views can only be 
-- created by procedural calls, which are generated through procedural actions.

create or replace force view ku$_view_objnum_view of ku$_schemaobj_t
  with object identifier(obj_num) as
  select value(o) from ku$_edition_schemaobj_view o, sys.view$ v
  where o.obj_num=v.obj#
  and not exists (SELECT 1 FROM SYS.OLAP_AW_VIEWS$ V
            WHERE O.OBJ_NUM = V.VIEW_OBJ# AND V.VIEW_TYPE = 1)
  AND (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (o.owner_num, 0)
        OR EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

-- get dependency information needed to sort views

create or replace force view ku$_depviews_base_view(
 viewobjno, viewname, viewownerno, viewowner, dobjno, dname)
as
 select unique o.obj#,o.name,o.owner#,u.name, d.d_obj#, do.name
from obj$ o, obj$ do, user$ u, dependency$ d, view$ v
where o.obj# = v.obj#
  and bitand(o.flags,16)!=16          /* not secondary object */
  and o.owner# != 0                   /* not owned by SYS */
  and o.owner# = u.user#
  and o.obj# = d.p_obj#
  and do.obj# = d.d_obj#
  and bitand(d.property,1)=1          /* only hard dependency */
  and do.type# = 4
union
 select o.obj#,o.name,o.owner#,u.name,0,NULL
from obj$ o, user$ u, view$ v
where o.obj# = v.obj#
  and bitand(o.flags,16)!=16          /* not secondary object */
  and o.owner# != 0                   /* not owned by SYS */
  and o.owner# = u.user#
  and not exists (select * from obj$ do, dependency$ d
                  where o.obj# = d.p_obj#
                  and do.obj# = d.d_obj#
                  and do.type# = 4
                  and bitand(d.property,1)=1 )
/

create or replace force view ku$_depviews_view(
 viewobjno, viewname, viewownerno, viewowner, dobjno, dname)
as
 select b.viewobjno, b.viewname, b.viewownerno, b.viewowner, b.dobjno, b.dname
 from ku$_depviews_base_view b
 where (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (b.viewownerno, 0) OR
              EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

-------------------------------------------------------------------------------
--                              OUTLINES
-------------------------------------------------------------------------------
-- views to support OUTLINEs

create or replace force view ku$_outline_view of ku$_outline_t
  with object identifier(name) as
  select '1','0',
         ol.ol_name,
         sys.dbms_metadata_util.long2clob(ol.textlen,
                                    'OUTLN.OL$',
                                    'SQL_TEXT',
                                    ol.rowid),
         ol.textlen, ol.signature, ol.hash_value, ol.category, ol.version,
         ol.creator, to_char(ol.timestamp,'YYYY/MM/DD HH24:MI:SS'), ol.flags, ol.hintcount,
         cast(multiset(select ol_name,hint#,category,hint_type,hint_text,
                              stage#,node#,table_name,table_tin,table_pos,
                              ref_id,user_table_name,cost,cardinality,
                              bytes,hint_textoff,hint_textlen,join_pred
                       from outln.ol$hints h
                       where h.ol_name = ol.ol_name order by h.stage#,h.node#
                      ) as ku$_outline_hint_list_t
             ),
         cast(multiset(select ol_name,category,node_id,parent_id,node_type,
                              node_textlen,node_textoff
                       from outln.ol$nodes n
                       where n.ol_name = ol.ol_name
                      ) as ku$_outline_node_list_t
             )
  from outln.ol$ ol, sys.user$ u
  where ol.creator=u.name
        AND (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (u.user#, 0) OR
              EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

-------------------------------------------------------------------------------
--                              SYNONYMS
-------------------------------------------------------------------------------
-- 
create or replace force view ku$_synonym_view of ku$_synonym_t
  with object identifier(obj_num) as
  select '1','0',
         s.obj#, value(o),
         -- syn_long_name defaults to name
         nvl((select j.longdbcs from sys.javasnm$ j where j.short = o.name),
             o.name),
         s.node, s.owner, s.name,
         (select j.longdbcs from sys.javasnm$ j where j.short = s.name)
  from  sys.ku$_edition_schemaobj_view o, sys.syn$ s
  where s.obj# = o.obj_num AND
         (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (o.owner_num, 0) OR
                o.owner_name='PUBLIC' or
                EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

-------------------------------------------------------------------------------
--                              DIRECTORY
-------------------------------------------------------------------------------
-- 
create or replace force view ku$_directory_view of ku$_directory_t
  with object identifier(obj_num) as
  select '1','0',
         o.obj#, value(sov),
         replace(d.audit$,chr(0),'-'),
         d.os_path
  from   sys.obj$ o, sys.ku$_schemaobj_view sov, sys.dir$ d
  where  o.obj# = sov.obj_num AND
         o.obj# = d.obj#
         AND (SYS_CONTEXT('USERENV','CURRENT_USERID')= 0
                OR EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

-------------------------------------------------------------------------------
--                           ROLLBACK SEGMENTS
-------------------------------------------------------------------------------
-- 
create or replace force view ku$_rollback_view of ku$_rollback_t
  with object identifier(us_num) as
  select '1','0',
         u.us#,
         u.name,
         u.user#,
         (select r.optsize from v$rollstat r where r.usn=u.us#),
         s.iniexts,
         s.minexts,
         s.maxexts,
         s.extsize,
         value(tsv)
  from   sys.ku$_tablespace_view tsv, sys.seg$ s, sys.undo$ u
  where  u.status$ != 1
    and  u.ts# = tsv.ts_num
    and  u.file#  = s.file#
    and  u.block# = s.block#
    and  u.ts#    = s.ts#
    and (SYS_CONTEXT('USERENV','CURRENT_USERID') = 0
        OR EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

-------------------------------------------------------------------------------
--                           DATABASE LINKS
-------------------------------------------------------------------------------
-- 

-- If a user
--   (a) owns the object or
--   (b) is SYS or
--   (c) has EXP_FULL_DATABASE role
-- the user can see all metadata for the object including passwords.
-- Otherwise, if the user has SELECT_CATALOG_ROLE
-- the user can see all metadata for the object except passwords.

create or replace force view ku$_dblink_view of ku$_dblink_t
  with object identifier(owner_num,name) as
  select '1','1',
         u.name,
         l.owner#, l.name, to_char(l.ctime,'YYYY/MM/DD HH24:MI:SS'),
         l.host, l.userid,
         l.password, l.flag, l.authusr, l.authpwd,
         dbms_metadata_util.glo(l.passwordx),dbms_metadata_util.glo(l.authpwdx)
  from   sys.user$ u, sys.link$ l
  where  u.user# = l.owner#
     AND (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (u.user#, 0) OR
          EXISTS ( SELECT * FROM sys.session_roles
                   WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('EXP_FULL_DATABASE', 'NLS_SORT=BINARY') OR
                         NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('DATAPUMP_CLOUD_EXP', 'NLS_SORT=BINARY')))
UNION
  select '1','1',
         u.name,
         l.owner#, l.name, to_char(l.ctime,'YYYY/MM/DD HH24:MI:SS'),
         l.host, l.userid,
         NULL, l.flag, l.authusr, NULL,
         NULL, NULL
  from   sys.user$ u, sys.link$ l
  where  u.user# = l.owner#
     AND (SYS_CONTEXT('USERENV','CURRENT_USERID') NOT IN (u.user#, 0))
     AND NOT (EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('EXP_FULL_DATABASE', 'NLS_SORT=BINARY') OR
                             NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('DATAPUMP_CLOUD_EXP', 'NLS_SORT=BINARY')))
     AND (EXISTS ( SELECT * FROM sys.session_roles
                   WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

-- 10_1 view excludes dblinks with stored password.  These were upgraded
-- in 10gR2 to obfuscate the password; no downgrade is possible.

create or replace force view ku$_10_1_dblink_view of ku$_dblink_t
  with object identifier(owner_num,name) as
  select t.* from ku$_dblink_view t
  where NVL(t.userid,'CURRENT_USER')='CURRENT_USER'
    and t.authusr is NULL
/

-------------------------------------------------------------------------------
--                           TRUSTED LINKS
-------------------------------------------------------------------------------
-- 
create or replace force view ku$_trlink_view of ku$_trlink_t
  with object identifier(name) as
  select '1','0',
         tl.dbname,
         decode(tl.dbname, '+*', 'DBMS_DISTRIBUTED_TRUST_ADMIN.ALLOW_ALL',
                           '-*', 'DBMS_DISTRIBUTED_TRUST_ADMIN.DENY_ALL',
                fdef.function),
         decode(tl.dbname, '+*', 0, '-*', 0, 1)
  from   sys.trusted_list$ tl,
         ( select  decode (dbname,
                           '+*', 'DBMS_DISTRIBUTED_TRUST_ADMIN.DENY_SERVER',
                           '-*', 'DBMS_DISTRIBUTED_TRUST_ADMIN.ALLOW_SERVER')
                           function
           from    sys.trusted_list$
           where   dbname like '%*') fdef
  where (SYS_CONTEXT('USERENV','CURRENT_USERID') = 0
        OR EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

-------------------------------------------------------------------------------
--                           Fine Grained Auditing
-------------------------------------------------------------------------------
-- 
create or replace force view ku$_fga_policy_view of ku$_fga_policy_t
  with object identifier(obj_num, pfschema, name) as
  SELECT '1','2',
         f.obj#,
         f.pname,
         TO_CLOB(replace ((f.ptxt), '''', '''''')),
         f.pfschma, f.ppname, f.pfname,
         cast(multiset(select c.name from sys.col$ c, sys.fgacol$ fc where
                       fc.obj# = f.obj# and
                       fc.pname = f.pname and
                       fc.obj#  = c.obj# and fc.intcol# = c.intcol#
                       )
              as ku$_fga_rel_col_list_t),
         f.enable_flag,
         BITAND(NVL(f.stmt_type, 1),15),
         BITAND(NVL(f.stmt_type, 0),64),
         BITAND(NVL(f.stmt_type, 1),128),
         value(sov),
         u.name
  FROM   sys.ku$_schemaobj_view sov, sys.fga$ f, sys.user$ u
  WHERE  f.obj# = sov.obj_num  AND
         u.user# = f.powner# AND
         (SYS_CONTEXT('USERENV','CURRENT_USERID') = 0 OR
          EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

-------------------------------------------------------------------------------
--              Fine Grained Access Control Administrative Interface
-------------------------------------------------------------------------------

create or replace force view ku$_rls_policy_objnum_view
   of ku$_rls_policy_objnum_t
   with object identifier (obj_num,name) as
  select
          r.obj#, r.pname, r.pfschma, r.ppname, r.pfname,
          value(sov)
  from    ku$_schemaobj_view sov, sys.rls$ r
  where   r.obj# = sov.obj_num and
          (SYS_CONTEXT('USERENV','CURRENT_USERID') in (sov.owner_num, 0) OR
          EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

--  Note: exclude XDS policies. Triton policies are not supported through
--        the policy_group interface:
--  ORA-46001: policy_group is not valid for Extensible Data Security policies

create or replace force view ku$_rls_policy_view of ku$_rls_policy_t
  with object identifier (obj_num,name) as
  select '1','1',
          value(sov),
          r.obj#, r.gname, r.pname,
          BITAND(r.stmt_type,15)+BITAND(r.stmt_type,2048),
          r.check_opt, r.enable_flag, r.pfschma, r.ppname, r.pfname,
          case bitand(r.stmt_type,16+64+128+256+8192+16384+32768+524288)
            when 16 then 'dbms_rls.STATIC'
            when 64 then 'dbms_rls.SHARED_STATIC'
            when 128 then 'dbms_rls.CONTEXT_SENSITIVE'
            when 256 then 'dbms_rls.SHARED_CONTEXT_SENSITIVE'
            when 8192 then 'dbms_rls.XDS1'
            when 16384 then 'dbms_rls.XDS2'
            when 32768 then 'dbms_rls.XDS3'
            when 524288 then 'dbms_rls.OLS'
            else 'dbms_rls.DYNAMIC'
          end,
          BITAND(r.stmt_type,512),
          cast(multiset(select c.name from col$ c, rls_sc$ sc where
                        sc.obj#=r.obj# and
                        sc.gname=r.gname and
                        sc.pname=r.pname and
                        sc.obj#=c.obj# and sc.intcol#=c.intcol#
                       )
               as ku$_rls_sec_rel_col_list_t),
          BITAND(r.stmt_type, 4096),
          cast(multiset(select * from sys.rls_csa$ rlsa where
                        rlsa.obj#=r.obj# and
                        rlsa.gname=r.gname and
                        rlsa.pname=r.pname
                        )
               as ku$_rls_assoc_list_t)
  from    ku$_edition_schemaobj_view sov, sys.rls$ r
  where   r.obj# = sov.obj_num and
          bitand(r.stmt_type, 8192+16384+32768) =0 and
          (SYS_CONTEXT('USERENV','CURRENT_USERID') in (sov.owner_num, 0) OR
          EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

create or replace force view ku$_rls_group_view of ku$_rls_group_t
  with object identifier (name,obj_num) as
  select '1','0',
          value(sov),
          rg.obj# , rg.gname
  from    ku$_edition_schemaobj_view sov, sys.rls_grp$ rg
  where   rg.obj# = sov.obj_num
      and (SYS_CONTEXT('USERENV','CURRENT_USERID') = 0 OR
           EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

create or replace force view ku$_rls_context_view of ku$_rls_context_t
  with object identifier (name,obj_num) as
  select '1','0',
          value(sov),
          rc.obj# ,rc.ns ,rc.attr
  from    ku$_edition_schemaobj_view sov, sys.rls_ctx$ rc
  where   rc.obj# = sov.obj_num
      and (SYS_CONTEXT('USERENV','CURRENT_USERID') = 0 OR
              EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

-------------------------------------------------------------------------------
--                           Materialized View
-------------------------------------------------------------------------------
--
--  Note: bug 18271304, There are two records for base object in obj$ for same
--  mview. When a mview is created referencing remote object, then a proxy 
--  object in obj$ is created in the local db, which will be used in building
--  summary join graphs (and later used during rewrite) and that records causing
--  this issue (as per discussion with praveen.kumar). 
--        

   -- View ku$_m_view_view_base moved to catmetviews_mig.sql

-- bug 6750821 and lrg 7071802: secondary Materialized Views must be 
-- fetched/created before the primary mviews that reference them.
-- This used to be accomplished with an 'order by parent_vname nulls last'.
-- Now there are additional mview views the follow the naming convention, ku$_zm_*
-- (e.g., ku$_zm_view_view, ku$_zm_view_fh_view, etc.) which fetch just the
-- secondary mviews. The ordering of the fetch is implicitly accomplished 
-- by the name of the view.

create or replace force view ku$_m_view_view of ku$_m_view_t
  with object identifier (oidval) as
  select * from ku$_m_view_view_base b
  where  bitand(b.flag2,33554432) != 33554432
    and (bitand(b.flag3, 512) = 0                /* snapshot != zonemap */
     or bitand(b.xpflags, 34359738368) = 0)      /* summary != zonemap */
     and(((
     case 
         when  nvl(b.unusablebef_num,0) = 0 then (0)			
	 else   dbms_editions_utilities.compare_edition(
               dbms_metadata.get_edition_id, b.unusablebef_num)  
	 end) in (0,2) ) 
      and((
      case 
	   when nvl(b.unusablebeg_num,0) = 0 then (1)			
	   else dbms_editions_utilities.compare_edition(
	        dbms_metadata.get_edition_id, b.unusablebeg_num)
      end) = 1  ))
/

create or replace force view ku$_zm_view_view of ku$_m_view_t
  with object identifier (oidval) as
  select * from ku$_m_view_view_base b
  where  bitand(b.flag2,33554432) = 33554432      /* secondary mviews. */
     and (bitand(b.flag3, 512) = 0                /* snapshot != zonemap */
      or bitand(b.xpflags, 34359738368) = 0)      /* summary != zonemap */
/

create or replace force view ku$_m_zonemap_view of ku$_m_view_t
  with object identifier (oidval) as
  select * from ku$_m_view_view_base b
  where bitand(b.flag3, 512) = 512                    /* snapshot = zonemap */
    and bitand(b.xpflags, 34359738368) = 34359738368   /* summary = zonemap */
/


create or replace force view ku$_m_view_h_view of ku$_m_view_h_t
  with object identifier (obj_num) as
  select '2','0',
         ot.obj#, 
         mvv.sowner,
         mvv.vname,
         value(mvv),
         value(htv),
         cast(multiset(select value(iv) from sys.ku$_all_index_view iv, sys.ind$ i
                       where i.bo# = ot.obj# and
                             bitand(i.property,8192) = 8192 and
                             iv.obj_num = i.obj#) as ku$_index_list_t)
  from   sys.obj$ ot, sys.user$ u, sys.ku$_htable_view htv,
         sys.ku$_m_view_view mvv
  where  ot.name     = mvv.tname
     and ot.owner#   = u.user#
     and u.name      = mvv.sowner
     and ot.type#    = 2
     and htv.obj_num = ot.obj#
     and BITAND(mvv.flag,33554432) != 33554432
     and (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (ot.owner#, 0) OR
          EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

create or replace force view ku$_zm_view_h_view of ku$_m_view_h_t
  with object identifier (obj_num) as
  select '2','0',
         ot.obj#, 
         mvv.sowner,
         mvv.vname,
         value(mvv),
         value(htv),
         cast(multiset(select value(iv) from sys.ku$_all_index_view iv, sys.ind$ i
                       where i.bo# = ot.obj# and
                             bitand(i.property,8192) = 8192 and
                             iv.obj_num = i.obj#) as ku$_index_list_t)
  from   sys.obj$ ot, sys.user$ u, sys.ku$_htable_view htv,
         sys.ku$_zm_view_view mvv
  where  ot.name     = mvv.tname
     and ot.owner#   = u.user#
     and u.name      = mvv.sowner
     and ot.type#    = 2
     and htv.obj_num = ot.obj#
     and BITAND(mvv.flag,33554432) != 33554432
     and (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (ot.owner#, 0) OR
          EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

create or replace force view ku$_m_view_ph_view of ku$_m_view_ph_t
  with object identifier (obj_num) as
  select '2','0',
         ot.obj#, 
         mvv.sowner,
         mvv.vname,
         value(mvv),
         value(phtv),
         cast(multiset(select value(iv) from sys.ku$_all_index_view iv, sys.ind$ i
                       where i.bo# = ot.obj# and
                             bitand(i.property,8192) = 8192 and
                             iv.obj_num = i.obj#) as ku$_index_list_t)
  from   sys.obj$ ot, sys.user$ u, sys.ku$_phtable_view phtv,
         sys.ku$_m_view_view mvv
  where  ot.name     = mvv.tname
     and ot.owner#   = u.user#
     and u.name      = mvv.sowner
     and ot.type#    = 2
     and phtv.obj_num = ot.obj#
     and BITAND(mvv.flag,33554432) != 33554432
     and (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (ot.owner#, 0) OR
          EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

create or replace force view ku$_zm_view_ph_view of ku$_m_view_ph_t
  with object identifier (obj_num) as
  select '2','0',
         ot.obj#, 
         mvv.sowner,
         mvv.vname,
         value(mvv),
         value(phtv),
         cast(multiset(select value(iv) from sys.ku$_all_index_view iv, sys.ind$ i
                       where i.bo# = ot.obj# and
                             bitand(i.property,8192) = 8192 and
                             iv.obj_num = i.obj#) as ku$_index_list_t)
  from   sys.obj$ ot, sys.user$ u, sys.ku$_phtable_view phtv,
         sys.ku$_zm_view_view mvv
  where  ot.name     = mvv.tname
     and ot.owner#   = u.user#
     and u.name      = mvv.sowner
     and ot.type#    = 2
     and phtv.obj_num = ot.obj#
     and BITAND(mvv.flag,33554432) != 33554432
     and (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (ot.owner#, 0) OR
          EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

create or replace force view ku$_m_view_fh_view of ku$_m_view_fh_t
  with object identifier (obj_num) as
  select '2','0',
         ot.obj#, 
         mvv.sowner,
         mvv.vname,
         value(mvv),
         value(fhtv),
         cast(multiset(select value(iv) from sys.ku$_all_index_view iv, sys.ind$ i
                       where i.bo# = ot.obj# and
                             bitand(i.property,8192) = 8192 and
                             iv.obj_num = i.obj#) as ku$_index_list_t)
  from   sys.obj$ ot, sys.user$ u, sys.ku$_fhtable_view fhtv,
         sys.ku$_m_view_view mvv
  where  ot.name     = mvv.tname
     and ot.owner#   = u.user#
     and u.name      = mvv.sowner
     and ot.type#    = 2
     and fhtv.obj_num = ot.obj#
     and BITAND(mvv.flag,33554432) != 33554432
     and (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (ot.owner#, 0) OR
          EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

create or replace force view ku$_zm_view_fh_view of ku$_m_view_fh_t
  with object identifier (obj_num) as
  select '2','0',
         ot.obj#, 
         mvv.sowner,
         mvv.vname,
         value(mvv),
         value(fhtv),
         cast(multiset(select value(iv) from sys.ku$_all_index_view iv, sys.ind$ i
                       where i.bo# = ot.obj# and
                             bitand(i.property,8192) = 8192 and
                             iv.obj_num = i.obj#) as ku$_index_list_t)
  from   sys.obj$ ot, sys.user$ u, sys.ku$_fhtable_view fhtv,
         sys.ku$_zm_view_view mvv
  where  ot.name     = mvv.tname
     and ot.owner#   = u.user#
     and u.name      = mvv.sowner
     and ot.type#    = 2
     and fhtv.obj_num = ot.obj#
     and BITAND(mvv.flag,33554432) != 33554432
     and (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (ot.owner#, 0) OR
          EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

create or replace force view ku$_m_view_pfh_view of ku$_m_view_pfh_t
  with object identifier (obj_num) as
  select '2','1',
         ot.obj#, 
         mvv.sowner,
         mvv.vname,
         value(mvv),
         value(pfhtv),
         cast(multiset(select value(iv) from sys.ku$_all_index_view iv, sys.ind$ i
                       where i.bo# = ot.obj# and
                             bitand(i.property,8192) = 8192 and
                             iv.obj_num = i.obj#) as ku$_index_list_t)
  from   sys.obj$ ot, sys.user$ u, sys.ku$_pfhtable_view pfhtv,
         sys.ku$_m_view_view mvv
  where  ot.name     = mvv.tname
     and ot.owner#   = u.user#
     and u.name      = mvv.sowner
     and ot.type#    = 2
     and pfhtv.obj_num = ot.obj#
     and BITAND(mvv.flag,33554432) != 33554432
     and (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (ot.owner#, 0) OR
          EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

create or replace force view ku$_zm_view_pfh_view of ku$_m_view_pfh_t
  with object identifier (obj_num) as
  select '2','1',
         ot.obj#, 
         mvv.sowner,
         mvv.vname,
         value(mvv),
         value(pfhtv),
         cast(multiset(select value(iv) from sys.ku$_all_index_view iv, sys.ind$ i
                       where i.bo# = ot.obj# and
                             bitand(i.property,8192) = 8192 and
                             iv.obj_num = i.obj#) as ku$_index_list_t)
  from   sys.obj$ ot, sys.user$ u, sys.ku$_pfhtable_view pfhtv,
         sys.ku$_zm_view_view mvv
  where  ot.name     = mvv.tname
     and ot.owner#   = u.user#
     and u.name      = mvv.sowner
     and ot.type#    = 2
     and pfhtv.obj_num = ot.obj#
     and BITAND(mvv.flag,33554432) != 33554432
     and (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (ot.owner#, 0) OR
          EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

create or replace force view ku$_m_view_iot_view of ku$_m_view_iot_t
  with object identifier (obj_num) as
  select '2','0',
         ot.obj#, 
         mvv.sowner,
         mvv.vname,
         value(mvv),
         value(iotv),
         cast(multiset(select value(iv) from sys.ku$_all_index_view iv, sys.ind$ i
                       where i.bo# = ot.obj# and
                             bitand(i.property,8192) = 8192 and
                             iv.obj_num = i.obj#) as ku$_index_list_t)
  from   sys.obj$ ot, sys.user$ u, sys.ku$_iotable_view iotv,
         sys.ku$_m_view_view mvv
  where  ot.name     = mvv.tname
     and ot.owner#   = u.user#
     and u.name      = mvv.sowner
     and ot.type#    = 2
     and iotv.obj_num = ot.obj#
     and BITAND(mvv.flag,33554432) = 33554432
     and (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (ot.owner#, 0) OR
          EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

create or replace force view ku$_zm_view_iot_view of ku$_m_view_iot_t
  with object identifier (obj_num) as
  select '2','0',
         ot.obj#, 
         mvv.sowner,
         mvv.vname,
         value(mvv),
         value(iotv),
         cast(multiset(select value(iv) from sys.ku$_all_index_view iv, sys.ind$ i
                       where i.bo# = ot.obj# and
                             bitand(i.property,8192) = 8192 and
                             iv.obj_num = i.obj#) as ku$_index_list_t)
  from   sys.obj$ ot, sys.user$ u, sys.ku$_iotable_view iotv,
         sys.ku$_zm_view_view mvv
  where  ot.name     = mvv.tname
     and ot.owner#   = u.user#
     and u.name      = mvv.sowner
     and ot.type#    = 2
     and iotv.obj_num = ot.obj#
     and BITAND(mvv.flag,33554432) = 33554432
     and (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (ot.owner#, 0) OR
          EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

create or replace force view ku$_m_view_piot_view of ku$_m_view_piot_t
  with object identifier (obj_num) as
  select '2','1',
         ot.obj#, 
         mvv.sowner,
         mvv.vname,
         value(mvv),
         value(piotv),
         cast(multiset(select value(iv) from sys.ku$_all_index_view iv, sys.ind$ i
                       where i.bo# = ot.obj# and
                             bitand(i.property,8192) = 8192 and
                             iv.obj_num = i.obj#) as ku$_index_list_t)
  from   sys.obj$ ot, sys.user$ u, sys.ku$_piotable_view piotv,
         sys.ku$_m_view_view mvv
  where  ot.name     = mvv.tname
     and ot.owner#   = u.user#
     and u.name      = mvv.sowner
     and ot.type#    = 2
     and piotv.obj_num = ot.obj#
     and BITAND(mvv.flag,33554432) = 33554432
     and (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (ot.owner#, 0) OR
              EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

create or replace force view ku$_zm_view_piot_view of ku$_m_view_piot_t
  with object identifier (obj_num) as
  select '2','1',
         ot.obj#, 
         mvv.sowner,
         mvv.vname,
         value(mvv),
         value(piotv),
         cast(multiset(select value(iv) from sys.ku$_all_index_view iv, sys.ind$ i
                       where i.bo# = ot.obj# and
                             bitand(i.property,8192) = 8192 and
                             iv.obj_num = i.obj#) as ku$_index_list_t)
  from   sys.obj$ ot, sys.user$ u, sys.ku$_piotable_view piotv,
         sys.ku$_zm_view_view mvv
  where  ot.name     = mvv.tname
     and ot.owner#   = u.user#
     and u.name      = mvv.sowner
     and ot.type#    = 2
     and piotv.obj_num = ot.obj#
     and BITAND(mvv.flag,33554432) = 33554432
     and (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (ot.owner#, 0) OR
              EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

-------------------------------------------------------------------------------
--                             Materialized Zonemap
-------------------------------------------------------------------------------
--
create or replace force view ku$_m_zonemap_h_view of ku$_m_view_h_t
  with object identifier (obj_num) as
  select '2','0',
         ot.obj#, 
         mvv.sowner,
         mvv.vname,
         value(mvv),
         value(htv),
         cast(multiset(select value(iv) from sys.ku$_all_index_view iv, sys.ind$ i
                       where i.bo# = ot.obj# and
                             bitand(i.property,8192) = 8192 and
                             iv.obj_num = i.obj#) as ku$_index_list_t)
  from   sys.obj$ ot, sys.user$ u, sys.ku$_htable_view htv,
         sys.ku$_m_zonemap_view mvv
  where  ot.name     = mvv.tname
     and ot.owner#   = u.user#
     and u.name      = mvv.sowner
     and ot.type#    = 2
     and htv.obj_num = ot.obj#
     and BITAND(mvv.flag,33554432) != 33554432
     and (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (ot.owner#, 0) OR
          EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

create or replace force view ku$_m_zonemap_ph_view of ku$_m_view_ph_t
  with object identifier (obj_num) as
  select '2','0',
         ot.obj#, 
         mvv.sowner,
         mvv.vname,
         value(mvv),
         value(phtv),
         cast(multiset(select value(iv) from sys.ku$_all_index_view iv, sys.ind$ i
                       where i.bo# = ot.obj# and
                             bitand(i.property,8192) = 8192 and
                             iv.obj_num = i.obj#) as ku$_index_list_t)
  from   sys.obj$ ot, sys.user$ u, sys.ku$_phtable_view phtv,
         sys.ku$_m_zonemap_view mvv
  where  ot.name     = mvv.tname
     and ot.owner#   = u.user#
     and u.name      = mvv.sowner
     and ot.type#    = 2
     and phtv.obj_num = ot.obj#
     and BITAND(mvv.flag,33554432) != 33554432
     and (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (ot.owner#, 0) OR
          EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

create or replace force view ku$_m_zonemap_fh_view of ku$_m_view_fh_t
  with object identifier (obj_num) as
  select '2','0',
         ot.obj#, 
         mvv.sowner,
         mvv.vname,
         value(mvv),
         value(fhtv),
         cast(multiset(select value(iv) from sys.ku$_all_index_view iv, sys.ind$ i
                       where i.bo# = ot.obj# and
                             bitand(i.property,8192) = 8192 and
                             iv.obj_num = i.obj#) as ku$_index_list_t)
  from   sys.obj$ ot, sys.user$ u, sys.ku$_fhtable_view fhtv,
         sys.ku$_m_zonemap_view mvv
  where  ot.name     = mvv.tname
     and ot.owner#   = u.user#
     and u.name      = mvv.sowner
     and ot.type#    = 2
     and fhtv.obj_num = ot.obj#
     and BITAND(mvv.flag,33554432) != 33554432
     and (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (ot.owner#, 0) OR
          EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

create or replace force view ku$_m_zonemap_pfh_view of ku$_m_view_pfh_t
  with object identifier (obj_num) as
  select '2','1',
         ot.obj#, 
         mvv.sowner,
         mvv.vname,
         value(mvv),
         value(pfhtv),
         cast(multiset(select value(iv) from sys.ku$_all_index_view iv, sys.ind$ i
                       where i.bo# = ot.obj# and
                             bitand(i.property,8192) = 8192 and
                             iv.obj_num = i.obj#) as ku$_index_list_t)
  from   sys.obj$ ot, sys.user$ u, sys.ku$_pfhtable_view pfhtv,
         sys.ku$_m_zonemap_view mvv
  where  ot.name     = mvv.tname
     and ot.owner#   = u.user#
     and u.name      = mvv.sowner
     and ot.type#    = 2
     and pfhtv.obj_num = ot.obj#
     and BITAND(mvv.flag,33554432) != 33554432
     and (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (ot.owner#, 0) OR
          EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

create or replace force view ku$_m_zonemap_iot_view of ku$_m_view_iot_t
  with object identifier (obj_num) as
  select '2','0',
         ot.obj#, 
         mvv.sowner,
         mvv.vname,
         value(mvv),
         value(iotv),
         cast(multiset(select value(iv) from sys.ku$_all_index_view iv, sys.ind$ i
                       where i.bo# = ot.obj# and
                             bitand(i.property,8192) = 8192 and
                             iv.obj_num = i.obj#) as ku$_index_list_t)
  from   sys.obj$ ot, sys.user$ u, sys.ku$_iotable_view iotv,
         sys.ku$_m_zonemap_view mvv
  where  ot.name     = mvv.tname
     and ot.owner#   = u.user#
     and u.name      = mvv.sowner
     and ot.type#    = 2
     and iotv.obj_num = ot.obj#
     and BITAND(mvv.flag,33554432) = 33554432
     and (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (ot.owner#, 0) OR
          EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

create or replace force view ku$_m_zonemap_piot_view of ku$_m_view_piot_t
  with object identifier (obj_num) as
  select '2','1',
         ot.obj#, 
         mvv.sowner,
         mvv.vname,
         value(mvv),
         value(piotv),
         cast(multiset(select value(iv) from sys.ku$_all_index_view iv, sys.ind$ i
                       where i.bo# = ot.obj# and
                             bitand(i.property,8192) = 8192 and
                             iv.obj_num = i.obj#) as ku$_index_list_t)
  from   sys.obj$ ot, sys.user$ u, sys.ku$_piotable_view piotv,
         sys.ku$_m_zonemap_view mvv
  where  ot.name     = mvv.tname
     and ot.owner#   = u.user#
     and u.name      = mvv.sowner
     and ot.type#    = 2
     and piotv.obj_num = ot.obj#
     and BITAND(mvv.flag,33554432) = 33554432
     and (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (ot.owner#, 0) OR
              EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

-------------------------------------------------------------------------------
--                             Materialized View Log
-------------------------------------------------------------------------------
--
create or replace force view ku$_m_view_log_view of ku$_m_view_log_t
  with object identifier (mowner,master) as
  select '1',
         case when dbms_metadata.get_version >= '11.02.00.00.00' then '1'
              else '0'
         end,
         m.mowner, m.master,
         to_char(m.oldest,'YYYY-MM-DD HH24:MI:SS'),
         TO_CHAR(m.oldest_pk, 'YYYY-MM-DD HH24:MI:SS'),
         m.oscn,
         TO_CHAR(m.youngest, 'YYYY-MM-DD HH24:MI:SS'),
         m.yscn, m.log, m.trig,
         case when dbms_metadata.get_version >= '11.02.00.00.00'
           then m.flag
           else bitand(m.flag,65535)  /* pre-11.2, flag was a ub2 */
         end,
         TO_CHAR(m.mtime, 'YYYY-MM-DD HH24:MI:SS'),
         m.temp_log,
         TO_CHAR(m.oldest_oid, 'YYYY-MM-DD HH24:MI:SS'),
         TO_CHAR(m.oldest_new, 'YYYY-MM-DD HH24:MI:SS'),
         TO_CHAR(m.oldest_seq, 'YYYY-MM-DD HH24:MI:SS'),
         p.value$,
         case when dbms_metadata.get_version >= '11.02.00.00.00'
           then TO_CHAR(m.purge_start, 'YYYY-MM-DD HH24:MI:SS')
           else NULL
         end,
         case when dbms_metadata.get_version >= '11.02.00.00.00'
           then m.purge_next
           else NULL
         end,
         (select count(*)
                       from   sys.mlog_refcol$ r
                       where  m.mowner = r.mowner
                          and m.master = r.master),
         cast(multiset(select r.colname,
                              to_char(r.oldest, 'YYYY-MM-DD HH24:MI:SS'),
                              r.flag
                       from   sys.mlog_refcol$ r
                       where  m.mowner = r.mowner
                          and m.master = r.master)
                       as ku$_refcol_list_t),
         (select count(*)
                       from   sys.slog$ s
                       where  m.mowner = s.mowner
                          and m.master = s.master),
         cast(multiset(select s.snapid,
                              to_char(s.snaptime, 'YYYY-MM-DD HH24:MI:SS'),
                              case when
                                dbms_metadata.get_version >= '11.02.00.00.00'
                                then s.tscn
                                else NULL
                              end
                       from   sys.slog$ s
                       where  m.mowner = s.mowner
                          and m.master = s.master)
                       as ku$_slog_list_t)
  from   sys.mlog$ m, sys.props$ p
  where  p.name  = 'GLOBAL_DB_NAME'
  /* for < 11.2, exclude MV logs with async_purge, sched_purge, commit scn */
  and (dbms_metadata.get_version >= '11.02.00.00.00'
       or
       (dbms_metadata.get_version < '11.02.00.00.00'
        and bitand(m.flag, 16384+32768+65536)=0))
 UNION ALL
  /* Get staging log details */
  select '1',
         case when dbms_metadata.get_version >= '11.02.00.00.00' then '1'
              else '0'
         end,
         u1.name, o2.name,NULL,NULL,NULL,NULL,NULL,o1.name,NULL,NULL,
         NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
from sys.syncref$_table_info srt, sys.obj$ o1, sys.user$ u1,
     sys.obj$ o2
where dbms_metadata.get_version >= '12.02.00.02.00' and
      o1.owner# = u1.user# and 
      o1.obj# = srt.staging_log_obj# and
      o2.obj# = srt.table_obj#
/

create or replace force view ku$_m_view_log_h_view of ku$_m_view_log_h_t
  with object identifier (tabobj_num) as
  select '1','0',
         htv.obj_num,
         value(mvlv),
         value(htv)
  from   obj$ o, user$ u, sys.ku$_htable_view htv, ku$_m_view_log_view mvlv
  where  mvlv.mowner = u.name
     and mvlv.log    = o.name
     and o.owner#    = u.user#
     and o.type#     = 2
     and o.obj#      = htv.schema_obj.obj_num
     and (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (u.user#, 0) OR
          EXISTS ( SELECT * FROM sys.session_roles
                   WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

create or replace force view ku$_m_view_log_ph_view of ku$_m_view_log_ph_t
  with object identifier (tabobj_num) as
  select '1','0',
         phtv.obj_num,
         value(mvlv),
         value(phtv)
  from   obj$ o, user$ u, sys.ku$_phtable_view phtv, ku$_m_view_log_view mvlv
  where  mvlv.mowner = u.name
     and mvlv.log    = o.name
     and o.owner#    = u.user#
     and o.type#     = 2
     and o.obj#      = phtv.schema_obj.obj_num
     and (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (u.user#, 0) OR
          EXISTS ( SELECT * FROM sys.session_roles
                   WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

create or replace force view ku$_m_view_log_fh_view of ku$_m_view_log_fh_t
  with object identifier (tabobj_num) as
  select '1','0',
         fhtv.obj_num,
         value(mvlv),
         value(fhtv)
  from   obj$ o, user$ u, sys.ku$_fhtable_view fhtv, ku$_m_view_log_view mvlv
  where  mvlv.mowner = u.name
     and mvlv.log    = o.name
     and o.owner#    = u.user#
     and o.type#     = 2
     and o.obj#      = fhtv.schema_obj.obj_num
     and (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (u.user#, 0) OR
          EXISTS ( SELECT * FROM sys.session_roles
                   WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

create or replace force view ku$_m_view_log_pfh_view of ku$_m_view_log_pfh_t
  with object identifier (tabobj_num) as
  select '1','1',
         pfhtv.obj_num,
         value(mvlv),
         value(pfhtv)
  from   obj$ o, user$ u, sys.ku$_pfhtable_view pfhtv, ku$_m_view_log_view mvlv
  where  mvlv.mowner = u.name
     and mvlv.log    = o.name
     and o.owner#    = u.user#
     and o.type#     = 2
     and o.obj#      = pfhtv.schema_obj.obj_num
     and (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (u.user#, 0) OR
          EXISTS ( SELECT * FROM sys.session_roles
                   WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

-------------------------------------------------------------------------------
--                              LIBRARY
-------------------------------------------------------------------------------
-- 
create or replace force view ku$_credential_view of ku$_credential_t
  with object identifier(flags) as
  select '1','0',
         c.obj#, value(o),
         c.password,
         c.domain,
         c.flags
  from sys.ku$_schemaobj_view o, sys.scheduler$_credential c
  where o.type_num=90 AND
        c.obj# = o.obj_num AND
        (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (o.owner_num, 0) OR
                EXISTS ( SELECT * FROM sys.session_roles
                         WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

create or replace force view ku$_library_view of ku$_library_t
  with object identifier(obj_num) as
  select '1','0',
         lb.obj#, value(o),
         lb.filespec,
         replace(lb.audit$,chr(0),'-'),
         lb.property,
         lb.agent,
         (select do.name from sys.obj$ do
          where do.obj#= (select d.p_obj# from sys.dependency$ d
            where d.d_obj#=lb.obj# and do.obj#=d.p_obj# and do.type#=23)),
         lb.leaf_filename,
         (select value(c) from sys.ku$_credential_view c 
          where c.schema_obj.obj_num= (select d.p_obj# from sys.dependency$ d, obj$ oo
            where d.d_obj#=lb.obj# and oo.obj#=d.p_obj# and oo.type#=90))
  from sys.ku$_edition_schemaobj_view o, sys.library$ lb
  where o.type_num=22 AND
        lb.obj# = o.obj_num AND
         (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (o.owner_num, 0) OR
                EXISTS ( SELECT * FROM sys.session_roles
                         WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

-------------------------------------------------------------------------------
--                        TRITION SECURITY (TS)
-------------------------------------------------------------------------------
-- 

-- Triton Security object (xs$obj + xs$prin)

create or replace force view ku$_xsprin_view of ku$_xsprin_t
  with object identifier(prin_id) as
  select '1','0',
  p.prin#,
  p.type,
  p.guid,
  p.ext_src,
  p.start_date,
  p.end_date,
  p.schema,
  p.tablespace,
  p.profile#,
  p.credential,
  p.failedlogins,
  p.enable,
  p.duration,
  p.system,
  p.scope,
  p.powner,
  p.pname,
  (select pn.name from sys.profname$ pn  where pn.profile#=p.profile#),
  p.objacl#,
  p.note,
  p.status,
  p.ctime,
  p.mtime,
  p.ptime,
  p.exptime,
  p.ltime,
  p.lslogontime,
  p.astatus,
  (select verifier from xs$verifiers where user#=p.prin#),
  (select type# from xs$verifiers where user#=p.prin#),
  p.description
  from xs$prin p
/

create or replace force view ku$_xsobj_view of ku$_xsobj_t
  with object identifier(id) as
  select '1','0',
          o.name,
          o.ws,
          o.owner,
          o.tenant,
          o.id,
          o.type,
          o.status,
          o.flags,
          o.early_dep_cnt,
          o.late_dep_cnt,
          o.aclid,
          (select value(p) from ku$_xsprin_view  p where p.prin_id=o.id)
  from xs$obj o
/

-- Triton Security User
-- same to ku$_xsobj_view except contains a where clause to fetch only users.
create or replace force view ku$_xsuser_view of ku$_xsuser_t
  with object identifier(id) as
  select '1','0',
          o.name,
          o.ws,
          o.owner,
          o.tenant,
          o.id,
          o.type,
          o.status,
          (select value(p)
              from ku$_xsprin_view p
              where p.prin_id=o.id)
  from xs$obj o, xs$prin p
  where o.id = p.prin#
  and   bitand(o.flags,1)=0                           /* not Oracle supplied */
  and   o.type=1
  and   p.type=0
/

-- Triton Security Grant related objects
-- This view was only slightly modified  from the system views,
-- DBA_XS_PRIVILEGE_GRANTS and DBA_XS_ACES.
create or replace force view ku$_xsgrant_view of ku$_xsgrant_t 
  with object identifier (name) as
  select '1','0', 
         o2.name, 
         (select u.name from sys.user$ u
                          where u.user# = ace.prin#),
         ace.prin_type, 
         o1.owner 
  from sys.xs$acl acl, sys.xs$ace ace, sys.xs$ace_priv ace_priv,
       sys.xs$obj o1, sys.xs$obj o2, sys.xs$obj o3
 where o2.name in ('ADMIN_ANY_SEC_POLICY', 'ADMIN_SEC_POLICY', 'APPLY_SEC_POLICY')
       and acl.acl# = ace.acl# 
       and bitand(o1.flags,1)=0                       /* not Oracle supplied */
       and ace.acl# = ace_priv.acl# 
       and ace.order# = ace_priv.ace_order#
       and o1.id = ace.acl# and o2.id = ace_priv.priv# and o3.id(+) = acl.sc#
/

-- Triton Security Roles related objects
create or replace force view ku$_xsrole_grant_view of ku$_xsrole_grant_t
  with object identifier(grantee) as
  select '1','0',
  r.grantee#,
  (select name from xs$obj o where o.id=r.grantee#),
  r.role#,
  (select name from xs$obj o where o.id=r.role#),
  r.granter#,
  (select name from xs$obj o where o.id=r.granter#),
  r.start_date,
  r.end_date
  from xs$role_grant r, xs$obj xo
  where xo.id = r.grantee#
    and bitand(xo.flags,1) = 0                        /* not Oracle supplied */
/

create or replace force view ku$_xsrole_view of ku$_xsrole_t
  with object identifier(vers_major) as
  select '1','0',
  (select value(xo) from ku$_xsobj_view xo where p.prin#=xo.id and p.type in (1,2)),
  (cast(multiset(select * from ku$_xsrole_grant_view r
                        where r.role_num = o.id
                      ) as ku$_xsrgrant_list_t))
  from xs$obj o, xs$prin p
  where o.id = p.prin#
  and   bitand(o.flags,1)=0                           /* not Oracle supplied */
  and   p.type in (1,2)
/

-- Triton Rolesets
create or replace force view ku$_xsroleset_view of ku$_xsroleset_t
  with object identifier(rsid) as
  select '1','0',
  rs.rsid#,
  rs.ctime,
  rs.mtime,
  rs.description,
  (select value(xo) from ku$_xsobj_view xo where xo.id = rs.rsid#),
  (cast(multiset(select value(o) from ku$_xsobj_view o
                        where   o.id in (select role# from xs$roleset_roles rsr
                                               where rsr.rsid#=rs.rsid#)
                      ) as ku$_xsobj_list_t))
  from xs$roleset rs, xs$obj xo
  where rs.rsid# = xo.id
    and bitand(xo.flags,1) = 0                        /* not Oracle supplied */
/

-- Triton Privileges
create or replace force view ku$_xsaggpriv_view of ku$_xsaggpriv_t
  with object identifier(scid) as
  select '1','0',
  ap.sc#,
  ap.aggr_priv#,
  ap.implied_priv#,
  (select name  from xs$obj o where o.id = ap.implied_priv#),
  (select owner from xs$obj o where o.id = ap.implied_priv#)
  from xs$aggr_priv ap
/

create or replace force view ku$_xspriv_view of ku$_xspriv_t
  with object identifier(scid) as
  select '1','0',
  p.priv#,
  p.sc#,
  p.ctime,
  p.mtime,
  p.description,
  (select name from xs$obj o where o.id = p.priv#),
  (select owner from xs$obj o where o.id = p.priv#),
  (cast(multiset(select * from ku$_xsaggpriv_view ap
                        where ap.scid = p.sc# and ap.aggr_privid = p.priv#
                      ) as ku$_xsaggpriv_list_t))
  from xs$priv p
/

create or replace force view ku$_xsacepriv_view of ku$_xsacepriv_t
  with object identifier(aclid) as
  select '1','0',
  ap.acl#,
  ap.ace_order#,
  ap.priv#,
  (select value(o) from ku$_xsobj_view o where ap.priv#=o.id)
  from xs$ace_priv ap
/

-- Triton Security class

create or replace force view ku$_xssecclsh_view of ku$_xssecclsh_t
  with object identifier(scid) as
  select '1','0',
  h.sc#,
  h.parent_sc#,
  (select name  from xs$obj o where o.id=h.parent_sc#),
  (select owner from xs$obj o where o.id=h.parent_sc#)
  from xs$seccls_h h
/

create or replace force view ku$_xssclass_view of ku$_xssclass_t
  with object identifier(scid) as
  select '1','1',
  sc.sc#,
  sc.ctime,
  sc.mtime,
  sc.description,
  (select value(xo) from ku$_xsobj_view xo where xo.id = sc.sc#),
  (cast(multiset(select * from ku$_xspriv_view p
                        where p.scid = sc.sc#
                      ) as ku$_xspriv_list_t)),
  (cast(multiset(select value(sh) from ku$_xssecclsh_view sh
                        where  sh.scid = sc.sc#
                      ) as ku$_xssecclsh_list_t))
  from xs$seccls sc, xs$obj xo
  where xo.type = 2
    AND sc.sc#= xo.id
    AND bitand(xo.flags,1)=0                          /* not Oracle supplied */
    AND (NLSSORT(SYS_CONTEXT('USERENV','CURRENT_USER'),'NLS_SORT=BINARY') IN
            ( NLSSORT(xo.owner, 'NLS_SORT=BINARY'),  NLSSORT('SYS', 'NLS_SORT=BINARY')) OR
                EXISTS ( SELECT * FROM sys.session_roles
                         WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/


-- Triton Security ACL (including ACEs, ACLParams, etc) views/types

create or replace force view ku$_xsace_view of ku$_xsace_t
  with object identifier(aclid) as
  select  '1','0',
  c.acl#,
  c.order#,
  c.ace_type,
  c.prin#,
  case when c.prin# > 10000 then
      (select name from xs$obj o where o.id =c.prin#)
  else (select name from user$ where user#=c.prin#)
  end,
  c.prin_type,
  c.prin_invert,
  c.start_date,
  c.end_date,
  (cast(multiset(select * from ku$_xsacepriv_view p
                        where p.aclid = c.acl# and
                              p.ace_order = c.order#
                      ) as ku$_xsacepriv_list_t)),
  (select value(xo) from ku$_xsobj_view xo where xo.id=c.acl#),
  c.ace_flag
  from  xs$ace c
  where bitand(c.ace_flag,2) = 0
/

create or replace force view ku$_xsaclparam_view of ku$_xsaclparam_t
  with object identifier(aclid) as
  select '1','0',
  ap.xdsid#,
  (select name from xs$obj where id = ap.xdsid#),
  (select owner from xs$obj where id = ap.xdsid#),
  ap.acl#,
  ap.pname,
  ap.pvalue1,
  ap.pvalue2,
  (select type from xs$policy_param p where p.xdsid#=ap.xdsid# and p.pname=ap.pname)
  from xs$acl_param ap
/

create or replace force view ku$_xsacl_view of ku$_xsacl_t
  with object identifier(aclid) as
  select '1','0',
  xa.acl#,
  (select o.name from xs$obj o where o.id = xa.acl#),
  (select o.owner from xs$obj o where o.id = xa.acl#),
  xa.sc#,
  (select o.name from xs$obj o where o.id = xa.sc#),
  (select o.owner from xs$obj o where o.id = xa.sc#),
  xa.parent_acl#,
  (select o.name from xs$obj o where o.id = xa.parent_acl#),
  (select o.owner from xs$obj o where o.id = xa.parent_acl#),
  xa.acl_flag,
  xa.ctime,
  xa.mtime,
  xa.description,
  (select value(xo) from ku$_xsobj_view xo where xo.id=xa.acl#),
  (select value(sc) from ku$_xssclass_view sc where sc.scid=xa.sc#),
  (cast(multiset(select * from ku$_xsace_view a
                          where a.aclid = xa.acl#
                        ) as ku$_xsace_list_t
                       )),
  (cast(multiset(select * from ku$_xsaclparam_view a
                          where a.aclid = xa.acl#
                        ) as ku$_xsaclparam_list_t
                       ))
  from xs$acl xa, xs$obj xobj
  where xobj.type = 3
    AND xobj.id = xa.acl#
    AND bitand(xobj.flags,1) = 0                      /* not Oracle supplied */
    AND name != 'XS$SCHEMA_ACL'
    AND (NLSSORT(SYS_CONTEXT('USERENV','CURRENT_USER'),'NLS_SORT=BINARY') IN
       ( NLSSORT(xobj.owner, 'NLS_SORT=BINARY'),  NLSSORT('SYS', 'NLS_SORT=BINARY')) OR
                EXISTS ( SELECT * FROM sys.session_roles
                         WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

------------------------------------------------------
--  Triton Data Security/Policy related views
-------
create or replace force view ku$_xspolicy_param_view of ku$_xspolicy_param_t
  with object identifier(name) as
  select '1','0',
  p.xdsid#,
  (select name from xs$obj where id = p.xdsid#),
  (select owner from xs$obj where id = p.xdsid#),
  p.pname,
  p.type
  from xs$policy_param p
/

create or replace force view ku$_xsinst_acl_view of ku$_xsinst_acl_t
  with object identifier(xdsid) as
  select '1','0',
  i.xdsid#,
  i.order#,
  i.acl#,
  i.acl_order#,
  (select value(xo) from ku$_xsobj_view xo where i.acl#=xo.id)
  from xs$instset_acl i
/

create or replace force view ku$_xsinst_rule_view of ku$_xsinst_rule_t
  with object identifier(xdsid) as
  select '1','0',
  i.xdsid#,
  i.order#,
  REPLACE(i.rule, '''', ''''''),
  i.static,
  i.flags,
  i.description,
  (cast(multiset(select value(a)
                 from ku$_xsinst_acl_view a
                 where a.xdsid= i.xdsid# and a.order_num = i.order#)
                 as ku$_xsinstacl_list_t))
  from xs$instset_rule i
/

create or replace force view ku$_xsinst_inhkey_view of ku$_xsinst_inhkey_t
  with object identifier(xdsid) as
  select '1','0',
  k.xdsid#,
  k.order#,
  k.pkey,                        /* primary key (col name from master table) */
  k.fkey,                  /* foreign key (col name or value in detail table */
  k.fkey_type                         /* 1=fk is col name; 2=fk is col value */
  from xs$instset_inh_key k
/

create or replace force view ku$_xsinst_inh_view of ku$_xsinst_inh_t
  with object identifier(xdsid) as
  select '1','0',
  i.xdsid#,
  i.order#,
  i.parent_schema,
  i.parent_object,
  i.when,
  (cast(multiset(select value(a)
                 from ku$_xsinst_inhkey_view a
                 where a.xdsid= i.xdsid# and a.order_num = i.order#)
                 as ku$_xsinstinhkey_list_t))
  from xs$instset_inh i
/

create or replace force view ku$_xsattrsec_view of ku$_xsattrsec_t
  with object identifier(priv_num) as
  select
  a.xdsid#,
  a.priv#,
  (select name  from xs$obj where id = a.priv#),
  (select owner from xs$obj where id = a.priv#),
  a.attr_name
  from xs$attr_sec a
/

create or replace force view ku$_xsinstset_view of ku$_xsinstset_t
  with object identifier(xdsid) as
  select '1','0',
  i.xdsid#,
  i.order#,
  i.type,
  (select value(r) from ku$_xsinst_rule_view r
                   where r.xdsid= i.xdsid# and r.order_num = i.order#),
  (cast(multiset(select value(a)
                 from ku$_xsinst_inh_view a
                 where a.xdsid= i.xdsid# and a.order_num = i.order#)
                 as ku$_xsinstinh_list_t))
  from xs$instset_list i
/

--  OLAP specific Data Security related views
create or replace force view ku$_xsolap_policy_view of ku$_xsolap_policy_t
  with object identifier(name) as
  select '1','0',
  o.schema_name,
  o.logical_name,
  o.policy_schema,
  o.policy_name,
  o.enable
from xs$olap_policy o
/

-- clone of ku$_rls_policy_view except it will get xml regardless of XDS type.
create or replace force view ku$_xsrls_policy_view of ku$_rls_policy_t
  with object identifier (obj_num,name) as
  select '1','1',
          value(sov),
          r.obj#, r.gname, r.pname,
          BITAND(r.stmt_type,15)+BITAND(r.stmt_type,2048),
          r.check_opt, r.enable_flag, r.pfschma, r.ppname, r.pfname,
          case bitand(r.stmt_type,16+64+128+256+8192+16384+32768)
            when 16 then 'dbms_rls.STATIC'
            when 64 then 'dbms_rls.SHARED_STATIC'
            when 128 then 'dbms_rls.CONTEXT_SENSITIVE'
            when 256 then 'dbms_rls.SHARED_CONTEXT_SENSITIVE'
            when 8192 then 'dbms_rls.XDS1'
            when 16384 then 'dbms_rls.XDS2'
            when 32768 then 'dbms_rls.XDS3'
            else 'dbms_rls.DYNAMIC'
          end,
          BITAND(r.stmt_type,512),
          cast(multiset(select c.name from col$ c, rls_sc$ sc where
                        sc.obj#=r.obj# and
                        sc.gname=r.gname and
                        sc.pname=r.pname and
                        sc.obj#=c.obj# and sc.intcol#=c.intcol#
                       )
               as ku$_rls_sec_rel_col_list_t),
          BITAND(r.stmt_type, 4096),
          cast(multiset(select * from sys.rls_csa$ rlsa where
                        rlsa.obj#=r.obj# and
                        rlsa.gname=r.gname and
                        rlsa.pname=r.pname
                        )
               as ku$_rls_assoc_list_t)
  from    ku$_schemaobj_view sov, sys.rls$ r
  where   r.obj# = sov.obj_num and
          (SYS_CONTEXT('USERENV','CURRENT_USERID') in (0) OR
          EXISTS ( SELECT * FROM sys.session_roles
                   WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

create or replace force view ku$_xspolicy_view of ku$_xspolicy_t
  with object identifier(xdsid) as
  select '1','0',
  p.xdsid#,
  p.ctime,
  p.mtime,
  p.description,
  (select value(xo) from ku$_xsobj_view xo where p.xdsid#=xo.id),
  (cast(multiset(select value(ia)
                 from ku$_xsinstset_view ia
                 where ia.xdsid= p.xdsid#)
                 as ku$_xsinstset_list_t)),
  (cast(multiset(select  value(a)
                 from ku$_xsattrsec_view a
                 where a.xdsid=p.xdsid#
                 order by a.priv_num)
                 as ku$_xsattrsec_list_t)),
(cast(multiset(select value(o) from ku$_xsolap_policy_view o
                  where o.name = (select name from xs$obj o where p.xdsid#=o.id) AND
                        o.owner_name = (select owner from xs$obj o where p.xdsid#=o.id)) as ku$_xsolap_policy_list_t)),
(cast(multiset(select value(r) from ku$_xsrls_policy_view r
                  where  r.pfschma= (select xo.owner from ku$_xsobj_view xo where xo.id=p.xdsid#) and
                         r.name = (select xo.name from ku$_xsobj_view xo where xo.id=p.xdsid#)) as ku$_rls_policy_list_t))
  from xs$dsec p, xs$obj xo
  where xo.type = 5
    AND p.xdsid# = xo.id
    AND bitand(xo.flags,1) = 0                        /* not Oracle supplied */
    AND (NLSSORT(SYS_CONTEXT('USERENV','CURRENT_USER'),'NLS_SORT=BINARY') IN
            ( NLSSORT(xo.owner, 'NLS_SORT=BINARY'),  NLSSORT('SYS', 'NLS_SORT=BINARY')) OR
                EXISTS ( SELECT * FROM sys.session_roles
                         WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

-------
--  Triton Security Namespace related views
-------
create or replace force view ku$_xsnstmpl_attr_view of ku$_xsnstmpl_attr_t
  with object identifier(ns_num) as
  select '1','0',
  a.ns#,
  a.attr_name,
  a.def_value,
  a.event_cbk
  from xs$nstmpl_attr a
/

create or replace force view ku$_xsnspace_view of ku$_xsnspace_t
  with object identifier(ns_num) as
  select '1','0',
  (select value(xo) from ku$_xsobj_view xo where n.ns#=xo.id),
  n.ns#,
  n.acl#,
  n.hschema,
  n.hpname,
  n.hfname,
  n.ctime,
  n.mtime,
  n.description,
  (cast(multiset(select  value(a)
                 from ku$_xsnstmpl_attr_view a
                 where a.ns_num=n.ns#)
                 as ku$_xsnstmpl_attr_list_t))
  from xs$nstmpl n, xs$obj xo
  where xo.type = 7
    AND n.ns# = xo.id
    AND bitand(xo.flags,1) = 0                        /* not Oracle supplied */
    AND (NLSSORT(SYS_CONTEXT('USERENV','CURRENT_USER'),'NLS_SORT=BINARY') IN
            ( NLSSORT(xo.owner, 'NLS_SORT=BINARY'),  NLSSORT('SYS', 'NLS_SORT=BINARY')) OR
                EXISTS ( SELECT * FROM sys.session_roles
                         WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

-------------------------------------------------------------------------------
--                              USER
-------------------------------------------------------------------------------
create or replace force view ku$_user_editioning_view of ku$_user_editioning_t
  with object identifier(user_id) as
  select u.user#,
         et.editionable_type
  from sys.user$ u, sys.v$editionable_types et, sys.user_editioning$ ue
  -- PACKAGE and TYPE are inclusive of BODY.
  where et.type# = ue.type# and ue.user# = u.user# and ue.type# not in (11, 14)
/

-------------------------------------------------------------------------------
--                              ROLE
-------------------------------------------------------------------------------
-- 
-- If the caller (i.e., the user querying the view)
--   (a) is SYS or
--   (b) has EXP_FULL_DATABASE role
-- the caller can see all metadata for the role including passwords.
-- Otherwise, if the caller has SELECT_CATALOG_ROLE
-- the caller can see all metadata for the role except passwords.

create or replace force view ku$_role_view of ku$_role_t
  with object identifier(user_id) as
  select '1','1',
        u.user#,
        u.name,
        u.type#,
        u.password,
          to_char(u.ctime,'YYYY/MM/DD HH24:MI:SS'),
          to_char(u.ptime,'YYYY/MM/DD HH24:MI:SS'),
          to_char(u.exptime,'YYYY/MM/DD HH24:MI:SS'),
          to_char(u.ltime,'YYYY/MM/DD HH24:MI:SS'),
          u.resource$,
          replace(u.audit$,chr(0),'-'),
          u.defrole,
          u.defgrp#,
          u.defgrp_seq#,
          u.astatus,
          u.lcount,
          u.ext_username,
          u.spare1,
          u.spare2,
          u.spare3,
          u.spare4,
          u.spare5,
          to_char(u.spare6,'YYYY/MM/DD HH24:MI:SS'),
        (select r.schema from sys.approle$ r  where r.role#=u.user#),
        (select r.package from sys.approle$ r  where r.role#=u.user#)
  from sys.user$ u
  where   u.type# = 0
  AND (SYS_CONTEXT('USERENV','CURRENT_USERID') = 0
        OR EXISTS ( SELECT * FROM sys.session_roles
                    WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('EXP_FULL_DATABASE', 'NLS_SORT=BINARY') OR
                          NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('DATAPUMP_CLOUD_EXP', 'NLS_SORT=BINARY')))
UNION
  select '1','1',
        u.user#,
        u.name,
        u.type#,
        NULL,
          to_char(u.ctime,'YYYY/MM/DD HH24:MI:SS'),
          to_char(u.ptime,'YYYY/MM/DD HH24:MI:SS'),
          to_char(u.exptime,'YYYY/MM/DD HH24:MI:SS'),
          to_char(u.ltime,'YYYY/MM/DD HH24:MI:SS'),
          u.resource$,
          replace(u.audit$,chr(0),'-'),
          u.defrole,
          u.defgrp#,
          u.defgrp_seq#,
          u.astatus,
          u.lcount,
          u.ext_username,
          u.spare1,
          u.spare2,
          u.spare3,
          NULL,
          u.spare5,
          to_char(u.spare6,'YYYY/MM/DD HH24:MI:SS'),
        (select r.schema from sys.approle$ r  where r.role#=u.user#),
        (select r.package from sys.approle$ r  where r.role#=u.user#)
  from sys.user$ u
  where   u.type# = 0
     AND (SYS_CONTEXT('USERENV','CURRENT_USERID') != 0 )
     AND NOT (EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('EXP_FULL_DATABASE', 'NLS_SORT=BINARY') OR
                             NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('DATAPUMP_CLOUD_EXP', 'NLS_SORT=BINARY')))
     AND (EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

-------------------------------------------------------------------------------
--                              PROFILE
-------------------------------------------------------------------------------
-- 
create or replace force view ku$_profile_attr_view of ku$_profile_attr_t
  with object identifier(profile_id) as
  select  p.profile#,
          p.resource#,
          r.name,
          p.type#,
          p.limit#
  from sys.resource_map r, sys.profile$ p
  where p.resource# = r.resource# and p.type# = r.type#
/

create or replace force view ku$_profile_view of ku$_profile_t
  with object identifier(profile_id) as
  select '1','0',
        n.profile#,
        n.name,
        (select distinct o.name
            from    sys.obj$ o, sys.ku$_profile_attr_view p
            where   o.type# = 8 AND
                    o.owner# = 0 AND
                    o.obj# = p.limit_num and
                    p.profile_id = n.profile# and
                    p.resource_num =4 and    -- res# 4, type# 1 =
                    p.type_num =1 ),         -- PASSWORD_VERIFY_FUNCTION
        cast(multiset (select * from ku$_profile_attr_view pl
            where pl.profile_id = n.profile# ) as ku$_profile_list_t
        )
  from sys.profname$ n
  where (SYS_CONTEXT('USERENV','CURRENT_USERID') = 0
        OR EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

-------------------------------------------------------------------------------
--                              DEFAULT_ROLE
-------------------------------------------------------------------------------
--
create or replace force view ku$_defrole_list_view of ku$_defrole_item_t
  with object identifier(user_id) as
  select  d$.user#, u$.name, u1$.name, d$.role#
  from    sys.user$ u$, sys.user$ u1$, sys.defrole$ d$
  where   u$.user# = d$.user# AND
          u1$.user# = d$.role#
/

create or replace force view ku$_defrole_view of ku$_defrole_t
  with object identifier(user_id) as
  select '1','0',
          u.user#,
          u.name,
          u.type#,
          u.defrole,
          cast(multiset (select * from ku$_defrole_list_view df
                where df.user_id = u.user#) as ku$_defrole_list_t
                )
  from sys.user$ u
  where (SYS_CONTEXT('USERENV','CURRENT_USERID') = 0
                OR EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

-------------------------------------------------------------------------------
--                              PROXY
-------------------------------------------------------------------------------
--
create or replace force view ku$_proxy_role_list_view of ku$_proxy_role_item_t
  with object identifier(client, proxy, role_id) as
  select  prd.role#, uc.name, up.name, ur.name
  from    sys.user$ ur, sys.user$ uc,
          sys.user$ up ,sys.proxy_role_info$ prd
  where   prd.role#   = ur.user# AND
                prd.client# = uc.user# AND
                prd.proxy#  = up.user#
/

create or replace force view ku$_proxy_view of ku$_proxy_t
  with object identifier(user_id) as
  select  u.user#, u.name, up.name, pi.flags,
          pi.credential_type#,
          cast(multiset (select * from ku$_proxy_role_list_view pr
                where pr.client= u.name AND pr.proxy=up.name)
                as ku$_proxy_role_list_t)
  from   sys.user$ u, sys.user$ up, sys.proxy_info$ pi
  where  pi.client# = u.user# AND
         pi.proxy# = up.user#(+)
         AND (SYS_CONTEXT('USERENV','CURRENT_USERID') = 0
                OR EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

-- 10_1 view excludes enterprise user proxies.  No downgrade possible.

create or replace force view ku$_10_1_proxy_view of ku$_proxy_t
  with object identifier(user_id) as
  select t.* from ku$_proxy_view t
  where bitand(t.flags,16)=0
/

-- 
-------------------------------------------------------------------------------
--                              ROLE_GRANT
-------------------------------------------------------------------------------
--
create or replace force view ku$_rogrant_view of ku$_rogrant_t
  with object identifier(grantee_id, role_id) as
  select '1','0',
          u1.user#, u1.name, u2.name, u2.user#, NVL(g.option$, 0), g.sequence#,
          u1.spare1
  from    sys.user$ u1, sys.user$ u2, sys.sysauth$ g
  where   u1.user# = g.grantee# AND
          u2.user# = g.privilege# AND
          g.privilege# > 0
          AND (SYS_CONTEXT('USERENV','CURRENT_USERID') =0
                OR EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

-- DATAPUMP_EXP(IMP)_FULL_DATABASE role not defined in 10g
create or replace force view ku$_11_2_rogrant_view of ku$_rogrant_t
  with object identifier(grantee_id, role_id) as
    select * from ku$_rogrant_view r
      where r.role  NOT IN ('AUDIT_ADMIN',
                            'AUDIT_VIEWER')
/

create or replace force view ku$_10_2_rogrant_view of ku$_rogrant_t
  with object identifier(grantee_id, role_id) as
    select * from ku$_11_2_rogrant_view r
      where r.role  NOT IN ('DATAPUMP_EXP_FULL_DATABASE',
                            'DATAPUMP_IMP_FULL_DATABASE',
                            'DATAPUMP_CLOUD_EXP',
                            'DATAPUMP_CLOUD_IMP')
      and r.grantee NOT IN ('DATAPUMP_EXP_FULL_DATABASE',
                            'DATAPUMP_IMP_FULL_DATABASE',
                            'DATAPUMP_CLOUD_EXP',
                            'DATAPUMP_CLOUD_IMP')
/

-------------------------------------------------------------------------------
--                              TABLESPACE_QUOTA
-------------------------------------------------------------------------------
-- 
create or replace force view ku$_tsquota_view of ku$_tsquota_t
  with object identifier(user_id, ts_id) as
  select  '1','0',
          u.user#, u.name, t.name, q.ts#, q.maxblocks, t.blocksize, q.grantor#,
          'SYSTEM', q.blocks, q.priv1, q.priv2, q.priv3
  from    sys.user$ u, sys.tsq$ q, sys.ts$ t
  where   q.user# = u.user# AND
          q.ts# = t.ts# AND
          q.maxblocks != 0 AND
          t.online$ IN (1, 2, 4) AND
          bitand(t.flags,2048) = 0 AND
          (SYS_CONTEXT('USERENV','CURRENT_USERID') = 0
                OR EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

-------------------------------------------------------------------------------
--                              RESOURCE_COST 
-------------------------------------------------------------------------------
-- 
create or replace force view ku$_resocost_list_view of ku$_resocost_item_t
  with object identifier(resource_id) as
  select  m.resource#, m.name,m.type#, c.cost
  from    sys.resource_cost$ c, sys.resource_map m
  where   c.resource# = m.resource#
/

create or replace force view ku$_resocost_view of ku$_resocost_t
  with object identifier (vers_major) as
  select '1','0',
         cast(multiset (select * from  ku$_resocost_list_view
             ) as  ku$_resocost_list_t
         )
  from dual
/

-- Sequence view definition:
-- Note: Exclude sequences relating to Identity Columns (flags&32 != 0).
--   Also, exclude xml token entity set sequences (flags&1024 != 0). 
--   These are internally created by XDB for CSX type storage. They are
--   re-reated by XDB via procedural action code on the base table.
-- Excluded sequences may not be fetched via get_ddl, and well as being
-- excluded from export.
create or replace force view ku$_sequence_view of ku$_sequence_t
  with object identifier(obj_num) as
  select '1','0',
         s.obj#, value(o),
         s.increment$, TO_CHAR(s.minvalue), TO_CHAR(s.maxvalue),
         s.cycle#, s.order$, s.cache,
         TO_CHAR(s.highwater),  replace(s.audit$,chr(0),'-'), nvl(s.flags,0)
  from  sys.ku$_schemaobj_view o, sys.seq$ s
  where s.obj# = o.obj_num AND bitand(nvl(s.flags,0), 32+1024) = 0 AND
        (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (o.owner_num, 0) OR
         EXISTS ( SELECT * FROM sys.session_roles
                  WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

-------------------------------------------------------------------------------
--                              CONTEXT
-------------------------------------------------------------------------------
-- 
create or replace force view ku$_context_view of ku$_context_t
  with object identifier(obj_num) as
  select '1','0',
         c.obj#, value(o),
         c.schema, c.package, c.flags
  from   sys.ku$_schemaobj_view o, sys.context$ c
  where  o.obj_num = c.obj# AND
         (SYS_CONTEXT('USERENV','CURRENT_USERID') = 0 OR
         NLSSORT(SYS_CONTEXT('USERENV','CURRENT_USER'),'NLS_SORT=BINARY') =  NLSSORT(c.schema, 'NLS_SORT=BINARY') OR 
                EXISTS ( SELECT * FROM sys.session_roles
                         WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

-------------------------------------------------------------------------------
--                              DIMENSION
-------------------------------------------------------------------------------
-- 
create or replace force view ku$_dimension_view of ku$_dimension_t
  with object identifier(obj_num) as
  select '1','0',
         d.obj#, value(o),
         d.dimtextlen,
         sys.dbms_metadata_util.long2clob(d.dimtextlen,
                                        'SYS.DIM$',
                                        'DIMTEXT',
                                        d.rowid)
  from sys.ku$_schemaobj_view o, sys.dim$ d
  where d.obj# = o.obj_num  AND
         (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (o.owner_num, 0) OR
                EXISTS ( SELECT * FROM sys.session_roles
                         WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

-------------------------------------------------------------------------------
--                              ASSOCIATION
-------------------------------------------------------------------------------
create or replace force view ku$_assoc_view of ku$_assoc_t
  with object identifier(obj_num) as
  select '1','0',
        a.obj#,
        value(so),
        a.property,
        (select c.name from  sys.col$ c where c.obj# = a.obj# and
           c.intcol# = a.intcol#),
        (select value(ss) from ku$_schemaobj_view ss where
                   ss.obj_num = a.statstype#),
        NVL(a.default_selectivity, 0), NVL(a.default_cpu_cost, 0),
        NVL(a.default_io_cost, 0), NVL(a.default_net_cost, 0),
        a.interface_version#, a.spare2
   from  sys.ku$_schemaobj_view so,
         sys.association$ a
   where   a.obj# =so.obj_num
         AND (SYS_CONTEXT('USERENV','CURRENT_USERID')=0  or
              EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

-------------------------------------------------------------------------------
--                              PASSWORD_VERIFY_FUNCTION 
-------------------------------------------------------------------------------
--
create or replace force view ku$_pwdvfc_view of ku$_proc_t
  with object identifier (obj_num) as
  select t.vers_major, t.vers_minor, t.obj_num, t.type_num,
         t.schema_obj, t.source_lines
  from ku$_base_proc_view t, profile$ p
  where t.type_num = 8 and t.obj_num = p.limit#
                        and p.resource# =4 and p.type# =1
/

-------------------------------------------------------------------------------
--                              COMMENT
-------------------------------------------------------------------------------
-- 
-- bug 14490576: a comment is dropped by setting the comment value to null.
-- Therefore we need to treat null comment rows as non-existent.
--
create or replace force view ku$_comment_view of ku$_comment_t
  with object identifier(obj_num) as
  select '1','0',
         cm.obj#, value(o),
         (select t.property from sys.tab$ t where t.obj#=cm.obj#),
         cm.col#,
         (select c.name
                 from  sys.col$ c
                 where  c.obj#=cm.obj# and c.intcol# = cm.col# ),
         TO_CLOB(replace(cm.comment$,'''',''''''))
  from   sys.ku$_edition_schemaobj_view o,
                sys.com$ cm
  where  o.obj_num = cm.obj# AND cm.comment$ is not null AND
         (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (o.owner_num, 0) OR
             EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

-- 10_1 view excludes comments on indextypes and operators
-- (type# 32,33) - support added in 10gR2

create or replace force view ku$_10_1_comment_view of ku$_comment_t
  with object identifier(obj_num) as
  select t.* from ku$_comment_view t
  where t.base_obj.type_num not in (32,33)
/

-------------------------------------------------------------------------------
--                              CLUSTER
-------------------------------------------------------------------------------
--
create or replace force view ku$_cluster_view of ku$_cluster_t
  with object identifier(obj_num) as
  select '1','3',
        o.obj_num,
        value(o),
        cast(multiset(select * from ku$_column_view col
                       where col.obj_num = c.obj#
                        order by col.col_num, col.intcol_num
                      ) as ku$_tab_column_list_t
        ),
        ts.name, ts.blocksize,
        ts.ts#, c.file#, c.block#,
        c.pctfree$, c.pctused$, c.initrans, c.maxtrans,NVL(c.size$, -1),
        c.hashfunc, NVL(c.hashkeys, 0), NVL(c.func, 1), c.extind,
        c.flags,
        NVL(c.degree, 1), NVL(c.instances, 1),
        NVL(c.avgchn, -1),
        (select condlength from sys.cdef$ co  where co.obj# = c.obj#),
        NULL,    /* functxt  */
        NULL,    /* func_vcnt */
        (select sys.dbms_metadata_util.long2clob(cd.condlength,
                                        'SYS.CDEF$',
                                        'CONDITION',
                                        cd.rowid)
              from sys.cdef$ cd  where cd.obj# = c.obj#),
        (select value(s) from  ku$_storage_view s
             where s.file_num = c.file#  and  s.block_num= c.block#
                 and s.ts_num = c.ts#),
        c.spare1, c.spare2, c.spare3, c.spare4, c.spare5, c.spare6,
        to_char(c.spare7,'YYYY/MM/DD HH24:MI:SS'),
        (select value(po) from ku$_tab_partobj_view po
          where c.obj# = po.obj_num)
   from     sys.ku$_schemaobj_view o, sys.ts$ ts, sys.clu$ c
   where    o.obj_num = c.obj# AND
                c.ts# = ts.ts# AND
            (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (o.owner_num, 0) OR
             EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

-------------------------------------------------------------------------------
--                              AUDIT
-------------------------------------------------------------------------------
create or replace force view ku$_audit_view of ku$_audit_t
  with object identifier(user_num) as
  select '1','0',
        a.user#,
        u.name,
        a.proxy#,
        m.name, m.property,
        NVL(a.success, 0),
        NVL(a.failure, 0),
        a.option#
  from     sys.audit$ a, sys.stmt_audit_option_map m,
           sys.user$ u
  where    a.user# = u.user# and
           a.option# = m.option# and
           a.option# in (select option# from metaaudit$ ma 
                         where ma.version <= dbms_metadata.get_version)
         AND (SYS_CONTEXT('USERENV','CURRENT_USERID') = 0
                OR EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

-- 11_2 view excludes users not defined prior to 12 release.
create or replace force view ku$_11_2_audit_view of ku$_audit_t
  with object identifier(user_num) as
  select t.* from ku$_audit_view t
  where NLSSORT(t.user_name,  'NLS_SORT=BINARY')  not in
         ( NLSSORT('DVSYS',   'NLS_SORT=BINARY'), 
           NLSSORT('LBACSYS', 'NLS_SORT=BINARY'),
           NLSSORT('DVF',     'NLS_SORT=BINARY'))
/

-------------------------------------------------------------------------------
--                              AUDIT_OBJ
-------------------------------------------------------------------------------
create or replace force view ku$_audit_obj_base_view of ku$_audit_obj_t
  with object identifier(obj_num) as
  select '1','0',
         o.obj_num,
         value(o),
         case when o.type_num = 2
        then (SELECT replace(t.audit$,chr(0),'-') from sys.tab$ t
              where t.obj# = o.obj_num)
        when o.type_num = 4
        then (SELECT replace(v.audit$,chr(0),'-') from sys.view$ v
              where v.obj# = o.obj_num)
        when o.type_num = 6
        then (SELECT replace(s.audit$,chr(0),'-') from sys.seq$ s
              where s.obj# = o.obj_num)
        when (o.type_num in (7, 9))
        then (SELECT replace(p.audit$,chr(0),'-') from sys.procedure$ p
              where p.obj# = o.obj_num)
        when o.type_num = 13
        then (SELECT replace(ty.audit$,chr(0),'-') from sys.type_misc$ ty
              where ty.obj#= o.obj_num)
        when o.type_num = 22
        then (SELECT replace(l.audit$,chr(0),'-') from sys.library$ l
              where l.obj# = o.obj_num)
        when o.type_num = 23
        then (SELECT replace(d.audit$,chr(0),'-') from sys.dir$ d
              where d.obj# = o.obj_num)
        else null end,
         sys.dbms_metadata_util.get_audit(o.obj_num,o.type_num)
  from   ku$_schemaobj_view o
  where  bitand(o.flags,4)=0            -- exclude system-generated objects
/

create or replace force view ku$_audit_obj_view of ku$_audit_obj_t
  with object identifier(obj_num) as
  select value(ku$) from sys.ku$_audit_obj_base_view ku$
  where trim('-' from ku$.audit_val) IS NOT NULL
  and  (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (ku$.base_obj.owner_num, 0)
        OR    EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

-------------------------------------------------------------------------------
--                              AUDIT_DEFAULT
-------------------------------------------------------------------------------
create or replace force view ku$_audit_default_view of ku$_audit_default_t
  with object identifier(obj_num) as
  select '1','0',
         o.obj#,
         t.audit$,
         sys.dbms_metadata_util.get_audit_default(o.obj#)
  from   tab$ t, obj$ o
  where  o.name = '_default_auditing_options_'
    and  o.owner# = 0
    and  t.obj# = o.obj#
    and  trim('-' from replace(t.audit$,chr(0),'-')) IS NOT NULL
/

-------------------------------------------------------------------------------
--                              AUDIT_POLICY
-------------------------------------------------------------------------------
create or replace force view ku$_audit_policy_view of ku$_audit_policy_t
  with object identifier(policy_num) as
select
  policy#,
  value(o),
  type,
  condition,
  condition_eval,
  cast(multiset(select spm.privilege, spm.name, spm.property
                from sys.system_privilege_map spm
                where bitand(pol.type, 1) = 1 and
                      substr(pol.syspriv, -spm.privilege+1, 1) = 'S'
                       ) as ku$_audit_sys_priv_list_t
      ),
  cast(multiset(select asa.action, asa.name
                from sys.auditable_system_actions asa
                where bitand(pol.type, 2) = 2 and
                      asa.type = 4 and
                      substr(pol.sysactn, asa.action+1, 1) = 'S'
                       ) as ku$_audit_act_list_t
      ),
  cast(multiset(select ata.action, ata.name
                from sys.auditable_system_actions ata
                where bitand(pol.type, 2) = 2 and
                      ata.type = 6 and
                      substr(pol.sysactn, ((select max(action)+1 from 
                        sys.auditable_system_actions where type = 4) +
                          ata.action+1), 1) = 'S'
                       ) as ku$_audit_act_list_t
      ),
  cast(multiset(select ata.action, ata.name
                from sys.auditable_system_actions ata
                where bitand(pol.type, 2) = 2 and
                      ata.type = 8 and
                      substr(pol.sysactn, ((select max(action)+1 from 
                         sys.auditable_system_actions where type = 4) +
                           (select count(*)+1 from 
                             sys.auditable_system_actions where type = 6) +
                         ata.action+1), 1) = 'S'
                       ) as ku$_audit_act_list_t
      ),
  cast(multiset(
      select aoa.action, value(ao) , aoa.name
      from sys.auditable_object_actions aoa, sys.aud_object_opt$ opt,
           sys.ku$_schemaobj_view ao
      where opt.policy# = pol.policy# and
        opt.object# = ao.obj_num and
        bitand(pol.type, 4) = 4 and          /* Audit policy has Object option */
        opt.type = 2 and                         /* Schema Object audit option */
        substr(opt.action#, aoa.action+1, 1) = 'S'
                       ) as ku$_auditp_obj_list_t
      ),
  cast(multiset(
      select u.user#, u.name
      from sys.aud_object_opt$ opt, sys.user$ u
      where opt.policy# = pol.policy# and
        opt.object# = u.user# and
        bitand(pol.type, 32) = 32 and          /* Audit policy has Role option */
        opt.type = 1                                      /* Role audit option */
                       ) as ku$_audit_pol_role_list_t
      )
from sys.aud_policy$ pol, ku$_schemaobj_view o
where o.obj_num=pol.policy#
/  
-------------------------------------------------------------------------------
--                              AUDIT_POLICY_ENABLE
-------------------------------------------------------------------------------
create or replace force view ku$_audit_policy_enable_view of ku$_audit_policy_enable_t
  with object identifier(policy_num) as
select
  ng.policy#,
  value(o),
  decode(ng.user#, -1, NULL,
        (select u.name from user$ u where  u.user#=ng.user#)) userid,
  ng."WHEN",
  ng."HOW"
from sys.audit_ng$ ng, ku$_schemaobj_view o
where o.obj_num=ng.policy#
/

create or replace force view ku$_12audit_policy_enable_view of ku$_audit_policy_enable_t
  with object identifier(policy_num) as
select v.* 
from ku$_audit_policy_enable_view v
where v.how_opt  < 3
/  
-------------------------------------------------------------------------------
--                              AUDIT_CONTEXT
-------------------------------------------------------------------------------
create or replace force view ku$_audcontext_namespace_view as
select unique a.user# user#, a.namespace namespace
from sys.aud_context$ a
/  

create or replace force view ku$_audcontext_user_view as
select unique a.user# user#, 
              decode (a.user#, -1, NULL, 
                       (select name from user$ u where u.user#=a.user#)) "USER"
from sys.aud_context$ a
/  

create or replace force view ku$_audit_context_view of ku$_audit_context_t
  with object identifier("USER") as
select
  "USER",
  cast(multiset(
    select
        acn.namespace,
        cast(multiset(
          select attribute
          from aud_context$ aca 
          where aca.user#=acu.user# and aca.namespace=acn.namespace
                                   ) as ku$_audit_attr_list_t)
    from ku$_audcontext_namespace_view acn where acu.user#=acn.user#
                       ) as ku$_audit_namespace_list_t)
from  ku$_audcontext_user_view acu
/  
-------------------------------------------------------------------------------
--                              JAVA_OBJNUM
-------------------------------------------------------------------------------
-- Used to fetch object numbers of java objects - used by heterogeneous
--  object types.  See comments on ku$_view_objnum_view, above.

create or replace force view ku$_java_objnum_view of ku$_schemaobj_t
  with object identifier(obj_num) as
  select value(o) from ku$_schemaobj_view o
  where o.type_num in (28,29,30)
  and bitand(o.flags,16)!= 16       -- exclude secondary objects
 and    (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (o.owner_num, 0)
        OR EXISTS ( SELECT * FROM sys.session_roles
                    WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

-------------------------------------------------------------------------------
--                              JAVA_SOURCE
-------------------------------------------------------------------------------
-- 
create or replace force view ku$_java_source_view of ku$_java_source_t
  with object identifier(obj_num) as
  select '1','0',
         o.obj_num, value(o),
         nvl((select j.longdbcs from sys.javasnm$ j where j.short = o.name),
             o.name),
         cast(multiset(select s.joxftobn, s.joxftlno,
                              NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL, s.joxftsrc
                from  x$joxfs s
                       where s.joxftobn = o.obj_num order by s.joxftlno
                       ) as ku$_source_list_t
             ),
         sys.dbms_metadata.get_java_metadata (o.name,
                                                   o.owner_name, o.type_num)
  from sys.ku$_schemaobj_view o
  where o.type_num = 28 and
            (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (o.owner_num, 0)
             OR EXISTS ( SELECT * FROM sys.session_roles
                         WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

-------------------------------------------------------------------------------
--                              AQ_QUEUE_TABLE
-------------------------------------------------------------------------------
--
-- QUEUE_TABLE storage clause info 
--             Deferred storage is not considered as deferred segment creation
--             is not allowed on queue table.
--
create or replace force view ku$_qtab_storage_view of ku$_qtab_storage_t
  with object identifier(obj_num) as
  select  tab.obj#,tab.property,
          ts.ts#,ts.name,
          tab.pctfree$,tab.pctused$,
          tab.initrans,tab.maxtrans,
          tab.flags,
          (select value(s) from ku$_storage_view s
          where tab.file# = s.file_num
          and tab.block#  = s.block_num
          and tab.ts#     = s.ts_num),
          cast( multiset(select * from ku$_column_view c
                        where c.obj_num = tab.obj#
                        order by c.col_num, c.intcol_num
                        ) as ku$_tab_column_list_t
              ),
         (select value(cl) from ku$_tabcluster_view cl
          where cl.obj_num = tab.obj#)
  from tab$ tab, ts$ ts
  where tab.ts# =ts.ts#
/

create or replace force view ku$_queue_table_view of ku$_queue_table_t
  with object identifier(obj_num) as
  select '1','1',
          t.objno,
          (select value(qo) from  sys.ku$_schemaobj_view qo where
             qo.obj_num=t.objno),
          (select value(s) from sys.ku$_qtab_storage_view s where
             s.obj_num = t.objno),
          t.udata_type,
         (select u.name || '.' || o.name
            from sys.ku$_schemaobj_view o, sys.user$ u,
                 sys.col$ c, sys.coltype$ ct
             where c.intcol# = ct.intcol#
                and c.obj# = ct.obj#
                and c.name = 'USER_DATA'
                and t.objno = c.obj#
                and o.oid = ct.toid
                and o.type_num = 13
                and o.owner_num = u.user#),
         t.sort_cols,
         t.flags,
         t.table_comment,
         aft.primary_instance,
         aft.secondary_instance,
         aft.owner_instance
  from   system.aq$_queue_tables t,
         sys.aq$_queue_table_affinities aft
  where  t.objno = aft.table_objno 
  and    (SYS_CONTEXT('USERENV','CURRENT_USERID') = 0
          OR EXISTS (SELECT * FROM sys.session_roles
                     WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

-------------------------------------------------------------------------------
--                              AQ_QUEUE
-------------------------------------------------------------------------------
-- 
create or replace force view ku$_queues_view of ku$_queues_t
  with object identifier(obj_num) as
  select '1','0',
        t.objno,
        q.eventid,
     (select value(o) from sys.ku$_schemaobj_view o where o.obj_num=q.eventid),
     (select value(b) from sys.ku$_schemaobj_view b where b.obj_num=t.objno),
        t.flags,
        q.usage, q.max_retries, q.retry_delay,
        q.enable_flag,
        q.properties, q.ret_time, q.queue_comment
  from system.aq$_queues q, system.aq$_queue_tables t
  where   q.table_objno = t.objno
/

--
-------------------------------------------------------------------------------
--                              AQ_TRANSFORM
-------------------------------------------------------------------------------
-- 
create or replace force view ku$_qtrans_view of ku$_qtrans_t
  with object identifier(transformation_id) as
  select '1','0',
          t.transformation_id,
          u.name, t.name,
          (select value (f) from ku$_schemaobj_view f where f.oid=t.from_toid),
          (select value (o) from ku$_schemaobj_view o where o.oid=t.to_toid),
          at.attribute_number,
          TO_CLOB(replace(at.sql_expression, '''', ''''''))
  from sys.user$ u , transformations$ t, attribute_transformations$ at
  where  u.name = t.owner and t.transformation_id = at.transformation_id
/

--
-------------------------------------------------------------------------------
--                              JOB
-------------------------------------------------------------------------------
-- 
create or replace force view ku$_job_view of ku$_job_t
  with object identifier(powner_id) as
  select '1','0',
         u.user#, j.powner, j.lowner, j.cowner, j.job,
         TO_CHAR(j.last_date, 'YYYY-MM-DD HH24:MI:SS'),
         TO_CHAR(j.this_date, 'YYYY-MM-DD HH24:MI:SS'),
         TO_CHAR(j.next_date, 'YYYY-MM-DD HH24:MI:SS'),
         j.flag, j.failures,
         REPLACE(REPLACE(j.interval#,chr(0)), '''', ''''''),
         TO_CLOB(REPLACE(j.what, '''', '''''')),
         TO_CLOB(REPLACE(j.nlsenv, '''', '''''')),
         j.env, j.field1, j.charenv
  from   sys.job$ j, sys.user$ u
  where  j.powner = u.name
/

--
-------------------------------------------------------------------------------
--                      TABLE/INDEX/CLUSTER STATISTICS
-------------------------------------------------------------------------------
--

-- Note: this view calls the function dbms_metadata_util.nulltochr0
-- to replace embedded \0 in epvalue characters with CHR(0).
-- In the worst case, this could dramatically increase the
-- size of epvalue; most likely, though, the column will only
-- have one or two \0 characters.  Since histgrm$.epvalue 
-- has a length of 1000 characters, we allocate a VARCHAR2(4000)
-- in the UDT, and that should be big enough for all but
-- pathological cases.

create or replace force view ku$_histgrm_view of ku$_histgrm_t
  with object identifier (obj_num, intcol_num, bucket, endpoint) as
   select  h.obj#, h.intcol#, h.bucket, 
           case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
                then h.endpoint
                else null
           end,
           case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
                then dbms_metadata_util.nulltochr0(
                          case when c.type# in (1, 96)
                               then utl_raw.cast_to_varchar2(h.epvalue_raw)
                               else null
                               end)
                else null
           end,
           case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
                then h.epvalue_raw
                else null
           end,
           h.ep_repeat_count, h.spare1
   from    sys.obj$ o, sys."_HISTGRM_DEC" h, sys.col$ c,
           -- tables
           (select tab.obj#, tab.obj# pobj#
            from tab$ tab            
           union all -- regular partitions
            select tab.obj#, tp.obj# pobj#
            from sys.tabpart$ tp, tab$ tab
            where tp.bo# = tab.obj# 
           union all -- composite partitions
            select tab.obj#, tcp.obj# pobj#
            from sys.tabcompart$ tcp, tab$ tab
            where tcp.bo# = tab.obj#
           union all -- subpartitions
            select tab.obj#, tsp.obj# pobj#
            from sys.tabsubpart$ tsp, sys.tabcompart$ tcp, tab$ tab
            where tcp.bo# = tab.obj# 
              and tsp.pobj# = tcp.obj#) t
   where   h.obj# = t.pobj# and
           c.obj# = t.obj# and 
           o.obj# = h.obj# and 
           h.intcol# = c.intcol#
   order by h.obj#, h.intcol#, bucket
/

-- Get the minimum histogram values for 10.1 compatibility
create or replace force view ku$_10_1_histgrm_min_view of ku$_histgrm_t
  with object identifier (obj_num, intcol_num, endpoint) as
   select  hh.obj#, hh.intcol#, 0, 
           case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
                then hh.minimum
                else null
           end, 
           NULL, NULL, 0, NULL
   from    sys.obj$ o, sys."_HIST_HEAD_DEC" hh
   where   hh.bucket_cnt = 1 AND o.obj# = hh.obj#
/

create or replace force view ku$_10_1_histgrm_max_view of ku$_histgrm_t
  with object identifier (obj_num, intcol_num, endpoint) as
   select  hh.obj#, hh.intcol#, 1, 
           case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
                then hh.maximum
                else null
           end, 
           NULL, NULL, 0, NULL
   from    sys.obj$ o, sys."_HIST_HEAD_DEC" hh
   where   bucket_cnt = 1 AND o.obj# = hh.obj#
/

--
-- view for column statistics
--
-- Note:  this view used to filter out columns that didn't have a distcnt > 0
--        or spare2 that without bit 1 or 2 set.  This was wrong and was fixed.
--
create or replace force view ku$_col_stats_view of ku$_col_stats_t
  with object identifier (obj_num) as
  select  hh.obj#, hh.intcol#, hh.distcnt,
          case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
               then case when hh.lowval is null 
                         then hh.lowval
                         else utl_raw.substr(hh.lowval, 1, 
                                          least(UTL_RAW.LENGTH(hh.lowval), 32))
                         end
               else null
          end, 
          case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
               then hh.lowval
               else null
          end,
          case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
               then case when hh.hival is null 
                         then hh.hival
                         else utl_raw.substr(hh.hival, 1, 
                                           least(UTL_RAW.LENGTH(hh.hival), 32))
                         end
               else null
          end, 
          case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
               then hh.hival
               else null
          end, 
          hh.density, hh.null_cnt, hh.avgcln,
          bitand(hh.spare2, 3), bitand(hh.spare2, 4), hh.sample_size,
          case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
               then hh.minimum
               else null
          end,
          case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
               then hh.maximum
               else null
          end, 
          hh.spare1,
          cast(multiset(select value(hv)
                        from   sys.ku$_histgrm_view hv
                        where  hv.obj_num = hh.obj#
                           and hv.intcol_num = hh.intcol#)
                        as ku$_histgrm_list_t)
  from    sys.obj$ o, sys."_HIST_HEAD_DEC" hh
  where   o.obj# = hh.obj# 
/


--
-- view for table column statistics for 10.1 compatibility
--
create or replace force view ku$_10_1_tab_col_stats_view of
        ku$_10_1_col_stats_t
  with object identifier (tab_obj_num) as
  select  c.obj#, hh.obj#, c.name, hh.intcol#, hh.distcnt,
          case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
               then case when hh.lowval is null 
                         then hh.lowval
                         else utl_raw.substr(hh.lowval,1,
                                          least(UTL_RAW.LENGTH(hh.lowval), 32))
                         end
               else null
          end,
          case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
               then case when hh.hival is null 
                         then hh.hival
                         else utl_raw.substr(hh.hival, 1, 
                                           least(UTL_RAW.LENGTH(hh.hival), 32))
                         end
               else null
          end, 
          hh.density, hh.null_cnt, hh.avgcln, bitand(hh.spare2, 3),
          bitand(hh.spare2, 4),
          cast(multiset(select value(hv)
                        from   sys.ku$_histgrm_view hv
                        where  hv.obj_num = hh.obj#
                           and hv.intcol_num = hh.intcol#)
                        as ku$_histgrm_list_t),
          (select value(hminv)
           from   sys.ku$_10_1_histgrm_min_view hminv
           where  hminv.obj_num = hh.obj#
              and hminv.intcol_num = hh.intcol#),
          (select value(hmaxv)
           from   sys.ku$_10_1_histgrm_max_view hmaxv
           where  hmaxv.obj_num = hh.obj#
              and hmaxv.intcol_num = hh.intcol#)
  from    sys.obj$ o, sys.col$ c, sys."_HIST_HEAD_DEC" hh
  where   hh.obj# = c.obj# and o.obj# = hh.obj# and
          hh.intcol# = c.intcol# and
          -- Need to remove rows for user defined stats.  Look in qosp.h
          -- for macros likeQOS_IS_*_STATS_EXTN.  This is where the next 3
          -- lines were taken from.
          NOT (BITAND(c.property,65576) = 65576 AND
               LENGTH(c.name) > 6 AND
               SUBSTR(c.name, 1, 6) = 'SYS_ST')
/

--
-- view for partition column statistics for 10.1 compatibility
--

create or replace force view ku$_10_1_ptab_col_stats_view of
        ku$_10_1_col_stats_t
  with object identifier (tab_obj_num) as
  select  c.obj#, hh.obj#, c.name, hh.intcol#, hh.distcnt,
          case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
               then case when hh.lowval is null 
                         then hh.lowval
                         else utl_raw.substr(hh.lowval,1,
                                          least(UTL_RAW.LENGTH(hh.lowval), 32))
                         end
               else null
          end,
          case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
               then case when hh.hival is null 
                         then hh.hival
                         else utl_raw.substr(hh.hival, 1, 
                                           least(UTL_RAW.LENGTH(hh.hival), 32))
                         end
               else null
          end, 
          hh.density, hh.null_cnt, hh.avgcln, bitand(hh.spare2, 3),
          bitand(hh.spare2, 4),
          cast(multiset(select value(hv)
                        from   sys.ku$_histgrm_view hv
                        where  hv.obj_num = hh.obj#
                           and hv.intcol_num = hh.intcol#)
                        as ku$_histgrm_list_t),
          (select value(hminv)
           from   sys.ku$_10_1_histgrm_min_view hminv
           where  hminv.obj_num = hh.obj#
              and hminv.intcol_num = hh.intcol#),
          (select value(hmaxv)
           from   sys.ku$_10_1_histgrm_max_view hmaxv
           where  hmaxv.obj_num = hh.obj#
              and hmaxv.intcol_num = hh.intcol#)
  from    sys.obj$ o, sys.col$ c, sys.tabpart$ tp, sys."_HIST_HEAD_DEC" hh
  where   hh.obj# = tp.obj# AND
          tp.bo# = c.obj# AND
          o.obj# = hh.obj# AND
          hh.intcol# = c.intcol# and
          -- Need to remove rows for user defined stats.  Look in qosp.h
          -- for macros likeQOS_IS_*_STATS_EXTN.  This is where the next 3
          -- lines were taken from.
          NOT (BITAND(c.property,65576) = 65576 AND
               LENGTH(c.name) > 6 AND
               SUBSTR(c.name, 1, 6) = 'SYS_ST')
UNION ALL
  select  c.obj#, hh.obj#, c.name, hh.intcol#, hh.distcnt,
          case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
               then case when hh.lowval is null 
                         then hh.lowval
                         else utl_raw.substr(hh.lowval,1,
                                          least(UTL_RAW.LENGTH(hh.lowval), 32))
                         end
               else null
          end,
          case when SYS_OP_DV_CHECK(o.name, o.owner#) = 1
               then case when hh.hival is null 
                         then hh.hival
                         else utl_raw.substr(hh.hival, 1, 
                                           least(UTL_RAW.LENGTH(hh.hival), 32))
                         end
               else null
          end,
          hh.density, hh.null_cnt, hh.avgcln, bitand(hh.spare2, 3),
          bitand(hh.spare2, 4),
          cast(multiset(select value(hv)
                        from   sys.ku$_histgrm_view hv
                        where  hv.obj_num = hh.obj#
                           and hv.intcol_num = hh.intcol#)
                        as ku$_histgrm_list_t),
          (select value(hminv)
           from   sys.ku$_10_1_histgrm_min_view hminv
           where  hminv.obj_num = hh.obj#
              and hminv.intcol_num = hh.intcol#),
          (select value(hmaxv)
           from   sys.ku$_10_1_histgrm_max_view hmaxv
           where  hmaxv.obj_num = hh.obj#
              and hmaxv.intcol_num = hh.intcol#)
  from    sys.obj$ o, sys.col$ c, sys."_HIST_HEAD_DEC" hh,  sys.tabcompart$ tcp,
          sys.tabsubpart$ tsp
  where   hh.obj# = tsp.obj# AND
          tsp.pobj# = tcp.obj# AND
          tcp.bo# = c.obj# AND
          o.obj# = hh.obj# AND
          hh.intcol# = c.intcol# and
          -- Need to remove rows for user defined stats.  Look in qosp.h
          -- for macros likeQOS_IS_*_STATS_EXTN.  This is where the next 3
          -- lines were taken from.
          NOT (BITAND(c.property,65576) = 65576 AND
               LENGTH(c.name) > 6 AND
               SUBSTR(c.name, 1, 6) = 'SYS_ST')
/

create or replace force view ku$_tab_cache_stats_view of ku$_cached_stats_t
    with object identifier (obj_num) as
  select obj#, cachedblk, cachehit from sys.tab_stats$
/

create or replace force view ku$_ind_cache_stats_view of ku$_cached_stats_t
    with object identifier (obj_num) as
  select obj#, cachedblk, cachehit from sys.ind_stats$
/

--
-- view for table specific statistic data
--
create or replace force view ku$_tab_only_stats_view of ku$_tab_ptab_stats_t
  with object identifier (obj_num) as
  select  t.obj#, t.trigflag, o.name, null, null, null,
          bitand(t.property, 2097152), t.blkcnt, t.rowcnt, t.avgrln,
          decode(bitand(t.flags, 768),
                 786, 3,            /* user specified stats and global stats */
                 512, 2,                                /* global stats only */
                 256, 1,                        /* user specified stats only */
                 /* Bug 8794227: t.flags values 768,512,256 gives info about
                    stats type but not about whether table is analyzed or not.
                    To find whether table analyzed or not, one more decode
                    function is added with value 16. */
                 0, decode(bitand(t.flags,16),
                           16,0,                        /* Table is analyzed */
                           4),      /* Table never analyzed or stats deleted */
                 0),
           t.samplesize, TO_CHAR(t.analyzetime, 'YYYY-MM-DD HH24:MI:SS'),
          (select value(tcsv) from sys.ku$_tab_cache_stats_view tcsv
           where t.obj# = tcsv.obj_num),
          cast(multiset(select value(csv)
                        from   sys.ku$_col_stats_view csv
                        where  csv.obj_num = t.obj#)
                        as ku$_col_stats_list_t)
  from    sys.obj$ o, sys.tab$ t
  where   o.obj# = t.obj# AND
          NOT EXISTS (                   /* table does not have associations */
                SELECT 1
                FROM   sys.association$ a
                where  a.obj# = t.obj#) and
          NOT EXISTS (           /* type in table does not have associations */
                SELECT  1
                FROM    sys.obj$ tt, sys.coltype$ ct, sys.association$ a
                WHERE   t.obj# = ct.obj# AND
                        ct.toid = tt.oid$ AND
                        tt.obj# = a.obj#)
/

--
-- view for table specific statistic data for 10.1 compatibility
--
create or replace force view ku$_10_1_tab_only_stats_view of
        ku$_10_1_tab_ptab_stats_t
  with object identifier (obj_num) as
  select  t.obj#, t.trigflag,
          (select value(sov) from ku$_schemaobj_view sov
           where sov.obj_num = t.obj#),
          null, bitand(t.property, 2097152), t.blkcnt, t.rowcnt, t.avgrln,
          decode(bitand(t.flags, 768),
                 786, 3,            /* user specified stats and global stats */
                 512, 2,                                /* global stats only */
                 256, 1,                        /* user specified stats only */
                 /* Bug 8794227: t.flags values 768,512,256 gives info about
                    stats type but not about whether table is analyzed or not.
                    To find whether table analyzed or not, one more decode
                    function is added with value 16. */
                 0, decode(bitand(t.flags,16),
                           16,0,                        /* Table is analyzed */
                              4),   /* Table never analyzed or stats deleted */
                 0),
          (select value(tcsv) from sys.ku$_tab_cache_stats_view tcsv
           where t.obj# = tcsv.obj_num),
          cast(multiset(select value(tcsv)
                        from   sys.ku$_10_1_tab_col_stats_view tcsv
                        where  tcsv.tab_obj_num = t.obj# and
                               bitand(t.property, 2097152) = 0 )
                        as ku$_10_1_col_stats_list_t)
  from    sys.tab$ t
  where   NOT EXISTS (                   /* table does not have associations */
                SELECT 1
                FROM   sys.association$ a
                where  a.obj# = t.obj#) and
          NOT EXISTS (           /* type in table does not have associations */
                SELECT  1
                FROM    sys.obj$ tt, sys.coltype$ ct, sys.association$ a
                WHERE   t.obj# = ct.obj# AND
                        ct.toid = tt.oid$ AND
                        tt.obj# = a.obj#)
/

create or replace force view ku$_ptab_stats_view of ku$_tab_ptab_stats_t
  with object identifier (obj_num) as
  select  /*+ no_merge */
          t.obj#, bt.trigflag, o.name, o.subname, null, t.bo#,
          bitand(bt.property, 2097152), t.blkcnt, t.rowcnt, t.avgrln,
          decode(bitand(t.flags, 24), 24, 3, 16, 2, 8, 1, 0),
          t.samplesize, TO_CHAR(t.analyzetime, 'YYYY-MM-DD HH24:MI:SS'),
          (select value(tcsv) from sys.ku$_tab_cache_stats_view tcsv
           where t.obj# = tcsv.obj_num),
          cast(multiset(select value(csv)
                        from   sys.ku$_col_stats_view csv
                        where  csv.obj_num = t.obj#)
                        as ku$_col_stats_list_t)
  from    sys.obj$ o, sys.tab$ bt, sys.tabpart$ t
  where   o.obj# = t.obj# and
          t.bo# = bt.obj# AND
          NOT EXISTS (                   /* table does not have associations */
                SELECT 1
                FROM   sys.association$ a
                where  a.obj# = t.obj#) and
          NOT EXISTS (           /* type in table does not have associations */
                SELECT  1
                FROM    sys.obj$ tt, sys.coltype$ ct, sys.association$ a
                WHERE   t.obj# = ct.obj# AND
                        ct.toid = tt.oid$ AND
                        tt.obj# = a.obj#) AND
          BITAND(t.flags,2) != 0
UNION ALL
  select  /*+ no_merge */
          t.obj#, bt.trigflag, op.name, op.subname, null, t.bo#,
          bitand(bt.property, 2097152), t.blkcnt, t.rowcnt,
          t.avgrln,
          decode(bitand(t.flags, 24), 24, 3, 16, 2, 8, 1, 0),
          t.samplesize, TO_CHAR(t.analyzetime, 'YYYY-MM-DD HH24:MI:SS'),
          (select value(tcsv) from sys.ku$_tab_cache_stats_view tcsv
           where t.obj# = tcsv.obj_num),
          cast(multiset(select value(csv)
                        from   sys.ku$_col_stats_view csv
                        where  csv.obj_num = t.obj#)
                        as ku$_col_stats_list_t)
  from    sys.obj$ op, sys.tab$ bt, sys.tabcompart$ t
  where   op.obj# = t.obj# and
          t.bo# = bt.obj# AND
          NOT EXISTS (                   /* table does not have associations */
                SELECT 1
                FROM   sys.association$ a
                where  a.obj# = t.obj#) and
          NOT EXISTS (           /* type in table does not have associations */
                SELECT  1
                FROM    sys.obj$ tt, sys.coltype$ ct, sys.association$ a
                WHERE   t.obj# = ct.obj# AND
                        ct.toid = tt.oid$ AND
                        tt.obj# = a.obj#) AND
          BITAND(t.flags,2) != 0
UNION ALL
  select  /*+ no_merge */
          tsp.obj#, bt.trigflag, ot.name, op.subname, ot.subname, t.bo#,
          bitand(bt.property, 2097152), tsp.blkcnt, tsp.rowcnt,
          tsp.avgrln,
          decode(bitand(tsp.flags, 24), 24, 3, 16, 2, 8, 1, 0),
          t.samplesize, TO_CHAR(t.analyzetime, 'YYYY-MM-DD HH24:MI:SS'),
          (select value(tcsv) from sys.ku$_tab_cache_stats_view tcsv
           where t.obj# = tcsv.obj_num),
          cast(multiset(select value(csv)
                        from   sys.ku$_col_stats_view csv
                        where  csv.obj_num = tsp.obj#)
                        as ku$_col_stats_list_t)
  from    sys.obj$ ot, sys.obj$ op, sys.tab$ bt, sys.tabcompart$ t,
          sys.tabsubpart$ tsp
  where   ot.obj# = tsp.obj# and
          tsp.pobj# = t.obj# AND
          t.obj# = op.obj# AND
          t.bo# = bt.obj# AND
          NOT EXISTS (                   /* table does not have associations */
                SELECT 1
                FROM   sys.association$ a
                where  a.obj# = t.obj#) and
          NOT EXISTS (           /* type in table does not have associations */
                SELECT  1
                FROM    sys.obj$ tt, sys.coltype$ ct, sys.association$ a
                WHERE   t.obj# = ct.obj# AND
                        ct.toid = tt.oid$ AND
                        tt.obj# = a.obj#) AND
          BITAND(tsp.flags,2) != 0
/

--
-- Partition view for 10_1 compability
--
create or replace force view ku$_10_1_ptab_stats_view of
        ku$_10_1_tab_ptab_stats_t
  with object identifier (obj_num) as
  select  t.obj#, bt.trigflag,
          (select value(sov) from ku$_schemaobj_view sov
           where sov.obj_num = t.obj#),
          t.bo#, bitand(bt.property, 2097152), t.blkcnt, t.rowcnt, t.avgrln,
          decode(bitand(t.flags, 24), 24, 3, 16, 2, 8, 1, 0),
          (select value(tcsv) from sys.ku$_tab_cache_stats_view tcsv
           where t.obj# = tcsv.obj_num),
          cast(multiset(select value(pcsv)
                        from   sys.ku$_10_1_ptab_col_stats_view pcsv
                        where  pcsv.tab_obj_num = bo# and
                               pcsv.p_obj_num = t.obj# and
                               bitand(bt.property, 2097152) = 0)
                        as ku$_10_1_col_stats_list_t)
  from    sys.tab$ bt, sys.tabpart$ t
  where   t.bo# = bt.obj# AND
          NOT EXISTS (                   /* table does not have associations */
                SELECT 1
                FROM   sys.association$ a
                where  a.obj# = t.obj#) and
          NOT EXISTS (           /* type in table does not have associations */
                SELECT  1
                FROM    sys.obj$ tt, sys.coltype$ ct, sys.association$ a
                WHERE   t.obj# = ct.obj# AND
                        ct.toid = tt.oid$ AND
                        tt.obj# = a.obj#) AND
          BITAND(t.flags,2) != 0
UNION ALL
  select  tsp.obj#, bt.trigflag,
          (select value(sov) from ku$_schemaobj_view sov
           where sov.obj_num = tsp.obj#),
          t.bo#, bitand(bt.property, 2097152), tsp.blkcnt, tsp.rowcnt,
          tsp.avgrln,
          decode(bitand(tsp.flags, 24), 24, 3, 16, 2, 8, 1, 0),
          (select value(tcsv) from sys.ku$_tab_cache_stats_view tcsv
           where t.obj# = tcsv.obj_num),
          cast(multiset(select value(pcsv)
                        from   sys.ku$_10_1_ptab_col_stats_view pcsv
                        where  pcsv.tab_obj_num = bo# and
                               pcsv.p_obj_num = tsp.obj# and
                               bitand(bt.property, 2097152) = 0)
                        as ku$_10_1_col_stats_list_t)
  from    sys.tab$ bt, sys.tabcompart$ t, sys.tabsubpart$ tsp
  where   tsp.pobj# = t.obj# AND
          t.bo# = bt.obj# AND
          NOT EXISTS (                   /* table does not have associations */
                SELECT 1
                FROM   sys.association$ a
                where  a.obj# = t.obj#) and
          NOT EXISTS (           /* type in table does not have associations */
                SELECT  1
                FROM    sys.obj$ tt, sys.coltype$ ct, sys.association$ a
                WHERE   t.obj# = ct.obj# AND
                        ct.toid = tt.oid$ AND
                        tt.obj# = a.obj#) AND
          BITAND(tsp.flags,2) != 0
/

create or replace force view ku$_tab_col_view of ku$_tab_col_t
  with object identifier (obj_num, intcol_num) as
   select  obj#, name, name, intcol#, col#, property,
           decode(c.property, 1056, 1, 0),   -- if nested table, 1, otherwise 0
           decode(c.property , 1056,         -- if nested table get intcol - 1
             (select name from attrcol$ a    -- else get incol info
              where a.obj# = c.obj# AND a.intcol# = c.intcol# - 1),
              (NVL((select name from attrcol$ a
                  where a.obj# = c.obj# AND a.intcol# = c.intcol#), NULL))),
           sys.dbms_metadata_util.long2varchar(c.deflength,
                                               'SYS.COL$',
                                               'DEFAULT$',
                                               c.rowid)
   from    sys.col$ c
   where   BITAND(c.property, 12) != 12 AND
           --
           -- DataPump doesn't support xdp repository columns.  This foolows
           -- the same "hack" that is done in ku$_strmtable_view.  This needs
           -- to be fixed with fusion security.  Basically, 2 columns can't
           -- be imported so the stats for these 2 columns should not be
           -- exported.
           --
           NOT EXISTS (SELECT c1.obj#
                       FROM   sys.col$ c1
                       WHERE  c1.obj# = c.obj# AND
                              c1.intcol# = c.intcol# AND
                              bitand(c.property,32) != 0 AND
                              c.name IN ('OWNERID', 'ACLOID') AND
                              dbms_metadata.get_version < '12.00.00.00.00')
   order by intcol#
/

create or replace force view ku$_10_2_tab_col_view of ku$_tab_col_t
  with object identifier (obj_num, intcol_num) as
   select  obj#, name, name, intcol#, col#, property,
           decode(c.property, 1056, 1, 0),   -- if nested table, 1, otherwise 0
           decode(c.property , 1056,         -- if nested table get intcol - 1
             (select name from attrcol$ a    -- else get incol info
              where a.obj# = c.obj# AND a.intcol# = c.intcol# - 1),
              (NVL((select name from attrcol$ a
                  where a.obj# = c.obj# AND a.intcol# = c.intcol#), NULL))),
           sys.dbms_metadata_util.long2varchar(c.deflength,
                                               'SYS.COL$',
                                               'DEFAULT$',
                                               c.rowid)
   from    sys.col$ c
   where   BITAND(c.property, 12) != 12 AND
          -- Need to remove rows for user defined stats.  Look in qosp.h
          -- for macros likeQOS_IS_*_STATS_EXTN.  This is where the next 3
          -- lines were taken from.
           NOT (BITAND(c.property,65576) = 65576 AND
               LENGTH(c.name) > 6 AND
               SUBSTR(c.name, 1, 6) = 'SYS_ST') AND
           --
           -- DataPump doesn't support xdp repository columns.  This foolows
           -- the same "hack" that is done in ku$_strmtable_view.  This needs
           -- to be fixed with fusion security.  Basically, 2 columns can't
           -- be imported so the stats for these 2 columns should not be
           -- exported.
           --
           NOT EXISTS (SELECT c1.obj#
                       FROM   sys.col$ c1
                       WHERE  c1.obj# = c.obj# AND
                              c1.intcol# = c.intcol# AND
                              bitand(c.property,32) != 0 AND
                              c.name IN ('OWNERID', 'ACLOID') AND
                              dbms_metadata.get_version < '12.00.00.00.00')
   order by intcol#
/

--
-- view for complete table analyzed statistics
--
create or replace force view ku$_tab_stats_view of ku$_tab_stats_t
  with object identifier (obj_num) as
  select  '3', '0', o.obj#,
          -- if this is a nested table, get parent table, otherwise get table.
         decode(bitand(t.property , 8192+512), 8192,
           (select value(oo) from ku$_schemaobj_view oo
            where  oo.obj_num = dbms_metadata_util.get_anc(o.obj#)),
           512, (select value(oo) from ku$_schemaobj_view oo
            where  oo.obj_num = t.bobj#),
           (select value(sov) from ku$_schemaobj_view sov
            where sov.obj_num = o.obj#)),
         decode(bitand(t.property , 8192+512), 8192, o.name, 512, o.name, null)
  from    sys.obj$ o, sys.tab$ t
  where   o.obj# = t.obj# and
          o.type# = 2 and
          (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (o.owner#, 0) OR
              EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

create or replace force view ku$_11_2_tab_stats_view of ku$_11_2_tab_stats_t
  with object identifier (obj_num) as
  select  '2', '1', o.obj#,
          -- if this is a nested table, get parent table, otherwise get table.
         decode(bitand(t.property , 8192), 8192,
           (select value(oo) from ku$_schemaobj_view oo
            where  oo.obj_num = dbms_metadata_util.get_anc(o.obj#)),
           (select value(sov) from ku$_schemaobj_view sov
            where sov.obj_num = o.obj#)),
          decode(bitand(t.property , 8192), 8192, o.name, null),
          cast(multiset(select value(tcv) from sys.ku$_tab_col_view tcv
                        where tcv.obj_num = o.obj#)
               as ku$_tab_col_list_t),
          value(tosv),
          cast(multiset(select value(psv)
                        from   sys.ku$_ptab_stats_view psv
                        where  psv.bobj_num = o.obj#)
                        as ku$_ptab_stats_list_t)
  from    sys.obj$ o, sys.tab$ t, ku$_tab_only_stats_view tosv
  where   tosv.obj_num = o.obj# and
          o.obj# = t.obj# and
          o.type# = 2 and
          -- Bug 8794227: Get the table stats info when stats deleted
          -- but locked based on trigflag value.
          BITAND(t.property, 512) = 0 AND -- NOT AN IOT MAPPING TABLE
          (BITAND(t.flags, 16) != 0 or
           BITAND(t.trigflag,67108864) != 0)
      and (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (o.owner#, 0) OR
              EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

--
-- view for complete table analyzed statistics
--
create or replace force view ku$_10_2_tab_stats_view of ku$_11_2_tab_stats_t
  with object identifier (obj_num) as
  select  '2', '1', o.obj#,
          -- if this is a nested table, get parent table, otherwise get table.
         decode(bitand(t.property , 8192), 8192,
           (select value(oo) from ku$_schemaobj_view oo
            where  oo.obj_num = dbms_metadata_util.get_anc(o.obj#)),
           (select value(sov) from ku$_schemaobj_view sov
            where sov.obj_num = o.obj#)),
          decode(bitand(t.property , 8192), 8192, o.name, null),
          cast(multiset(select value(tcv) from sys.ku$_10_2_tab_col_view tcv
                        where tcv.obj_num = o.obj#)
               as ku$_tab_col_list_t),
          value(tosv),
          cast(multiset(select value(psv)
                        from   sys.ku$_ptab_stats_view psv
                        where  psv.bobj_num = o.obj#)
                        as ku$_ptab_stats_list_t)
  from    sys.obj$ o, sys.tab$ t, ku$_tab_only_stats_view tosv
  where   tosv.obj_num = o.obj# and
          o.obj# = t.obj# and
          o.type# = 2 and
          -- Bug 8794227: Get the table stats info when stats deleted
          -- but locked based on trigflag value.
          BITAND(t.property, 512) = 0 AND -- NOT AN IOT MAPPING TABLE
          (BITAND(t.flags, 16) != 0 or
           bitand(t.trigflag,67108864) != 0)
      and (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (o.owner#, 0) OR
              EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

--
-- view for complete table analyzed statistics for 10.1 compatibility
--
create or replace force view ku$_10_1_tab_stats_view of
        ku$_10_1_tab_stats_t
  with object identifier (obj_num) as
  select  '1', '0', o.obj#,
          -- if this is a nested table, get parent table, otherwise get table.
         decode(bitand(t.property , 8192), 8192,
           (select value(oo) from ku$_schemaobj_view oo
            where  oo.obj_num = dbms_metadata_util.get_anc(o.obj#)),
           (select value(sov) from ku$_schemaobj_view sov
            where sov.obj_num = o.obj#)),
          value(tosv),
          cast(multiset(select value(psv)
                        from   sys.ku$_10_1_ptab_stats_view psv
                        where  psv.bobj_num = o.obj#)
                        as ku$_10_1_ptab_stats_list_t)
  from    sys.obj$ o, sys.tab$ t, ku$_10_1_tab_only_stats_view tosv
  where   tosv.obj_num = o.obj# and
          o.obj# = t.obj# and
          o.type# = 2 and
          -- Bug 8794227: Get the table stats info when stats deleted
          -- but locked based on trigflag value.
          BITAND(t.property, 512) = 0 AND -- NOT AN IOT MAPPING TABLE
          (BITAND(t.flags, 16) != 0 or
           bitand(t.trigflag,67108864) != 0)
      and (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (o.owner#, 0) OR
              EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

--
-- Create view for subpartition information
--
create or replace force view ku$_spind_stats_view of ku$_spind_stats_t
  with object identifier (obj_num) as
  select  o.obj#, op.subname,  o.subname, i.pobj#, i.rowcnt, i.leafcnt,
          i.distkey, i.lblkkey, i.dblkkey, i.clufac, i.blevel,
          decode(bitand(i.flags, 24), 24, 3, 16, 2, 8, 1, 0),
          o.flags, i.samplesize,
          TO_CHAR(i.analyzetime, 'YYYY-MM-DD HH24:MI:SS'),
          (select value(icsv) from sys.ku$_ind_cache_stats_view icsv
           where i.obj# = icsv.obj_num)
  from    sys.obj$ o, sys.obj$ op, sys.indsubpart$ i
  where   i.obj# = o.obj# and
          i.pobj# = op.obj# and
          bitand(i.flags,2) = 2                         /* index is analyzed */
/

--
-- Create view for subpartition information for 10.1 compatibility
--
create or replace force view ku$_10_1_spind_stats_view of
        ku$_10_1_spind_stats_t
  with object identifier (obj_num) as
  select  i.obj#,
          (select value(sov) from sys.ku$_schemaobj_view sov
           where sov.obj_num = i.obj#),
          i.pobj#, i.rowcnt, i.leafcnt, i.distkey, i.lblkkey, i.dblkkey,
          i.clufac, i.blevel,
          decode(bitand(i.flags, 24), 24, 3, 16, 2, 8, 1, 0),
          o.flags,
          (select value(icsv) from sys.ku$_ind_cache_stats_view icsv
           where i.obj# = icsv.obj_num)
  from    sys.obj$ o, sys.indsubpart$ i
  where   i.obj# = o.obj# and
          bitand(i.flags,2) = 2                         /* index is analyzed */
/

create or replace force view ku$_pind_stats_view of ku$_pind_stats_t
  with object identifier (obj_num) as
  select  i.obj#, o.subname,
          i.bo#, i.rowcnt, i.leafcnt, i.distkey, i.lblkkey, i.dblkkey,
          i.clufac, i.blevel,
          decode(bitand(i.flags, 24), 24, 3, 16, 2, 8, 1, 0),
          o.flags, i.samplesize,
          TO_CHAR(i.analyzetime, 'YYYY-MM-DD HH24:MI:SS'),
          (select value(icsv) from sys.ku$_ind_cache_stats_view icsv
           where i.obj# = icsv.obj_num), NULL
  from    sys.obj$ o, sys.indpart$ i
  where   i.obj# = o.obj# and
          bitand(i.flags,2) = 2                         /* index is analyzed */
UNION ALL
  select  i.obj#, o.subname,
          i.bo#, i.rowcnt, i.leafcnt, i.distkey, i.lblkkey, i.dblkkey,
          i.clufac, i.blevel,
          decode(bitand(i.flags, 24), 24, 3, 16, 2, 8, 1, 0),
          o.flags, i.samplesize,
          TO_CHAR(i.analyzetime, 'YYYY-MM-DD HH24:MI:SS'),
          (select value(icsv) from sys.ku$_ind_cache_stats_view icsv
           where i.obj# = icsv.obj_num),
          cast(multiset(select value(sisv)
                        from   sys.ku$_spind_stats_view sisv
                        where  sisv.bobj_num = o.obj#)
                        as ku$_spind_stats_list_t)
  from    sys.obj$ o, sys.indcompart$ i
  where   i.obj# = o.obj# and
          bitand(i.flags,2) = 2                         /* index is analyzed */
/

-- view for 10.1 compatibility
create or replace force view ku$_10_1_pind_stats_view of
        ku$_10_1_pind_stats_t
  with object identifier (obj_num) as
  select  i.obj#,
          (select value(sov) from sys.ku$_schemaobj_view sov
           where sov.obj_num = i.obj#),
          i.bo#, i.rowcnt, i.leafcnt, i.distkey, i.lblkkey, i.dblkkey,
          i.clufac, i.blevel,
          decode(bitand(i.flags, 24), 24, 3, 16, 2, 8, 1, 0),
          o.flags,
          (select value(icsv) from sys.ku$_ind_cache_stats_view icsv
           where i.obj# = icsv.obj_num), NULL
  from    sys.obj$ o, sys.indpart$ i
  where   i.obj# = o.obj# and
          bitand(i.flags,2) = 2                         /* index is analyzed */
UNION ALL
  select  i.obj#,
          (select value(sov) from sys.ku$_schemaobj_view sov
           where sov.obj_num = i.obj#),
          i.bo#, i.rowcnt, i.leafcnt, i.distkey, i.lblkkey, i.dblkkey,
          i.clufac, i.blevel,
          decode(bitand(i.flags, 24), 24, 3, 16, 2, 8, 1, 0),
          o.flags,
          (select value(icsv) from sys.ku$_ind_cache_stats_view icsv
           where i.obj# = icsv.obj_num),
          cast(multiset(select value(sisv)
                        from   sys.ku$_10_1_spind_stats_view sisv
                        where  sisv.bobj_num = o.obj#)
                        as ku$_10_1_spind_stats_list_t)
  from    sys.obj$ o, sys.indcompart$ i
  where   i.obj# = o.obj# and
          bitand(i.flags,2) = 2                         /* index is analyzed */
/

create or replace force view ku$_ind_col_view of ku$_tab_col_t
  with object identifier (obj_num,intcol_num) as
  select  i.obj#, c.name, c.name, i.intcol#, i.col#, c.property,
          decode(c.property, 1056, 1, 0),
          decode(c.property , 1056,
            (select name from attrcol$ a
             where a.obj# = c.obj# AND a.intcol# = c.intcol# - 1),
             (NVL((select name from attrcol$ a
                 where a.obj# = c.obj# AND a.intcol# = c.intcol#), NULL))),
          sys.dbms_metadata_util.long2varchar(c.deflength,
                                              'SYS.COL$',
                                              'DEFAULT$',
                                              c.rowid)
  from    col$ c, icol$ i
  where   i.bo# = c.obj# and
          i.intcol# = c.intcol#
/

-- view for Index stats from version 12 on.
create or replace force view ku$_ind_stats_view of ku$_ind_stats_t
  with object identifier (obj_num) as
  select  '3', '0',
          i.obj#, i.bo#,
         decode(i.type# , 8,
            (select value(sov) from ku$_schemaobj_view sov
             where sov.obj_num = dbms_metadata_util.get_anc(i.bo#)),
           (select value(sov) from ku$_schemaobj_view sov
            where sov.obj_num = i.bo#)),
          (select value(sov) from ku$_schemaobj_view sov
           where sov.obj_num = i.obj#),
          i.type#, i.property
  from    sys.obj$ o, sys.ind$ i
  where   i.obj# = o.obj# and
          (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (o.owner#, 0) OR
              EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

create or replace force view ku$_11_2_ind_stats_view of ku$_11_2_ind_stats_t
  with object identifier (obj_num) as
  select  '2', '1',
          i.obj#, i.bo#,
          (select value(sov) from ku$_schemaobj_view sov
           where sov.obj_num = i.bo#),
          (select value(sov) from ku$_schemaobj_view sov
           where sov.obj_num = i.obj#),
          i.type#, i.property,
          i.intcols, i.rowcnt, i.leafcnt, i.distkey, i.lblkkey, i.dblkkey,
          i.clufac, i.blevel,
          decode(bitand(i.flags, 2112), 2112, 3, 2048, 2, 64, 1, 0),
          o.flags, i.samplesize,
          TO_CHAR(i.analyzetime, 'YYYY-MM-DD HH24:MI:SS'),
          (select value(icsv) from sys.ku$_ind_cache_stats_view icsv
           where i.obj# = icsv.obj_num),
          cast(multiset(select value(psv)
                        from   sys.ku$_pind_stats_view psv
                        where  psv.bobj_num = i.obj#)
                        as ku$_pind_stats_list_t),
          cast(multiset(select value(icv)
                        from   sys.ku$_ind_col_view icv
                        where  icv.obj_num = i.obj# and
                               bitand(o.flags,4) = 4 and /* system generated */
                               bitand(i.property,1) = 1) /* constraint index */
                        as ku$_tab_col_list_t)
  from    sys.obj$ o, sys.ind$ i
  where   i.obj# = o.obj# and
          bitand(i.flags,2) = 2 and
          i.type# != 8 and                                 /* no lob indexes */
          (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (o.owner#, 0) OR
              EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

-- view for 10.2 and 11.1.0.6 compatibility
create or replace force view ku$_10_2_ind_stats_view of ku$_11_2_ind_stats_t
  with object identifier (obj_num) as
  select  '2', '0',
          i.obj#, i.bo#,
          (select value(sov) from ku$_schemaobj_view sov
           where sov.obj_num = i.bo#),
          (select value(sov) from ku$_schemaobj_view sov
           where sov.obj_num = i.obj#),
          i.type#, i.property,
          i.intcols, i.rowcnt, i.leafcnt, i.distkey, i.lblkkey, i.dblkkey,
          i.clufac, i.blevel,
          decode(bitand(i.flags, 2112), 2112, 3, 2048, 2, 64, 1, 0),
          o.flags, i.samplesize,
          TO_CHAR(i.analyzetime, 'YYYY-MM-DD HH24:MI:SS'),
          (select value(icsv) from sys.ku$_ind_cache_stats_view icsv
           where i.obj# = icsv.obj_num),
          cast(multiset(select value(psv)
                        from   sys.ku$_pind_stats_view psv
                        where  psv.bobj_num = i.obj#)
                        as ku$_pind_stats_list_t),
          cast(multiset(select value(icv)
                        from   sys.ku$_ind_col_view icv
                        where  icv.obj_num = i.obj# and
                               bitand(o.flags,4) = 4 and /* system generated */
                               bitand(i.property,1) = 1) /* constraint index */
                        as ku$_tab_col_list_t)
  from    sys.obj$ o, sys.ind$ i
  where   i.obj# = o.obj# and
          bitand(i.flags,2) = 2 and
          i.type# != 8 and                               /* no lob indexes */
          NOT EXISTS (SELECT 1 FROM SYS.COL$ C WHERE     /* no indexes with */
            C.OBJ# = I.BO# AND                           /* system generated */
            BITAND(C.PROPERTY,32) = 32 AND               /* column names */
            BITAND(O.FLAGS, 4) = 4) AND                  /* and index names */
          (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (o.owner#, 0) OR
              EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

-- view for 10.1 compatibility
create or replace force view ku$_10_1_ind_stats_view of
        ku$_10_1_ind_stats_t
  with object identifier (obj_num) as
  select  '1', '0',
          i.obj#, i.bo#,
          (select value(sov) from ku$_schemaobj_view sov
           where sov.obj_num = i.bo#),
          (select value(sov) from ku$_schemaobj_view sov
           where sov.obj_num = i.obj#),
          i.type#, i.property,
          i.cols, i.rowcnt, i.leafcnt, i.distkey, i.lblkkey, i.dblkkey,
          i.clufac, i.blevel,
          decode(bitand(i.flags, 2112), 2112, 3, 2048, 2, 64, 1, 0),
          o.flags,
          (select value(icsv) from sys.ku$_ind_cache_stats_view icsv
           where i.obj# = icsv.obj_num),
          cast(multiset(select value(psv)
                        from   sys.ku$_10_1_pind_stats_view psv
                        where  psv.bobj_num = i.obj#)
                        as ku$_10_1_pind_stats_list_t),
          cast(multiset(select value(icv)
                        from   sys.ku$_ind_col_view icv
                        where  icv.obj_num = i.obj# and
                               bitand(o.flags,4) = 4 and /* system generated */
                               bitand(i.property,1) = 1) /* constraint index */
                        as ku$_tab_col_list_t)
  from    sys.obj$ o, sys.ind$ i
  where   i.obj# = o.obj# and
          bitand(i.flags,2) = 2 and
          i.type# != 8 and                              /* no lob indexes */
          NOT EXISTS (SELECT 1 FROM SYS.COL$ C WHERE    /* no indexes with */
            C.OBJ# = I.BO# AND                          /* system generated */
            BITAND(C.PROPERTY,32) = 32) AND             /* column names */
          (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (o.owner#, 0) OR
              EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

--
-- These views are used in the kustat.xsl style sheet to determine
-- the index name when an index is system generated.
--

--
-- Create view to fetch constraint columns.
--
create or replace force view ku$_find_sgc_cols_view
  of ku$_sgi_col_t with object identifier (con_num) as
  select 0, cc.con#, c.name
  from   ccol$ cc, col$ c
  where  cc.obj# = c.obj# AND
         cc.col# = c.col#;

--
-- Create view to fetch index columns.
--
create or replace force view ku$_find_sgi_cols_view
  of ku$_sgi_col_t with object identifier (obj_num, name) as
  select  i.obj#, 0, c.name
  from    col$ c, icol$ i
  where   i.bo# = c.obj# and
          i.intcol# = c.intcol#
/

create or replace force view ku$_find_sgc_view of ku$_find_sgc_t
  with object identifier (obj_num) as
  select  oi.obj#, cdef$.cols, ui.name, oi.name, ut.name, ot.name,
          cast(multiset(select value(sgcc)
                        from   sys.ku$_find_sgc_cols_view sgcc
                        where  sgcc.con_num = cdef$.con#)
                        as ku$_sgi_col_list_t)
  from    sys.cdef$, sys.obj$ oi, sys.obj$ ot, sys.con$, sys.user$ ui,
          sys.user$ ut
  where   cdef$.obj# = ot.obj# and
          cdef$.con# = con$.con# and
          oi.obj# = cdef$.enabled and
          ot.owner# = ut.user# and
          oi.owner# = ui.user# and
          bitand(cdef$.defer,8) = 8 and                  /* system generated */
          cdef$.type# = 3 and                           /* unique constraint */
          con$.name != oi.name and
          (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (ui.user#,ut.user#,0) OR
              EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
UNION ALL
  select  i.obj#, i.intcols, ui.name, o.name, ut.name, ot.name,
          cast(multiset(select value(sgic)
                        from   sys.ku$_find_sgi_cols_view sgic
                        where  sgic.obj_num = i.obj# and
                               bitand(o.flags,4) = 4 and /* system generated */
                               bitand(i.property,1) = 1) /* constraint index */
                        as ku$_sgi_col_list_t)
  from    sys.obj$ o, sys.obj$ ot, sys.ind$ i, sys.user$ ui, sys.user$ ut
  where   i.obj# = o.obj# and
          i.bo# = ot.obj# and
          o.owner# = ui.user# and
          ot.owner# = ut.user# and
          i.type# != 8 and                              /* no lob indexes */
          bitand(o.flags,4) = 4 and                     /* system generated */
          bitand(i.property,1) = 1 and                  /* constraint index */
          (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (o.owner#, 0) OR
              EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

create or replace force view ku$_find_sgcol_view (
    owner_name, table_name, col_name, col_default) AS
  select  u.name, o.name, c.name, c.default$
  from    sys.col$ c, sys.obj$ o, user$ u
  where   c.obj# = o.obj# and o.owner# = u.user# and default$ IS NOT NULL and
          (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (o.owner#, 0) OR
              EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

create or replace force view ku$_find_attrcol_view (
    owner_name, table_name, col_name, attr_colname) AS
  select  u.name, o.name, c.name, a.name
  from    sys.col$ c, sys.obj$ o, user$ u, sys.attrcol$ a
  where   c.obj# = o.obj# and
          o.owner# = u.user# and
          c.intcol# = a.intcol# and
          a.obj# = c.obj# and
          (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (o.owner#, 0) OR
              EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

create or replace force view ku$_find_ntab_attrcol_view (
     owner_name, table_name, col_name, attr_colname) AS
  select  u.name, o.name, c.name, a.name
  from    sys.col$ c, sys.obj$ o, user$ u, sys.attrcol$ a
  where   c.obj# = o.obj# and
          o.owner# = u.user# and
          c.intcol# - 1 = a.intcol# and
          a.obj# = c.obj# and
          bitand(c.property, 1056) = 1056 and
          (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (o.owner#, 0) OR
              EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

-------------------------------------------------------------------------------
--                              USER PREFERENCE STATS
-------------------------------------------------------------------------------
-- 
create or replace force view ku$_up_stats_view of ku$_up_stats_t
  with object identifier (obj_num) as
  select obj#, pname, valnum, valchar,
         TO_CHAR(chgtime, 'YYYY-MM-DD HH24:MI:SS'), spare1
  from   sys.optstat_user_prefs$
/

create or replace force view ku$_user_pref_stats_view of ku$_user_pref_stats_t
  with object identifier (obj_num) as
  select '1', '0', o.obj#,
         (select value(sov) from ku$_schemaobj_view sov
          where sov.obj_num = o.obj#),
          cast(multiset(select value(usv) from ku$_up_stats_view usv
                        where usv.obj_num = o.obj#
                       ) as ku$_up_stats_list_t
              )
  from   sys.obj$ o
  where  exists (select 1 from sys.optstat_user_prefs$ opt
                 where o.obj# = opt.obj#) and
         (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (o.owner#, 0) OR
              EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

-------------------------------------------------------------------------------
--                              JAVA_CLASS
-------------------------------------------------------------------------------
-- 
create or replace force view ku$_java_class_view of ku$_java_class_t
  with object identifier(obj_num) as
  select '1','0',
         o.obj_num, value(o),
         nvl((select j.longdbcs from sys.javasnm$ j where j.short = o.name),
             o.name),
         sys.dbms_metadata.get_java_metadata (o.name,
                                                   o.owner_name, o.type_num)
  from sys.ku$_schemaobj_view o
  where o.type_num = 29 and
            (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (o.owner_num, 0)
             OR EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

-------------------------------------------------------------------------------
--                              JAVA_RESOURCE
-------------------------------------------------------------------------------
-- 
create or replace force view ku$_java_resource_view of ku$_java_resource_t
  with object identifier(obj_num) as
  select '1','0',
         o.obj_num, value(o),
         nvl((select j.longdbcs from sys.javasnm$ j where j.short = o.name),
             o.name),
         sys.dbms_metadata.get_java_metadata (o.name,
                                                   o.owner_name, o.type_num)
  from sys.ku$_schemaobj_view o
  where o.type_num = 30 and
            (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (o.owner_num, 0)
             OR EXISTS ( SELECT * FROM sys.session_roles
                         WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

-------------------------------------------------------------------------------
--                      REFRESH_GROUP
-------------------------------------------------------------------------------
create or replace force view ku$_add_snap_view of ku$_add_snap_t
  with object identifier (refgroup) as
  select  r.refgroup,
  sys.dbms_metadata_util.get_refresh_add_user(rc.owner,
                                        rc.name,rc.type#,rc.instsite) ,
  sys.dbms_metadata_util.get_refresh_add_dba(rc.owner,
                                        rc.name,rc.type#,rc.instsite)
  from rgroup$ r, rgchild$ rc
  where  r.refgroup = rc.refgroup
/

create or replace force view ku$_refgroup_view of ku$_refgroup_t
  with object identifier (refname) as
  select  '1','0', r.name, u.user#, r.owner, r.refgroup,
          sys.dbms_metadata_util.get_refresh_make_user (r.refgroup),
          sys.dbms_metadata_util.get_refresh_make_dba (r.refgroup),
          cast(multiset(select value(s) from ku$_add_snap_view s
             where s.refgroup =r.refgroup)
                as ku$_add_snap_list_t
          )
  from sys.user$ u, sys.rgroup$  r
  where  u.name=r.owner
        AND (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (r.owner, 0) OR
                EXISTS ( SELECT * FROM sys.session_roles
                         WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

-- 
-------------------------------------------------------------------------------
--                      MONITORING
-------------------------------------------------------------------------------
create or replace force view ku$_monitor_view of ku$_monitor_t
  with object identifier (obj_num) as
  select '1','0',
         o.obj_num,
         value(o),
         decode(bitand(nvl(t.flags, 0), 2097152), 2097152, 1, 0)
  from ku$_schemaobj_view o, sys.tab$ t
  where   t.obj# = o.obj_num and bitand(nvl(t.flags, 0), 2097152) != 0
        AND (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (o.owner_num, 0) OR
                EXISTS ( SELECT * FROM sys.session_roles
                         WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

--
-------------------------------------------------------------------------------
--                      RMGR_PLAN
-------------------------------------------------------------------------------
-- lrg 19308563: txn jomcdon_bug-22318009 adds duplicate RMGR_PLAN and 
-- RMGR_PLAN_DIRECTIVE entries. These can be identified with 'FLAT' appended to 
-- known status values. These must not be export to avoid duplication of plan on 
-- import.
create or replace force view ku$_rmgr_plan_view of ku$_rmgr_plan_t
  with object identifier(obj_num) as
  select '1','0',
        r.obj#,
        (select value(o) from  sys.ku$_schemaobj_view o where
             o.obj_num=r.obj#),
        r.mgmt_method, r.mast_method,
        r.pdl_method, r.num_plan_directives,
        r.description,  r.que_method,
        r.status, r.mandatory
  from resource_plan$ r
  where status not like '%FLAT'
/

--
-------------------------------------------------------------------------------
--                      RMGR_PLAN_DIRECTIVE
-------------------------------------------------------------------------------
-- 
create or replace force view ku$_rmgr_plan_direct_view of ku$_rmgr_plan_direct_t
  with object identifier(obj_num) as
  select '1','0',
         r.obj#,
         (select value(o) from  sys.ku$_schemaobj_view o where
             o.obj_num=r.obj#),
         r.group_or_subplan,
         r.is_subplan,
         decode(r.mgmt_p1,4294967295,0,r.mgmt_p1),
         decode(r.mgmt_p2,4294967295,0,r.mgmt_p2),
         decode(r.mgmt_p3,4294967295,0,r.mgmt_p3),
         decode(r.mgmt_p4,4294967295,0,r.mgmt_p4),
         decode(r.mgmt_p5,4294967295,0,r.mgmt_p5),
         decode(r.mgmt_p6,4294967295,0,r.mgmt_p6),
         decode(r.mgmt_p7,4294967295,0,r.mgmt_p7),
         decode(r.mgmt_p8,4294967295,0,r.mgmt_p8),
         decode(r.active_sess_pool_p1,4294967295,0,r.active_sess_pool_p1),
         decode(r.queueing_p1,4294967295,0,r.queueing_p1),
         decode(r.parallel_degree_limit_p1,4294967295,0,
                r.parallel_degree_limit_p1),
         r.switch_group,
         decode(r.switch_time,4294967295,0,r.switch_time),
         decode(r.switch_estimate,4294967295,0,r.switch_estimate),
         decode(r.max_est_exec_time,4294967295,0,r.max_est_exec_time),
         decode(r.undo_pool,4294967295,0,r.undo_pool),
         r.description, r.status, r.mandatory
  from resource_plan_directive$ r
  where status not like '%FLAT'
/

--
-------------------------------------------------------------------------------
--                      RMGR_CONSUMER_GROUP
-------------------------------------------------------------------------------
-- 
create or replace force view ku$_rmgr_consumer_view of ku$_rmgr_consumer_t
  with object identifier(obj_num) as
  select '1','0',
        r.obj#,
        (select value(o) from  sys.ku$_schemaobj_view o where
                o.obj_num=r.obj#),
        r.mgmt_method,
        r.description,
        r.status, r.mandatory
  from resource_consumer_group$ r
/

--
-------------------------------------------------------------------------------
--                      RMGR_INITIAL_CONSUMER_GROUP
-------------------------------------------------------------------------------
-- 
create or replace force view ku$_rmgr_init_consumer_view of ku$_rmgr_init_consumer_t
  with object identifier(user_num) as
  select '1','0',
        ue.user#,
        ue.name, g.name,
        a.option$,
        ue.defschclass
  from sys.user$ ue, sys.resource_consumer_group$ g, sys.objauth$ a,
       sys.dba_rsrc_consumer_group_privs dr
  where a.obj# = g.obj# and a.grantee# = ue.user#
  and   ue.name = dr.grantee
  and   g.name = dr.granted_group
  and   dr.initial_group = 'YES'
/

--
-------------------------------------------------------------------------------
--                      PASSWORD_HISTORY
-------------------------------------------------------------------------------
-- 
create or replace force view ku$_psw_hist_list_view of ku$_psw_hist_item_t
  with object identifier(user_id) as
  select  h.user#,
          u.name,
          h.password,
          to_char(h.password_date,'YYYY/MM/DD HH24:MI:SS')
  from    sys.user_history$ h, sys.user$ u
  where   h.user# = u.user#
/

create or replace force view ku$_psw_hist_view of ku$_psw_hist_t
  with object identifier (user_id) as
  select '1','1', u.user#, u.name,
         cast(multiset (select * from  ku$_psw_hist_list_view p
                where p.user_id = u.user#) as  ku$_psw_hist_list_t)
  from sys.user$ u
  where exists (select 1 from sys.user_history$ h where h.user# = u.user#)
/

create or replace force view ku$_11_2_psw_hist_view of ku$_psw_hist_t
  with object identifier (user_id) as
  select '1','0', u.user#, u.name,
         cast(multiset (select * from  ku$_psw_hist_list_view p
                where p.user_id = u.user# and 
                      length(p.password) < 31) as  ku$_psw_hist_list_t)
  from sys.user$ u
  where exists (select 1 from sys.user_history$ h where h.user# = u.user#)
/

--
-------------------------------------------------------------------------------
--                      PROC_SYSTEM_GRANT
-- (procedural system privilege grant)
-- corresponds to the grant_sysprivs_exp function of a package in exppkgobj$
-------------------------------------------------------------------------------
--
-- see dtools.bsq for exppkgobj$
create or replace force view ku$_exppkgobj_view
as
select 
  decode (po.package,
    'DBMS_AQ_EXP_QUEUES',             'AQ',
    'DBMS_DM_MODEL_EXP',              'OAA',
    'DBMS_FILE_GROUP_EXP',            'FILE',
    'DBMS_JVM_EXP_PERMS',             'JVM',
    'DBMS_RMGR_GROUP_EXPORT',         'RMGR',
    'DBMS_RMGR_PLAN_EXPORT',          'RMGR',
    'DBMS_RULE_EXP_EV_CTXS',          'RULE',
    'DBMS_RULE_EXP_RULES',            'RULE',
    'DBMS_RULE_EXP_RULE_SETS',        'RULE',
    'DBMS_SCHED_ATTRIBUTE_EXPORT',    'SCHEDULER',
    'DBMS_SCHED_CHAIN_EXPORT',        'SCHEDULER',
    'DBMS_SCHED_CLASS_EXPORT',        'SCHEDULER',
    'DBMS_SCHED_CONSTRAINT_EXPORT',   'SCHEDULER',
    'DBMS_SCHED_CREDENTIAL_EXPORT',   'SCHEDULER',
    'DBMS_SCHED_FILE_WATCHER_EXPORT', 'SCHEDULER',
    'DBMS_SCHED_JOB_EXPORT',          'SCHEDULER',
    'DBMS_SCHED_PROGRAM_EXPORT',      'SCHEDULER',
    'DBMS_SCHED_SCHEDULE_EXPORT',     'SCHEDULER',
    'DBMS_SCHED_WINDOW_EXPORT',       'SCHEDULER',
    'DBMS_SCHED_WINGRP_EXPORT',       'SCHEDULER',
    'DBMS_SQL_TRANSLATOR_EXPORT',     'SQL',
    'DBMS_SUM_RWEQ_EXPORT',           'MATVW',
                                      po.package) tag,
  decode (po.package,
    'DBMS_AQ_EXP_QUEUES',             'Advanced Queuing',
    'DBMS_DM_MODEL_EXP',              'Oracle Advanced Analytics',
    'DBMS_FILE_GROUP_EXP',            'Streams',
    'DBMS_JVM_EXP_PERMS',             'Java VM',
    'DBMS_RMGR_GROUP_EXPORT',         'Resource Manager',
    'DBMS_RMGR_PLAN_EXPORT',          'Resource Manager',
    'DBMS_RULE_EXP_EV_CTXS',          'Rules Catalog',
    'DBMS_RULE_EXP_RULES',            'Rules Catalog',
    'DBMS_RULE_EXP_RULE_SETS',        'Rules Catalog',
    'DBMS_SCHED_ATTRIBUTE_EXPORT',    'Oracle Scheduler',
    'DBMS_SCHED_CHAIN_EXPORT',        'Oracle Scheduler',
    'DBMS_SCHED_CLASS_EXPORT',        'Oracle Scheduler',
    'DBMS_SCHED_CONSTRAINT_EXPORT',   'Oracle Scheduler',
    'DBMS_SCHED_CREDENTIAL_EXPORT',   'Oracle Scheduler',
    'DBMS_SCHED_FILE_WATCHER_EXPORT', 'Oracle Scheduler',
    'DBMS_SCHED_JOB_EXPORT',          'Oracle Scheduler',
    'DBMS_SCHED_PROGRAM_EXPORT',      'Oracle Scheduler',
    'DBMS_SCHED_SCHEDULE_EXPORT',     'Oracle Scheduler',
    'DBMS_SCHED_WINDOW_EXPORT',       'Oracle Scheduler',
    'DBMS_SCHED_WINGRP_EXPORT',       'Oracle Scheduler',
    'DBMS_SQL_TRANSLATOR_EXPORT',     'SQL Translator',
    'DBMS_SUM_RWEQ_EXPORT',           'Materialized Views',
                                      po.package) cmnt,
  po.package,
  po.schema,
  po.class,
  po.type#,
  po.prepost,
  po.level#,
  decode (po.package,
    'DBMS_JVM_EXP_PERMS',             0,
                                      1) hascreate
from exppkgobj$ po
/

create or replace force view ku$_objpkg_view of ku$_objpkg_t
  with object identifier(package) as
  select distinct p.tag, p.cmnt, p.package, p.schema
  FROM  sys.ku$_exppkgobj_view p
  WHERE (SYS_CONTEXT('USERENV','CURRENT_USERID') = 0 OR
         NLSSORT(SYS_CONTEXT('USERENV','CURRENT_USER'),'NLS_SORT=BINARY') =  NLSSORT(p.schema, 'NLS_SORT=BINARY') OR
                EXISTS ( SELECT * FROM sys.session_roles
                         WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

create or replace force view ku$_proc_grant_view of ku$_objpkg_privs_t
  with object identifier(package) as
  select '1','2',
         p.tag, p.cmnt, p.package, p.schema,
         sys.dbms_metadata.get_sysprivs
                (p.tag, p.package, p.schema, 'GRANT_SYSPRIVS_EXP')
  from  sys.ku$_objpkg_view p
/

--
-------------------------------------------------------------------------------
--                      PROC_AUDIT
-- (procedural system privilege audit) - corresponds to
-- the audit_sysprivs_exp function of a package in exppkgobj$
-------------------------------------------------------------------------------
--
create or replace force view ku$_proc_audit_view of ku$_objpkg_privs_t
  with object identifier(package) as
  select '1','2',
        p.tag, p.cmnt, p.package, p.schema,
        sys.dbms_metadata.get_sysprivs
                (p.tag, p.package, p.schema, 'AUDIT_SYSPRIVS_EXP')
  from  sys.ku$_objpkg_view p
/

--
-------------------------------------------------------------------------------
--                      PROCOBJ
-- (system/schema procedural objects) - corresponds to the create_exp function
-- of a package in exppkgobj$ where the class is 1 (system) or 2 (schema)
-------------------------------------------------------------------------------
--
create or replace force view ku$_procobj_view of ku$_procobj_t
  with object identifier(obj_num) as
  select '1','0',
         o.obj_num,
         value(o),
         p.class,
         p.prepost,
         o.type_num,
         p.level#,
         p.tag,
         p.cmnt,
         p.package,
         p.schema,
         sys.dbms_metadata.get_procobj
                (p.tag, p.package, p.schema,'CREATE_EXP', 
                 o.owner_name || '.' || o.name || ' - ' || o.type_name, o.obj_num,
                  (select 1 from dual
                   where  (SYS_CONTEXT('USERENV','CURRENT_USERID') = 0
                   OR EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))))
  from   sys.ku$_schemaobj_view o, sys.ku$_exppkgobj_view p
  where  p.type#=o.type_num and
         (p.class=1 or p.class=2) and
         p.hascreate=1 and
         (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (o.owner_num, 0) OR
              EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

-- Used to fetch object numbers of procedural objects - used by heterogeneous
--  object types.  See comments on ku$_view_objnum_view, above.
--  Note that we do not exclude procedural objects in SYS.
--

create or replace force view ku$_procobj_objnum_view of ku$_schemaobj_t
  with object identifier(obj_num) as
  select value(o) 
  from   sys.ku$_schemaobj_view o, sys.ku$_exppkgobj_view p
  where  p.type#=o.type_num and
         bitand(o.flags,16)!=16 and         /* not secondary object */
        (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (o.owner_num, 0)
        OR EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

--
-------------------------------------------------------------------------------
--                      PROCOBJ_GRANT
-- (grants on system/schema procedural objects) - corresponds to the
-- grant_exp function of a package in exppkgobj$ where the class is 1 (system)
-- or 2 (schema).
-------------------------------------------------------------------------------
--
create or replace force view ku$_procobj_grant_view of ku$_procobj_grant_t
  with object identifier(obj_num) as
  select '1','0',
         o.obj_num,
         value(o),
         p.class,
         p.prepost,
         o.type_num,
         p.level#,
         p.tag,
         p.cmnt,
         p.package,
         p.schema,
         sys.dbms_metadata.get_procobj_grant
                (p.tag, p.package, p.schema, 'GRANT_EXP',
                 o.owner_name || '.' || o.name || ' - ' || o.type_name, o.obj_num,
                  (select 1 from dual
                   where  (SYS_CONTEXT('USERENV','CURRENT_USERID') = 0
                   OR EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))))
  from sys.ku$_schemaobj_view o, sys.ku$_exppkgobj_view p
  where p.type#=o.type_num and
        (p.class=1 or p.class=2) and
        (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (o.owner_num, 0) OR
              EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

--
-------------------------------------------------------------------------------
--                      PROCOBJ_AUDIT
-- (audits on system/schema procedural objects) - corresponds to the
-- audit_exp function of a package in exppkgobj$ where the class is 1 (system)
-- or 2 (schema).
-------------------------------------------------------------------------------
--
create or replace force view ku$_procobj_audit_view of ku$_procobj_audit_t
  with object identifier(obj_num) as
  select '1','0',
         o.obj_num,
         value(o),
         p.class,
         p.prepost,
         o.type_num,
         p.level#,
         p.tag,
         p.cmnt,
         p.package,
         p.schema,
         sys.dbms_metadata.get_procobj
                (p.tag, p.package, p.schema,'AUDIT_EXP',
                 o.owner_name || '.' || o.name || ' - ' || o.type_name, o.obj_num,
                  (select 1 from dual
                   where  (SYS_CONTEXT('USERENV','CURRENT_USERID') = 0
                   OR EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))))
  from sys.ku$_schemaobj_view o, sys.ku$_exppkgobj_view p 
  where p.type#=o.type_num and (p.class=1 or p.class=2) and
    (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (o.owner_num, 0) OR
              EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

--
-------------------------------------------------------------------------------
--                      PROCDEPOBJ
-- (instance procedural objects) - corresponds to the create_exp function
-- of a package in exppkgobj$ where the class is 3 (instance)
-- and where there is a corresponding row in expdepobj$.
-------------------------------------------------------------------------------
--
create or replace force view ku$_procdepobj_view of ku$_procdepobj_t
  with object identifier(obj_num) as
  select '1','0',
         o.obj_num,
         value(o),
         p.class, p.prepost, p.type#, p.level#, 
         p.tag, p.cmnt, p.package, p.schema,
         oo.obj_num,
         value(oo),
         sys.dbms_metadata.get_procobj
                (p.tag, p.package, p.schema,'CREATE_EXP', 
                 o.owner_name || '.' || o.name || ' - ' || o.type_name, o.obj_num,
                  (select 1 from dual
                   where  (SYS_CONTEXT('USERENV','CURRENT_USERID') = 0
                   OR EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))))
  from   sys.ku$_schemaobj_view o, sys.ku$_schemaobj_view oo,
         sys.ku$_exppkgobj_view p,
         (select dp.p_obj#,dp.d_obj# from sys.expdepobj$ dp
             where not exists (select 1 from sys.expdepobj$ dp2
                         where dp.d_obj#=dp2.d_obj# and dp.rowid < dp2.rowid)) d 
  where  p.class = 3 and p.type# = o.type_num and
                d.d_obj# = o.obj_num AND
                d.p_obj# = oo.obj_num
         AND (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (o.owner_num, 0) OR
              EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
  order  by p.level#, p.type#
/

--
-------------------------------------------------------------------------------
--                      PROCDEPOBJ_GRANT
-- (grants on instance procedural objects) - corresponds to the
-- grant_exp function of a package in exppkgobj$ where the class is 3 (instance)
-- and where there is a corresponding row in expdepobj$.
-------------------------------------------------------------------------------
--
create or replace force view ku$_procdepobj_grant_view of ku$_procdepobjg_t
  with object identifier(obj_num) as
  select '1','0',
         o.obj_num,
         value(o),
         p.class, p.prepost, p.type#, p.level#, 
         p.tag, p.cmnt, p.package, p.schema,
         value(oo),
         sys.dbms_metadata.get_procobj_grant
               (p.tag, p.package, p.schema, 'GRANT_EXP', 
                o.owner_name || '.' || o.name || ' - ' || o.type_name, o.obj_num,
                (select 1 from dual
                 where  (SYS_CONTEXT('USERENV','CURRENT_USERID') = 0
                 OR EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))))
  from   sys.ku$_schemaobj_view o, sys.ku$_schemaobj_view oo,
         sys.ku$_exppkgobj_view p, 
         (select dp.p_obj#,dp.d_obj# from sys.expdepobj$ dp
             where not exists (select 1 from sys.expdepobj$ dp2
                         where dp.d_obj#=dp2.d_obj# and dp.rowid < dp2.rowid)) d
  where  p.class = 3 and p.type# = o.type_num and
                d.d_obj# = o.obj_num AND
                d.p_obj# = oo.obj_num
         AND (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (o.owner_num, 0) OR
              EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
  order  by p.level#, p.type#
/

--
-------------------------------------------------------------------------------
--                      PROCDEPOBJ_AUDIT
-- (audits on instance procedural objects) - corresponds to the
-- audit_exp function of a package in exppkgobj$ where the class is 3 (instance)
-- and where there is a corresponding row in expdepobj$.
-------------------------------------------------------------------------------
--
create or replace force view ku$_procdepobj_audit_view of ku$_procdepobja_t
  with object identifier(obj_num) as
  select '1','0',
         o.obj_num,
         value(o),
         p.class, p.prepost, p.type#, p.level#, 
         p.tag, p.cmnt, p.package, p.schema,
         value(oo),
         sys.dbms_metadata.get_procobj
          (p.tag, p.package, p.schema, 'AUDIT_EXP',
           o.owner_name || '.' || o.name || ' - ' || o.type_name, o.obj_num,
            (select 1 from dual
                where  (SYS_CONTEXT('USERENV','CURRENT_USERID') = 0
                OR EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))))
  from   sys.ku$_schemaobj_view o, sys.ku$_schemaobj_view oo,
         sys.ku$_exppkgobj_view p, 
         (select dp.p_obj#,dp.d_obj# from sys.expdepobj$ dp
             where not exists (select 1 from sys.expdepobj$ dp2
                         where dp.d_obj#=dp2.d_obj# and dp.rowid < dp2.rowid)) d
  where  p.class = 3 and p.type# = o.type_num and
                d.d_obj# = o.obj_num AND
                d.p_obj# = oo.obj_num
         AND (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (o.owner_num, 0) OR
              EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
  order by p.level#, p.type#
/

--
-------------------------------------------------------------------------------
--                      PROCACT_SYSTEM
-- (system procedural actions) - corresponds to the system_info_exp function
-- of a package in exppkgact$ where the class is 1 (system).
------------------------------------------------------------------------------
--
-- see dtools.bsq for exppkgact$
create or replace force view ku$_exppkgact_view
as
select 
  decode (pa.package,
    'DBMSHSXP',                      'SERVERM',
    'DBMSZEXP_SYSPKGGRNT',           'SEC',
    'DBMS_AQ_EXP_CMT_TIME_TABLES',   'AQ',
    'DBMS_AQ_EXP_DEQUEUELOG_TABLES', 'AQ',
    'DBMS_AQ_EXP_HISTORY_TABLES',    'AQ',
    'DBMS_AQ_EXP_INDEX_TABLES',      'AQ',
    'DBMS_AQ_EXP_QUEUE_TABLES',      'AQ',
    'DBMS_AQ_EXP_SIGNATURE_TABLES',  'AQ',
    'DBMS_AQ_EXP_SUBSCRIBER_TABLES', 'AQ',
    'DBMS_AQ_EXP_TIMEMGR_TABLES',    'AQ',
    'DBMS_AUTO_TASK_EXPORT',         'SERVERM',
    'DBMS_AW_EXP',                   'OLAPAW',
    'DBMS_CSX_ADMIN',                'XDB',
    'DBMS_CUBE_EXP',                 'OLAPC',
    'DBMS_DBFS_SFS_ADMIN',           'DBFS',
    'DBMS_FILE_GROUP_EXP',           'FILE',
    'DBMS_GOLDENGATE_EXP',           'GOLDENGATE',
    'DBMS_LOGMNR_LOGREP_DICT',       'LOGMNR',
    'DBMS_LOGREP_EXP',               'LOGREP',
    'DBMS_RMGR_PACT_EXPORT',         'RMGR',
    'DBMS_RULE_EXP_RULES',           'RULE',
    'DBMS_SCHED_EXPORT_CALLOUTS',    'SCHEDULER',
    'DBMS_SERVER_ALERT_EXPORT',      'SRVR',
    'DBMS_TRANSFORM_EXIMP',          'OLTP',
    'SDO_RDF_EXP_IMP',               'SEMANTIC',
                                     pa.package) tag,
  decode (pa.package,
    'DBMSHSXP',                      'Server Manageability',
    'DBMSZEXP_SYSPKGGRNT',           'Security',
    'DBMS_AQ_EXP_CMT_TIME_TABLES',   'Advanced Queuing',
    'DBMS_AQ_EXP_DEQUEUELOG_TABLES', 'Advanced Queuing',
    'DBMS_AQ_EXP_HISTORY_TABLES',    'Advanced Queuing',
    'DBMS_AQ_EXP_INDEX_TABLES',      'Advanced Queuing',
    'DBMS_AQ_EXP_QUEUE_TABLES',      'Advanced Queuing',
    'DBMS_AQ_EXP_SIGNATURE_TABLES',  'Advanced Queuing',
    'DBMS_AQ_EXP_SUBSCRIBER_TABLES', 'Advanced Queuing',
    'DBMS_AQ_EXP_TIMEMGR_TABLES',    'Advanced Queuing',
    'DBMS_AUTO_TASK_EXPORT',         'Server Manageability',
    'DBMS_AW_EXP',                   'OLAP Analytic Workspace',
    'DBMS_CSX_ADMIN',                'XML Database',
    'DBMS_CUBE_EXP',                 'OLAP CUBE',
    'DBMS_DBFS_SFS_ADMIN',           'Database File System',
    'DBMS_FILE_GROUP_EXP',           'Streams',
    'DBMS_GOLDENGATE_EXP',           'GoldenGate',
    'DBMS_LOGMNR_LOGREP_DICT',       'Log Miner',
    'DBMS_LOGREP_EXP',               'Data Replication',
    'DBMS_RMGR_PACT_EXPORT',         'Resource Manager',
    'DBMS_RULE_EXP_RULES',           'Rules Catalog',
    'DBMS_SCHED_EXPORT_CALLOUTS',    'Oracle Scheduler',
    'DBMS_SERVER_ALERT_EXPORT',      'Server Managability',
    'DBMS_TRANSFORM_EXIMP',          'OLTP Transformation',
    'SDO_RDF_EXP_IMP',               'semantic technologies: exp/imp registered object',
                                     pa.package) cmnt,
  pa.package, 
  pa.schema,
  pa.class,
  pa.level#
from exppkgact$ pa
/

-- Create a dummy view with two rows: 0 and 1
create or replace force view ku$_prepost_view(prepost) as
 select 0 from dual
 union
 select 1 from dual
/

create or replace force view ku$_procobjact_view of ku$_procobjact_t
  with object identifier(package) as
  select distinct p.package, p.schema
  FROM  sys.ku$_exppkgact_view p
  WHERE (SYS_CONTEXT('USERENV','CURRENT_USERID') = 0 OR
         NLSSORT(SYS_CONTEXT('USERENV','CURRENT_USER'),'NLS_SORT=BINARY') =  NLSSORT(p.schema, 'NLS_SORT=BINARY') OR
                EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

create or replace force view KU$_PROCACT_SYS_PKG_VIEW as
  select
  p.package pname, p.schema pschema,
  p.level# plevel
  FROM  sys.ku$_exppkgact_view p
  where p.class =1
  order by p.level#
/

create or replace force view ku$_procact_sys_view of ku$_procact_t
  with object identifier(schema,package) as
  select '1','0',
  p.tag, p.cmnt, p.package, p.schema,
  p.level#, p.class, pr.prepost,
  case
   when p.class=1 then sys.dbms_metadata.get_action_sys
        ( p.tag, p.package, p.schema, 'SYSTEM_INFO_EXP', pr.prepost)
   else null
  end
  FROM  sys.ku$_exppkgact_view p , ku$_prepost_view pr
  where p.class =1
  order by p.level#
/

--
------------------------------------------------------------------------------
---                     PROCACT_SCHEMA
-- (schema procedural actions) - corresponds to the schema_info_exp function
-- of a package in exppkgact$ where the class is 2 (schema)
-------------------------------------------------------------------------------
--

create or replace force view ku$_procact_schema_pkg_view as
  select
  p.package pname, p.schema pschema, p.level# plevel
  FROM  sys.ku$_exppkgact_view p
  where p.class = 2
  order by p.level#
/

create or replace force view ku$_procact_schema_view of ku$_procact_schema_t
  with object identifier(user_name) as
    select '1','0',
    u.name,
    p.tag, p.cmnt, p.package, p.schema,
    p.level#, p.class, pr.prepost,
    value(act)
  FROM   sys.user$ u, sys.ku$_exppkgact_view p, ku$_prepost_view pr,
    table(sys.dbms_metadata.get_action_schema
        (p.tag, p.package, p.schema, 'SCHEMA_INFO_EXP', u.name, pr.prepost,
        (select 1 from dual where  (SYS_CONTEXT('USERENV','CURRENT_USERID') = 0
                OR EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))))) act
  where 
    p.class=2  and u.type# = 1 and
    p.package !='DBMS_RULE_EXP_RULES' and -- current is a problem, need to remove
                                        -- once the problem is fixed
    (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (u.user#, 0)  OR
              EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

--
-------------------------------------------------------------------------------
--                      PROCACT_INSTANCE
-- (instance procedural actions) - corresponds to the instance_info_exp function
-- of a package in exppkgact$ where the class is 3 (instance) and where there is
-- a corresponding row in expdepact$.  
-------------------------------------------------------------------------------
--
create or replace force view ku$_procact_instance_view
  of ku$_procact_instance_t
  with object identifier(obj_num) as
  select * 
  from table(sys.dbms_metadata.get_action_instance);
/
--
-------------------------------------------------------------------------------
--                      PRE_TABLE_ACTION
-------------------------------------------------------------------------------
--
create or replace force view ku$_expact_view (owner, name, prepost)
as select distinct owner,name,code from expact$
/

create or replace force view ku$_pre_table_view of ku$_prepost_table_t
  with object identifier(obj_num) as
  select '1','0',
          o.obj_num,
          value(o),
          sys.dbms_metadata.get_prepost_table_act
                (e.prepost, o.owner_name, o.name)
  from  sys.ku$_schemaobj_view o,
        sys.tab$ t,
        ku$_expact_view e
  where o.obj_num = t.obj#
    and e.prepost=1
    and e.owner=o.owner_name and e.name=o.name
/

--
-------------------------------------------------------------------------------
--                      POST_TABLE_ACTION
-------------------------------------------------------------------------------
--
create or replace force view ku$_post_table_view of ku$_prepost_table_t
  with object identifier(obj_num) as
  select '1','0',
          o.obj_num,
          value(o),
          sys.dbms_metadata.get_prepost_table_act
                (e.prepost, o.owner_name, o.name)
  from  sys.ku$_schemaobj_view o,
        sys.tab$ t,
        ku$_expact_view e
  where o.obj_num = t.obj#
    and e.prepost=2
    and e.owner=o.owner_name and e.name=o.name
/

-------------------------------------------------------------------------------
--                      (SYSTEM, SCHEMA, INSTANCE) CALLOUT
--                      TRANSPORTABLE CALLS TO DBMS_PLUGTS
------------------------------------------------------------------------------

-- system_callout view

create or replace force view ku$_syscallout_view of ku$_callout_t
  with object identifier(pkg_schema,package) as
  select '1','0',
  null, null, null,
  p.tag, p.package, p.schema,
  p.level#, p.class, pr.prepost,
  null, null, null, null, null, null, null, null
  FROM  sys.ku$_exppkgact_view p , ku$_prepost_view pr
  where p.class =5
  order by p.level#
/

-- schema_callout view

create or replace force view ku$_schema_callout_view of ku$_callout_t
  with object identifier(user_name) as
  select '1','0',
  u.name, null, null,
  p.tag, p.package, p.schema,
  p.level#, p.class, pr.prepost,
  null, null, null, null, null, null, null, null
  FROM   sys.user$ u, sys.ku$_exppkgact_view p, ku$_prepost_view pr
  where p.class=6 and u.type# = 1
         AND (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (u.user#, 0)  OR
              EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
  order by p.level#
/

-- instance_callout view

create or replace force view ku$_instance_callout_view of ku$_callout_t
  with object identifier(obj_num) as
  select '1','0',
     null, d.obj#,
     value(o),
     p.tag, p.package, p.schema, p.level#, p.class, pr.prepost,
     null, null, null, null, null, null, null, null
   FROM  sys.ku$_schemaobj_view o,
         sys.ku$_exppkgact_view p,
         sys.expdepact$ d,
         ku$_prepost_view pr
   WHERE d.obj# = o.obj_num AND d.package = p.package
         and d.schema = p.schema and p.class = 7
         and (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (o.owner_num, 0)
                 OR EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
   ORDER   by p.level#
/


--
-- Views for partition transportable.  They are used to get the
-- tablespace set to cover a specified set of table partitions or table
-- subpartitions.
--
-- partition transportable - tables
--
--    non-partitioned tables
create or replace force view ku$_tts_tabview (
        obj_num, partobj, ts_name, ts_num, subquery ) AS
    -- tablespace for table
    SELECT t.obj#, value(o), ts.name, ts.ts#, 'TV1'
    FROM  sys.ku$_schemaobj_view o, sys.tab$ t, sys.ts$ ts
    WHERE  (BITAND (t.property,32)!=32) and
           o.obj_num = t.obj# and
           t.ts# = ts.ts#
  UNION ALL
    -- tablespace for table lobs
    SELECT t.obj#, value(o), ts.name, ts.ts#, 'TV2'
    FROM  sys.ku$_schemaobj_view o, sys.tab$ t,
          sys.lobfrag$ lf, sys.ts$ ts
    WHERE  (BITAND (t.property,32)!=32) and
           o.obj_num = t.obj# and
           lf.tabfragobj# = t.obj# and
           lf.ts# = ts.ts#;

--    simple partitioned tables
create or replace force view ku$_tts_tabpartview (
        obj_num, partobj, ts_name, ts_num, subquery ) AS
    -- tablespace for partition
    SELECT tp.bo#, value(po), ts.name, ts.ts#, 'TPV1'
    FROM  sys.ku$_schemaobj_view po, sys.tabpart$ tp, sys.ts$ ts
    WHERE  po.obj_num = tp.obj# and
           tp.ts# = ts.ts#
  UNION ALL
    --    lobs for simple partitioned tables
    SELECT tp.bo#, value(po), ts.name, ts.ts#, 'TPV2'
    FROM  sys.ku$_schemaobj_view po, sys.tabpart$ tp,
          sys.lobfrag$ lf, sys.ts$ ts
    WHERE  po.obj_num = tp.obj# and
           lf.tabfragobj# = tp.obj# and
           lf.ts# = ts.ts#
  UNION ALL
    -- tablespace for table partition default
    --  PIOTs have a partobj$ row, but do not use that for default storage
    --  instead, they use def stoarge from indpartobj$
    SELECT po.obj#, value(o), ts.name, ts.ts#, 'TPV3'
    FROM  sys.ku$_schemaobj_view o, sys.partobj$ po, sys.ts$ ts, tab$ t
    WHERE  o.obj_num = po.obj# and
           o.obj_num = t.obj# and
           bitand(t.property,64)=0 and
           po.defts# = ts.ts#
  UNION ALL
    -- tablespace for table partition lob default
    SELECT o.obj_num, value(o), ts.name, ts.ts#, 'TPV4'
    FROM  sys.ku$_schemaobj_view o, sys.partlob$ pl, sys.ts$ ts
    WHERE  o.obj_num = pl.tabobj# and
           pl.defts# = ts.ts#
;
--    composite partitioned tables
create or replace force view ku$_tts_tabsubpartview (
        obj_num, partobj, ts_name, ts_num, subquery ) AS
    -- tablespace for subpartition
    SELECT tp.bo#, value(po), ts.name, ts.ts#, 'TSPV1'
    FROM  sys.ku$_schemaobj_view po, sys.tabcompart$ tp,
          sys.tabsubpart$ tsp, sys.ts$ ts
    WHERE  po.obj_num = tsp.obj# and
           tp.obj# = tsp.pobj# and
           tsp.ts# = ts.ts#
  UNION ALL
    -- tablespace for subpartition (select by partition)
    SELECT tcp.bo#, value(po), ts.name, ts.ts#, 'TSPV1a'
    FROM  sys.ku$_schemaobj_view po, sys.tabcompart$ tcp,
          sys.tabsubpart$ tsp, sys.ts$ ts
    WHERE  po.obj_num = tcp.obj# and
           tcp.obj# = tsp.pobj# and
           tsp.ts# = ts.ts#
  UNION ALL
    -- tablespace for subpartition lobs
    SELECT tcp.bo#, value(po), ts.name, ts.ts#, 'TSPV2'
    FROM  sys.ku$_schemaobj_view po, sys.tabcompart$ tcp,
          sys.tabsubpart$ tsp, sys.lobfrag$ lf, sys.ts$ ts
    WHERE  po.obj_num = tsp.obj# and
           tcp.obj# = tsp.pobj# and
           lf.tabfragobj# = tsp.obj# and
           lf.ts# = ts.ts#
  UNION ALL
    -- tablespace for subpartition lobs (select by partition)
    SELECT tcp.bo#, value(po), ts.name, ts.ts#, 'TSPV2a'
    FROM  sys.ku$_schemaobj_view po, sys.tabcompart$ tcp,
          sys.tabsubpart$ tsp, sys.lobfrag$ lf, sys.ts$ ts
    WHERE  po.obj_num = tcp.obj# and
           tcp.obj# = tsp.pobj# and
           lf.tabfragobj# = tsp.obj# and
           lf.ts# = ts.ts#
  UNION ALL
    -- tablespace for default subpartition
    SELECT tcp.bo#, value(o), ts.name, ts.ts#, 'TSP-D'
    FROM  sys.ku$_schemaobj_view o, sys.tabcompart$ tcp, sys.ts$ ts
    WHERE  o.obj_num = tcp.obj# and
           tcp.defts# = ts.ts#
  UNION ALL
    -- tablespace for default lob subpartition
    SELECT tcp.bo#, value(o), ts.name, ts.ts#, 'TSP-DL'
    FROM  sys.ku$_schemaobj_view o, sys.lobcomppart$ lcp, sys.tabcompart$ tcp, sys.ts$ ts
    WHERE  o.obj_num = tcp.obj# and
           tcp.obj# = lcp.tabpartobj# and
           lcp.defts# = ts.ts#
;
--
-- The partition and subpartition table views and lob views both return the
-- same columns.  Combine them here into one view.
--
-- view columns:
--  obj_num  - table object number (for selection on table obj_num)
--  partobj  - schemaobj_t for partition/subpartion (for selection on partition,
--              subpartitions may be selected by partition or subpartition)
--  ts_name  - tablespace name
--  ts_num   - tablespace number
--  subquery - tag to help debug this set of views!
-- 
create or replace force view ku$_tts_tab_tablespace_view (
        obj_num, partobj, ts_name, ts_num, subquery ) AS
    SELECT * FROM ku$_tts_tabview
  UNION ALL
    SELECT * FROM ku$_tts_tabpartview
  UNION ALL
    SELECT * FROM ku$_tts_tabsubpartview;

--
-- partition transportable - indexes
--
--    non-partitioned indexes
create or replace force view ku$_tts_idxview (
        obj_num, partobj, ts_name, ts_num, idx_prop ) AS
    SELECT i.bo#, NULL, ts.name, ts.ts#, i.property
    FROM  sys.ind$ i, sys.ts$ ts
    WHERE  (BITAND (i.property,2)!=2) and
           i.ts# = ts.ts#;

-- simple partitioned indexes (not partition selected)
create or replace force view ku$_tts_indpartview (
         obj_num, partobj, ts_name, ts_num, idx_prop ) AS
    SELECT i.bo#, NULL, ts.name, ts.ts#, i.property
    from  (     sys.indpart$ ip
     inner join sys.ind$     i  on i.obj#=ip.bo#
     inner join sys.ts$      ts on ip.ts#=ts.ts#);

-- simple partitioned indexes (partition selected)
create or replace force view ku$_ttsp_indpartview (
         obj_num, partobj, ts_name, ts_num, idx_prop, poflags ) AS
    SELECT i.bo#, value(tpo), ts.name, ts.ts#, i.property, po.flags
    from  (     sys.ku$_schemaobj_view tpo
     inner join sys.tabpart$    tp  on tpo.obj_num = tp.obj#
     inner join sys.ind$        i   on tp.bo#=i.bo#
     inner join sys.partobj$    po  on po.obj# = i.obj#
     inner join sys.indpart$    ip  on i.obj#=ip.bo# and  
                                       tp.part#=ip.part#
     inner join sys.ts$         ts  on ip.ts#=ts.ts#
  );

-- composite partitioned indexes (not partition selected)
create or replace force view ku$_tts_indsubpartview (
         obj_num, partobj, ts_name, ts_num, idx_prop ) AS
    SELECT i.bo#, NULL, ts.name, ts.ts#, i.property
    from  (     sys.indsubpart$ isp
     inner join sys.indcompart$ ip  on isp.pobj# = ip.obj#
     inner join sys.ind$        i   on i.obj#=ip.bo#
     inner join sys.ts$         ts  on isp.ts#=ts.ts#
  );

-- composite partitioned indexes (partition selected)
create or replace force view ku$_ttsp_indsubpartview (
         obj_num, partobj, ts_name, ts_num, idx_prop, poflags ) AS
    SELECT i.bo#, value(tspo), ts.name, ts.ts#, i.property, po.flags
    from  (
                sys.ku$_schemaobj_view tspo
     inner join sys.tabsubpart$ tsp on tspo.obj_num = tsp.obj#
     inner join sys.tabcompart$ tp  on tsp.pobj#=tp.obj#
     inner join sys.ind$         i   on tp.bo#=i.bo#
     inner join sys.partobj$     po  on po.obj# = i.obj#
     inner join sys.indcompart$ ip  on i.obj#=ip.bo# and  
                tp.part#=ip.part#
     inner join sys.indsubpart$ isp on isp.pobj# = ip.obj# and
                tsp.subpart#=isp.subpart#
     inner join sys.ts$         ts  on isp.ts#=ts.ts#
  );

--
-- The partition and subpartition index views return the same columns.  Combine
-- them here into one view.
-- (not partition selected)
create or replace force view ku$_tts_idx_tablespace_view (
         obj_num, partobj, ts_name, ts_num, idx_prop ) AS
    SELECT * FROM ku$_tts_idxview
  UNION ALL
    SELECT * FROM ku$_tts_indpartview
  UNION ALL
    SELECT * FROM ku$_tts_indsubpartview;

-- (partition selected)
create or replace force view ku$_ttsp_idx_tablespace_view (
         obj_num, partobj, ts_name, ts_num, idx_prop, poflags ) AS
    SELECT * FROM ku$_ttsp_indpartview
  UNION ALL
    SELECT * FROM ku$_ttsp_indsubpartview;

-- PLUGTS_BEGIN
-- view for begin export
create or replace force view ku$_plugts_begin_view of ku$_callout_t
  with object identifier(pkg_schema,package) as
  select '1','0',
  null, null, null, null,
  'DBMS_PLUGTS','SYS',
  0,
  100,
  0,
  null, null, null, null, null, null, null, null
  FROM dual
  where (SYS_CONTEXT('USERENV','CURRENT_USERID')=0
                 OR EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

-- PLUGTS_TSNAME_FULL - for full/table transportable
--  used for callout to dbms_plugts.beginExpTablespace
create or replace force view ku$_plugts_tsname_full_view of ku$_callout_t
  with object identifier(obj_num) as
  select '1','0',
  null, ts.ts#, null, null,
  'DBMS_PLUGTS', 'SYS', 0, 101, 0,
  ts.name, ts.ts#, null, null, null, null, null, null
  FROM sys.ts$ ts
  where (SYS_CONTEXT('USERENV','CURRENT_USERID')=0
                 OR EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

-- PLUGTS_TSNAME_TABLE
-- view for begin exp tablespace
create or replace force view ku$_plugts_tsname_table_view of ku$_callout_t
  with object identifier(user_name) as
  select '1','0',
  null, tts.obj_num, tts.partobj, null,
  'DBMS_PLUGTS','SYS',
  0,
  101,
  0,
  tts.ts_name,tts.ts_num,
  null, null, null, null, null, null
  FROM sys.ku$_tts_tab_tablespace_view tts
  where (SYS_CONTEXT('USERENV','CURRENT_USERID')=0
                 OR EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

-- PLUGTS_TSNAME_INDEX/PLUGTS_TSNAME_INDEXP
-- view for begin exp tablespace
--(not partition selected)
create or replace force view ku$_plugts_tsname_index_view of ku$_callout_t
  with object identifier(user_name) as
  select '1','0',
  null, tts.obj_num, null, null,
  'DBMS_PLUGTS','SYS',
  0,
  101,
  0,
  tts.ts_name,tts.ts_num,
  null, null, null, null, null, tts.idx_prop
  FROM sys.ku$_tts_idx_tablespace_view tts
  where (SYS_CONTEXT('USERENV','CURRENT_USERID')=0
                 OR EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

--(partition selected)
-- partition selection only works on local indexes, so this view checks the 
-- partobj$.flags for local index.
create or replace force view ku$_plugts_tsname_indexp_view of ku$_callout_t
  with object identifier(user_name) as
  select '1','0',
  null, tts.obj_num, tts.partobj, null,
  'DBMS_PLUGTS','SYS',
  0,
  101,
  0,
  tts.ts_name,tts.ts_num,
  null, null, null, null, null, tts.idx_prop
  FROM sys.ku$_ttsp_idx_tablespace_view tts
  where bitand(tts.poflags,1)=1 and
        (SYS_CONTEXT('USERENV','CURRENT_USERID')=0
                 OR EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

-- PLUGTS_TSNAME
-- view for begin exp tablespace
create or replace force view ku$_plugts_tsname_view of ku$_callout_t
  with object identifier(user_name) as
  select '1','0',
  null, null, null, null,
  'DBMS_PLUGTS','SYS',
  0,
  101,
  0,
  ts.name,ts.ts#,
  null, null, null, null, null, null
  FROM sys.ts$ ts
   where
   /* ts.online$:  1 = ONLINE, 2 = OFFLINE, 3 = INVALID, 4 = READ ONLY
    * a tablespace may exist in TS$ with online$=3 after being dropped.
    * we wish to treat such tablespaces as if they do not exist.
    * As in the dba_tablespaces view, these tablespaces do not exist!
    */
   ts.online$ != 3 and
   (SYS_CONTEXT('USERENV','CURRENT_USERID')=0
                 OR EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

-- PLUGTS_CHECKPL
-- view for checkPluggable
create or replace force view ku$_plugts_checkpl_view of ku$_callout_t
  with object identifier(pkg_schema,package) as
  select '1','0',
  null, null, null, null,
  'DBMS_PLUGTS','SYS',
  0,
  102,
  0,
  null,null,
  p1.prepost,p2.prepost,p3.prepost,p4.prepost,p5.prepost, null
  from ku$_prepost_view p1, ku$_prepost_view p2, ku$_prepost_view p3,
       ku$_prepost_view p4, ku$_prepost_view p5
  where (SYS_CONTEXT('USERENV','CURRENT_USERID')=0
                 OR EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

-- PLUGTS_BLK

create or replace force view ku$_plugts_blk_view of ku$_plugts_blk_t
 with object identifier(prepost) as
  select '1','0',
  pr.prepost,
  (select sys.dbms_metadata.get_plugts_blk(pr.prepost) from dual)
  from ku$_prepost_view pr
  where (SYS_CONTEXT('USERENV','CURRENT_USERID')=0
                 OR EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

create or replace force view ku$_end_plugts_blk_view of ku$_plugts_blk_t
 with object identifier(prepost) as
  select '1','0',
  1,
  (select sys.dbms_metadata.get_plugts_blk(1) from dual)
  from sys.dual
  where (SYS_CONTEXT('USERENV','CURRENT_USERID')=0
                 OR EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

-- View for fetching early tablespace numbers
-- PLUGTS_EARLY_TABLESPACE 
create or replace force view ku$_plugts_early_tblsp_view of ku$_callout_t
  with object identifier(user_name) as
  select '1','0',
  null, tts.obj_num, tts.partobj,
  null, null, null, null, null, null,
  tts.ts_name,tts.ts_num,
  null, null, null, null, null, null
  FROM sys.ku$_tts_tab_tablespace_view tts
/

-- View for fetching tablespace name and other characteristics
--  intended for selection by a set of tsnum's

create or replace force view ku$_plugts_tablespace_view of ku$_plugts_tablespace_t
 with object identifier(ts_num)  as
  select  '1','0', tsv.ts_num, tsv.bitmapped, tsv.flags, tsv.name
  from ku$_tablespace_view tsv
/

-- define views for DataPump Master Control Process

-- View for validating names for datapump include/exclude parameters.
-- Valid names are path names of the heterogeneous object and, for database 
--  export, option tag names.
-- This view also allows cross version compatibility.

create or replace force view DATAPUMP_PATHS_VERSION
    (HET_TYPE, OBJECT_PATH, SEQ_NUM, FULL_PATH, VERSION, TAG)
as
 select m.htype,m.name,m.seq#,
  (select m2.name from sys.metanametrans$ m2
   where m2.seq#=m.seq#
     and m2.htype=m.htype
     and bitand(m2.properties,1)=1),
  (select version from metascript$ s where s.seq#=m.seq# and s.htype=m.htype),
  0             -- these are not tags
  from sys.metanametrans$ m
union
 -- add in tag names for options, so they can be included/excluded.
 select unique 'DATABASE_EXPORT', tag, -1, tag, 1200000000, 1
  from impcalloutreg$
union
 select unique 'DATABASE_EXPORT', tag, -1, tag, 1000000000, 1
    from ku$_exppkgobj_view 
union
 select unique 'DATABASE_EXPORT', tag, -1, tag, 1000000000, 1
    from ku$_exppkgact_view
union
 select unique 'SCHEMA_EXPORT', tag, -1, tag, 1000000000, 1
    from ku$_exppkgobj_view
union
 select unique 'SCHEMA_EXPORT', tag, -1, tag, 1000000000, 1
    from ku$_exppkgact_view
union
 select unique 'TABLE_EXPORT', tag, -1, tag, 1000000000, 1
    from ku$_exppkgobj_view
union
 select unique 'TABLE_EXPORT', tag, -1, tag, 1000000000, 1
    from ku$_exppkgact_view
union
 select unique 'TRANSPORTABLE_EXPORT', tag, -1, tag, 1000000000, 1
    from ku$_exppkgobj_view
union
 select unique 'TRANSPORTABLE_EXPORT', tag, -1, tag, 1000000000, 1
    from ku$_exppkgact_view
/

-- View for validating object path names - compatible with release prior to
--  12.0 (11.2.0.3 has some V12 path names!)
create or replace force view DATAPUMP_PATHS
    (HET_TYPE, OBJECT_PATH, SEQ_NUM, FULL_PATH)
as
select m.het_type, m.object_path, m.seq_num, m.full_path
 from datapump_paths_version m
 where m.version < '1200000000'
/

-- View for mapping object paths in dump file set to import mode
create or replace force view DATAPUMP_PATHMAP
    (HET_TYPE, OBJECT_PATH)
as
select htype,name
 from sys.metapathmap$
/

-- View to get full path spec of TABLE_DATA
create or replace force view DATAPUMP_TABLE_DATA
   (HET_TYPE, OBJECT_PATH, SEQ_NUM)
as
select htype,name,seq#
 from sys.metanametrans$
 where properties!=0
 and name like '%/TABLE_DATA'
 and name not like '%INDEX%'
 and name not like '%VIEWS_AS_TABLES%'
 and name not like '%OPTIONS%'
/

-- define views for worker process

create or replace force view DATAPUMP_OBJECT_CONNECT
    (OBJECT_TYPE, CONNECT_TYPE, NEED_EXECUTE, PARALLEL_LOAD)
as
select unique a.type, decode(bitand(a.properties,8+16),
                8,   'SOFT',
                16,  'HARD', 'NONE'),
       decode(bitand(a.properties,64), 64, 1, 0),
       decode(bitand(a.properties,128), 128, 1, 0)
from sys.metaview$ a
where bitand(a.properties,2+4)=0
/

-- view to see if transform is supported for a particular object type.

create or replace force view DATAPUMP_DDL_TRANSFORM_PARAMS(OBJECT_TYPE,PARAM_NAME)
as
select  type, param
from    sys.metaxslparam$
where   model='ORACLE' and
        transform='DDL' and
        param!='DUMMY'and
        param not like 'PRS_%'
/

-- define DBA_EXPORT_OBJECTS catalog views
-- NAMED is Y if the last element in the path is a type with a NAME filter,
--  else N.
-- In the regular expression [A-Z_]+$, A-Z_ means uppercase alpha or '_',
-- [A-Z_]+ means one or more such characters, and the final $ anchors
-- the substring to the end of a.name; thus the whole regular expression
-- picks off the element following the last '/' if any, e.g.,
-- 'TABLE' from 'TABLE_EXPORT/TABLE'.

create or replace force view DBA_EXPORT_OBJECTS
    (HET_TYPE, OBJECT_PATH, COMMENTS, NAMED)
as
select unique a.htype,a.name,a.descrip,
 case
  when exists (select 1 from sys.metafilter$ f
                 where f.filter='NAME'
                 and f.type=regexp_substr(a.name,'[A-Z_]+$')) then 'Y'
  else 'N'
 end
 from sys.metanametrans$ a
 where a.descrip is not null order by a.htype,a.name
/


execute CDBView.create_cdbview(false,'SYS','DBA_EXPORT_OBJECTS','CDB_EXPORT_OBJECTS');
grant select on SYS.CDB_EXPORT_OBJECTS to select_catalog_role
/
create or replace public synonym CDB_EXPORT_OBJECTS for SYS.CDB_EXPORT_OBJECTS
/

create or replace force view TABLE_EXPORT_OBJECTS
    (OBJECT_PATH, COMMENTS, NAMED)
as
select OBJECT_PATH, COMMENTS, NAMED
    from dba_export_objects
    where het_type='TABLE_EXPORT'
/

create or replace force view SCHEMA_EXPORT_OBJECTS
    (OBJECT_PATH, COMMENTS, NAMED)
as
select OBJECT_PATH, COMMENTS, NAMED
    from dba_export_objects
    where het_type='SCHEMA_EXPORT'
union
select unique TAG, CMNT, NULL 
    from ku$_exppkgobj_view 
    union select unique TAG, CMNT, NULL 
    from ku$_exppkgact_view
/

create or replace force view DATABASE_EXPORT_OBJECTS
    (OBJECT_PATH, COMMENTS, NAMED)
as
select OBJECT_PATH, COMMENTS, NAMED
    from dba_export_objects
    where het_type='DATABASE_EXPORT'
union
select unique TAG, CMNT, NULL 
    from impcalloutreg$
    where cmnt is not null
union
select unique TAG, CMNT, NULL 
    from ku$_exppkgobj_view 
    union select unique TAG, CMNT, NULL
    from ku$_exppkgact_view
/

create or replace force view TABLESPACE_EXPORT_OBJECTS
    (OBJECT_PATH, COMMENTS, NAMED)
as
select OBJECT_PATH, COMMENTS, NAMED
    from dba_export_objects
    where het_type='TABLESPACE_EXPORT'
/

create or replace force view TRANSPORTABLE_EXPORT_OBJECTS
    (OBJECT_PATH, COMMENTS, NAMED)
as
select OBJECT_PATH, COMMENTS, NAMED
    from dba_export_objects
    where het_type='TRANSPORTABLE_EXPORT'
/

-- Bug 8354702: Define views with all path names for the export modes.
-- These are used by dbms_metadata.set_filter to process IN/EXCLUDE_PATH_EXPR

create or replace force view DBA_EXPORT_PATHS
    (HET_TYPE, OBJECT_PATH)
as
select a.htype,a.name
 from sys.metanametrans$ a
 order by a.htype,a.name
/


execute CDBView.create_cdbview(false,'SYS','DBA_EXPORT_PATHS','CDB_EXPORT_PATHS');
grant select on SYS.CDB_EXPORT_PATHS to select_catalog_role
/
create or replace public synonym CDB_EXPORT_PATHS for SYS.CDB_EXPORT_PATHS
/

create or replace force view TABLE_EXPORT_PATHS (OBJECT_PATH, TAG)
as
select OBJECT_PATH, 0
    from dba_export_paths
    where het_type='TABLE_EXPORT'
union
 select unique tag, 1
  from impcalloutreg$
union
 select unique tag, 1
    from ku$_exppkgobj_view 
union
  select unique tag, 1
    from ku$_exppkgact_view
/

create or replace force view SCHEMA_EXPORT_PATHS (OBJECT_PATH, TAG)
as
select OBJECT_PATH, 0
    from dba_export_paths
    where het_type='SCHEMA_EXPORT'
union
 select unique tag, 1
  from impcalloutreg$
union
 select unique tag, 1
    from ku$_exppkgobj_view 
union
  select unique tag, 1
    from ku$_exppkgact_view
/

-- for database export add in tag names for options, so they can be 
--  used for include/exclude.
create or replace force view DATABASE_EXPORT_PATHS (OBJECT_PATH, TAG)
as
select OBJECT_PATH, 0
    from dba_export_paths
    where het_type='DATABASE_EXPORT'
union
 select unique tag, 1
  from impcalloutreg$
union
 select unique tag, 1
    from ku$_exppkgobj_view 
union
  select unique tag, 1
    from ku$_exppkgact_view
/

create or replace force view TABLESPACE_EXPORT_PATHS (OBJECT_PATH, TAG)
as
select OBJECT_PATH, 0
    from dba_export_paths
    where het_type='TABLESPACE_EXPORT'
/

--
-- TABLE_DATA is not a path in transportable_export, but the Data Pump
-- worker specifies it for all export modes.  Rather than change the
-- worker code, we include TABLE_DATA in this view.
--
create or replace force view TRANSPORTABLE_EXPORT_PATHS (OBJECT_PATH, TAG)
as
select OBJECT_PATH, 0
    from dba_export_paths
    where het_type='TRANSPORTABLE_EXPORT'
UNION
select 'TABLE_DATA', 0 from dual  /* hack */
union
 select unique tag, 1
  from impcalloutreg$
union
 select unique tag, 1
    from ku$_exppkgobj_view 
union
  select unique tag, 1
    from ku$_exppkgact_view
/

-- This view is for OEM: allows the GUI to get a list of object types
-- for each REMAP_ param.

create or replace force view DATAPUMP_REMAP_OBJECTS (PARAM, OBJECT_TYPE)
as
select param,type
 from sys.metaxslparam$
 where model='ORACLE' and transform='MODIFY'
 and param like 'REMAP_%'
/

--
-- Create a view that will contain the object_schema, object_name, and
-- object_type for all oracle supplied objects that the Data Pump may have
-- exported.  Since the objects in the noexp table have never been exported,
-- then no use including them.
--
create or replace force view sys.ku$_oracle_supplied_obj_view (
               object_type, object_schema, object_name) AS
        SELECT  type_name, owner_name, name
        FROM    sys.ku$_schemaobj_view
        WHERE   BITAND(flags, 4194304) = 4194304 AND
                owner_name NOT IN (SELECT UNIQUE n.name
                                   FROM   sys.ku_noexp_tab n
                                    WHERE n.obj_type = 'SCHEMA')
/
GRANT SELECT ON sys.ku$_oracle_supplied_obj_view TO SELECT_CATALOG_ROLE
/

-- Fetch the errors associated with each object.
create or replace force view ku$_object_error_view(
                object_schema, object_name, error_num) 
AS
SELECT  u.name, o.name, e.error#
FROM   sys.error$ e, sys.obj$ o, sys.user$ u 
WHERE o.owner# = u.user# and e.obj# = o.obj# and
      (SYS_CONTEXT('USERENV','CURRENT_USERID')=0
       OR EXISTS ( SELECT * FROM sys.session_roles
                   WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

-- Views to document transforms, transform params and parse items.

create or replace force view dbms_metadata_all_transforms
  (object_type, transform, input_type, output_type,description)
as
 select unique v.type,x.transform,
   decode(x.transform,'DDL','XML',
                      'MODIFY','XML',
                      'SXML','XML',
                      'SXMLDDL','SXML',
                      'MODIFYSXML','SXML',
                      'ALTERXML','SXML difference document',
                      'ALTERDDL','ALTER_XML',
                      'EDITIONING_VIEW','SXML',
                      'STREAMSXML','SXML difference document',
                      'MODIFYSTREAMSXML','SXML difference document',
                      'PARSE','XML',
                      NULL),
   decode(x.transform,'DDL','DDL',
                      'MODIFY','XML',
                      'SXML','SXML',
                      'SXMLDDL','DDL',
                      'MODIFYSXML','SXML',
                      'ALTERXML','ALTER_XML',
                      'ALTERDDL','ALTER_DDL',
                      'EDITIONING_VIEW','SXML',
                      'STREAMSXML','DDL',
                      'MODIFYSTREAMSXML','SXML difference document',
                      'PARSE','Parse items',
                      NULL),
   decode(x.transform,'DDL','Convert XML to SQL to create the object',
                      'MODIFY',
                   'Modify XML document according to transform parameters',
                      'SXML','Convert XML to SXML',
                      'SXMLDDL','Convert SXML to DDL',
                      'MODIFYSXML','Modify SXML document',
                      'ALTERXML',
                   'Generate ALTER_XML from SXML difference document',
                      'ALTERDDL','Convert ALTER_XML to ALTER_DDL',
                      'EDITIONING_VIEW','Modify SXML document for editioning',
                      'STREAMSXML',
                   'Generate external table DDL from SXML difference document',
                      'MODIFYSTREAMSXML',
                   'Modify SXML difference document in preparation ' ||
                   'for STREAMSXML transform',
                      'PARSE','Transform to generate parse items - obsolete',
                      NULL)
 from sys.metaview$ v, sys.metaxsl$ x
 where x.xmltag=v.xmltag
   and v.model='ORACLE'
/
--
-- public view
--
create or replace force view dbms_metadata_transforms
  (object_type, transform, input_type, output_type,description)
as
 select * from dbms_metadata_all_transforms
 where transform not in 
    ('EDITIONING_VIEW','MODIFYSTREAMSXML','STREAMSXML','PARSE')
/
--
-- base view for transform parameters and parse items
--
create or replace force view dbms_metadata_tparams_base
  (object_type, transform, param, datatype, default_val, flags, description,
   model)
as
 select unique p.type,x.transform, p.param,
   decode(p.datatype,1,'BOOLEAN',
                     2,'TEXT',
                     3,'NUMBER','UNSPECIFIED'),
   case p.datatype 
     when 1 then 
        case p.default_val when '1' then 'TRUE' else 'FALSE' end
     else p.default_val
   end,
   d.flags,d.description, v.model
 from sys.metaview$ v, sys.metaxsl$ x, sys.metaxslparam$ p,
      sys.metaxslparamdesc$ d
 where x.xmltag=v.xmltag
   and (v.type=p.type or p.type='*')
   and x.transform=p.transform
   and d.model=v.model
   and d.param=p.param
/
--
-- all transform parameters (privileged view)
--
create or replace force view dbms_metadata_all_tparams
  (object_type, transform, param, datatype, default_val, internal, description)
as
  select t.object_type, t.transform, t.param, t.datatype, t.default_val,
  decode(bitand(t.flags,1),1,'Y','N'),
  t.description
  from dbms_metadata_tparams_base t
  where t.model = 'ORACLE'
    and t.transform != 'PARSE'
/
--
-- all parse items (privileged view)
--
create or replace force view dbms_metadata_all_parse_items
  (object_type, parse_item, internal, alter_xml, fetch_xml_clob,
   convert,  description)
as
  select t.object_type, substr(t.param,5),
  decode(bitand(t.flags,1),1,'Y','N'),
  decode(bitand(t.flags,2),2,'Y','N'),
  decode(bitand(t.flags,4),4,'Y','N'),
  decode(bitand(t.flags,8),8,'Y','N'),
         t.description
  from dbms_metadata_tparams_base t
  where t.model = 'ORACLE'
    and t.transform = 'PARSE'
/
--
-- public view for transform params
--
create or replace force view dbms_metadata_transform_params
  (object_type, transform, param, datatype, default_val, description)
as
  select t.object_type, t.transform, t.param, t.datatype,
         t.default_val, t.description
  from dbms_metadata_all_tparams t
  where t.transform not in ('EDITIONING_VIEW','MODIFYSTREAMSXML',
                            'STREAMSXML')
    and t.internal='N'        -- exclude internal params
/
--
-- public view for parse items
--
create or replace force view dbms_metadata_parse_items
  (object_type, parse_item, alter_xml, fetch_xml_clob,
   convert, description)
as
  select t.object_type, t.parse_item,
         t.alter_xml, t.fetch_xml_clob, t.convert,
         t.description
  from dbms_metadata_all_parse_items t
  where t.internal='N'        -- exclude internal params
/



-------------------------------------------------------------------------------
--          HCS ATTRIBUTE DIMENSION / HIERARCHY / ANALYTIC VIEW
------------------------------------------------------------------------------

-- hcs src view
create or replace force view ku$_hcs_src_view of ku$_hcs_src_t
  with object identifier (hcs_obj#, src_id) as 
  select s.hcs_obj#,
         s.src#,
         s.owner,
         s.owner_in_ddl,
         s.name,
         s.alias,
         s.order_num
  from sys.hcs_src$ s
/

-- hcs src col view
create or replace force view ku$_hcs_src_col_view of ku$_hcs_src_col_t
  with object identifier (obj#, src_col#) as
  select sc.obj#,
         sc.src_col#,
         sc.obj_type,
         sc.table_alias,
         sc.src_col_name
  from sys.hcs_src_col$ sc
/

-- classification view
create or replace force view ku$_hcs_clsfctn_view of ku$_hcs_clsfctn_t
  with object identifier (obj#, sub_obj#, obj_type, clsfction_name) as
  select c.obj#,
         c.sub_obj#,
         c.obj_type,
         c.clsfction_name,
         c.clsfction_lang,
         c.clsfction_value,
         c.order_num
  from sys.hcs_clsfctn$ c
/

-- hier dim join path view
create or replace force view ku$_attr_dim_join_path_view
  of ku$_attr_dim_join_path_t
  with object identifier (dim_obj#, join_path_id) as
WITH
  cond_vars AS
    (SELECT
       '"' || lhsc.table_alias || '"."' || lhsc.src_col_name || '" = "' ||
       rhsc.table_alias || '"."' || rhsc.src_col_name || '"' cond,
       jce.dim# dimnum, jce.joinpath# joinpathnum, jce.order_num
     FROM hcs_dim_join_path$ djp, hcs_join_cond_elem$ jce, 
          hcs_src_col$ lhsc, hcs_src_col$ rhsc
     WHERE  jce.dim# = djp.dim#
            and jce.joinpath# = djp.joinpath#
            and jce.dim# = lhsc.obj# and jce.dim# = rhsc.obj# 
            and jce.lhs_src_col# = lhsc.src_col# 
            and jce.rhs_src_col# = rhsc.src_col# 
            and lhsc.obj_type = 12 
            and rhsc.obj_type = 12 
    ),
  all_cond_vars(cond, dimnum, joinpathnum, order_num) AS
    (SELECT cond, dimnum, joinpathnum, order_num
     FROM cond_vars
     WHERE order_num = 0
     UNION ALL
       (SELECT a.cond || ' AND ' || c.cond cond, c.dimnum, 
        c.joinpathnum, c.order_num
        FROM cond_vars c, all_cond_vars a
        WHERE c.joinpathnum = a.joinpathnum
              and c.dimnum = a.dimnum
              and c.order_num = a.order_num + 1
       )
    ),
  last_cond_vars AS
    (SELECT cond, dimnum, joinpathnum
     FROM
       (SELECT cond, dimnum, joinpathnum, order_num, 
           MAX(order_num) OVER (PARTITION BY dimnum, joinpathnum) max_order_num
        FROM all_cond_vars
       )
     WHERE order_num = max_order_num
    )
select djp.dim#,
       djp.joinpath#,
       djp.join_path_name,
       lcv.cond,
       djp.order_num
from   obj$ o, hcs_dim_join_path$ djp, user$ u, last_cond_vars lcv
where  o.owner# = u.user#
       and djp.dim# = o.obj#
       and djp.joinpath# = lcv.joinpathnum
       and djp.dim# = lcv.dimnum
/

-- hier join path view
create or replace force view ku$_hier_join_path_view
  of ku$_hier_join_path_t
  with object identifier (hier_obj#) as
  select hjp.hier#,
       hjp.join_path_name,
       hjp.order_num
  from  hcs_hier_join_path$ hjp
/

-- attribute dimension attr view
create or replace force view ku$_attr_dim_attr_view of ku$_attr_dim_attr_t
  with object identifier (dim_obj#, attr_id) as
  select a.dim#,
         a.attr#,
         a.attr_name,
         sc.table_alias,
         sc.src_col_name,
         cast(multiset(select c.*
                       from ku$_hcs_clsfctn_view c
                       where c.obj# = a.dim#
                       and c.sub_obj# = a.attr#
                       and c.obj_type = 4
                       order by c.order_num
                      ) as ku$_hcs_clsfctn_list_t
         ),
         a.order_num
  from sys.hcs_dim_attr$ a, sys.obj$ o, sys.obj$ co, 
       sys.hcs_dim$ d, sys.hcs_src_col$ sc
  where a.dim# = o.obj#
      and d.obj# = a.dim#
      and a.src_col# = sc.src_col#
      and sc.obj_type = 4 -- HCSDDL_DICT_TYPE_DIMATR
      and a.dim# = sc.obj#
      and co.obj# = sc.obj#
      and co.owner# = o.owner#
/

-- attribute dim level key view
create or replace force view ku$_attr_dim_lvl_key_view 
  of ku$_attr_dim_lvl_key_t
  with object identifier (dim_obj#, lvl_id, key_id) as
  select k.dim#,
         k.lvl#,
         k.lvl_key#,
         cast(multiset(select av.*
                       from ku$_attr_dim_attr_view av, 
                            hcs_dim_lvl_key_attr$ ka
                       where av.dim_obj# = ka.dim#
                             and av.attr_id = ka.attr#
                             and ka.lvl# = k.lvl#
                             and ka.lvl_key# = k.lvl_key#
                             and ka.dim# = k.dim#
                       order by ka.order_num) as ku$_attr_dim_attr_list_t
             ),
        k.order_num
  from sys.hcs_dim_lvl_key$ k
/

-- hier dim level order by view
create or replace force view ku$_attr_dim_lvl_ordby_view
  of ku$_attr_dim_lvl_ordby_t
  with object identifier (dim_obj#, lvl_id) as
select lo.dim#,
       dl.lvl#,
       DECODE(lo.aggr_func, 1, 'MIN', 2, 'MAX') AGG_FUNC,
       da.attr_name ATTRIBUTE_NAME,
       lo.order_num,
       DECODE(lo.is_asc, 1, 'ASC',0, 'DESC') CRITERIA,
       DECODE(lo.null_first, 1, 'FIRST', 0, 'LAST') NULLS_POSITION
from hcs_dim_attr$ da, hcs_dim_lvl$ dl, hcs_lvl_ord$ lo, obj$ o
where lo.dim# = o.obj#
      and dl.lvl# = lo.dim_lvl#
      and da.attr# = lo.attr#
      and o.obj# = dl.dim#
      and o.obj# = da.dim#
/

-- attribute dim level view
create or replace force view ku$_attr_dim_lvl_view
  of ku$_attr_dim_lvl_t
  with object identifier (dim_obj#, lvl_id) as
  select l.dim#,
         l.lvl#,
         l.lvl_name,
         l.member_name,
         l.member_caption,
         l.member_desc,
         DECODE(l.skip_when_null, 0, 'N', 'Y') SKIP_WHEN_NULL,
         DECODE(l.lvl_type, 1, 'STANDARD', 2, 'YEARS', 3, 'HALF_YEARS', 
		4, 'QUARTERS', 5, 'MONTHS', 6, 'WEEKS', 7, 'DAYS',
		8, 'HOURS', 9, 'MINUTES', 10, 'SECONDS')  LEVEL_TYPE,
         cast(multiset(select c.*
                       from ku$_hcs_clsfctn_view c
                       where c.obj# = l.dim#
                       and c.sub_obj# = l.lvl#
                       and c.obj_type = 5
                       order by c.order_num
                      ) as ku$_hcs_clsfctn_list_t
         ),
         cast(multiset(select lkv.*
                       from ku$_attr_dim_lvl_key_view lkv
                       where lkv.dim_obj# = l.dim#
                             and lkv.lvl_id = l.lvl#
                       order by lkv.order_num) as ku$_attr_dim_lvl_key_list_t
             ),
         cast(multiset(select ob.*
                       from ku$_attr_dim_lvl_ordby_view ob
                       where ob.dim_obj# = l.dim#
                             and ob.lvl_id = l.lvl#
                       order by ob.order_num) as ku$_attr_dim_lvl_ordby_list_t
             ),
         cast(multiset(select av.*
                       from ku$_attr_dim_attr_view av, hcs_dim_dtm_attr$ da
                       where av.dim_obj# = da.dim#
                             and av.attr_id = da.attr#
                             and da.dim# = l.dim#
                             and da.lvl# = l.lvl#
                             and da.in_minimal = 1
                       order by da.order_num
                      ) as ku$_attr_dim_attr_list_t
             ),
         l.order_num
  from sys.hcs_dim_lvl$ l
/

-- hier level view
create or replace force view ku$_hier_lvl_view
  of ku$_hier_lvl_t
  with object identifier (hier_obj#, name) as
  select h.obj#,
         hl.lvl_name,
         hl.order_num
  from obj$ o, hcs_hierarchy$ h, hcs_hr_lvl$ hl
  where h.obj# = o.obj#
      and hl.hier# = h.obj#
/

-- hierarchy hier attr view
create or replace force view ku$_hier_hier_attr_view
  of ku$_hier_hier_attr_t
  with object identifier (hier_obj#, name) as
  select h.obj#,
         ha.attr_name,
         case when ha.is_sys_expr = 0 then ha.expr else null end,
         cast(multiset(select c.*
                       from ku$_hcs_clsfctn_view c
                       where c.obj# = ha.hier#
                       and c.sub_obj# = ha.attr#
                       and c.obj_type = 11
                       order by c.order_num
                      ) as ku$_hcs_clsfctn_list_t
         ),
         ha.order_num
  from obj$ o, hcs_hierarchy$ h, hcs_hier_attr$ ha
  where h.obj# = o.obj#
      and ha.hier# = o.obj#
      and (exists (select * from ku$_hcs_clsfctn_view c
                  where c.obj# = ha.hier#
                  and c.sub_obj# = ha.attr#
                  and c.obj_type = 11)
          or ha.is_sys_expr = 0)
/


-- analytic view keys view
create or replace force view ku$_analytic_view_keys_view
  of ku$_analytic_view_keys_t
  with object identifier (av_obj#, dim_obj#, key_col_name) as
select av.obj#,
       avd.av_dim#,
       sc.src_col_name,
       k.ref_attr_name,
       k.order_num
from  hcs_analytic_view$ av, hcs_av_key$ k, hcs_av_dim$ avd, hcs_src_col$ sc
where av.obj# = k.av#
      and avd.av# = av.obj#
      and k.av_dim# = avd.av_dim#
      -- join for srcCol of analytic view key
      and k.src_col# = sc.src_col#
      and sc.obj# = k.av#
      and sc.obj_type = 10 -- HCSDDL_DICT_TYPE_AVKEY
/

-- analytic view hiers view
create or replace force view ku$_analytic_view_hiers_view
  of ku$_analytic_view_hiers_t
  with object identifier (av_obj#, dim_obj#, hier_name) as
select avh.av#,
       avh.av_dim#,
       avh.hier_owner,
       avh.owner_in_ddl,
       avh.hier_name,
       avh.hier_alias,       
       DECODE(avh.is_default, 0, 'N', 'Y') IS_DEFAULT,
       avh.ORDER_NUM
from hcs_av_hier$ avh
/

-- analytic view dim view
create or replace force view ku$_analytic_view_dim_view
  of ku$_analytic_view_dim_t
  with object identifier (av_obj#, dim_obj#) as
select avd.av#,
       avd.av_dim#,
       avd.dim_owner,
       avd.owner_in_ddl,	
       avd.dim_name,
       avd.alias,
       avd.ref_distinct,
       cast(multiset(select k.*
                       from ku$_analytic_view_keys_view k
                       where k.av_obj# = avd.av#
                       and k.dim_obj# = avd.av_dim#
                       order by k.order_num
                      ) as ku$_analytic_view_keys_list_t
         ),
       cast(multiset(select avh.*
                       from ku$_analytic_view_hiers_view avh
                       where avh.av_obj# = avd.av#
                       and avh.dim_obj# = avd.av_dim#
                       order by avh.order_num
                      ) as ku$_analytic_view_hiers_list_t
         ),
         cast(multiset(select c.*
                       from ku$_hcs_clsfctn_view c
                       where c.obj# = avd.av#
                       and c.sub_obj# = avd.av_dim#
                       and c.obj_type = 6    --HCSDDL_DICT_TYPE_AVDIM
                       order by c.order_num
                      ) as ku$_hcs_clsfctn_list_t
         ),
       avd.order_num
from hcs_av_dim$ avd
/

-- analytic view meas view
create or replace force view ku$_analytic_view_meas_view
  of ku$_analytic_view_meas_t
  with object identifier (av_obj#, meas_id) as
select avm.av#,
       avm.meas#,
       avm.meas_type,
       avm.meas_name,
       sc.src_col_name,
       avm.expr,
       upper(avm.aggr),
       cast(multiset(select c.*
                       from ku$_hcs_clsfctn_view c
                       where c.obj# = avm.av#
                       and c.sub_obj# = avm.meas#
                       and c.obj_type = 7
                       order by c.order_num
                      ) as ku$_hcs_clsfctn_list_t
         ),
       avm.order_num
from hcs_av_meas$ avm, sys.hcs_src_col$ sc
where avm.av# = sc.obj#
  and avm.src_col# = sc.src_col#
  and sc.obj_type = 7
union all
select avm.av#,
       avm.meas#,
       avm.meas_type,
       avm.meas_name,
       cast(null as varchar2(1)),
       avm.expr,
       cast(null as varchar2(1)),
       cast(multiset(select c.*
                       from ku$_hcs_clsfctn_view c
                       where c.obj# = avm.av#
                       and c.sub_obj# = avm.meas#
                       and c.obj_type = 7 -- HCSDDL_DICT_TYPE_MEAS
                       order by c.order_num
                      ) as ku$_hcs_clsfctn_list_t
         ),
       avm.order_num
from hcs_av_meas$ avm
where avm.meas_type = 2
/

-- analytic view cache views

create or replace force view ku$_hcs_av_cache_dst_mslst
as select distinct av#,
                   measlst#
   from hcs_av_lvlgrp$
/

create or replace force view ku$_hcs_av_cache_meas_view
  of ku$_hcs_av_cache_meas_t
  with object identifier (av_obj#, measlst#) as
  select av#,
         measlst#,
         meas_name,
         order_num
  from hcs_measlst_measures$
/

create or replace force view ku$_hcs_av_cache_lvl_view
  of ku$_hcs_av_cache_lvl_t
  with object identifier (av_obj#, lvlgrp#) as
  select av#,
         lvlgrp#,
         dim_alias,
         hier_alias,
         level_name,
         order_num
  from hcs_lvlgrp_lvls$
/

create or replace force view ku$_hcs_av_cache_lvgp_view
  of ku$_hcs_av_cache_lvgp_t
  with object identifier (av_obj#, lvlgrp#) as
  select lg.av#,
         lg.measlst#,
         lg.lvlgrp#,
         lg.cache_type,
         cast(multiset(select lgl.*
                from ku$_hcs_av_cache_lvl_view lgl
                where lgl.av_obj# = lg.av#
                and lgl.lvlgrp# = lg.lvlgrp#
                order by lgl.order_num
             ) as ku$_hcs_av_cache_lvl_list_t
         ),
         order_num
  from hcs_av_lvlgrp$ lg
/

create or replace force view ku$_hcs_av_cache_mlst_view
  of ku$_hcs_av_cache_mlst_t
  with object identifier (av_obj#, measlst#) as
  select dml.av#,
         dml.measlst#,
         cast(multiset(select cm.*
                 from ku$_hcs_av_cache_meas_view cm
                 where cm.av_obj# = dml.av#
                 and cm.measlst# = dml.measlst#
                 order by cm.order_num
             ) as ku$_hcs_av_cache_meas_list_t
         ),
         cast(multiset(select lg.*
                 from ku$_hcs_av_cache_lvgp_view lg
                 where lg.av_obj# = dml.av#
                 and lg.measlst# = dml.measlst#
                 order by lg.order_num
             ) as ku$_hcs_av_cache_lvgp_list_t
         )
  from ku$_hcs_av_cache_dst_mslst dml
/

-- end analytic view cache views


-- attribute dimension view
create or replace force view ku$_attribute_dimension_view 
  of ku$_attribute_dimension_t
  with object identifier (obj_num) as 
  select d.obj#,
         value(o),
         DECODE(d.dim_type, 1, 'STANDARD', 2, 'TIME') DIMENSION_TYPE,
         d.all_member_name ALL_MEMBER_NAME,
         d.all_member_caption ALL_MEMBER_CAPTION,
         d.all_member_desc ALL_MEMBER_DESC,
         cast(multiset(select sv.*
                       from ku$_hcs_src_view sv
                       where sv.hcs_obj# = d.obj#
                       order by sv.order_num
                      ) as ku$_hcs_src_list_t
         ),
         cast(multiset(select av.*
                       from ku$_attr_dim_attr_view av
                       where av.dim_obj# = d.obj#
                       order by av.order_num
                      ) as ku$_attr_dim_attr_list_t
         ),
         cast(multiset(select lv.*
                       from ku$_attr_dim_lvl_view lv
                       where lv.dim_obj# = d.obj#
                       order by lv.order_num
                      ) as ku$_attr_dim_lvl_list_t
         ),
         cast(multiset(select c.*
                       from ku$_hcs_clsfctn_view c
                       where c.obj# = d.obj#
                       and c.obj_type = 1
                       order by c.order_num
                      ) as ku$_hcs_clsfctn_list_t
         ),
         cast(multiset(select jp.*
                       from ku$_attr_dim_join_path_view jp
                       where jp.dim_obj# = d.obj#
                       order by jp.order_num
                       ) as ku$_attr_dim_join_path_list_t
         )
  from sys.hcs_dim$ d, sys.ku$_edition_schemaobj_view o
  where d.obj# = o.obj_num
         AND (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (o.owner_num, 0) OR
              EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

-- hier view
create or replace force view ku$_hierarchy_view 
  of ku$_hierarchy_t
  with object identifier (obj_num) as 
  select h.obj#,
         value(o),
         h.dim_owner,
         h.owner_in_ddl,
         h.dim_name,
         cast(multiset(select lv.*
                       from ku$_hier_lvl_view lv
                       where lv.hier_obj# = h.obj#
                       order by lv.order_num desc
                      ) as ku$_hier_lvl_list_t
         ),
         cast(multiset(select c.*
                       from ku$_hcs_clsfctn_view c
                       where c.obj# = h.obj#
                       and c.obj_type = 2
                       order by c.order_num
                      ) as ku$_hcs_clsfctn_list_t
         ),
         cast(multiset(select jp.*
                       from ku$_hier_join_path_view jp
                       where jp.hier_obj# = h.obj#
                       order by jp.order_num
                       ) as ku$_hier_join_path_list_t
         ),
         cast(multiset(select ha.*
                       from ku$_hier_hier_attr_view ha
                       where ha.hier_obj# = h.obj#
                       order by ha.order_num
                       ) as ku$_hier_hier_attr_list_t
         )
  from sys.hcs_hierarchy$ h, sys.ku$_edition_schemaobj_view o
  where h.obj# = o.obj_num
         AND (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (o.owner_num, 0) OR
              EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
/

-- analytic_view view
create or replace force view ku$_analytic_view
  of ku$_analytic_view_t
  with object identifier (obj_num) as 
  select av.obj#,
         value(o),
         avm.meas_name,
         upper(av.default_aggr),
         cast(multiset(select sv.*
                       from ku$_hcs_src_view sv
                       where sv.hcs_obj# = av.obj#
                       order by sv.order_num
                      ) as ku$_hcs_src_list_t
         ),
         cast(multiset(select avd.*
                       from ku$_analytic_view_dim_view avd
                       where avd.av_obj# = av.obj#
                       order by avd.order_num
                      ) as ku$_analytic_view_dim_list_t
         ),
         cast(multiset(select avm.*
                       from ku$_analytic_view_meas_view avm
                       where avm.av_obj# = av.obj#
                       order by avm.order_num
                      ) as ku$_analytic_view_meas_list_t
         ),
         cast(multiset(select c.*
                       from ku$_hcs_clsfctn_view c
                       where c.obj# = av.obj#
                       and c.obj_type = 3
                       order by c.order_num
                      ) as ku$_hcs_clsfctn_list_t
         ),
         cast(multiset(select cam.*
                       from ku$_hcs_av_cache_mlst_view cam
                       where cam.av_obj# = av.obj#
                      ) as ku$_hcs_av_cache_mlst_list_t
         ),
         av.dyn_all_cache
  from sys.hcs_analytic_view$ av, sys.ku$_edition_schemaobj_view o,
       sys.hcs_av_meas$ avm
  where av.obj# = o.obj_num
         AND (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (o.owner_num, 0) OR
              EXISTS ( SELECT * FROM sys.session_roles
                       WHERE NLSSORT(role, 'NLS_SORT=BINARY') = NLSSORT('SELECT_CATALOG_ROLE', 'NLS_SORT=BINARY')))
         AND av.obj# = avm.av#
         AND av.default_measure# = avm.meas#
/

@?/rdbms/admin/sqlsessend.sql
