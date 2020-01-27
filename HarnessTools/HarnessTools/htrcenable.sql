exec dbms_monitor.serv_mod_act_trace_enable -
(service_name => '&service_name' , -
 module_name => '&module_name', -
 action_name => '&action_name', -
 waits => TRUE, -
 binds => TRUE );