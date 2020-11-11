Rem
Rem $Header: rdbms/admin/cathcsx.sql /main/12 2017/05/23 07:15:17 jhartsin Exp $
Rem
Rem cathcsx.sql
Rem
Rem Copyright (c) 2014, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      cathcsx.sql - mdx schema rowset metadata view creation
Rem
Rem    DESCRIPTION
Rem      This file creates the metadata views to support the mdx schema rowsets
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/cathcsx.sql 
Rem    SQL_SHIPPED_FILE: 
Rem    SQL_PHASE: CATHCSX
Rem    SQL_STARTUP_MODE: NORMAL 
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: 
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    jhartsin    05/19/17 - Bug 26109171: cast columns to varchar2(4000)
Rem    mstasiew    02/04/16 - Bug 22665373: default numeric_precision/scale
Rem    mstasiew    02/02/16 - Bug 22648480: odbo_prop attr_hier_name,card
Rem    mstasiew    12/22/15 - Bug 20849731: mdx_odbo_properties fixes
Rem    mstasiew    12/22/15 - Bug 20892639: mdx_odbo_measures num col fixes
Rem    smesropi    10/10/15 - Bug 21171628: Rename HCS tables and views
Rem    sfeinste    10/09/15 - Return schema name as CATALOG_NAME column
Rem    sfeinste    09/09/15 - Bug 20849495: level_type in mdx_odbo_levels
Rem    mstasiew    08/03/15 - 21547588 fix mdx_odbo_functions column order
Rem    mstasiew    07/17/15 - 20777735 add mdx_odbo_functions.caption
Rem    sfeinste    04/14/15 - Remove TO_CHAR hack on CLOB columns and
Rem                           enable extended cell properties
Rem    mstasiew    07/29/14 - add MDX_ODBO_FUNCTIONS
Rem    ddedonat    05/20/14 - Removed Order by from MDX_ODBO_LEVELS view
Rem    sfeinste    04/30/14 - language IS NULL => language (+) IS NULL
Rem    sfeinste    04/28/14 - Populate default member for measure dimension
Rem                           in mdx_odbo_hierarchies.  Also modified
Rem                           unique measure name in mdx_odbo_measures.
Rem                           Added ALTER PACKAGE sys.dbms_mdx_odbo COMPILE
Rem                           at the end to ensure that the package is valid.
Rem    smesropi    04/25/14 - Added join on measure views
Rem    ddedonat    03/27/14 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

CREATE OR REPLACE VIEW mdx_odbo_cubes AS (
SELECT
  schema_name CATALOG_NAME,
  SCHEMA_NAME,
  CUBE_NAME,
  CUBE_TYPE,
  NULL CUBE_GUID,             /* not supported by schema rowset, set to NULL */
  NULL CREATED_ON,       /* not supported by this schema rowset, set to NULL */
  NULL LAST_SCHEMA_UPDATE,    /* not supported by schema rowset, set to NULL */
  NULL SCHEMA_UPDATED_BY,     /* not supported by schema rowset, set to NULL */
  NULL LAST_DATA_UPDATE, /* not supported by this schema rowset, set to NULL */
  NULL DATA_UPDATED_BY,  /* not supported by this schema rowset, set to NULL */
  DESCRIPTION,
  IS_DRILLTHROUGH_ENABLED,
  NULL IS_LINKABLE,      /* not supported by this schema rowset, set to NULL */
  NULL IS_WRITE_ENABLED, /* not supported by this schema rowset, set to NULL */
  NULL IS_SQL_ENABLED,   /* not supported by this schema rowset, set to NULL */
  CUBE_CAPTION,
  NULL BASE_CUBE_NAME,  /* not supported by schema rowset, set NULL */
  NULL ANNOTATIONS,      /* not supported by this schema rowset, set to NULL */
  NULL CUBE_SOURCE   /* not supported by schema rowset, set to NULL */
  FROM (
SELECT
  SCHEMA_NAME,
  CUBE_NAME,
  CUBE_TYPE,
  NVL(CUBE_DESCRIPTION_RAW, NVL(CUBE_CAPTION_RAW, CUBE_NAME)) DESCRIPTION,
  IS_DRILLTHROUGH_ENABLED,
  NVL(CUBE_CAPTION_RAW, CUBE_NAME) CUBE_CAPTION
  FROM (  
SELECT
  av.owner SCHEMA_NAME,
  av.analytic_view_name CUBE_NAME,
  'CUBE' CUBE_TYPE,
  NVL(avc_desc_l.value, avc_desc_n.value) CUBE_DESCRIPTION_RAW,
  1 IS_DRILLTHROUGH_ENABLED,
  NVL(avc_cap_l.value, avc_cap_n.value) CUBE_CAPTION_RAW
FROM all_analytic_views av, v$nls_parameters nls,
     all_analytic_view_class avc_cap_l,
     all_analytic_view_class avc_cap_n,
     all_analytic_view_class avc_desc_l,
     all_analytic_view_class avc_desc_n
WHERE avc_cap_l.owner (+)= av.owner AND
      avc_cap_l.analytic_view_name (+)= av.analytic_view_name AND
      avc_cap_l.classification (+)= 'CAPTION' AND
      avc_cap_l.language (+)= nls.value AND
      avc_cap_n.owner (+)= av.owner AND
      avc_cap_n.analytic_view_name (+)= av.analytic_view_name AND
      avc_cap_n.classification (+)= 'CAPTION' AND
      avc_cap_n.language (+) IS NULL AND
      avc_desc_l.owner (+)= av.owner AND
      avc_desc_l.analytic_view_name (+)= av.analytic_view_name AND
      avc_desc_l.classification (+)= 'DESCRIPTION' AND
      avc_desc_l.language (+)= nls.value AND
      avc_desc_n.owner (+)= av.owner AND
      avc_desc_n.analytic_view_name (+)= av.analytic_view_name AND
      avc_desc_n.classification (+)= 'DESCRIPTION' AND
      avc_desc_n.language (+) IS NULL AND
      nls.parameter = 'NLS_LANGUAGE'
)));


