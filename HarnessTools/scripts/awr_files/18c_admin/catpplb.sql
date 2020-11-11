Rem
Rem
Rem catpplb.sql
Rem
Rem Copyright (c) 2015, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catpplb.sql - Catalog Pre-PLugin Backup tables and views
Rem
Rem    DESCRIPTION
Rem      Catalog Pre-PLugin Backup tables and views that are necessary to
Rem      to restore pre-plugin backups of PDB.
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/catpplb.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/catpplb.sql
Rem    SQL_PHASE: CATPPLB
Rem    SQL_STARTUP_MODE: NORMAL
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    SQL_CALLING_FILE: rdbms/admin/catpcnfg.sql
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    molagapp    11/02/17 - RTI 20485278
Rem    molagapp    08/10/17 - Bug 26595855: rename con_id -> unplug_con_id
Rem    jingzhen    06/19/17 - RTI 20393192: add kccd2x_ced_scn to X$KCCDI2
Rem    molagapp    06/03/17 - add inst_id runtime column
Rem    jingzhen    04/26/17 - bug 25454856: add SYS.RPP$X$KCCPIC
Rem    molagapp    03/08/17 - bug-25666562
Rem    yuli        09/21/16 - bug 19798066: add more fields into x$kccpdb
Rem    jingzhen    07/05/16 - Add PDBCRCVBSCN in RPP and CDB_ROPP X$KCCPDB
Rem    molagapp    06/14/16 - bug 23007304
Rem    jingzhen    10/20/15 - Add the PDBLOCALUNDOSCN in RPP and CDB_ROPP
Rem    jingzhen    10/20/15 - bug 22074876: change the RAW rows back from
Rem                           VARCHAR2
Rem    molagapp    10/05/15 - bug-21651380
Rem    molagapp    06/25/15 - bug-21258967
Rem    molagapp    05/30/15 - bug-21132967
Rem    molagapp    05/05/15 - Create Job during installation
Rem    molagapp    03/11/15 - Project 47808 - Phase 2
Rem    molagapp    02/18/15 - skip partition if feature not enabled
Rem    molagapp    01/22/15 - Project 47808 - Restore from preplugin backup
Rem    molagapp    01/21/15 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

Rem
Rem SYS.RPPX$ tables content are populated while exporting backup meta-data.
Rem These are kept in SYSAUX tablespace of PDB because SYSTEM tablespace of
Rem PDB might be too much to hold its pre-plugin backups.
Rem
Rem SYS.ROPPX$ tables content are populated while importing backup meta-data.
Rem These are kept in SYSAUX tablespace of ROOT because SYSTEM tablepsace
Rem of ROOT might be too much to hold all PDB pre-plugin backups.
Rem

Rem X$KCCDI pre-plugin table
CREATE TABLE SYS.RPP$X$KCCDI(
   INDX                          NUMBER
  ,INST_ID                       NUMBER DEFAULT 1 NOT NULL
  ,UNPLUG_CON_ID                 NUMBER
  ,DICTS                         VARCHAR2(20)
  ,DIDBN                         VARCHAR2(9)
  ,DIRDB                         NUMBER
  ,DICCT                         VARCHAR2(20)
  ,DIFLG                         NUMBER
  ,DIIRS                         VARCHAR2(20)
  ,DIRLS                         VARCHAR2(20)
  ,DIRLC                         VARCHAR2(20)
  ,DIRLC_I                       NUMBER
  ,DIPRS                         VARCHAR2(20)
  ,DIPRC                         VARCHAR2(20)
  ,DIPRC_I                       NUMBER
  ,DIRDC                         NUMBER
  ,DINDF                         NUMBER
  ,DINTF                         NUMBER
  ,DINOF                         NUMBER
  ,DICPT                         NUMBER
  ,DISCN                         VARCHAR2(20)
  ,DINET                         NUMBER
  ,DINOT                         NUMBER
  ,DIOTH                         NUMBER
  ,DIOTT                         NUMBER
  ,DIETB                         RAW(132)
  ,DIMLM                         NUMBER
  ,DIMDM                         NUMBER
  ,DIARH                         NUMBER
  ,DIART                         NUMBER
  ,DIPRT                         NUMBER
  ,DIFAS                         VARCHAR2(20)
  ,DICKP_SCN                     VARCHAR2(20)
  ,DICKP_TIM                     VARCHAR2(20)
  ,DICSQ                         NUMBER
  ,DIDBI                         NUMBER
  ,DISSC_SCN                     VARCHAR2(20)
  ,DISSC_TIM                     VARCHAR2(20)
  ,DISFP                         NUMBER
  ,DIBSC                         NUMBER
  ,DIPOFB                        NUMBER
  ,DIPNFB                        NUMBER
  ,DICOFB                        NUMBER
  ,DICNFB                        NUMBER
  ,DIVTS                         VARCHAR2(20)
  ,DICID                         NUMBER
  ,DIDOR                         NUMBER
  ,DISLH                         NUMBER
  ,DISLT                         NUMBER
  ,DIRAE                         NUMBER
  ,DIACID                        NUMBER
  ,DIARS                         VARCHAR2(20)
  ,DISOS                         NUMBER
  ,DIDGD                         NUMBER
  ,DIMLA                         NUMBER
  ,DIPDB                         NUMBER
  ,DIFL2                         NUMBER
  ,DIPLID                        NUMBER
  ,DIPLN                         VARCHAR2(101)
  ,DICUR_SCN                     VARCHAR2(20)
  ,DIDBUN                        VARCHAR2(30)
  ,DIFSTS                        NUMBER
  ,DIFOPR                        NUMBER
  ,DIFTHS                        NUMBER
  ,DIFTGT                        VARCHAR2(30)
  ,DIFOBS                        VARCHAR2(512)
  ,DIDBOP                        NUMBER
  ,DIBFN                         NUMBER
  ,DIBSQ                         NUMBER
  ,DIFL3                         NUMBER
  ,DIPRCT                        VARCHAR2(512)
) tablespace SYSAUX;


Rem X$KCCDI2 pre-plugin table
CREATE TABLE SYS.RPP$X$KCCDI2(
   INDX                          NUMBER
  ,INST_ID                       NUMBER DEFAULT 1 NOT NULL
  ,UNPLUG_CON_ID                 NUMBER
  ,DI2AB_DAY                     NUMBER
  ,DI2AB_MON                     NUMBER
  ,DI2AB_YEAR                    NUMBER
  ,DI2AB_NUM                     NUMBER
  ,DI2CTFN                       NUMBER
  ,DI2CTST                       NUMBER
  ,DI2CTCPC                      NUMBER
  ,DI2RDI                        NUMBER
  ,DI2INC                        NUMBER
  ,DI2FBM_FLN                    NUMBER
  ,DI2FBM_THR                    NUMBER
  ,DI2FBM_SEQ                    NUMBER
  ,DI2FBM_BNO                    NUMBER
  ,DI2FBM_BOF                    NUMBER
  ,DI2LD_SCN                     VARCHAR2(20)
  ,DI2LR_SCN                     VARCHAR2(20)
  ,DI2FLAG                       NUMBER
  ,DI2FB_LOG_COUNT               NUMBER
  ,DI2FB_BLK_COUNT               VARCHAR2(23)
  ,DI2ACTISCN                    VARCHAR2(20)
  ,DI2SL_THID                    NUMBER
  ,DI2IRT                        VARCHAR2(20)
  ,DI2RSP_OLDEST                 NUMBER
  ,DI2FLG                        NUMBER
  ,DI2SSBY_RDI                   NUMBER
  ,DI2SSBY_PIC                   NUMBER
  ,DI2SSBY_GRSP                  NUMBER
  ,DI2PDBUN                      VARCHAR2(30)
  ,DI2MIN_REQ_CAPTURE_SCN        NUMBER
  ,DI2FBRET                      NUMBER
  ,DI2DBUN                       VARCHAR2(30)
  ,DI2MIN_ACTSCN                 NUMBER
  ,DI2CTSS                       NUMBER
  ,DI2FBDNBLKS                   NUMBER
  ,DI2FBRLS                      VARCHAR2(20)
  ,DI2FBRLC                      VARCHAR2(20)
  ,DI2MINFDSCN                   VARCHAR2(20)
  ,DI2MINFBSCN                   VARCHAR2(20)
  ,DI2MVSUM                      NUMBER
  ,DI2FB_FREELIST                NUMBER
  ,DI2FB_DELETELIST              NUMBER
  ,DI2CCID_LOWER                 NUMBER
  ,DI2CCID_UPPER                 NUMBER
  ,DI2PREV_CCID_LOWER            NUMBER
  ,DI2PREV_CCID_UPPER            NUMBER
  ,DI2MVUSE_PRI                  NUMBER
  ,DI2GUID                       RAW(16)
  ,DI2SBP_TIM                    VARCHAR2(20)
  ,DI2MINDFHCKPSCN               VARCHAR2(20)
  ,DI2_IRV                       NUMBER
  ,DI2PREVCYCLEDFHCKPSCN         VARCHAR2(20)
  ,DI2_CED_SCN                   VARCHAR2(20)
) tablespace SYSAUX;

