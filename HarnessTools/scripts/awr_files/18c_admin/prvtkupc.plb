@@?/rdbms/admin/sqlsessstart.sql
CREATE OR REPLACE TYPE kupc$_LogEntries FORCE AS VARRAY(10) OF (ku$_LogEntry)
PERSISTABLE -- Part of kupc$_JobInfo
/
grant execute on kupc$_LogEntries to public;
CREATE OR REPLACE TYPE kupc$_JobInfo FORCE AUTHID CURRENT_USER IS OBJECT (
        errstat_info   kupc$_LogEntries,
        CONSTRUCTOR FUNCTION kupc$_JobInfo(
                                logLine IN ku$_LogLine
                                ) RETURN SELF AS RESULT,
        CONSTRUCTOR FUNCTION kupc$_JobInfo(
                                text IN VARCHAR2,
                                errorNumber IN NUMBER DEFAULT NULL
                                ) RETURN SELF AS RESULT,
        CONSTRUCTOR FUNCTION kupc$_JobInfo(
                                logEntry IN ku$_LogEntry
                                ) RETURN SELF AS RESULT,
        STATIC FUNCTION createJobInfo(
                                logLine IN ku$_LogLine
                                ) RETURN kupc$_JobInfo,
        STATIC FUNCTION createJobInfo(
                                text IN VARCHAR2,
                                errorNumber IN NUMBER DEFAULT NULL
                                ) RETURN kupc$_JobInfo,
        STATIC FUNCTION createJobInfo(
                                logEntry IN ku$_LogEntry
                                ) RETURN kupc$_JobInfo,
        MEMBER PROCEDURE addLogEntry(
                                logEntry IN ku$_LogEntry DEFAULT NULL
                                ),
        MEMBER PROCEDURE addLine(
                                logLine IN ku$_LogLine
                                ),
        MEMBER PROCEDURE addLine(
                                text IN VARCHAR2,
                                errorNumber IN NUMBER DEFAULT NULL
                                ),
        MEMBER PROCEDURE addError(
                                errorNumber IN NUMBER,
                                param1 IN VARCHAR2 DEFAULT '',
                                param2 IN VARCHAR2 DEFAULT '',
                                param3 IN VARCHAR2 DEFAULT '',
                                param4 IN VARCHAR2 DEFAULT '',
                                param5 IN VARCHAR2 DEFAULT '',
                                param6 IN VARCHAR2 DEFAULT '',
                                param7 IN VARCHAR2 DEFAULT '',
                                param8 IN VARCHAR2 DEFAULT ''
                                ),
        MEMBER FUNCTION format RETURN ku$_LogEntry,
        MEMBER PROCEDURE printJobInfo,
        MEMBER PROCEDURE addTimeStamp
        )
PERSISTABLE -- Part of kupc$_mastererror, kupc$_masterjobinfo, etc
/
grant execute on kupc$_JobInfo to public;
CREATE OR REPLACE TYPE kupc$_LobPieces FORCE 
AS VARRAY(4000) OF (VARCHAR2(4000))
PERSISTABLE -- Part of kupc$_data_filter, kupc$_metadata_filter
/
grant execute on kupc$_LobPieces to public;
CREATE OR REPLACE TYPE kupc$_message FORCE AS OBJECT (
        msgtype                 NUMBER,
        requestid               VARCHAR2(128),
        MEMBER FUNCTION isDatagram RETURN BOOLEAN,
        MEMBER FUNCTION isRequest  RETURN BOOLEAN,
        MEMBER FUNCTION isResponse RETURN BOOLEAN
        ) NOT FINAL
PERSISTABLE -- ***Root of DP persistable types***: Part of AQ messaging table
/
grant execute on kupc$_message to public;
CREATE OR REPLACE TYPE kupc$_master_msg FORCE UNDER kupc$_message (
        parallel                NUMBER,
        last_error              NUMBER,
        error_count             NUMBER,
        debug_flags             NUMBER,
        mcp_queue_type          NUMBER
        ) NOT FINAL NOT INSTANTIABLE
/
grant execute on kupc$_master_msg to public;
CREATE OR REPLACE TYPE kupc$_shadow_msg FORCE UNDER kupc$_message (
        handle                  NUMBER
        ) NOT FINAL NOT INSTANTIABLE
/
grant execute on kupc$_shadow_msg to public;
CREATE OR REPLACE TYPE kupc$_worker_msg FORCE UNDER kupc$_message (
        id                      NUMBER
        ) NOT FINAL NOT INSTANTIABLE
/
grant execute on kupc$_worker_msg to public;
CREATE OR REPLACE TYPE kupc$_add_device FORCE UNDER kupc$_shadow_msg (
        devicename                VARCHAR2(4000),
        volumesize                NUMBER,
        CONSTRUCTOR FUNCTION kupc$_add_device(
                                dn  VARCHAR2,
                                vs  NUMBER
                                ) RETURN SELF AS RESULT,
        CONSTRUCTOR FUNCTION kupc$_add_device(
                                qh  NUMBER,
                                dn  VARCHAR2,
                                vs  NUMBER
                                ) RETURN SELF AS RESULT
        )
/
grant execute on kupc$_add_device to public;
CREATE OR REPLACE TYPE kupc$_add_file FORCE UNDER kupc$_shadow_msg (
        filename                VARCHAR2(4000),
        directory               VARCHAR2(4000),
        filesize                NUMBER,
        filetype                NUMBER,
        reusefile               NUMBER,
        CONSTRUCTOR FUNCTION kupc$_add_file(
                                fn  VARCHAR2,
                                dr  VARCHAR2,
                                fs  NUMBER
                                ) RETURN SELF AS RESULT,
        CONSTRUCTOR FUNCTION kupc$_add_file(
                                qh  NUMBER,
                                fn  VARCHAR2,
                                dr  VARCHAR2,
                                fs  NUMBER
                                ) RETURN SELF AS RESULT,
        CONSTRUCTOR FUNCTION kupc$_add_file(
                                fn  VARCHAR2,
                                dr  VARCHAR2,
                                fs  NUMBER,
                                ft  NUMBER,
                                rf  NUMBER
                                ) RETURN SELF AS RESULT,
        CONSTRUCTOR FUNCTION kupc$_add_file(
                                qh  NUMBER,
                                fn  VARCHAR2,
                                dr  VARCHAR2,
                                fs  NUMBER,
                                ft  NUMBER
                                ) RETURN SELF AS RESULT
        )
/
grant execute on kupc$_add_file to public;
CREATE OR REPLACE TYPE kupc$_restart FORCE UNDER kupc$_shadow_msg (
        job_name                VARCHAR2(128),
        job_owner               VARCHAR2(128),
        CONSTRUCTOR FUNCTION kupc$_restart(
                                jn  VARCHAR2,
                                jo  VARCHAR2
                                ) RETURN SELF AS RESULT,
        CONSTRUCTOR FUNCTION kupc$_restart(
                                qh  NUMBER,
                                jn  VARCHAR2,
                                jo  VARCHAR2
                                ) RETURN SELF AS RESULT
        )
/
grant execute on kupc$_restart to public;
CREATE OR REPLACE TYPE kupc$_data_filter FORCE UNDER kupc$_shadow_msg (
        filter_name                VARCHAR2(30),
        filter_value_t             VARCHAR2(4000),
        filter_value_n             NUMBER,
        filter_value_l             kupc$_LobPieces,
        table_name                 VARCHAR2(128),
        schema_name                VARCHAR2(128),
        CONSTRUCTOR FUNCTION kupc$_data_filter(
                                fn   VARCHAR2,
                                fvt  VARCHAR2,
                                tn   VARCHAR2,
                                sn   VARCHAR2
                                ) RETURN SELF AS RESULT,
        CONSTRUCTOR FUNCTION kupc$_data_filter(
                                fn   VARCHAR2,
                                fvn  NUMBER,
                                tn   VARCHAR2,
                                sn   VARCHAR2
                                ) RETURN SELF AS RESULT,
        CONSTRUCTOR FUNCTION kupc$_data_filter(
                                fn   VARCHAR2,
                                fvl  CLOB,
                                tn   VARCHAR2,
                                sn   VARCHAR2
                                ) RETURN SELF AS RESULT
        )
/
grant execute on kupc$_data_filter to public;
CREATE OR REPLACE TYPE kupc$_data_remap FORCE UNDER kupc$_shadow_msg (
        remap_name                 VARCHAR2(30),
        remap_table                VARCHAR2(128),
        remap_column               VARCHAR2(128),
        remap_function             VARCHAR2(392),
        remap_schema               VARCHAR2(128),
        remap_flags                NUMBER,
        CONSTRUCTOR FUNCTION kupc$_data_remap(
                                rn   VARCHAR2,
                                rt   VARCHAR2,
                                rc   VARCHAR2,
                                rf   VARCHAR2,
                                rs   VARCHAR2,
                                rfg  NUMBER
                                ) RETURN SELF AS RESULT
        )
/
grant execute on kupc$_data_remap to public;
CREATE OR REPLACE TYPE kupc$_log_entry FORCE UNDER kupc$_shadow_msg (
        log_entry_text          VARCHAR2(2000),
        logfile_only            NUMBER,
        CONSTRUCTOR FUNCTION kupc$_log_entry(
                                let  VARCHAR2,
                                lon  NUMBER
                                ) RETURN SELF AS RESULT,
        CONSTRUCTOR FUNCTION kupc$_log_entry(
                                qh   NUMBER,
                                let  VARCHAR2,
                                lon  NUMBER
                                ) RETURN SELF AS RESULT
        )
/
grant execute on kupc$_log_entry to public;
CREATE OR REPLACE TYPE kupc$_log_error FORCE UNDER kupc$_shadow_msg (
        log_error_text          VARCHAR2(2000),
        error_number            NUMBER,
        fatal_error             NUMBER,
        logfile_only            NUMBER,
        CONSTRUCTOR FUNCTION kupc$_log_error(
                                let  VARCHAR2,
                                len  NUMBER,
                                lfe  NUMBER,
                                lon  NUMBER
                                ) RETURN SELF AS RESULT,
        CONSTRUCTOR FUNCTION kupc$_log_error(
                                qh   NUMBER,
                                let  VARCHAR2,
                                len  NUMBER,
                                lfe  NUMBER,
                                lon  NUMBER
                                ) RETURN SELF AS RESULT
        )
/
grant execute on kupc$_log_error to public;
CREATE OR REPLACE TYPE kupc$_metadata_filter FORCE UNDER kupc$_shadow_msg (
        filter_name                VARCHAR2(30),
        filter_value               VARCHAR2(4000),
        clob_value                 kupc$_LobPieces,
        object_path                VARCHAR2(200),
        CONSTRUCTOR FUNCTION kupc$_metadata_filter(
                                fn  VARCHAR2,
                                fv  VARCHAR2,
                                op  VARCHAR2
                                ) RETURN SELF AS RESULT,
        CONSTRUCTOR FUNCTION kupc$_metadata_filter(
                                fn  VARCHAR2,
                                lo  CLOB,
                                op  VARCHAR2
                                ) RETURN SELF AS RESULT
        )