CREATE OR REPLACE VIEW mdx_odbo_dimensions AS (
SELECT
  schema_name CATALOG_NAME,
  SCHEMA_NAME,
  CUBE_NAME,
  DIMENSION_NAME,
  CAST(DIMENSION_UNIQUE_NAME AS VARCHAR2(4000)) DIMENSION_UNIQUE_NAME,
  NULL DIMENSION_GUID,   /* not supported by this schema rowset, set to NULL */
  DIMENSION_CAPTION,
  DIMENSION_ORDINAL,
  DIMENSION_TYPE,
  DIMENSION_CARDINALITY,
  CAST(DEFAULT_HIERARCHY AS VARCHAR2(4000)) DEFAULT_HIERARCHY,
  DESCRIPTION,
  NULL IS_VIRTUAL,       /* not supported by this schema rowset, set to NULL */
  NULL IS_READWRITE,     /* not supported by this schema rowset, set to NULL */
  NULL DIMENSION_UNIQUE_SETTINGS,/* not supported by schema rowset, set NULL */
  NULL DIMENSION_MASTER_UNIQUE_NAME,/*not supported by schema rowset,set NULL*/
  DIMENSION_IS_VISIBLE
FROM (
SELECT
  SCHEMA_NAME,
  CUBE_NAME,
  DIMENSION_NAME DIMENSION_NAME,
  DIMENSION_UNIQUE_NAME,
  NVL(DIMENSION_CAPTION_RAW, DIMENSION_NAME) DIMENSION_CAPTION,
  DIMENSION_ORDINAL,
  DIMENSION_TYPE,
  DIMENSION_CARDINALITY,
  DEFAULT_HIERARCHY DEFAULT_HIERARCHY,
  NVL(DESCRIPTION_RAW, NVL(DIMENSION_CAPTION_RAW,DIMENSION_NAME)) DESCRIPTION,
  DIMENSION_IS_VISIBLE
FROM (
SELECT /* Measure dimension */
  av.owner SCHEMA_NAME,
  av.analytic_view_name CUBE_NAME,
  NVL(mdname.value, 'MEASURES') DIMENSION_NAME,
  dbms_mdx_odbo.mdx_component_id(NVL(mdname.value, 'MEASURES')) DIMENSION_UNIQUE_NAME,
  mdcaption.value DIMENSION_CAPTION_RAW,
  /*  Todo:  Would like to make ordinal 1-based instead of 0-based but this 
      currently causes  problem in OLAP Provider */
  0 DIMENSION_ORDINAL,
  dbms_mdx_odbo.mdx_dimension_type('MD_DIMTYPE_MEASURE') DIMENSION_TYPE,
  dbms_mdx_odbo.mdx_get_measure_cardinality(av.owner, av.analytic_view_name) DIMENSION_CARDINALITY,
  dbms_mdx_odbo.mdx_component_id(NVL(mdname.value, 'MEASURES'), NVL(mdhiername.value, 'MEASURES')) DEFAULT_HIERARCHY,
  mddesc.value DESCRIPTION_RAW,
  1 DIMENSION_IS_VISIBLE
FROM all_analytic_views av,
     all_analytic_view_class mdname,
     all_analytic_view_class mdhiername,
     all_analytic_view_class mdcaption,
     all_analytic_view_class mddesc
WHERE mdname.owner (+)= av.owner AND
      mdname.analytic_view_name (+)= av.analytic_view_name AND
      mdname.classification (+)= 'MEAS_DIM_NAME' AND
      mdhiername.owner (+)= av.owner AND
      mdhiername.analytic_view_name (+)= av.analytic_view_name AND
      mdhiername.classification (+)= 'MEAS_DIM_HIER_NAME' AND
      mdcaption.owner (+)= av.owner AND
      mdcaption.analytic_view_name (+)= av.analytic_view_name AND
      mdcaption.classification (+)= 'MEAS_DIM_CAPTION' AND
      mddesc.owner (+)= av.owner AND
      mddesc.analytic_view_name (+)= av.analytic_view_name AND
      mddesc.classification (+)= 'MEAS_DIM_DESCRIPTION'
UNION ALL
SELECT /* Attribute dimensions in DIMENSION BY */
  avd.owner SCHEMA_NAME,
  avd.analytic_view_name CUBE_NAME,
  /*  Need to convert to clob to align datatype with dimension_name of measure dimension  */  
  to_clob(avd.dimension_alias) DIMENSION_NAME,
  dbms_mdx_odbo.mdx_component_id(avd.dimension_alias) DIMENSION_UNIQUE_NAME,
  /*  Need to convert to clob to align datatype with dimension_caption_raw of measure dimension  */  
  to_clob(NVL(avdc_cap_l.value, avdc_cap_n.value)) DIMENSION_CAPTION_RAW,
  avd.order_num + 1 DIMENSION_ORDINAL,
  CASE avd.dimension_type
    WHEN 'TIME' THEN  dbms_mdx_odbo.mdx_dimension_type('MD_DIMTYPE_TIME')
    WHEN 'STANDARD' THEN dbms_mdx_odbo.mdx_dimension_type('MD_DIMTYPE_OTHER')
    ELSE dbms_mdx_odbo.mdx_dimension_type('MD_DIMTYPE_UNKNOWN')
  END DIMENSION_TYPE,
  dbms_mdx_odbo.mdx_get_dimension_cardinality(avd.owner, avd.analytic_view_name, avd.dimension_alias) DIMENSION_CARDINALITY,
  dbms_mdx_odbo.mdx_component_id(avd.dimension_alias, def_hier.hier_alias) DEFAULT_HIERARCHY,
  NVL(avdc_desc_l.value, avdc_desc_n.value) DESCRIPTION_RAW,
  1 DIMENSION_IS_VISIBLE
FROM all_analytic_view_dimensions avd,
     all_analytic_view_hiers def_hier,
     v$nls_parameters nls,
     all_analytic_view_dim_class avdc_cap_l,
     all_analytic_view_dim_class avdc_cap_n,
     all_analytic_view_dim_class avdc_desc_l,
     all_analytic_view_dim_class avdc_desc_n
WHERE avd.owner = def_hier.owner AND
      avd.analytic_view_name = def_hier.analytic_view_name AND 
      avd.dimension_alias = def_hier.dimension_alias AND
      def_hier.is_default = 'Y' AND
      nls.parameter = 'NLS_LANGUAGE' AND 
      avdc_cap_l.owner (+)= avd.owner AND
      avdc_cap_l.analytic_view_name (+)= avd.analytic_view_name AND
      avdc_cap_l.dimension_alias (+)= avd.dimension_alias AND
      avdc_cap_l.classification (+)= 'CAPTION' AND
      avdc_cap_l.language (+)= nls.value AND
      avdc_cap_n.owner (+)= avd.owner AND
      avdc_cap_n.analytic_view_name (+)= avd.analytic_view_name AND
      avdc_cap_n.dimension_alias (+)= avd.dimension_alias AND
      avdc_cap_n.classification (+)= 'CAPTION' AND
      avdc_cap_n.language (+) IS NULL AND
      avdc_desc_l.owner (+)= avd.owner AND
      avdc_desc_l.analytic_view_name (+)= avd.analytic_view_name AND
      avdc_desc_l.dimension_alias (+)= avd.dimension_alias AND
      avdc_desc_l.classification (+)= 'DESCRIPTION' AND
      avdc_desc_l.language (+)= nls.value AND
      avdc_desc_n.owner (+)= avd.owner AND
      avdc_desc_n.analytic_view_name (+)= avd.analytic_view_name AND
      avdc_desc_n.dimension_alias (+)= avd.dimension_alias AND
      avdc_desc_n.classification (+)= 'DESCRIPTION' AND
      avdc_desc_n.language (+) IS NULL
)));

CREATE OR REPLACE VIEW mdx_odbo_functions AS
select FUNCTION_NAME,
 DESCRIPTION,
 PARAM_LIST,
 12 AS RETURN_TYPE,
 1 AS ORIGIN,
 INTERFACE_NAME,
 NULL AS LIBRARY_NAME,
 NULL AS DLL_NAME,
 NULL AS HELP_FILE,
 NULL AS HELP_CONTEXT,
 OBJECT,
 CAPTION
from
TABLE(sys.dbms_mdx_odbo.get_mdx_function_names());