Rem X$KCCIC pre-plugin table
CREATE TABLE SYS.RPP$X$KCCIC(
   INDX                          NUMBER
  ,INST_ID                       NUMBER DEFAULT 1 NOT NULL
  ,UNPLUG_CON_ID                 NUMBER
  ,ICRID                         NUMBER
  ,ICRLS                         VARCHAR2(20)
  ,ICRLC                         VARCHAR2(20)
  ,ICRLC_I                       NUMBER
  ,ICPRS                         VARCHAR2(20)
  ,ICPRC                         VARCHAR2(20)
  ,ICPRC_I                       NUMBER
  ,ICLLH                         NUMBER
  ,ICLOR                         NUMBER
  ,ICHLH                         NUMBER
  ,ICHOR                         NUMBER
  ,ICPINC                        NUMBER
  ,ICFLG                         NUMBER
  ,ICALW                         VARCHAR2(26)
) tablespace SYSAUX;


Rem X$KCCPDB pre-plugin table
CREATE TABLE SYS.RPP$X$KCCPDB(
   INDX                          NUMBER
  ,INST_ID                       NUMBER DEFAULT 1 NOT NULL
  ,UNPLUG_CON_ID                 NUMBER
  ,PDBRNO                        NUMBER
  ,PDBDBID                       NUMBER
  ,PDBDBN                        VARCHAR2(128)
  ,PDBNLN                        NUMBER
  ,PDBINC                        NUMBER
  ,PDBSTA                        NUMBER
  ,PDBFLG                        NUMBER
  ,PDBINS                        VARCHAR2(20)
  ,PDBRDI                        NUMBER
  ,PDBSTSI                       NUMBER
  ,PDBSAB                        RAW(132)
  ,PDBADCNE                      NUMBER
  ,PDBADCNR                      NUMBER
  ,PDBDFP                        NUMBER
  ,PDBTFP                        NUMBER
  ,PDBNDF                        NUMBER
  ,PDBNTF                        NUMBER
  ,PDBCRS                        VARCHAR2(20)
  ,PDBOTB                        RAW(132)
  ,PDBCSS                        VARCHAR2(20)
  ,PDBMKID                       RAW(16)
  ,PDBUID                        NUMBER
  ,PDBGUID                       RAW(16)
  ,PDBIRCVBSCN                   VARCHAR2(20)
  ,PDBIRCVESCN                   VARCHAR2(20)
  ,PDBIRCV1_THR                  NUMBER
  ,PDBIRCV1_SEQ                  NUMBER
  ,PDBIRCV1_BNO                  NUMBER
  ,PDBIRCV1_SCN                  VARCHAR2(20)
  ,PDBIRCV2_THR                  NUMBER
  ,PDBIRCV2_SEQ                  NUMBER
  ,PDBIRCV2_BNO                  NUMBER
  ,PDBIRCV2_SCN                  VARCHAR2(20)
  ,PDBIRCV3_THR                  NUMBER
  ,PDBIRCV3_SEQ                  NUMBER
  ,PDBIRCV3_BNO                  NUMBER
  ,PDBIRCV3_SCN                  VARCHAR2(20)
  ,PDBCRCVBSCN                   VARCHAR2(20)
  ,PDBRDB                        NUMBER
  ,PDBCCID_LOWER                 NUMBER
  ,PDBCCID_UPPER                 NUMBER
  ,PDBPREV_CCID_LOWER            NUMBER
  ,PDBPREV_CCID_UPPER            NUMBER
  ,PDBMIN_ACTSCN                 VARCHAR2(20)
  ,PDBSCAN_FINSCN                VARCHAR2(20)
  ,PDBMA_RLS                     VARCHAR2(20)
  ,PDBMA_RLC                     NUMBER
) tablespace SYSAUX;


Rem X$KCPDBINC pre-plugin table
CREATE TABLE SYS.RPP$X$KCPDBINC(
   INDX                          NUMBER
  ,INST_ID                       NUMBER DEFAULT 1 NOT NULL
  ,UNPLUG_CON_ID                 NUMBER
  ,DBINC                         NUMBER
  ,DBRLS                         NUMBER
  ,DBRLC                         DATE
  ,PDBINC                        NUMBER
  ,STATUS                        NUMBER
  ,PR_CNFRM                      NUMBER
  ,INCSCN                        NUMBER
  ,INCTIME                       DATE
  ,BRSCN                         NUMBER
  ,BRTIME                        DATE
  ,ERSCN                         NUMBER
  ,ERTIME                        DATE
  ,PR_DBINC                      NUMBER
  ,PR_DBRLS                      NUMBER
  ,PR_DBRLC                      DATE
  ,PR_PDBINC                     NUMBER
  ,PR_PDBINC_NULL                NUMBER
  ,PR_INCSCN                     NUMBER
  ,PR_ERSCN                      NUMBER
  ,FB_ALLOWED                    NUMBER
) tablespace SYSAUX;


Rem X$KCCTS pre-plugin table
CREATE TABLE SYS.RPP$X$KCCTS(
   INDX                          NUMBER
  ,INST_ID                       NUMBER DEFAULT 1 NOT NULL
  ,UNPLUG_CON_ID                 NUMBER
  ,TSRNO                         NUMBER
  ,TSTSN                         NUMBER
  ,TSNAM                         VARCHAR2(30)
  ,TSFLG                         NUMBER
  ,TSDFP                         NUMBER
  ,TSPSS                         VARCHAR2(20)
  ,TSPST                         VARCHAR2(20)
  ,TSPCS                         VARCHAR2(20)
  ,TSPCT                         VARCHAR2(20)
  ,TSKRI                         NUMBER
) tablespace SYSAUX;


Rem X$KCCFE pre-plugin table
CREATE TABLE SYS.RPP$X$KCCFE(
   INDX                          NUMBER
  ,INST_ID                       NUMBER DEFAULT 1 NOT NULL
  ,UNPLUG_CON_ID                 NUMBER
  ,FENUM                         NUMBER
  ,FECSZ                         NUMBER
  ,FEBSZ                         NUMBER
  ,FESTA                         NUMBER
  ,FECRC_SCN                     VARCHAR2(20)
  ,FECRC_TIM                     VARCHAR2(20)
  ,FECRC_THR                     NUMBER
  ,FECRC_RBA_SEQ                 NUMBER
  ,FECRC_RBA_BNO                 NUMBER
  ,FECRC_RBA_BOF                 NUMBER
  ,FECRC_ETB                     RAW(132)
  ,FECPS                         VARCHAR2(20)
  ,FECPT                         VARCHAR2(20)
  ,FECPC                         NUMBER
  ,FESTS                         VARCHAR2(20)
  ,FESTT                         VARCHAR2(20)
  ,FEBSC                         VARCHAR2(20)
  ,FEFNH                         NUMBER
  ,FEFNT                         NUMBER
  ,FEDUP                         NUMBER
  ,FEPFAFN                       NUMBER
  ,FEURS                         VARCHAR2(20)
  ,FEURT                         VARCHAR2(20)
  ,FEOFS                         VARCHAR2(20)
  ,FEONC_SCN                     VARCHAR2(20)
  ,FEONC_TIM                     VARCHAR2(20)
  ,FEONC_THR                     NUMBER
  ,FEONC_RBA_SEQ                 NUMBER
  ,FEONC_RBA_BNO                 NUMBER
  ,FEONC_RBA_BOF                 NUMBER
  ,FEONC_ETB                     RAW(132)
  ,FEPOR                         NUMBER
  ,FETSN                         NUMBER
  ,FETSI                         NUMBER
  ,FERFN                         NUMBER
  ,FEPFT                         NUMBER
  ,FEDOR                         NUMBER
  ,FEPDI                         NUMBER
  ,FEFDB                         NUMBER
  ,FEPLG_SCN                     VARCHAR2(20)
  ,FEPAX                         NUMBER
  ,FEFLG                         NUMBER
  ,FEPFP                         NUMBER
  ,FEPLUS                        NUMBER
  ,FEPRLS                        NUMBER
  ,FEPRLT                        DATE
  ,FEFCRS                        NUMBER
  ,FEFCRT                        DATE
  ,FEFCPS                        NUMBER
  ,FEFCPT                        DATE
  ,FEMVST                        NUMBER
  ,FEPFDI                        NUMBER
  ,FEPFCPS                       NUMBER
  ,FEPFRLS                       NUMBER
  ,FEPFRLT                       NUMBER
  ,FEIBRFT                       NUMBER
) tablespace SYSAUX;


