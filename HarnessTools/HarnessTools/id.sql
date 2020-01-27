SELECT  CNTNR.hi_lvl_strg_i
        ||
        ':'
        ||
        (
                CASE
                        WHEN COUNT(DISTINCT CNTNR.loc_i) OVER(PARTITION BY CNTNR.hi_lvl_strg_i, CNTNR.trlr_i, CNTNR.ship_i) > 1
                        THEN 'Y'
                        ELSE 'N'
                END) sub_total_key                                          ,
        CNTNR.hi_lvl_strg_i door_i                                          ,
        CNTNR.loc_i store_i                                                 ,
        CNTNR.trlr_i                                                        ,
        TO_CHAR(MIN(TIME_Q.beg_dt),'yyyy-MM-dd HH24:mi:ss') time_open       ,
        ROUND((MAX(TIME_Q.end_dt) - MIN(TIME_Q.beg_dt)) * 24,2) hours_opened,
        CEIL(SUM(unit_wt_q)) trlr_wt                                        ,
        ROUND(SUM(
                CASE
                        WHEN catg_c IN ('CON','SEC','NCN','NSR','PIO','FPS','HIN','TML')
                        THEN CNTNR.item_q
                        ELSE 0
                END)) ctn_q,
        ROUND(SUM(
                CASE
                        WHEN PCX.catg_c IN ('CON','SEC')
                        THEN CNTNR.item_q
                        ELSE 0
                END)) conveyable,
        ROUND(SUM(
                CASE
                        WHEN catg_c IN ('NCN','NSR','PIO','FPS','HIN','TML')
                        THEN CNTNR.item_q
                        ELSE 0
                END)) non_conveyable,
        ROUND(SUM(
                CASE
                        WHEN catg_c IN ('NCN','NSR')
                        THEN CNTNR.item_q
                        ELSE 0
                END)) non_con_sort,
        ROUND(SUM(
                CASE
                        WHEN catg_c                 = 'PIO'
                                AND NVL(orig_c,'X') < > 'V'
                        THEN CNTNR.item_q
                        ELSE 0
                END)) pipo,
        ROUND(SUM(
                CASE
                        WHEN NVL(orig_c,'X') = 'V'
                        THEN CNTNR.item_q
                        ELSE 0
                END)) nmsc,
        ROUND(SUM(
                CASE
                        WHEN catg_c = 'FPS'
                        THEN CNTNR.item_q
                        ELSE 0
                END)) fps,
        ROUND(SUM(
                CASE
                        WHEN catg_c = 'TML'
                        THEN CNTNR.item_q
                        ELSE 0
                END)) team_lift,
        ROUND(SUM(
                CASE
                        WHEN catg_c = 'HIN'
                        THEN CNTNR.item_q
                        ELSE 0
                END)) hand_induct,
        ROUND(SUM(
                CASE
                        WHEN pull_priority_c = 3
                        THEN CNTNR.item_q
                        ELSE 0
                END)) shv,
        ROUND(SUM(
                CASE
                        WHEN pull_priority_c = 5
                        THEN CNTNR.item_q
                        ELSE 0
                END)) hv,
        ROUND(SUM(
                CASE
                        WHEN pull_priority_c = 10
                        THEN CNTNR.item_q
                        ELSE 0
                END)) rr,
        ROUND(SUM(
                CASE
                        WHEN pull_priority_c = 15
                        THEN CNTNR.item_q
                        ELSE 0
                END)) TRAN          ,
        ROUND(NVL(SUM(ad_q),0)) ad_q,
        CASE
                WHEN COUNT(DISTINCT CNTNR.loc_i) OVER(PARTITION BY CNTNR.hi_lvl_strg_i, CNTNR.trlr_i, CNTNR.ship_i) > 1
                THEN 'Y'
                ELSE 'N'
        END co_load_f,
        CNTNR.t_size trlr_size
