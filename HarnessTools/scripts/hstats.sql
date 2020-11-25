--@hboilraw

set echo off feed off
column colgrp heading 'Column Group/Expression' format a40
column numdis heading 'NDV' format 999,999,999

alter session set nls_date_format = 'dd-MON-yyyy hh24:mi:ss';

set termout on
accept htst_owner prompt 'Enter the owner name: '
accept htst_table prompt 'Enter the table name: '

set termout on lines 200

declare
  v_query varchar2(4000)  ;
  v_owner varchar2(30) := upper('&&htst_owner');
  v_table varchar2(30) := upper('&&htst_table');
  v_max_colname   number ;
  v_max_ndv       number ;
  v_max_nulls     number ;
  v_max_bkts      number ;
  v_max_smpl      number ;
  v_max_endnum    number ;
  v_max_endval    number ;
  v_max_extension number ;
  v_ct            number := 0 ;
  prev_col        varchar2(30) ;
  v_numrows       number;
  v_numblks       number;
  v_avgrlen       number ;
  v_stattab       varchar2(30) := null ;
  v_numirows      number;
  v_numlblks      number;
  v_numdist       number;
  v_avglblk       number;
  v_avgdblk       number;
  v_clstfct       number;
  v_indlevel      number;
  v_minval        VARCHAR2(50);
  v_maxval        VARCHAR2(50);
  v_distcnt       NUMBER ;
  v_density       NUMBER ;
  v_nullcnt       NUMBER ;
  v_avgclen       NUMBER ;
  v_statrec       dbms_stats.StatRec;

  -- Column stat information
  cursor col_stats is
  select a.column_name,
	 a.data_type,
         a.last_analyzed,
         a.nullable,
         a.num_distinct, a.density, a.num_nulls,
         a.num_buckets, a.avg_col_len, a.sample_size,
         case when
                trim(boil_raw(low_value,DATA_TYPE) || ', ' || boil_raw(high_value,DATA_TYPE)) = ','
              then null
              else boil_raw(low_value,DATA_TYPE) || ', ' || boil_raw(high_value,DATA_TYPE)
         end as valrange
    from all_tab_columns a
   where a.owner = v_owner
     and a.table_name = v_table order by 1 ;
     
  -- Histogram stat information
  cursor hist_stats is
  select b.column_name, b.endpoint_number, b.endpoint_value, b.endpoint_actual_value
    from all_tab_histograms b
   where b.owner = v_owner
     and b.table_name = v_table
     and (exists (select 1 from all_tab_columns
                   where num_buckets > 1
                     and owner = b.owner
                     and table_name = b.table_name
                     and column_name = b.column_name)
          or
          exists (select 1 from all_tab_histograms
                   where endpoint_number > 1
                     and owner = b.owner
                     and table_name = b.table_name
                     and column_name = b.column_name)
         )
    order by b.column_name, b.endpoint_number;

  -- Table info
  cursor tabs is
    select *
    from all_tables
    where table_name = UPPER(v_table)
    and owner = UPPER(v_owner) ;

  -- Partition info
  cursor parts is
    select *
    from all_tab_partitions
    where table_name = UPPER(v_table)
    and table_owner = UPPER(v_owner) ;

  -- Column info
  cursor cols is
    select *
    from all_tab_cols
    where table_name = UPPER(v_table)
    and owner = UPPER(v_owner) ;

  -- Index info
  cursor idxs is
    select index_name, index_type, last_analyzed, degree, partitioned, visibility, TABLESPACE_NAME, INI_TRANS, PCT_FREE, LOGGING, a.STATUS, created
    from all_indexes a, dba_objects
    where table_name = UPPER(v_table)
    and a.owner = UPPER(v_owner)
    and OBJECT_NAME=index_name
    and OBJECT_TYPE='INDEX';
  
  -- Extended stats info 
  cursor extnd_stats is
    select e.extension colgrp, t.num_distinct numdis
    from all_stat_extensions e, all_tab_col_statistics t
    where e.extension_name=t.column_name
    and e.table_name = t.table_name
    and e.owner = t.owner
    and t.table_name = UPPER(v_table)
    and t.owner = UPPER(v_owner);   
    
  cursor triggers is select trigger_name, trigger_type, triggering_event, status, action_type from all_triggers where table_name = UPPER(v_table) and table_owner = UPPER(v_owner);
  cursor synonyms is  select * from all_synonyms  where table_name = UPPER(v_table) and table_owner = UPPER(v_owner);
  cursor constraints is 
     select '   + PRIMARY CONSTRAINT  NAME : '||CONSTRAINT_NAME DESCRIPTION from all_constraints where (owner = UPPER(v_owner) and table_name = UPPER(v_table) and CONSTRAINT_TYPE='P') 
       union 
          select '     + HAS FOREIGN CONSTRAINT TO TABLE  : '|| OWNER ||'.'|| TABLE_NAME DESCRIPTION from all_constraints where CONSTRAINT_NAME in (select R_CONSTRAINT_NAME from all_constraints where owner = UPPER(v_owner) and table_name = UPPER(v_table) and CONSTRAINT_TYPE='R') 
       union 
          select '       + HAS FOREIGN CONSTRAINT FROM TABLE : '|| OWNER ||'.'|| TABLE_NAME DESCRIPTION from all_constraints where R_CONSTRAINT_NAME = (select CONSTRAINT_NAME from all_constraints where owner = UPPER(v_owner) and table_name = UPPER(v_table) and CONSTRAINT_TYPE='P')  order by 1 desc;