Rem X$KCCFN pre-plugin table
CREATE TABLE SYS.RPP$X$KCCFN(
   INDX                          NUMBER
  ,INST_ID                       NUMBER DEFAULT 1 NOT NULL
  ,UNPLUG_CON_ID                 NUMBER
  ,FNNUM                         NUMBER
  ,FNTYP                         NUMBER
  ,FNFNO                         NUMBER
  ,FNFWD                         NUMBER
  ,FNBWD                         NUMBER
  ,FNFLG                         NUMBER
  ,FNNAM                         VARCHAR2(513)
  ,FNONM                         VARCHAR2(513)
  ,FNBOF                         NUMBER
  ,FNUNN                         NUMBER
  ,BYTES                         NUMBER
) tablespace SYSAUX;


Rem X$KCVDF pre-plugin table
CREATE TABLE SYS.RPP$X$KCVDF(
   INDX                          NUMBER
  ,INST_ID                       NUMBER DEFAULT 1 NOT NULL
  ,UNPLUG_CON_ID                 NUMBER
  ,DF_FECSZ                      NUMBER
  ,DF_FEBSZ                      NUMBER
  ,DF_FESTA                      NUMBER
  ,DF_FECRC_THR                  NUMBER
  ,DF_FECRC_RBA_SEQ              NUMBER
  ,DF_FECRC_RBA_BNO              NUMBER
  ,DF_FECRC_RBA_BOF              NUMBER
  ,DF_FECRC_ETB                  RAW(132)
  ,DF_FECPC                      NUMBER
  ,DF_FEONC_THR                  NUMBER
  ,DF_FEONC_RBA_SEQ              NUMBER
  ,DF_FEONC_RBA_BNO              NUMBER
  ,DF_FEONC_RBA_BOF              NUMBER
  ,DF_FEONC_ETB                  RAW(132)
  ,DF_FEPOR                      NUMBER
  ,DF_FETSN                      NUMBER
  ,DF_FETSI                      NUMBER
  ,DF_FERFN                      NUMBER
  ,DF_FEPFT                      NUMBER
  ,DF_FEPDI                      NUMBER
  ,DF_FEFNH                      NUMBER
  ,DF_FEFNT                      NUMBER
  ,DF_FEDUP                      NUMBER
  ,DF_FEFLG                      NUMBER
  ,DF_FEPLUS                     NUMBER
  ,DF_FEPRLS                     NUMBER
  ,DF_FEPRLT                     DATE
  ,DF_FEFCRS                     NUMBER
  ,DF_FEFCRT                     DATE
  ,DF_FEFCPS                     NUMBER
  ,DF_FEFCPT                     DATE
  ,DF_FEMVST                     NUMBER
  ,DF_FENUM                      NUMBER
  ,DF_FECRC_SCN                  VARCHAR2(20)
  ,DF_FECRC_TIM                  VARCHAR2(20)
  ,DF_FECPS                      VARCHAR2(20)
  ,DF_FECPT                      VARCHAR2(20)
  ,DF_FESTS                      VARCHAR2(20)
  ,DF_FESTT                      VARCHAR2(20)
  ,DF_FEBSC                      VARCHAR2(20)
  ,DF_FEURS                      VARCHAR2(20)
  ,DF_FEURT                      VARCHAR2(20)
  ,DF_FEOFS                      VARCHAR2(20)
  ,DF_FEONC_SCN                  VARCHAR2(20)
  ,DF_FEONC_TIM                  VARCHAR2(20)
  ,DF_FEDOR                      NUMBER
  ,DF_FEDOR_ROOT                 NUMBER
  ,DF_FEUNKNOWN                  NUMBER
  ,DF_FEFDB                      NUMBER
  ,DF_FEPLG_SCN                  VARCHAR2(20)
  ,DF_FEPAX                      NUMBER
  ,DF_HXONS                      NUMBER
  ,DF_HXSTS                      VARCHAR2(20)
  ,DF_HXERR                      NUMBER
  ,DF_HXVER                      NUMBER
  ,DF_FHSWV                      NUMBER
  ,DF_FHCVN                      NUMBER
  ,DF_FHDBI                      NUMBER
  ,DF_FHDBN                      VARCHAR2(9)
  ,DF_FHCSQ                      NUMBER
  ,DF_FHFSZ                      NUMBER
  ,DF_FHBSZ                      NUMBER
  ,DF_FHFNO                      NUMBER
  ,DF_FHTYP                      NUMBER
  ,DF_FHRDB                      NUMBER
  ,DF_FHCRS                      VARCHAR2(20)
  ,DF_FHCRT                      VARCHAR2(20)
  ,DF_FHRLC                      VARCHAR2(20)
  ,DF_FHRLC_I                    NUMBER
  ,DF_FHRLS                      VARCHAR2(20)
  ,DF_FHPRC                      VARCHAR2(20)
  ,DF_FHPRC_I                    NUMBER
  ,DF_FHPRS                      VARCHAR2(20)
  ,DF_FHBTI                      VARCHAR2(20)
  ,DF_FHBSC                      VARCHAR2(20)
  ,DF_FHBTH                      NUMBER
  ,DF_FHSTA                      NUMBER
  ,DF_FHSCN                      VARCHAR2(20)
  ,DF_FHTIM                      VARCHAR2(20)
  ,DF_FHTHR                      NUMBER
  ,DF_FHRBA_SEQ                  NUMBER
  ,DF_FHRBA_BNO                  NUMBER
  ,DF_FHRBA_BOF                  NUMBER
  ,DF_FHETB                      RAW(132)
  ,DF_FHCPC                      NUMBER
  ,DF_FHRTS                      VARCHAR2(20)
  ,DF_FHCCC                      NUMBER
  ,DF_FHBCP_SCN                  VARCHAR2(20)
  ,DF_FHBCP_TIM                  VARCHAR2(20)
  ,DF_FHBCP_THR                  NUMBER
  ,DF_FHBCP_RBA_SEQ              NUMBER
  ,DF_FHBCP_RBA_BNO              NUMBER
  ,DF_FHBCP_RBA_BOF              NUMBER
  ,DF_FHBCP_ETB                  RAW(132)
  ,DF_FHBHZ                      NUMBER
  ,DF_FHXCD                      RAW(16)
  ,DF_FHTSN                      NUMBER
  ,DF_FHTNM                      VARCHAR2(30)
  ,DF_FHRFN                      NUMBER
  ,DF_FHAFS                      VARCHAR2(20)
  ,DF_FHRFS                      VARCHAR2(20)
  ,DF_FHRFT                      DATE
  ,DF_HXIFZ                      NUMBER
  ,DF_HXNRCV                     NUMBER
  ,DF_HXFNM                      VARCHAR2(513)
  ,DF_FHPOFB                     NUMBER
  ,DF_FHPNFB                     NUMBER
  ,DF_FHPRE10                    NUMBER
  ,DF_FHFIRSTUNRECSCN            VARCHAR2(20)
  ,DF_FHFIRSTUNRECTIME           VARCHAR2(20)
  ,DF_FHFTUS                     VARCHAR2(20)
  ,DF_FHFTUT                     VARCHAR2(20)
  ,DF_FHFUUS                     VARCHAR2(20)
  ,DF_FHFUUT                     VARCHAR2(20)
  ,DF_HXLMDBA                    NUMBER
  ,DF_HXLMLD_SCN                 VARCHAR2(20)
  ,DF_FHFCRS                     NUMBER
  ,DF_FHFCRT                     DATE
  ,DF_FHFCPS                     NUMBER
  ,DF_FHFCPT                     DATE
  ,DF_FHPLUS                     NUMBER
  ,DF_FHFDBI                     NUMBER
  ,DF_FHPIDI                     NUMBER
  ,DF_FHPIFN                     NUMBER
  ,DF_FHPRLS                     NUMBER
  ,DF_FHPRLT                     DATE
  ,DF_FHPTSN                     NUMBER
  ,DF_FHBSSZ                     NUMBER
  ,DF_FHBSFMT                    NUMBER
  ,DF_FHBSEOFSCN                 NUMBER
  ,DF_FHBSMAP                    RAW(32)
  ,DF_HXUOPC_SCN                 NUMBER
  ,DF_FHPDBI                     NUMBER
  ,DF_FHPDBDBI                   NUMBER
  ,DF_FHPDBIDN                   RAW(16)
  ,DF_FNTYP                      NUMBER
  ,DF_FNFWD                      NUMBER
  ,DF_FNBWD                      NUMBER
  ,DF_FNFLG                      NUMBER
  ,DF_FNNAM                      VARCHAR2(513)
  ,DF_FNNUM                      NUMBER
  ,DF_FNONM                      VARCHAR2(513)
  ,DF_FNBOF                      NUMBER
  ,DF_FNUNN                      NUMBER
  ,DF_BYTES                      NUMBER
  ,DF_FNAUXNAM                   VARCHAR2(513)
  ,DF_FHPDBUID                   NUMBER
) tablespace SYSAUX;


