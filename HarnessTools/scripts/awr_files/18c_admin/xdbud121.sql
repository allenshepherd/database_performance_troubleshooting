Rem
Rem $Header: rdbms/admin/xdbud121.sql /main/11 2017/04/27 17:09:45 raeburns Exp $
Rem
Rem xdbud121.sql
Rem
Rem Copyright (c) 2014, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      xdbud121.sql - XDB Upgrade Dependent objects from 12.1.0
Rem
Rem    DESCRIPTION
Rem      This script upgrades the XDB dependent objects from release 12.1.0
Rem      to the current release.
Rem
Rem    NOTES
Rem     It is invoked by xdbud.sql, and invokes the xdbudNNN script for the 
Rem     subsequent release.
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/xdbud121.sql 
Rem    SQL_SHIPPED_FILE: rdbms/admin/xdbud121.sql 
Rem    SQL_PHASE: UPGRADE
Rem    SQL_STARTUP_MODE: UPGRADE 
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: rdbms/admin/xdbud.sql 
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    raeburns    04/15/17 - Bug Bug 25790192: Use UPGRADE for SQL_PHASE
Rem    qyu         11/10/16 - invoke xdbud122.sql
Rem    sriksure    08/17/16 - Bug 22967968 - Moving inline XML schemas to
Rem                           external schema files
Rem    qyu         07/25/16 - add file metadata
Rem    huiz        12/12/14 - bug# 18857697: annotate XDBFolderListing.xsd 
Rem    hxzhang     06/04/14 - bug#18857697, annotate XDB schema
Rem    raeburns    05/14/14 - move xdb$ttset changes to xdbuo121.sql
Rem                         - drop obsolete migr9202status table
Rem    pyam        04/29/14 - back out huiz_bug-18406799, huiz_bug-18609669
Rem    huiz        04/17/14 - bug 18609669: make fix of bug 18406799 and
Rem                           18490650 in major release upgrade script 
Rem    raeburns    04/13/14 - move 121 actions post reload
Rem    raeburns    10/25/13 - XDB upgrade restructure
Rem    raeburns    10/25/13 - Created
Rem

Rem ================================================================
Rem BEGIN XDB Dependent Object Upgrade from 12.1.0
Rem ================================================================

-- migr9202status no longer used
-- must be restored for downgrade in xdeud121.sql
DROP TABLE xdb.migr9202status;

-- First remove XDBFolderListing.xsd and then re-register it with genTables false
declare
 c NUMBER;
 csxxinurl VARCHAR2(2000) := 'http://xmlns.oracle.com/xdb/XDBFolderListing.xsd';
begin
  select count(*) into c from xdb.xdb$schema s
   where s.xmldata.schema_url = csxxinurl;

  if c > 0 then
    dbms_xmlschema.deleteschema(csxxinurl, dbms_xmlschema.delete_cascade);
  end if;
  exception when others then raise;
end;
/

declare
  FLXSD BFILE := dbms_metadata_hack.get_bfile('xdbfolderlisting.xsd');
  FLURL VARCHAR2(2000) := 'http://xmlns.oracle.com/xdb/XDBFolderListing.xsd';

begin
dbms_metadata_hack.cre_dir();
xdb.dbms_xmlschema.registerSchema(FLURL, FLXSD, FALSE, TRUE, FALSE, FALSE, FALSE, 'XDB');
end;
/

-- First remove stats.xsd and then re-register it
declare
 c NUMBER;
 inurl VARCHAR2(2000) := 'http://xmlns.oracle.com/xdb/stats.xsd';
begin
  select count(*) into c from xdb.xdb$schema s
    where s.xmldata.schema_url = inurl;

  if c > 0 then
    dbms_xmlschema.deleteschema(inurl, dbms_xmlschema.delete_cascade);
  end if;
  exception when others then raise;
end;
/

/* --------------------------------------------------------------------------*/
/* register statistics schema
/* --------------------------------------------------------------------------*/
declare
  STATSXSD BFILE := dbms_metadata_hack.get_bfile('stats.xsd');
  STATSURL VARCHAR2(2000) := 'http://xmlns.oracle.com/xdb/stats.xsd';
  n integer;
begin
  select count(*) into n from xdb.xdb$schema s
  where s.xmldata.schema_url = 'http://xmlns.oracle.com/xdb/stats.xsd';

  dbms_metadata_hack.cre_dir();
  if (n = 0) then
    xdb.dbms_xmlschema.registerSchema(STATSURL, STATSXSD, FALSE, TRUE,
                                      FALSE, TRUE, FALSE, 'XDB');
  end if;
end;
/

Rem ================================================================
Rem END XDB Dependent Object Upgrade from 12.1.0
Rem ================================================================

Rem ================================================================
Rem BEGIN XDB Dependent Object Upgrade from the next release
Rem ================================================================

@@xdbud122.sql

