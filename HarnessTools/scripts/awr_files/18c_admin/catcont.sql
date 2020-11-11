Rem Copyright (c) 2012, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catcont.sql - Availability Machine Container Schema
Rem
Rem    BEGIN SQL_FILE_METADATA
Rem    SQL_SOURCE_FILE: rdbms/admin/catcont.sql
Rem    SQL_SHIPPED_FILE: rdbms/admin/catcont.sql
Rem    SQL_PHASE: UTILITY
Rem    SQL_STARTUP_MODE: NORMAL
Rem    SQL_IGNORABLE_ERRORS: NONE
Rem    END SQL_FILE_METADATA
Rem    
Rem    MODIFIED   (MM/DD/YY)
Rem    molagapp    05/10/14 - XbranchMerge molagapp_pt_amv1a_to_12.1.0.2_sync_d
Rem                           from st_rdbms_12.1
Rem    cplakyda    12/12/13 - Add flags column to amau
Rem    cplakyda    09/06/13 - Add remove and repair comments to amrv
Rem    cplakyda    08/12/13 - Add amcfg$ table
Rem    cplakyda    06/26/13 - Performance improvements
Rem    vbegun      06/13/13 - added tablespace name handling
Rem    cplakyda    05/13/13 - Remove next_bucket# col.  Add lastbucket, bktmap
Rem    cplakyda    12/19/12 - CF Rebuild
Rem    wfisher     11/29/12 - add size to amcont$
Rem    cplakyda    09/13/12 - Performance improvements
Rem    cplakyda    07/17/12 - Retain actual filesize
Rem    swerthei    04/26/12 - Created
Rem

SET TERMOUT OFF VERIFY OFF DEFINE "&"
COLUMN 1 NEW_VALUE 1
COLUMN t NEW_VALUE avm_cf
COLUMN u NEW_VALUE u
SELECT '' AS "1" FROM dual WHERE ROWNUM = 0;
SELECT NVL('&1', 'SYSAUX') t FROM dual;
SELECT CASE
         WHEN '&avm_cf' IN ('-h', '-H')
         THEN 'Usage: catcont.sql [<tablespace_name>]'
           || CHR(10)
           || 'Default tablespace name is SYSAUX.'
       END u
  FROM dual
/
SET TERMOUT ON
PROMPT
PROMPT &u
PROMPT
SET TERMOUT OFF HEADING OFF FEEDBACK OFF
WHENEVER SQLERROR EXIT 1
SELECT CASE WHEN '&u' IS NOT NULL THEN 1/0 END FROM dual;
WHENEVER SQLERROR CONTINUE
UNDEFINE 1
UNDEFINE u
SET TERMOUT ON HEADING ON FEEDBACK ON

CREATE SEQUENCE amrvsq MAXVALUE 18446744073709551615 START WITH 1 CACHE 10
/

create table amrv$msg
(
 amrvmsg_key   number not null,          -- amrvmsg key
 amrv_key      number not null,          -- message goes with this amrv entry
 msgtime       timestamp with time zone, -- time when the message was added
 msgphase      char(1 byte) not null,    -- message occurred in this phase
 msgcode       number not null,          -- error # from kbcrv_ec_t
 fname         varchar2(512),            -- ctdfname with issue
 msg           varchar2(1024),           -- msg itself
 constraint amrv$msg_rv_p primary key (amrvmsg_key)
 using index (
   create unique index amrv$msg_rv_p ON amrv$msg(amrvmsg_key)
   tablespace &avm_cf
 )
)
tablespace &avm_cf
/

