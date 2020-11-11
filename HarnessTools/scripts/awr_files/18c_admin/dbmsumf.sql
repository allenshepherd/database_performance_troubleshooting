Rem
Rem $Header: rdbms/admin/dbmsumf.sql /main/4 2016/08/17 10:28:14 osuro Exp $
Rem
Rem dbmsumf.sql
Rem
Rem Copyright (c) 2014, 2016, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbmsumf.sql - DBMS Unified Manageability Framework public interface.
Rem
Rem    DESCRIPTION
Rem      Specification of the dbms_umf interface.
Rem
Rem    NOTES
Rem      
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/dbmsumf.sql 
Rem    SQL_SHIPPED_FILE: 
Rem    SQL_PHASE: 
Rem    SQL_STARTUP_MODE: NORMAL 
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: rdbms/admin/catpdbms.sql
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    osuro       07/20/16 - Improvements in node information APIs
Rem    quotran     02/02/16 - Appoint a node to become new UMF target
Rem    spapadom    02/02/15 - UMF Milestone 2.
Rem    spapadom    06/02/14 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

--  ************************************************************************ --
--  The dbms_umf API provides functions to create and manage UMF topologies.
--
--  Specifically, it provides calls to create/drop topologies and to modify
--  a topology by adding/removing nodes and links. It also provides calls to 
--  manage services (such as AWR) running on nodes and to view/validate a 
--  topology. API calls for a given topology must be executed on the target
--  for that topology.
--  ************************************************************************ --

CREATE OR REPLACE PACKAGE dbms_umf AS

--************************************************************************** --
--  dbms_umf constants. 
-- 

-- Service types
        SERVICE_TYPE_AWR          CONSTANT NUMBER:=0;

-- Misc types
--************************************************************************** --

--************************************************************************** --
--      create_topology 
--     
--      Creates a new topology and designates the system it runs on as 
--      the target for that topology. 
--     
--      Input arguments 
--      
--      topology_name   -   The new topology name. Maximum name size is 128.
--************************************************************************** --
        PROCEDURE create_topology(topology_name VARCHAR2);

 
--************************************************************************** --
--      drop_topology 
--     
--      Deletes a topology and all the associated registrations and links.
--     
--      Input arguments 
--      
--      topology_name   -   The name of the topology to delete.
--************************************************************************** --
        PROCEDURE drop_topology(topology_name VARCHAR2);


--************************************************************************** --
--      register_node
--     
--      Registers a node with a given topology. Nodes are identified by the 
--      "node_name", which can be any string, with the constraint that it 
--      must be unique for a given topology and node type (The tuple
--      [topology_name, node_name] must be unique). Maximum size
--      of the node name is 128.
--      It also takes as input the names of the two dblinks, 
--      to and from the target. The procedure returns the auto-generated 
--      node id for the new registration (which is also stored in 
--      umf$_registration). 
--     
--      Input arguments 
--      
--      topology_name        -   Existing topology name.
--      node_name            -   The name with which a node will be registered.
--                               Maximum size is 128.
--      dblink_to_node       -   The name of the database link from the 
--                               target to the node.          
--      dblink_from_node     -   Database link from the node to the target.
--      as_source            -   String that can take only two values:
--                               'TRUE' or 'FALSE'. 'TRUE' if the node is a 
--                               source and 'FALSE' otherwise.
--      as_candidate_target  -   String that can take only two values:
--                               'TRUE' or 'FALSE'. 'TRUE' if the node is a 
--                               candidate target and 'FALSE' otherwise. 
--      RETURN VALUE
--      registered_node_id   - The numerical ID for the registered node.
--************************************************************************** --
        FUNCTION register_node (
                topology_name                   VARCHAR2,
                node_name                       VARCHAR2,
                dblink_to_node                  VARCHAR2 DEFAULT NULL,
                dblink_from_node                VARCHAR2 DEFAULT NULL,
                as_source                       VARCHAR2 DEFAULT 'TRUE',
                as_candidate_target             VARCHAR2 DEFAULT 'FALSE'
                )
        RETURN NUMBER;

