drop procedure load_trace ;
create or replace procedure load_trace ( p_scenario_id number , p_type number)
as

begin
    if p_type = 10053 then
        delete
          from hscenario_10053_line
         where hscenario_id = p_scenario_id ;

        insert into hscenario_10053_line
        select hscenario_id, id, text
          from trace_file_text
         where hscenario_id = p_scenario_id
           and trc_type = p_type
         order by id;
    end if ;

    if p_type = 10046 then
        delete
          from hscenario_10046_line
         where hscenario_id = p_scenario_id ;

        insert into hscenario_10046_line
        select hscenario_id, id, 0, text
          from trace_file_text
         where hscenario_id = p_scenario_id
           and trc_type = p_type
         order by id;
    end if ;

    commit ;
end ;
/
show errors
