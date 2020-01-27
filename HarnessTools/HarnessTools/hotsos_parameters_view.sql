rem This view must be created as SYS and then select permission
rem must be granted to any account wanting to use it.

SET ERRORLOGGING on IDENTIFIER HARNESS_INSTALL_HOTSOS_PARAMETERS_VIEW

drop view hotsos_parameters ;  

create or replace view hotsos_parameters as
select n.indx num, n.ksppinm name, n.ksppity type, 
 	   v.ksppstvl value, n.ksppdesc description
  from x$ksppi n , x$ksppcv v
 where n.indx = v.indx;

rem Grant select privilege to account specific accounts or public
grant select on hotsos_parameters to public;

