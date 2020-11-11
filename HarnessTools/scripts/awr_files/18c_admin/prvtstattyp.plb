@@?/rdbms/admin/sqlsessstart.sql
create or replace type DS_VARRAY_4_CLOB oid '00000000000000000000000000021200'
as   varray(2000000000) of varchar2(4000 char)
/
create or replace public synonym DS_VARRAY_4_CLOB for DS_VARRAY_4_CLOB
/
grant execute on SYS.DS_VARRAY_4_CLOB to public;
CREATE OR REPLACE TYPE COLDICTREC FORCE AS OBJECT(
  col_name   dbms_id,  -- bug # 19366477 - changed from VARCHAR2(30) to dbms_id
  col_type   number,
  col_def    varchar2(32767),
  col_null   number,
  col_flag   number,
  col_prop   number,
  col_unum   number,
  col_inum   number,
  col_obj    number,
  col_scale  number,
  h_bcnt     number,
  h_pfreq    number,
  col_len    number,
  cu_time    date,
  cu_ep      number,
  cu_ejp     number,
  cu_rp      number,
  cu_lp      number,
  cu_nejp    number,
  cu_np      number
);
/
show errors
CREATE OR REPLACE PUBLIC SYNONYM COLDICTREC FOR COLDICTREC;
/
CREATE OR REPLACE TYPE COLDICTTAB AS TABLE OF COLDICTREC;
/
CREATE OR REPLACE PUBLIC SYNONYM COLDICTTAB FOR COLDICTTAB;
/
CREATE OR REPLACE TYPE SELREC FORCE AS OBJECT (
    colidx   integer,                -- index into CTab
    colicol  integer,                -- column intcol#
    selitem  varchar2(256),          -- select list item expression
    gathflg  integer                 -- gather flags
);
/
show errors
CREATE OR REPLACE PUBLIC SYNONYM SELREC FOR SELREC;
/
CREATE OR REPLACE TYPE SELTAB AS TABLE OF SELREC;
/
CREATE OR REPLACE PUBLIC SYNONYM SELTAB FOR SELTAB;
/
CREATE OR REPLACE TYPE DBMSSTATNumTab AS TABLE OF Number;
/
CREATE OR REPLACE PUBLIC SYNONYM DBMSSTATNumTab FOR DBMSSTATNumTab;
/
show errors
CREATE OR REPLACE TYPE CREC FORCE AS OBJECT(
    name    dbms_id,                    -- bug # 19366477 - changed from 
    type    number,                     -- c.type#
    sel     dbms_quoted_id,             -- select list item
    def     varchar2(32767),            -- c.default$
    alias   varchar2(30),               -- alias (null if unnecessary)
    nlable  number,                     -- c.null$
    unq     number,                     -- unique if not null
    ucol    number,                     -- c.col#
    icol    number,                     -- c.intcol#
    fixlen  number,                     -- fixed column length
    maxlen  number,                     -- max column length
    hind    integer,                    -- index into first ColHistTab entry
    pfreq   number,                     -- avg frequency based on previously
    gather  integer,                    -- flags indicating basic stats
    hgath   integer,                    -- flags indicating histograms
    bktnum  integer,                    -- # buckets for this histogram
    hreq    integer,                    -- histogram collection required 
    freq    integer,                    -- frequency histogram if true
    aclonly integer,                    -- 3620168: only get avg col len
    snnv    number,                     -- sample number of non-null values
    sndv    number,                     -- sample number of distinct values
    snnvdv  number,                     -- sample non-null for dv
    slsv    number,                     -- linearly scalable values in sample
    nnv     number,                     -- number of non-null values
    nv      number,                     -- number of null values
    ndv     number,                     -- number of distinct values
    acl     number,                      -- average column length
    ccnt    number,                     -- > 0 if have histograms
    dens    number,                     -- density
    minval  raw(64),                    -- minimum
    maxval  raw(64),                    -- maximum
    nmin    number,                     -- normalized minimum
    nmax    number,                     -- normalized maximum
    dmin    varchar2(240),              -- 'dump'ed minimum
    dmax    varchar2(240)               -- 'dump'ed maximum
  );
/
show errors
CREATE OR REPLACE PUBLIC SYNONYM CREC FOR CREC;
/
CREATE OR REPLACE TYPE CTAB AS TABLE OF CREC;
/
CREATE OR REPLACE PUBLIC SYNONYM CTAB FOR CTAB;
/
CREATE OR REPLACE TYPE RAWCREC FORCE AS OBJECT(
    pos        number,
    res        varchar2(240),
    nonnulls   number,
    ndv        number,
    split      number,
    rsize      number,
    rowcnt     number,
    minfreq    number,
    maxfreq    number,
    avgfreq    number,
    stddevfreq number,
    hindstart  number, -- Start index of histogram of the column in COLHISTTAB
    hindstop   number, -- Stop index of histogram of the column in COLHISTTAB
    hgath      number  -- histogram gathering flags
);
/
show errors
CREATE OR REPLACE PUBLIC SYNONYM RAWCREC FOR RAWCREC;
/
CREATE OR REPLACE TYPE RAWCTAB AS TABLE OF RAWCREC;
/
CREATE OR REPLACE PUBLIC SYNONYM RAWCTAB FOR RAWCTAB;
/
CREATE OR REPLACE TYPE COLHISTREC FORCE AS OBJECT(
    cind    integer,                    -- index into CRec structure
    bval    integer,                    -- bucket value
    edval   varchar2(240),              -- endpoint dump value
    enval   number,                     -- endpoint normalized value
    eaval   raw(64),                    -- endpoint actual value
    maxrep  number                      -- used to build freq hisotgrams
);
/
show errors
CREATE OR REPLACE PUBLIC SYNONYM COLHISTREC FOR COLHISTREC;
/
CREATE OR REPLACE TYPE COLHISTTAB AS TABLE OF COLHISTREC;
/
CREATE OR REPLACE PUBLIC SYNONYM COLHISTTAB FOR COLHISTTAB;
/
show errors
@?/rdbms/admin/sqlsessend.sql