CREATE OR REPLACE VIEW mdx_odbo_hierarchies AS (
SELECT
  schema_name CATALOG_NAME,
  SCHEMA_NAME,
  CUBE_NAME,
  CAST(DIMENSION_UNIQUE_NAME AS VARCHAR2(4000)) DIMENSION_UNIQUE_NAME,
  CAST(HIERARCHY_NAME AS VARCHAR2(4000)) HIERARCHY_NAME,
  CAST(HIERARCHY_UNIQUE_NAME AS VARCHAR2(4000)) HIERARCHY_UNIQUE_NAME,
  NULL HIERARCHY_GUID,   /* not supported by this schema rowset, set to NULL */
  HIERARCHY_CAPTION,
  DIMENSION_TYPE,
  HIERARCHY_CARDINALITY,
  CAST(DEFAULT_MEMBER AS VARCHAR2(4000)) DEFAULT_MEMBER,
  CAST(ALL_MEMBER AS VARCHAR2(4000)) ALL_MEMBER,
  DESCRIPTION,
  STRUCTURE,
  NULL IS_VIRTUAL,       /* not supported by this schema rowset, set to NULL */
  NULL IS_READWRITE,     /* not supported by this schema rowset, set to NULL */
  NULL DIMENSION_UNIQUE_SETTINGS,/* not supported by schema rowset, set NULL */
  NULL DIMENSION_MASTER_UNIQUE_NAME,/*not supported by schema rowset,set NULL*/
  DIMENSION_IS_VISIBLE, 
  HIERARCHY_ORDINAL,
  NULL DIMENSION_IS_SHARED,   /* not supported by schema rowset, set to NULL */
  HIERARCHY_IS_VISIBLE,
  HIERARCHY_ORIGIN,
  HIERARCHY_DISPLAY_FOLDER,
  INSTANCE_SELECTION,
  NULL GROUPING_BEHAVIOR,
  NULL STRUCTURE_TYPE
FROM (
SELECT
  SCHEMA_NAME,
  CUBE_NAME,
  DIMENSION_UNIQUE_NAME,
  HIERARCHY_NAME,
  HIERARCHY_UNIQUE_NAME,
  NVL(HIERARCHY_CAPTION_RAW, HIERARCHY_NAME) HIERARCHY_CAPTION,
  DIMENSION_TYPE,
  HIERARCHY_CARDINALITY,
  DEFAULT_MEMBER,
  ALL_MEMBER,
  NVL(DESCRIPTION_RAW, NVL(HIERARCHY_CAPTION_RAW, HIERARCHY_NAME)) DESCRIPTION,
  STRUCTURE,
  DIMENSION_IS_VISIBLE, 
  HIERARCHY_ORDINAL,
  HIERARCHY_IS_VISIBLE,
  HIERARCHY_ORIGIN,
  HIERARCHY_DISPLAY_FOLDER,
  INSTANCE_SELECTION
FROM (
SELECT /* Hierarchy in the Measure dimension */
  av.owner SCHEMA_NAME,
  av.analytic_view_name CUBE_NAME,
  dbms_mdx_odbo.mdx_component_id(NVL(mdname.value, 'MEASURES')) DIMENSION_UNIQUE_NAME,
  to_char(NVL(mdhiername.value, 'MEASURES')) HIERARCHY_NAME,
  dbms_mdx_odbo.mdx_component_id(NVL(mdname.value, 'MEASURES'), NVL(mdhiername.value, 'MEASURES')) HIERARCHY_UNIQUE_NAME,
  NVL(mdhiername.value, 'MEASURES') HIERARCHY_CAPTION_RAW,
  dbms_mdx_odbo.mdx_dimension_type('MD_DIMTYPE_MEASURE') DIMENSION_TYPE,
  dbms_mdx_odbo.mdx_get_measure_cardinality(av.owner, av.analytic_view_name) HIERARCHY_CARDINALITY,  
  dbms_mdx_odbo.mdx_component_id(NVL(mdname.value, 'MEASURES'),
    NVL(mdhiername.value, 'MEASURES'), NVL(mdlvlname.value, 'MEASURES'))
    || '.&[' || av.default_measure || ']' DEFAULT_MEMBER,
  NULL ALL_MEMBER,
  NULL DESCRIPTION_RAW,
  dbms_mdx_odbo.mdx_hierarchy_structure('MD_STRUCTURE_FULLYBALANCED') STRUCTURE,  
  1 DIMENSION_IS_VISIBLE,
  /*  To do:  Would like to make ordinal 1-based instead of 0-based but this 
      currently causes  problem in OLAP Provider */
  0 HIERARCHY_ORDINAL,
  1 HIERARCHY_IS_VISIBLE,
  dbms_mdx_odbo.mdx_origin('MD_ORIGIN_USER_DEFINED') HIERARCHY_ORIGIN,    
  NULL HIERARCHY_DISPLAY_FOLDER,
  dbms_mdx_odbo.mdx_hierarchy_inst_selection('MD_INSTANCE_SELECTION_LIST') INSTANCE_SELECTION
FROM all_analytic_views av,
     all_analytic_view_class mdname,
     all_analytic_view_class mdhiername,
     all_analytic_view_class mdlvlname
WHERE mdname.owner (+)= av.owner AND
      mdname.analytic_view_name (+)= av.analytic_view_name AND
      mdname.classification (+)= 'MEAS_DIM_NAME' AND
      mdhiername.owner (+)= av.owner AND
      mdhiername.analytic_view_name (+)= av.analytic_view_name AND
      mdhiername.classification (+)= 'MEAS_DIM_HIER_NAME' AND
      mdlvlname.owner (+)= av.owner AND
      mdlvlname.analytic_view_name (+)= av.analytic_view_name AND
      mdlvlname.classification (+)= 'MEAS_DIM_HIER_LVL_NAME'
UNION ALL
SELECT /* Hierarchies in DIMENSION BY */
  avh.owner SCHEMA_NAME,
  avh.analytic_view_name CUBE_NAME,
  dbms_mdx_odbo.mdx_component_id(avh.dimension_alias) DIMENSION_UNIQUE_NAME,
  avh.hier_alias HIERARCHY_NAME,
  dbms_mdx_odbo.mdx_component_id(avh.dimension_alias, avh.hier_alias) HIERARCHY_UNIQUE_NAME,
  NVL(avhc_cap_l.value, avhc_cap_n.value) HIERARCHY_CAPTION_RAW,
  CASE avd.dimension_type
    WHEN 'TIME' THEN  dbms_mdx_odbo.mdx_dimension_type('MD_DIMTYPE_TIME')
    WHEN 'STANDARD' THEN dbms_mdx_odbo.mdx_dimension_type('MD_DIMTYPE_OTHER')
    ELSE dbms_mdx_odbo.mdx_dimension_type('MD_DIMTYPE_UNKNOWN')  
  END DIMENSION_TYPE,
    dbms_mdx_odbo.mdx_get_hierarchy_cardinality(avh.owner, avh.analytic_view_name, avh.dimension_alias, avh.hier_alias) HIERARCHY_CARDINALITY,
    dbms_mdx_odbo.mdx_component_id(avh.dimension_alias, avh.hier_alias, 'ALL',
      	avd.all_member_name) DEFAULT_MEMBER,
    dbms_mdx_odbo.mdx_component_id(avh.dimension_alias, avh.hier_alias, 'ALL',
      avd.all_member_name) ALL_MEMBER,
    NVL(avhc_desc_l.value, avhc_desc_n.value) DESCRIPTION_RAW,
    /*  To do:  Need to set STRUCTURE to an appropriate value.  Not sure 
        where this will come from. Setting temporarily to 
       'MD_STRUCTURE_FULLYBALANCED' */ 
    dbms_mdx_odbo.mdx_hierarchy_structure('MD_STRUCTURE_FULLYBALANCED') STRUCTURE,  
    1 DIMENSION_IS_VISIBLE,
	ROW_NUMBER() OVER (
    PARTITION BY avh.owner, avh.analytic_view_name
    ORDER BY avd.order_num, avh.order_num ) HIERARCHY_ORDINAL,
    1 HIERARCHY_IS_VISIBLE,
    dbms_mdx_odbo.mdx_origin('MD_ORIGIN_USER_DEFINED') HIERARCHY_ORIGIN,    
    NULL HIERARCHY_DISPLAY_FOLDER,
    dbms_mdx_odbo.mdx_hierarchy_inst_selection('MD_INSTANCE_SELECTION_LIST') INSTANCE_SELECTION
FROM all_analytic_view_dimensions avd,
     all_analytic_view_hiers avh,
	 v$nls_parameters nls,
     all_analytic_view_hier_class avhc_cap_l,
     all_analytic_view_hier_class avhc_cap_n,
     all_analytic_view_hier_class avhc_desc_l,
     all_analytic_view_hier_class avhc_desc_n
WHERE avd.owner = avh.owner AND
      avd.analytic_view_name = avh.analytic_view_name AND
      avd.dimension_alias = avh.dimension_alias AND
      nls.parameter = 'NLS_LANGUAGE' AND
      avhc_cap_l.owner (+)= avh.owner AND
      avhc_cap_l.analytic_view_name (+)= avh.analytic_view_name AND
      avhc_cap_l.dimension_alias (+)= avh.dimension_alias AND
      avhc_cap_l.hier_alias (+)= avh.hier_alias AND
      avhc_cap_l.classification (+)= 'CAPTION' AND
      avhc_cap_l.language (+)= nls.value AND
      avhc_cap_n.owner (+)= avh.owner AND
      avhc_cap_n.analytic_view_name (+)= avh.analytic_view_name AND
      avhc_cap_n.dimension_alias (+)= avh.dimension_alias AND
      avhc_cap_n.hier_alias (+)= avh.hier_alias AND
      avhc_cap_n.classification (+)= 'CAPTION' AND
      avhc_cap_n.language (+) IS NULL AND
      avhc_desc_l.owner (+)= avh.owner AND
      avhc_desc_l.analytic_view_name (+)= avh.analytic_view_name AND
      avhc_desc_l.dimension_alias (+)= avh.dimension_alias AND
      avhc_desc_l.hier_alias (+)= avh.hier_alias AND
      avhc_desc_l.classification (+)= 'DESCRIPTION' AND
      avhc_desc_l.language (+)= nls.value AND
      avhc_desc_n.owner (+)= avh.owner AND
      avhc_desc_n.analytic_view_name (+)= avh.analytic_view_name AND
      avhc_desc_n.dimension_alias (+)= avh.dimension_alias AND
      avhc_desc_n.hier_alias (+)= avh.hier_alias AND
      avhc_desc_n.classification (+)= 'DESCRIPTION' AND
      avhc_desc_n.language (+) IS NULL  
)));