/
grant execute on kupc$_metadata_filter to public;
CREATE OR REPLACE TYPE kupc$_metadata_transform FORCE UNDER kupc$_shadow_msg (
        transform_name             VARCHAR2(30),
        transform_value_t          VARCHAR2(4000),
        transform_value_n          NUMBER,
        object_type                VARCHAR2(128),
        CONSTRUCTOR FUNCTION kupc$_metadata_transform(
                                tn   VARCHAR2,
                                tvt  VARCHAR2,
                                tvn  NUMBER,
                                ot   VARCHAR2
                                ) RETURN SELF AS RESULT,
        CONSTRUCTOR FUNCTION kupc$_metadata_transform(
                                qh   NUMBER,
                                tn   VARCHAR2,
                                tvt  VARCHAR2,
                                tvn  NUMBER,
                                ot   VARCHAR2
                                ) RETURN SELF AS RESULT,
        CONSTRUCTOR FUNCTION kupc$_metadata_transform(
                                tn   VARCHAR2,
                                tvt  VARCHAR2,
                                ot   VARCHAR2
                                ) RETURN SELF AS RESULT,
        CONSTRUCTOR FUNCTION kupc$_metadata_transform(
                                qh   NUMBER,
                                tn   VARCHAR2,
                                tvt  VARCHAR2,
                                ot   VARCHAR2
                                ) RETURN SELF AS RESULT,
        CONSTRUCTOR FUNCTION kupc$_metadata_transform(
                                tn   VARCHAR2,
                                tvn  NUMBER,
                                ot   VARCHAR2
                                ) RETURN SELF AS RESULT,
        CONSTRUCTOR FUNCTION kupc$_metadata_transform(
                                qh   NUMBER,
                                tn   VARCHAR2,
                                tvn  NUMBER,
                                ot   VARCHAR2
                                ) RETURN SELF AS RESULT
        )
/
grant execute on kupc$_metadata_transform to public;
CREATE OR REPLACE TYPE kupc$_metadata_remap FORCE UNDER kupc$_shadow_msg (
        remap_name                VARCHAR2(30),
        remap_old_value           VARCHAR2(4000),
        remap_new_value           VARCHAR2(4000),
        object_type               VARCHAR2(128),
        CONSTRUCTOR FUNCTION kupc$_metadata_remap(
                                rn   VARCHAR2,
                                rov  VARCHAR2,
                                rnv  VARCHAR2,
                                ot   VARCHAR2
                                ) RETURN SELF AS RESULT,
        CONSTRUCTOR FUNCTION kupc$_metadata_remap(
                                qh   NUMBER,
                                rn   VARCHAR2,
                                rov  VARCHAR2,
                                rnv  VARCHAR2,
                                ot   VARCHAR2
                                ) RETURN SELF AS RESULT
        )
/
grant execute on kupc$_metadata_remap to public;
CREATE OR REPLACE TYPE kupc$_open FORCE UNDER kupc$_shadow_msg (
        current_user              VARCHAR2(128),
        operation                 VARCHAR2(30),
        job_mode                  VARCHAR2(30),
        remote_link               VARCHAR2(4000),
        job_name                  VARCHAR2(128),
        version                   VARCHAR2(30),
        compression               NUMBER,
        CONSTRUCTOR FUNCTION kupc$_open(
                                cu   VARCHAR2,
                                op   VARCHAR2,
                                jm   VARCHAR2,
                                rl   VARCHAR2,
                                jn   VARCHAR2,
                                vs   VARCHAR2,
                                cp   NUMBER
                                ) RETURN SELF AS RESULT,
        CONSTRUCTOR FUNCTION kupc$_open(
                                qh   NUMBER,
                                cu   VARCHAR2,
                                op   VARCHAR2,
                                jm   VARCHAR2,
                                rl   VARCHAR2,
                                jn   VARCHAR2,
                                vs   VARCHAR2,
                                cp   NUMBER
                                ) RETURN SELF AS RESULT
        )
/
grant execute on kupc$_open to public;
CREATE OR REPLACE TYPE kupc$_set_parallel FORCE UNDER kupc$_shadow_msg (
        degree                   NUMBER,
        CONSTRUCTOR FUNCTION kupc$_set_parallel(
                                dg   NUMBER
                                ) RETURN SELF AS RESULT,
        CONSTRUCTOR FUNCTION kupc$_set_parallel(
                                qh   NUMBER,
                                dg   NUMBER
                                ) RETURN SELF AS RESULT
        )
/
grant execute on kupc$_set_parallel to public;
CREATE OR REPLACE TYPE kupc$_set_parameter FORCE UNDER kupc$_shadow_msg (
                                parameter_name     VARCHAR2(30),
                                parameter_value_t  VARCHAR2(4000),
                                parameter_value_n  NUMBER,
        CONSTRUCTOR FUNCTION kupc$_set_parameter(
                                pn   VARCHAR2,
                                pvt  VARCHAR2,
                                pvn  NUMBER
                                ) RETURN SELF AS RESULT,
        CONSTRUCTOR FUNCTION kupc$_set_parameter(
                                qh   NUMBER,
                                pn   VARCHAR2,
                                pvt  VARCHAR2,
                                pvn  NUMBER
                                ) RETURN SELF AS RESULT,
        CONSTRUCTOR FUNCTION kupc$_set_parameter(
                                pn   VARCHAR2,
                                pvt  VARCHAR2
                                ) RETURN SELF AS RESULT,
        CONSTRUCTOR FUNCTION kupc$_set_parameter(
                                qh   NUMBER,
                                pn   VARCHAR2,
                                pvt  VARCHAR2
                                ) RETURN SELF AS RESULT,
        CONSTRUCTOR FUNCTION kupc$_set_parameter(
                                pn   VARCHAR2,
                                pvn  NUMBER
                                ) RETURN SELF AS RESULT,
        CONSTRUCTOR FUNCTION kupc$_set_parameter(
                                qh   NUMBER,
                                pn   VARCHAR2,
                                pvn  NUMBER
                                ) RETURN SELF AS RESULT
        )
/
grant execute on kupc$_set_parameter to public;
CREATE OR REPLACE TYPE kupc$_shadow_key_exchange FORCE UNDER kupc$_shadow_msg (
                                public_key    VARCHAR2(256),
                                token         VARCHAR2(4000),
        CONSTRUCTOR FUNCTION kupc$_shadow_key_exchange(
                                pubkey  VARCHAR2,
                                tok     VARCHAR2
                                ) RETURN SELF AS RESULT
        )
/
grant execute on kupc$_shadow_key_exchange to public;
CREATE OR REPLACE TYPE kupc$_start_job FORCE UNDER kupc$_shadow_msg (
                                skip_current  NUMBER,
                                cluster_ok    NUMBER,
                                service_name  VARCHAR2(100),
                                abort_step    NUMBER,
        CONSTRUCTOR FUNCTION kupc$_start_job(
                                sc  NUMBER
                                ) RETURN SELF AS RESULT,
        CONSTRUCTOR FUNCTION kupc$_start_job(
                                qh  NUMBER,
                                sc  NUMBER
                                ) RETURN SELF AS RESULT,
        CONSTRUCTOR FUNCTION kupc$_start_job(
                                sc  NUMBER,
                                ab  NUMBER
                                ) RETURN SELF AS RESULT,
        CONSTRUCTOR FUNCTION kupc$_start_job(
                                qh  NUMBER,
                                sc  NUMBER,
                                cl  NUMBER,
                                sn  VARCHAR2,
                                ab  NUMBER
                                ) RETURN SELF AS RESULT
        )
/
grant execute on kupc$_start_job to public;
CREATE OR REPLACE TYPE kupc$_stop_job FORCE UNDER kupc$_shadow_msg (
                                immediate_flag  NUMBER,
                                keep_master     NUMBER,
                                delay           NUMBER,
        CONSTRUCTOR FUNCTION kupc$_stop_job(
                                im  NUMBER,
                                km  NUMBER,
                                de  NUMBER
                                ) RETURN SELF AS RESULT,
        CONSTRUCTOR FUNCTION kupc$_stop_job(
                                qh  NUMBER,
                                im  NUMBER,
                                km  NUMBER,
                                de  NUMBER
                                ) RETURN SELF AS RESULT
        )
/
grant execute on kupc$_stop_job to public;
CREATE OR REPLACE TYPE kupc$_stop_worker FORCE UNDER kupc$_shadow_msg (
                                worker_id       NUMBER,
                                skip_current    NUMBER,
        CONSTRUCTOR FUNCTION kupc$_stop_worker(
                                wi  NUMBER,
                                sc  NUMBER
                                ) RETURN SELF AS RESULT,
        CONSTRUCTOR FUNCTION kupc$_stop_worker(
                                qh  NUMBER,
                                wi  NUMBER,
                                sc  NUMBER
                                ) RETURN SELF AS RESULT
        )
/
grant execute on kupc$_stop_worker to public;
CREATE OR REPLACE TYPE kupc$_api_ack FORCE UNDER kupc$_master_msg (
        errnum                   NUMBER,
        error                    kupc$_JobInfo,
        flags                    NUMBER,
        CONSTRUCTOR FUNCTION kupc$_api_ack(
                                en NUMBER
                                ) RETURN SELF AS RESULT,
        CONSTRUCTOR FUNCTION kupc$_api_ack(
                                en  NUMBER,
                                err kupc$_JobInfo
                                ) RETURN SELF AS RESULT,
        CONSTRUCTOR FUNCTION kupc$_api_ack(
                                en  NUMBER,
                                flg NUMBER
                                ) RETURN SELF AS RESULT,
        CONSTRUCTOR FUNCTION kupc$_api_ack(
                                en  NUMBER,
                                err kupc$_JobInfo,
                                flg NUMBER
                                ) RETURN SELF AS RESULT
        )
/
grant execute on kupc$_api_ack to public;
CREATE OR REPLACE TYPE kupc$_disk_file FORCE UNDER kupc$_master_msg (
                                file_number     NUMBER,
                                block_size      NUMBER,
                                flags           NUMBER,
                                allocated_size  NUMBER,
                                file_position   NUMBER,
                                file_max_size   NUMBER,
                                file_name       VARCHAR2(4000),
                                file_type       NUMBER,
                                user_directory  VARCHAR2(4000),
        CONSTRUCTOR FUNCTION kupc$_disk_file(
                                fno  NUMBER,
                                bsz  NUMBER,
                                flg  NUMBER,
                                asz  NUMBER,
                                fpo  NUMBER,
                                msz  NUMBER,
                                fnm  VARCHAR2,
                                typ  NUMBER,
                                dir  VARCHAR2
                                ) RETURN SELF AS RESULT
        )
/
grant execute on kupc$_disk_file to public;
CREATE OR REPLACE TYPE kupc$_master_key_exchange FORCE UNDER kupc$_master_msg (
                                public_key      VARCHAR2(256),
                                key_digest      VARCHAR2(64),
        CONSTRUCTOR FUNCTION kupc$_master_key_exchange(
                                pubkey  VARCHAR2,
                                digest  VARCHAR2
                                ) RETURN SELF AS RESULT
        )
/
grant execute on kupc$_master_key_exchange to public; 
CREATE OR REPLACE TYPE kupc$_sequential_file FORCE UNDER kupc$_master_msg (
                                block_size      NUMBER,
                                flags           NUMBER,
                                allocated_size  NUMBER,
                                file_max_size   NUMBER,
                                file_name       VARCHAR2(4000),
        CONSTRUCTOR FUNCTION kupc$_sequential_file(
                                bsz  NUMBER,
                                flg  NUMBER,
                                asz  NUMBER,
                                msz  NUMBER,
                                fnm  VARCHAR2
                               ) RETURN SELF AS RESULT
        )
/
grant execute on kupc$_sequential_file to public;
CREATE OR REPLACE TYPE kupc$_release_files FORCE UNDER kupc$_master_msg (
                                unused        NUMBER,
        CONSTRUCTOR FUNCTION kupc$_release_files
                               RETURN SELF AS RESULT
        )
/
grant execute on kupc$_release_files to public;
CREATE OR REPLACE TYPE kupc$_unload_metadata FORCE UNDER kupc$_master_msg (
                                flags          NUMBER,
                                degree         NUMBER,
                                start_seqno    NUMBER,
                                end_seqno      NUMBER,
                                md_worker      NUMBER,
        CONSTRUCTOR FUNCTION kupc$_unload_metadata(
                                flg  NUMBER,
                                deg  NUMBER,
                                ssq  NUMBER,
                                esq  NUMBER,
                                mdw  NUMBER
                               ) RETURN SELF AS RESULT
        )
