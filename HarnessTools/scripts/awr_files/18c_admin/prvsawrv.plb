@@?/rdbms/admin/sqlsessstart.sql
CREATE OR REPLACE TYPE prvt_awrv_metadata FORCE AUTHID CURRENT_USER AS OBJECT (
   m_dbid              number,
   m_begin_snap        number,
   m_end_snap          number,
   m_inst_id_low       number,
   m_inst_id_high      number,
   m_inst_id_list      awrrpt_instance_list_type,
   m_min_time          timestamp,
   m_max_time          timestamp,
   m_db_version        varchar2(17),
   m_inst_detail       number,       -- display information per instance 
   m_cont_detail       number,       -- display information per container 
   m_member_id         number,       -- specific instance in RAC
   mp_member_id        number,
   mp_inst_id_low      number,
   mp_inst_id_high     number,
   m_db_type            varchar2(64),
   m_awr_view_prefix    varchar2(8), 
   m_resolved_db_type   varchar2(8),
   FINAL INSTANTIABLE CONSTRUCTOR FUNCTION
     prvt_awrv_metadata(p_start_time     IN date     default null,
                        p_end_time       IN date     default null,
                        p_instance_list  IN varchar2 default null,
                        p_dbid           IN number   default null,
                        p_member_id      IN number   default null,
                        p_inst_detail    IN number   default 0,
                        p_default_range  IN number   default 1,
                        p_con_detail     IN number   default 0)
     RETURN SELF AS RESULT,
   MEMBER FUNCTION  to_xml RETURN XMLTYPE,
   MEMBER FUNCTION  get_inst_clause(p_table_name IN VARCHAR) RETURN VARCHAR,
   MEMBER FUNCTION  isDBLocal(p_dbid IN number) RETURN BOOLEAN,
   MEMBER PROCEDURE set_member(member_id IN number),
   MEMBER PROCEDURE reset_member,
   MEMBER PROCEDURE clear_member
   )
   FINAL INSTANTIABLE;
/
show errors;
GRANT EXECUTE ON prvt_awrv_metadata TO PUBLIC;
DECLARE
  obj_not_found EXCEPTION;
  PRAGMA EXCEPTION_INIT(obj_not_found, -4043);
BEGIN  
  BEGIN
    execute immediate 'DROP TYPE prvt_awrv_mapTab';
    EXCEPTION WHEN obj_not_found THEN NULL;    
  END;
  BEGIN
    execute immediate 'DROP TYPE prvt_awrv_map';
    EXCEPTION WHEN obj_not_found THEN NULL;
  END;
END;
/
CREATE OR REPLACE TYPE prvt_awrv_map wrapped 
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
d
12a ef
yHWzL2JQahyyniW1fvpEPdugoUkwg3n/154VfHRbuHIi6Uqkio/Gs14FRDuDVIPSjyaK+zkL
hc8Q2iTIex1syLWWGs8y53N8GQkSLNR3DQCFhVvrqUoZ71IY+wCFph8yotcMpvcsTU2uhT6Y
IMygnhAAlTca1Wpm345U8dTS7HNVn+zBBeDt5Xg9tiowyTqMyX1zLgIShPTwlXoToyIgkLRv
5yY6yNMBXs1vKKsi6Wc=

/
GRANT EXECUTE ON prvt_awrv_map TO PUBLIC;
CREATE OR REPLACE TYPE prvt_awrv_mapTab AS TABLE OF prvt_awrv_map;
/
show errors; 
GRANT EXECUTE ON prvt_awrv_mapTab TO PUBLIC;
DECLARE
  obj_not_found EXCEPTION;
  PRAGMA EXCEPTION_INIT(obj_not_found, -4043);
BEGIN  
  BEGIN
    execute immediate 'DROP TYPE prvt_awrv_instTab';
    EXCEPTION WHEN obj_not_found THEN NULL;    
  END;
  BEGIN
    execute immediate 'DROP TYPE prvt_awrv_inst';
    EXCEPTION WHEN obj_not_found THEN NULL;
  END;
END;
/
CREATE OR REPLACE TYPE prvt_awrv_inst wrapped 
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
d
7a aa
KHFKtCEh7JQvfeAKhRWKEQ/uU4Ewg5n0dLhcFhbF1fSuVpbFbXJH1dHMuHSyCKX1zLjLsp7A
gZn0KLKfsgm4dCulv5vAMsvuJY8JaaXSmcv0W8U1+z9rvNziNXtp3oAkF7EwJIAP6nX1dQvI
AwcLyPdALfcbnOgqHaZ6uBzw

/
GRANT EXECUTE ON prvt_awrv_inst TO PUBLIC;
CREATE OR REPLACE TYPE prvt_awrv_instTab AS TABLE OF prvt_awrv_inst;
/
show errors
GRANT EXECUTE ON prvt_awrv_instTab TO PUBLIC;
CREATE OR REPLACE PACKAGE prvt_awr_viewer wrapped 
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
2b60 87d
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

/
show errors;
create or replace type prvt_awrv_varchar64Tab as table of varchar2(64);
/
GRANT EXECUTE ON prvt_awrv_varchar64Tab TO PUBLIC;
@?/rdbms/admin/sqlsessend.sql
