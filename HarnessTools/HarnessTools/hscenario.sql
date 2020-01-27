drop table hscenario;
create table HSCENARIO (
    id                      number      not null,
    workspace               varchar2(80)    not null,
    name                    varchar2(80)    not null,
    test_type               varchar2(1),
    constraint HSCENARIO_PK primary key (id),
    constraint HSCENARIO_U1 unique (workspace, name)
);
