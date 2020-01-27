set echo off feedback off term on
col description format a38 wrapped
col "Parameter Value" format a25 wrapped
col "Parameter Name" format a31
@hparam optimizer_features_enable
prompt "Setting OFE to 12..."
alter system set optimizer_features_enable='12.1.0.1';
set echo off feedback off term on
col description format a38 wrapped
col "Parameter Value" format a25 wrapped
col "Parameter Name" format a31
@hparam optimizer_features_enable