Rem X$KCCTF pre-plugin table
CREATE TABLE SYS.RPP$X$KCCTF(
   INDX                          NUMBER
  ,INST_ID                       NUMBER DEFAULT 1 NOT NULL
  ,UNPLUG_CON_ID                 NUMBER
  ,TFNUM                         NUMBER
  ,TFAFN                         NUMBER
  ,TFCSZ                         NUMBER
  ,TFBSZ                         NUMBER
  ,TFSTA                         NUMBER
  ,TFCRC_SCN                     VARCHAR2(20)
  ,TFCRC_TIM                     VARCHAR2(20)
  ,TFFNH                         NUMBER
  ,TFFNT                         NUMBER
  ,TFDUP                         NUMBER
  ,TFTSN                         NUMBER
  ,TFTSI                         NUMBER
  ,TFRFN                         NUMBER
  ,TFPFT                         NUMBER
  ,TFMSZ                         NUMBER
  ,TFNSZ                         NUMBER
  ,TFPFP                         NUMBER
) tablespace SYSAUX;


Rem X$KCVFH pre-plugin table
CREATE TABLE SYS.RPP$X$KCVFH(
   INDX                          NUMBER
  ,INST_ID                       NUMBER DEFAULT 1 NOT NULL
  ,UNPLUG_CON_ID                 NUMBER
  ,HXFIL                         NUMBER
  ,HXONS                         NUMBER
  ,HXSTS                         VARCHAR2(20)
  ,HXERR                         NUMBER
  ,HXVER                         NUMBER
  ,FHSWV                         NUMBER
  ,FHCVN                         NUMBER
  ,FHDBI                         NUMBER
  ,FHDBN                         VARCHAR2(9)
  ,FHCSQ                         NUMBER
  ,FHFSZ                         NUMBER
  ,FHBSZ                         NUMBER
  ,FHFNO                         NUMBER
  ,FHTYP                         NUMBER
  ,FHRDB                         NUMBER
  ,FHCRS                         VARCHAR2(20)
  ,FHCRT                         VARCHAR2(20)
  ,FHRLC                         VARCHAR2(20)
  ,FHRLC_I                       NUMBER
  ,FHRLS                         VARCHAR2(20)
  ,FHPRC                         VARCHAR2(20)
  ,FHPRC_I                       NUMBER
  ,FHPRS                         VARCHAR2(20)
  ,FHBTI                         VARCHAR2(20)
  ,FHBSC                         VARCHAR2(20)
  ,FHBTH                         NUMBER
  ,FHSTA                         NUMBER
  ,FHSCN                         VARCHAR2(20)
  ,FHTIM                         VARCHAR2(20)
  ,FHTHR                         NUMBER
  ,FHRBA_SEQ                     NUMBER
  ,FHRBA_BNO                     NUMBER
  ,FHRBA_BOF                     NUMBER
  ,FHETB                         RAW(132)
  ,FHCPC                         NUMBER
  ,FHRTS                         VARCHAR2(20)
  ,FHCCC                         NUMBER
  ,FHBCP_SCN                     VARCHAR2(20)
  ,FHBCP_TIM                     VARCHAR2(20)
  ,FHBCP_THR                     NUMBER
  ,FHBCP_RBA_SEQ                 NUMBER
  ,FHBCP_RBA_BNO                 NUMBER
  ,FHBCP_RBA_BOF                 NUMBER
  ,FHBCP_ETB                     RAW(132)
  ,FHBHZ                         NUMBER
  ,FHXCD                         RAW(16)
  ,FHTSN                         NUMBER
  ,FHTNM                         VARCHAR2(30)
  ,FHRFN                         NUMBER
  ,FHAFS                         VARCHAR2(20)
  ,FHRFS                         VARCHAR2(20)
  ,FHRFT                         DATE
  ,HXIFZ                         NUMBER
  ,HXNRCV                        NUMBER
  ,HXFNM                         VARCHAR2(513)
  ,FHPOFB                        NUMBER
  ,FHPNFB                        NUMBER
  ,FHPRE10                       NUMBER
  ,FHFIRSTUNRECSCN               VARCHAR2(20)
  ,FHFIRSTUNRECTIME              VARCHAR2(20)
  ,FHFTURS                       VARCHAR2(20)
  ,FHFTURT                       VARCHAR2(20)
  ,FHFUTURS                      VARCHAR2(20)
  ,FHFUTURT                      VARCHAR2(20)
  ,HXLMDBA                       NUMBER
  ,HXLMLD_SCN                    VARCHAR2(20)
  ,FHFCRS                        NUMBER
  ,FHFCRT                        DATE
  ,FHFCPS                        NUMBER
  ,FHFCPT                        DATE
  ,FHPLUS                        NUMBER
  ,FHFDBI                        NUMBER
  ,FHPIDI                        NUMBER
  ,FHPIFN                        NUMBER
  ,FHPRLS                        NUMBER
  ,FHPRLT                        DATE
  ,FHPTSN                        NUMBER
  ,FHBSSZ                        NUMBER
  ,FHBSFMT                       NUMBER
  ,FHBSEOFSCN                    NUMBER
  ,FHBSMAP                       RAW(32)
  ,HXUOPC_SCN                    NUMBER
  ,FHPDBI                        NUMBER
  ,FHPDBDBI                      NUMBER
  ,FHPDBIDN                      RAW(16)
  ,FHPIN_SCN                     NUMBER
  ,FHPIN_TIME                    DATE
  ,FHPBR_SCN                     NUMBER
  ,FHPBR_TIME                    DATE
  ,FHPER_SCN                     NUMBER
  ,FHPER_TIME                    DATE
  ,FHPIC                         NUMBER
  ,FHSPARSE                      NUMBER
  ,FHPLID                        NUMBER
  ,FHCLPLID                      NUMBER
  ,FHCPLID                       NUMBER
  ,FHPDBUID                      NUMBER
  ,FHALG                         NUMBER
  ,FHKEY                         RAW(48)
  ,FHMKID                        RAW(48)
  ,FHKEYFLG                      NUMBER
  ,FHMKLOC                       NUMBER
) tablespace SYSAUX;


Rem X$KCVFHTMP pre-plugin table
CREATE TABLE SYS.RPP$X$KCVFHTMP(
   INDX                          NUMBER
  ,INST_ID                       NUMBER DEFAULT 1 NOT NULL
  ,UNPLUG_CON_ID                 NUMBER
  ,HTMPXFIL                      NUMBER
  ,HTMPXONS                      NUMBER
  ,HTMPXERR                      NUMBER
  ,HTMPXVER                      NUMBER
  ,FHTMPSWV                      NUMBER
  ,FHTMPCVN                      NUMBER
  ,FHTMPDBI                      NUMBER
  ,FHTMPDBN                      VARCHAR2(9)
  ,FHTMPCSQ                      NUMBER
  ,FHTMPFSZ                      NUMBER
  ,FHTMPBSZ                      NUMBER
  ,FHTMPFNO                      NUMBER
  ,FHTMPTYP                      NUMBER
  ,FHTMPCRS                      VARCHAR2(20)
  ,FHTMPCRT                      VARCHAR2(20)
  ,FHTMPSTA                      NUMBER
  ,FHTMPCCC                      NUMBER
  ,FHTMPXCD                      RAW(16)
  ,FHTMPTSN                      NUMBER
  ,FHTMPTNM                      VARCHAR2(30)
  ,FHTMPRFN                      NUMBER
  ,HTMPXFNM                      VARCHAR2(513)
) tablespace SYSAUX;


