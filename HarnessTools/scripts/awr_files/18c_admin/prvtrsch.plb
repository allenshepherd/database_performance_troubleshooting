SET FEEDBACK 1
SET NUMWIDTH 10
SET LINESIZE 80
SET TRIMSPOOL ON
SET TAB OFF
SET PAGESIZE 100
SET SERVEROUTPUT ON;
WHENEVER SQLERROR EXIT;
begin
  dbms_isched_agent.agent_install_pre_steps;
end;
/
WHENEVER SQLERROR CONTINUE;
SET SERVEROUTPUT OFF;
@?/rdbms/admin/catrsa.sql
@?/rdbms/admin/dbmsrsa.plb
@?/rdbms/admin/prvtrsa.plb
@?/rdbms/admin/execrsa.plb
begin
  dbms_isched_agent.agent_install_post_steps;
end;
/
