Rem
Rem $Header: rdbms/admin/catimfstab.sql /main/5 2017/10/25 18:01:33 raeburns Exp $
Rem
Rem catimfs.sql
Rem
Rem Copyright (c) 2015, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catimfstab.sql - IMC FastStart Catalog Tables
Rem
Rem    DESCRIPTION
Rem      Catalog tables for Inmemory FastStart
Rem
Rem    NOTES
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/catimfstab.sql 
Rem    SQL_SHIPPED_FILE: rdbms/admin/catimfstab.sql 
Rem    SQL_PHASE: CATIMFSTAB
Rem    SQL_STARTUP_MODE: NORMAL 
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    raeburns    10/20/17 - RTI 20225108: Fix SQL_METADATA
Rem    pbollimp    03/28/16 - Bug 23012367: Change column order in SYSDBIMFS$
Rem    pbollimp    03/01/16 - Bug 22644127: Add columns in SYSDBIMFS$ for IME
Rem    kdnguyen    11/30/15 - RTI 18784149: handle reupgrade issue
Rem    kdnguyen    05/12/15 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

define FSDEFTBS=SYSAUX
define FSVER=1;

--Schema and feature metadata.  Data are stored in key-value pairs to keep this table structure unchanged. 
CREATE TABLE SYSDBIMFS_METADATA$(
    key         varchar(128), 
    value       varchar(4096),
    CONSTRAINTS SYSDBIMFS_METADATA_PK$ PRIMARY KEY(key)
) TABLESPACE &FSDEFTBS;

truncate table SYSDBIMFS_METADATA$;

insert into SYSDBIMFS_METADATA$ values('STATUS', 'DISABLE');
insert into SYSDBIMFS_METADATA$ values ('TSN', '-1');
insert into SYSDBIMFS_METADATA$ values ('SCHEMA_VER', '&FSVER');
commit;

-- Table for storing segment info 
CREATE TABLE SYSDBIMFSSEG$(
    segid      NUMBER,                                -- FS internal segment id
    pdb        NUMBER,                                -- Segment's PDB id
    tsn        NUMBER,                                -- Segment's TSN
    objd       NUMBER,                                -- Segment's OBJD
    CONSTRAINT SYSDBIMFSSEG_PK$ PRIMARY KEY(segid)
)  TABLESPACE &FSDEFTBS;

-- Table for storing CU info
CREATE TABLE SYSDBIMFS$(
    cuid      NUMBER,                            -- FS internal cu id
    segid     NUMBER,                            -- FS internal segment id
    startdba  NUMBER,                            -- CU's start DBA
    scn       NUMBER,                            -- CU's load scn
    valid     CHAR(1) default 'T'
      check(valid='T' or valid='F'),             -- CU's validity
    ver       NUMBER,                            -- kdz version
    aln       NUMBER,                            -- bitvwvec align       
    epad      NUMBER,                            -- KDZK_END_PAD
    flgs      NUMBER default 0,                  -- FS flags  
    endness   CHAR(1) 
      check (endness='B' or endness='L'),        -- Endianness
    created   TIMESTAMP default systimestamp,    -- CU created time
    lastread  TIMESTAMP default systimestamp,    -- CU last read time
    rscn      NUMBER,                            -- CU's registration scn
    lscn      NUMBER,                            -- Checkpointed CU's load scn
    imcuflgs  NUMBER default 0,                  -- IMCU flags
    spare1    NUMBER default 0,                  -- future spare columns
    spare2    NUMBER default 0,                  -- future spare columns 
    spare3    NUMBER default 0,                  -- future spare columns 
    spare4    NUMBER default 0,                  -- future spare columns 
    spare5    NUMBER default 0,                  -- future spare columns 
    CONSTRAINT SYSDBIMFS_PK$ PRIMARY KEY (cuid),
    CONSTRAINT SYSDBIMFS_SEGID_REF$ foreign key(segid) 
      REFERENCES SYSDBIMFSSEG$(segid) 
      ON DELETE CASCADE
) TABLESPACE &FSDEFTBS;