/
grant execute on kupc$_unload_metadata to public;
CREATE OR REPLACE TYPE kupc$_unload_data FORCE UNDER kupc$_master_msg (
                                start_process_order  NUMBER,
                                end_process_order    NUMBER,
                                datasize             NUMBER,
                                method               NUMBER,
                                creation_level       NUMBER,
                                seqno                NUMBER,
        CONSTRUCTOR FUNCTION kupc$_unload_data(
                                spo NUMBER,
                                epo NUMBER,
                                ds  NUMBER,
                                md  NUMBER,
                                pa  NUMBER,
                                lvl NUMBER,
                                seq NUMBER
                               ) RETURN SELF AS RESULT
        )
/
grant execute on kupc$_unload_data to public;
CREATE OR REPLACE TYPE kupc$_load_metadata FORCE UNDER kupc$_master_msg (
                                flags         NUMBER,
                                degree        NUMBER,
                                start_row     NUMBER,
                                end_row       NUMBER,
                                md_worker     NUMBER,
        CONSTRUCTOR FUNCTION kupc$_load_metadata(
                                flg  NUMBER,
                                deg  NUMBER,
                                sro  NUMBER,
                                ero  NUMBER,
                                mdw  NUMBER
                               ) RETURN SELF AS RESULT
        )
/
grant execute on kupc$_load_metadata to public;
CREATE OR REPLACE TYPE kupc$_load_data FORCE UNDER kupc$_master_msg (
                                start_process_order  NUMBER,
                                end_process_order    NUMBER,
                                datasize             NUMBER,
                                method               NUMBER,
                                creation_level       NUMBER,
                                flags                NUMBER,
        CONSTRUCTOR FUNCTION kupc$_load_data(
                                spo NUMBER,
                                epo NUMBER,
                                ds  NUMBER,
                                md  NUMBER,
                                pa  NUMBER,
                                lvl NUMBER,
                                flg NUMBER
                               ) RETURN SELF AS RESULT
        )
/
grant execute on kupc$_load_data to public;
CREATE OR REPLACE TYPE kupc$_estimate_job FORCE UNDER kupc$_master_msg (
                                md_worker NUMBER,
        CONSTRUCTOR FUNCTION kupc$_estimate_job (mdw NUMBER)
                               RETURN SELF AS RESULT
        )
/
grant execute on kupc$_estimate_job to public;
CREATE OR REPLACE TYPE kupc$_recomp FORCE UNDER kupc$_master_msg (
                               md_worker NUMBER,
        CONSTRUCTOR FUNCTION kupc$_recomp (mdw NUMBER)
                               RETURN SELF AS RESULT
        )
/
grant execute on kupc$_recomp to public;
CREATE OR REPLACE TYPE kupc$_sql_file_job FORCE UNDER kupc$_master_msg (
                                file_path     VARCHAR2(4000),
                                file_name     VARCHAR2(2000),
                                restart       NUMBER,       
        CONSTRUCTOR FUNCTION kupc$_sql_file_job(
                                fp  VARCHAR2,
                                fn  VARCHAR2,
                                rst NUMBER
                               ) RETURN SELF AS RESULT
        )
/
grant execute on kupc$_sql_file_job to public;
CREATE OR REPLACE TYPE kupc$_prepare_data FORCE UNDER kupc$_master_msg (
                                seqno          NUMBER,
                                path           VARCHAR2(200),
                                restart        NUMBER,
        CONSTRUCTOR FUNCTION kupc$_prepare_data(
                                sq   NUMBER,
                                pa   VARCHAR2,
                                rst  NUMBER
                               ) RETURN SELF AS RESULT
        )
/
grant execute on kupc$_prepare_data to public;
CREATE OR REPLACE TYPE kupc$_restore_logging FORCE UNDER kupc$_master_msg (
                                seqno          NUMBER,
        CONSTRUCTOR FUNCTION kupc$_restore_logging(
                                sq   NUMBER
                               ) RETURN SELF AS RESULT
        )
/
grant execute on kupc$_restore_logging to public;
CREATE OR REPLACE TYPE kupc$_fixup_virtual_column FORCE UNDER kupc$_master_msg (
                                seqno          NUMBER,
        CONSTRUCTOR FUNCTION kupc$_fixup_virtual_column(
                                sq   NUMBER
                               ) RETURN SELF AS RESULT
        )
/
grant execute on kupc$_fixup_virtual_column to public;
CREATE OR REPLACE TYPE kupc$_complete_imp_object FORCE UNDER kupc$_master_msg (
                                old_seqno      NUMBER,
                                new_seqno      NUMBER,
                                restart        NUMBER,
        CONSTRUCTOR FUNCTION kupc$_complete_imp_object(
                                osn  NUMBER,
                                nsn  NUMBER,
                                rst  NUMBER
                               ) RETURN SELF AS RESULT
        )
/
grant execute on kupc$_complete_imp_object  to public;
CREATE OR REPLACE TYPE kupc$_exit FORCE UNDER kupc$_master_msg (
                                unused        NUMBER,
        CONSTRUCTOR FUNCTION kupc$_exit
                               RETURN SELF AS RESULT
        )
/
grant execute on kupc$_exit to public;
CREATE OR REPLACE TYPE kupc$_post_mt_init FORCE UNDER kupc$_master_msg (
                                metadata_worker    NUMBER,
                                restarting         NUMBER,
        CONSTRUCTOR FUNCTION kupc$_post_mt_init (
                                mdw  NUMBER,
                                rs   NUMBER
                               ) RETURN SELF AS RESULT
        )
/
grant execute on kupc$_post_mt_init to public;
CREATE OR REPLACE TYPE kupc$_mastererror FORCE UNDER kupc$_master_msg (
                                flags        NUMBER,
                                error        kupc$_JobInfo,
        CONSTRUCTOR FUNCTION kupc$_mastererror(
                                err  kupc$_JobInfo
                               ) RETURN SELF AS RESULT,
        CONSTRUCTOR FUNCTION kupc$_mastererror(
                                flg  NUMBER,
                                err  kupc$_JobInfo
                               ) RETURN SELF AS RESULT
        )
/
grant execute on kupc$_mastererror to public;
CREATE OR REPLACE TYPE kupc$_masterjobinfo FORCE UNDER kupc$_master_msg (
                                flags          NUMBER,
                                jobinfo        kupc$_JobInfo,
        CONSTRUCTOR FUNCTION kupc$_masterjobinfo(
                                info  kupc$_JobInfo
                               ) RETURN SELF AS RESULT,
        CONSTRUCTOR FUNCTION kupc$_masterjobinfo(
                                flg   NUMBER,
                                info  kupc$_JobInfo
                               ) RETURN SELF AS RESULT
        )
/
grant execute on kupc$_masterjobinfo to public;
CREATE OR REPLACE TYPE SYS.kupc$_mdFilePiece FORCE AS OBJECT
(
   dump_fileid     NUMBER,
   dump_pos        NUMBER,
   dump_len        NUMBER,
   dump_alloc      NUMBER,
   dump_off        NUMBER,
   dump_name       VARCHAR2(4000),
   dump_cred       VARCHAR2(4000),
   CONSTRUCTOR FUNCTION kupc$_mdFilePiece RETURN SELF AS RESULT,
   CONSTRUCTOR FUNCTION kupc$_mdFilePiece (
                                fid      NUMBER,
                                pos      NUMBER,
                                len      NUMBER,
                                alc      NUMBER
                               ) RETURN SELF AS RESULT
)
NOT PERSISTABLE
/
grant execute on kupc$_mdFilePiece to public;
CREATE OR REPLACE TYPE SYS.kupc$_mdFilePieceList FORCE
AS TABLE OF (SYS.kupc$_mdFilePiece)
NOT PERSISTABLE
/
grant execute on kupc$_mdFilePieceList to public;
CREATE OR REPLACE TYPE SYS.kupc$_mdReplOffsets FORCE AS OBJECT
(
   offset          NUMBER,
   CONSTRUCTOR FUNCTION kupc$_mdReplOffsets RETURN SELF AS RESULT,
   CONSTRUCTOR FUNCTION kupc$_mdReplOffsets (
                                off      NUMBER
                               ) RETURN SELF AS RESULT
)
NOT PERSISTABLE
/
grant execute on kupc$_mdReplOffsets to public;
CREATE OR REPLACE TYPE SYS.kupc$_mdReplOffsetsList FORCE
AS TABLE OF (SYS.kupc$_mdReplOffsets)
NOT PERSISTABLE
/
grant execute on kupc$_mdReplOffsetsList to public;
CREATE OR REPLACE TYPE kupc$_fileInfo FORCE AS OBJECT
(
   fileNumber         NUMBER,         -- Assigned file-number
   mediaType          NUMBER,         -- 0=disk file, 1=pipe, 2=tape, 3=uridisk
   version            NUMBER,         -- Dump file version (for import)
   directory          VARCHAR2(4000), -- Directory spec
   fileName           VARCHAR2(4000), -- User filename
   fileSpec           VARCHAR2(4000), -- Full file spec
   guid               RAW(16),        -- Holds guid from dmphdr during import
   maxFileSize        NUMBER,         -- Max size to use or 0 for unlimited
   flags              NUMBER,         -- FLAGS attribute for a DISK_FILE msg
   allocSize          NUMBER,         -- Tracks most current allocation size
   filePos            NUMBER,         -- Tracks most current file position
   blockSize          NUMBER,         -- Used only during import as a check
   charsetID          NUMBER,         -- Used only during import for lobs
   mdEncoding         NUMBER,         -- Used only during import for lobs
   reservedTo         NUMBER,         -- The ID of the proc using the file
   sid                NUMBER,         -- ID of slave if parallel
   used               NUMBER(1),      -- 1 if file was used, else 0
   reserved           NUMBER(1),      -- 1 when file is inuse, else 0
   usable             NUMBER(1),      -- 1 if file is good, else 0
   verified           NUMBER(1),      -- 1 if file verified at import, else 0
   hasMstTbl          NUMBER(1),      -- 1 if file contains the msttbl, else 0
   CONSTRUCTOR FUNCTION kupc$_fileInfo RETURN SELF AS RESULT
)
PERSISTABLE -- Part of kupc$_fileList
/
grant execute on kupc$_fileInfo to public;
CREATE OR REPLACE TYPE kupc$_fileList FORCE AS TABLE OF (kupc$_fileInfo)
PERSISTABLE -- Part of kupc$_file_list
/
grant execute on kupc$_fileList to public;
CREATE OR REPLACE TYPE kupc$_file_list FORCE UNDER kupc$_master_msg (
                            fileList     kupc$_fileList,
        CONSTRUCTOR FUNCTION kupc$_file_list(
                            flist        kupc$_fileList
                           ) RETURN SELF AS RESULT
        )
/
grant execute on kupc$_file_list to public;
CREATE OR REPLACE TYPE kupc$_encoded_pwd FORCE UNDER kupc$_master_msg (
                                encoded_pwd RAW(2000),
                                encoded_pwd_len NUMBER,
        CONSTRUCTOR FUNCTION kupc$_encoded_pwd(
                                encPwd    RAW,
                                encPwdLen NUMBER
                               ) RETURN SELF AS RESULT
        )
/
grant execute on kupc$_encoded_pwd to public;
CREATE OR REPLACE TYPE kupc$_get_work FORCE UNDER kupc$_worker_msg (
                                dummy         NUMBER,
        CONSTRUCTOR FUNCTION kupc$_get_work RETURN SELF AS RESULT,
        CONSTRUCTOR FUNCTION kupc$_get_work(
                                wid  NUMBER
                               ) RETURN SELF AS RESULT
        )
/
grant execute on kupc$_get_work to public;
CREATE OR REPLACE TYPE kupc$_worker_file FORCE UNDER kupc$_worker_msg (
                                sid           NUMBER,
                                flags         NUMBER,
                                minimum_size  NUMBER,
                                used_byte     NUMBER,
                                alloc_size    NUMBER,
                                file_number   NUMBER,
        CONSTRUCTOR FUNCTION kupc$_worker_file(
                                wid      NUMBER,
                                psi      NUMBER,
                                flg      NUMBER,
                                msz      NUMBER,
                                usb      NUMBER,
                                asz      NUMBER,
                                fno      NUMBER
                               ) RETURN SELF AS RESULT,
        CONSTRUCTOR FUNCTION kupc$_worker_file(
                                flg      NUMBER,
                                msz      NUMBER
                               ) RETURN SELF AS RESULT,
        CONSTRUCTOR FUNCTION kupc$_worker_file(
                                wid      NUMBER,
                                psi      NUMBER,
                                flg      NUMBER,
                                usb      NUMBER,
                                asz      NUMBER,
                                fno      NUMBER
                               ) RETURN SELF AS RESULT
        )
