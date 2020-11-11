@@?/rdbms/admin/sqlsessstart.sql
CREATE OR REPLACE PROCEDURE sys.scheduler$ntfy_svc_metrics wrapped 
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
7
743 3d5
QchmkzgC02UHOXLWohTot6svmlYwgwLDTCATZy+Kgp0GxenhFB9sJqNc6eL1QA0QYmj37Wq9
rrDfoQVaLiwGoAlj5M4ZW3DdGulhdEGQVe04n9WOiF0q4TEPqp3tOoGGM+5dwYaxJCO1+KOa
miIiaEy7jKl11bZxr41mt5kpQxXu5/3UseAY2WAb0gai/VS6aFvByoIUXb5wWwPyvdLulHme
NU4X9sQwf69CTOKmC+bhowpi2aEr7+HqRaepFHBluGwyAn5JwU0mvaaiN0VRWtk4WbzFY+KU
1XUn8azr0yHpGi6r2NgvQFfy+T8py8FUZQWr+pnd22iRT/UslJUmwVgourcOjaLEJYBrzf3O
0XFGardGf0K+FGv0dL1DvozpkZWJQuOSXZnqE74GoUBnjSl1eJKMVL6pdVb6JmSh492qTgyX
KTnLSYiR4y6eDUS5XrKhWlg2YsjJRBFJ9vWfkpJ+f/G0oaZ6eOEaN5xmB9gO5ztS0SdNLqfy
f69D7lxQbZGs3o178r0Jg8nVjpQO4MooiQt+l4Or8559c2+Q7fCA+4D5Kpq2VivlJs92H0Wy
gVUVXDniNSjqWnhsAOT2QEY+07JUmZv85Nc6OtrqsRP23BhG66QFaRKaDQtZsaT112nl0QF7
2XhyPN6txz50xIHmEUo722/iUcZyD/H4c8SY/SBTfBSurhqAVVAbYyHHQcZvf/vuA2Noxz7A
VyeUa47aUHFdw7NC+WwBt+khj/0pViJyIVuJMt509klhF0X/gGn8KtFGTXukRb4bx+htrDh4
vMkPFUzZKIfX/+/JuL9Wgqup5qf6uH+XfMFO32o2q06LRxmbSmt/Mkj6Sia3CcBq6NVCCZco
rmgYOqrry5pRkzALnUUNjyDNP0tkGzL4a0+kB0yDVYJ2e5hfrEgKH+mYD4quG5cl/WNMIdYB
lT1Fs8CcMruAsVzi1ByuHRPBlQ/c1lP8

/
show errors;
grant execute on scheduler$ntfy_svc_metrics to public;
begin
  dbms_aqadm.create_aq_agent(agent_name => 'SCHEDULER$_LBAGT');
exception
  when others then
    if sqlcode = -24089 then null;
    else raise;
    end if;
end;
/
begin
  dbms_aqadm.enable_db_access('SCHEDULER$_LBAGT', 'SYS');
end;
/
DECLARE subscriber sys.aq$_agent;
BEGIN
  subscriber := sys.aq$_agent('SCHEDULER$_LBAGT', NULL, NULL);
  dbms_aqadm.add_subscriber(queue_name => 'SYS.SYS$SERVICE_METRICS',
    subscriber => subscriber);
EXCEPTION
  when others then
    if sqlcode = -24034 then null;
    else raise;
    end if;
END;
/
DECLARE 
  reginfo sys.aq$_reg_info;
  reglist sys.aq$_reg_info_list;
BEGIN
  reginfo := sys.aq$_reg_info('SYS.SYS$SERVICE_METRICS:"SCHEDULER$_LBAGT"', 
      dbms_aq.namespace_aq,'plsql://SYS.SCHEDULER$NTFY_SVC_METRICS',NULL);
  reglist := sys.aq$_reg_info_list(reginfo);
  dbms_aq.register ( reglist, 1 );
END;
/
@?/rdbms/admin/sqlsessend.sql
