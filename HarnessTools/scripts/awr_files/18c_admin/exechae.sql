Rem
Rem $Header: rdbms/admin/exechae.sql /main/3 2014/02/20 12:45:37 surman Exp $
Rem
Rem exechae.sql
Rem
Rem Copyright (c) 2006, 2014, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      exechae.sql - EXECute HA Event setup
Rem
Rem    DESCRIPTION
Rem      pl/sql blocks for HA events (FAN alerts)
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/exechae.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/exechae.sql
Rem SQL_PHASE: EXECHAE
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catpexec.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    kneel       06/06/06 - removing auto-inserted SET commands 
Rem    kneel       06/01/06 - subscriber creation for HA Events (FAN alerts) 
Rem    kneel       06/01/06 - subscriber creation for HA Events (FAN alerts) 
Rem    kneel       06/01/06 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql



Rem Define a transformation to be used for the notification subscriber
begin
  sys.dbms_transform.create_transformation(
        schema => 'SYS', name => 'haen_txfm_obj',
        from_schema => 'SYS', from_type => 'ALERT_TYPE',
        to_SCHEMA => 'SYS', to_type => 'VARCHAR2',
        transformation => 'SYS.haen_txfm_text(source.user_data)');
EXCEPTION
  when others then
    if sqlcode = -24184 then NULL;
    else raise;
    end if;
end;
/


Rem Define the HAE_SUB subscriber for the alert_que
  
declare  
subscriber sys.aq$_agent; 
begin 
subscriber := sys.aq$_agent('HAE_SUB',null,null); 
dbms_aqadm_sys.add_subscriber(queue_name => 'SYS.ALERT_QUE',
                              subscriber => subscriber,
                              rule => 'tab.user_data.MESSAGE_LEVEL <> '
                                      || sys.dbms_server_alert.level_clear ||
                                      ' AND tab.user_data.MESSAGE_GROUP = ' ||
                                      '''High Availability''',
                              transformation => 'SYS.haen_txfm_obj',
                              properties =>
                                dbms_aqadm_sys.NOTIFICATION_SUBSCRIBER
                                + dbms_aqadm_sys.PUBLIC_SUBSCRIBER); 
EXCEPTION
  when others then
    if sqlcode = -24034 then NULL;
    else raise;
    end if;
end;
/

@?/rdbms/admin/sqlsessend.sql
