@@?/rdbms/admin/sqlsessstart.sql
create or replace
PACKAGE dbms_dg AUTHID CURRENT_USER IS
-- DE-HEAD2  <- tell SED where to cut when generating fixed package

  --
  -- This function is used by an application to initiate a Fast-Start Failover.
  -- The broker will determine if the configuration is ready to failover
  -- and then signal the Observer to failover.
  --
  -- The caller can pass in a character string to indicate the reason
  -- a Fast-Start Failover has been requested. If a NULL string is passed in
  -- a default string of 'Application Failover Requested' will be sent to the
  -- observer.
  --
  -- RETURNS:
  --   ORA-00000: normal, successful completion
  --   ORA-16646: Fast-Start Failover is disabled
  --   ORA-16666: unable to initiate Fast-Start Failover on a bystander
  --     standby database
  --   ORA-16817: unsynchronized Fast-Start Failover configuration
  --   ORA-16819: Fast-Start Failover observer not started
  --   ORA-16820: Fast-Start Failover observer is no longer observing this
  --     database
  --   ORA-16829: lagging Fast-Start Failover configuration
  --
  FUNCTION initiate_fs_failover(condstr IN VARCHAR2) RETURN BINARY_INTEGER;

pragma TIMESTAMP('2012-01-26:08:55:00');

END;
/
CREATE OR REPLACE PUBLIC SYNONYM DBMS_DG FOR SYS.DBMS_DG;
@?/rdbms/admin/sqlsessend.sql
