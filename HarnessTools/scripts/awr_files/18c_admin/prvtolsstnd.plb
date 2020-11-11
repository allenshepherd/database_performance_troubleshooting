UPDATE LBACSYS.ols$props SET value$='0' where name ='OID_STATUS_FLAG';
EXECUTE LBACSYS.LBAC_CACHE.UPDATE_PROPS_TABLE(0, FALSE);
CREATE OR REPLACE FUNCTION LBACSYS.to_numeric_data_label wrapped 
a000000
1
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
8
16f 124
NrynfLAmgIsv5RvoHJFXikJGvGEwg43QJCisfC+VkPg+e+bmdnZsy1uOfgnLJSQbWbLF1r0n
4KX4BWbFbRsZJZg0/j/t2bLo7OpaBwrtaHJVzfVLxp8ReZq5mEFQZJR3jY/eC/PyYK0lpIX1
mcCUc4XnWnVL8gxKlaqIsgIscehvl8B32HDxyVZb7yHp76JaFOtgUf2X295x8/dn/AZK7qs9
TWOqzedfoRWeSvmanPbtQvj1AYD2OatB+ToNs+RffQNwBBJooJWigRZJRNwLdZVtW5cl6nc=


/
show errors;
CREATE OR REPLACE PUBLIC SYNONYM to_numeric_data_label 
                     FOR LBACSYS.to_numeric_data_label;
CREATE OR REPLACE PUBLIC SYNONYM to_data_label
                     FOR  LBACSYS.to_numeric_data_label;
CREATE OR REPLACE VIEW LBACSYS.sa$admin AS
SELECT POL#, pol_name, granted_role admin_role, R.grantee usr_name
  FROM LBACSYS.ols$pol P,
       sys.dba_role_privs R
 WHERE P.package = 'LBAC$SA'
   AND R.granted_role = P.pol_role;
CREATE OR REPLACE VIEW LBACSYS.all_sa_policies AS
   SELECT p.pol_name as policy_name, p.column_name, p.status, p.policy_options
     FROM LBACSYS.sa$pol p
    WHERE pol# in (select pol# from LBACSYS.sa$admin
                   where usr_name = SYS_CONTEXT('USERENV', 'CURRENT_USER'));
CREATE OR REPLACE VIEW LBACSYS.all_sa_schema_policies AS
  SELECT s.policy_name, schema_name, s.status, schema_options
    FROM LBACSYS.sa$pol p, LBACSYS.dba_lbac_schema_policies s
   WHERE p.pol_name = s.policy_name
     AND pol# in (select pol# from LBACSYS.sa$admin
                  where usr_name = SYS_CONTEXT('USERENV', 'CURRENT_USER'));
CREATE OR REPLACE VIEW LBACSYS.all_sa_table_policies AS
  SELECT t.policy_name, schema_name, table_name, t.status,
         table_options, function, predicate
    FROM LBACSYS.sa$pol p, LBACSYS.dba_lbac_table_policies t
   WHERE p.pol_name=t.policy_name
     AND pol# in (select pol# from LBACSYS.sa$admin
                  where usr_name = SYS_CONTEXT('USERENV', 'CURRENT_USER'));
CREATE OR REPLACE VIEW LBACSYS.all_sa_labels AS
  SELECT p.pol_name AS policy_name,
         l.slabel   AS label,
         l.nlabel   AS label_tag,
         DECODE (l.flags,2,'USER LABEL',
                 3, 'USER/DATA LABEL', 'UNDEFINED') AS label_type
   FROM LBACSYS.ols$lab l, LBACSYS.sa$pol p
  WHERE p.pol# = l.pol#
    AND (p.pol# in (select pol# from LBACSYS.sa$admin
                    where usr_name = SYS_CONTEXT('USERENV', 'CURRENT_USER'))
         OR
         LBACSYS.lbac$sa.enforce_read(p.pol_name, l.ilabel)>0);
CREATE OR REPLACE VIEW LBACSYS.all_sa_data_labels AS
  SELECT p.pol_name AS policy_name,
         l.slabel   AS label,
         l.nlabel   AS label_tag
   FROM LBACSYS.ols$lab l, LBACSYS.sa$pol p
  WHERE p.pol# = l.pol#
    AND BITAND(l.flags, 1) = 1
    AND (p.pol# in (select pol# from LBACSYS.sa$admin
                    where usr_name = SYS_CONTEXT('USERENV', 'CURRENT_USER'))
         OR
         lbacsys.lbac$sa.enforce_read(p.pol_name, l.ilabel)>0);
