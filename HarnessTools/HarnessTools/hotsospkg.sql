rem $Header$
rem $Name$      hotsospkg.sql

rem Copyright (c); 2004-2011 by Hotsos Enterprises, Ltd.
rem
rem This package must be owned by SYS for everything to work.
rem JUNE 2009 RVD - Changed trace_file_upload to trunc lines at 2000 chars
rem JUNE 2009 RVD - Also removed procedures trace_file_contents and sql_file_contents

create or replace package HOTSOS_PKG is
    procedure       delete_trace_files (p_scenario_id number, p_type in number) ;
    procedure       capture_trace_files (p_scenario_id number, p_type number) ;
    procedure       trace_file_upload( p_filename in varchar2, p_scenario_id number , p_type number) ;
    procedure       remove_host_file( p_directory in varchar2, p_filename in varchar2) ;
end;
/

show errors

create or replace package body HOTSOS_PKG is

    procedure delete_trace_files (p_scenario_id number, p_type in number) is
        begin
            delete from avail_trace_files
             where hscenario_id = p_scenario_id
               and trc_type = p_type ;
            commit ;
        end ;

    procedure capture_trace_files (p_scenario_id number, p_type number) is
        begin
            delete_trace_files(p_scenario_id, p_type);

            for xrow in (select * from session_trace_file_name) loop
                if (dbms_lob.fileexists ( bfilename ('UDUMP_DIR', xrow.filename)) = 1) then
                    begin
                       insert into avail_trace_files (filename, hscenario_id, trc_type)
                       values (xrow.filename, p_scenario_id, p_type) ;
                    end;
                    /* dbms_lob.filecloseall; */
                else
                   dbms_output.put_line ('Trace file ' || xrow.filename || ' not found');
                   dbms_output.put_line (dbms_lob.fileexists ( bfilename ('UDUMP_DIR', xrow.filename)) );
                end if ;
            end loop;
            commit ;

        end ;


    procedure trace_file_upload( p_filename in varchar2, p_scenario_id number , p_type number) is
            l_bfile                  bfile := bfilename('UDUMP_DIR',p_filename);
            l_last                   number := 1;
            l_current                number;
            read_lenght              number := 0;
            cntr                     number := 0;
        begin

            begin
               insert into avail_trace_files (filename, hscenario_id, trc_type)
               values (p_filename, p_scenario_id, p_type) ;
               commit ;
            exception
               when others then dbms_output.put_line(sqlerrm);
            end ;

            delete from trace_file_text;
            dbms_lob.fileopen( l_bfile );
            loop
                cntr := cntr+1;
                l_current := dbms_lob.instr( l_bfile, '0A', l_last, 1 );
                exit when (nvl(l_current,0) = 0);
                if l_current-l_last+1 > 2000 then /* can't read lines longer then 2000 */
                   read_lenght := 2000;
                else
                   read_lenght := l_current-l_last+1;
                end if;
                insert into trace_file_text (id, hscenario_id, trc_type, text)
                values 
                (l_last, p_scenario_id, p_type, 
                 utl_raw.cast_to_varchar2(dbms_lob.substr( l_bfile, read_lenght, l_last ) )
                );
                l_last := l_current+1;
            end loop;
            dbms_lob.fileclose(l_bfile);

        end;


    procedure remove_host_file( p_directory in varchar2, p_filename in varchar2) is
    begin
        utl_file.fremove(p_directory, p_filename) ;
        dbms_output.put_line('Trace file removed successfully');
    exception
        when others then dbms_output.put_line('Trace file could not be removed');
    end ;

end;
/

show errors