CREATE OR REPLACE VIEW mdx_odbo_levels AS (
SELECT
  schema_name CATALOG_NAME,
  SCHEMA_NAME,
  CUBE_NAME,
  CAST(DIMENSION_UNIQUE_NAME AS VARCHAR2(4000)) DIMENSION_UNIQUE_NAME,
  CAST(HIERARCHY_UNIQUE_NAME AS VARCHAR2(4000)) HIERARCHY_UNIQUE_NAME,
  CAST(LEVEL_NAME AS VARCHAR2(4000)) LEVEL_NAME,
  CAST(LEVEL_UNIQUE_NAME AS VARCHAR2(4000)) LEVEL_UNIQUE_NAME,
  NULL LEVEL_GUID,       /* not supported by this schema rowset, set to NULL */
  LEVEL_CAPTION,
  LEVEL_NUMBER,
  LEVEL_CARDINALITY,
  LEVEL_TYPE,
  DESCRIPTION,
  NULL CUSTOM_ROLLUP_SETTINGS,   /* not supported by schema rowset, set NULL */
  LEVEL_UNIQUE_SETTINGS,
  LEVEL_IS_VISIBLE,
  LEVEL_ORDERING_PROPERTY,
  NULL LEVEL_DBTYPE,     /* not supported by this schema rowset, set to NULL */
  NULL LEVEL_MASTER_UNIQUE_NAME, /* not supported by schema rowset, set NULL */
  NULL LEVEL_NAME_SQL_COLUMN_NAME,/* not supported by schema rowset, set NULL*/
  NULL LEVEL_KEY_SQL_COLUMN_NAME,/* not supported by schema rowset, set NULL */
  NULL LEVEL_UNIQUE_NAME_SQL_COL_NAME,/*not supported by schema rowset,  NULL*/
  NULL LEVEL_ATTRIBUTE_HIERARCHY_NAME,/* not supported by schema rowset, NULL*/
  LEVEL_KEY_CARDINALITY,
  LEVEL_ORIGIN
FROM (
SELECT
  SCHEMA_NAME,
  CUBE_NAME,
  DIMENSION_UNIQUE_NAME,
  HIERARCHY_UNIQUE_NAME,
  LEVEL_NAME,
  LEVEL_UNIQUE_NAME,
  NVL(level_caption_raw, level_name) LEVEL_CAPTION,
  LEVEL_NUMBER,
  LEVEL_CARDINALITY,
  LEVEL_TYPE,
  NVL(description_raw, NVL(level_caption_raw, level_name)) DESCRIPTION,
  LEVEL_UNIQUE_SETTINGS,
  LEVEL_IS_VISIBLE,
  LEVEL_ORDERING_PROPERTY,
  LEVEL_KEY_CARDINALITY,
  LEVEL_ORIGIN
FROM (
SELECT /* Single level in the Measure dimension */
  av.owner SCHEMA_NAME,
  av.analytic_view_name CUBE_NAME,
  dbms_mdx_odbo.mdx_component_id(NVL(mdname.value, 'MEASURES')) DIMENSION_UNIQUE_NAME,
  dbms_mdx_odbo.mdx_component_id(NVL(mdname.value, 'MEASURES'), NVL(mdhiername.value, 'MEASURES')) HIERARCHY_UNIQUE_NAME,
  to_char(NVL(mdhierlvlname.value, 'MEASURES')) LEVEL_NAME,
  dbms_mdx_odbo.mdx_component_id(NVL(mdname.value, 'MEASURES'), NVL(mdhiername.value, 'MEASURES'), NVL(mdhierlvlname.value, 'MEASURES')) LEVEL_UNIQUE_NAME,
  NULL LEVEL_CAPTION_RAW,
  0 LEVEL_NUMBER,
  dbms_mdx_odbo.mdx_get_measure_cardinality(av.owner, av.analytic_view_name) LEVEL_CARDINALITY,  
  /*  Set LEVEL_TYPE to MDLEVEL_TYPE_REGULAR (0) for measures  */
  0 LEVEL_TYPE,
  NULL DESCRIPTION_RAW,
  /*  Set LEVEL_UNIQUE_SETTINGS to MDDIMENSIONS_MEMBER_KEY_UNIQUE and 
      MDDIMENSIONS_MEMBER_NAME_UNIQUE for Measures level */
  dbms_mdx_odbo.mdx_level_unique_settings('MDDIMENSIONS_MEMBER_KEY_UNIQUE') + 
    dbms_mdx_odbo.mdx_level_unique_settings('MDDIMENSIONS_MEMBER_NAME_UNIQUE') LEVEL_UNIQUE_SETTINGS,
  /* Set LEVEL_IS_VISIBLE to TRUE as a default               */
  1 LEVEL_IS_VISIBLE,
  NULL LEVEL_ORDERING_PROPERTY,
  1 LEVEL_KEY_CARDINALITY,
  /* Set LEVEL_ORIGIN to user-defined as a default           */
  dbms_mdx_odbo.mdx_origin('MD_ORIGIN_USER_DEFINED') LEVEL_ORIGIN   
FROM all_analytic_views av,
     all_analytic_view_class mdname,
     all_analytic_view_class mdhiername,
     all_analytic_view_class mdhierlvlname
WHERE mdname.owner (+)= av.owner AND
      mdname.analytic_view_name (+)= av.analytic_view_name AND
      mdname.classification (+)= 'MEAS_DIM_NAME' AND
      mdhiername.owner (+)= av.owner AND
      mdhiername.analytic_view_name (+)= av.analytic_view_name AND
      mdhiername.classification (+)= 'MEAS_DIM_HIER_NAME' AND
      mdhierlvlname.owner (+)= av.owner AND
      mdhierlvlname.analytic_view_name (+)= av.analytic_view_name AND
      mdhierlvlname.classification (+)= 'MEAS_DIM_HIER_LVL_NAME'
UNION ALL
SELECT /* ALL level in level hiers in DIMENSION BY */
  avh.owner SCHEMA_NAME,
  avh.analytic_view_name CUBE_NAME,
  dbms_mdx_odbo.mdx_component_id(avh.dimension_alias) DIMENSION_UNIQUE_NAME,
  dbms_mdx_odbo.mdx_component_id(avh.dimension_alias, avh.hier_alias) HIERARCHY_UNIQUE_NAME,
  'ALL' LEVEL_NAME,
  dbms_mdx_odbo.mdx_component_id(avh.dimension_alias, avh.hier_alias, 'ALL') LEVEL_UNIQUE_NAME,
  NULL LEVEL_CAPTION_RAW,
  0 LEVEL_NUMBER,
  1 LEVEL_CARDINALITY,
  /*  Set LEVEL_TYPE to MDLEVEL_TYPE_ALL (1) for All Level   */
  1 LEVEL_TYPE,
  NULL DESCRIPTION_RAW,
  /*  Set LEVEL_UNIQUE_SETTINGS to MDDIMENSIONS_MEMBER_KEY_UNIQUE and 
      MDDIMENSIONS_MEMBER_NAME_UNIQUE for All level */
  dbms_mdx_odbo.mdx_level_unique_settings('MDDIMENSIONS_MEMBER_KEY_UNIQUE') + 
    dbms_mdx_odbo.mdx_level_unique_settings('MDDIMENSIONS_MEMBER_NAME_UNIQUE') LEVEL_UNIQUE_SETTINGS,
  /* Set LEVEL_IS_VISIBLE to TRUE as a default               */
  1 LEVEL_IS_VISIBLE,
  NULL LEVEL_ORDERING_PROPERTY,
  1 LEVEL_KEY_CARDINALITY,
  /* Set LEVEL_ORIGIN to user-defined as a default           */
  dbms_mdx_odbo.mdx_origin('MD_ORIGIN_USER_DEFINED') LEVEL_ORIGIN
FROM all_analytic_view_hiers avh
/*  Parent-child hierarchies are currently not supported.  Remove WHERE 
    block logic temporarily  */
--     all_analytic_view_columns avc
/* Eliminate parent-child hierarchies */
--WHERE  avc.role = 'PAR' AND  
--      NOT (avh.owner = avc.owner AND
--           avh.analytic_view_name = avc.analytic_view_name AND
--           avh.dimension_alias = avc.dimension_name AND
--           avh.hier_alias = avc.hier_name)
UNION ALL
SELECT /* Explicit levels in level hiers in DIMENSION BY */
  avl.owner SCHEMA_NAME,
  avl.analytic_view_name CUBE_NAME,
  dbms_mdx_odbo.mdx_component_id(avl.dimension_alias) DIMENSION_UNIQUE_NAME,
  dbms_mdx_odbo.mdx_component_id(avl.dimension_alias, avl.hier_alias) HIERARCHY_UNIQUE_NAME,
  avl.level_name LEVEL_NAME,
  dbms_mdx_odbo.mdx_component_id(avl.dimension_alias, avl.hier_alias, avl.level_name) LEVEL_UNIQUE_NAME,
  NVL(avlc_cap_l.value, avlc_cap_n.value) LEVEL_CAPTION_RAW,
  avl.order_num+1 LEVEL_NUMBER,
  dbms_mdx_odbo.mdx_get_level_cardinality(avl.owner, avl.analytic_view_name, avl.dimension_alias, avl.hier_alias, avl.level_name) LEVEL_CARDINALITY,
  /*  Set LEVEL_TYPE to MDLEVEL_TYPE_REGULAR (0) for every Level   */
  0 LEVEL_TYPE,
  NVL(avlc_desc_l.value, avlc_desc_n.value) DESCRIPTION_RAW,
  /*  Set LEVEL_UNIQUE_SETTINGS to MDDIMENSIONS_MEMBER_KEY_UNIQUE as 
      a default */
  dbms_mdx_odbo.mdx_level_unique_settings('MDDIMENSIONS_MEMBER_KEY_UNIQUE') LEVEL_UNIQUE_SETTINGS,
  /* Set LEVEL_IS_VISIBLE to TRUE as a default               */
  1 LEVEL_IS_VISIBLE,
  NULL LEVEL_ORDERING_PROPERTY,
  1 LEVEL_KEY_CARDINALITY,
  /* Set LEVEL_ORIGIN to user-defined as a default           */
  dbms_mdx_odbo.mdx_origin('MD_ORIGIN_USER_DEFINED') LEVEL_ORIGIN   
FROM all_analytic_view_levels avl,
     v$nls_parameters nls,
     all_analytic_view_level_class avlc_cap_l,
     all_analytic_view_level_class avlc_cap_n,
     all_analytic_view_level_class avlc_desc_l,
     all_analytic_view_level_class avlc_desc_n
WHERE nls.parameter = 'NLS_LANGUAGE' AND
      avlc_cap_l.owner (+)= avl.owner AND
      avlc_cap_l.analytic_view_name (+)= avl.analytic_view_name AND
      avlc_cap_l.dimension_alias (+)= avl.dimension_alias AND
      avlc_cap_l.hier_alias (+)= avl.hier_alias AND
      avlc_cap_l.level_name (+)= avl.level_name AND
      avlc_cap_l.classification (+)= 'CAPTION' AND
      avlc_cap_l.language (+)= nls.value AND
      avlc_cap_n.owner (+)= avl.owner AND
      avlc_cap_n.analytic_view_name (+)= avl.analytic_view_name AND
      avlc_cap_n.dimension_alias (+)= avl.dimension_alias AND
      avlc_cap_n.hier_alias (+)= avl.hier_alias AND
      avlc_cap_n.level_name (+)= avl.level_name AND
      avlc_cap_n.classification (+)= 'CAPTION' AND
      avlc_cap_n.language (+) IS NULL AND
      avlc_desc_l.owner (+)= avl.owner AND
      avlc_desc_l.analytic_view_name (+)= avl.analytic_view_name AND
      avlc_desc_l.dimension_alias (+)= avl.dimension_alias AND
      avlc_desc_l.hier_alias (+)= avl.hier_alias AND
      avlc_desc_l.level_name (+)= avl.level_name AND
      avlc_desc_l.classification (+)= 'DESCRIPTION' AND
      avlc_desc_l.language (+)= nls.value AND
      avlc_desc_n.owner (+)= avl.owner AND
      avlc_desc_n.analytic_view_name (+)= avl.analytic_view_name AND
      avlc_desc_n.dimension_alias (+)= avl.dimension_alias AND
      avlc_desc_n.hier_alias (+)= avl.hier_alias AND
      avlc_desc_n.level_name (+)= avl.level_name AND
      avlc_desc_n.classification (+)= 'DESCRIPTION' AND
      avlc_desc_n.language (+) IS NULL
)));