create table amrv$
(
 amrv_key   number,                -- Rebuild/Validate key
 gname      varchar2(30) not null, -- group name rebuilt/validated
 opstate    char(1 byte) not null, -- Rebuild, validate, repair, remove?
  -- WARNING NOTE: Same values exist in kbcrv.h.  Sync Changes.
  --
  -- Desc: Operation being performed on a container group
  --
  --  KBC_RV_OS_xxxxx DESCRIPTIONS
  -- R = Rebuilding a container group
  -- V = Validating a container group
  -- D = Remove containers and metadata
  -- P = Repair inconsistent container group
  --
  --
 phase       char(1 byte) not null, -- Executing phase in repair/validate
  -- WARNING NOTE: Same values exist in kbcrv.h.  Sync Changes.
  --
  -- Desc: Rebuild/Validate phase
  --
  --  KBC_RVP_xxxxx DESCRIPTIONS
  -- I = Init Phase
  -- S = Structure rebuild/validate
  -- F = contained File rebuild/validate phase
  -- Z = Finalize Phase - "official" amXXX tables about to be updated
  -- C = Complete - "official" amXXX tables updated with rebuild data
  --
  --
 step       char(1 byte) not null, -- Within a phase, current step
  -- WARNING NOTE: Same values exist in kbcrv.h.  Sync Changes.
  --
  -- Desc: Progress in a given phase
  --
  --  KBC_RVS_xxxxx DESCRIPTIONS
  -- Within each phase we track our progress.
  -- NOTE - KBC_RVS_ERROR indicates an error occured but processing continued
  -- The values are:
  --   B = phase began
  --   A = aborted due to errors - Fatal error
  --   E = finished with errors
  --   C = completed with no errors
  --
  --
 error       char(1 byte) not null, -- E = encountered errors but finished
                                    -- N = did not encounter any errors
                                    -- A = aborted rebuild/validate due to fatal
                                    -- a = amrv$ row found abandoned on  r/v
 pct_done    number,
 starttime   timestamp with time zone,   -- When did we start (phase='I')
 finishtime  timestamp with time zone,   -- When did we finish (phase='F')
 doneid      number,  -- Used as a constraint preventing multiple reblds on a CG
                      -- as well as indicating completion.
 constraint amrv$_rv_p primary key (amrv_key)
 using index (
   create unique index amrv$_rv_p ON amrv$(amrv_key)
   tablespace &avm_cf
 ),
 constraint amrv$_u1 unique(gname, doneid)
 using index (
   create unique index amrv$_u1 ON amrv$(gname, doneid)
   tablespace &avm_cf
 ),
 constraint amrv$_check_error check(error in ('E','N', 'A', 'a')),
 constraint amrv$_check_opstate check(opstate in ('R','V', 'D', 'P')),
 constraint amrv$_check_phase check(phase in ('I','S','F','Z','C')),
 constraint amrv$_check_step check(step in ('B','A','E','C'))
)
tablespace &avm_cf
/

create table amcfg$
(
name            varchar2(30),           -- name of configuration option
value           varchar2(100),          -- value of configuration option
constraint amcfg_p primary key (name)
)
tablespace &avm_cf
/

create table amgrp$
(
  gid         number,                -- group id assigned automatically
  gname       varchar2(30) not null, -- group name assigned by user
  ausize      number,                -- AU size of this group, in bytes
  -- gvfld1 and gvfld2 are stored in the containers and are used to tie together
  -- a container group.  This prevents using stale data on the harddrives
  -- during rebuild from reused diskgroups
  gvfld1      number not null,       -- timestamp at group create time
  gvfld2      number not null,       -- db activation# at group create time
  constraint amgrp$_p primary key (gid)
  using index (
    create unique index amgrp$_p ON amgrp$(gid)
    tablespace &avm_cf
  ),
  constraint amgrp$_u unique (gname)
  using index (
    create unique index amgrp$_u ON amgrp$(gname)
    tablespace &avm_cf
  ),
  constraint check_gid check(gid >= 1)
)
tablespace &avm_cf
/