Rem X$KCVFHALL pre-plugin table
CREATE TABLE SYS.RPP$X$KCVFHALL(
   INDX                          NUMBER
  ,INST_ID                       NUMBER DEFAULT 1 NOT NULL
  ,UNPLUG_CON_ID                 NUMBER
  ,HXFIL                         NUMBER
  ,HXONS                         NUMBER
  ,HXSTS                         VARCHAR2(20)
  ,HXERR                         NUMBER
  ,HXVER                         NUMBER
  ,FHSWV                         NUMBER
  ,FHCVN                         NUMBER
  ,FHDBI                         NUMBER
  ,FHDBN                         VARCHAR2(9)
  ,FHCSQ                         NUMBER
  ,FHFSZ                         NUMBER
  ,FHBSZ                         NUMBER
  ,FHFNO                         NUMBER
  ,FHTYP                         NUMBER
  ,FHRDB                         NUMBER
  ,FHCRS                         VARCHAR2(20)
  ,FHCRT                         VARCHAR2(20)
  ,FHRLC                         VARCHAR2(20)
  ,FHRLC_I                       NUMBER
  ,FHRLS                         VARCHAR2(20)
  ,FHPRC                         VARCHAR2(20)
  ,FHPRC_I                       NUMBER
  ,FHPRS                         VARCHAR2(20)
  ,FHBTI                         VARCHAR2(20)
  ,FHBSC                         VARCHAR2(20)
  ,FHBTH                         NUMBER
  ,FHSTA                         NUMBER
  ,FHSCN                         VARCHAR2(20)
  ,FHTIM                         VARCHAR2(20)
  ,FHTHR                         NUMBER
  ,FHRBA_SEQ                     NUMBER
  ,FHRBA_BNO                     NUMBER
  ,FHRBA_BOF                     NUMBER
  ,FHETB                         RAW(132)
  ,FHCPC                         NUMBER
  ,FHRTS                         VARCHAR2(20)
  ,FHCCC                         NUMBER
  ,FHBCP_SCN                     VARCHAR2(20)
  ,FHBCP_TIM                     VARCHAR2(20)
  ,FHBCP_THR                     NUMBER
  ,FHBCP_RBA_SEQ                 NUMBER
  ,FHBCP_RBA_BNO                 NUMBER
  ,FHBCP_RBA_BOF                 NUMBER
  ,FHBCP_ETB                     RAW(132)
  ,FHBHZ                         NUMBER
  ,FHXCD                         RAW(16)
  ,FHTSN                         NUMBER
  ,FHTNM                         VARCHAR2(30)
  ,FHRFN                         NUMBER
  ,FHAFS                         VARCHAR2(20)
  ,FHRFS                         VARCHAR2(20)
  ,FHRFT                         DATE
  ,HXIFZ                         NUMBER
  ,HXNRCV                        NUMBER
  ,HXFNM                         VARCHAR2(513)
  ,FHPOFB                        NUMBER
  ,FHPNFB                        NUMBER
  ,FHPRE10                       NUMBER
  ,FHFIRSTUNRECSCN               VARCHAR2(20)
  ,FHFIRSTUNRECTIME              VARCHAR2(20)
  ,FHFTURS                       VARCHAR2(20)
  ,FHFTURT                       VARCHAR2(20)
  ,FHFUTURS                      VARCHAR2(20)
  ,FHFUTURT                      VARCHAR2(20)
  ,HXLMDBA                       NUMBER
  ,HXLMLD_SCN                    VARCHAR2(20)
  ,FHFCRS                        NUMBER
  ,FHFCRT                        DATE
  ,FHFCPS                        NUMBER
  ,FHFCPT                        DATE
  ,FHPLUS                        NUMBER
  ,FHFDBI                        NUMBER
  ,FHPIDI                        NUMBER
  ,FHPIFN                        NUMBER
  ,FHPRLS                        NUMBER
  ,FHPRLT                        DATE
  ,FHPTSN                        NUMBER
  ,FHBSSZ                        NUMBER
  ,FHBSFMT                       NUMBER
  ,FHBSEOFSCN                    NUMBER
  ,FHBSMAP                       RAW(32)
  ,HXUOPC_SCN                    NUMBER
  ,FHPDBI                        NUMBER
  ,FHPDBDBI                      NUMBER
  ,FHPDBIDN                      RAW(16)
  ,FHPIN_SCN                     NUMBER
  ,FHPIN_TIME                    DATE
  ,FHPBR_SCN                     NUMBER
  ,FHPBR_TIME                    DATE
  ,FHPER_SCN                     NUMBER
  ,FHPER_TIME                    DATE
  ,FHPIC                         NUMBER
  ,FHSPARSE                      NUMBER
  ,FHPLID                        NUMBER
  ,FHCLPLID                      NUMBER
  ,FHCPLID                       NUMBER
  ,FHPDBUID                      NUMBER
  ,FHALG                         NUMBER
  ,FHKEY                         RAW(48)
  ,FHMKID                        RAW(48)
  ,FHKEYFLG                      NUMBER
  ,FHMKLOC                       NUMBER
) tablespace SYSAUX;


Rem X$KCCRT pre-plugin table
CREATE TABLE SYS.RPP$X$KCCRT(
   INDX                          NUMBER
  ,INST_ID                       NUMBER DEFAULT 1 NOT NULL
  ,UNPLUG_CON_ID                 NUMBER
  ,RTNUM                         NUMBER
  ,RTSTA                         NUMBER
  ,RTCKP_SCN                     VARCHAR2(20)
  ,RTCKP_TIM                     VARCHAR2(20)
  ,RTCKP_THR                     NUMBER
  ,RTCKP_RBA_SEQ                 NUMBER
  ,RTCKP_RBA_BNO                 NUMBER
  ,RTCKP_RBA_BOF                 NUMBER
  ,RTCKP_ETB                     RAW(132)
  ,RTOTF                         NUMBER
  ,RTOTB                         NUMBER
  ,RTNLF                         NUMBER
  ,RTLFH                         NUMBER
  ,RTLFT                         NUMBER
  ,RTCLN                         NUMBER
  ,RTSEQ                         NUMBER
  ,RTENB                         VARCHAR2(20)
  ,RTETS                         VARCHAR2(20)
  ,RTDIS                         VARCHAR2(20)
  ,RTDIT                         VARCHAR2(20)
  ,RTLHP                         NUMBER
  ,RTSID                         VARCHAR2(16)
  ,RTOTS                         VARCHAR2(20)
  ,RTFBCU                        NUMBER
  ,RTFBRS                        NUMBER
) tablespace SYSAUX;


Rem X$KCCLE pre-plugin table
CREATE TABLE SYS.RPP$X$KCCLE(
   INDX                          NUMBER
  ,INST_ID                       NUMBER DEFAULT 1 NOT NULL
  ,UNPLUG_CON_ID                 NUMBER
  ,LENUM                         NUMBER
  ,LESIZ                         NUMBER
  ,LESEQ                         NUMBER
  ,LEHWS                         NUMBER
  ,LEBSZ                         NUMBER
  ,LENAB                         NUMBER
  ,LEFLG                         NUMBER
  ,LETHR                         NUMBER
  ,LELFF                         NUMBER
  ,LELFB                         NUMBER
  ,LELOS                         VARCHAR2(20)
  ,LELOT                         VARCHAR2(20)
  ,LENXS                         VARCHAR2(20)
  ,LENXT                         VARCHAR2(20)
  ,LEPVS                         VARCHAR2(20)
  ,LEARF                         NUMBER
  ,LEARB                         NUMBER
  ,LEFNH                         NUMBER
  ,LEFNT                         NUMBER
  ,LEDUP                         NUMBER
) tablespace SYSAUX;