/
grant execute on kupc$_worker_file to public;
CREATE OR REPLACE TYPE kupc$_device_ident FORCE UNDER kupc$_worker_msg (
                                flags         NUMBER,
                                file_name     VARCHAR2(4000),
                                file_number   NUMBER,
        CONSTRUCTOR FUNCTION kupc$_device_ident(
                                flg      NUMBER,
                                fnm      VARCHAR2,
                                fno      NUMBER
                               ) RETURN SELF AS RESULT
        )
/
grant execute on kupc$_device_ident to public;
CREATE OR REPLACE TYPE kupc$_bad_file FORCE UNDER kupc$_worker_msg (
                                error         ku$_LogEntry,
                                bad_row       CLOB,
        CONSTRUCTOR FUNCTION kupc$_bad_file(
                                err      ku$_LogEntry,
                                bro      CLOB
                               ) RETURN SELF AS RESULT
        )
/
grant execute on kupc$_bad_file to public;
CREATE OR REPLACE TYPE kupc$_table_data FORCE AS OBJECT (
                                process_order  NUMBER,
                                creation_level NUMBER,
                                degree         NUMBER,
                                datasize       NUMBER,
                                method         NUMBER,
                                seqno          NUMBER
        )
PERSISTABLE -- Part of kupc$_table_datas
/
grant execute on kupc$_table_data to public;
CREATE OR REPLACE TYPE kupc$_table_datas FORCE
AS VARRAY(1000) OF (kupc$_table_data)
PERSISTABLE -- Part of kupc$_table_data_array
/
grant execute on kupc$_table_datas to public;
CREATE OR REPLACE TYPE kupc$_table_data_array FORCE UNDER kupc$_worker_msg (
                                table_datas   kupc$_table_datas,
        CONSTRUCTOR FUNCTION kupc$_table_data_array(
                                tds      kupc$_table_datas
                               ) RETURN SELF AS RESULT
        )
/
grant execute on kupc$_table_data_array to public;
CREATE OR REPLACE TYPE kupc$_type_comp_ready FORCE UNDER kupc$_worker_msg (
                               seqno     NUMBER,
        CONSTRUCTOR FUNCTION kupc$_type_comp_ready(
                                sn       NUMBER
                               ) RETURN SELF AS RESULT
        )
/
grant execute on kupc$_type_comp_ready to public;
CREATE OR REPLACE TYPE kupc$_worker_log_entry FORCE UNDER kupc$_worker_msg (
                                wip           ku$_LogEntry,
        CONSTRUCTOR FUNCTION kupc$_worker_log_entry(
                                log      ku$_LogEntry
                               ) RETURN SELF AS RESULT
        )
/
grant execute on kupc$_worker_log_entry to public;
CREATE OR REPLACE TYPE kupc$_workererror FORCE UNDER kupc$_worker_msg (
                                error         kupc$_JobInfo,
                                errcnt        NUMBER,
                                workerid      NUMBER,
                                last_msg      NUMBER,
        CONSTRUCTOR FUNCTION kupc$_workererror(
                                err      kupc$_JobInfo,
                                ecnt     NUMBER,
                                wid      NUMBER,
                                lstmsg   NUMBER
                               ) RETURN SELF AS RESULT,
        CONSTRUCTOR FUNCTION kupc$_workererror(
                                err      kupc$_JobInfo,
                                ecnt     NUMBER,
                                lstmsg   NUMBER
                               ) RETURN SELF AS RESULT
        )
/
grant execute on kupc$_workererror to public;
CREATE OR REPLACE TYPE kupc$_worker_exit FORCE UNDER kupc$_worker_msg (
                                process_number       NUMBER,
        CONSTRUCTOR FUNCTION kupc$_worker_exit(
                                pid      NUMBER
                               ) RETURN SELF AS RESULT
        )
/
grant execute on kupc$_worker_exit to public;
CREATE OR REPLACE TYPE kupc$_worker_file_list FORCE UNDER kupc$_worker_msg (
                             dummy NUMBER,
        CONSTRUCTOR FUNCTION kupc$_worker_file_list 
                             RETURN SELF AS RESULT,
        CONSTRUCTOR FUNCTION kupc$_worker_file_list (wid NUMBER)
                             RETURN SELF AS RESULT
        )
/
grant execute on kupc$_worker_file_list to public;
CREATE OR REPLACE TYPE kupc$_worker_get_pwd FORCE UNDER kupc$_worker_msg (
                             dummy NUMBER,
        CONSTRUCTOR FUNCTION kupc$_worker_get_pwd
                             RETURN SELF AS RESULT,
        CONSTRUCTOR FUNCTION kupc$_worker_get_pwd (wid NUMBER)
                             RETURN SELF AS RESULT
        )
/
grant execute on kupc$_worker_get_pwd to public;
CREATE OR REPLACE TYPE kupc$_mt_info FORCE AS OBJECT (
    version     VARCHAR2(30),
    owner_name  VARCHAR2(128),
    table_name  VARCHAR2(128))
NOT PERSISTABLE
/
CREATE OR REPLACE TYPE kupc$_mt_info_list FORCE IS TABLE OF (kupc$_mt_info)
NOT PERSISTABLE
/
CREATE OR REPLACE TYPE kupc$_mt_col_info FORCE AS OBJECT (
    col_name    VARCHAR2(128),
    col_type    VARCHAR2(30),
    col_version VARCHAR2(30),
    col_size    NUMBER)
NOT PERSISTABLE
/
CREATE OR REPLACE TYPE kupc$_mt_col_info_list FORCE
IS TABLE OF (kupc$_mt_col_info)
NOT PERSISTABLE
/
CREATE OR REPLACE TYPE kupc$_par_con FORCE AS OBJECT (
   ind1            NUMBER,          /* 1st Parameter number */
   ok_value1       VARCHAR2(200),   /* Ok value for 1st parameter */
   ind2            NUMBER,          /* 2nd Parameter number */
   ok_value2       VARCHAR2(200),   /* Ok value for 2nd parameter */
   ok_mode         VARCHAR2(30))   /* Legal if in using this mode */
NOT PERSISTABLE
/
CREATE OR REPLACE PACKAGE kupcc wrapped 
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
9
1cab5 5924
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

/
show errors
GRANT EXECUTE ON sys.kupcc TO PUBLIC;
CREATE OR REPLACE PUBLIC SYNONYM kupcc FOR sys.kupcc;
CREATE OR REPLACE FUNCTION sys.kupc$_tab_mt_cols wrapped 
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
225 144
E8XSTIZ57w7ckHiHuTf2pnf1r4Awgzv3LdxqZ3RAWE6OHHsU05cd0ttQG9z2UgiQ/8t5k9yg
C21nUTQkv1vg4QEmSfixu3KnAFloPq1ATsH43vNklsbOI/CwxNmARD7h/I4EXcrNhl2Y6XYq
n/9gBq/pDFGP+oxs1BypGvIu2wClIeJ/dSfw/QYseTqmiLMN7dCG8o5qliakFuPskWh5+uAt
t6baLhT2r3vB2XtCBDbECrVxTfnQD0lw64sY6u8ZH3dZR4zSjyACIxXKKVt4Ub0AC+t14RPa
eoaHDBdhC2XBXsHk+Ajo8uy++OEWHAIc

/
GRANT EXECUTE ON sys.kupc$_tab_mt_cols TO PUBLIC;
CREATE OR REPLACE TYPE BODY kupc$_message wrapped 
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
e
234 113
AcufSQMc4QeP1t8bqOuoIW8bBRcwg+1Kf5kVZ3QCkPjVZVcWjjWxBrixDB44EuqWvmte8z7L
ZueVtbs9YdaPK1L6mZb62cYyAso75e4zz3Gn1+3NRU4NRDXzZ/RjoltYeD729me301bASfK4
hRlYuN6ZjslUnHX2to5nF2eH05iNareA4DsGeTS6ahxKvPLr14nrNvsij7g5Xlba0PoFFayl
x6f0cPCEjBUKvChM0xBsHPuL4dAzJDAmwkC4IqXITroGvNGHtTkH9A==

/
CREATE OR REPLACE TYPE BODY kupc$_add_device wrapped 
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
e
2dd 148
03SR98pqf/kmLeLFZkAzJ56v+F4wg1XIACAVfC9A2k7VSHCmPuZr4MX8j9DWohQXpTGnJZXl
5x3gOD6dT9tIPTtWWYFwOv/Q3HLt4gXvWozaU89M0OvOMf4tJFX/xrbnQaYWhIrY6v9UtDAJ
4t822p3q6xagSquEO7jfqaosLqY1VFy9+KN6Gh0dyCBsgwd9dlZ7IL0EE9cOeomK/ZxDbEj2
8u+jGUVS68T+FGRvnZsI+CCQ3Wjvsxun7XZhnIIulcJUjQGtcsN88CD3HtCiRP9VfmW899Ij
mzTSyz2uHJW1oUXTGhPbpOXBFyQZlr8lflhu

/
CREATE OR REPLACE TYPE BODY kupc$_add_file wrapped 
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
e
811 1a1
yPeExkb/DuayDeA9GXrF2YfnbSEwg0OJLgwdfy9AAP7qR2sHb2+TlbeVhCKYr4qKn/GOYZzK
KzXSj5W1u8mx6QI8YcocaHbmZUIEm7yCXyAnRDTxsnqd7RmuhlWf/SxPhxypvr2pTVBCnhXq
NnsOpejmU7INdWAbAXfU5ZNtczQh4diI9KyzAZ/Ip/WeO6SmQPHVe+P/N4koRo+JPTs0M/ys
ge1p4qc5mI5jupJd+oEuScNuKOaGxtlRagk2kzFS0aU8bCLrdUyR6kJBchJgqwn6RYvVFCna
idOtAynT3v6IBU69iJdFB1pEsAlWzATYpBWhkXvViW36IJRSXHRgF4ZWMK9pM4dkGFJh3ZqJ
gec8LHLx+btONfik7WcjkWqPieKIco+0Mf34waKDchn7o5hr0g==

/
CREATE OR REPLACE TYPE BODY kupc$_restart wrapped 
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
e
2e8 13c
dHpj0kBMjuvGC5+pv7bwOwaXYa4wg1X37Z4VfC+pkPiOeFcWjmuQ2wbIGiY7YR/tcY6wZgZd
ZqOamvnnlekfTDSoaPfQaL8fGWQqWra77s+ddgdDgfUKy7GeRoGmiTXZXY79rNtrBkfK2Gij
sgwlp0QITegZxtP7YazDxRbSJOvosCQVC8rXSi/Y/7eDU9E72b7HnCP3OPiiOB9oWa0TxLkn
m/WWTx/3sTKnbBhRldi3gWjAoKIkpda4e7nzA4Qull9COHuMG7EEgBmcp1Oh+1CUCbe1eJmu
RNRCmXklTz81x8scZJsTuw==