CREATE OR REPLACE VIEW mdx_odbo_measures AS (
SELECT
  schema_name CATALOG_NAME,
  SCHEMA_NAME,
  CUBE_NAME,
  MEASURE_NAME,
  CAST(MEASURE_UNIQUE_NAME AS VARCHAR2(4000)) MEASURE_UNIQUE_NAME,
  MEASURE_CAPTION,
  NULL MEASURE_GUID,     /* not supported by this schema rowset, set to NULL */
  MEASURE_AGGREGATOR, 
  DATA_TYPE,
  decode(data_type, 139, nvl(numeric_precision, 38), numeric_precision) 
    NUMERIC_PRECISION,
  decode(data_type, 139, nvl2(numeric_precision, nvl(numeric_scale, 0), 127),
    numeric_scale) NUMERIC_SCALE,
  NULL MEASURE_UNITS,
  DESCRIPTION, 
  NULL EXPRESSION,       /* not supported by this schema rowset, set to NULL */
  MEASURE_IS_VISIBLE,
  NULL LEVELS_LIST,      /* not supported by this schema rowset, set to NULL */
  NULL MEASURE_NAME_SQL_COLUMN_NAME, /* not supported by schema rowset, NULL */
  NULL MEASURE_UNQUALIFIED_CAPTION,  /* not supported by schema rowset, NULL */
  NULL MEASUREGROUP_NAME,    /* not supported by  schema rowset, set to NULL */
  NULL MEASURE_DISPLAY_FOLDER,
  NULL DEFAULT_FORMAT_STRING
FROM (  
  SELECT
  av.owner SCHEMA_NAME,
  av.analytic_view_name CUBE_NAME,
  avm.measure_name MEASURE_NAME,
  dbms_mdx_odbo.mdx_component_id(NVL(mdname.value, 'MEASURES'),
    NVL(mdhiername.value, 'MEASURES'), NVL(mdlvlname.value, 'MEASURES'))
    || '.&[' || avm.measure_name || ']' MEASURE_UNIQUE_NAME,
  NVL(avmc_cap_l.value, NVL(avmc_cap_n.value, avm.measure_name)) MEASURE_CAPTION,
  /*  To do: Hard code to MDMEASURE_AGGR_SUM for now    */ 
  dbms_mdx_odbo.mdx_measure_aggregator('MDMEASURE_AGGR_SUM') MEASURE_AGGREGATOR, 
  /*  Get from classifications and then translate to MS format  */
-- Will need to figure out where to get agg method from in the metadata
--CASE avm.agg_method
--  WHEN 'SUM' THEN  sys.dbms_mdx_odbo.mdx_measure_aggregator('MDMEASURE_AGGR_SUM')
--  WHEN 'MAX' THEN sys.dbms_mdx_odbo.mdx_measure_aggregator('MDMEASURE_AGGR_MAX')
--  ...
--  ...
--  ELSE NULL 
--END MEASURE_AGGREGATOR,
--
--  MDMEASURE_AGGR_SUM (1) identifies that the measure aggregates from SUM.
--  MDMEASURE_AGGR_COUNT (2) identifies that the measure aggregates from COUNT.
--  MDMEASURE_AGGR_MIN (3) identifies that the measure aggregates from MIN.
--  MDMEASURE_AGGR_MAX (4) identifies that the measure aggregates from MAX.
--  MDMEASURE_AGGR_AVG (5) identifies that the measure aggregates from AVG.
--  MDMEASURE_AGGR_VAR (6) identifies that the measure aggregates from VAR.
--  MDMEASURE_AGGR_STD (7) identifies that the measure aggregates from STDEV.
--  MDMEASURE_AGGR_DST (8) identifies that the measure aggregates from DISTINCT COUNT.
--  MDMEASURE_AGGR_NONE (9) identifies that the measure aggregates from NONE.
--  MDMEASURE_AGGR_AVGCHILDREN (10) identifies that the measure aggregates from AVERAGEOFCHILDREN.
--  MDMEASURE_AGGR_FIRSTCHILD (11) identifies that the measure aggregates from FIRSTCHILD.
--  MDMEASURE_AGGR_LASTCHILD (12) identifies that the measure aggregates from LASTCHILD.
--  MDMEASURE_AGGR_FIRSTNONEMPTY (13) identifies that the measure aggregates from FIRSTNONEMPTY,
--  MDMEASURE_AGGR_LASTNONEMPTY (14) identifies that the measure aggregates from LASTNONEMPTY.
--  MDMEASURE_AGGR_BYACCOUNT (15) identifies that the measure aggregates from BYACCOUNT.
--    MDMEASURE_AGGR_CALCULATED (127) identifies that the measure was derived from a formula that was not any single function above.
--  MDMEASURE_AGGR_UNKNOWN (0) identifies that the measure was derived from an unknown aggregation function or formula.
/*  To do:  Need to determine correct datatype along with precision and scale.  Hard coded for now to Number = 139 */
--  CASE avm.datatype
--    WHEN 'DECMAL' THEN sys.dbms_mdx_odbo.mdx_measure_aggregator('DBTYPE_DECIMAL')
--    WHEN 'DATE' THEN sys.dbms_mdx_odbo.mdx_measure_aggregator('DBTYPE_DATE')
--    ...
--    ...
--    ELSE NULL 
--  END DATA_TYPE,
  /*  Setting datatype to number since all_analytic_view_columns does not 
      have this data right now  */
  dbms_mdx_odbo.mdx_datatype(avm.data_type) DATA_TYPE,  
  /*  Setting precision and scale to 20,2 since all_analytic_view_columns 
      does not have this data right now */
  avm.data_precision NUMERIC_PRECISION,
  avm.data_scale NUMERIC_SCALE,
  NULL MEASURE_UNITS,
  NVL(avmc_desc_l.value, NVL(avmc_desc_n.value, avm.measure_name)) DESCRIPTION,
  1 MEASURE_IS_VISIBLE,
  NULL MEASURE_DISPLAY_FOLDER,
  /*  To DO:  Need to set default format string.   It is found in the 
      all_analytic_view_meas_class view */  
  NULL DEFAULT_FORMAT_STRING
FROM all_analytic_views av,
     (select owner, analytic_view_name, column_name measure_name,
      data_type, data_precision, data_scale from all_analytic_view_columns
      where role = 'BASE' or role = 'CALC') 
      avm,
     v$nls_parameters nls,
     all_analytic_view_meas_class avmc_cap_l,
     all_analytic_view_meas_class avmc_cap_n,
     all_analytic_view_meas_class avmc_desc_l,
     all_analytic_view_meas_class avmc_desc_n,
     all_analytic_view_class mdname,
     all_analytic_view_class mdhiername,
     all_analytic_view_class mdlvlname
WHERE nls.parameter = 'NLS_LANGUAGE' AND
      av.owner (+)= avm.owner AND
      av.analytic_view_name (+)= avm.analytic_view_name AND
      avmc_cap_l.owner (+)= avm.owner AND
      avmc_cap_l.analytic_view_name (+)= avm.analytic_view_name AND
      avmc_cap_l.measure_name (+)= avm.measure_name AND	  
      avmc_cap_l.classification (+)= 'CAPTION' AND
      avmc_cap_l.language (+)= nls.value AND
      avmc_cap_n.owner (+)= avm.owner AND
      avmc_cap_n.analytic_view_name (+)= avm.analytic_view_name AND
      avmc_cap_n.measure_name (+)= avm.measure_name AND	  
      avmc_cap_n.classification (+)= 'CAPTION' AND
      avmc_cap_n.language (+) IS NULL AND
      avmc_desc_l.owner (+)= avm.owner AND
      avmc_desc_l.analytic_view_name (+)= avm.analytic_view_name AND
      avmc_desc_l.measure_name (+)= avm.measure_name AND	  
      avmc_desc_l.classification (+)= 'DESCRIPTION' AND
      avmc_desc_l.language (+)= nls.value AND
      avmc_desc_n.owner (+)= avm.owner AND
      avmc_desc_n.analytic_view_name (+)= avm.analytic_view_name AND
      avmc_desc_n.measure_name (+)= avm.measure_name AND	  
      avmc_desc_n.classification (+)= 'DESCRIPTION' AND
      avmc_desc_n.language (+) IS NULL AND
      mdname.owner (+)= av.owner AND
      mdname.analytic_view_name (+)= av.analytic_view_name AND
      mdname.classification (+)= 'MEAS_DIM_NAME' AND
      mdhiername.owner (+)= av.owner AND
      mdhiername.analytic_view_name (+)= av.analytic_view_name AND
      mdhiername.classification (+)= 'MEAS_DIM_HIER_NAME' AND
      mdlvlname.owner (+)= av.owner AND
      mdlvlname.analytic_view_name (+)= av.analytic_view_name AND
      mdlvlname.classification (+)= 'MEAS_DIM_HIER_LVL_NAME'
));