--************************************************************************** --
--      register_node (Does not return the registered node ID.
--     
--      Registers a node with a given topology. Nodes are identified by the 
--      "node_name", which can be any string, with the constraint that it 
--      must be unique for a given topology and node type (The tuple
--      [topology_name, node_name] must be unique). Maximum size
--      of the node name is 128.
--      It also takes as input the names of the two dblinks, 
--      to and from the target. 
--      The procedure simply invokes the dbms_umf.register_node function 
--      without returning the node_id.
-- 
--     
--      Input arguments 
--      
--      topology_name        -   Existing topology name.
--      node_name            -   The name with which a node will be registered.
--                               Maximum size is 128.
--      dblink_to_node       -   The name of the database link from the 
--                               target to the node.          
--      dblink_from_node     -   Database link from the node to the target.
--      as_source            -   String that can take only two values:
--                               'TRUE' or 'FALSE'. 'TRUE' if the node is a 
--                               source and 'FALSE' otherwise.
--      as_candidate_target  -   String that can take only two values:
--                               'TRUE' or 'FALSE'. 'TRUE' if the node is a 
--                               candidate target and 'FALSE' otherwise. 
--************************************************************************** --
        PROCEDURE register_node (
                topology_name                   VARCHAR2,
                node_name                       VARCHAR2,
                dblink_to_node                  VARCHAR2 DEFAULT NULL,
                dblink_from_node                VARCHAR2 DEFAULT NULL,
                as_source                       VARCHAR2 DEFAULT 'TRUE',
                as_candidate_target             VARCHAR2 DEFAULT 'FALSE'
                );

--************************************************************************** --
--      register_node (Returning the registered node UMF Node ID).
--     
--      Registers a node with a given topology. Nodes are identified by the 
--      "node_name", which can be any string, with the constraint that it 
--      must be unique for a given topology and node type (The tuple
--      [topology_name, node_name] must be unique). Maximum size
--      of the node name is 128.
--      It also takes as input the names of the two dblinks, 
--      to and from the target. 
--      The procedure simply invokes the dbms_umf.register_node function 
--      without returning the node_id.
-- 
--     
--      Input arguments 
--      
--      topology_name        -   Existing topology name.
--      node_name            -   The name with which a node will be registered.
--                               Maximum size is 128.
--      dblink_to_node       -   The name of the database link from the 
--                               target to the node.          
--      dblink_from_node     -   Database link from the node to the target.
--      as_source            -   String that can take only two values:
--                               'TRUE' or 'FALSE'. 'TRUE' if the node is a 
--                               source and 'FALSE' otherwise.
--      as_candidate_target  -   String that can take only two values:
--                               'TRUE' or 'FALSE'. 'TRUE' if the node is a 
--                               candidate target and 'FALSE' otherwise. 
--      node_id              -   (OUT) The UMF Node ID for the registered node.
--************************************************************************** --
        PROCEDURE register_node (
                topology_name                   VARCHAR2,
                node_name                       VARCHAR2,
                dblink_to_node                  VARCHAR2 DEFAULT NULL,
                dblink_from_node                VARCHAR2 DEFAULT NULL,
                as_source                       VARCHAR2 DEFAULT 'TRUE',
                as_candidate_target             VARCHAR2 DEFAULT 'FALSE',
                node_id                     OUT VARCHAR2
                );
        
--************************************************************************** --
--      unregister_node
--     
--      Removes the registration info for the node identified by the tuple 
--      [topology_name, node_name].
--
--      Input arguments 
--
--      topology_name   -       The name of the topology.
--      node_name       -       The name of the node to be un-registered.
--************************************************************************** --
        PROCEDURE unregister_node (
                topology_name                   VARCHAR2,
                node_name                       VARCHAR2);

--************************************************************************** --
--      create_link
--     
--      Create a link between two nodes, node A and B. Since links are 
--      implemented with dblinks it takes as input two dblinks, one for
--      each direction.  Maximum link name size is 128.
--
--      Input arguments 
--
--      topology_name   -       The name of the existing topology.
--      node_a_name     -       Name of existing node A. 
--      node_b_name     -       Name of existing node B. 
--      dblink_a_to_b   -       Name of database link from A to B. Maximum 
--                              name size is 128.
--      dblink_b_to_a   -       Name of dblink from B to A. Maximum name size
--                              is 128.
--************************************************************************** --
        PROCEDURE create_link(
                topology_name                   VARCHAR2,
                node_a_name                     VARCHAR2, 
                node_b_name                     VARCHAR2,
                dblink_a_to_b                   VARCHAR2,
                dblink_b_to_a                   VARCHAR2);

--************************************************************************** --
--      drop_link
--     
--      Delete the link between nodes A and B. It deletes the name of the two 
--      dblinks connecting A and B. 
--
--      Input arguments 
--
--      topology_name   -       The name of existing topology.
--      node_a_name     -       Name of existing node A. 
--      node_b_name     -       Name of existing node B.
--************************************************************************** --
        PROCEDURE drop_link(
                topology_name                   VARCHAR2,
                node_a_name                     VARCHAR2, 
                node_b_name                     VARCHAR2);

--************************************************************************** --
--      enable_service
--     
--      Enables a service (e.g. AWR) on the given node.
--
--      Input arguments 
--
--      topology_name   -       The name of the topology.
--      node_name       -       Node name.
--      service_type    -       Numeric constant identifying the service
--                              (e.g. UMF_SERVICE_TYPE_AWR)
--************************************************************************** --
        PROCEDURE enable_service(
                topology_name                   VARCHAR2,
                node_name                       VARCHAR2,
                service_type                     NUMBER);


--************************************************************************** --
--      configure_node
--     
--     Configure a node so that it can participate in a UMF topology,
--     by setting a node name.If input is NULL it will be set to 
--     db_unique_name or db_name, whichever is available.
--
--     It also allows pre-setting the name of the database link to the target,
--     before registration. During the registration, that value must agree 
--     with the value set by the target. Pre-setting the dblink locally 
--     protects against invalid registration requests by the target.
--
--     PARAMETERS
--      node_name       	-       Node name.
--      dblink_to_target        - 
--************************************************************************** --
	 PROCEDURE configure_node(
	           node_name	    VARCHAR2 DEFAULT NULL,
                   dblink_to_target VARCHAR2 DEFAULT NULL);


--************************************************************************** --
--      unconfigure_node
--      Clear a node's internal configuration.
--
--      PARAMETERS
--      NONE.
--************************************************************************** --
	PROCEDURE unconfigure_node;


--************************************************************************** --
--      get_topology_name_local
--      Returns the name of the active UMF topology.
--      The local node must be registered with a topology. Otherwise a
--      NULL result will be returned.
--************************************************************************** --
        FUNCTION get_topology_name_local
        RETURN VARCHAR2;

--************************************************************************** --
--      get_node_name_local
--      Returns the UMF node name. The UMF node name is assigned by the 
--      dbmsumf.configure_node procedure call
--      NONE.
--************************************************************************** --
        FUNCTION get_node_name_local RETURN VARCHAR2;


--************************************************************************** --
--      get_node_id_local
--      Returns the UMF node ID for the local node.
--      The local node must be registered with a topology. If the local node
--      is not registered, a NULL result will  be returned.
--      NONE.
--************************************************************************** --
        FUNCTION get_node_id_local(topology_name IN VARCHAR2 DEFAULT NULL)
        RETURN NUMBER;


--  ************************************************************************ --
--  query_node_info
-- 
--  Retrieves registration info for a node. Given the node_name, it returns
--  the topology name and the node ID.
--  ************************************************************************ --
        PROCEDURE query_node_info(topology_name IN  VARCHAR2,
                                  node_name     IN  VARCHAR2,
                                  node_id       OUT NUMBER);

        PROCEDURE query_node_info(node_id       IN  NUMBER,
                                  topology_name OUT VARCHAR2,
                                  node_name     OUT VARCHAR2);

--  ************************************************************************ --
--  query_link_info
-- 
--  Retrieves the name of the database link that connects two nodes. 
--  The input is the topology name and the node ids for the two endpints. 
--  The output is the name of the database link. If the link does not exist 
--  a NULL value will be returned. The code will query the local XML data on 
--  the node. 
--  ************************************************************************ --
        PROCEDURE query_link_info(topology_name     IN  VARCHAR2,
                                  from_node_id      IN  NUMBER,
                                  to_node_id        IN  NUMBER,
                                  link_name         OUT VARCHAR2);

--  ************************************************************************ --
--  get_target_id
-- 
--  Retrieves the target ID of the given topology.
--  The input is the topology name. The output is the ID of the target, queried
--  based on the local XML data on the local node.
--  ************************************************************************ --
        FUNCTION get_target_id(topology_name     IN  VARCHAR2)
        RETURN   NUMBER;

--  ************************************************************************ --
--  switch_destination
-- 
--  Designate the node where the command is executed as the new UMF destination
--  of the given topology. The procedure fails if the designated node is not 
--  capable of performing the target role such as (1) the target is a 
--  read-only  database; (2) it lacks links to some source nodes; (3) the node
--  cannot get latest information from the old targets.
--  Users can turn on force_switch if they want to force switching destination
--  and ignores some errors such as in (2) and (3).
--
--  ************************************************************************ --
        PROCEDURE switch_destination(topology_name  IN  VARCHAR2,
                                     force_switch   IN  BOOLEAN DEFAULT TRUE); 

END dbms_umf;
/

SHOW ERRORS;
/

CREATE OR REPLACE PUBLIC SYNONYM dbms_umf
FOR sys.dbms_umf
/

GRANT EXECUTE ON dbms_umf TO DBA
/

-- pl/sql callout library for UMF
CREATE OR REPLACE LIBRARY DBMS_UMF_LIB TRUSTED AS STATIC;
/

@?/rdbms/admin/sqlsessend.sql


