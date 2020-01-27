set echo off
set verify off

rem $Header$
rem $Name$

rem Copyright (c); 2005-2011 by Hotsos Enterprises, Ltd.
rem


set termout on serveroutput on
accept htst_owner prompt 'Enter the owner name: '
accept htst_table prompt 'Enter the table name: '
accept htst_level prompt 'Enter the display level (T)able, (C)olumn, (I)ndex, (A)ll: '

declare

    v_numrows   number;
    v_numblks   number;
    v_avgrlen   number ;
    v_table     all_tables.table_name%type := '&htst_table' ;
    v_owner     all_tables.owner%type := '&htst_owner' ;
    v_stattab   varchar2(30) := null ;
    v_level     char(1) := upper(substr('&htst_level',1,1)) ;

    v_numirows  number;
    v_numlblks  number;
    v_numdist   number;
    v_avglblk   number;
    v_avgdblk   number;
    v_clstfct   number;
    v_indlevel  number;

    cursor cols is
    select *
    from all_tab_cols
    where table_name = UPPER(v_table)
    and owner = UPPER(v_owner) ;

    cursor idxs is
    select index_name, index_type, last_analyzed, degree, partitioned
    from all_indexes
    where table_name = UPPER(v_table)
    and owner = UPPER(v_owner) ;

    v_minval    VARCHAR2(50);
    v_maxval    VARCHAR2(50);
    v_distcnt   NUMBER ;
    v_density   NUMBER ;
    v_nullcnt   NUMBER ;
    v_avgclen   NUMBER ;
    v_statrec   dbms_stats.StatRec;

begin

    dbms_stats.get_table_stats (v_owner, v_table, stattab => v_stattab,
        numrows => v_numrows, numblks => v_numblks, avgrlen => v_avgrlen ) ;
    dbms_output.put_line ('-----------------------------------------');
    dbms_output.put_line ('Table: ' || UPPER(v_table));
    dbms_output.put_line ('-----------------------------------------');
    dbms_output.put_line ('Rows: ' || v_numrows || '  Blocks: ' || v_numblks ||'  Avg Row Len: ' || v_avgrlen) ;

    if v_level = 'C' or v_level = 'A' then

            dbms_output.put_line ('-----------------------------------------');
            dbms_output.put_line ('------------ Column Statistics ----------');
            dbms_output.put_line ('-----------------------------------------');

           for colinfo in cols loop

               dbms_stats.get_column_stats (v_owner, v_table, colname => colinfo.column_name,
                    stattab => v_stattab, distcnt => v_distcnt, density => v_density,
                    nullcnt => v_nullcnt, srec => v_statrec, avgclen => v_avgclen );

            v_minval := boil_raw(v_statrec.minval,colinfo.data_type);
            v_maxval := boil_raw(v_statrec.maxval,colinfo.data_type);

            dbms_output.put_line ('Column name : ' || colinfo.column_name) ;
            dbms_output.put_line ('Data Type   : ' || colinfo.data_type) ;
            dbms_output.put_line ('NDV         : ' || v_distcnt) ;
            dbms_output.put_line ('Density     : ' || v_density) ;
            dbms_output.put_line ('Nullable    : ' || colinfo.nullable) ;
            dbms_output.put_line ('Nulls       : ' || v_nullcnt) ;
            dbms_output.put_line ('Lo Value    : ' || v_minval ) ;
            dbms_output.put_line ('Hi Value    : ' || v_maxval ) ;
            dbms_output.put_line ('Histogram   : ' || colinfo.histogram) ;
            dbms_output.put_line ('# Buckets   : ' || colinfo.num_buckets) ;
            dbms_output.put_line ('Avg Col Len : ' || colinfo.avg_col_len) ;
            dbms_output.put_line ('Last Analyze: ' || to_char(colinfo.last_analyzed,'mm/dd/yyyy hh24:mi:ss')) ;
            dbms_output.put_line ('-----------------------------------------');

           end loop;
    end if ;

    if v_level = 'I' or v_level = 'A' then
       dbms_output.put_line ('------------- Index Statistics ----------');
       dbms_output.put_line ('-----------------------------------------');

       for idxinfo in idxs loop
        dbms_stats.get_index_stats (v_owner, indname => idxinfo.index_name,
                stattab => v_stattab, numrows => v_numirows, numlblks => v_numlblks,
                numdist => v_numdist, avglblk => v_avglblk, avgdblk => v_avgdblk,
                clstfct => v_clstfct, indlevel => v_indlevel );

        dbms_output.put_line ('Index name    : ' || idxinfo.index_name) ;
        dbms_output.put_line ('Index type    : ' || idxinfo.index_type) ;
        dbms_output.put_line ('Last analyzed : ' || idxinfo.last_analyzed) ;
        dbms_output.put_line ('Degree        : ' || idxinfo.degree) ;
        dbms_output.put_line ('Partitioned   : ' || idxinfo.partitioned) ;
        dbms_output.put_line ('Rows          : ' || v_numirows) ;
        dbms_output.put_line ('Levels        : ' || v_indlevel ) ;
        dbms_output.put_line ('Leaf Blocks   : ' || v_numlblks) ;
        dbms_output.put_line ('Distinct Keys : ' || v_numdist) ;
        dbms_output.put_line ('Avg LB/Key    : ' || v_avglblk ) ;
        dbms_output.put_line ('Avg DB/Key    : ' || v_avgdblk ) ;
        dbms_output.put_line ('Clust. Factor : ' || v_clstfct ) ;
        dbms_output.put_line ('Table Rows    : ' || v_numrows) ;
        dbms_output.put_line ('Table Blocks  : ' || v_numblks) ;
        dbms_output.put_line ('-----------------------------------------');

       end loop;
    end if ;

exception
   when others then
    dbms_output.put_line (sqlerrm) ;
    dbms_output.put_line ('*** Statistics missing ***') ;

end ;
/

undefine htst_owner
undefine htst_table
undefine htst_stattab
undefine htst_level

clear columns
clear breaks

@henv