CREATE OR REPLACE VIEW mdx_odbo_properties AS (
SELECT
  schema_name CATALOG_NAME,
  SCHEMA_NAME,
  CUBE_NAME,
  CAST(DIMENSION_UNIQUE_NAME AS VARCHAR2(4000)) DIMENSION_UNIQUE_NAME,
  CAST(HIERARCHY_UNIQUE_NAME AS VARCHAR2(4000)) HIERARCHY_UNIQUE_NAME,
  CAST(LEVEL_UNIQUE_NAME AS VARCHAR2(4000)) LEVEL_UNIQUE_NAME,
  MEMBER_UNIQUE_NAME,
  PROPERTY_TYPE,
  PROPERTY_NAME,
  PROPERTY_CAPTION,
  DATA_TYPE,
  CHARACTER_MAXIMUM_LENGTH,
  CHARACTER_OCTET_LENGTH,
  decode(data_type, 139, nvl(numeric_precision, 38), numeric_precision) 
    NUMERIC_PRECISION,
  decode(data_type, 139, nvl2(numeric_precision, nvl(numeric_scale, 0), 127),
    numeric_scale) NUMERIC_SCALE,
  DESCRIPTION,
  PROPERTY_CONTENT_TYPE,
  NULL SQL_COLUMN_NAME,  /* not supported by this schema rowset, set to NULL */
  LANGUAGE,
  PROPERTY_ORIGIN,
  PROPERTY_ATTRIBUTE_HIER_NAME,
  'ONE' PROPERTY_CARDINALITY,
  NULL MIME_TYPE,        /* not supported by this schema rowset, set to NULL */
  1 PROPERTY_IS_VISIBLE
FROM(
SELECT
  SCHEMA_NAME,
  CUBE_NAME,
  DIMENSION_UNIQUE_NAME,
  HIERARCHY_UNIQUE_NAME,
  LEVEL_UNIQUE_NAME,
  MEMBER_UNIQUE_NAME,
  PROPERTY_TYPE,
  PROPERTY_NAME,
  NVL(property_caption_raw, property_name) PROPERTY_CAPTION,
  DATA_TYPE,
  CHARACTER_MAXIMUM_LENGTH,
  CHARACTER_OCTET_LENGTH,
  NUMERIC_PRECISION,
  NUMERIC_SCALE,
  NVL(description_raw, NVL(property_caption_raw, property_name)) DESCRIPTION,
  PROPERTY_CONTENT_TYPE,
  LANGUAGE,
  PROPERTY_ORIGIN,
  PROPERTY_ATTRIBUTE_HIER_NAME
FROM (
SELECT /* dimension properties */
  avc.owner SCHEMA_NAME,
  avc.analytic_view_name CUBE_NAME,
  dbms_mdx_odbo.mdx_component_id(NVL(avc.dimension_name, 'MEASURES'))
    DIMENSION_UNIQUE_NAME,
  dbms_mdx_odbo.mdx_component_id(NVL(avc.dimension_name, 'MEASURES'),
    avc.hier_name) HIERARCHY_UNIQUE_NAME,
  dbms_mdx_odbo.mdx_component_id(NVL(avc.dimension_name, 'MEASURES'),
    avc.hier_name, avl.level_name) LEVEL_UNIQUE_NAME,
  NULL MEMBER_UNIQUE_NAME,
  dbms_mdx_odbo.mdx_property_type('MDPROP_MEMBER') PROPERTY_TYPE,
  avc.column_name PROPERTY_NAME,
  NVL(avac_cap_l.value, avac_cap_n.value) PROPERTY_CAPTION_RAW,
  dbms_mdx_odbo.mdx_datatype(avc.data_type) DATA_TYPE,
  avc.char_col_decl_length CHARACTER_MAXIMUM_LENGTH,
  avc.data_length CHARACTER_OCTET_LENGTH,
  avc.data_precision NUMERIC_PRECISION,
  avc.data_scale NUMERIC_SCALE,
  NVL(avac_desc_l.value, avac_desc_n.value) DESCRIPTION_RAW,
  CASE avc.role
    WHEN 'KEY' THEN
      dbms_mdx_odbo.mdx_property_content_type('MD_PROPTYPE_ID')
    WHEN 'AKEY' THEN
      dbms_mdx_odbo.mdx_property_content_type('MD_PROPTYPE_ID')
    ELSE dbms_mdx_odbo.mdx_property_content_type('MD_PROPTYPE_REGULAR')
  END PROPERTY_CONTENT_TYPE,
  NULL LANGUAGE,
  dbms_mdx_odbo.mdx_property_origin('MD_ORIGIN_USER_DEFINED') PROPERTY_ORIGIN,
  avc.column_name PROPERTY_ATTRIBUTE_HIER_NAME
 FROM all_analytic_view_columns avc,
     all_analytic_view_levels avl,
     v$nls_parameters nls,
     all_analytic_view_attr_class avac_cap_l,
     all_analytic_view_attr_class avac_cap_n,
     all_analytic_view_attr_class avac_desc_l,
     all_analytic_view_attr_class avac_desc_n
WHERE 1 != 1 AND /* TEMPORARILY return 0 rows */
      nls.parameter = 'NLS_LANGUAGE' AND
      avc.role not in ('BASE', 'CALC') AND
      avc.owner = avl.owner AND
      avc.analytic_view_name = avl.analytic_view_name AND
      avc.dimension_name = avl.dimension_alias AND
      avc.hier_name = avl.hier_alias AND
      avac_cap_l.owner (+)= avc.owner AND
      avac_cap_l.analytic_view_name (+)= avc.analytic_view_name AND
      avac_cap_l.dimension_alias (+)= avc.dimension_name AND
      avac_cap_l.hier_alias (+)= avc.hier_name AND
      avac_cap_l.attribute_name (+)= avc.column_name AND
      avac_cap_l.classification (+)= 'CAPTION' AND
      avac_cap_l.language (+)= nls.value AND
      avac_cap_n.owner (+)= avc.owner AND
      avac_cap_n.analytic_view_name (+)= avc.analytic_view_name AND
      avac_cap_n.dimension_alias (+)= avc.dimension_name AND
      avac_cap_n.hier_alias (+)= avc.hier_name AND
      avac_cap_n.attribute_name (+)= avc.column_name AND
      avac_cap_n.classification (+)= 'CAPTION' AND
      avac_cap_n.language (+) IS NULL AND
      avac_desc_l.owner (+)= avc.owner AND
      avac_desc_l.analytic_view_name (+)= avc.analytic_view_name AND
      avac_desc_l.dimension_alias (+)= avc.dimension_name AND
      avac_desc_l.hier_alias (+)= avc.hier_name AND
      avac_desc_l.attribute_name (+)= avc.column_name AND
      avac_desc_l.classification (+)= 'DESCRIPTION' AND
      avac_desc_l.language (+)= nls.value AND
      avac_desc_n.owner (+)= avc.owner AND
      avac_desc_n.analytic_view_name (+)= avc.analytic_view_name AND
      avac_desc_n.dimension_alias (+)= avc.dimension_name AND
      avac_desc_n.hier_alias (+)= avc.hier_name AND
      avac_desc_n.attribute_name (+)= avc.column_name AND
      avac_desc_n.classification (+)= 'DESCRIPTION' AND
      avac_desc_n.language (+) IS NULL  
)));