-- Table for storing CU payload
--CREATE TABLE SYSDBIMFSDATA$(
--    cuid      NUMBER,
--    data      BLOB,
--    CONSTRAINT SYSDBIMFSDATA_PK$ PRIMARY KEY (cuid),
--    CONSTRAINT SYSDBIMFSDATA_CUID_REF$ FOREIGN KEY(cuid)
--      REFERENCES SYSDBIMFS$(cuid)
--      ON DELETE CASCADE
--) TABLESPACE &FSDEFTBS;


-- Table for storing CU extents info
CREATE TABLE SYSDBIMFSDBA$(
    cuid      NUMBER,                                     -- FS internal CU id
    segid     NUMBER,                                     -- FS internal Seg id
    basedba   NUMBER,                                     -- Extent base DBA
    blocks    NUMBER,                                     -- Number of blocks in extent
    CONSTRAINT SYSDBIMFSDBA_PK$ primary key(segid,  basedba),
    CONSTRAINT SYSDBIMFSDBA_CUID_REF$ foreign key(cuid)
      REFERENCES SYSDBIMFS$(cuid) on delete cascade,
    CONSTRAINT SYSDBIMFSDBA_SEGID_REF$ foreign key(segid)
      REFERENCES SYSDBIMFSSEG$(segid) on delete cascade
) TABLESPACE &FSDEFTBS;

-- IDX to make sure each segment can only have 1 extent with a given startdba
CREATE UNIQUE INDEX SYSDBIMFS_IDX$ ON 
  SYSDBIMFS$(segid, startdba) TABLESPACE &FSDEFTBS;

-- IDX to make sure that a segment is unique for the pdb, tsn, objd tupple.
CREATE UNIQUE INDEX SYSDBIMFSSEG_IDX$ ON
  SYSDBIMFSSEG$(pdb, tsn, objd) TABLESPACE &FSDEFTBS;

-- Foreign key IDX
CREATE INDEX SYSDBIMFSDBA_CUID_FK$ ON 
  SYSDBIMFSDBA$(cuid) TABLESPACE &FSDEFTBS;
CREATE INDEX SYSDBIMFSDBA_SEGID_FK$ ON 
  SYSDBIMFSDBA$(segid) TABLESPACE &FSDEFTBS;
CREATE INDEX SYSDBIMFS_SEGID_FK$ ON 
  SYSDBIMFS$(segid) TABLESPACE &FSDEFTBS;

--Sequence to generate CU id, where CUID=0 is a special value
CREATE SEQUENCE SYSDBIMFSCUID_SEQ$ 
  START WITH 1 INCREMENT BY 1 
  MINVALUE 1 MAXVALUE 9999999999;

--Sequence to generate Seg id, where SEGID=0 is a special value
CREATE SEQUENCE SYSDBIMFSSEG_SEQ$ 
  START WITH 1 INCREMENT BY 1 
  MINVALUE 1 MAXVALUE 9999999999;

-- View to join FS metadata normalized tables
--CREATE VIEW SYSDBIMFSV$ AS  
--  SELECT  pdb, tsn, objd, startdba, 
--          scn, basedba, blocks, SYSDBIMFS$.cuid as cuid, 
--          SYSDBIMFSDATA$.data as data, valid, created, 
--          SYSDBIMFSSEG$.segid as segid , ver, aln, epad, endness 
--  FROM SYSDBIMFS$, SYSDBIMFSDBA$, SYSDBIMFSSEG$,  SYSDBIMFSDATA$
--  WHERE SYSDBIMFSDBA$.cuid = SYSDBIMFS$.cuid AND 
--        SYSDBIMFSSEG$.segid = SYSDBIMFS$.segid AND
--        SYSDBIMFSDATA$.cuid = SYSDBIMFS$.cuid;


@?/rdbms/admin/sqlsessend.sql