/
CREATE OR REPLACE TYPE BODY kupc$_data_filter wrapped 
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
e
87b 288
cAIvCTUdz6FIfmpyGkqW2sjY7S0wg82JAK5qfC9AWPjVSHBad00nmR1RfFdK62BX3AFPmVnz
BoTmfMrD+SQXxjt2CGw5omx9UNu/ZLv/rhk2lpzhm+hTRgecsB5zM4snED0ZVSTiIE83WK+m
qXiXDmF2/bJjXHYKYK9YTJtzYXCFg8LxFvXml3KqY1GdlOvPr9Ih+KO8FbuFCBI9Lla1CZCs
bxEN4e+RoVQR3tiiW+fKH07yOtMNWIxqQs/8OqXM27Cy+ljqQHXgDer9E7YGej5c3/rL1N6u
oOAlGG8SRZTxpbh6P+rlbsOTPpr6+j/Lk9GVE39Q8H9YHAIGQJai1xlNWQ8988D+5pQDDyrL
KY07x2u1edZPMK/4RhFzXBNa/GITz5wu4coCnsm5zmLMBw3Wer2v8rizm9TFX/GGFr6QSfS8
qyIL4fZm8zyvB8wWvf3FXKJqiuPWmG6uSPTMU4X2htx87JkaUHYf0jGJ3mlBlsU+ylIhrtxV
p44EpNH0oUE2Z++TPZToyhPJiBwXxiG5JZDbDYUboleMl+4h/f/vUjcZTkxQLRrhE29HcA9B
yMpVxWGt0tA8TECPq4HfAq94ExXAUy29Mv4Hzn0Cu6tycKXrlnPdTDOH+2OKJes=

/
CREATE OR REPLACE TYPE BODY kupc$_data_remap wrapped 
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
e
2c2 16d
Tw/zpHoeTdHstR042cI51+zUo5cwg40lNQxqfI5buHJzjq2KSzXz6pb8pcg06FV8Qj5ClhXc
Y01J80B9/ngpi3FwZeyE7Bokh4+1FQXcmUP8OzC1Ge1HkrHu9n0kmiJAkMjD42qmB9siptqW
7Knd/QcGPvV8Hvb6wv6Dl0g/XbWy0FIjpxw8JepDAf/rV1mG1yHctgrE5nBL8vhtn6g0iy9q
qHnsBBJoCXw0IKklzTnG06ej3FUjMHaMBx6dffhqnT3n/oAWzRE+TbTaKv5U0dkFE5UmOCZZ
SldRATKcPrgbVEcEbjjGB1KeE/UpEI01rDLkyV//PYLCYxrgp53BPuigPFRkGGbX6iQIQvd1


/
CREATE OR REPLACE TYPE BODY kupc$_log_entry wrapped 
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
e
2fb 158
UBHxdUM6OJJtBxBqv7eRlkY2y3kwg1X3AK5qfC9AWE7VSH1Q8vOepLp/tP9sSrhyOxDR111r
5nTKZ+dA+RKKRhVgH0V31kPQxjPHZL4P71q6/qXSOmFP28Gxxs6lmwg/pu6ZpgH6A5kYO9Yb
yAb/02gCDeyiCwXj2+JPG7m7ycj7YRU+Ymg0evCweKkV8lHa+v/dqFuAj7Mh+q0uEHx6gwx+
2qviVDqnx2NtBa+HTBJiJxK1uqLkG6eVEbhxyWhSIkPWWTWF3sVjND7BXFzXP1DoggRiWCLW
oT9oBO2bBCaHb7Vvi2Bqf5Cbm/GxrCeCUP0QvJ2Fcz0fH+waNw==

/
CREATE OR REPLACE TYPE BODY kupc$_log_error wrapped 
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
e
411 179
+47O0WioK4eQncMkvxEUKVTKG+Ewg83xf64dqI6pkLvqNGuEE3FHMbPU+1PGUvfmmSiBGzkL
diEmvtu1lnY7VaAudnaXZ4/t0B/OMCF+L1N5WzD45DBBlf5V9s+IxlXnR+qmFauu0efCy5F8
rCP2jyJ+21YnBen1/0VCBj8cq72PN61rdbo8SY853UYqgL/hVgh0tD/q+Y1MqYSe/6mAYrfw
oIE1XggVLR7Xw+DN2pfLILsblgaD1TyDxoxBU0krXL6vqFnOojqJKHo+i04UJrwmnC7rVp6j
S8AFdBtibKiIf0zlWVJC2GIS8LOrAFm9mCRpHPGxEYNcgRe1RVy4QPgMtnbsZ3/r/PQZ5ap3
b0K8kuEpx7S2

/
CREATE OR REPLACE TYPE BODY kupc$_metadata_filter wrapped 
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
e
571 264
G25AEVzpvve9LpSl88NaiZzbl8Uwg5Ve2dxqfC9dR+rO3ajzzD3hSRxbxlKDqQuAM0XdPuUw
WufIL8W1cpL3ITXjnstsBxQZkPq5R0iPYe4U6pViQvkwmNoRDyw8Cvg9Iz0iIu3YLBm9KvhG
fGyyEdln3gmj+g4J8XExQKSgKlujaQ55k72PezXScuo+vZMJ12/DLAEFs9maDlwDNSBEsKLH
S6PTaun0ewgR2KkOV8FO8pKud8nL/4zrmWR1LrwWSO+PR4wLWSWDgl/Xs1N6PgHf2UqwKeeg
GhVKzAyikFmwpEq9jSBpJZ7zBsWdXXSDQBXgWuqyJdAjn2nBGb5W/zO1Ml/mRCqYdqgrQ9NM
Csfi1u+yfTCfYdfgSwZfxFmTvdZd9ciK+KE5AwiItlWEAQh2xJEv8mZr8ZUOWJC56rR2T/wQ
r3w+m4NTYEnHywQTambzxfCFHulsV6FuF8EfSvHTGNPxaw/Bs0D0TfyeCXYDJwZQrMdUY5bT
I5WeMXR5R6VqLVX/R72d+53lqH10hD/qN6sEarY2GgBRcjdPTxJ20+oRohgQvxoweoqf+woS
sppzP2sRIcEgqg6YuxDhHi5/cA==

/
CREATE OR REPLACE TYPE BODY kupc$_metadata_transform wrapped 
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
e
be0 1be
x8ROokJSxI6CdOctvVDUD/VtD0swg82N164VfATUAE7q0t378ZV00nAUHIPiC30zb4PEDFcq
bSwf1qtutZ1MW/N/e6GPDgsHySyd/qH+0t4Pbq5EOGXst8bEnAXiTGiclUzMb2Fxb65kKHLZ
RGtFhOecDsyISgn3tKbG9DbAC+g09oI3IVFaYsWee6fFHr6sT5Y2eF3DCEblOFBfwVP9uV2v
kVlNyVQG1MOrKSLM4fDhUemr2vZojN8+PBt/f0GpnIXSBNUXlmQ0oeTSCqGflV/Pr8b2Dlhk
60CtxpMoqAQ2FziqE9neJ0aVrhFKSgAoarsRTRHB3HNcwvavs+JJRSv3jYVwMC0lTbXERR8v
8Hv4chVWqJ0POwu4Yay3aeMJcnLxPIApSynOckmVCFYR/jP5Cv1TKvC8AjuYle0wLApM8Em7
26tG8g==

/
CREATE OR REPLACE TYPE BODY kupc$_metadata_remap wrapped 
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
e
481 185
qvKUG0+muz0u4Q0Ye8XdgUD9aeUwgz0lLgwdfy85cHJzlK3SUBVmBfw1Vhybf80reLd5ZZMp
PlaDt44Yd7Ug3w388i2ONt7LhCIc5ptloNipvYynikN5TncoHj1hQkhhLjBMOxOyhuLGdSF9
hSOh1MImgKHH1oqv6sIsIS/qbjBLDkIq487+OH+n7LqTuNr/SsdeT9sIFEh9DCyVhMk3z8+d
1sCrx/QMwQyDbBRw38b1Ap+CJ+/t7Qy9+tlI5u6Gz/GlSJm+3BlC8wtvHW0xFpiXB5rwPlxN
QimYUHfMh8FCsWZ6HEvOaqtSKPEV+S0SFxbCs86LTtQzcs12aS4jqgV0bWZv0qOp1/9kx/nE
Mp5K5VmfzG72gg2BBqTfrJty

/
CREATE OR REPLACE TYPE BODY kupc$_open wrapped 
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
e
5fc 1ad
04BnaQ063sEmIqQDuZ+BwOP0vJEwg83rLUjWfC85j/96Agd09EbF8Z9NqwGmx70vz5//3wkb
KFyw8nmnvKp55/Hra/MJdz50bw7QhqWqdYzhK4WbhSK8riCC/jIjtZG+3ASG0w2o2fAUYQ2F
LmL3zTsGgkmUj2i3nShIcyVD2wpuKylc0T0UGeOhboPePVLTu9IU/2qwUZREUFyYcDbU02Wy
zTxJhpYNedfIzPuYq/jT5rtZ45sy6xfbLIRguc+/kHRCL/urFyppuINvIo/g/3lFWZwKnJXd
5NaJ/jiAYMUgQcKC3pHuRlaob/DjRDfIOXG6hiJgdyPSbgFSqEeVAag0EbAdJZ3sKfXkxdEC
mxJlZuLUyxXiAsfdwJBo4A4oPXWjIyz5tQT5Bdc/jQsxMwZpVbVAFL0eaihq5ZaU

/
CREATE OR REPLACE TYPE BODY kupc$_set_parallel wrapped 
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
e
237 11f
e4FkyXc8QE4g+jaMQjIPttAPgxUwgzvI7cusfI4CkEIY2nwR4M+m9ITelgJUo31y3XcvahQd
CMFzAlH0t2VQ7ujt/tnNrcbflOblVB2xwbj0c+0SzmvtDRCagWdZNmeNISvaJ41AR6EnmWzu
isWrEtY86qK2qGl+gNL+OM9WJY0+/J2KyyGjsGwEjjFNC8+rSYrYFumHhUtRIWjcOUqwDuMc
vJQ6/iG9FoTif8hfcpA6BylK8Wyz7Cse5Ib1nRanASbYLPLcFLY32E5jfy4yTuFp1iPI

/
CREATE OR REPLACE TYPE BODY kupc$_set_parameter wrapped 
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
e
9af 18d
xYpaPM1GiTQ3tq8MUG9/TMFRp9Ewg1WNLvbhfy9AEjPqR6/WFQlhLLDyKKGf9WOYA/Zlk6WO
ojMURC0ztXgxYmJv5YmjTfqoT67TGUKIQJwqrNjCbH6HxB5rEt7+SJiDO0EFEJgdODmm5WZq
g8XiIVliPkHqNq5hK4QXyExioBb3zNB6EjQ9jpJgEY2ZEBNui/35qCwiyrryd0nufxGRCr10
b15kd5bwYlOxVlLfsLn0JUdX233uLevY4ighmP6GocY/SLcsapQLY9CQdj2JaBS/Kc7VseMV
UYYdoDhyGbApvyFEgwzNrhLzOEqJLjkXgfb3aoB6t23A/ihH10QB6QfRm1fN+ZA3CBRxVj6U
UvHkZCFTR+W2rqT0GtF2eBTS6iASD7K8

/
CREATE OR REPLACE TYPE BODY kupc$_shadow_key_exchange wrapped 
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
e
18a 148
75lg4att3fvmyGY4Y/0DSN7E1kowgwLIJPZqfC+V2vheaI+vObZoJSZr1mxPpAvqZZK327fn
9CaoUDby3vjNEhglYtur2+spc0oSF0AcN/rAqYaxQiyYct6/VxCYhs4e1E9zoPgwLGtQ86ac
5v0BvveexdVT3hqpPDN6nyNcicCGo3Z2SDrlLyobomgk7QE2yFQfGASBiddmYGE15O8Dop6e
8FzhIZ+UQw6wYZC99AQ88FOgMOsNCBIwQu0UBm399Gg9oF/i67+y/jkoAlbuB0Ci7m2DZaME
DE3Irws5ckJBsK+2QJur6b5fZqok5Psw4JO6