create table amcont$
(
  cid   number not null,        -- unique container id, 1-based
  gid   number not null,        -- group id
  crid  number not null,        -- relative id within group, 0-based
  fsize number not null,        -- size of container file in bytes
  state char(1 byte) not null,  -- R = File record created
                                -- F = File formatted
                                -- C = Complete
                                -- D = Delete
                                -- E = Problem with container during rebuild.
                                --     Typically, an IO problem when scanning
                                -- S = (rebuild/validate) Scanning for aufmaps
  -- used in aufmaps to validate that the map belongs to this container
  cvfld number not null,        -- timestamp at container create time
  fname varchar2(512) not null, -- file name
  constraint amcont$_p primary key (cid)
  using index (
    create unique index amcont$_p ON amcont$(cid)
    tablespace &avm_cf
  ),
  constraint amcont$_f1 foreign key(gid) references amgrp$
    on delete cascade,
  constraint amcont$_u1 unique(gid, crid)
  using index (
    create unique index amcont$_u1 ON amcont$(gid, crid)
    tablespace &avm_cf
  ),
  constraint amcont$_check_cid check(cid >= 1),
  constraint amcont$_check_crid check(crid >= 0),
  constraint amcont$_check_state check(state in ('R','F','C','D','E','S')),
  constraint amcont$_u2 unique(fname)
  using index (
    create unique index amcont$_u2 ON amcont$(fname)
    tablespace &avm_cf
  )
)
tablespace &avm_cf
/