Rem X$KCCSL pre-plugin table
CREATE TABLE SYS.RPP$X$KCCSL(
   INDX                          NUMBER
  ,INST_ID                       NUMBER DEFAULT 1 NOT NULL
  ,UNPLUG_CON_ID                 NUMBER
  ,SLNUM                         NUMBER
  ,SLPDB                         NUMBER
  ,SLTHR                         NUMBER
  ,SLSEQ                         NUMBER
  ,SLSIZ                         NUMBER
  ,SLBSZ                         NUMBER
  ,SLNAB                         NUMBER
  ,SLFLG                         NUMBER
  ,SLLOS                         VARCHAR2(20)
  ,SLLOT                         VARCHAR2(20)
  ,SLNXS                         VARCHAR2(20)
  ,SLNXT                         VARCHAR2(20)
  ,SLRLC                         NUMBER
  ,SLRLS                         VARCHAR2(20)
  ,SLLASTSCN                     VARCHAR2(20)
  ,SLLASTTIM                     VARCHAR2(20)
) tablespace SYSAUX;


Rem X$KCCTIR pre-plugin table
CREATE TABLE SYS.RPP$X$KCCTIR(
   INDX                          NUMBER
  ,INST_ID                       NUMBER DEFAULT 1 NOT NULL
  ,UNPLUG_CON_ID                 NUMBER
  ,TIRNUM                        NUMBER
  ,TIRSID                        VARCHAR2(80)
) tablespace SYSAUX;


Rem X$KCCOR pre-plugin table
CREATE TABLE SYS.RPP$X$KCCOR(
   INDX                          NUMBER
  ,INST_ID                       NUMBER DEFAULT 1 NOT NULL
  ,UNPLUG_CON_ID                 NUMBER
  ,ORRID                         NUMBER
  ,ORTSM                         VARCHAR2(20)
  ,ORSTM                         NUMBER
  ,ORDFP                         NUMBER
  ,ORFNP                         NUMBER
  ,OROFS                         VARCHAR2(20)
  ,ORONS                         VARCHAR2(20)
  ,ORONT                         VARCHAR2(20)
  ,ORRLS                         VARCHAR2(20)
  ,ORRLC                         VARCHAR2(20)
  ,ORIC                          NUMBER
  ,ORONC_THR                     NUMBER
  ,ORONC_RBA_SEQ                 NUMBER
  ,ORONC_RBA_BNO                 NUMBER
  ,ORONC_RBA_BOF                 NUMBER
  ,ORONC_ETB                     VARCHAR2(264)
) tablespace SYSAUX;


Rem X$KCCLH pre-plugin table
CREATE TABLE SYS.RPP$X$KCCLH(
   INDX                          NUMBER
  ,INST_ID                       NUMBER DEFAULT 1 NOT NULL
  ,UNPLUG_CON_ID                 NUMBER
  ,LHRID                         NUMBER
  ,LHTSM                         VARCHAR2(20)
  ,LHSTM                         NUMBER
  ,LHTHP                         NUMBER
  ,LHTNP                         NUMBER
  ,LHSEQ                         NUMBER
  ,LHLOS                         VARCHAR2(20)
  ,LHLOT                         VARCHAR2(20)
  ,LHNXS                         VARCHAR2(20)
  ,LHNAM                         VARCHAR2(513)
  ,LHRLS                         VARCHAR2(20)
  ,LHRLC                         VARCHAR2(20)
  ,LHIC                          NUMBER
) tablespace SYSAUX;


Rem X$KCCAL pre-plugin table
CREATE TABLE SYS.RPP$X$KCCAL(
   INDX                          NUMBER
  ,INST_ID                       NUMBER DEFAULT 1 NOT NULL
  ,UNPLUG_CON_ID                 NUMBER
  ,ALRID                         NUMBER
  ,ALPRC                         NUMBER
  ,ALTSM                         VARCHAR2(20)
  ,ALSTM                         NUMBER
  ,ALFLG                         NUMBER
  ,ALTHP                         NUMBER
  ,ALSEQ                         NUMBER
  ,ALRLS                         VARCHAR2(20)
  ,ALRLC                         VARCHAR2(20)
  ,ALLOS                         VARCHAR2(20)
  ,ALLOT                         VARCHAR2(20)
  ,ALNXS                         VARCHAR2(20)
  ,ALNXT                         VARCHAR2(20)
  ,ALBCT                         NUMBER
  ,ALBSZ                         NUMBER
  ,ALDST                         NUMBER
  ,ALNAM                         VARCHAR2(513)
  ,ALFL2                         NUMBER
  ,ALTOA                         NUMBER
  ,ALDLY                         NUMBER
  ,ALACD                         NUMBER
  ,ALXLC                         NUMBER
) tablespace SYSAUX;


Rem X$KCCBS pre-plugin table
CREATE TABLE SYS.RPP$X$KCCBS(
   INDX                          NUMBER
  ,INST_ID                       NUMBER DEFAULT 1 NOT NULL
  ,UNPLUG_CON_ID                 NUMBER
  ,BSRID                         NUMBER
  ,BSTSM                         VARCHAR2(20)
  ,BSSTM                         NUMBER
  ,BSBSS                         NUMBER
  ,BSBST                         VARCHAR2(20)
  ,BSBSC                         NUMBER
  ,BSPCT                         NUMBER
  ,BSTYP                         NUMBER
  ,BSLVL                         NUMBER
  ,BSBSZ                         NUMBER
  ,BSKPT                         VARCHAR2(20)
  ,BSPFW                         NUMBER
  ,BSPLW                         NUMBER
  ,BSCAL                         NUMBER
  ,BSFLG2                        NUMBER
  ,BSGUID                        RAW(16)
) tablespace SYSAUX;


Rem X$KCCBP pre-plugin table
CREATE TABLE SYS.RPP$X$KCCBP(
   INDX                          NUMBER
  ,INST_ID                       NUMBER DEFAULT 1 NOT NULL
  ,UNPLUG_CON_ID                 NUMBER
  ,BPRID                         NUMBER
  ,BPTSM                         VARCHAR2(20)
  ,BPSTM                         NUMBER
  ,BPBSS                         NUMBER
  ,BPBSC                         NUMBER
  ,BPFLG                         NUMBER
  ,BPNUM                         NUMBER
  ,BPEXT                         NUMBER
  ,BPTIM                         VARCHAR2(20)
  ,BPDEV                         VARCHAR2(17)
  ,BPHDL                         VARCHAR2(513)
  ,BPMDH                         VARCHAR2(65)
  ,BPCMT                         VARCHAR2(64)
  ,BPRSI                         NUMBER
  ,BPRST                         NUMBER
  ,BPTAG                         VARCHAR2(32)
  ,BPSZ1                         NUMBER
  ,BPFLG2                        NUMBER
  ,BPGUID                        RAW(16)
) tablespace SYSAUX;


Rem X$KCCBF pre-plugin table
CREATE TABLE SYS.RPP$X$KCCBF(
   INDX                          NUMBER
  ,INST_ID                       NUMBER DEFAULT 1 NOT NULL
  ,UNPLUG_CON_ID                 NUMBER
  ,BFRID                         NUMBER
  ,BFTSM                         VARCHAR2(20)
  ,BFSTM                         NUMBER
  ,BFBSS                         NUMBER
  ,BFBSC                         NUMBER
  ,BFFLG                         NUMBER
  ,BFDFP                         NUMBER
  ,BFLVL                         NUMBER
  ,BFCRS                         VARCHAR2(20)
  ,BFCRT                         VARCHAR2(20)
  ,BFCPS                         VARCHAR2(20)
  ,BFCPT                         VARCHAR2(20)
  ,BFRLS                         VARCHAR2(20)
  ,BFRLC                         VARCHAR2(20)
  ,BFICS                         VARCHAR2(20)
  ,BFAFS                         VARCHAR2(20)
  ,BFNCB                         NUMBER
  ,BFMCB                         NUMBER
  ,BFLCB                         NUMBER
  ,BFFSZ                         NUMBER
  ,BFBCT                         NUMBER
  ,BFBSZ                         NUMBER
  ,BFLOR                         NUMBER
  ,BFBRD                         NUMBER
  ,BFSIX                         NUMBER
  ,BFFDI                         NUMBER
  ,BFPLUS                        NUMBER
  ,BFPRLS                        NUMBER
  ,BFPRLT                        DATE
  ,BFPTSN                        NUMBER
  ,BFSSB                         NUMBER
  ,BFSSZ                         NUMBER
  ,BFGUID                        RAW(16)
) tablespace SYSAUX;