/
CREATE OR REPLACE TYPE BODY kupc$_start_job wrapped 
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
e
589 18d
UfGaqGBQp+vgERynVR2InfJUnwAwg9cJLdxqfC8BuepoUGuNxYllCX+0H8S9Uv8pkEwmt0R+
fKkO5CRSCXDv5Y70MEuKwbBOmP7/LP0dg0OAMDrPEuzG0Otq+D4inSKs8Yime9Ny++0LtDnm
D3usxSFX0AaU+DC70lFDc+02+xZ3g6XKMr1+z3Dhf58FJxFk09i7PRED1SbVzNn/SUPEv5Cr
NPnMtnKuE0pJXDGidEdAz2aZM1Ml4mNteC7mAxyKqtwXhDrJ36P4+AaYcz3jK/CKw2sWxKR5
D1mFmA8kQO1eI4ML6NKOwX51bTOsRTa4aV8CBhN/tvjE3oD9g+RXRcVrEXJ+agfTLhRcv1wU
fd9n7S+jO+oeVrqH8aqDZLymjExJ2w==

/
CREATE OR REPLACE TYPE BODY kupc$_stop_job wrapped 
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
e
332 144
5O82M0MagfQjE2cJkpw6fiozCs4wg5X3nUjWfC/U2k6OeHwUCT1bEYmvtFtXzigtch23Y/UM
QMoNELVwyvbeFFEwS4qYTyJV/qQyYuY46VucmvnV0JoksSJBZElwIh2PPDDAN7cyaTlqoaMd
LhFCHAAx3xx+LYhLndB3pht94VX4ZgV63Z40A219b3YJuDl65cBL388QaSFYVkvxyYlQvFGJ
xsE/IfokuRuGaDEBt6jw5mUVVMUrbKP8JuvKYcyCrn1g975WaS3RlNvYfC63GRHb0brVKQtz
tdKHnY0ynAmC73dapB4XOz5VIHjiB+jy

/
CREATE OR REPLACE TYPE BODY kupc$_stop_worker wrapped 
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
e
2bf 134
A3zh9z4DMugcL+KUceZNN2oDS94wgw3I7cusfI5gkBAY2lcR4M+m8B2JnrIwbf4ZQFcyfNx0
q6oGHgw1tklS3csu+IEacyORDyfjecIHkj8iWeSBn3v4xikJLJYvCARnk5GosNvTfnbFf2+o
v2PsMG+6kpcJ4t6DyJqAAaZQeQsuToenPRPN6Rdno3aoS9HfLobJ2eLI4hLYXtbNlLrcbOT1
vkiYCpWAv7V7cQ1d1YKhcNXrAm4TJdWAGszm/+XZmMRqowvCqyhN9pxz4h4kJ1t4E+l1jmJT
2Tm4pIuztu8GjRM=

/
CREATE OR REPLACE TYPE BODY kupc$_disk_file wrapped 
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
e
338 199
07toO+hIZz8tRjd8YvsZGNxeO9Ywg43xAK5qfC9AWE7VSH2m0+BwGuC4igxLBpY6HffRHBH3
5WXKqPkk+RZrVhQIL8a/cu17+AAkq0YrA/PcDyxkE1MkP0EGBQhzptsqpsPVwXkOh7p9rFFB
9kSEfPW2iL+EilPdHttznXtj+8PIYoMFk1MymEO4SZJDfJNjfivSVuo+1b2lWVYQZjM/HP6M
k+LXU3M9QWMg3VEoKzeEs2PBoYAfRmQ8xLTHPXcFgSLQ+moLLUEZLjzGxye6U9MmkMnfvoeG
O1D140q7GKKb/l+ZJZjhGLxg41oUCIUbdVm4PN+DCGU3voV9bV8Ull7w5F6M49uD8DTj+WhJ
zSqrdoMhJW9OTdCtjcsqXJoWtYzgBej6mgogqEoa8A==

/
CREATE OR REPLACE TYPE BODY kupc$_sequential_file wrapped 
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
e
231 15c
nFv9W0hW7TQWVCV6c7XzzVqElGAwg43Irgwdfy+VALuwdYQongZrgG0HMYqRsi4bKqoYzWzj
fmtUorM/qgP0Vn2vg3bmm4t4ahMf39WsPJ/9MK28AHIlxqU/dock/q4HoAUsOWeapufZIlMW
rDLK720OVmpl4ttWQiPj2zVr3AneRUfSmrCBuqZK6Gy/ENOnRbUkX8FZ3xcxcB1LYEm5s9eu
JeqPFqLGj6HZisWqEHdrYDEJZFMmy5J8QKoS6lGOeJ1RWZrdUVA7YeBYNIOnQHbgjWPUGdDy
3OXFTYL0N0W91L3RXghS5XUslGBedzR5XB6rhhNTuiHXMA/P+3OwMvo=

/
CREATE OR REPLACE TYPE BODY kupc$_release_files wrapped 
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
e
d2 df
NyBFrAtyQzgJHXXxtv95pXmSZR4wgxBKr54VfHRAAP4+wLQxW7gwtEX1jvZ77NJLXvMmyrnK
y5qaMp4GlXbmP9O8lmXL5zu7YFMAu8HFAJuJrsfcnB6JFxFU+xGuVqgnCPtZFGI8tnYGDgqO
UDhqdV8yVNy16mf0N6mzWAI0okrcGUpvEgzVj4XtiU+f+D1rxCRK0pOx/JlWggnq1VySi0Sc
LoIG

/
CREATE OR REPLACE TYPE BODY kupc$_unload_metadata wrapped 
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
e
252 16d
28hJZ4VZ5IH0xLds2fAHVqK5qLkwg43IACAVfC9n2sHqaN1Q8pT8cXevLZbzFa1qVZPj+hjy
sD/LpbX2xg7ypPL6LzGWch86KUjwUDnE1rGGsU5WpCQZIsYQI6qtX/gIfKz3Od0500MRKnz1
99jRHa/F4s1W6ZuvUyEOqxd3aMn4u7BOAKaVa+m8nRbaNOZvMeQP1PZdr3lym+n+ywQqZTcO
u8C8NI19DUB+LQ8lIeDIhwySxrA+GpC1nljcFVEms1mWldeBxfoBBLCGQlz3TTgurP2eAsF2
je++LBgXe1OgsjTm0SEPSwkgorZlB71e0vkhjA6RhBRiLBzFO3hiHuTQ6euJ/td423LPGg==


/
CREATE OR REPLACE TYPE BODY kupc$_unload_data wrapped 
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
e
2d6 191
10euJPAyacTlbtp3wWiipzTo3SUwg43xLgwdfy9AALtkdYQonmZBYhwlkaMfA6GfyQlNnEu0
E1EcirV4LNXnrEzH5/r4IrdkeMDn5/0gy6XAkjCHY+sFHvj1WcYpx+GVTFsO7QtrTZW2fozr
JRJb0H99XBj/IwHxzFHRgjq/ho+vlTjW9RCnlapLQDh/2nVDfmnZk5jEbZPUUslyUepnFvdx
4i0FdoBBwKAJrPu0j+K/MvQ3vwngNJhkvn0TLL4aMXHq8en3GmeH78ebkcjyXEroOn1HIB+d
VcIc/q4y72ou/WkcND6XcOzTjj72s29iTeje5lz5LsJTINw/LcmTlfHIhbHtcaADh2MaEPUJ
XwU64Vd7D9BfC16DmY1SIuRFHvKqCER1M4kD

/
CREATE OR REPLACE TYPE BODY kupc$_load_metadata wrapped 
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
e
248 164
2cp7eIwl+Mx+rhboy2Bkc/ebHKMwg43ILUgdqHRA2ppeMIVQWlyNrcxby8+wFqnvC/WXRtwu
sOgnQNJzmYBIfSUUdOcitQQ6t2oca2zHqXJPTvhmkLzGC5KSU1/GCGWsnrKpGyxGjG/gfVGx
wmwomFOxbZGhWF1picxRQccztT0xHN2AsWadaHT9z8p2dbkohu84F0Ctz4KYNmD0iqgOzcI0
z7Kz8j204J2BXpkfIz6DsSC3YHOSgAtFp3guXOiSafExTGwxmYbSV0/FnlFU0+tpESvMPiOC
gm5Ygt7KGagf7IAKd+XKvVjeFSKjEs1paSWO7YkV5SV7C63BLN8uXjOwD2ZPQl4=

/
CREATE OR REPLACE TYPE BODY kupc$_load_data wrapped 
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
e
2cf 189
brfkMXFY7J8+QQZyaJvv+dMWvlwwg43xmNzbfC/pJk6U0WGmvagnK45KAL3ztgXsiGSgISvb
n8o1+7XQLDc59LI+UV1oC9rs/a05ae3EgIGbOvk0DGQg2T6Qp9Dp3rmJZRktaSEGobKziFg0
XtB/dUzmZHnCo9IBM/m8VzBDBmgdTE8y7iziAQ0xkM2feH3N0Ry4A9qPU0UXPdXpyvdu4N2o
v/cPrVGgKyMESerEdUKJJY9VEHmVaOSg8TwRDwBvLvHhQh1H+rdExfbAf2JbF6qwpZCnczAj
5cZUSH45QqVhyDHf0yHeot0VrEhHL32bchRGhAybNKMhDhy+yHqNYGkDFMqbgfUfUirV8tSA
SWxTeaDXsHrB0Jq/TL4Pz/tN9vGA

/
CREATE OR REPLACE TYPE BODY kupc$_estimate_job wrapped 
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
e
142 11b
3QN4uQM/Tu2cZ7Nh7oSOwk6sF48wgwLQLZ4VfC9AkPiOePVQ6W5iy3kjp4PSZpyZBo7De03j
rIFzeatbSdcvwJq1x8/3c29rfEMc4mTGPoFVAySayxDBlv7vXd/7aUDYS17gBDxKiXdADlK6
jSOgCcS+Dpp14HvDqk9haPvI9pldnVWIfBgL4W0jADB0jDKjUcw3XC6GGDwr0yJLcfBgJ/l5
XSTebwpjmohIyIRCafTDwSt6ZRPzt+t7m/NCAXah52/3YLClYMUDFL3+XbK6JPKc

/
CREATE OR REPLACE TYPE BODY kupc$_recomp wrapped 
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
e
12f 10b
9DGe70CPqxeTkdDp0NpVSJ7Ey34wgwJKLZ4VZ3RAkPiOiHt9Zv9vBzPRYmO/vvHZzG5IFtxm
b6/+xLHHPHSoOpu2Ir5K5/Dr6lOdnL5fZAXkz1Zp+OFnrZsVNfQLER0+KaSvL2BcYGBDilMP
hJ3Z/L2prHnItcko3RY3vXrsnypU6ixfkZw5mEFhHzy/8RpynNfppAMM5JvFB/VudiiFPmHy
kScnlvNYVUA+BLc6QFHANxSk3FjJEyHvKeVaef77tgKiEA==

/
CREATE OR REPLACE TYPE BODY kupc$_sql_file_job wrapped 
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
e
1c5 148
aLuTyHmFn/ABLGd2IrxPK7ECbKswg43Ir/Idfy9AALteR2tbRD4GswaoEy6fxMlJUmU+0iEO
FhGZO+O7IPFcffrgy6g6iwt1qjD9dKC8BRW5Hs40yHLQ7TS8zQ9dc6U2xd+mgwuR8uwANy5N
QtLnKD59AtuASZ/1YDy87Uf8msY5qfBmABZF7SIghqp+GHR16DxQk4GehbhmRhFu1/NOeBvG
x7Q80u88b16KvoqLubxAPdnrS5teTFwNJQ4wFsKySS89w9pUbmte95UvQ1zJGPq+WOoUg0ld
CVNY3hxflFzxTnPCZRJC/YorLl65bSDMouAd

/
CREATE OR REPLACE TYPE BODY kupc$_exit wrapped 
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
e
b7 ca
lbaxUQGfZ8UQZlO1yYadbuEvTpMwg5n0dLhcuJu/9MOF0WJaK/SuO4VWzLh0iwlpuDP+mcu9
njLLCCgJuJmBx8sI0v5epcuyuCv0v/CldPvl3SiscYTm1uSOrEwQaKk54b6vayKoL4yQcVUA
c905zjmYB6lxcAGZ34OTKJH1esN37Jk4y+PN/MHg15VEZoimiH3VHw==

