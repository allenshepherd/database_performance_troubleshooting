Rem Copyright (c) 1987, 2015, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem NAME
Rem    CATMETA.SQL - Object views of the Oracle dictionary for Metadata API.
Rem  FUNCTION
Rem     Creates an object model of the Oracle dictionary for use by the
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
Rem SQL_SOURCE_FILE: rdbms/admin/catmeta.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catmeta.sql
Rem SQL_PHASE: CATMETA
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/dpload.sql
Rem END SQL_FILE_METADATA
Rem
Rem  MODIFIED
Rem     mjangir    04/03/15 - bug 20826924: Update SQL metadata
Rem     lbarton    02/14/12 - make usable
Rem     jerrede    09/01/11 - Parallel Upgrade Project #23496
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
Rem     lbarton    02/28/11 - get_vat_xml
Rem     gclaborn   03/01/11 - Move user mapping view to catdpb.sql
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

Rem     rapayne    08/04/10 - Triton Security support.
Rem     tbhukya    01/24/10 - Bug 10177856 : Add fntyp cond in ku$_file_view
Rem     tbhukya    01/04/10 - Bug 10416375 : set properties to use CBO
Rem                           for table views.
Rem     lbarton    08/16/10 - project 30934: export views as tables
Rem     lbarton    07/21/10 - bug 9791589: scaling problems with object grants
Rem     tbhukya    11/22/10 - Bug 10265349: Use clob for sql_text
Rem                           in ku$_outline_t
Rem     mjungerm   11/19/10 - make OJVMSYS no export
Rem     mjangir    10/26/10 - bug 10200919: set the flag to use the CBO
Rem     ebatbout   10/19/10 - 10112900: Correct test for condition 5 in
Rem                           ku$_unload_method_view
Rem     esoyleme   10/21/10 - CUBE inhier support
Rem     tbhukya    10/04/10 - Bug 10102984 :Increase highwater size in sequence
Rem     sdavidso   09/29/10 - bug10107749: long 'replace null with' value
Rem     sdavidso   09/09/10 - bug10101332: partition numbers in dictionary
Rem                           tables are not reliable across tables. Use 
Rem                           computed values (e.g., tabpartv$ not tabpart$)
Rem     sdavidso   09/02/10 - lrg4843109: fatal error with xdb not installed
Rem     ebatbout   08/19/10 - Bug 9335975: Fix col_sortkey, for view, 
Rem                           ku$_strmcol_view, to recognize schema based 
Rem                           XMLType columns (also known as object relational)
Rem     dgagne     08/04/10 - add tstz parse item for table
Rem     mjangir    07/22/10 - bug 9110642: Add creation_time parse item fori
Rem                           table_data 
Rem     lbarton    07/14/10 - fix properties for MViewLog filters
Rem     tbhukya    07/12/10 - BUG 9841333: Add new col defschema_exst in ku$_trigger_t
Rem                           and new param REMAP_TRG_SCHEMA added
Rem     tbhukya    06/28/10 - Bug 9837313: Consider col# also while fetching
Rem                           bulk object_grant by object to avoid duplicates.
Rem     lbarton    05/28/10 - bug 9571727: remap dpapiversion, force_lob_be,
Rem                           force_no_encrypt
Rem     lbarton    06/18/10 - bug 9828495: correct freelists/freelist groups
Rem                           for deferred segs
Rem     tbhukya    06/15/10 - bug 9786285: Exclude system generated, hidden and
Rem                           stored in lob cols from ku$_objgrant_view which is 
Rem                           generated with Xmltype columns.
Rem     mjangir    06/04/10 - bug 9535916: Remap_schema for dbms job 
Rem     ebatbout   05/24/10 - bug 9491530: Add Ku$_10_2_fhtable_view and new
Rem                           reason (condition 9) to ku$_unload_method_view
Rem     sdavidso   05/17/10 - lrg 3603060: problem with procobj ordering
Rem     lbarton    04/21/10 - bug 9491539
Rem     sdavidso   04/16/10 - bug9480755: export dependant xmlschemas
Rem     sdavidso   01/27/10  - Bug 8847153: reduce resources for xmlschema
Rem                            export
Rem     rapayne    04/08/10 - bug 9368254: fix ora-1427 in ku$_iotpart_data_view
Rem     rapayne    03/14/09 - bug 9439234: add parse_alter parameter and add hook
Rem                           for parsing $default for diff/alter paths.
Rem     dgagne     04/05/10 - fetch stats on if collected
Rem     ebatbout   03/28/10 - Add transform parameter, streamd_version, that 
Rem                           will contain stream metadata version.
Rem     tbhukya    02/19/10 - Bug 9263473: add schema_obj in 
Rem                                        ku$_procact_instance_t
Rem     tbhukya    02/15/10 - Bug 9277709: Exclude nested table column 
Rem                                        from KU$_OBJGRANT_VIEW
Rem     rapayne    01/27/10 - bug 8692663: modify htspart_data_view and 
Rem                           htpart_data_view to fetch obj_num rather than
Rem                           dataobj_num.
Rem     ebatbout   01/20/10 - bug 8465341: Define parse item, sqlvalid. Add 
Rem                           base_col_name to the stream metadata (used
Rem                           for nested tables) and bump stream minor version
Rem                           from 1 to 2 to account for this new field.
Rem     mjangir    01/08/10  - bug 6644244: IOT w/mapping table in TTS mode 
Rem     rapayne    01/05/09 - bug 8367909: add a view for exppkgact$ checking.
Rem     rapayne    01/05/09 - bug 9214753: fix ku$_iotpart_data_view - data layer obj#
Rem                           returning more than one row.
Rem     tbhukya    01/07/10  - Bug 9160088: Generate cachehint value based on version
Rem     dgagne     12/22/09  - fix version 10 tab stat views
Rem     sdavidso   12/18/09  - bug 8395233: avoid export of invalid nested
Rem                            table
Rem     tbhukya    12/04/09  - Bug 8307012: Add support for domain index whose
Rem                                         support interface is 1
Rem     ebatbout   12/02/09 - Bug 9080222: Ensure that inclcol_name is not
Rem                           a system generated name in ku$_iotable_view
Rem     rapayne    12/01/09 - bug 8402872: modify ku$_context_view to check for 'owner'.
Rem     lbarton    11/02/09 - deferred segment creation for partitions
Rem     tbhukya    11/24/09 - Bug 8822995: Add OLDEXPORT parameter
Rem     tbhukya    11/18/09 - Bug 8983880: Use clob for default_val 
Rem                                        in ku$_simple_col_t
Rem     sdavidso   11/03/09 - lrg 4065313: fix home content dif
Rem     sdavidso   10/30/09 - bug 8477142 constraints and ref partitioning
Rem     rapayne    10/01/09 - cm_synch: change transform parameter 
Rem                               MAKE_DIFF_READY to CM_MODE
Rem     prakumar   09/16/09 - Bug 8857211: Handle NULL flag3 in ku$_m_view_view
Rem     msaunder   09/15/09 - Change object_grant version to 11.2 from 11.1
Rem     lbarton    09/11/09 - bug 8856467: do not fetch grants on nested tables
Rem     ebatbout   09/10/09 - Bug 8523879: exclude MGDSYS user
Rem     tbhukya    09/07/09 - Bug 8794227: Get the stats info even though stats 
Rem                                        deleted but locked.
Rem     mjangir    08/24/09 - Bug 8467825: remove v$datafile, bad performance 
Rem     tbhukya    08/10/09 - Do not use  RBO for CONSTRAINT_T
Rem     dgagne     08/07/09 - add convert parse items
Rem     ebatbout   07/24/09 - Bug 8722752: Add parse items for dropped columns
Rem     tbhukya    07/10/09 - Bug 8666013: get the password_date in varchar2 
Rem                           to get the full date format.
Rem     tbhukya    07/08/09 - Bug 8617779: Increase the size of role 
Rem                                        in ku$_proxy_role_item_t
Rem     spetride   06/15/09 - 8561406: add SCHEMAOID parse item for XMLSCHEMA 
Rem     dgagne     06/04/09 - add property to index col type and view
Rem     sdavidso   06/03/09 - bug 8352607: support minimize records_per_block
Rem     rapayne    05/30/09 - bug 8539628: add SCHEMA_LEVEL parse item for
Rem                           xmlschema objects.
Rem     lbarton    03/26/09 - bug 8354702: add EXPORT_PATHS views
Rem     rapayne    05/10/09 - bug 8355496: add deferred_stg ind_part_t
Rem     sdavidso   04/21/09 - bug 7597578: support NT partition properties
Rem     lbarton    11/25/08 - archive level compression
Rem     lbarton    03/19/09 - lrg 3762023: unusable index subpartitions
Rem     lbarton    03/23/09 - bug 8347514: parse read-only view query
Rem     ebatbout   04/09/09 - bug 8367506: fix to ku$_trigger_view
Rem     ebatbout   04/09/09 - bug 8397778: prefix session_roles with SYS
Rem     sdavidso   02/27/09 - bug 7567327: ORA-904 importing xmltype
Rem     mjangir    04/06/09 - bug 8372834: add tablespace transform for MV
Rem     mjangir    03/25/09 - bug 7658844:  hard connect when creating refresh
Rem                           group 
Rem     ebatbout   03/25/09 - bug 7229037: add OVERRIDE_* parameters for the
Rem                           Modify transform
Rem     sdavidso   03/03/09 - bug 8328108: add xdb_ntable objnum view
Rem     mjangir    03/17/09 - bug 7722575: predicate issue
Rem     sdavidso   03/03/09 - bug 8328108: add xdb_ntable objnum view
Rem     lbarton    11/13/08 - TSTZ support
Rem     rapayne    03/05/09 - bug 8295513: 'editionify' type views.
Rem     lbarton    10/08/08 - bug 5661474: network exp/imp of (sub)partitions
Rem     lbarton    02/18/09 - bug 8252494: ku$_deferred_stg_t/_view
Rem     rapayne    02/26/09 - lrg 3784210: add REUSE transform parameter to
Rem                           tablespace sxml-ddl transforms list.
Rem     sdavidso   01/22/09 - bug 5672035: fix quote handling for
Rem                           remap_column_name
Rem     lbarton    02/09/09 - bug 5323844: fix synonym OWNER_NAME filter
Rem     slynn      02/06/09 - Fix bug-7023008: SecureFile Retention incorrect
Rem     lbarton    12/30/08 - Bug 7354560: add trailing_nl to ku_source_t
Rem     lbarton    12/19/08 - bug 6269507: soft connect when creating packages
Rem     sdavidso   12/16/08 - bug 7620558: problems w/xmltype,ADT,nested tables
Rem     rapayne    01/06/08 - bug 7605276: in 11.2 obj$.spare3 maps the original
Rem                           owner# while owner# will potentially map the internal
Rem                           adjunct schema when editions have been enabled. 
Rem                           This txn changes schemaobj_view to additionally 
Rem                           collect this new mapping.
Rem     sdavidso   12/09/08 - lrg 3718808: extend OCT fix to equipartitioned
Rem                           tables
Rem     rapayne    11/10/08 - bug7393931: add parameters for modifysxml:
Rem                           STORAGE, SEGMENT_ATTRIBUTES, TABLESPACE, 
Rem                           CONSTRAINTS, REF_CONSTRAINTS
Rem     lbarton    11/03/08 - always export equipart NT table data
Rem     sdavidso   10/21/08 - bug 7320642: don`t export xmltype nested tables
Rem     sdavidso   09/26/08 - bug7362589: excessive time for table_data
Rem     rlong      09/25/08 - 
Rem     sramakri   09/12/08 - reflect usage of mflags2 for aclmvs
Rem     chliang    09/04/08 - 
Rem     ssonawan   07/11/08 - bug 5921164: add column powner to fga$
Rem     htseng     08/28/08 - 
Rem     mjangir    08/08/08 - bug 6460304: set properties=+1024(do not use RBO)
Rem                           in metaview$ for INDEX
Rem     ebatbout   07/09/08 - Bug 6075698: Add Streamsxml transform; add new
Rem                           hidden_columns parameter for sxml transforms;
Rem                           add new stylesheet, kuetable, that converts a
Rem                           diff doc. to SQL statements using external table
Rem     akoeller   07/31/08 - Fix property flag for ACLMV
Rem     pknaggs    07/07/08 - bug 6938028: Factor and Rule support for DVPS.
Rem     wesmith    06/30/08 - modify ku$_m_view_view, ku$_m_view_log_view to
Rem                           filter out new types of MVs, MV logs
Rem     dsemler    06/09/08 - fix merge error on view
Rem     pknaggs    07/07/08 - bug 6938028: Factor and Rule support for DVPS.
Rem     cchiappa   06/23/08 - Add ordering to COT views
Rem     lbarton    06/18/08 - bug 6624138: exclude history tables
Rem     dgagne     06/16/08 - make new object grant version 2.0, not 2.1
Rem     sdavidso   06/06/08 - bug 6910214: mv log in transportable
Rem     pknaggs    06/03/08 - bug 6938028: Database Vault Protected Schema.
Rem     lbarton    04/22/08 - bug 6730161: get version-specific hashcode
Rem     lbarton    06/02/08 - bug 6767780: view trigger on nested table col
Rem     sdavidso   05/23/08 - fix edition support
Rem     sdavidso   05/20/08 - bug 6861416: transportable fails
Rem                           w/exp_full_database
Rem     lbarton    04/22/08 - bug 6730161: get version-specific hashcode
Rem     dgagne     05/19/08 - add TSMSYS to the noexp table
Rem     rapayne    04/16/08 - bug 7129765 - add kuatype.xsl to handle alter 
Rem                           transforms for TYPE objects.
Rem     sdavidso   04/08/08 - bug 6953611: alter_package_spec also editionable
Rem     lbarton    02/05/08 - Bug 6029076: query parsing. PARSE_EXPRESSIONS
Rem                           defaults to TRUE. Parse_* in prvtmeta.
Rem     wesmith    03/20/08 - Project 25482: add snap$.flag3 to ku$_m_view_t,
Rem                           ku$_m_view_view
Rem     lbarton    02/05/08 - Bug 6029076: query parsing. PARSE_EXPRESSIONS
Rem                           defaults to TRUE. Parse_* in prvtmeta.
Rem     lbarton    04/01/08 - bug 6857781: editioning view for mv logs
Rem     rapayne    03/25/08 - bug 3337571: expand type definition for
Rem                           REGEN_DEFN support.
Rem     wesmith    03/20/08 - Project 25482: add snap$.flag3 to ku$_m_view_t,
Rem                           ku$_m_view_view
Rem     dsemler    03/06/08 - exclude the APPQOSSYS user
Rem     lbarton    02/05/08 - Bug 6029076: query parsing. PARSE_EXPRESSIONS
Rem                           defaults to TRUE. Parse_* in prvtmeta.
Rem     lbarton    01/24/08 - Bug 6724820: table compression
Rem     wesmith    12/21/07 - MV log purge optimization
Rem     lbarton    02/11/08 - Bug 6804815: pparse item for JOB schema
Rem     akoeller   01/23/08 - Support ACLMV export/import (DBMS_XDS)
Rem     lbarton    01/31/08 - bug 5961283: get uncorrupted hashcode
Rem     zqiu       01/28/08 - bug 6750821, order ku$_m_view_view by
Rem                           snap$.parent_vname
Rem     smashimo   12/21/07 - Bug 6635956: replace null with '-' in audit$ col
Rem     mjangir    12/19/07 - bug 5211477: fix SEQUENCE start value
Rem     smashimo   11/27/07 - Bug 6603832: run catmetx.sql if XDB is installed
Rem     lbarton    11/26/07 - bug 6454237: parse trigger definition
Rem     sdavidso   11/06/07 - bug 5451654 - table ordering for equipartition NT
Rem     tbhukya    11/19/07 - bug 6484209: Disable storage for MV when storage 
Rem                           param set to false with set_transform_param
Rem     sdavidso   11/14/07 - Bug 6355515: exclude OLAP cube views
Rem     dgagne     11/13/07 - add network_name transform
Rem     lbarton    11/02/07 - bug 6060058: flashback archived tables
Rem     lbarton    10/31/07 - bug 6051635: domain index on xmltype col
Rem     htseng     10/25/07 - lrg 3194978: need order by clause for cluster
Rem                           column_list
Rem     smashimo   10/16/07 - Bug 6017760: Modify ku$_file_view for bitmaped
Rem                           tablespace
Rem     smashimo   10/12/07 - Bug 6063940: exculde tablespace group from 
Rem                           ku$_tablespace_view and ku$_tsquota_view
Rem     smashimo   10/03/07 - Bug 5891213: strip nulls from ind$.spare4 
Rem     dgagne     09/26/07 - fix stats of system generated indexes and columns
Rem     rapayne    08/06/07 - bug 6276904: fix freelist collection for
Rem                           'next generation' lobs
Rem     rapayne    07/26/07 - allow owner queries on rls_policy_view.
Rem     mjangir    08/12/07 - bug 5523375 - dont filter the pk constraint
Rem     mjangir    08/07/07 - bug 6156708 - add filter for index order by
Rem     htseng     07/16/07 - bug 6051635 -index on XML type column
Rem     sdavidso   07/10/07 - bug 5950173 - xmlschema dependencies
Rem     htseng     06/20/07 - equipartition nested table support
Rem     dgagne     06/29/07 - 
Rem     jkaloger   06/12/07 - Use version 11.0
Rem     achoi      04/26/07 - use defining_edition
Rem     dgagne     06/13/07 - Don`t force "analyze table" if table has 
Rem                           functional indexes
Rem     dgagne     05/17/07 - bulk object_grant by object
Rem     htseng     05/04/07 - Bug 5567364: DEFAULT profile
Rem     htseng     04/26/07 - bug 5690152: add 2 new fields in source_list_t
Rem     lbarton    02/02/07 - IMPORT_CONVENTIONAL
Rem     smashimo   04/19/07 - Bug 5095025: set properties=+1024(don't use RBO)
Rem                           in metaview$ for PROCDEPOBJ
Rem     sdavidso   04/23/07 - Note xmltype tables with hierarchy enabled
Rem     smashimo   04/06/07 - Bug 5464834: remove 'don't use rbo' bit from
Rem                           metaview$.properties
Rem     lbarton    04/05/07 - strmtable column sorting
Rem     sdavidso   03/22/07 - 5903231 - maintain binary storage for xmlschemas
Rem     cchiappa   03/22/07 - Cube DIMENSION USING support
Rem     lbarton    01/09/07 - kusparsd.xsl
Rem     sdavidso   02/15/07 - add LRG xsl parameter for DDL conversions
Rem     htseng     02/09/07 - bug 5727911: encrypted columns bit
Rem     sdavidso   01/31/07 - add XMLschemas for transportable
Rem     lbarton    01/18/07 - bug 5584945: restrict password access to
Rem                           EXP_FULL_DATABASE
Rem     htseng     01/16/07 - add RLS support for differ
Rem     htseng     01/08/07 - AQ_QUEUE, AQ_QUEUE_TABLE support for differ.
Rem     lbarton    11/03/06 - USING_INDEX transform param
Rem     lbarton    09/22/06 - ALTERDDL transform
Rem     rapayne    07/14/06 - Further differ/alter work.
Rem     achoi      12/21/06 - new definition for _CURRENT_EDITION_OBJ
Rem     smashimo   01/11/07 - bug 5520154: not null constraints on XMLType cols
Rem     smashimo   12/20/06 - bug 5589140: exclude ADT col in ku$_objgrant_view
Rem     cchiappa   12/15/06 - Match col# rather than colname in cube_tab_view
Rem     smashimo   12/05/06 - bug 5515882: Add 'rownum < 2' to query on secobj$
Rem     lbarton    11/03/06 - bug 5607195: subpartition template in interval
Rem                           partition
Rem     dgagne     12/01/06 - add property parse item for table_data
Rem     lbarton    11/17/06 - bug 5663744: add MODIFY transform for XMLSCHEMA
Rem     slynn      10/12/06 - smartfile->securefile
Rem     lbarton    10/05/06 - more interval partitioning
Rem     sramakri   10/20/06 - use get_version in ku$_m_view_view
Rem     sdavidso   10/18/06 - allow xml version based on metadata version
Rem     sdavidso   09/07/06 - Editions support
Rem     rdecker    08/15/06 - ADd PLScope parameter
Rem     lbarton    09/13/06 - interval partitioning
Rem     cchiappa   09/13/06 - Expand cube table metadata
Rem     akruglik   09/07/06 - Column Map Views got rechristened as Editioning
Rem                           Views
Rem     lbarton    09/18/06 - bug 5212908: PARALLEL_HINT
Rem     rapayne    09/10/06 - exclude XS$NULL from export
Rem     rapayne    09/07/06 - lrg 2526933: add order by to jijoin_table_view
Rem     lbarton    08/25/06 - Bug 5414416: transient types
Rem     lbarton    08/31/06 - lrg 2453260: dpstream compatibility
Rem     rapayne    08/22/06 - Add pfname to FGA_POLICY total_order filter
Rem     sdavidso   07/14/06 - parent_object parse items for refpar 
Rem     dgagne     08/21/06 - add user pref stats
Rem     sdavidso   07/25/06 - new view for 10_1_audit 
Rem     lbarton    07/12/06 - bug 5386908: XMLType fixes 
Rem     lbarton    06/01/06 - Editioning View (EV) transform 
Rem     ataracha   07/13/06 - add user anonymous to be excluded from all views
Rem     lbarton    10/05/05 - bug 4516042: xmlschemas and SB tables in Data 
Rem                           Pump 
Rem     rapayne    06/27/06 - lrg 2374146 - add ORDER BY to jijoin_view to
Rem                           make mdapi test (e.g., where clauses) more
Rem                           deterministic.
Rem     dkapoor    06/29/06 - don't export ORACLE_OCM 
Rem     clei       06/22/06 - add XDS policy types for fusion security
Rem     weizhang   06/12/06 - proj 18567: support LOBRETENTION and MAXSIZE 
Rem     htseng     05/30/06 - add support for column default replace null with 
Rem     sdavidso   05/23/06 - Add partition transportable support 
Rem     sdavidso   05/12/06 - support for ref partitioning 
Rem     rapayne    05/24/06 - proj 15998 - add xmlalter stylesheets.
Rem     wesmith    06/01/06 - create 10.2 view for triggers
Rem     wesmith    05/15/06 - add support for triggerdep$
Rem     sramakri   05/15/06 - set minor version to 2 in ku$_m_view_view
Rem     sramakri   04/12/06 - ku$_10_2_index_view
Rem     sdavidso   04/25/06 - support for invisible index attr 
Rem     suelee     03/31/06 - Add procedures for IORM 
Rem     sdavidso   04/28/06 - default parameters - part domain index 
Rem     dgagne     04/14/06 - add parse item for parttype in table_data 
Rem     shshanka   04/25/06 - (jstenois) changes to disallow direct path
Rem     sdavidso   04/12/06 - Add support for dependent tables 
Rem     dgagne     04/21/06 - add parseitem for tablespace num and index prop
Rem                         - add views to fetch subnames for tables + indexes
Rem     cchiappa   04/10/06 - ORGANIZATION CUBE tables 
Rem     lbarton    04/05/06 - bug 5120417: use ku$_prepost_view 
Rem     lbarton    03/27/06 - bug 5118027: CONSTRAINTS and REF_CONSTRAINTS 
Rem                           params for SXML(DDL) 
Rem     lbarton    01/20/06 - partition transportable
Rem     lbarton    01/20/06 - bug 3328206: add QUOTE_SYMBOL 
Rem     dgagne     01/27/06 - add views to get tablespaces based on partitions 
Rem     lbarton    01/13/06 - bug 4951322: grants WITH HIERARCHY OPTION 
Rem     lbarton    12/29/05 - REMAP_COLUMN_NAME
Rem     rapayne    12/14/05 - bug 4868804: ku$_index_view workaround for a 
Rem                           typed view bug 4886241.
Rem     htseng     12/16/05 - add transform param PARTITIONING 
Rem     sdavidso   11/07/05 - Bug 4660745: Add fully qualified name expansion
Rem                           of attrname, for XMLtype naming issues.
Rem     lbarton    11/09/05 - bug 4724986: add kusidxwk.xsl 
Rem     rapayne    11/11/05 - bug 4634712: ensure local attributes are large
Rem                           enough to double up quotes.
Rem     cmlim      11/30/05 - support dml error logging 
Rem     sdavidso   10/19/05 - add group name for temporary tablespaces 
Rem     rapayne    10/07/05 - Fix bug 4628170 - fail to fetch index metadata
Rem                           for materialized views.
Rem     sdavidso   08/22/05 - add OMF indicator for files 
Rem     sdavidso   08/01/05 - add tranform_param type check info 
Rem     htseng     06/03/05 - metadata diffing
Rem     lbarton    05/27/05 - metadata diffing 
Rem     lbarton    05/25/05 - metadata diffing 
Rem     dgagne     06/27/05 - return ancestor info as base info for indexes, 
Rem                           if ancestor is available 
Rem     rapayne    06/13/05 - Bug 4321610: allow constraint conditions to
Rem                           exceed 4k chars.
Rem     lbarton    06/17/05 - bug 4352110: strip nulls from trigger 
Rem                           definition, whenclause 
Rem     dgagne     05/24/05 - fix problems with not uniquely identifying 
Rem                           objects with parse items 
Rem     dgagne     06/02/05 - add index_statistics parse item for index flags 
Rem                           to see if system generated 
Rem     lbarton    05/09/05 - Bug 4331909: fetch dataobj with ov_tabpart
Rem                           and ov_table 
Rem     lbarton    05/03/05 - Bug 4338735: dont export WMSYS 
Rem     dgagne     04/13/05 - fix bug 4134884 - do not decode public schema 
Rem                           for db_link 
Rem     dgagne     03/16/05 - fix find_sgc_view to look in con$ not ind$ for 
Rem                           constraints 
Rem     htseng     03/09/05 - more fixe for bug 4067141 
Rem     htseng     03/03/05 - bug 4067141: set up correct base_obj_num for pkg
Rem     dgagne     03/03/05 - return has_xmlschemacols for all types of 
Rem                           table_data objects 
Rem     dgagne     02/15/05 - bug 3738015 - give parse item for fgac on 
Rem                           table_data objects 
Rem     lbarton    01/07/05 - Bug 4109444: exclude schemas 
Rem     lbarton    12/21/04 - bug 4081635: not null constraint on ADT column 
Rem     lbarton    12/20/04 - bug 3995788: exclude type body for SQLJ type 
Rem     htseng     11/29/04 - bug 4004882: get updated default comsumer group 
Rem                           value. 
Rem     rpfau      10/25/04 - More on bug 3599656 - Do versioning. Make it 
Rem                           VERS_MAJOR=2, VERS_MINOR=2 for the 4 non-heap
Rem                           tables to get them all in sync, for checking
Rem                           whether to make check_type calls for
Rem                           transportable tablespace imports in kutable.xsl.
Rem     rpfau      09/10/04 - Bug 3599656 - Add hashcode and typeid to 
Rem                           subcoltype_t, hashcode to coltype_t, and
Rem                           version to type_t for type checking for
Rem                           transportable tablespace import.
Rem     araghava   10/29/04 - 3448802: get blocksize from 1st lob fragment if 
Rem                           deftsn is null in partlob$ 
Rem     htseng     10/18/04 - fix bug 3955213 not exclude private synonym when 
Rem                           exclude_noexp 
Rem     rapayne    10/13/04 - bug 3928528: Add table parse item, PRS_TRIGFLAG.
Rem                           Also, modify ku$_strmcol_view to utilize new
Rem                           get_col_property function to clear 
Rem                           encryption bits if appropriate.
Rem     dgagne     10/14/04 - add transform parameter stats_lock to lock 
Rem                           statistics 
Rem     htseng     10/05/04 - bug 3884290:add condition linkname is NULL for 
Rem                           ku$_base_proc_view
Rem     lbarton    09/01/04 - Bug 3827736: use NULLTOCHR0 with epvalue 
Rem     htseng     08/19/04 - bug 3794006:correct Tablespace size after resize
Rem     lbarton    08/05/04 - Bug 3813945: encryption password 
Rem     lbarton    07/16/04 - add encryption support 
Rem     dgagne     07/27/04 - add index_flags parse item for indexes 
Rem     dgagne     07/21/04 - get more index stats if both index name and cols 
Rem                           are not system generated 
Rem     rpfau      06/15/04 - Fix opaque type (also anydata type) in 
Rem                           partitioned tables - bug 3618089.
Rem     lbarton    06/30/04 - Bug 3722008: comment parse item: NAME (colname)
Rem     lbarton    06/29/04 - Bug 3730124: table_data parse items:
Rem                             HAS_NFT_VARRAY, HAS_NONSCOPED_REF
Rem     lbarton    06/22/04 - Bug 3695154: obsolete initmeta.sql 
Rem     htseng     06/21/04 - add support plsql_ccflags 
Rem     dgagne     06/25/04 - add stat_table and stat_schema as transforms for 
Rem                           statistics 
Rem     lbarton    06/10/04 - Bug 3675944: PCTSPACE for CLUSTER/CONSTRAINT;
Rem                           versioning support for dblink, statistics
Rem     lbarton    06/01/04 - Bug 3617842: SAMPLE and PCTSPACE 
Rem     jnarasin   05/28/04 - Alter User changes for EUS Proxy project 
Rem     dgagne     06/14/04 - add values to table stats for using stats table 
Rem     rvissapr   05/06/04 - dblink encoding - proj 5523 
Rem     lbarton    05/18/04 - Bug 3622808: comments on operators/idxtypes
Rem     lbarton    05/14/04 - trigflag
Rem     dgagne     05/12/04 - add trigflag as parse item for table_data 
Rem     dgagne     05/18/04 - add old stats types and stats for compatibility 
Rem     htseng     05/04/04 - bug 3599070: timestamp format 
Rem     htseng     05/11/04 - bug 3601775: fix SEQUENCE maxvalue 
Rem     lbarton    05/14/04 - Add TRANSPORTABLE_CLASSIC 
Rem     rpfau      05/12/04 - Add logic to control closure checking. 
Rem     lbarton    01/28/04 - split off catmet2.sql 
Rem     dgagne     04/28/04 - add privname as parse item to object_grant and
Rem                           sys_grant
Rem     htseng     04/27/04 - bug 3566300: support subtitutable column
Rem     lbarton    04/14/04 - Bug 3561663: fetch NOT NULL and check constr
Rem     htseng     04/08/04 - bug 3554691: add storage_clause for 
Rem                           AQ_QUEUE_TABLE 
Rem     lbarton    04/02/04 - Bug 3549198: parse item last_ddl_time 
Rem     htseng     04/02/04 - bug 3464376: subpartitions were created via 
Rem                           the tables's subpartition template clause 
Rem     lbarton    04/14/04 - Bug 3546038: MODIFY transform for STRMTABLE_T 
Rem     htseng     04/05/04 - add set_transform_param for CLUSTER 
Rem     mxiao      03/24/04 - support synonym in materialized view
Rem     rpfau      03/17/04 - Bump version number. 
Rem     rpfau      03/16/04 - Bug 3368895: add HAS_LONG_COL parse item to
Rem                           table_data. 
Rem     lbarton    03/30/04 - Bug 3540185: allow table_export of SYS tables 
Rem     lbarton    02/16/04 - Bug 3440387: exclude_noexp for types in tte 
Rem     emagrath   02/10/04 - Transportable OID/SETID constraints/indexes
Rem     dgagne     02/23/04 - fix statistics view performance 
Rem     htseng     02/02/04 - bug 3412625 : enlarge AQ_QUEUE comments size 
Rem     lbarton    01/30/04 - table data not schema object 
Rem     dgagne     01/20/04 - put back stats locking and caching changes 
Rem     lbarton    01/07/04 - Bug 3358912: force lob big endian 
Rem     dgagne     12/26/03 - get trigflags in stats for locking 
Rem     jdavison   12/18/03 - Add workaround of no_merge hint for optimizer 
Rem     dgagne     12/08/03 - escape epvalue single ' with 2 single ''
Rem     lbarton    12/03/03 - Bug 3209757: enable remap_schema for procdepobjg 
Rem     lbarton    10/17/03 - bug fixes from vision db testing
Rem     lbarton    11/21/03 - Bug 3264014: skip PIOT mapping table partitions 
Rem     dgagne     12/02/03 - add view for subpartitioned index stats 
Rem     dgagne     11/19/03 - fix sgc view - don't exclude unanalyzed indexes 
Rem     lbarton    11/07/03 - Bug 3238141: SEGMENT_ATTRIBUTES for constr, etc. 
Rem     lbarton    11/10/03 - lrg1589893: pkref constraints in iots 
Rem     htseng     11/14/03 - fix bug 3114752 - connect to user for db link
Rem     dgagne     11/05/03 - change system generated constraint view 
Rem     dgagne     10/21/03 - connect to owner for index and materialized 
Rem     lbarton    10/02/03 - Bug 3167541: run domain index metadata code as 
Rem                           cur user 
Rem     lbarton    09/22/03 - Bug 3105223: PARTITION_NAME parse item 
Rem     lbarton    09/17/03 - Bug 3130275: domain index fix 
Rem     lbarton    09/16/03 - Bug 3121396: run procobj code as cur user 
Rem     rvissapr   09/10/03 - bug 3095609 - add all_columns 
Rem     htseng     09/15/03 - bug3116063(v9.2):use long2clob to fix 
Rem                           query_text >36K 
Rem     nmanappa   09/03/03 - Adding audit trail option to fga policy 
Rem     dgagne     09/08/03 - add convert parse item for PATCHTABLEMETADATA 
Rem     clei       09/03/03 - Add VPD security relevant column option
Rem     wesmith    08/28/03 - add additional filters, parse items for MV logs
Rem     lbarton    08/15/03 - Bug 3097576: parse item HAS_XMLSCHEMA_COLS 
Rem     dgagne     08/20/03 - return base and anc info for secodnary tables 
Rem     lbarton    08/06/03 - Bug 3056720: use long2clob for view text 
Rem     htseng     08/05/03 - sql compiler switch support 
Rem     lbarton    07/16/03 - Bug 3042522: export procobjs in SYS
Rem     lbarton    06/23/03 - Bug 2994218: REMAP_TABLESPACE remap CREATE TS
Rem     lbarton    07/18/03 - Bug 3045926: PRS_GRANTOR for proc objs
Rem     clei       07/15/03 - synonym policies no longer attached to base obj
Rem     lbarton    07/10/03 - Bug 3045654: VERSION transform param
Rem     htseng     07/24/03 - add logname for object_grants
Rem     lbarton    07/02/03 - Bug 3016951: fetch more type metadata
Rem     emagrath   07/01/03 - Restore IOT/pkOID Pkeys to CONSTRAINT object,
Rem                           filter for heterogeneous types
Rem     lbarton    06/16/03 - Bug 2983400: get nested tables in ku$_tts_view
Rem     dgagne     06/24/03 - add grantor parse item for role grants and
Rem                           system privileges
Rem     htseng     06/11/03 - bug 2999418: large dbtimezone to be varchar2(64)
Rem     gclaborn   06/16/03 - 3000737: Fix grant ordering problem
Rem     emagrath   06/06/03 - Correct index info for constraints
Rem     lbarton    06/02/03 - Bug 2971302: PRIMARY filter for all schema objs
Rem     lbarton    05/27/03 - add MV/MVlogs to transportable_export
Rem     wesmith    05/20/03 - fix MV-related types/views for snap_colmap$ 
Rem                           metadata
Rem     gclaborn   06/04/03 - Add OID transform for INC_TYPE
Rem     lbarton    05/16/03 - bug 2949397: support INDEXTYPE options
Rem     htseng     05/28/03 - bug 2978647: connect to user for JAVA creating
Rem     gclaborn   05/20/03 - Move data_int.choose_unloadpath functionality to
Rem                           ku$_unload_method_view
Rem     emagrath   05/20/03 - Revamp constraint processing
Rem     htseng     05/23/03 - bug 2969613:Cluster table columns order
Rem     htseng     05/21/03 - bug 2967731:Trigger body > 4000
Rem     lbarton    05/07/03 - bug 2944274: bitmap join indexes
Rem     lbarton    05/05/03 - fix PRIMARY/SECONDARY for TRIGGER
Rem     htseng     05/12/03 - change parse LONGNAME to LONG_NAME for JAVA
Rem     dgagne     05/05/03 - add view for transform/object type matching
Rem     gclaborn   05/02/03 - bug 2939384: Add obj_num to property views
Rem     dgagne     05/07/03 - use parent table as base object for table
Rem                           statistics on nested tables
Rem     lbarton    04/15/03 - bug 2848977: skip IOT mapping tables
Rem     lbarton    04/04/03 - bug 2844111: move ku$_source_t to dbmsmetu.sql
Rem     htseng     04/16/03 - bug 2907529:cluster hash is clause
Rem     lbarton    04/01/03 - bug 2875448: 2ndary table fix
Rem     lbarton    03/28/03 - Bug 2833951: add LONGNAME parse item
Rem     lbarton    03/14/03 - bug 2837703: fix table_data bytes_alloc
Rem     htseng     03/25/03 - bug 2862458: Table varopq type column
Rem     dgagne     03/28/03 - change index to soft connect
Rem     gclaborn   04/03/03 - Allow bind vars for certain filters
Rem     lbarton    03/04/03 - bug 2828224: null procact_schema stmts
Rem     lbarton    02/25/03 - bug 2816302 - mask unused col bit in fhtable_view
Rem     lbarton    01/27/03 - add types to transportable_export
Rem     lbarton    01/23/03 - sort types
Rem     dgagne     01/27/03 - add index type parse item for index stats
Rem     htseng     01/29/03 - fix rollback segment optimal value
Rem     lbarton    01/17/03 - remove empty audit_default xml documents
Rem     lbarton    01/07/03 - rework INCLUDE_NULL filter; cache objnum
Rem     clei       01/15/03 - fix ku$_rls_policy_view
Rem     lbarton    01/22/03 - new transform params SQLFILE, CURRENT_SCHEMA
Rem     dgagne     01/20/03 - indicate which objects can be loaded in parallel
Rem     gclaborn   01/15/03 - Change NOEXP filter for synonyms
Rem     dgagne     01/16/03 - Change grantor for tablespace_quota to be system
Rem     gclaborn   01/09/03 - Fix metaview$ entry for system callouts
Rem     lbarton    12/30/02 - add lobmd to pcolumn_t for transportable
Rem     nmanappa   12/27/02 - Adding AUDIT_DEFAULT type
Rem     dgagne     01/02/03 - update materialized view types and views
Rem     lbarton    12/11/02 - get more trigger metadata
Rem     lbarton    11/12/02 - new types for procedural objects
Rem     htseng     12/06/02 - fix bug 2670085- when dimension length >4000
Rem     dgagne     12/17/02 - add Data Pump imp information to metaview$ flags
Rem     clei       11/25/02 - add Index statement type for VPD policies
Rem     lbarton    12/02/02 - fix busted merge
Rem     lbarton    11/26/02 - strmcoltype_view: get hashcode from matching vsn
Rem     lbarton    11/12/02 - more bugfixes
Rem     lbarton    11/11/02 - bugfix
Rem     lbarton    11/05/02 - comment on materialized views
Rem     lbarton    10/29/02 - RECYCLED filter
Rem     dgagne     12/03/02 - fix select for stats for subpartitioned tables
Rem     dgagne     11/21/02 - fix statistics view
Rem     jdavison   11/27/02 - Exclude invalid rollback segs
Rem     gclaborn   11/08/02 - Add parse_attr to metaxslparam$
Rem     masubram   10/06/02 - add knredef1
Rem     dgagne     10/09/02 - remove empty audit_obj xml documents
Rem     lbarton    10/09/02 - add PRS_ROW for DDL
Rem     wfisher    10/06/02 - Add final path to datapump_paths view
Rem     htseng     10/11/02 - fix bug 2616047 - when query length > 4000 
Rem                           in ku$_m_view_t
Rem     lbarton    09/20/02 - add DATAPUMP_PATHMAP view
Rem     rvissapr   10/01/02 - fga changes
Rem     htseng     10/01/02 - fix EXCLUDE_NAME_EXPR for XMLSCHEMA
Rem     tkeefe     09/19/02 - Move proxy_data$ and proxy_role_data$ out of
Rem                           bootstrap region
Rem     lbarton    09/30/02 - more strm metadata
Rem     clei       09/03/02 - add 10i rls policy api extension
Rem     gclaborn   08/23/02 - accomodate CORE`s new file name length of 1025
Rem     dgagne     08/27/02 - fix rls to fetch only bits needed for stmttype
Rem     bmccarth   08/22/02 - XDB: 92->main merge of stripschema
Rem     htseng     08/02/02 - correct variable name
Rem     htseng     08/07/02 - add parse CONSTRAINTS for VIEW 
Rem     lbarton    08/02/02 - transportable export
Rem     lbarton    07/12/02 - clean up schema export
Rem     htseng     07/02/02 - add attriv property to table_data
Rem     htseng     06/25/02 - add post/pre table action support
Rem     lbarton    06/07/02 - implement set_remap_param
Rem     lbarton    06/03/02 - transform params for data layer & network support
Rem     htseng     05/31/02 - add filter package for PROCACT_SYSTEM.
Rem     htseng     05/29/02 - add supplemental log support.
Rem     lbarton    05/17/02 - simplify DPSTREAM_TABLE object
Rem     lbarton    05/09/02 - EXCLUDE_NOEXP filter
Rem     lbarton    05/06/02 - support subviews
Rem     htseng     04/26/02 - add procedural objects and actions API support.
Rem     lbarton    04/25/02 - domain index support
Rem     lbarton    04/17/02 - new parse items
Rem     gclaborn   04/11/02 - Change usage text
Rem     lbarton    04/10/02 - add DPSTREAM_TABLE object
Rem     htseng     04/02/02 - add refresh_group object support.
Rem     lbarton    04/01/02 - add column lists to insert statements
Rem     lbarton    03/21/02 - parse items for BL0
Rem     htseng     03/05/02 - add rmgr object support.
Rem     bmccarth   03/01/02 - add schemaoid to xmlschema
Rem     lbarton    02/14/02 - Fix iot issue
Rem     lbarton    02/06/02 - new 10i infrastructure
Rem     emagrath   01/31/02 - Complete support for REF constraints
Rem     htseng     01/22/02 - add AQ_QUEUE_TABLE support from export.
Rem     lbarton    12/13/01 - filter out empty AUDIT_OBJ docs
Rem     dgagne     12/11/01 - fix security views so only DBA can use
Rem     htseng     12/07/01 - add java object support.
Rem     dgagne     12/06/01 - remove not-null constraints from constraint view
Rem     htseng     11/27/01 - add password_history object support.
Rem     htseng     11/15/01 - add rmgr objects support.
Rem     htseng     11/05/01 - privilege checking.
Rem     htseng     10/22/01 - change AQ. to AQ_
Rem     lbarton    10/25/01 - xdb support
Rem     vmarwah    10/18/01 - LOB retention compatibility changes.
Rem     htseng     10/18/01 - change privilege for ku$_user_view..
Rem     lbarton    10/05/01 - Support Ordered Collections in Tables
Rem     vmarwah    10/08/01 - renaming spare1 and spare2 fields for LOB$.
Rem     lbarton    10/10/01 - Improve performance of mviews and mview logs
Rem     dgagne     10/10/01 - add support for table/index/cluster statistics
Rem     htseng     09/24/01 - fix missing kujob.xsl.
Rem     htseng     09/17/01 - add syn_long_name for java_source.
Rem     htseng     09/04/01 - add more objects support.
Rem     dgagne     09/14/01 - add subpartition template support
Rem     lbarton    09/24/01 - tablespace filter
Rem     dgagne     09/05/01 - add support for range/list composite support
Rem     lbarton    09/05/01 - package reorg
Rem     lbarton    07/11/01 - tweak query on source$ for perf
Rem     dgagne     06/14/01 - add more object support
Rem     lbarton    01/19/01 - add BUILTIN_COL filter
Rem     lbarton    01/12/01 - add comments
Rem     lbarton    01/10/01 - add USER_COL to constraint_col_t
Rem     lbarton    01/08/01 - support 8.1 compatibility
Rem     lbarton    12/01/00 - bugfix
Rem     gclaborn   11/22/00 - Update base dir for stylesheets
Rem     lbarton    11/10/00 - support long views
Rem     lbarton    10/24/00 - sort in views, not in xsl
Rem     lbarton    10/13/00 - bugfixes
Rem     gclaborn   11/03/00 - Change xsl script names to kufoo format
Rem     lbarton    10/05/00 - synonym support
Rem     gclaborn   10/11/00 - perf. enhancements
Rem     svivian    09/14/00 - add support for logical instantiation
Rem     lbarton    09/13/00 - version strings; new transform params
Rem     lbarton    08/18/00 - functions now in dbms_metadata_int
Rem     elu        08/15/00 - add replication xsl scripts for flavors
Rem     lbarton    07/28/00 - datapump: add metastylesheet
Rem     lbarton    06/23/00 - Multinested collections; populate dictionary
Rem     lbarton    06/12/00 - facility name change
Rem     rmurthy    06/20/00 - change objauth.option column to hold flag bits
Rem     gclaborn   05/04/00 - Update operators/indextypes to use multinesting
Rem     lbarton    05/18/00 - bugfix: piotable_view
Rem     gclaborn   04/24/00 - Update outline metadata to new 8.2 format
Rem     gclaborn   04/06/00 - Add outline support
Rem     lbarton    03/30/00 - Changes for partitioning
Rem     lbarton    03/17/00 - multinested collections
Rem     lbarton    03/01/00 - new table views, etc.
Rem     gclaborn   12/29/99 - Remove ref. to dbms_metadata_int
Rem     lbarton    12/03/99 - domain index support
Rem     gclaborn   11/24/99 - Add trigger support
Rem     akalra/lbarton/gclaborn
Rem                11/17/99 -  created


-------------------------------------------------------------------------------
--
-- Catmeta.sql has been broken out as part of the Parallel Upgrade Project.
-- All new changes and comments should be entered in the files below.
-- Comments are preserved in this file for historical purpose.
--
-- catmettypes.sql  - Contains Type Definitions
-- catmetviews.sql  - Contains View Definitions
-- catmetgrant1.sql - Contains 50% of Metadata Grants
-- catmetgrant2.sql - Contains 50% of Metadata Grants
-- catmetinsert.sql - Contains Metadata Inserts
--
-------------------------------------------------------------------------------
@@catmettypes.sql
@@catmetviews.sql
@@catmetgrant1.sql
@@catmetgrant2.sql
@@catmetinsert.sql