Rem X$KCCBL pre-plugin table
CREATE TABLE SYS.RPP$X$KCCBL(
   INDX                          NUMBER
  ,INST_ID                       NUMBER DEFAULT 1 NOT NULL
  ,UNPLUG_CON_ID                 NUMBER
  ,BLRID                         NUMBER
  ,BLTSM                         VARCHAR2(20)
  ,BLSTM                         NUMBER
  ,BLBSS                         NUMBER
  ,BLBSC                         NUMBER
  ,BLTHP                         NUMBER
  ,BLSEQ                         NUMBER
  ,BLRLS                         VARCHAR2(20)
  ,BLRLC                         VARCHAR2(20)
  ,BLLOS                         VARCHAR2(20)
  ,BLLOT                         VARCHAR2(20)
  ,BLNXS                         VARCHAR2(20)
  ,BLNXT                         VARCHAR2(20)
  ,BLBCT                         NUMBER
  ,BLBSZ                         NUMBER
  ,BLSIX                         NUMBER
  ,BLFLG                         NUMBER
) tablespace SYSAUX;


Rem X$KCCBI pre-plugin table
CREATE TABLE SYS.RPP$X$KCCBI(
   INDX                          NUMBER
  ,INST_ID                       NUMBER DEFAULT 1 NOT NULL
  ,UNPLUG_CON_ID                 NUMBER
  ,BIRID                         NUMBER
  ,BITSM                         VARCHAR2(20)
  ,BISTM                         NUMBER
  ,BIBSS                         NUMBER
  ,BIBSC                         NUMBER
  ,BIMDT                         VARCHAR2(20)
  ,BIFSZ                         NUMBER
  ,BISIX                         NUMBER
  ,BIDUN                         VARCHAR2(30)
  ,BIFLG                         NUMBER
  ,BIGUID                        RAW(16)
) tablespace SYSAUX;


Rem X$KCCDC pre-plugin table
CREATE TABLE SYS.RPP$X$KCCDC(
   INDX                          NUMBER
  ,INST_ID                       NUMBER DEFAULT 1 NOT NULL
  ,UNPLUG_CON_ID                 NUMBER
  ,DCRID                         NUMBER
  ,DCTSM                         VARCHAR2(20)
  ,DCSTM                         NUMBER
  ,DCFLG                         NUMBER
  ,DCDFP                         NUMBER
  ,DCRFN                         NUMBER
  ,DCDBI                         NUMBER
  ,DCCRS                         VARCHAR2(20)
  ,DCCRT                         VARCHAR2(20)
  ,DCCPS                         VARCHAR2(20)
  ,DCCPT                         VARCHAR2(20)
  ,DCRLS                         VARCHAR2(20)
  ,DCRLC                         VARCHAR2(20)
  ,DCRFS                         VARCHAR2(20)
  ,DCRFT                         VARCHAR2(20)
  ,DCAFS                         VARCHAR2(20)
  ,DCNCB                         NUMBER
  ,DCMCB                         NUMBER
  ,DCLCB                         NUMBER
  ,DCBCT                         NUMBER
  ,DCBSZ                         NUMBER
  ,DCLOR                         NUMBER
  ,DCKPT                         VARCHAR2(20)
  ,DCTAG                         VARCHAR2(32)
  ,DCNAM                         VARCHAR2(513)
  ,DCRSI                         NUMBER
  ,DCRST                         NUMBER
  ,DCFDI                         NUMBER
  ,DCPLUS                        NUMBER
  ,DCPRLS                        NUMBER
  ,DCPRLT                        DATE
  ,DCPTSN                        NUMBER
  ,DCCPTHR                       NUMBER
  ,DCFLG2                        NUMBER
  ,DCGUID                        RAW(16)
) tablespace SYSAUX;


Rem X$KCCPD pre-plugin table
CREATE TABLE SYS.RPP$X$KCCPD(
   INDX                          NUMBER
  ,INST_ID                       NUMBER DEFAULT 1 NOT NULL
  ,UNPLUG_CON_ID                 NUMBER
  ,PCRID                         NUMBER
  ,PCTSM                         VARCHAR2(20)
  ,PCSTM                         NUMBER
  ,PCFLG                         NUMBER
  ,PCMPL                         NUMBER
  ,PCTYP                         NUMBER
  ,PCTIM                         VARCHAR2(20)
  ,PCDEV                         VARCHAR2(17)
  ,PCHDL                         VARCHAR2(513)
  ,PCMDH                         VARCHAR2(65)
  ,PCCMT                         VARCHAR2(81)
  ,PCTAG                         VARCHAR2(32)
  ,PDFLG                         NUMBER
  ,PDDFP                         NUMBER
  ,PDCRS                         VARCHAR2(20)
  ,PDCRT                         VARCHAR2(20)
  ,PDCPS                         VARCHAR2(20)
  ,PDCPT                         VARCHAR2(20)
  ,PDRLS                         VARCHAR2(20)
  ,PDRLC                         VARCHAR2(20)
  ,PDRFS                         VARCHAR2(20)
  ,PDRFT                         VARCHAR2(20)
  ,PDAFS                         VARCHAR2(20)
  ,PDFSZ                         NUMBER
  ,PDBSZ                         NUMBER
  ,PDLOR                         NUMBER
  ,PDKPT                         VARCHAR2(20)
  ,PCRSI                         NUMBER
  ,PCRST                         NUMBER
  ,PCFDI                         NUMBER
  ,PCPLUS                        NUMBER
  ,PCPRLS                        NUMBER
  ,PCPRLT                        DATE
  ,PCPTSN                        NUMBER
  ,PCGUID                        RAW(16)
) tablespace SYSAUX;


Rem X$KCCPA pre-plugin table
CREATE TABLE SYS.RPP$X$KCCPA(
   INDX                          NUMBER
  ,INST_ID                       NUMBER DEFAULT 1 NOT NULL
  ,UNPLUG_CON_ID                 NUMBER
  ,PCRID                         NUMBER
  ,PCTSM                         VARCHAR2(20)
  ,PCSTM                         NUMBER
  ,PCFLG                         NUMBER
  ,PCMPL                         NUMBER
  ,PCTIM                         VARCHAR2(20)
  ,PCDEV                         VARCHAR2(17)
  ,PCHDL                         VARCHAR2(513)
  ,PCMDH                         VARCHAR2(65)
  ,PCCMT                         VARCHAR2(81)
  ,PCTAG                         VARCHAR2(32)
  ,PATHP                         NUMBER
  ,PASEQ                         NUMBER
  ,PARLS                         VARCHAR2(20)
  ,PARLC                         VARCHAR2(20)
  ,PALOS                         VARCHAR2(20)
  ,PALOT                         VARCHAR2(20)
  ,PANXS                         VARCHAR2(20)
  ,PANXT                         VARCHAR2(20)
  ,PABCT                         NUMBER
  ,PABSZ                         NUMBER
  ,PCRSI                         NUMBER
  ,PCRST                         NUMBER
  ,PAFLG                         NUMBER
  ,PAKPT                         VARCHAR2(20)
) tablespace SYSAUX;

Rem X$KCCPIC pre-plugin table
CREATE TABLE SYS.RPP$X$KCCPIC(
   INDX                          NUMBER
  ,INST_ID                       NUMBER DEFAULT 1 NOT NULL
  ,UNPLUG_CON_ID                 NUMBER
  ,PICRNO                        NUMBER
  ,PICSTA                        NUMBER
  ,PICDBINC                      VARCHAR2(128)
  ,PICDBRLS                      VARCHAR2(128)
  ,PICDBRLC                      NUMBER
  ,PICID                         NUMBER
  ,PICINCS                       VARCHAR2(128)
  ,PICINCT                       VARCHAR2(128)
  ,PICBRLS                       VARCHAR2(128)
  ,PICBRLT                       VARCHAR2(128)
  ,PICERLS                       VARCHAR2(128)
  ,PICERLT                       VARCHAR2(128)
  ,PICPRIDBINC                   NUMBER
  ,PICPRIDBRLS                   VARCHAR2(128)
  ,PICPRIDBRLC                   NUMBER
  ,PICPRIPDBINC                  NUMBER
  ,PICPRIPDBINCS                 VARCHAR2(128)
  ,PICPRIPDBINCT                 VARCHAR2(128)
  ,PICPRIPDBBRLS                 VARCHAR2(128)
  ,PICPRIPDBBRLT                 VARCHAR2(128)
  ,PICPRIPDBERLS                 VARCHAR2(128)
  ,PICPRIPDBERLT                 VARCHAR2(128)
) tablespace SYSAUX;
 