/
CREATE OR REPLACE TYPE BODY kupc$_post_mt_init wrapped 
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
e
18b 13c
zs5HXXnaKhi+76m+NSGaEf9dFP4wgwLQLUgVfC9A2sE+SHAWCVwyOTK4bu/CuP+zOlbb9R22
5Q5aRv7GSm13vXpUM6pPqhCnc+NQQEgoJMTZOGucmh4asKHQwYY2G9+m32mO3Cvhahv3lB/n
Yd6gmaSEjqSipK1Ccn1OKvXapvKEbeQI04vnKM5smDZgoVkvsyDC9bzUXWP8xLTa7NVAtAw6
zfwSPMRPtYGBIEXiFhgpXwRVRBlmnEkxvP/AvgRvgBD0rTx3E2gCRzhAPkIPTq0J/dOhiM8A
exggre8yHug++AWkhXCTBA==

/
CREATE OR REPLACE TYPE BODY kupc$_prepare_data wrapped 
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
e
18f 130
mU1kQxyH9sEqzx5iScGz5vUqH54wgwLIfyAVfC8C2sHqaN1nYxhr78wHbce983DavxcUG9VR
WUxmw/kkn+EJsNRqt7s6mOsAHjG2w+IianIQNNgGMJhKas2rnQea+2mepobYFluMSmu9PBHB
VorWeAp9WHpllauUsb1ztVpP20AL6eQt5xJZwObf2l1yAW7pDwMfMb9wJd1vRssul3XyvVuQ
6yt3n5+rUokrTsF+neigyU54ec+8p7bsORbCySFiZRIcMpyy0Mdid7qcsikPLkL0z0m6nOn3
gc37e6XD2g==

/
CREATE OR REPLACE TYPE BODY kupc$_restore_logging wrapped 
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
e
118 103
lSMsI/kkrBi+qDwhb553c7IqsMYwgwLQf8sVfHTpWMeeKKRw7qbDdCEyjBg83oaRfYn7XJTh
zMOP+RRith0wzsI7SbUgBSrnWP/aUzS5sNuuc4at3O2dSmq4vLK4cPvKKi0q3KN5DrgUeSa9
SuL39HiFOG28JfKNGjw3+UxoOajqFxH5wv18EZCocNgYL2xfisWYRpd8BP9JJyvfvC0Fcmtd
M9WJtaYpWYJhGu/ZzcJUeuDQibDmokzt++yJNSo=

/
CREATE OR REPLACE TYPE BODY kupc$_fixup_virtual_column wrapped 
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
e
127 10f
rj4yjeDvab+qbrhlwUV59M5c8VgwgwLQr8usfHRAAE6OALhQbSjKCKYLL2b1Sztg3G2of6hR
04Zf0Ls5HPAzUKDXtcQPMrrHWqKDFTFKTBHcc9lKizGaLDNXdbnftNmU4JSmfDfyDOCjWoXn
WNE2FUonb+zYV2l5MwJ3jpxA9PHFcXvZu2nwDFpcFUMPzZ4UsRTzjpaCxoaj6WNB+tNBH1c7
TcPic4QTzaLUPJqFR4CULm+V/Y4ZDuxCfCybKsYhnuFPHyA4w2B3

/
CREATE OR REPLACE TYPE BODY kupc$_complete_imp_object wrapped 
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
e
1b2 138
sw2+M+O4IfFitJ7kd83cFzprck0wg43I2ssVfC+iJscYYhZn5namovdXmZ4UmK+HmcyTZvKv
rhqp+AtJz6s2FZWXP+wtF1YF06ju9ZnGul6BTDKteLCSo5hzvlKcVWvi4i8T52d/iLMrvfZ1
ugnxf6+Xp+W7jh8BSqzR1fLG+tONdDSG+OCEP/Fi03eMTyeSDDvwNHcklYRQFiu2BEfBvAok
qxMMsXuv6WDNlAKTWs4K+th5O9Qso5gHEYN7V66QrypSpc5FpGxoND4AJqpe4KQJEvyGJN7n
bzNaKSEYFYpV+yM7D4w=

/
CREATE OR REPLACE TYPE BODY kupc$_api_ack wrapped 
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
e
4eb 13c
zoxgzRFFac/eep1zEK0eyJZPp6Qwgz0JLcsVyi8yM9VIfQ70f/+rWxiAXm2Ax92Pol+3KSWV
tR/yhuB3lWtlyJjG2VWGQ77HbWnsaohFEqpiFWOdAtkNHTjBpiXIMopjgnSXt/UNqBHP1W3K
g3vnMVZmHk414Zuw0zrVx71f/4I36TtRqbSjZEynCeBc63wGkdWcoiD+1o6+HGNGCDh4S8it
4i4UGknTnfP7m6MXWt7MMTZ5wE/+sKspSxO1/zezrD2/0U5X+RGX7IlYX/YtdeXe8uqqyC1N
wMI++AzQD7Y6PAb1chwYYTa4

/
CREATE OR REPLACE TYPE BODY kupc$_mastererror wrapped 
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
e
253 124
PDPXzfjRAYoSMd1WT9OKjX24Mvwwgz3IACgVyi9AkPjVSH0O9H//38tiRAljUHZ89SdfKZFf
OYG12YBbSTK49zdomXJV7b/ouxbD5bnu0lMcTu7PU1WAeHu/Umn8dKkWJrKj4I7hA/F1YKG0
BUpdhLonhPdmxW4Sm3MIBFlC2lwq8SbQPplnJ1byUMN8u9QMeQKhvMWX/YgMoOwTfJXJ/R63
PW1kOJJWZvqi+jKPPKGAFBEsGpx3fNvDPOkzajpYj6YlYZSVQ6pi2dq1n0zuQQD79OU3NA==


/
CREATE OR REPLACE TYPE BODY kupc$_masterjobinfo wrapped 
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
e
266 124
+wATGIS3+Km39ZWSKskl3IuGdZUwgz1pACgVyi8yuWRTa9Yb1FcFV46eGvJr7gt9d02zovA8
zgi1AhUGUX9S9+6PuRnaGQDrdzbIVqtXItEToAA7SP7NgVA7/sFMW77cpkuOgxZt8MNnO93o
ieGnYdTeukODLw3ITY7Dy6QzcwgW43dakoWIN2bUxfvsuPw2vsO6SKwholQ+kvONydRkZRP+
Tghd6aP9BZPQY3oXg++wqNDKDwi/FkAPcxPjZgw//B1DR+k41aJ3zrtxx/ydpdfGr7Ym/EC3


/
CREATE OR REPLACE TYPE BODY kupc$_master_key_exchange wrapped 
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
e
180 130
b4sP26D8wgx6OZh1CaflxRrBONwwgwLIJJkVfC+VkPg+SLhpL1uAlWsucgTYoaHR4LDKCY6i
87WpPxK36NbWtHTuAr+dhu1pXGaRxWSP0jS5+Lk0mCT8E9o9IOqdM8ZVQ2mEJ9Om6BqoeYg+
spnViL1sOAEMPL8edy8nxBWX7qdiXvpSj/S1sKBYWzS0GoOCI2X8osCvs1AfJaF0Ne+TYq9w
LaUA5Ou0rOCMdL7I1xgN7o75OHsgqy0I0GDipOxseZLmS3wvDrRsezfe1iNJ5X3bFjWMRxeh
07kZW89wVCo=

/
CREATE OR REPLACE TYPE BODY kupc$_mdFilePiece wrapped 
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
e
31c 150
tyI+gCc+0CyIGL1l4jCfkc94VHgwgw3MmEoVfC8ai9VhDlcUnidR1dMS8Fbf9tnQrMXpWjeP
GvbOqm7Z6QfLmWYUcbSGMaTZ2rYzb2tlwCiw2b+YEbzL/DC5ii322hZzdmcEM6/p818dlJM2
eQSfsxjpXgxjvTtgN498osaP98MlYwrQjkAfxWgn3EmpXw15I/CnphOuVB+qoCq8xrXe5v+z
bPfz/qDMxbHXAfCdIYBRExi4FrvFalYAYKeVz8K9LCT8gAzeraZKMgJIgcN8RWWTfJIqk2nx
U5R6zQ+8bzLseiyfrDpTtkdbQT/kM4X4EJ9ERRjoTA==

/
CREATE OR REPLACE TYPE BODY kupc$_mdReplOffsets wrapped 
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
e
164 f3
gk7kBgBc6jSUHxxIPjjbsmYcBq0wg5Cuf8sVfHSRudV69anwWBg3G8vlEZCFUkDcpA5MpiYJ
7rUa1xhnj6+8A7l+kKDLa6BFAh7HesFVcxVzMANqfIHQvcsiHWmnNLhp4IhZymyNbFdEsJvi
s1/iYdQwjihf03XdC3lRggksJ6F48norjkln03IRxAd5LYrxUtRaRYU/zr6H5E/FnrYOUImF
pT1LOu+AFLu3RxCB4XUaaTE=

/
CREATE OR REPLACE TYPE BODY kupc$_fileInfo wrapped 
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
e
26b 185
37uG8XRFmhks0oguzZ+fBRTmYiMwg3nx7dxqfC+pWE6OeNL7cGzgpXKtAD0t709M86fL4/JN
lEul+bQuDIboiPHOmLv/wU9Xy+clHvPLnSS7ClX5Ts41D/ggL2imFrtXQBpRKHDxXvc01i6r
dycXhWathqhwWa/7jCqtPiitMVdjDIqFQ5ZnLUz8bEB6MD83xjNGEncU4N5rFbp0ccmsq/ae
VKOIcrRs9gX2QrPvaPClqSeIKdPeU3pcGh9ksCEjajrS1BhKF70XVtiBJ8DV2uoEepqDZdkT
Yzs8ZnzUJowx+RH1l/bATAJOHAu0UUq8FXq6UHRJYBBbDxhWfqhih82wte+ohJkSYlPBBGPt
O0y5ojqAsAXoPrsHJL/ArD0=

/
CREATE OR REPLACE TYPE BODY kupc$_file_list wrapped 
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
e
110 f3
AGABOsBrZ2uNA5aOhVpHyfrTyWQwgxBKmMsVfHTpWPiUHHvdFVtpf1B3JmbmCZX/UD4d4SZR
HdOltV03lzYcViS5DSjQHeb2mPNIZPi+y7HevEZCI3ruZ5SpS0C0Qq88N9JgS8I5Sj8vMsjy
C1AYMKQynYQbocW84no6F4OphDP/pmun8xRhXSofGm8SAcL4ogBJ5FUiLB8FRD7PKy48YiSM
fIaJUjr3JyFMXlw+ZBkVuiQd

/
CREATE OR REPLACE TYPE BODY kupc$_encoded_pwd wrapped 
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
e
15a 10f
/+uNBQNINSOk3idOuK1dzpTGWPYwg/DQ7cusfC+pkEIY/QQhfyKp1PuD1i/u8oP2415bcGXM
b4YeBQn1f6vaIf5OTLnaIsTnvvEXU2iwIjKGDZ2yho/oxqZYoaZGZmqDniurngys1em4wjta
pPFp02P22r4zXf7BNXJGWhdVMyigYOHCLkqSHzT78H4qN69FpWEiKmGLfZALk7N6VXXxao34
hopin1IHuvwHkTH4RWyp8zoRvsozSPgU08zv21o/Fr21/L0l3Nzf

/
CREATE OR REPLACE TYPE BODY kupc$_get_work wrapped 
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
e
194 103
K9F7mXSCfDVllyqYXpid+TKyM3Awgw3QLcusfC9AkEIY/QT1f//fywnL5qnV3mSoWaTjUnBQ
BPBkILr1gvwGsu32u7W5uwhQqJHFLHBFkMZ3pCjqvyRMG7QTNmfFZdg7kWNrSxS+CTYNzZH8
8pGx1UzWYGHs3XBeMIUP8Hkw1IJW1ZuIDipsW7DN0QbAcxVVA+9R2JfW4O/mpCyL7mv0iW1d
xJZi75I+IyA2kQV0gerN/Cj9I6oIn5240RyYzUwm

