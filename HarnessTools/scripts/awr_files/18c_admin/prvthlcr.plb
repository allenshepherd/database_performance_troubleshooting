@@?/rdbms/admin/sqlsessstart.sql
CREATE OR REPLACE TYPE lcr$_procedure_parameter FORCE AS OBJECT (
  name           VARCHAR2(4000),  -- parameter name
  data           sys.AnyData      -- parameter value
);
/
CREATE OR REPLACE TYPE lcr$_parameter_list FORCE AS TABLE 
  OF lcr$_procedure_parameter;
/
CREATE OR REPLACE LIBRARY lcr_prc_lib wrapped 
a000000
1
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
16
26 59
mfrs049O4TCxSMWVNPSHjdEZtHUwg04I9Z7AdBjDhaHRGJYW8kpy+lkJ572esstSMsy4dCvn
y1J0CPXJpqalqJl1

/
CREATE OR REPLACE TYPE LCR$_PROCEDURE_RECORD 
OID '00000000000000000000000000020015' 
AS OPAQUE VARYING (*)
USING LIBRARY lcr_prc_lib
( 
   MAP MEMBER FUNCTION map_lcr RETURN NUMBER,
  MEMBER FUNCTION  get_source_database_name RETURN VARCHAR2,
   MEMBER FUNCTION  get_scn                  RETURN NUMBER,
  MEMBER FUNCTION  get_transaction_id       RETURN VARCHAR2,
   MEMBER FUNCTION  get_publication          RETURN VARCHAR2,
   MEMBER FUNCTION  get_package_owner        RETURN VARCHAR2,
   MEMBER FUNCTION  get_package_name         RETURN VARCHAR2,
   MEMBER FUNCTION  get_procedure_name       RETURN VARCHAR2,
   MEMBER FUNCTION  get_parameters           RETURN SYS.LCR$_PARAMETER_LIST,
   MEMBER FUNCTION  get_compatible           RETURN NUMBER,
   MEMBER FUNCTION get_source_time RETURN DATE,
   MEMBER FUNCTION get_thread_number RETURN NUMBER,
   MEMBER FUNCTION get_position RETURN RAW,
   MEMBER FUNCTION  get_tag                  RETURN RAW,
   MEMBER FUNCTION is_null_tag  RETURN VARCHAR2,
   MEMBER FUNCTION  get_root_name            RETURN VARCHAR2,
   MEMBER FUNCTION  get_logon_user           RETURN VARCHAR2,
   MEMBER FUNCTION  get_current_user         RETURN VARCHAR2,
   MEMBER FUNCTION  get_default_user         RETURN VARCHAR2
)
/
GRANT EXECUTE ON LCR$_PROCEDURE_RECORD TO PUBLIC WITH GRANT OPTION;
CREATE OR REPLACE PACKAGE dbms_streams_lcr_int wrapped 
a000000
1
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
9
175 12c
IzknYwYNFGHM74ZKqH+w/CdVakkwgxDQACgVZ+dAkPjVBPbgdnHa7pT2C+2CdrCfRc4qdU3W
krXvXOugy4daqR1BHysRb1Qvdv6xgM96u7CQktnuHHLESXDIQljWvUeRbDmudH23Ng4Nk0tg
8hevV5gbp1NMK8xx2HSwq4sWj/YkPGn8lLI3oeEF/iyDo9l1c8E+Te4+yj3710UDABnqjHL4
LW8PUFs7ZVHEY6MdEX1V6jNvpO0StHng7+spk+8TrZsaVdTDSOxskceFsAws7XxrkmBkoPGy
h5bZTAQ=

/
CREATE OR REPLACE PUBLIC SYNONYM dbms_streams_lcr_int FOR 
sys.dbms_streams_lcr_int
/
GRANT EXECUTE ON sys.dbms_streams_lcr_int TO execute_catalog_role
/
@?/rdbms/admin/sqlsessend.sql