Rem
Rem NOTE! NOTE! NOTE!
Rem
Rem If you add new table or sequence, then ensure to change
Rem downgrade scripts to drop/truncate that table and sequence.
Rem
Rem If you add new columns, then ugprade script must be changed and
Rem downgrade scripts must be changed to drop that column
Rem
Rem

Rem -------------------------------
Rem Add new tables before this line
Rem -------------------------------

Rem
Rem CDB views on top of pre-plugin tables
Rem

DECLARE
   name_in_use       EXCEPTION;
   job_doesnt_exist  EXCEPTION;
   prog_doesnt_exist EXCEPTION;
   queue_exist       EXCEPTION;
   queue_table_exist EXCEPTION;
   pragma exception_init( name_in_use, -955 );
   pragma exception_init( job_doesnt_exist, -27475 );
   pragma exception_init( prog_doesnt_exist, -27476 );
   pragma exception_init( queue_exist, -24006);
   pragma exception_init( queue_table_exist, -24001);
   partition      NUMBER;
   part_clause    VARCHAR2(128);
   l_columns      VARCHAR2(32767);
   l_ropp_columns VARCHAR2(32767);
   nullcol        VARCHAR2(8) := '$NULL$';
   l_program_name VARCHAR2(128) := 'SYS.ORA$PREPLUGIN_BACKUP_PRG';
   l_job_name     VARCHAR2(128) := 'SYS.ORA$PREPLUGIN_BACKUP_JOB';
   l_queue_name   VARCHAR2(128) := 'SYS.ORA$PREPLUGIN_BACKUP_QUE';
   l_queue_tab    VARCHAR2(128) := 'SYS.ORA$PREPLUGIN_BACKUP_QTB';
   l_pay_type     VARCHAR2(128) := 'SYS.ORA$PREPLUGIN_BACKUP_MSG_T';
BEGIN
   SELECT decode(value, 'TRUE', 1, 0) INTO partition
     FROM v$option
    WHERE parameter = 'Partitioning';

   IF (partition > 0) THEN
      part_clause := 'PARTITION BY LIST (con_id) (PARTITION p0 VALUES (0))';
   END IF;

   FOR i IN
   (
      SELECT name_krbppbtbl                     name,
             rPP_krbppbtbl                      rPP,
             cdbrPP_krbppbtbl                   cdbrPP,
             roPP_krbppbtbl                     roPP,
             cdbroPP_krbppbtbl                  cdbroPP,
             nvl(seqName_krbppbtbl, nullcol)    seqName,
             instidName_krbppbtbl               instidName
        FROM X$KRBPPBTBL
   )
   LOOP
      CDBView.create_cdbview(FALSE, 'SYS', i.rPP, i.cdbrPP);
      EXECUTE IMMEDIATE
         'GRANT SELECT ON SYS.' || i.rPP || ' TO SELECT_CATALOG_ROLE';
      EXECUTE IMMEDIATE
         'CREATE OR REPLACE PUBLIC SYNONYM ' ||
          i.cdbrPP || ' FOR SYS.' || i.rPP;
      EXECUTE IMMEDIATE q'{
         SELECT LISTAGG(dbms_assert.enquote_name(column_name), ',')
                WITHIN GROUP (ORDER BY column_id) x
           FROM all_tab_columns
          WHERE table_name = :1
          AND owner = 'SYS'
          AND column_name != 'INST_ID'
         }'
      INTO l_columns
      USING i.rPP;

      -- Add runtime instance_id columns
      l_ropp_columns := regexp_replace(l_columns,
         '(.*,)("' || i.instidName || '")(.*)',
         '\1\2,TO_NUMBER(SYS_CONTEXT(''USERENV'',''INSTANCE''))"INST_ID"\3');

      -- Add INST_ID column after the column name indicated by X$KRBPPBTBL
      l_columns := regexp_replace(l_columns,
         '(.*,)("' || i.instidName || '")(.*)', '\1\2,"INST_ID"\3');

      -- Rename UNPLUG_CON_ID column as CON_ID in ROPP$ tables
      l_columns := regexp_replace(l_columns,
         '(.*,)("UNPLUG_CON_ID")(.*)', '\1"UNPLUG_CON_ID" AS "CON_ID"\3');
      l_ropp_columns := regexp_replace(l_ropp_columns,
         '(.*,)("UNPLUG_CON_ID")(.*)', '\1"CON_ID"\3');

      BEGIN
         EXECUTE IMMEDIATE
            'CREATE TABLE SYS.' || i.roPP ||
            ' tablespace SYSAUX ' || part_clause ||
            ' AS (SELECT ' || l_columns ||
            '       FROM SYS.' || i.rPP ||
            '      WHERE 1 = 0 )';

         EXECUTE IMMEDIATE
            'ALTER TABLE SYS.' || i.roPP || ' MODIFY INST_ID DEFAULT 1 ';
      EXCEPTION
         WHEN name_in_use THEN
            NULL;
      END;

      BEGIN
         IF (i.seqName != nullcol) THEN
            EXECUTE IMMEDIATE 'CREATE SEQUENCE SYS.' || i.seqName;
         END IF;
      EXCEPTION
         WHEN name_in_use THEN
            NULL;
      END;

      EXECUTE IMMEDIATE
         'CREATE OR REPLACE VIEW ' ||
          i.cdbroPP || ' CONTAINER_DATA SHARING=OBJECT AS ' ||
          'SELECT ' || l_ropp_columns || ' FROM SYS.' || i.roPP || ' T ';
      EXECUTE IMMEDIATE
         'GRANT SELECT ON SYS.' || i.roPP || ' TO SELECT_CATALOG_ROLE';
      EXECUTE IMMEDIATE
         'CREATE OR REPLACE PUBLIC SYNONYM ' ||
         i.cdbroPP || ' FOR SYS.' || i.roPP;
   END LOOP;

   BEGIN
      dbms_aqadm.create_queue_table(
         queue_table        => l_queue_tab,
         queue_payload_type => l_pay_type,
         multiple_consumers => TRUE,
         comment            => l_queue_name);
   EXCEPTION
      WHEN queue_table_exist THEN
         NULL;
   END;

   BEGIN
      dbms_aqadm.create_queue(
         queue_name         => l_queue_name,
         queue_table        => l_queue_tab,
         comment            => l_queue_name);
   EXCEPTION
      WHEN queue_exist THEN
         NULL;
   END;
    
   dbms_aqadm.start_queue(
      queue_name         => l_queue_name);

   BEGIN
      dbms_scheduler.drop_program(
         program_name => l_program_name,
         force        => TRUE);
   EXCEPTION
      WHEN prog_doesnt_exist THEN
         NULL;
   END;

   dbms_scheduler.create_program(
      program_name        => l_program_name,
      program_type        => 'STORED_PROCEDURE',
      program_action      =>
        'sys.dbms_preplugin_backup.importX$RmanTablesUsingConId',
      number_of_arguments => 1,
      enabled             => FALSE,
      comments            => 'Program to import preplugin backups');

   dbms_scheduler.define_metadata_argument(
      program_name       => l_program_name,
      metadata_attribute => 'event_message',
      argument_position  => 1,
      argument_name      => 'p_con_id');

   dbms_scheduler.enable(name => l_program_name);

   BEGIN
      dbms_scheduler.drop_job(
         job_name  => l_job_name,
         force     => TRUE);
   EXCEPTION
      WHEN job_doesnt_exist THEN
         NULL;
   END;

   dbms_scheduler.create_job(
      job_name        => l_job_name,
      program_name    => l_program_name,
      queue_spec      => l_queue_name,
      enabled         => FALSE);

   dbms_scheduler.set_attribute(
      name      => l_job_name,
      attribute => 'parallel_instances',
      value     => TRUE);  

   -- RTI 20485278
   -- If PDB gets closed immediately after open which can happen during
   -- migration from non-cdb to pdb, then we will retry few times before
   -- giving up the import.
   dbms_scheduler.set_attribute(
      name      => l_job_name,
      attribute => 'restart_on_failure',
      value     => TRUE);  
END;
/

@?/rdbms/admin/sqlsessend.sql
