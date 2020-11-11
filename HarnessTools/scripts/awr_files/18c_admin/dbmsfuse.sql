Rem
Rem $Header: rdbms/admin/dbmsfuse.sql /main/12 2015/02/05 18:38:50 siteotia Exp $
Rem
Rem dbmsfuse.sql
Rem
Rem Copyright (c) 2008, 2015, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbmsfuse.sql - The DBFS client adapter specification.
Rem
Rem    DESCRIPTION
Rem      The DBFS client adapter specification.
Rem
Rem    NOTES
Rem      Specification for the "dbms_fuse" package.
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/dbmsfuse.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/dbmsfuse.sql
Rem SQL_PHASE: DBMSFUSE
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catpdbms.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    kkunchit    01/21/15 - project-47046: dbfs support for posix locking
Rem    surman      12/29/13 - 13922626: Update SQL metadata
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    kkunchit    05/26/11 - bug-12568334: unified attribute views
Rem    kkunchit    05/23/11 - bug-12582607: nanosecond resolution timestamps
Rem    kkunchit    01/04/11 - bug-10630023: split rename/move semantics
Rem    kkunchit    08/16/10 - dbfs_client/xattr API conformance
Rem    kkunchit    07/27/10 - bug-9956078: dbfs fastpath
Rem    kkunchit    07/03/10 - bug-9881611: readdir enhancements
Rem    kkunchit    09/16/08 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql



/* ------------ dbms_fuse client-side adapter for the DBFS API ------------- */
/*
 * The "dbms_fuse" package contains a near 1-to-1 mapping between operations
 * invoked by the DBFS client and PL/SQL calls that translate these
 * operations into the DBFS API.
 *
 * The DBFS client is thus insulated from much of the complexities of the
 * DBFS API, RDBMS types, etc.
 *
 * The "dbms_fuse" package also provides various defaults, and performs
 * timestamp translation from the RDBMS formats to the Unix epoch.
 *
 */

create or replace package dbms_fuse
    authid current_user
