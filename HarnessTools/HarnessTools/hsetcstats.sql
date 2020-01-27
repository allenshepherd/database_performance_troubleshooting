set echo off

rem $Header$
rem $Name$		hsetcstats.sql

rem Copyright (c); 2005-2011 by Hotsos Enterprises, Ltd.
rem 


set termout on verify off serveroutput on

accept htst_owner  prompt 'Enter the owner name : '
accept htst_table  prompt 'Enter the table name : '
accept htst_column prompt 'Enter the column name: '

prompt
prompt For the following prompts, no entry will leave values unchanged.
prompt To set NDV, density or # nulls to 0 (zero), enter -1.
prompt
accept htst_ndv     number prompt 'Enter the desired NDV            : '
accept htst_density number prompt 'Enter the desired density        : '
accept htst_nulls   number prompt 'Enter the desired number of nulls: '
accept htst_low            prompt 'Enter the desired low value      : '
accept htst_high           prompt 'Enter the desired high value     : '

declare

	v_table		all_tables.table_name%type := UPPER('&htst_table') ;
	v_owner		all_tables.owner%type := UPPER('&htst_owner') ;
	v_stattab	varchar2(30) := null ;
	v_column	all_tab_columns.column_name%type := UPPER('&htst_column') ;

	v_datatype	all_tab_columns.data_type%type ;
	
	v_minval	VARCHAR2(50) := '&htst_low';
	v_maxval	VARCHAR2(50) := '&htst_high';
	vn_minval	number;
	vn_maxval	number;
	vd_minval	date;
	vd_maxval	date;

	v_distcnt	NUMBER := &htst_ndv;
	v_density	NUMBER := &htst_density;
	v_nullcnt	NUMBER := &htst_nulls;
	v_avgclen	NUMBER ;


	v_statrec	dbms_stats.StatRec;
	v_novals	dbms_stats.numarray;
	v_svals		dbms_stats.chararray;
	v_dvals		dbms_stats.datearray;

	v_nomin		char(1) := 'N' ;
	v_nomax		char(1) := 'N' ;
	v_nondv		char(1) := 'N' ;
	v_nodens	char(1) := 'N' ;
	v_nonull	char(1) := 'N' ;



begin
	if v_distcnt = -1 then 
		v_distcnt := 0 ;
	elsif v_distcnt = 0 then
		v_distcnt := -1 ;
	elsif v_distcnt is null then
		v_distcnt := -1 ;
	end if ;

	if v_density = -1 then 
		v_density := 0 ;
	elsif v_density = 0 then
		v_density := -1 ;
	elsif v_density is null then
		v_density := -1 ;
	end if ;

	if v_nullcnt = -1 then 
		v_nullcnt := 0 ;
	elsif v_nullcnt = 0 then
		v_nullcnt := -1 ;
	elsif v_nullcnt is null then
		v_nullcnt := -1 ;
	end if ;

	if v_minval = '-1' or v_minval is null then
	   v_nomin := 'Y' ;
	end if;
	
	if v_maxval = '-1' or v_maxval is null then
	   v_nomax := 'Y' ;
	end if;
	
	if v_distcnt = -1 or v_distcnt is null  then
	   v_nondv := 'Y' ;
	end if;
	
	if v_density = -1 or v_density is null  then
	   v_nodens := 'Y' ;
	end if;

	if v_nullcnt = -1 or v_nullcnt is null  then
	   v_nonull := 'Y' ;
	end if;

	select trim(data_type)
	  into v_datatype
	  from all_tab_columns
	 where column_name = v_column
	   and owner = v_owner
	   and table_name = v_table ;

	if v_nomin = 'N' and v_nomax = 'N' then
		if v_datatype = 'NUMBER' then
		   vn_minval := to_number(v_minval) ;
		   vn_maxval := to_number(v_maxval) ;
		   v_novals := dbms_stats.numarray(vn_minval, vn_maxval);
		   v_statrec.epc := 2 ;
		   v_statrec.bkvals := null ;
		   
		   dbms_stats.prepare_column_values (v_statrec, v_novals) ;
		elsif v_datatype = 'CHAR' then
		   v_minval := rpad(v_minval,15);
		   v_maxval := rpad(v_maxval,15);
		   v_svals := dbms_stats.chararray(v_minval, v_maxval);
		   v_statrec.epc := 2 ;
		   v_statrec.bkvals := null ;
		   
		   dbms_stats.prepare_column_values (v_statrec, v_svals) ;
		elsif v_datatype = 'DATE' then
		   vd_minval := to_date(v_minval,'mm/dd/yyyy') ;
		   vd_maxval := to_date(v_maxval,'mm/dd/yyyy') ;
		   v_dvals := dbms_stats.datearray(vd_minval, vd_maxval);
		   v_statrec.epc := 2 ;
		   v_statrec.bkvals := null ;
		   
		   dbms_stats.prepare_column_values (v_statrec, v_dvals) ;		   
		
		elsif v_datatype = 'VARCHAR2' then
		   v_minval := v_minval;
		   v_maxval := v_maxval;
		   v_svals := dbms_stats.chararray(v_minval, v_maxval);
		   v_statrec.epc := 2 ;
		   v_statrec.bkvals := null ;
		   
		   dbms_stats.prepare_column_values (v_statrec, v_svals) ;		
		end if ;
	
		dbms_stats.set_column_stats(v_owner, v_table, v_column, srec => v_statrec,
		   	stattab=>v_stattab, no_invalidate=>FALSE) ;
	end if;

	if v_nondv = 'N' then
		dbms_stats.set_column_stats(v_owner, v_table, v_column, distcnt => v_distcnt,
			stattab=>v_stattab, no_invalidate=>FALSE) ;
	end if ;
	
	if v_nodens = 'N' then
		dbms_stats.set_column_stats(v_owner, v_table, v_column, density => v_density,
			stattab=>v_stattab, no_invalidate=>FALSE) ;
	end if ;

	if v_nonull = 'N' then
		dbms_stats.set_column_stats(v_owner, v_table, v_column, nullcnt => v_nullcnt,
			stattab=>v_stattab, no_invalidate=>FALSE) ;
	end if ;


	dbms_output.put_line ('Request Complete.') ;

	dbms_output.put_line ('------------------------------------') ;
	dbms_stats.get_column_stats (v_owner, v_table, colname => v_column, 
			stattab => v_stattab, distcnt => v_distcnt, density => v_density,
			nullcnt => v_nullcnt, srec => v_statrec, avgclen => v_avgclen );
	
	v_minval := boil_raw(v_statrec.minval,v_datatype);
	v_maxval := boil_raw(v_statrec.maxval,v_datatype);

	dbms_output.put_line ('Column name : ' || v_column) ;
	dbms_output.put_line ('NDV         : ' || v_distcnt) ;
	dbms_output.put_line ('Density     : ' || v_density) ;
	dbms_output.put_line ('Nulls       : ' || v_nullcnt) ;
	dbms_output.put_line ('Lo Value    : ' || v_minval ) ;
	dbms_output.put_line ('Hi Value    : ' || v_maxval ) ;
	dbms_output.put_line ('-----------------------------------------');
exception
	when others then
		dbms_output.put_line ('Cannot modify statistics.  Check request and try again.') ;

end ;
/

undefine  htst_owner
undefine  htst_table
undefine  htst_column
undefine  htst_ndv
undefine  htst_density
undefine  htst_nulls
undefine  htst_low
undefine  htst_high

@henv
