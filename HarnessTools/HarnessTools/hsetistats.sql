set echo off

rem $Header$
rem $Name$		hsetistats.sql

rem Copyright (c); 2005-2011 by Hotsos Enterprises, Ltd.
rem 


set termout on verify off serveroutput on

accept htst_owner   prompt 'Enter the owner name: '
accept htst_index   prompt 'Enter the index name: '

prompt
prompt For the following prompts, no entry will leave values unchanged.
prompt To set a value to 0 (zero), enter -1.
prompt

accept htst_rows   number prompt 'Number of index entries: '
accept htst_ilevel number prompt 'Index height (blevel)  : '
accept htst_blks   number prompt 'Number of leaf blocks  : '
accept htst_ndv    number prompt 'Number of distinct keys: '
accept htst_lblks  number prompt 'Avg leaf blocks per key: '
accept htst_dblks  number prompt 'Avg data blocks per key: '
accept htst_cluf   number prompt 'Clustering factor      : '

declare

	v_owner		all_tables.owner%type := UPPER('&htst_owner') ;
	v_stattab	varchar2(30) := null ;
	v_index		all_indexes.index_name%type := UPPER('&htst_index') ;
	
	v_numirows	number := &htst_rows;
	v_numlblks	number := &htst_blks;
	v_numdist	number := &htst_ndv;
	v_avglblk	number := &htst_lblks;
	v_avgdblk	number := &htst_dblks;
	v_clstfct	number := &htst_cluf;
	v_indlevel	number := &htst_ilevel;


begin

	if v_numirows = -1 then 
		v_numirows := 0 ;
	elsif v_numirows = 0 then
		v_numirows := -1 ;
	elsif v_numirows is null then
		v_numirows := -1 ;
	end if ;

	if v_numlblks = -1 then 
		v_numlblks := 0 ;
	elsif v_numlblks = 0 then
		v_numlblks := -1 ;
	elsif v_numlblks is null then
		v_numlblks := -1 ;
	end if ;

	if v_numdist = -1 then 
		v_numdist := 0 ;
	elsif v_numdist = 0 then
		v_numdist := -1 ;
	elsif v_numdist is null then
		v_numdist := -1 ;
	end if ;

	if v_avglblk = -1 then 
		v_avglblk := 0 ;
	elsif v_avglblk = 0 then
		v_avglblk := -1 ;
	elsif v_avglblk is null then
		v_avglblk := -1 ;
	end if ;

	if v_avgdblk = -1 then 
		v_avgdblk := 0 ;
	elsif v_avgdblk = 0 then
		v_avgdblk := -1 ;
	elsif v_avgdblk is null then
		v_avgdblk := -1 ;
	end if ;

	if v_clstfct = -1 then 
		v_clstfct := 0 ;
	elsif v_clstfct = 0 then
		v_clstfct := -1 ;
	elsif v_clstfct is null then
		v_clstfct := -1 ;
	end if ;

	if v_indlevel = -1 then 
		v_indlevel := 0 ;
	elsif v_indlevel = 0 then
		v_indlevel := -1 ;
	elsif v_indlevel is null then
		v_indlevel := -1 ;
	end if ;

	if v_numirows >= 0 then
	    dbms_stats.set_index_stats(v_owner, v_index, stattab=>v_stattab, no_invalidate=>FALSE,
		numrows => v_numirows ) ;
	end if ;

	if v_numlblks >= 0 then
		dbms_stats.set_index_stats(v_owner, v_index, stattab=>v_stattab, no_invalidate=>FALSE,
		numlblks => v_numlblks ) ;
	end if ;

	if v_numdist >= 0 then
		dbms_stats.set_index_stats(v_owner, v_index, stattab=>v_stattab, no_invalidate=>FALSE,
		numdist => v_numdist ) ;
	end if ;	
	
	if v_avglblk >= 0 then
		dbms_stats.set_index_stats(v_owner, v_index, stattab=>v_stattab, no_invalidate=>FALSE,
		avglblk => v_avglblk ) ;
	end if ;

	if v_avgdblk >= 0 then
		dbms_stats.set_index_stats(v_owner, v_index, stattab=>v_stattab, no_invalidate=>FALSE,
		avgdblk => v_avgdblk ) ;
	end if ;
	
	if v_clstfct >= 0 then
		dbms_stats.set_index_stats(v_owner, v_index, stattab=>v_stattab, no_invalidate=>FALSE,
		clstfct => v_clstfct ) ;
	end if ;
	
	if v_indlevel >= 0 then
		dbms_stats.set_index_stats(v_owner, v_index, stattab=>v_stattab, no_invalidate=>FALSE,
		indlevel => v_indlevel ) ;
	end if ;
			
	dbms_output.put_line ('Request Complete.') ;
	
	dbms_stats.get_index_stats (v_owner, v_index, 
			stattab => v_stattab, numrows => v_numirows, numlblks => v_numlblks,
			numdist => v_numdist, avglblk => v_avglblk, avgdblk => v_avgdblk,
			clstfct => v_clstfct, indlevel => v_indlevel );

	dbms_output.put_line ('-----------------------------------------');	
	dbms_output.put_line ('Index name    : ' || v_index) ;
	dbms_output.put_line ('Rows          : ' || v_numirows) ;
	dbms_output.put_line ('Levels        : ' || v_indlevel ) ;
	dbms_output.put_line ('Leaf Blocks   : ' || v_numlblks) ;
	dbms_output.put_line ('Distinct Keys : ' || v_numdist) ;
	dbms_output.put_line ('Avg LB/Key    : ' || v_avglblk ) ;
	dbms_output.put_line ('Avg DB/Key    : ' || v_avgdblk ) ;
	dbms_output.put_line ('Clust. Factor : ' || v_clstfct ) ;
	dbms_output.put_line ('-----------------------------------------');	

exception 
	when others then
	   	dbms_output.put_line (sqlerrm) ;
		dbms_output.put_line ('Cannot modify statistics.  Check request and try again.') ;

	
end ;
/

clear columns
undefine htst_owner   
undefine htst_index   
undefine htst_rows   
undefine htst_ilevel 
undefine htst_blks   
undefine htst_ndv    
undefine htst_lblks  
undefine htst_dblks  
undefine htst_cluf 

@henv