CREATE OR REPLACE VIEW mdx_odbo_sets AS (
SELECT
  NULL CATALOG_NAME,
  NULL SCHEMA_NAME,
  NULL CUBE_NAME,
  NULL SET_NAME,
  NULL SCOPE,
  NULL DESCRIPTION,
  NULL EXPRESSION,
  NULL DIMENSIONS,
  NULL SET_CAPTION,
  NULL SET_DISPLAY_FOLDER,
  NULL SET_EVALUATION_CONTEXT
FROM DUAL
WHERE 1=0
);


--  Unsupported OLE DB for OLAP Schema Rowsets
CREATE OR REPLACE VIEW mdx_odbo_actions AS (
SELECT 
  NULL CATALOG_NAME,
  NULL SCHEMA_NAME,
  NULL CUBE_NAME,
  NULL ACTION_NAME,
  NULL ACTION_TYPE,
  NULL COORDINATE,
  NULL COORDINATE_TYPE,
  NULL ACTION_CAPTION,
  NULL DESCRIPTION,
  NULL CONTENT,
  NULL APPLICATION,
  NULL INVOCATION
FROM DUAL WHERE 1=0
);

CREATE OR REPLACE VIEW mdx_odbo_input_datasources AS (
SELECT 
  NULL CATALOG_NAME,
  NULL SCHEMA_NAME,
  NULL DATASOURCE_NAME,
  NULL DATASOURCE_TYPE,
  NULL CREATED_ON,
  NULL LAST_SCHEMA_UPDATE,
  NULL DESCRIPTION,
  NULL TIMEOUT
FROM DUAL WHERE 1=0
);