FROM    prcsg_catg_xref PCX,
        (
                SELECT  DR.hi_lvl_strg_i                     ,
                        TR.trlr_i                            ,
                        SH.ship_i                            ,
                        SH.open_ts                           ,
                        LC.loc_i                             ,
                        NVL(LCD.cntnr_i, LCA.cntnr_i) cntnr_i,
                        CASE
                                WHEN LCA.cntnr_type_c = 'FPS'
                                THEN 'FPS'
                                WHEN lca.orig_c = 'V'
                                THEN 'NMF'
                                ELSE LCD.prcsg_type_c
                        END prcsg_type_c   ,
                        BAT.pull_priority_c,
                        LCD.batch_i        ,
                        LG.load_type_c     ,
                        CASE
                                WHEN LCA.cntnr_type_c = 'OVP'
                                THEN 1/(COUNT(*) OVER (PARTITION BY LCD.cntnr_i))
                                WHEN LCA.cntnr_type_c = 'FCS'
                                THEN 1
                                ELSE SUM(DECODE(LCD.vcp_q, 0, 0, (LCD.item_unit_q/LCD.vcp_q)))
                        END item_q                                                                           ,
                        SUM(DECODE(promo_i, 0, 0, DECODE(LCD.vcp_q, 0, 0, (LCD.item_unit_q/LCD.vcp_q)))) ad_q,
                        SUM(
                                CASE
                                        WHEN lca.orig_c = 'V'
                                        THEN lca.bol_wt_a
                                        ELSE NVL(di.unit_wt_q, 0) * lcd.item_unit_q
                                END ) unit_wt_q                ,
                        (TR.lgth_q * TR.wth_q * TR.ht_q) t_size,
                        LCA.orig_c orig_c
                FROM    load_cntnr_det LCD ,
                        load_cntnr_acum LCA,
                        ship SH            ,
                        trailr TR          ,
                        load_grp LG        ,
                        load_cntnr LC      ,
                        dc_item DI         ,
                        batch BAT          ,
                        Door DR
                WHERE   LCA.cntnr_i            = LCD.cntnr_i(+)
                        AND DR.hi_lvl_strg_i   = TR.hi_lvl_strg_i
                        AND DR.strg_loc_type_c = TR.strg_loc_type_c
                        AND TR.trlr_seq_i      = SH.trlr_seq_i
                        AND TR.arv_ts          = SH.arv_ts
                        AND DR.strg_loc_type_c = 'D'
                        AND DR.door_type_c     = 'S'
                        AND LCA.cntnr_i        = LC.cntnr_i
                        AND SH.close_f         = 'N'
                        AND
                        (
                                (
                                        LG.load_close_f      = 'N'
                                        AND LG.hi_lvl_strg_i = TR.hi_lvl_strg_i
                                )
                                OR LG.ship_i = SH.ship_i
                        )
                        AND LC.load_grp_i     = LG.load_grp_i
                        AND LC.force_divert_f = 'N'
                        AND LCD.dept_i        = di.dept_i(+)
                        AND LCD.class_i       = di.class_i(+)
                        AND LCD.item_i        = di.item_i(+)
                        AND LCD.batch_i       = BAT.batch_i(+)
                GROUP BY DR.hi_lvl_strg_i               ,
                        TR.trlr_i                       ,
                        SH.ship_i                       ,
                        SH.open_ts                      ,
                        LC.loc_i                        ,
                        LCD.cntnr_i                     ,
                        LC.loc_i                        ,
                        LCA.cntnr_type_c                ,
                        LCD.prcsg_type_c                ,
                        BAT.pull_priority_c             ,
                        LG.load_type_c                  ,
                        LCD.batch_i                     ,
                        LG.load_type_c                  ,
                        (TR.lgth_q * TR.wth_q * TR.ht_q),
                        LCA.orig_c                      ,
                        LCA.cntnr_i
        )
        CNTNR,
        (
                SELECT  TR.hi_lvl_strg_i,
                        TR.trlr_i       ,
                        SH.ship_i       ,
                        LC.loc_i        ,
                        LG.load_type_c  ,
                        CASE
                                WHEN SUM(DECODE(load_type_c,'C',1,0)) OVER (PARTITION BY TR.hi_lvl_strg_i,TR.trlr_i,SH.ship_i,LC.loc_i) > = 1
                                THEN MIN(LC.load_ts)
                                ELSE MIN(LC.load_ts)
                        END beg_dt,
                        SYSDATE end_dt
                FROM    load_cntnr LC,
                        load_grp LG  ,
                        trailr TR    ,
                        ship SH
                WHERE   LC.load_grp_i          = LG.load_grp_i
                        AND LG.strg_loc_type_c = 'D'
                        AND
                        (
                                (
                                        LG.load_close_f      = 'N'
                                        AND LG.hi_lvl_strg_i = TR.hi_lvl_strg_i
                                )
                                OR LG.ship_i = SH.ship_i
                        )
                        AND SH.close_f         = 'N'
                        AND TR.strg_loc_type_c = 'D'
                        AND TR.trlr_seq_i      = SH.trlr_seq_i
                        AND TR.arv_ts          = SH.arv_ts
                        AND LC.force_divert_f  = 'N'
                GROUP BY TR.hi_lvl_strg_i,
                        TR.trlr_i        ,
                        SH.ship_i        ,
                        LC.loc_i         ,
                        LG.load_type_c
        )
        TIME_Q
WHERE   PCX.prcsg_type_c   = CNTNR.prcsg_type_c
        AND PCX.loc_type_c =
        (
                SELECT LOC.loc_type_c FROM LOC, dc_config DC WHERE DC.loc_i = LOC.loc_i
        )
        AND CNTNR.hi_lvl_strg_i = TIME_Q.hi_lvl_strg_i
        AND CNTNR.trlr_i        = TIME_Q.trlr_i
        AND CNTNR.ship_i        = TIME_Q.ship_i
        AND CNTNR.loc_i         = TIME_Q.loc_i
        AND CNTNR.load_type_c   = TIME_Q.load_type_c
GROUP BY CNTNR.hi_lvl_strg_i,
        CNTNR.trlr_i        ,
        CNTNR.ship_i        ,
        CNTNR.loc_i         ,
        CNTNR.t_size
ORDER BY door_i       ,
        time_open DESC,
        trlr_wt
/