as



    -- inode types
    S_IFDIR                 constant pls_integer    := 16384;
    S_IFLNK                 constant pls_integer    := 40960;
    S_IFREG                 constant pls_integer    := 32768;

    -- file modes
    MODE_DIR                constant pls_integer    := 16877;  /* drwxr-xr-x */
    MODE_LINK               constant pls_integer    := 41471;  /* lrwxrwxrwx */
    MODE_FILE               constant pls_integer    := 33188;  /* -rw-r--r-- */

    -- default uid/gid
    DEFAULT_UID             constant pls_integer    := 0;            /* root */
    DEFAULT_GID             constant pls_integer    := 0;            /* root */

    -- posix properties
    posix_nlink             constant varchar2(32)   := 'posix:nlink';
    posix_mode              constant varchar2(32)   := 'posix:mode';
    posix_uid               constant varchar2(32)   := 'posix:uid';
    posix_gid               constant varchar2(32)   := 'posix:gid';

    -- extended attributes flags
    XATTR_CREATE            constant pls_integer    := 1;
    XATTR_REPLACE           constant pls_integer    := 2;



    type dir_entry_t is record (
        path        varchar2(1024),              /* dbms_dbfs_content.path_t */
        item_name   varchar2(256),               /* dbms_dbfs_content.name_t */
        st_ino      integer,
        st_mode     integer,
        st_nlink    integer,
        st_uid      integer,
        st_gid      integer,
        st_size     integer,
        st_blksize  integer,
        st_blocks   integer,
        st_atime    integer,
        st_mtime    integer,
        st_ctime    integer,
        st_atimens  integer,
        st_mtimens  integer,
        st_ctimens  integer
    );
    type dir_entries_t is table of dir_entry_t;


    /* table of dbms_dbfs_content.propname_t */
    type propnames_t is table of varchar2(32);


    function    fs_getattr(
        path            in              varchar2,
        st_ino          out             integer,
        st_mode         out             integer,
        st_nlink        out             integer,
        st_uid          out             integer,
        st_gid          out             integer,
        st_size         out             integer,
        st_blksize      out             integer,
        st_blocks       out             integer,
        st_atime        out             integer,
        st_mtime        out             integer,
        st_ctime        out             integer)
        return  integer;

    function    fs_getattr(
        path            in              varchar2,
        st_ino          out             integer,
        st_mode         out             integer,
        st_nlink        out             integer,
        st_uid          out             integer,
        st_gid          out             integer,
        st_size         out             integer,
        st_blksize      out             integer,
        st_blocks       out             integer,
        st_atime        out             integer,
        st_mtime        out             integer,
        st_ctime        out             integer,
        st_atimens      out             integer,
        st_mtimens      out             integer,
        st_ctimens      out             integer)
        return  integer;


    function    fs_readlink(
        path            in              varchar2,
        link            out nocopy      varchar2)
        return  integer;


    function    fs_mknod(
        path            in              varchar2,
        st_mode         in              integer     default MODE_FILE,
        st_uid          in              integer     default 0,
        st_gid          in              integer     default 0)
        return  integer;

    function    fs_mknod(
        path            in              varchar2,
        st_mode         in              integer     default MODE_FILE,
        st_uid          in              integer     default 0,
        st_gid          in              integer     default 0,
        ret_ino         out             integer,
        ret_mode        out             integer,
        ret_nlink       out             integer,
        ret_uid         out             integer,
        ret_gid         out             integer,
        ret_size        out             integer,
        ret_blksize     out             integer,
        ret_blocks      out             integer,
        ret_atime       out             integer,
        ret_mtime       out             integer,
        ret_ctime       out             integer)
        return  integer;

    function    fs_mknod(
        path            in              varchar2,
        st_mode         in              integer     default MODE_FILE,
        st_uid          in              integer     default 0,
        st_gid          in              integer     default 0,
        ret_ino         out             integer,
        ret_mode        out             integer,
        ret_nlink       out             integer,
        ret_uid         out             integer,
        ret_gid         out             integer,
        ret_size        out             integer,
        ret_blksize     out             integer,
        ret_blocks      out             integer,
        ret_atime       out             integer,
        ret_mtime       out             integer,
        ret_ctime       out             integer,
        ret_atimens     out             integer,
        ret_mtimens     out             integer,
        ret_ctimens     out             integer)
        return  integer;


    function    fs_mkdir(
        path            in              varchar2,
        st_mode         in              integer     default MODE_DIR,
        st_uid          in              integer     default 0,
        st_gid          in              integer     default 0)
        return  integer;

    function    fs_mkdir(
        path            in              varchar2,
        st_mode         in              integer     default MODE_DIR,
        st_uid          in              integer     default 0,
        st_gid          in              integer     default 0,
        ret_ino         out             integer,
        ret_mode        out             integer,
        ret_nlink       out             integer,
        ret_uid         out             integer,
        ret_gid         out             integer,
        ret_size        out             integer,
        ret_blksize     out             integer,
        ret_blocks      out             integer,
        ret_atime       out             integer,
        ret_mtime       out             integer,
        ret_ctime       out             integer)
        return  integer;

    function    fs_mkdir(
        path            in              varchar2,
        st_mode         in              integer     default MODE_DIR,
        st_uid          in              integer     default 0,
        st_gid          in              integer     default 0,
        ret_ino         out             integer,
        ret_mode        out             integer,
        ret_nlink       out             integer,
        ret_uid         out             integer,
        ret_gid         out             integer,
        ret_size        out             integer,
        ret_blksize     out             integer,
        ret_blocks      out             integer,
        ret_atime       out             integer,
        ret_mtime       out             integer,
        ret_ctime       out             integer,
        ret_atimens     out             integer,
        ret_mtimens     out             integer,
        ret_ctimens     out             integer)
        return  integer;


    function    fs_unlink(
        path            in              varchar2)
        return  integer;

    function    fs_rmdir(
        path            in              varchar2)
        return  integer;


    function    fs_symlink(
        path            in              varchar2,
        link            in              varchar2,
        st_uid          in              integer     default 0,
        st_gid          in              integer     default 0)
        return  integer;

    function    fs_symlink(
        path            in              varchar2,
        link            in              varchar2,
        st_uid          in              integer     default 0,
        st_gid          in              integer     default 0,
        ret_ino         out             integer,
        ret_mode        out             integer,
        ret_nlink       out             integer,
        ret_uid         out             integer,
        ret_gid         out             integer,
        ret_size        out             integer,
        ret_blksize     out             integer,
        ret_blocks      out             integer,
        ret_atime       out             integer,
        ret_mtime       out             integer,
        ret_ctime       out             integer)
        return  integer;

    function    fs_symlink(
        path            in              varchar2,
        link            in              varchar2,
        st_uid          in              integer     default 0,
        st_gid          in              integer     default 0,
        ret_ino         out             integer,
        ret_mode        out             integer,
        ret_nlink       out             integer,
        ret_uid         out             integer,
        ret_gid         out             integer,
        ret_size        out             integer,
        ret_blksize     out             integer,
        ret_blocks      out             integer,
        ret_atime       out             integer,
        ret_mtime       out             integer,
        ret_ctime       out             integer,
        ret_atimens     out             integer,
        ret_mtimens     out             integer,
        ret_ctimens     out             integer)
        return  integer;


    function    fs_rename(
        opath           in              varchar2,
        npath           in              varchar2)
        return  integer;

    function    fs_move(
        opath           in              varchar2,
        npath           in              varchar2)
        return  integer;


    function    fs_link(
        path            in              varchar2,
        link            in              varchar2,
        st_uid          in              integer     default 0,
        st_gid          in              integer     default 0)
        return  integer;

    function    fs_link(
        path            in              varchar2,
        link            in              varchar2,
        st_uid          in              integer     default 0,
        st_gid          in              integer     default 0,
        ret_ino         out             integer,
        ret_mode        out             integer,
        ret_nlink       out             integer,
        ret_uid         out             integer,
        ret_gid         out             integer,
        ret_size        out             integer,
        ret_blksize     out             integer,
        ret_blocks      out             integer,
        ret_atime       out             integer,
        ret_mtime       out             integer,
        ret_ctime       out             integer)
        return  integer;

    function    fs_link(
        path            in              varchar2,
        link            in              varchar2,
        st_uid          in              integer     default 0,
        st_gid          in              integer     default 0,
        ret_ino         out             integer,
        ret_mode        out             integer,
        ret_nlink       out             integer,
        ret_uid         out             integer,
        ret_gid         out             integer,
        ret_size        out             integer,
        ret_blksize     out             integer,
        ret_blocks      out             integer,
        ret_atime       out             integer,
        ret_mtime       out             integer,
        ret_ctime       out             integer,
        ret_atimens     out             integer,
        ret_mtimens     out             integer,
        ret_ctimens     out             integer)
        return  integer;


    function    fs_chmod(
        path            in              varchar2,
        st_mode         in              integer)
        return  integer;

    function    fs_chmod(
        path            in              varchar2,
        st_mode         in              integer,
        ret_ino         out             integer,
        ret_mode        out             integer,
        ret_nlink       out             integer,
        ret_uid         out             integer,
        ret_gid         out             integer,
        ret_size        out             integer,
        ret_blksize     out             integer,
        ret_blocks      out             integer,
        ret_atime       out             integer,
        ret_mtime       out             integer,
        ret_ctime       out             integer)
        return  integer;

    function    fs_chmod(
        path            in              varchar2,
        st_mode         in              integer,
        ret_ino         out             integer,
        ret_mode        out             integer,
        ret_nlink       out             integer,
        ret_uid         out             integer,
        ret_gid         out             integer,
        ret_size        out             integer,
        ret_blksize     out             integer,
        ret_blocks      out             integer,
        ret_atime       out             integer,
        ret_mtime       out             integer,
        ret_ctime       out             integer,
        ret_atimens     out             integer,
        ret_mtimens     out             integer,
        ret_ctimens     out             integer)
        return  integer;


    function    fs_chown(
        path            in              varchar2,
        st_uid          in              integer,
        st_gid          in              integer)
        return  integer;

    function    fs_chown(
        path            in              varchar2,
        st_uid          in              integer,
        st_gid          in              integer,
        ret_ino         out             integer,
        ret_mode        out             integer,
        ret_nlink       out             integer,
        ret_uid         out             integer,
        ret_gid         out             integer,
        ret_size        out             integer,
        ret_blksize     out             integer,
        ret_blocks      out             integer,
        ret_atime       out             integer,
        ret_mtime       out             integer,
        ret_ctime       out             integer)
        return  integer;

    function    fs_chown(
        path            in              varchar2,
        st_uid          in              integer,
        st_gid          in              integer,
        ret_ino         out             integer,
        ret_mode        out             integer,
        ret_nlink       out             integer,
        ret_uid         out             integer,
        ret_gid         out             integer,
        ret_size        out             integer,
        ret_blksize     out             integer,
        ret_blocks      out             integer,
        ret_atime       out             integer,
        ret_mtime       out             integer,
        ret_ctime       out             integer,
        ret_atimens     out             integer,
        ret_mtimens     out             integer,
        ret_ctimens     out             integer)
        return  integer;


    function    fs_truncate(
        path            in              varchar2,
        newlen          in              number)
        return  integer;

    function    fs_truncate(
        path            in              varchar2,
        newlen          in              number,
        ret_ino         out             integer,
        ret_mode        out             integer,
        ret_nlink       out             integer,
        ret_uid         out             integer,
        ret_gid         out             integer,
        ret_size        out             integer,
        ret_blksize     out             integer,
        ret_blocks      out             integer,
        ret_atime       out             integer,
        ret_mtime       out             integer,
        ret_ctime       out             integer)
        return  integer;

    function    fs_truncate(
        path            in              varchar2,
        newlen          in              number,
        ret_ino         out             integer,
        ret_mode        out             integer,
        ret_nlink       out             integer,
        ret_uid         out             integer,
        ret_gid         out             integer,
        ret_size        out             integer,
        ret_blksize     out             integer,
        ret_blocks      out             integer,
        ret_atime       out             integer,
        ret_mtime       out             integer,
        ret_ctime       out             integer,
        ret_atimens     out             integer,
        ret_mtimens     out             integer,
        ret_ctimens     out             integer)
        return  integer;


    function    fs_utime(
        path            in              varchar2,
        atime           in              integer,
        mtime           in              integer,
        atimens         in              integer     default 0,
        mtimens         in              integer     default 0)
        return  integer;

    function    fs_utime(
        path            in              varchar2,
        atime           in              integer,
        mtime           in              integer,
        ret_ino         out             integer,
        ret_mode        out             integer,
        ret_nlink       out             integer,
        ret_uid         out             integer,
        ret_gid         out             integer,
        ret_size        out             integer,
        ret_blksize     out             integer,
        ret_blocks      out             integer,
        ret_atime       out             integer,
        ret_mtime       out             integer,
        ret_ctime       out             integer)
        return  integer;

    function    fs_utime(
        path            in              varchar2,
        atime           in              integer,
        mtime           in              integer,
        atimens         in              integer,
        mtimens         in              integer,
        ret_ino         out             integer,
        ret_mode        out             integer,
        ret_nlink       out             integer,
        ret_uid         out             integer,
        ret_gid         out             integer,
        ret_size        out             integer,
        ret_blksize     out             integer,
        ret_blocks      out             integer,
        ret_atime       out             integer,
        ret_mtime       out             integer,
        ret_ctime       out             integer,
        ret_atimens     out             integer,
        ret_mtimens     out             integer,
        ret_ctimens     out             integer)
        return  integer;


    function    fs_open(
        path            in              varchar2,
        content         out nocopy      blob,
        forWrite        in              integer     default 0)
        return  integer;

    function    fs_open(
        path            in              varchar2,
        content         out nocopy      blob,
        forWrite        in              integer     default 0,
        ret_ino         out             integer,
        ret_mode        out             integer,
        ret_nlink       out             integer,
        ret_uid         out             integer,
        ret_gid         out             integer,
        ret_size        out             integer,
        ret_blksize     out             integer,
        ret_blocks      out             integer,
        ret_atime       out             integer,
        ret_mtime       out             integer,
        ret_ctime       out             integer)
        return  integer;

    function    fs_open(
        path            in              varchar2,
        content         out nocopy      blob,
        forWrite        in              integer     default 0,
        ret_ino         out             integer,
        ret_mode        out             integer,
        ret_nlink       out             integer,
        ret_uid         out             integer,
        ret_gid         out             integer,
        ret_size        out             integer,
        ret_blksize     out             integer,
        ret_blocks      out             integer,
        ret_atime       out             integer,
        ret_mtime       out             integer,
        ret_ctime       out             integer,
        ret_atimens     out             integer,
        ret_mtimens     out             integer,
        ret_ctimens     out             integer)
        return  integer;


    function    fs_read(
        path            in              varchar2,
        buffer          out nocopy      raw,
        amount          in              integer,
        offset0         in              integer)
        return  integer;

    function    fs_read(
        path            in              varchar2,
        amount          in              integer,
        offset0         in              integer,
        buffers         out nocopy      dbms_dbfs_content_raw_t)
        return  integer;


    function    fs_write(
        path            in              varchar2,
        buffer          in              raw,
        amount          in              integer,
        offset0         in              integer)
        return  integer;

    function    fs_write(
        path            in              varchar2,
        buffer          in              raw,
        amount          in              integer,
        offset0         in              integer,
        ret_ino         out             integer,
        ret_mode        out             integer,
        ret_nlink       out             integer,
        ret_uid         out             integer,
        ret_gid         out             integer,
        ret_size        out             integer,
        ret_blksize     out             integer,
        ret_blocks      out             integer,
        ret_atime       out             integer,
        ret_mtime       out             integer,
        ret_ctime       out             integer)
        return  integer;

    function    fs_write(
        path            in              varchar2,
        buffer          in              raw,
        amount          in              integer,
        offset0         in              integer,
        ret_ino         out             integer,
        ret_mode        out             integer,
        ret_nlink       out             integer,
        ret_uid         out             integer,
        ret_gid         out             integer,
        ret_size        out             integer,
        ret_blksize     out             integer,
        ret_blocks      out             integer,
        ret_atime       out             integer,
        ret_mtime       out             integer,
        ret_ctime       out             integer,
        ret_atimens     out             integer,
        ret_mtimens     out             integer,
        ret_ctimens     out             integer)
        return  integer;

    function    fs_write(
        path            in              varchar2,
        offset0         in              integer,
        buffers         in              dbms_dbfs_content_raw_t)
        return  integer;

    function    fs_write(
        path            in              varchar2,
        offset0         in              integer,
        buffers         in              dbms_dbfs_content_raw_t,
        ret_ino         out             integer,
        ret_mode        out             integer,
        ret_nlink       out             integer,
        ret_uid         out             integer,
        ret_gid         out             integer,
        ret_size        out             integer,
        ret_blksize     out             integer,
        ret_blocks      out             integer,
        ret_atime       out             integer,
        ret_mtime       out             integer,
        ret_ctime       out             integer)
        return  integer;

    function    fs_write(
        path            in              varchar2,
        offset0         in              integer,
        buffers         in              dbms_dbfs_content_raw_t,
        ret_ino         out             integer,
        ret_mode        out             integer,
        ret_nlink       out             integer,
        ret_uid         out             integer,
        ret_gid         out             integer,
        ret_size        out             integer,
        ret_blksize     out             integer,
        ret_blocks      out             integer,
        ret_atime       out             integer,
        ret_mtime       out             integer,
        ret_ctime       out             integer,
        ret_atimens     out             integer,
        ret_mtimens     out             integer,
        ret_ctimens     out             integer)
        return  integer;


    function    fs_statfs(
        path            in              varchar2,
        f_bsize         out             integer,
        f_frsize        out             integer,
        f_blocks        out             integer,
        f_bfree         out             integer,
        f_bavail        out             integer,
        f_files         out             integer,
        f_ffree         out             integer,
        f_favail        out             integer,
        f_fsid          out             integer,
        f_flag          out             integer,
        f_namemax       out             integer,
        useEstimate     in              integer     default 0)
        return  integer;

    function    fs_flush(
        path            in              varchar2)
        return  integer;

    function    fs_release(
        path            in              varchar2)
        return  integer;

    function    fs_fsync(
        path            in              varchar2)
        return  integer;

    function    fs_setxattr(
        path            in              varchar2,
        xname           in              varchar2,
        xvalue          in              raw,
        xflags          in              integer     default 0)
        return  integer;

    function    fs_getxattr(
        path            in              varchar2,
        xname           in              varchar2,
        xvalue          out nocopy      raw)
        return  integer;

    function    fs_listxattr(
        path            in              varchar2)
        return  propnames_t
            pipelined;

    function    fs_removexattr(
        path            in              varchar2,
        xname           in              varchar2)
        return  integer;

    function    fs_opendir(
        path            in              varchar2)
        return  integer;

    function    fs_readdir(
        path            in              varchar2,
        withProps       in              integer     default 0,
        doCursor        in              integer     default 1,
        doSort          in              integer     default 0,
        doFts           in              integer     default 0,
        doBulk          in              integer     default 0,
        doFallback      in              integer     default 0,
        doRecurse       in              integer     default 0)
        return  dir_entries_t
            pipelined;

    function    fs_releasedir(
        path            in              varchar2)
        return  integer;

    function    fs_fsyncdir(
        path            in              varchar2)
        return  integer;

    function    fs_init
        return  integer;

    function    fs_destroy
        return  integer;

    function    fs_access(
        path            in              varchar2,
        st_mode         in              integer)
        return  integer;


    function    fs_creat(
        path            in              varchar2,
        st_mode         in              integer     default MODE_FILE,
        content         out nocopy      blob,
        st_uid          in              integer     default 0,
        st_gid          in              integer     default 0)
        return  integer;

    function    fs_creat(
        path            in              varchar2,
        st_mode         in              integer     default MODE_FILE,
        content         out nocopy      blob,
        st_uid          in              integer     default 0,
        st_gid          in              integer     default 0,
        ret_ino         out             integer,
        ret_mode        out             integer,
        ret_nlink       out             integer,
        ret_uid         out             integer,
        ret_gid         out             integer,
        ret_size        out             integer,
        ret_blksize     out             integer,
        ret_blocks      out             integer,
        ret_atime       out             integer,
        ret_mtime       out             integer,
        ret_ctime       out             integer)
        return  integer;

    function    fs_creat(
        path            in              varchar2,
        st_mode         in              integer     default MODE_FILE,
        content         out nocopy      blob,
        st_uid          in              integer     default 0,
        st_gid          in              integer     default 0,
        ret_ino         out             integer,
        ret_mode        out             integer,
        ret_nlink       out             integer,
        ret_uid         out             integer,
        ret_gid         out             integer,
        ret_size        out             integer,
        ret_blksize     out             integer,
        ret_blocks      out             integer,
        ret_atime       out             integer,
        ret_mtime       out             integer,
        ret_ctime       out             integer,
        ret_atimens     out             integer,
        ret_mtimens     out             integer,
        ret_ctimens     out             integer)
        return  integer;


    function    fs_ftruncate(
        path            in              varchar2,
        newlen          in              integer,
        content         in out nocopy   blob)
        return  integer;

    function    fs_ftruncate(
        path            in              varchar2,
        newlen          in              integer,
        content         in out nocopy   blob,
        ret_ino         out             integer,
        ret_mode        out             integer,
        ret_nlink       out             integer,
        ret_uid         out             integer,
        ret_gid         out             integer,
        ret_size        out             integer,
        ret_blksize     out             integer,
        ret_blocks      out             integer,
        ret_atime       out             integer,
        ret_mtime       out             integer,
        ret_ctime       out             integer)
        return  integer;

    function    fs_ftruncate(
        path            in              varchar2,
        newlen          in              integer,
        content         in out nocopy   blob,
        ret_ino         out             integer,
        ret_mode        out             integer,
        ret_nlink       out             integer,
        ret_uid         out             integer,
        ret_gid         out             integer,
        ret_size        out             integer,
        ret_blksize     out             integer,
        ret_blocks      out             integer,
        ret_atime       out             integer,
        ret_mtime       out             integer,
        ret_ctime       out             integer,
        ret_atimens     out             integer,
        ret_mtimens     out             integer,
        ret_ctimens     out             integer)
        return  integer;


    function    fs_fgetattr(
        path            in              varchar2,
        st_ino          out             integer,
        st_mode         out             integer,
        st_nlink        out             integer,
        st_uid          out             integer,
        st_gid          out             integer,
        st_size         out             integer,
        st_blksize      out             integer,
        st_blocks       out             integer,
        st_atime        out             integer,
        st_mtime        out             integer,
        st_ctime        out             integer)
        return  integer;

    function    fs_fgetattr(
        path            in              varchar2,
        st_ino          out             integer,
        st_mode         out             integer,
        st_nlink        out             integer,
        st_uid          out             integer,
        st_gid          out             integer,
        st_size         out             integer,
        st_blksize      out             integer,
        st_blocks       out             integer,
        st_atime        out             integer,
        st_mtime        out             integer,
        st_ctime        out             integer,
        st_atimens      out             integer,
        st_mtimens      out             integer,
        st_ctimens      out             integer)
        return  integer;


    /* posix locking */
    function    fs_lock(
        path            in              varchar2,
        who             in              varchar2,
        lockExclusive   in              integer,
        waitForRowLock  in              integer     default 1)
        return  integer;

    function    fs_islocked(
        path            in              varchar2,
        who             in              varchar2,
        lockExclusive   in              integer)
        return  integer;

    function    fs_unlock(
        path            in              varchar2,
        who             in              varchar2,
        waitForRowLock  in              integer     default 1)
        return  integer;


    /* lookup acceleration view: see dbms_dbfs_content.getattr_view */
    procedure   fs_getattr_view(
        path            in              varchar2,
        prefix          out nocopy      varchar2,
        view_name       out nocopy      varchar2);
end;
/
show errors;

create or replace public synonym dbms_fuse
    for sys.dbms_fuse;

grant execute on dbms_fuse
    to dbfs_role;




@?/rdbms/admin/sqlsessend.sql