CREATE OR REPLACE VIEW mdx_odbo_kpis AS (
SELECT
  NULL CATALOG_NAME,
  NULL SCHEMA_NAME,
  NULL CUBE_NAME,
  NULL MEASUREGROUP_NAME,
  NULL KPI_NAME,
  NULL KPI_CAPTION,
  NULL KPI_DESCRIPTION, 
  NULL KPI_DISPLAY_FOLDER,
  NULL KPI_VALUE,
  NULL KPI_GOAL,
  NULL KPI_STATUS,
  NULL KPI_TREND,
  NULL KPI_STATUS_GRAPHIC,
  NULL KPI_TREND_GRAPHIC,
  NULL KPI_WEIGHT,
  NULL KPI_CURRENT_TIME_MEMBER,
  NULL KPI_PARENT_KPI_NAME,
  NULL SCOPE
FROM DUAL
WHERE 1=0
);

-- To do:   mdx_odbo_measuregroup_dimensions name is too long.
--         renamed to mdx_odbo_measuregroup_dims
CREATE OR REPLACE VIEW mdx_odbo_measuregroup_dims AS (
SELECT
  NULL CATALOG_NAME,
  NULL SCHEMA_NAME,
  NULL CUBE_NAME,
  NULL MEASUREGROUP_NAME,
  NULL MEASUREGROUP_CARDINALITY,
  NULL DIMENSION_UNIQUE_NAME,
  NULL DIMENSION_CARDINALITY,
  NULL DIMENSION_IS_VISIBLE,
  NULL DIMENSION_IS_FACT_DIMENSION,
  NULL DIMENSION_PATH,
  NULL DIMENSION_GRANULARITY
FROM DUAL
WHERE 1=0
);

CREATE OR REPLACE VIEW mdx_odbo_measuregroups AS (
SELECT
  NULL CATALOG_NAME,
  NULL SCHEMA_NAME,
  NULL CUBE_NAME,
  NULL MEASUREGROUP_NAME,
  NULL DESCRIPTION,
  NULL IS_WRITE_ENABLED,
  NULL MEASUREGROUP_CAPTION
FROM DUAL
WHERE 1=0
);

CREATE ROLE DBMS_MDX_INTERNAL;

GRANT SELECT ON mdx_odbo_cubes to DBMS_MDX_INTERNAL;
GRANT SELECT ON mdx_odbo_dimensions to DBMS_MDX_INTERNAL;
GRANT SELECT ON mdx_odbo_functions to DBMS_MDX_INTERNAL;
GRANT SELECT ON mdx_odbo_hierarchies to DBMS_MDX_INTERNAL;
GRANT SELECT ON mdx_odbo_levels to DBMS_MDX_INTERNAL;
GRANT SELECT ON mdx_odbo_measures to DBMS_MDX_INTERNAL;
GRANT SELECT ON mdx_odbo_properties to DBMS_MDX_INTERNAL;
GRANT SELECT ON mdx_odbo_sets to DBMS_MDX_INTERNAL;
GRANT SELECT ON mdx_odbo_actions to DBMS_MDX_INTERNAL;
GRANT SELECT ON mdx_odbo_input_datasources to DBMS_MDX_INTERNAL;
GRANT SELECT ON mdx_odbo_kpis to DBMS_MDX_INTERNAL;
GRANT SELECT ON mdx_odbo_measuregroup_dims to DBMS_MDX_INTERNAL;
GRANT SELECT ON mdx_odbo_measuregroups to DBMS_MDX_INTERNAL;

GRANT DBMS_MDX_INTERNAL TO PACKAGE SYS.DBMS_MDX_ODBO;

/* If this script is run over an existing package, it can cause the package
   to become invalidated.  This explicit compile ensures that the package
   is valid when this script is complete. */
ALTER PACKAGE SYS.DBMS_MDX_ODBO COMPILE;

@?/rdbms/admin/sqlsessend.sql
