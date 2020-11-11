Rem
Rem $Header: rdbms/admin/catumfvw.sql /main/4 2017/10/25 18:01:33 raeburns Exp $
Rem
Rem catumfvw.sql
Rem
Rem Copyright (c) 2014, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catumfvw.sql - Catalog View Definitions for the Universal 
Rem                     Manageability Framework. 
Rem
Rem    DESCRIPTION
Rem      View definitions for UMF
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/catumfvw.sql 
Rem    SQL_SHIPPED_FILE: rdbms/admin/catumfvw.sql 
Rem    SQL_PHASE: CATUMFVW
Rem    SQL_STARTUP_MODE: NORMAL 
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: rdbms/admin/catumftv.sql
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    raeburns    10/20/17 - RTI 20225108: Fix SQL_METADATA
Rem    quotran     02/16/16 - Make umf$_registration_xml schema identical to
Rem                           umf$_registration
Rem    spapadom    02/02/15 - Added XML views.
Rem    spapadom    06/18/14 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

-- DBA_UMF_*  views for UMF Metadata.

/******************************************************
 *        DBA_UMF_TOPOLOGY
 ******************************************************/
CREATE OR REPLACE VIEW DBA_UMF_TOPOLOGY
   (TOPOLOGY_NAME, TARGET_ID, TOPOLOGY_VERSION, TOPOLOGY_STATE)
AS SELECT TOPOLOGY_NAME, TARGET_ID, TOPOLOGY_VERSION, 
DECODE(TOPOLOGY_STATE, 0, 'ACTIVE', 1, 'INACTIVE')
FROM UMF$_TOPOLOGY; 
/

CREATE OR REPLACE PUBLIC SYNONYM DBA_UMF_TOPOLOGY FOR DBA_UMF_TOPOLOGY
/
GRANT SELECT ON DBA_UMF_TOPOLOGY TO SELECT_CATALOG_ROLE
/

/******************************************************
 *        DBA_UMF_REGISTRATION
 ******************************************************/
CREATE OR REPLACE VIEW DBA_UMF_REGISTRATION
   (TOPOLOGY_NAME, NODE_NAME, NODE_ID, NODE_TYPE, AS_SOURCE, 
    AS_CANDIDATE_TARGET, STATE)
AS SELECT TOPOLOGY_NAME, NODE_NAME, NODE_ID, NODE_TYPE, 
          DECODE(AS_SOURCE, 1, 'TRUE', 0, 'FALSE'),
          DECODE(AS_CANDIDATE_TARGET, 1, 'TRUE', 0, 'FALSE'), 
          DECODE(STATE, 0, 'OK', 1, 'REGISTRATION PENDING', 2, 'SYNC FAILED')
FROM UMF$_REGISTRATION; 
/
CREATE OR REPLACE PUBLIC SYNONYM DBA_UMF_REGISTRATION FOR DBA_UMF_REGISTRATION
/

GRANT SELECT ON DBA_UMF_REGISTRATION TO SELECT_CATALOG_ROLE
/

/******************************************************
 *        DBA_UMF_LINK
 ******************************************************/
CREATE OR REPLACE VIEW DBA_UMF_LINK 
(TOPOLOGY_NAME, FROM_NODE_ID, TO_NODE_ID, LINK_NAME)
AS SELECT TOPOLOGY_NAME, FROM_NODE_ID, TO_NODE_ID, LINK_NAME
FROM UMF$_LINK;
/

CREATE OR REPLACE PUBLIC SYNONYM DBA_UMF_LINK FOR DBA_UMF_LINK
/

GRANT SELECT ON DBA_UMF_LINK TO SELECT_CATALOG_ROLE
/

/******************************************************
 *        DBA_UMF_SERVICE
 ******************************************************/
CREATE OR REPLACE VIEW DBA_UMF_SERVICE
(TOPOLOGY_NAME, NODE_ID, SERVICE_ID)
AS SELECT TOPOLOGY_NAME, NODE_ID, 
DECODE(SERVICE_ID, 1, 'AWR', 2, 'SQLTUNE')
FROM UMF$_SERVICE;
/

CREATE OR REPLACE PUBLIC SYNONYM DBA_UMF_SERVICE FOR DBA_UMF_SERVICE
/

GRANT SELECT ON DBA_UMF_SERVICE TO SELECT_CATALOG_ROLE
/

/******************************************************
 *        UMF_SCHEMA_XMLTYPE 
 * 
 *        Presents the contents of the umf$_ tables
 *        as an XMLType object.
 ******************************************************/
CREATE OR REPLACE VIEW umf_schema_xmltype OF XMLType 
WITH OBJECT ID (EXTRACT (object_value, 'umf').getNumberVal())
AS SELECT XMLElement("UMF_SCHEMA", 
        /* Root element for umf$_topology */
        XMLElement("TOPOLOGY",
                    /* Aggregation of XML Elements, one for each row */
                    (SELECT XMLAgg(XMLElement("TOPOLOGY_INST",
                               /* XMLForest corresponds to the table columns */
                                        XMLForest(topology_name, 
                                                  target_id,
                                                  topology_version, 
                                                  topology_state))) 
                     FROM umf$_topology)),
        /* Root element for umf$_registration */
        XMLElement("REGISTRATION",
                    /* Aggregation of XML Elements, one for each row */
                    (SELECT XMLAgg(XMLElement("REGISTRATION_INST",
                               /* XMLForest corresponds to the table columns */
                                        XMLForest(topology_name, 
                                                  node_name,
                                                  node_id, 
                                                  node_type,
                                                  as_source,
                                                  as_candidate_target,
                                                  state))) 
                     FROM umf$_registration)),
        /* Root element for umf$_link */
        XMLElement("LINK",
                    /* Aggregation of XML Elements, one for each row */
                    (SELECT XMLAgg(XMLElement("LINK_INST",
                               /* XMLForest corresponds to the table columns */
                                        XMLForest(topology_name, 
                                                  from_node_id,
                                                  to_node_id, 
                                                  link_name)))
                     FROM umf$_link)),
        /* Root element for umf$_service */
        XMLElement("SERVICE",
                    /* Aggregation of XML Elements, one for each row */
                    (SELECT XMLAgg(XMLElement("SERVICE_INST",
                               /* XMLForest corresponds to the table columns */
                                        XMLForest(topology_name, 
                                                  node_id,
                                                  service_id)))
                     FROM umf$_service))
)
AS "result" FROM dual;

@?/rdbms/admin/sqlsessend.sql
