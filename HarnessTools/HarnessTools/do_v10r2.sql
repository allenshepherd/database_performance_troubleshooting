rem $Header$
rem $Name$

rem Copyright (c); 2005 - 2011 by Hotsos Enterprises, Ltd.
rem 

rem Called by do.sql for Oracle v10.2 and v11
rem


delete from hscenario_plan_table
 where hscenario_id = &htst_scenario_id; 
 
declare
	CURSOR plan_table_cur IS
	SELECT * 
	  FROM PLAN_TABLE
	 WHERE statement_id = '&htst_stmt_id';

begin
    FOR c_rec IN plan_table_cur LOOP
        insert into hscenario_plan_table values (
        &htst_scenario_id,
		c_rec.statement_id,
		c_rec.plan_id,
		c_rec.timestamp,
		c_rec.remarks,
		c_rec.operation,
		c_rec.options,
		c_rec.object_node,
		c_rec.object_owner,
		c_rec.object_name,
		c_rec.object_alias,
		c_rec.object_instance,
		c_rec.object_type,
		c_rec.optimizer,
		c_rec.search_columns,
		c_rec.id,
		c_rec.parent_id,
		c_rec.depth,
		c_rec.position,
		c_rec.cost,
		c_rec.cardinality,
		c_rec.bytes,
		c_rec.other_tag,
		c_rec.partition_start,
	    c_rec.partition_stop,
	   	c_rec.partition_id,
		c_rec.other,
		c_rec.distribution,
		c_rec.cpu_cost,
		c_rec.io_cost,
		c_rec.temp_space,
	    c_rec.access_predicates,
	    c_rec.filter_predicates,
		c_rec.projection,
		c_rec.time,
		c_rec.qblock_name,
		c_rec.other_xml ) ;
    END LOOP;
    
    commit ;
end;
/

delete from hscenario_plans
 where hscenario_id = &htst_scenario_id;

insert into  hscenario_plans 
select &htst_scenario_id , hseq.nextval , a.* 
  from table(dbms_xplan.display('PLAN_TABLE','&htst_stmt_id','TYPICAL')) a;

commit ;
