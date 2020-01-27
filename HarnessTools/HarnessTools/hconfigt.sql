drop table hconfig ;
create table HCONFIG (
    harness_user        varchar2(100)   not null,
    harness_pswd        varchar2(100)   not null,
    db_instance         varchar2(100)   not null,
    editor              varchar2(200)   not null,
    rm_cmd              varchar2(100)   not null,
    host_cmd            varchar2(10)    not null,
    capture_job_no      number,
    harness_pipe_name   varchar2(15),
    capture_job_name    varchar2(100)
);

set echo off feed off
insert into hconfig values (USER,
                            'password',
                            'instance',
                            'notepad.exe',
                            'erase',
                            '$',
                            null,
                            null,
                            null);
commit ;
set echo on feed on