CREATE OR REPLACE VIEW LBACSYS.all_sa_levels AS
   SELECT p.pol_name as policy_name, l.level# AS level_num,
          l.code AS short_name, l.name AS long_name
     FROM LBACSYS.sa$pol p, LBACSYS.ols$levels l
    WHERE p.pol# = l.pol#
      AND p.pol# in (select pol# from LBACSYS.sa$admin
                     where usr_name = SYS_CONTEXT('USERENV', 'CURRENT_USER'))
    UNION
   SELECT p.pol_name as policy_name, l.level# AS level_num,
          l.code AS short_name, l.name AS long_name
     FROM LBACSYS.sa$pol p, LBACSYS.ols$levels l, LBACSYS.ols$user_levels ul
    WHERE p.pol# = l.pol#
      and l.pol# = ul.pol#
      and l.level# <= ul.max_level
      and
      ul.usr_name = LBACSYS.sa_session.sa_user_name(
                            LBACSYS.lbac_cache.policy_name(ul.pol#));
CREATE OR REPLACE VIEW LBACSYS.all_sa_compartments AS
   SELECT p.pol_name as policy_name, c.comp# AS comp_num,
          c.code AS short_name, c.name AS long_name
     FROM LBACSYS.sa$pol p, LBACSYS.ols$compartments c
    WHERE p.pol# = c.pol#
      and (p.pol# in (select pol# from LBACSYS.sa$admin
                      where usr_name = SYS_CONTEXT('USERENV', 'CURRENT_USER'))
           OR
          (c.pol#,c.comp#) in (select pol#,comp#
                               from LBACSYS.ols$user_compartments
                             where usr_name = LBACSYS.sa_session.sa_user_name(
                                      LBACSYS.lbac_cache.policy_name(pol#))));
CREATE OR REPLACE VIEW LBACSYS.all_sa_groups AS
   SELECT p.pol_name as policy_name, g.group# AS group_num,
          g.code AS short_name, g.name AS long_name,
          g.parent# AS parent_num, pg.code AS parent_name
     FROM LBACSYS.sa$pol p, LBACSYS.ols$groups g, LBACSYS.ols$groups pg
    WHERE p.pol# = g.pol#
      AND g.pol# = pg.pol# (+)
      AND g.parent# = pg.group#(+)
      and (p.pol# in (select pol# from LBACSYS.sa$admin
                      where usr_name = SYS_CONTEXT('USERENV', 'CURRENT_USER'))
           OR
          (g.pol#,g.group#) in (select pol#,group#
                                from LBACSYS.ols$user_groups
                            where usr_name = LBACSYS.sa_session.sa_user_name(
                                     LBACSYS.lbac_cache.policy_name(pol#))));
CREATE OR REPLACE VIEW LBACSYS.all_sa_group_hierarchy AS
   SELECT p.pol_name as policy_name, g.hierarchy_level, g.group_name
     FROM (SELECT LEVEL AS hierarchy_level,
               RPAD(' ',2*LEVEL,' ') || code || ' - ' ||  name AS group_name,
               pol#
             FROM LBACSYS.ols$groups
                  CONNECT BY PRIOR pol#=pol# AND PRIOR group#=parent#
            START WITH ((pol# in (select pol# from LBACSYS.sa$admin
                      where usr_name = SYS_CONTEXT('USERENV', 'CURRENT_USER'))
                         and parent# IS NULL)
                        or
                        (pol#,group#) in
                        (select pol#,group# from LBACSYS.ols$user_groups
                          where usr_name = LBACSYS.sa_session.sa_user_name(
                                    LBACSYS.lbac_cache.policy_name(pol#))))
          ) g,
          LBACSYS.sa$pol p
    WHERE g.pol#=p.pol#;
CREATE OR REPLACE VIEW LBACSYS.all_sa_user_levels AS
   SELECT DISTINCT p.pol_name AS policy_name,
          ul.usr_name AS user_name,
          lmax.code AS max_level,
          lmin.code AS min_level,
          ldef.code AS def_level,
          lrow.code AS row_level
     FROM LBACSYS.sa$pol p, LBACSYS.ols$user_levels ul,
          LBACSYS.ols$levels lmax, LBACSYS.ols$levels lmin,
          LBACSYS.ols$levels ldef, LBACSYS.ols$levels lrow
    WHERE p.pol#=ul.pol#
      AND ul.pol#=lmax.pol#
      AND ul.pol#=lmin.pol#
      AND ul.pol#=ldef.pol#
      AND ul.pol#=lrow.pol#
      AND ul.max_level = lmax.level#
      AND ul.min_level = lmin.level#
      AND ul.def_level = ldef.level#
      AND ul.row_level = lrow.level#
      AND (p.pol# in (select pol# from LBACSYS.sa$admin
                      where usr_name = SYS_CONTEXT('USERENV', 'CURRENT_USER'))
           or
           ul.usr_name = LBACSYS.sa_session.sa_user_name(
                         LBACSYS.lbac_cache.policy_name(p.pol#)));
CREATE OR REPLACE VIEW LBACSYS.all_sa_user_compartments AS
   SELECT p.pol_name AS policy_name, uc.usr_name AS user_name,
          c.code AS comp, DECODE(uc.rw_access,'1','WRITE','READ') AS rw_access,
          uc.def_comp, uc.row_comp
     FROM LBACSYS.sa$pol p, LBACSYS.ols$user_compartments uc,
          LBACSYS.ols$compartments c
    WHERE p.pol#=uc.pol#
      AND uc.pol#=c.pol#
      AND uc.comp# = c.comp#
      AND (p.pol# in (select pol# from LBACSYS.sa$admin
                      where usr_name = SYS_CONTEXT('USERENV', 'CURRENT_USER'))
           or
           uc.usr_name = LBACSYS.sa_session.sa_user_name(
                         LBACSYS.lbac_cache.policy_name(p.pol#)));
CREATE OR REPLACE VIEW LBACSYS.all_sa_user_groups AS
   SELECT p.pol_name AS policy_name, ug.usr_name AS user_name,
          g.code AS grp, DECODE(ug.rw_access,'1','WRITE','READ') AS rw_access,
          ug.def_group, ug.row_group
     FROM LBACSYS.sa$pol p, LBACSYS.ols$user_groups ug, LBACSYS.ols$groups g
    WHERE p.pol#=ug.pol#
      AND ug.pol#=g.pol#
      AND ug.group# = g.group#
      AND (p.pol# in (select pol# from LBACSYS.sa$admin
                      where usr_name = SYS_CONTEXT('USERENV', 'CURRENT_USER'))
           or
           ug.usr_name = LBACSYS.sa_session.sa_user_name(
                         LBACSYS.lbac_cache.policy_name(p.pol#)));
CREATE OR REPLACE VIEW LBACSYS.all_sa_users AS
   SELECT user_name,  u.policy_name, user_privileges,
          NULL AS user_labels,
          LABEL1 AS MAX_READ_LABEL, LABEL2 AS MAX_WRITE_LABEL,
          LABEL3 AS MIN_WRITE_LABEL , LABEL4 AS DEFAULT_READ_LABEL,
          LABEL5 AS DEFAULT_WRITE_LABEL, LABEL6 AS DEFAULT_ROW_LABEL
     FROM LBACSYS.sa$pol p, LBACSYS.dba_ols_users u
    WHERE p.pol_name=u.policy_name
      AND (p.pol# in (select pol# from LBACSYS.sa$admin
                      where usr_name = SYS_CONTEXT('USERENV', 'CURRENT_USER'))
           or
           u.user_name = LBACSYS.sa_session.sa_user_name(
                         LBACSYS.lbac_cache.policy_name(p.pol#)));
CREATE OR REPLACE VIEW LBACSYS.all_sa_user_labels AS
   SELECT user_name,
          policy_name,
          user_labels as labels,
          MAX_READ_LABEL,
          MAX_WRITE_LABEL, MIN_WRITE_LABEL ,DEFAULT_READ_LABEL,
          DEFAULT_WRITE_LABEL ,  DEFAULT_ROW_LABEL
     FROM LBACSYS.all_sa_users
    WHERE MAX_READ_LABEL IS NOT NULL;
CREATE OR REPLACE VIEW LBACSYS.all_sa_programs AS
   SELECT schema_name, program_name, p.policy_name, program_privileges as
          prog_privileges, NULL as prog_labels
     FROM LBACSYS.sa$pol, LBACSYS.dba_sa_prog_privs p
    WHERE pol_name=p.policy_name
      AND pol# in (select pol# from LBACSYS.sa$admin
                   where usr_name = SYS_CONTEXT('USERENV', 'CURRENT_USER'));
CREATE OR REPLACE VIEW LBACSYS.all_sa_user_privs AS
  SELECT user_name,
         policy_name,
         user_privileges
    FROM LBACSYS.all_sa_users
   WHERE user_privileges IS NOT NULL;
CREATE OR REPLACE VIEW LBACSYS.all_sa_prog_privs AS
  SELECT schema_name, program_name, policy_name,
         prog_privileges as program_privileges
    FROM LBACSYS.all_sa_programs
   WHERE prog_privileges IS NOT NULL;
CREATE OR REPLACE VIEW LBACSYS.all_sa_audit_options AS
  SELECT a.policy_name, a.user_name, APY, REM, SET_, PRV
    FROM LBACSYS.sa$pol p, LBACSYS.dba_ols_audit_options a
   WHERE p.pol_name = a.policy_name
     AND p.pol# in (select pol# from LBACSYS.sa$admin
                    where usr_name = SYS_CONTEXT('USERENV', 'CURRENT_USER'));