begin
  v_ct := 0 ;
  ----------------------------
  -- Get partition info
  ----------------------------
  -- are there any partitions?
  
  select count(1)
    into v_ct
    from all_tab_partitions
   where table_owner = UPPER(v_owner)
     and table_name = UPPER(v_table);

  if v_ct > 0 then
      dbms_output.put_line('==========================================================================================');
      dbms_output.put_line('  PARTITION INFORMATION');
      dbms_output.put_line('==========================================================================================');
      for partinfo in parts loop
        dbms_output.put_line ('Owner         : ' || lower(partinfo.table_owner)) ;
        dbms_output.put_line ('Table name    : ' || lower(partinfo.table_name)) ;
        dbms_output.put_line ('Partition Name: ' || lower(partinfo.partition_name)) ;
        dbms_output.put_line ('Tablespace    : ' || lower(partinfo.tablespace_name)) ;
        dbms_output.put_line ('Composite     : ' || lower(partinfo.composite )) ;
        dbms_output.put_line ('High Value    : ' || substr(partinfo.high_value,1,80)) ;
        dbms_output.put_line ('Last analyzed : ' || partinfo.last_analyzed) ;
        dbms_output.put_line ('# Rows        : ' || partinfo.num_rows) ;
        dbms_output.put_line ('# Blocks      : ' || partinfo.blocks ) ;
        dbms_output.put_line ('Empty Blocks  : ' || partinfo.empty_blocks) ;
        dbms_output.put_line ('Avg Space     : ' || partinfo.avg_space) ;
        dbms_output.put_line ('Avg Row Length: ' || partinfo.avg_row_len ) ;
        dbms_output.put_line ('-----------------------------------------');
      end loop;
  end if ;

    dbms_output.put_line('==========================================================================================');
    dbms_output.put_line('  TABLE STATISTICS');
    dbms_output.put_line('==========================================================================================');

      for tabinfo in tabs loop
        dbms_output.put_line ('Owner         : ' || lower(tabinfo.owner)) ;
        dbms_output.put_line ('Table name    : ' || lower(tabinfo.table_name)) ;
        dbms_output.put_line ('Partitioned   : ' || lower(tabinfo.partitioned)) ;
        dbms_output.put_line ('Last analyzed : ' || tabinfo.last_analyzed) ;
        dbms_output.put_line ('Degree        : ' || to_number(tabinfo.degree)) ;
        dbms_output.put_line ('IOT Type      : ' || lower(tabinfo.iot_type)) ;
        dbms_output.put_line ('# Rows        : ' || tabinfo.num_rows) ;
        dbms_output.put_line ('# Blocks      : ' || tabinfo.blocks ) ;
        dbms_output.put_line ('Empty Blocks  : ' || tabinfo.empty_blocks) ;
        dbms_output.put_line ('Avg Space     : ' || tabinfo.avg_space) ;
        dbms_output.put_line ('Avg Row Length: ' || tabinfo.avg_row_len ) ;
        dbms_output.put_line ('Monitoring?   : ' || lower(tabinfo.monitoring )) ;
        v_numblks := tabinfo.blocks ;
        v_numrows := tabinfo.num_rows ;
      end loop;

  ----------------------------
  -- Get column info
  ----------------------------
  -- get max lenght of extension column used to make output look pretty

    select max(length(column_name)) + 1, max(length(num_distinct)) + 3,
         max(length(num_nulls)) + 1, max(length(num_buckets)) + 1,
         max(length(sample_size)) + 1
    into v_max_colname, v_max_ndv, v_max_nulls, v_max_bkts, v_max_smpl
    from all_tab_columns
   where owner = v_owner
     and table_name = v_table ;

  if v_max_nulls < 8 then
     v_max_nulls := 8 ;
  end if ;

  if v_max_bkts < 10 then
     v_max_bkts := 10 ;
  end if ;

  if v_max_smpl < 7 then
     v_max_smpl := 7;
  end if;

  dbms_output.put_line('=========================================================================================================================');
  dbms_output.put_line('  COLUMN STATISTICS');
  dbms_output.put_line('=========================================================================================================================');
  dbms_output.put_line(' ' || rpad('Name',v_max_colname) || '  Analyzed              Null? ' ||
        rpad(' NDV',v_max_ndv) || '  ' || rpad(' Density',10) ||
        rpad('# Nulls',v_max_nulls) || '  ' || rpad('# Buckets',v_max_bkts) || '  ' ||
        rpad('Sample',v_max_smpl) || '  Avg Col Len  Lo-Hi Values');
  dbms_output.put_line('-------------------------------------------------------------------------------------------------------------------------');
  for v_rec in col_stats loop
      if v_rec.last_analyzed is not null then
          dbms_output.put_line(rpad(lower(v_rec.column_name),v_max_colname) || --'  ' || v_rec.data_type|| ' '||
          v_rec.last_analyzed || '  ' ||
          rpad(v_rec.nullable,5) || '  ' ||
          rpad(v_rec.num_distinct,v_max_ndv) ||
          to_char(v_rec.density,'9.999999') || '  ' ||
          rpad(v_rec.num_nulls,v_max_nulls) || '  ' ||
          rpad(v_rec.num_buckets,v_max_bkts) || '  ' ||
          rpad(v_rec.sample_size,v_max_smpl) || '  ' ||
          rpad(v_rec.avg_col_len,14) || '  ' || v_rec.valrange);
      else
          dbms_output.put_line(rpad(lower(v_rec.column_name),v_max_colname));
      end if;
  end loop ;

  ----------------------------
  -- Get Extended Statistics Info
  ----------------------------
  -- get max lenght of extension column used to make output look pretty
  
  select max(length(extension)) + 1
    into v_max_extension 
    from all_stat_extensions
   where owner = v_owner
     and table_name = v_table ;
     
  -- are then any extended stats?  
  select count(1)
    into v_ct
    from all_stat_extensions
  where owner = v_owner and table_name = v_table;
  
  if v_ct > 0 then
    dbms_output.put_line('======================================================================');
    dbms_output.put_line('  EXTENDED STATISTICS');
    dbms_output.put_line('======================================================================');
    dbms_output.put_line(' ' || rpad('Column Expresion',v_max_extension) || ' NDV');
    dbms_output.put_line('----------------------------------------------------------------------');
    for v_rec in extnd_stats loop
     dbms_output.put_line(rpad(v_rec.colgrp, v_max_extension) || ' ' ||v_rec.numdis);
    end loop ;
  end if;
  v_ct := 0;

  ------------------
  -- Get Histogram Info
  ------------------
  -- get how long columns are used to make output look pretty
  
  select max(length(column_name)) + 1, max(length(endpoint_number)) + 1,
         max(length(endpoint_value)) + 1
    into v_max_colname, v_max_endnum, v_max_endval
    from all_tab_histograms
   where owner = v_owner
     and table_name = v_table ;

  if v_max_endnum < 12 then
     v_max_endnum := 12 ;
  end if ;

  if v_max_endval < 16 then
     v_max_endval := 16 ;
  end if ;
  
  -- are there any histograms?
  select count(1)
    into v_ct
    from all_tab_histograms b
   where b.owner = v_owner
     and b.table_name = v_table
     and (exists (select 1 from all_tab_columns
                   where num_buckets > 1
                     and owner = b.owner
                     and table_name = b.table_name
                     and column_name = b.column_name)
          or
          exists (select 1 from all_tab_histograms
                   where endpoint_number > 1
                     and owner = b.owner
                     and table_name = b.table_name
                     and column_name = b.column_name)
         );


  v_ct := 0;
  ------------------
  -- Get index information 
  ------------------
  -- are there any indexes?
  select count(1)
    into v_ct
    from all_indexes a
   where a.table_owner = v_owner
     and a.table_name = v_table;

  select count(1) into v_ct from all_triggers a where a.table_owner = v_owner and a.table_name = v_table;
  if v_ct > 0 then
      dbms_output.put_line('==========================================================================================');
      dbms_output.put_line('  TRIGGER INFORMATION');
      dbms_output.put_line('==========================================================================================');
       for triggerinfo in triggers loop
            dbms_output.put_line ('-------------------------------------------------------------');
            dbms_output.put_line ('TRIGGER NAME        : ' || triggerinfo.trigger_name) ;
            dbms_output.put_line ('TRIGGER TYPE        : ' || triggerinfo.trigger_type) ;
            dbms_output.put_line ('TRIGGERING EVENT    : ' || triggerinfo.triggering_event) ;
            dbms_output.put_line ('STATUS              : ' || triggerinfo.status) ;
            dbms_output.put_line ('ACTION_TYPE         : ' || triggerinfo.action_type) ;
            dbms_output.put_line ('-------------------------------------------------------------');
       end loop;
  end if;

  select count(1) into v_ct from all_synonyms  where table_owner = v_owner and table_name = v_table;
  if v_ct > 0 then
      dbms_output.put_line('==========================================================================================');
      dbms_output.put_line('  SYNONYM INFORMATION');
      dbms_output.put_line('==========================================================================================');
       for synonyminfo in synonyms loop
            dbms_output.put_line ('-------------------------------------------------------------');
            dbms_output.put_line ('SYNONYM NAME        : ' || synonyminfo.SYNONYM_NAME) ;
            dbms_output.put_line ('VISIBLE TO          : ' || synonyminfo.OWNER) ;
            dbms_output.put_line ('-------------------------------------------------------------');
       end loop;
  end if;

  select count(1) into v_ct from all_constraints where (constraint_type <>'C' and owner = v_owner and table_name = v_table) or  ( R_CONSTRAINT_NAME=(select CONSTRAINT_NAME from all_constraints where owner = UPPER(v_owner) and table_name = UPPER(v_table) and CONSTRAINT_TYPE='P') );
   if v_ct > 0 then
     dbms_output.put_line('==========================================================================================');
      dbms_output.put_line('  CONSTRAINT INFORMATION');
     dbms_output.put_line('==========================================================================================');
       for constraintinfo in constraints loop
            dbms_output.put_line (constraintinfo.DESCRIPTION) ;
       end loop;
  end if;

  select count(1) into v_ct from all_indexes a where a.table_owner = v_owner and a.table_name = v_table;
  if v_ct > 0 then
      dbms_output.put_line('==========================================================================================');
      dbms_output.put_line('  INDEX INFORMATION');
      dbms_output.put_line('==========================================================================================');

      for idxinfo in idxs loop
        begin
            dbms_stats.get_index_stats (v_owner, indname => idxinfo.index_name,
               stattab => v_stattab, numrows => v_numirows, numlblks => v_numlblks,
               numdist => v_numdist, avglblk => v_avglblk, avgdblk => v_avgdblk,
               clstfct => v_clstfct, indlevel => v_indlevel );
            dbms_output.put_line ('Index name    : ' || lower(idxinfo.index_name)) ;
            dbms_output.put_line ('Index type    : ' || lower(idxinfo.index_type)) ;
            dbms_output.put_line ('Index created : ' || idxinfo.created) ;
            dbms_output.put_line ('Last analyzed : ' || idxinfo.last_analyzed) ;
            dbms_output.put_line ('Degree        : ' || idxinfo.degree) ;
            dbms_output.put_line ('Partitioned   : ' || lower(idxinfo.partitioned)) ;
            dbms_output.put_line ('Visibility    : ' || lower(idxinfo.visibility)) ;
            dbms_output.put_line ('Rows          : ' || v_numirows) ;
            dbms_output.put_line ('Levels        : ' || v_indlevel ) ;
            dbms_output.put_line ('Leaf Blocks   : ' || v_numlblks) ;
            dbms_output.put_line ('Distinct Keys : ' || v_numdist) ;
            dbms_output.put_line ('Avg LB/Key    : ' || v_avglblk ) ;
            dbms_output.put_line ('Avg DB/Key    : ' || v_avgdblk ) ;
            dbms_output.put_line ('Clust. Factor : ' || v_clstfct ) ;
            dbms_output.put_line ('Table Rows    : ' || v_numrows) ;
            dbms_output.put_line ('Table Blocks  : ' || v_numblks) ;
            dbms_output.put_line ('Tablespace    : ' || idxinfo.TABLESPACE_NAME) ;
            dbms_output.put_line ('INI_TRANS     : ' || idxinfo.INI_TRANS) ;
            dbms_output.put_line ('PCT_FREE      : ' || idxinfo.pct_free) ;
            dbms_output.put_line ('LOGGING       : ' || idxinfo.logging) ;
            dbms_output.put_line ('STATUS        : ' || idxinfo.status) ;
	    dbms_output.put_line ('SYNTAX:  CREATE INDEX '||v_owner||'.'||idxinfo.index_name||' ON '||v_owner||'.'||v_table||' (column_info) PCTFREE '||idxinfo.pct_free||' INITRANS '||idxinfo.INI_TRANS||' TABLESPACE '||idxinfo.TABLESPACE_NAME||' parallel;');
            dbms_output.put_line ('-----------------------------------------');
        exception
            when others then
                 dbms_output.put_line ('Index name    : ' || lower(idxinfo.index_name));
        end;

      end loop;

      dbms_output.put_line('==========================================================================================');
      dbms_output.put_line('  INDEX COLUMNS INFORMATION');
      dbms_output.put_line('==========================================================================================');
      dbms_output.put_line('Index Name                           Pos# Order Column Name          Expression');
      dbms_output.put_line('------------------------------------------------------------------------------------------');
  end if;

end ;
/

------------------------------------------------------------------
-- This section get the index column info out side the PLSQL block
------------------------------------------------------------------
set verify off feed off numwidth 15 lines 500 heading off
column column_name format a30 heading 'Column Name'
column index_name format a30 heading 'Index Name'
column column_position format 999999999 heading 'Position'
column descend format a5 heading 'Order'
column column_expression format a40 heading 'Expression'

break on index_name skip 1

select lower(b.index_name) index_name, b.column_position, b.descend, lower(b.column_name) column_name,  e.column_expression
from all_ind_columns b, all_ind_expressions e
where b.table_owner = UPPER('&&htst_owner')
and b.table_name = UPPER('&&htst_table')
and b.index_name = e.index_name(+)
order by b.index_name, b.column_position, b.column_name
/

undefine htst_owner
undefine htst_table

clear columns
clear breaks