-- ### remove all except the PK constraint for production
create table amau$
(
  bucket#      number not null,  -- 0-based partition number
  gid          number not null,
  au#          number not null,  -- unique within gid
  state        char(1 byte) not null, -- F=Free, U=Uncommitted, A=Allocated
  fid          number not null,  -- file number (au# when not allocated)
  incarnation# number not null,  -- file incarnation number
  crestamp     number not null,  -- file creation timestamp
  sequence#    number not null,  -- 1-based AU number within file
                                 -- (-)rowcount for first row
  alocount     number not null,  -- space allocation counter
  flags        number,           -- currently r1 only - general use bitfield
  -- WARNING NOTE: Same values exist in kbc0.h.  Sync Changes.
  --
  --  KBC_AMAU_xxxxx DESCRIPTIONS
  -- KBC_AUFLG_IN_FC (bit 0 == 1) File originally written to the flash cache
  --
  fsize        number,           -- actual filesize in bytes
  last_bucket# number,           -- r1 only - last bucket used for file
  bucket_map   RAW(64),  -- r1 only - bitmap of buckets used for file (64*8=512)
  constraint amau$_check_au# check(au# >= 1),
  constraint amau$_check_state check(state in ('F', 'U', 'A')),
  constraint amau$_unique_1 unique(gid, au#)
  using index (
    create unique index amau$_unique_1 ON amau$(gid, au#)
    initrans 10
    tablespace &avm_cf
  ),
  constraint fk_1 foreign key(gid) references amgrp$ on delete cascade
)
partition by range(bucket#)
(
  partition p001 values less than(001),
  partition p002 values less than(002),
  partition p003 values less than(003),
  partition p004 values less than(004),
  partition p005 values less than(005),
  partition p006 values less than(006),
  partition p007 values less than(007),
  partition p008 values less than(008),
  partition p009 values less than(009),
  partition p010 values less than(010),
  partition p011 values less than(011),
  partition p012 values less than(012),
  partition p013 values less than(013),
  partition p014 values less than(014),
  partition p015 values less than(015),
  partition p016 values less than(016),
  partition p017 values less than(017),
  partition p018 values less than(018),
  partition p019 values less than(019),
  partition p020 values less than(020),
  partition p021 values less than(021),
  partition p022 values less than(022),
  partition p023 values less than(023),
  partition p024 values less than(024),
  partition p025 values less than(025),
  partition p026 values less than(026),
  partition p027 values less than(027),
  partition p028 values less than(028),
  partition p029 values less than(029),
  partition p030 values less than(030),
  partition p031 values less than(031),
  partition p032 values less than(032),
  partition p033 values less than(033),
  partition p034 values less than(034),
  partition p035 values less than(035),
  partition p036 values less than(036),
  partition p037 values less than(037),
  partition p038 values less than(038),
  partition p039 values less than(039),
  partition p040 values less than(040),
  partition p041 values less than(041),
  partition p042 values less than(042),
  partition p043 values less than(043),
  partition p044 values less than(044),
  partition p045 values less than(045),
  partition p046 values less than(046),
  partition p047 values less than(047),
  partition p048 values less than(048),
  partition p049 values less than(049),
  partition p050 values less than(050),
  partition p051 values less than(051),
  partition p052 values less than(052),
  partition p053 values less than(053),
  partition p054 values less than(054),
  partition p055 values less than(055),
  partition p056 values less than(056),
  partition p057 values less than(057),
  partition p058 values less than(058),
  partition p059 values less than(059),
  partition p060 values less than(060),
  partition p061 values less than(061),
  partition p062 values less than(062),
  partition p063 values less than(063),
  partition p064 values less than(064),
  partition p065 values less than(065),
  partition p066 values less than(066),
  partition p067 values less than(067),
  partition p068 values less than(068),
  partition p069 values less than(069),
  partition p070 values less than(070),
  partition p071 values less than(071),
  partition p072 values less than(072),
  partition p073 values less than(073),
  partition p074 values less than(074),
  partition p075 values less than(075),
  partition p076 values less than(076),
  partition p077 values less than(077),
  partition p078 values less than(078),
  partition p079 values less than(079),
  partition p080 values less than(080),
  partition p081 values less than(081),
  partition p082 values less than(082),
  partition p083 values less than(083),
  partition p084 values less than(084),
  partition p085 values less than(085),
  partition p086 values less than(086),
  partition p087 values less than(087),
  partition p088 values less than(088),
  partition p089 values less than(089),
  partition p090 values less than(090),
  partition p091 values less than(091),
  partition p092 values less than(092),
  partition p093 values less than(093),
  partition p094 values less than(094),
  partition p095 values less than(095),
  partition p096 values less than(096),
  partition p097 values less than(097),
  partition p098 values less than(098),
  partition p099 values less than(099),
  partition p100 values less than(100),
  partition p101 values less than(101),
  partition p102 values less than(102),
  partition p103 values less than(103),
  partition p104 values less than(104),
  partition p105 values less than(105),
  partition p106 values less than(106),
  partition p107 values less than(107),
  partition p108 values less than(108),
  partition p109 values less than(109),
  partition p110 values less than(110),
  partition p111 values less than(111),
  partition p112 values less than(112),
  partition p113 values less than(113),
  partition p114 values less than(114),
  partition p115 values less than(115),
  partition p116 values less than(116),
  partition p117 values less than(117),
  partition p118 values less than(118),
  partition p119 values less than(119),
  partition p120 values less than(120),
  partition p121 values less than(121),
  partition p122 values less than(122),
  partition p123 values less than(123),
  partition p124 values less than(124),
  partition p125 values less than(125),
  partition p126 values less than(126),
  partition p127 values less than(127),
  partition p128 values less than(128),
  partition p129 values less than(129),
  partition p130 values less than(130),
  partition p131 values less than(131),
  partition p132 values less than(132),
  partition p133 values less than(133),
  partition p134 values less than(134),
  partition p135 values less than(135),
  partition p136 values less than(136),
  partition p137 values less than(137),
  partition p138 values less than(138),
  partition p139 values less than(139),
  partition p140 values less than(140),
  partition p141 values less than(141),
  partition p142 values less than(142),
  partition p143 values less than(143),
  partition p144 values less than(144),
  partition p145 values less than(145),
  partition p146 values less than(146),
  partition p147 values less than(147),
  partition p148 values less than(148),
  partition p149 values less than(149),
  partition p150 values less than(150),
  partition p151 values less than(151),
  partition p152 values less than(152),
  partition p153 values less than(153),
  partition p154 values less than(154),
  partition p155 values less than(155),
  partition p156 values less than(156),
  partition p157 values less than(157),
  partition p158 values less than(158),
  partition p159 values less than(159),
  partition p160 values less than(160),
  partition p161 values less than(161),
  partition p162 values less than(162),
  partition p163 values less than(163),
  partition p164 values less than(164),
  partition p165 values less than(165),
  partition p166 values less than(166),
  partition p167 values less than(167),
  partition p168 values less than(168),
  partition p169 values less than(169),
  partition p170 values less than(170),
  partition p171 values less than(171),
  partition p172 values less than(172),
  partition p173 values less than(173),
  partition p174 values less than(174),
  partition p175 values less than(175),
  partition p176 values less than(176),
  partition p177 values less than(177),
  partition p178 values less than(178),
  partition p179 values less than(179),
  partition p180 values less than(180),
  partition p181 values less than(181),
  partition p182 values less than(182),
  partition p183 values less than(183),
  partition p184 values less than(184),
  partition p185 values less than(185),
  partition p186 values less than(186),
  partition p187 values less than(187),
  partition p188 values less than(188),
  partition p189 values less than(189),
  partition p190 values less than(190),
  partition p191 values less than(191),
  partition p192 values less than(192),
  partition p193 values less than(193),
  partition p194 values less than(194),
  partition p195 values less than(195),
  partition p196 values less than(196),
  partition p197 values less than(197),
  partition p198 values less than(198),
  partition p199 values less than(199),
  partition p200 values less than(200),
  partition p201 values less than(201),
  partition p202 values less than(202),
  partition p203 values less than(203),
  partition p204 values less than(204),
  partition p205 values less than(205),
  partition p206 values less than(206),
  partition p207 values less than(207),
  partition p208 values less than(208),
  partition p209 values less than(209),
  partition p210 values less than(210),
  partition p211 values less than(211),
  partition p212 values less than(212),
  partition p213 values less than(213),
  partition p214 values less than(214),
  partition p215 values less than(215),
  partition p216 values less than(216),
  partition p217 values less than(217),
  partition p218 values less than(218),
  partition p219 values less than(219),
  partition p220 values less than(220),
  partition p221 values less than(221),
  partition p222 values less than(222),
  partition p223 values less than(223),
  partition p224 values less than(224),
  partition p225 values less than(225),
  partition p226 values less than(226),
  partition p227 values less than(227),
  partition p228 values less than(228),
  partition p229 values less than(229),
  partition p230 values less than(230),
  partition p231 values less than(231),
  partition p232 values less than(232),
  partition p233 values less than(233),
  partition p234 values less than(234),
  partition p235 values less than(235),
  partition p236 values less than(236),
  partition p237 values less than(237),
  partition p238 values less than(238),
  partition p239 values less than(239),
  partition p240 values less than(240),
  partition p241 values less than(241),
  partition p242 values less than(242),
  partition p243 values less than(243),
  partition p244 values less than(244),
  partition p245 values less than(245),
  partition p246 values less than(246),
  partition p247 values less than(247),
  partition p248 values less than(248),
  partition p249 values less than(249),
  partition p250 values less than(250),
  partition p251 values less than(251),
  partition p252 values less than(252),
  partition p253 values less than(253),
  partition p254 values less than(254),
  partition p255 values less than(255),
  partition p256 values less than(256),
  partition p257 values less than(257),
  partition p258 values less than(258),
  partition p259 values less than(259),
  partition p260 values less than(260),
  partition p261 values less than(261),
  partition p262 values less than(262),
  partition p263 values less than(263),
  partition p264 values less than(264),
  partition p265 values less than(265),
  partition p266 values less than(266),
  partition p267 values less than(267),
  partition p268 values less than(268),
  partition p269 values less than(269),
  partition p270 values less than(270),
  partition p271 values less than(271),
  partition p272 values less than(272),
  partition p273 values less than(273),
  partition p274 values less than(274),
  partition p275 values less than(275),
  partition p276 values less than(276),
  partition p277 values less than(277),
  partition p278 values less than(278),
  partition p279 values less than(279),
  partition p280 values less than(280),
  partition p281 values less than(281),
  partition p282 values less than(282),
  partition p283 values less than(283),
  partition p284 values less than(284),
  partition p285 values less than(285),
  partition p286 values less than(286),
  partition p287 values less than(287),
  partition p288 values less than(288),
  partition p289 values less than(289),
  partition p290 values less than(290),
  partition p291 values less than(291),
  partition p292 values less than(292),
  partition p293 values less than(293),
  partition p294 values less than(294),
  partition p295 values less than(295),
  partition p296 values less than(296),
  partition p297 values less than(297),
  partition p298 values less than(298),
  partition p299 values less than(299),
  partition p300 values less than(300),
  partition p301 values less than(301),
  partition p302 values less than(302),
  partition p303 values less than(303),
  partition p304 values less than(304),
  partition p305 values less than(305),
  partition p306 values less than(306),
  partition p307 values less than(307),
  partition p308 values less than(308),
  partition p309 values less than(309),
  partition p310 values less than(310),
  partition p311 values less than(311),
  partition p312 values less than(312),
  partition p313 values less than(313),
  partition p314 values less than(314),
  partition p315 values less than(315),
  partition p316 values less than(316),
  partition p317 values less than(317),
  partition p318 values less than(318),
  partition p319 values less than(319),
  partition p320 values less than(320),
  partition p321 values less than(321),
  partition p322 values less than(322),
  partition p323 values less than(323),
  partition p324 values less than(324),
  partition p325 values less than(325),
  partition p326 values less than(326),
  partition p327 values less than(327),
  partition p328 values less than(328),
  partition p329 values less than(329),
  partition p330 values less than(330),
  partition p331 values less than(331),
  partition p332 values less than(332),
  partition p333 values less than(333),
  partition p334 values less than(334),
  partition p335 values less than(335),
  partition p336 values less than(336),
  partition p337 values less than(337),
  partition p338 values less than(338),
  partition p339 values less than(339),
  partition p340 values less than(340),
  partition p341 values less than(341),
  partition p342 values less than(342),
  partition p343 values less than(343),
  partition p344 values less than(344),
  partition p345 values less than(345),
  partition p346 values less than(346),
  partition p347 values less than(347),
  partition p348 values less than(348),
  partition p349 values less than(349),
  partition p350 values less than(350),
  partition p351 values less than(351),
  partition p352 values less than(352),
  partition p353 values less than(353),
  partition p354 values less than(354),
  partition p355 values less than(355),
  partition p356 values less than(356),
  partition p357 values less than(357),
  partition p358 values less than(358),
  partition p359 values less than(359),
  partition p360 values less than(360),
  partition p361 values less than(361),
  partition p362 values less than(362),
  partition p363 values less than(363),
  partition p364 values less than(364),
  partition p365 values less than(365),
  partition p366 values less than(366),
  partition p367 values less than(367),
  partition p368 values less than(368),
  partition p369 values less than(369),
  partition p370 values less than(370),
  partition p371 values less than(371),
  partition p372 values less than(372),
  partition p373 values less than(373),
  partition p374 values less than(374),
  partition p375 values less than(375),
  partition p376 values less than(376),
  partition p377 values less than(377),
  partition p378 values less than(378),
  partition p379 values less than(379),
  partition p380 values less than(380),
  partition p381 values less than(381),
  partition p382 values less than(382),
  partition p383 values less than(383),
  partition p384 values less than(384),
  partition p385 values less than(385),
  partition p386 values less than(386),
  partition p387 values less than(387),
  partition p388 values less than(388),
  partition p389 values less than(389),
  partition p390 values less than(390),
  partition p391 values less than(391),
  partition p392 values less than(392),
  partition p393 values less than(393),
  partition p394 values less than(394),
  partition p395 values less than(395),
  partition p396 values less than(396),
  partition p397 values less than(397),
  partition p398 values less than(398),
  partition p399 values less than(399),
  partition p400 values less than(400),
  partition p401 values less than(401),
  partition p402 values less than(402),
  partition p403 values less than(403),
  partition p404 values less than(404),
  partition p405 values less than(405),
  partition p406 values less than(406),
  partition p407 values less than(407),
  partition p408 values less than(408),
  partition p409 values less than(409),
  partition p410 values less than(410),
  partition p411 values less than(411),
  partition p412 values less than(412),
  partition p413 values less than(413),
  partition p414 values less than(414),
  partition p415 values less than(415),
  partition p416 values less than(416),
  partition p417 values less than(417),
  partition p418 values less than(418),
  partition p419 values less than(419),
  partition p420 values less than(420),
  partition p421 values less than(421),
  partition p422 values less than(422),
  partition p423 values less than(423),
  partition p424 values less than(424),
  partition p425 values less than(425),
  partition p426 values less than(426),
  partition p427 values less than(427),
  partition p428 values less than(428),
  partition p429 values less than(429),
  partition p430 values less than(430),
  partition p431 values less than(431),
  partition p432 values less than(432),
  partition p433 values less than(433),
  partition p434 values less than(434),
  partition p435 values less than(435),
  partition p436 values less than(436),
  partition p437 values less than(437),
  partition p438 values less than(438),
  partition p439 values less than(439),
  partition p440 values less than(440),
  partition p441 values less than(441),
  partition p442 values less than(442),
  partition p443 values less than(443),
  partition p444 values less than(444),
  partition p445 values less than(445),
  partition p446 values less than(446),
  partition p447 values less than(447),
  partition p448 values less than(448),
  partition p449 values less than(449),
  partition p450 values less than(450),
  partition p451 values less than(451),
  partition p452 values less than(452),
  partition p453 values less than(453),
  partition p454 values less than(454),
  partition p455 values less than(455),
  partition p456 values less than(456),
  partition p457 values less than(457),
  partition p458 values less than(458),
  partition p459 values less than(459),
  partition p460 values less than(460),
  partition p461 values less than(461),
  partition p462 values less than(462),
  partition p463 values less than(463),
  partition p464 values less than(464),
  partition p465 values less than(465),
  partition p466 values less than(466),
  partition p467 values less than(467),
  partition p468 values less than(468),
  partition p469 values less than(469),
  partition p470 values less than(470),
  partition p471 values less than(471),
  partition p472 values less than(472),
  partition p473 values less than(473),
  partition p474 values less than(474),
  partition p475 values less than(475),
  partition p476 values less than(476),
  partition p477 values less than(477),
  partition p478 values less than(478),
  partition p479 values less than(479),
  partition p480 values less than(480),
  partition p481 values less than(481),
  partition p482 values less than(482),
  partition p483 values less than(483),
  partition p484 values less than(484),
  partition p485 values less than(485),
  partition p486 values less than(486),
  partition p487 values less than(487),
  partition p488 values less than(488),
  partition p489 values less than(489),
  partition p490 values less than(490),
  partition p491 values less than(491),
  partition p492 values less than(492),
  partition p493 values less than(493),
  partition p494 values less than(494),
  partition p495 values less than(495),
  partition p496 values less than(496),
  partition p497 values less than(497),
  partition p498 values less than(498),
  partition p499 values less than(499),
  partition p500 values less than(500),
  partition p501 values less than(501),
  partition p502 values less than(502),
  partition p503 values less than(503),
  partition p504 values less than(504),
  partition p505 values less than(505),
  partition p506 values less than(506),
  partition p507 values less than(507),
  partition p508 values less than(508),
  partition p509 values less than(509),
  partition p510 values less than(510),
  partition p511 values less than(511),
  partition p512 values less than(512)
)
pctfree 30
initrans 10
tablespace &avm_cf
/

create index amau$_i on amau$(gid, state, fid, sequence#) local compress 2
initrans 10
tablespace &avm_cf
/

create index amau$uncommitted on amau$ (case when state = 'U' then state end)
local
initrans 10
tablespace &avm_cf
/

UNDEFINE avm_cf