/
CREATE OR REPLACE TYPE BODY kupc$_worker_file wrapped 
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
e
687 1a5
a24xEbBQskCIE9YfF8ae2UCa2Eswg83Dr/Idfy+BaGSFa1tE9wDVHPF+wkbJt2y3aWGcdhrm
3jU+4527fmBjBwbCJ2Nb/kuRG7tsWP4b9BCwdaUycmGWcihO5JKgmuL+OlIDuoLLgtQavy+E
8bNb6Le3szDGbya3TjTSOGvmPNTlDKI/c2IuLh2co2sVgRZrHYLwDnmC8FAVJ6uoN3Vgj16/
UP8s02AI6lZNdawLDtjUzXxGke+TScMLaF/FeQZw0s0QLdwZdlScmkm7ntNM5i/s6ahpX4dp
2GIgcIUOtIne8IJ5J4J1XJMs6WP0NuX/UdBsbZfMp7oeQ0l1qqnZNU2LwkVOibD8QC3AMBoP
isZPn9mauk5MzQoLl+qAMmTcO5KIvOG1nCM0LeW2hynuqgg5A2UMTw==

/
CREATE OR REPLACE TYPE BODY kupc$_device_ident wrapped 
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
e
1a6 12c
29OD37QeLMjrmVjjmPUJ5JDPpTwwg/DIJCisfC+VkDqOeHwR4HZ2bMtjdrTn6uskFFmkqTd1
BFuBTroWHbe0a0IQ7b/tDy7HhFoBPN1zc34LsYFPa81VUIHQH3yk+7ihgxbZ8MPIugZgWqwK
7Qi0AVSZStyRWskeDKpkNFasyrpjTTMe++WsTVgGH+hKtaJdm/A9kqQWISvzEVbHch7Qg6cb
yLBU5+yjw0V8hoCQ/7atJFb6Vc8TojfxlCNW0lMD7/L12+U+uVinuSEBpQGlanqMYJfxFqv+
1x81DFTG

/
CREATE OR REPLACE TYPE BODY kupc$_bad_file wrapped 
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
e
151 10f
31lvTxyuUgwJjQ/qRCw1OWhkA4owgwLQ18sVyi9GAE6OEn01toYdtDAW9QUh6RGnbOhJBiDg
0o+V/h/y7cVbZXQDfCzQHayggefQ/h5xRusI00j+wZTFSaaJKkr61WE28HgY2vYO/tbFrNj8
UPWrnH8zEqjMb+2WrGFiq+hSc79Z8dfm3tW16OpnhUF0V3cuVizQ//b/BNMF/1muikzZ9DCY
E3x3i23zixMJR43vUnTp95CJ7xJah1an7eQLJRH8CeOgliI10oCY

/
CREATE OR REPLACE TYPE BODY kupc$_table_data_array wrapped 
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
e
12b 103
VaNPaRBQPMVYhdVYGNm6lKTnYmAwgwKumMsVfHSRueowfaaZLGeVyBveXPPxxZ9A3MwwWXwO
5XTkAKFqaX+pW9nQTlVYQIfmedumxMGGcZI+brnqqr1epTh2apkEb6ZoERQeV4iZ8Otue4zu
jyOHI+AN8Yd84EGT2UAyRrXL03VtIOHkEkX71fqTshZctjuVb5BRfsKnebAXGO9hifmDzRey
vEx15IrliFNQ3I99VnID8uVjb1zMGjQjHTGI6QM=

/
CREATE OR REPLACE TYPE BODY kupc$_type_comp_ready wrapped 
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
e
11a ff
THlm7BFHwcsS+oI7uRuPfBDJUZIwgwJKLcusZ3RnkDoYy3RFzvvTW62eqOYoZO03KeDI+gT0
szed/rm4wFD9I3lOgyIp2kZxHwBxD+vIRcF68EhTmhv+BHKciMtuphYuVtTFsznyDPInLrig
kPKQzkKw9QWt1gdRDxKS/gsYLDHfgE6cGak1LUCpLT7tX5Yx38IRQ1Q9juqgcUTztM2Mp4M/
3r4oyOnsCKJ7S1kMC77zwBpmDPEv6iDzzTWQ

/
CREATE OR REPLACE TYPE BODY kupc$_worker_log_entry wrapped 
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
e
124 107
Gf607iNmxg31sqtA9w87dk+EGBQwgwLQncusZ3TUkEIYy3RFzqbTW62eqHDQaIHmdUh82/vv
QBFfILtzUsBQyy4T+bwz1Sik5tFt++jGzYmDwTRZhuCWTjFKsfibrNbcpkYU15fnp57yhKz2
oVB13BphnOU1AbqTkxQraoPunWprLRFZ/DI1M+oN+wJ+jjfUYfXicQou2bMPSlwuOJXM6ooP
g83WJC1zMxckom+lvLl6/Ogt0HjP8MORoQZO/LKfmKJy

/
CREATE OR REPLACE TYPE BODY kupc$_workererror wrapped 
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
e
384 148
x5a0TtYf5to1YOK25Gk4CzTtui0wg1X3LZ7hf3RAkLs+ZVcW4ygOVzDtQW48wyWOUkU1bnaJ
rM6S6B/zSSiAzVDoqk4HP70sn2/yD6SPz5gcB81z8f+w9fIp8XCInqaGf3zpakEOShFTCOcT
U4Jqn7veC/rTQquhi8Fs3qtNv83ZOfYkKf6IXdHdU2Jigf1xj3lU7XTtOgvK2fcvrDINfNkq
osbyD4Nc1ky9Jvq+6gPpgHDoINLNTlKHeqFj6vFJrwz6jpPxXioNeFwrf3uw5bo5/z3C5crl
Hh/Hfi3sH51XnO1L+fjKAgiYrYsQpabXfZjv

/
CREATE OR REPLACE TYPE BODY kupc$_worker_exit wrapped 
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
e
11a 103
nZeYHc5lVmXu5m8XGKarVUj85pcwgwLQ2ssVfHRAWBKeKKRw7qbKOexFXHff9HaAUD6EPfsy
plzKVyKhat02HFYkPwVPvnjnAtESdRzEqP5yHnrwAywPnNp2eTnKoMJZ3EsbTW7TVg2s1Ij3
+LfoOfqGk5t7FqoT9wGeiR6eGp2Ssi/C70RvBcUORndFp7bDNw3D2Rj/PHYPtKRvFi1zrJtP
iz/MqyXhO4EpP3bnWiaN0ZUEXBYBs2QZlLQ1HQ==

/
CREATE OR REPLACE TYPE BODY kupc$_worker_file_list wrapped 
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
e
188 10f
qlD2a66bteTKQngblmABDS+EWJ4wgw1KJCisfC+VkDqOeHx94G5sywnLJWmjJYeEbnsEWecU
q3fOgXmv9FNXMGpzoRlzGYxe8MjlijZzTp9KVR57M8190VVQRWuYJI8RZqboGqh5iD6yvo1f
U/Fpg+yV4sxFos3A0VC9SOch8T3TdBhoJPjrVDWCG5WsDCT7xV5puBksG3QF0X+5jFobrXKs
wHgsAzW0zMmh0ro0MoaTJSs+/Neiune1JRKGuzqED+37PwuRkw==

/
CREATE OR REPLACE TYPE BODY kupc$_worker_get_pwd wrapped 
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
e
17e 107
WRjKogwt3JmM2Uf2ozGe4CEVWOcwgw1KACisZ3RAkDqUpAT1f//TW77VRqYAwLGZUkU19B3W
RhHO+Bk3bdSVr8tzWgXBEDp3yhryQQ6qdMG0LsQtu2C/zblIddG4IfOpaZFUuq/yhMmhuGvn
8gXjtA3ynE1MSorsK6xgYezdcI066iSrugjhoX+Wheqpg112w/4HiGZhuy/+g0lOUqhqVUiI
b89995HTc+B5VSPTMXvp7ViTLAiWwYczmP7I6q6Lijii

/
CREATE OR REPLACE TYPE BODY kupc$_JobInfo wrapped 
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
e
1dca 61d
heuv7bYpYGzlfUrr1FLZn3F+qb4wg81UuiATfI4Zgp0VKI3dox+BwhOnMtP7sAEd2mXoTEFQ
owG6eCpYJVmDGnPOMXDdG3HH3v5LWmIE+M/GwTM6phPcLwTzv568teRSxy+dD3ESTnKZcAc5
psuvqIz3audEhufaR+8Ez+Mbyw+AYBwctm1kJ/k6XWj+fOFByHrjQ0tcdOEYVKJ/5/cki5ju
anybk0Vk83v+uOE3FrJY1+AtH6WLWUhK1TV1zCgCp3c+QF4MxQe4deewq9sAFblQtPevdBCR
FYMME3sf3wCtfo2PYC8YjHBGTS+Jv9GrBRXgdjr5hlMK3ArTgB7OaTFza0ukubHtMbmJRvLU
KItRWTg7jeZox54dpBh+QBzYcCGqpzsKowsyVqtThO8sxFqfzVHwmUS53yBhVl+kU2yWy9fC
pmyv7GkGynhR57TiBfw0K2qSOZ2RyHg5p6OKHQeidTfEqx10z5alBFk2tEQVYEFfldMcl9tQ
9fLdb9rL+xspOWtu6mn1dhCCvKRlFs5Japel9yxRIpujURV2RJjPsClNUyBfnFoGc/fqurhG
APTax+qfmcZAHJfP4PXdUCFh2A2DS8JMiGzQuRt60KKYtda6tnGBqRG23H3ecy/eDF+i3YNW
/80pfy0mpHYKPo3BQN6fjiQx3OT12gjBBfSdtNzkQ58GZGG2qkzvvJpq9aqVVS7CT0EHFicN
kolQAuu43drY2dZ//RTV4MwIp0VUbw40QYUeJjQiu+zbwHMMQhBsZGSoft7zm8kyWRFwA1EM
w4MhQcXmZv3HTkz6loTvJJonQejeFEL0gORaWcKZllaPXEzgb4wK/PrsX6G3tHzfV+waDeDc
kiYR/yHHvosqdyWTFHi4Mu46Wh8r7FoiNRtC7yYjaxqvCfNwniAWpOUbegQSw6Mxd9jl9wb8
xcpAOoNoX3FR1J4IXu8rxdxcIOyZ3gzYejCeSgcqcKdANCtNXEQKOHic0IumDC2Uy+Ueviw5
LF1bz7AvcDXLxaKoPsJZV+3lcyChPb2BMLVp8kmkXhAkwwAZtOy4cUeJv9cZjrPb4TsBTJHP
XEyYjMpfodsb8/2lnVf6dLcQ7e2WEGxMcaoTVdimqiKY+C2SeRUqq32ZMgN1ZCJV/7s3vfnk
+0KmiPSVqExS1OYt/11waPmVHyEPYqoM2BK2K8dZCzSN5hm2HyqtYILvUjXJvjkVScCxdWxP
AeEjUl28CV0aZbWfIl5MM5ZeAQ2xqcnyMXmtLE08seRZuDP/dxaw3O94CRYTtTSYQWKvk1Fc
hGRfaquV9DWj60uMo6Bx0acFKVx9vgor3/gN5XczcrYwQKNymteWyEeZL4CZG9oX3iIT4Rdk
yjwpzDKuK2pVojrha3dPopT5jb7d2t6xyX1Q9VUX+69y6F5em+jcA1yQ/q3gUoNVZV3UFf30
Xf1wy5TofZcmEFQytxyWt4qvcWy5/MaHADoKDK/YxBFlDqw8o2MHYJX+hRmBYYdSQ+wdsi1U
XiohlywDEo0nQnhDsX8ItfoPgh9Dxg==

/
@?/rdbms/admin/sqlsessend.sql
