Rem
Rem $Header: rdbms/admin/dbmsfs.sql /main/9 2016/02/08 15:47:57 nkedlaya Exp $
Rem
Rem dbmsfs.sql
Rem
Rem Copyright (c) 2011, 2016, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbmsfs.sql - DBMS package for file system operations definition
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/dbmsfs.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/dbmsfs.sql
Rem SQL_PHASE: DBMSFS
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catpdbms.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    nkedlaya    01/07/16 - add new table ofsftab to keep track of all the
Rem                           OFS filesystems created
Rem    msusaira    11/16/15 - add options to umount
Rem    jlasagu     10/08/15 - Add nodenm to ofsmtab
Rem    msusaira    07/17/15 - add fsid to ofsmtab
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    msusaira    09/23/11 - add fsid to ofsdtab
Rem    msusaira    02/14/11 - dbms file system package
Rem    msusaira    02/14/11 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

--*****************************************************************************
-- Package Declaration
--*****************************************************************************

create or replace package dbms_fs AUTHID CURRENT_USER AS

-- DE-HEAD  <- tell SED where to cut when generating fixed package

  -- Creates a file system of type specified by fstype and of name fsname
  -- This is similar to mkfs on Unix
  -- 
  -- fstype - file system type
  -- fsname - name of the file system
  -- fsoptions - a comma separated file system create options
  --
  PROCEDURE make_oracle_fs (fstype  IN varchar2,
                            fsname  IN varchar2,
                            fsoptions  IN varchar2);

  -- Mount an Oracle file system on the specified mount point
  -- This is similar to mount on Unix
  -- 
  -- fstype - file system type
  -- fsname - name of the file system
  -- mount_point - directory where the file system should be mounted
  -- mount_options - a comma separated mount options
  --
  PROCEDURE mount_oracle_fs (fstype  IN varchar2,
                             fsname  IN varchar2,
                             mount_point IN varchar2,
                             mount_options  IN varchar2);

  -- Unmount an Oracle file system on the specified mount point
  -- This is similar to mount on Unix
  -- 
  -- fsname - name of the file system
  -- mount_point - directory where the file system is mounted
  -- umount options - options used for unmount - force option
  --
  PROCEDURE unmount_oracle_fs (fsname  IN varchar2,
                               mount_point  IN varchar2,
                               umount_options IN varchar2 default NULL);


  -- Destroys a file system of type specified by fstype and of name fsname
  -- This is similar to zfs destroy <filesystem>
  -- 
  -- fstype - file system type
  -- fsname - name of the file system
  --
  PROCEDURE destroy_oracle_fs (fstype  IN varchar2,
                               fsname  IN varchar2);

-------------------------------------------------------------------------------

pragma TIMESTAMP('2011-02-14:12:00:00');

-------------------------------------------------------------------------------


end;

-- CUT_HERE    <- tell sed where to chop off the rest

/
CREATE OR REPLACE PUBLIC SYNONYM dbms_fs FOR sys.dbms_fs
/
GRANT EXECUTE ON dbms_fs TO dba
/

show errors;

rem Oracle File System Mount Table
create table ofsmtab$
(
  mntpath              varchar2(1024),   /* mount point */
  path                 varchar2(1024),   /* underlying filesystem path */
  mntopts              varchar2(1024),   /* XXX should this be a string? */
  fstype               varchar(64),      /* file system type */
  mntdate              date,             /* mount creation date */
  fsid                 integer,          /* file system id */
  nodenm               varchar2(256)     /* node name */
)
/

rem Oracle File System Object Table
create table ofsotab$
(
  path                 varchar2(1024),                    /* mount path name */
  f_type               integer,                /* type of Oracle File System */
  f_bsize              integer,               /* optimal transfer block size */
  f_blocks             integer,         /* total number of data blocks in fs */
  f_bfree              integer,                         /* free blocks in fs */
  f_bavail             integer,     /* free blocks available to regular user */
  f_files              integer,               /* total number of files in fs */
  f_ffree              integer,           /* number of free file nodes in fs */
  f_fsid               integer,                            /* file system id */
  f_namelen            integer                /* maximum length of file name */
)
/

rem Oracle File System Directory Object Table
create table ofsdtab$
(
  name                 varchar2(1024),                          /* file name */
  fsid                 integer,                            /* file system id */
  st_ino               integer,                              /* inode number */
  st_pino              integer,                       /* parent inode number */
  st_mode              integer,                                 /* file mode */
  st_nlink             integer,                                /* link count */
  st_uid               integer,                                   /* user id */
  st_gid               integer,                                  /* group id */
  st_size              integer,                     /* size of file in bytes */
  st_blksize           integer,                /* optimal block size for I/O */
  st_blocks            integer,       /* Number of 512 byte blocks allocated */
  st_atime             integer,                       /* time of last access */
  st_mtime             integer,                 /* time of last modification */
  st_ctime             integer,                /* time of last status change */
  st_atimens           integer,            /* time of last access - nano sec */
  st_mtimens           integer,      /* time of last modification - nano sec */
  st_ctimens           integer      /* time of last status change - nano sec */
)
/

rem Oracle File System Filesystems created table
create table ofsftab$
(
  fstype                  varchar(64) not null,          /* file system type */
  fsname                  varchar(64) not null,  /* created file system name */
                                          /* owner of the fs meta-data table */
  fs_metadata_table_owner varchar2(30) default 'SYS',
  fs_metadata_table_name  varchar2(30),           /* fs meta-data table name */
                                               /* owner of the fs data table */
  fs_data_table_owner     varchar2(30) default 'SYS',
  fs_data_table_name      varchar2(30),                /* fs data table name */
  fs_creation_time        date default sysdate,     /* fs creation date/time */
  constraint pk_ofsftab$ primary key (fstype, fsname)
)
/

@?/rdbms/admin/sqlsessend.sql
