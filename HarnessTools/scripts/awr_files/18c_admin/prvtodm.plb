@@?/rdbms/admin/sqlsessstart.sql
PROMPT Model Util Package, qgen
@@prvtdmmi.plb
PROMPT DBMS_DATA_MINING_TRANSFORM
@@prvtdmxf.plb
PROMPT Meta Code package (adaptor,sys,sec,exp code,superh/b)
@@prvtdmsu.plb
PROMPT KM,SVM Trusted code
@@prvtdmtf.plb
PROMPT R Model definition code
@@prvtrqtf.plb
PROMPT DBMS DM Internal, DBMS DM
@@prvtdm.plb
PROMPT Predictive code 
@@prvtdmpa.plb
CREATE OR REPLACE PUBLIC SYNONYM odm_model_util
  FOR sys.odm_model_util
/
CREATE OR REPLACE PUBLIC SYNONYM odm_util
  FOR sys.odm_util
/
GRANT EXECUTE ON odm_util TO PUBLIC
/
@?/rdbms/admin/sqlsessend.sql
