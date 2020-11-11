Rem
Rem $Header: rdbms/admin/catumftb.sql /main/3 2017/10/25 18:01:33 raeburns Exp $
Rem
Rem catumftb.sql
Rem
Rem Copyright (c) 2014, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catumftb.sql - CATalog Unified Manageability Framework TaBle 
Rem                     definitions. 
Rem
Rem    DESCRIPTION
Rem      UMF table definitions.
Rem
Rem    NOTES
Rem      
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/catumftb.sql 
Rem    SQL_SHIPPED_FILE: rdbms/admin/catumftb.sql 
Rem    SQL_PHASE: CATUMFTB
Rem    SQL_STARTUP_MODE: NORMAL 
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: rdbms/admin/catumftv.sql
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    raeburns    10/20/17 - RTI 20225108: Fix SQL_METADATA
Rem    spapadom    02/02/15 - Added state column in UMF$_REGISTRATION.
Rem    spapadom    07/16/14 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

-- ************************************************************************ --
--  catumftb.sql implements the UMF data model. 
-- 
--  In UM, a "topology" is the set of all the participating "UMF nodes" and 
--  and provides metadata such as names and connection information for each 
--  node. 
-- 
--  The data model has the following entities.
-- 
-- Topology 
-- --------
-- A set of nodes participating in remote data collection. One of the nodes 
-- is designated as the target.
-- 
-- Node
-- -------
-- A system participating in data collection. A node can be a source
-- (of statistic information) and / or a candidate target (i.e. suitable for
-- replacing the target if necessary). Nodes have types: For now, we expect to
-- support onlu he Oracle database, but in the future we expect UMF to be 
-- used for other types (e.g. Exadata cells, application servers). In order 
-- for a node to participate in a topology, it must first "register" with the 
-- target of that topology. 
-- 
-- Link
-- -----
-- A method of communication between two nodes. Currently we use database links
-- to communicate between (database) nodes but in the future a link may
-- correspond to other kinds of connection descriptors. 
-- 
-- Service
-- -------
-- A service is an application running over a topology. For example, for remote
-- AWR snapshots, we need to enable the AWR service on participating nodes. 
-- 
-- ************************************************************************ --


-- ************************************************************************ --
-- UMF$_TOPOLOGY
-- ************************************************************************ --
CREATE TABLE UMF$_TOPOLOGY
(topology_name                  VARCHAR(128) NOT NULL
,target_id                      NUMBER 
,topology_version               NUMBER NOT NULL
,topology_state                 NUMBER NOT NULL
,CONSTRAINT umf$_topology_pk    PRIMARY KEY(topology_name)
) TABLESPACE SYSAUX
/

-- ************************************************************************ --
-- UMF$_REGISTRATION
-- ************************************************************************ --
CREATE TABLE UMF$_REGISTRATION
(topology_name           VARCHAR(128) NOT NULL
 ,node_name              VARCHAR(128) NOT NULL   /* Provided at registration */
 ,node_id                NUMBER NOT NULL           /* Auto-generated node ID */
 ,node_type              NUMBER NOT NULL             /* See data model above */
 ,as_source              NUMBER NOT NULL               /* Is this a source ? */
 ,as_candidate_target    NUMBER NOT NULL      /* Is this a candidate target? */
 ,state                  NUMBER NOT NULL            /* state of registration 
                                                            (e.g. error etc) */
 /* The same node name can belong to multiple topologies */
,CONSTRAINT umf$_registration_pk PRIMARY KEY(topology_name, node_name)
 /* The auto-generated node-id must be unique *for the target* because 
   it will be used to identify the nodes in data tables (AWR etc). */
,CONSTRAINT umf$_registration_unique UNIQUE (node_id)
) TABLESPACE SYSAUX
/

-- ************************************************************************ --
-- UMF$_REGISTRATION
-- ************************************************************************ --
CREATE TABLE UMF$_LINK
(topology_name                  VARCHAR(128) NOT NULL
,from_node_id                   NUMBER NOT NULL
,to_node_id                     NUMBER NOT NULL
,link_name                      VARCHAR2(128) NOT NULL
,CONSTRAINT umf$_link_pk PRIMARY KEY(topology_name, from_node_id, to_node_id)
) TABLESPACE SYSAUX
/

-- ************************************************************************ --
-- UMF$_SERVICE
-- ************************************************************************ --
CREATE TABLE UMF$_SERVICE
(topology_name            VARCHAR(128) NOT NULL
,node_id                  NUMBER NOT NULL
,service_id               NUMBER NOT NULL
) TABLESPACE SYSAUX
/

@?/rdbms/admin/sqlsessend.sql
