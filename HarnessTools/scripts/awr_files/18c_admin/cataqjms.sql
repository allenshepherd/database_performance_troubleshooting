Rem
Rem $Header: rdbms/admin/cataqjms.sql /main/2 2017/10/25 18:01:32 raeburns Exp $
Rem
Rem cataqjms.sql
Rem
Rem Copyright (c) 2015, 2017, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      cataqjms.sql - Create aqjms types
Rem
Rem    DESCRIPTION
Rem      Type creation related to AQJMS
Rem
Rem    NOTES
Rem      This file is used to create types related to AQ JMS.  
Rem      cataqjms.sql followed by cataqalt121.sql needs to be executed to maintain
Rem      all versions of AQ/AQJMS types. 
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/cataqjms.sql 
Rem    SQL_SHIPPED_FILE: rdbms/admin/cataqjms.sql
Rem    SQL_PHASE: CATAQJMS
Rem    SQL_STARTUP_MODE: NORMAL 
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: rdbms/admin/catpspec.sql 
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    raeburns    10/20/17 - RTI 20225108: correct SQLPHASE
Rem    atomar      09/02/15 - aq jms type creation
Rem    atomar      09/02/15 - Created
Rem


@@?/rdbms/admin/sqlsessstart.sql

create type aq$_jms_userproperty 
oid '00000000000000000000000000021020' 
as object
(
  name        varchar(100),
  type        int,
  str_value   varchar(2000),
  num_value   NUMBER,
  java_type   int
);
/

create type aq$_jms_userproparray 
oid '00000000000000000000000000021021' 
as varray(100) of aq$_jms_userproperty;
/
create type aq$_jms_exception
oid '00000000000000000000000000021041'
as object
(
  id          number, -- reserved for later use
  exp_name    varchar(200),
  err_msg     varchar(500),
  stack       varchar(4000)
);
/
create type aq$_jms_value
oid '00000000000000000000000000021040'
as object
(
  type        number(2),
  num_val     number,
  char_val    char(1),
  text_val    clob,
  bytes_val   blob
);
/

show errors;


show errors;

create type aq$_jms_namearray
oid '00000000000000000000000000021042'
as varray(1024) of varchar(200);
/

show errors;


create type aq$_jms_header 
oid '00000000000000000000000000021022' 
as object
(
  replyto     sys.aq$_agent,
  type        varchar(100),
  userid      varchar(100),
  appid       varchar(100),
  groupid     varchar(100),
  groupseq    int,
  properties  aq$_jms_userproparray,
   --
  -- lookup_property_name checks whether new_property_name has existed
  -- in the properties.
  --
  -- @param new_property_name (IN)
  --
  -- @throws -24191 if the property name  has existed
  -- @throws -24192 if the property name  is null
  --
  MEMBER PROCEDURE lookup_property_name (new_property_name IN VARCHAR ),

  --
  -- set_replyto sets replyto which corresponds to JMSReplyTo
  --
  -- @param replyto (IN)
  --
  MEMBER PROCEDURE set_replyto (replyto IN      sys.aq$_agent),

  --
  -- set_type sets JMS type which can be any text, which
  -- corresponds to JMSType
  --
  -- @param type (IN)
  --
  MEMBER PROCEDURE set_type (type       IN      VARCHAR ),

  --
  -- set_userid sets userid which corresponds to JMSXUserID
  --
  -- @param userid (IN)
  --
MEMBER PROCEDURE set_userid (userid   IN      VARCHAR ),

  --
  -- set_appid sets appid which corresponds to JMSXAppID
  --
  -- @param appid (IN)
  --
  MEMBER PROCEDURE set_appid (appid     IN      VARCHAR ),

  --
  -- set_groupid sets groupid which corresponds to JMSXGroupID
  --
  -- @param groupid (IN)
  --
  MEMBER PROCEDURE set_groupid (groupid IN      VARCHAR ),

  --
  -- set_groupseq sets groupseq which corresponds to JMSXGroupSeq
  --
  -- @param groupseq (IN)
  --
  MEMBER PROCEDURE set_groupseq (groupseq       IN      int ),

  --
  -- clear_properties nukes properties.
  --
  MEMBER PROCEDURE clear_properties ,

  --
  -- set_boolean_property checks whether property_name is null or
  -- has existed. If not, it translates property_value into
  -- the NUMBER type since Oracle RDBMS doesnt know BOOLEAN.
  --
  -- @param property_name (IN), property_value (IN)
--
  MEMBER PROCEDURE set_boolean_property (
                property_name   IN      VARCHAR,
                property_value  IN      BOOLEAN ),

  --
  -- set_byte_property checks whether property_name is null or
  -- has existed. If not, it checks whether property_value
  -- is within -128 to 127 (8-bits) because both PL/SQL and Oracle
  -- RDBMS dont have the type byte.
  --
  -- @param property_name (IN), property_value (IN)
  --
  -- @throws -24193 if the property value excceeds the valid range
  --
  MEMBER PROCEDURE set_byte_property (
                property_name   IN      VARCHAR,
                property_value  IN      int ),

  --
  -- set_short_property checks whether property_name is null or
  -- has existed. If not, it checks whether property_value
  -- is within -32768 to 32767 (16-bits) because both PL/SQL
  -- and Oracle RDBMS dont have the type short.
  --
  -- @param property_name (IN), property_value (IN)
  --
  -- @throws -24193 if the property value excceeds the valid range
  --
  MEMBER PROCEDURE set_short_property (
                property_name   IN      VARCHAR,
                property_value  IN      int ),

  --
  -- set_int_property checks whether property_name is null or
  -- has existed. If not, it checks whether property_value
  -- is within -2147483648 to 2147483647 (32-bits) because in
  -- both PL/SQL and Oracle RDBMS the type int (or INTEGER) is
  -- 38 bit.
  --
  -- @param property_name (IN), property_value (IN)
  --
  -- @throws -24193 if the property value excceeds the valid range
  --
  MEMBER PROCEDURE set_int_property (
                property_name   IN      VARCHAR,
                property_value  IN      int ),
--
  -- set_long_property checks whether property_name is null or
  -- has existed. If not, it stores the property_value.
  -- In Java the type long is 64-bit long. In
  -- both PL/SQL and Oracle RDBMS the type NUMBER is
  -- 38 bit. So there is no need to check the range.
  --
  -- @param property_name (IN), property_value (IN)
  --
  MEMBER PROCEDURE set_long_property (
                property_name   IN      VARCHAR,
                property_value  IN      NUMBER ),

  --
  -- set_float_property checks whether property_name is null or
  -- has existed. If not, it stores the property_value.
  --
  -- @param property_name (IN), property_value (IN)
  --
  MEMBER PROCEDURE set_float_property (
                property_name   IN      VARCHAR,
                property_value  IN      FLOAT ),

  --
  -- set_double_property checks whether property_name is null or
  -- has existed. If not, it stores the property_value.
  --
  -- @param property_name (IN), property_value (IN)
  --
  MEMBER PROCEDURE set_double_property (
                property_name   IN      VARCHAR,
                property_value  IN      DOUBLE PRECISION ),

  --
  -- set_string_property checks whether property_name is null or
  -- has existed. If not, it stores the property_value.
  --
  -- @param property_name (IN), property_value (IN)
  --
  MEMBER PROCEDURE set_string_property (
                property_name   IN      VARCHAR,
                property_value  IN      VARCHAR ),

  --
  -- get_replyto returns replyto which corresponds to JMSReplyTo.
  --
  -- @return sys.aq$_agent
  --
  MEMBER FUNCTION get_replyto RETURN sys.aq$_agent,
 --
  -- get_type returns type which corresponds to JMSType.
  --
  -- @return VARCHAR
  --
  MEMBER FUNCTION get_type RETURN VARCHAR,

  --
  -- get_userid returns userid which corresponds to JMSXUserID.
  --
  -- @return VARCHAR
  --
  MEMBER FUNCTION get_userid RETURN VARCHAR,

  --
  -- get_appid returns appid which corresponds to JMSXAppID.
  --
  -- @return VARCHAR
  --
  MEMBER FUNCTION get_appid RETURN VARCHAR,

  --
  -- get_groupid returns groupid which corresponds to JMSXGroupID.
  --
  -- @return VARCHAR
  --
  MEMBER FUNCTION get_groupid RETURN VARCHAR,

  --
  -- get_groupseq returns groupseq which corresponds to JMSXGroupSeq.
  --
  -- @return int
  --
  MEMBER FUNCTION get_groupseq RETURN int,

  --
  -- get_boolean_property returns a BOOLEAN value if it can find
  -- property_name and its java_type is BOOLEAN, and returns a NULL
  -- if it cannot find.
  --
  -- @param property_name (IN)
  --
  -- @return BOOLEAN
  --
  MEMBER FUNCTION get_boolean_property ( property_name   IN      VARCHAR)
  RETURN   BOOLEAN,
 --
  -- get_boolean_property_as_int returns 1 (for TRUE) and 0 (for FALSE) 
  -- value if it can find property_name and its java_type is BOOLEAN, 
  -- and returns a NULL otherwise.
  --
  -- @param property_name (IN)
  --
  -- @return int
  --
  MEMBER FUNCTION get_boolean_property_as_int ( property_name   IN   VARCHAR)
  RETURN   int,

  --
  -- get_byte_property returns a "byte" value if it can find
  -- property_name and its java_type is byte, and returns a NULL
  -- if it cannot find.
  --
  -- @param property_name (IN)
  --
  -- @return int
  --
  MEMBER FUNCTION get_byte_property ( property_name   IN      VARCHAR)
  RETURN   int,

  --
  -- get_short_property returns a "short" value if it can find
  -- property_name and its java_type is short, and returns a NULL
  -- if it cannot find.
  --
  -- @param property_name (IN)
  --
  -- @return int
  --
  MEMBER FUNCTION get_short_property ( property_name   IN      VARCHAR)
  RETURN   int,

  --
  -- get_int_property returns a int value if it can find
  -- property_name and its java_type is int, and returns a NULL
  -- if it cannot find.
  --
  -- @param property_name (IN)
  --
  -- @return int
  --
  MEMBER FUNCTION get_int_property ( property_name   IN      VARCHAR)
  RETURN   int,

  --
  -- get_long_property returns a int value if it can find
  -- property_name and its java_type is long, and returns a NULL
  -- if it cannot find.
 --
  -- @param property_name (IN)
  --
  -- @return NUMBER
  --
  MEMBER FUNCTION get_long_property ( property_name   IN      VARCHAR)
  RETURN   NUMBER,

  --
  -- get_float_property returns a FLOAT value if it can find
  -- property_name and its java_type is float, and returns a NULL
  -- if it cannot find.
  --
  -- @param property_name (IN)
  --
  -- @return FLOAT
  --
  MEMBER FUNCTION get_float_property ( property_name   IN      VARCHAR)
  RETURN   FLOAT,

  --
  -- get_double_property returns a DOUBLE PRECISION value if it can find
  -- property_name and its java_type is double, and returns a NULL
  -- if it cannot find.
  --
  -- @param property_name (IN)
  --
  -- @return DOUBLE PRECISION
  --
  MEMBER FUNCTION get_double_property ( property_name   IN      VARCHAR)
  RETURN   DOUBLE PRECISION,

  --
  -- get_string_property returns a varchar value if it can find
  -- property_name and its java_type is string, and returns a NULL
  -- if it cannot find.
  --
  -- @param property_name (IN)
  --
  -- @return VARCHAR
  --
  MEMBER FUNCTION get_string_property ( property_name   IN      VARCHAR)
  RETURN   VARCHAR

);
/
show errors;
create type aq$_jms_object_message
oid '00000000000000000000000000021028' 
as object
(
  header     aq$_jms_header,
  bytes_len  int,
  bytes_raw  raw(2000),
  bytes_lob  blob
);
/
show errors
create type aq$_jms_text_message 
oid '00000000000000000000000000021024' 
as object
(
  header    aq$_jms_header,
  text_len  int,
  text_vc   varchar2(4000),
  text_lob  clob,
  STATIC FUNCTION construct RETURN aq$_jms_text_message,

  --
  -- set_text sets payload in varchar2 into text_vc if the length of
  -- payload is <= 4000, into text_lob if otherwise.
  --
  -- @param payload (IN)
  --
  MEMBER PROCEDURE set_text ( payload IN VARCHAR2 ),

  --
  -- set_text sets payload in clob in text_lob.
  --
  -- @param payload (IN)
  --
  MEMBER PROCEDURE set_text ( payload IN CLOB ),

  --
  -- get_text puts text_vc into payload if text_vc is not null,
  -- or transfers text_lob in clob into payload in varchar2 if the
  -- length of text_lob is =< 32767 (2**16 -1).
  -- Maximum length of varchar2 in PL/SQL is 32767.
  --
  -- @param payload (OUT)
  --
  -- @throws -24190 if the length of text_lob is > 32767.
  --
  MEMBER PROCEDURE get_text ( payload OUT VARCHAR2 ),

  --
  -- get_text puts text_lob into payload if text_lob is not null,
  -- or transfers text_vc in varchar2 into payload in clob.
  --
  -- @param payload (OUT)
  --
  MEMBER PROCEDURE get_text ( payload OUT NOCOPY CLOB ),

  MEMBER PROCEDURE set_replyto (replyto IN      sys.aq$_agent),

  MEMBER PROCEDURE set_type (type       IN      VARCHAR ),

  MEMBER PROCEDURE set_userid (userid   IN      VARCHAR ),

  MEMBER PROCEDURE set_appid (appid     IN      VARCHAR ),

  MEMBER PROCEDURE set_groupid (groupid IN      VARCHAR ),

  MEMBER PROCEDURE set_groupseq (groupseq       IN      int ),

  MEMBER PROCEDURE clear_properties ,

  MEMBER PROCEDURE set_boolean_property (
               property_name   IN      VARCHAR,
                property_value  IN      BOOLEAN ),

  MEMBER PROCEDURE set_byte_property (
                property_name   IN      VARCHAR,
                property_value  IN      int ),

  MEMBER PROCEDURE set_short_property (
                property_name   IN      VARCHAR,
                property_value  IN      int ),

  MEMBER PROCEDURE set_int_property (
                property_name   IN      VARCHAR,
                property_value  IN      int ),

  MEMBER PROCEDURE set_long_property (
                property_name   IN      VARCHAR,
                property_value  IN      NUMBER ),

  MEMBER PROCEDURE set_float_property (
                property_name   IN      VARCHAR,
                property_value  IN      FLOAT ),

  MEMBER PROCEDURE set_double_property (
                property_name   IN      VARCHAR,
                property_value  IN      DOUBLE PRECISION ),

  MEMBER PROCEDURE set_string_property (
                property_name   IN      VARCHAR,
                property_value  IN      VARCHAR ),

  MEMBER FUNCTION get_replyto RETURN sys.aq$_agent,

  MEMBER FUNCTION get_type RETURN VARCHAR,

  MEMBER FUNCTION get_userid RETURN VARCHAR,

  MEMBER FUNCTION get_appid RETURN VARCHAR,

  MEMBER FUNCTION get_groupid RETURN VARCHAR,

  MEMBER FUNCTION get_groupseq RETURN int,

  MEMBER FUNCTION get_boolean_property ( property_name   IN      VARCHAR)
  RETURN   BOOLEAN,

  MEMBER FUNCTION get_byte_property ( property_name   IN      VARCHAR)
  RETURN   int,

  MEMBER FUNCTION get_short_property ( property_name   IN      VARCHAR)
  RETURN   int,
MEMBER FUNCTION get_int_property ( property_name   IN      VARCHAR)
  RETURN   int,

  MEMBER FUNCTION get_long_property ( property_name   IN      VARCHAR)
  RETURN   NUMBER,

  MEMBER FUNCTION get_float_property ( property_name   IN      VARCHAR)
  RETURN   FLOAT,

  MEMBER FUNCTION get_double_property ( property_name   IN      VARCHAR)
  RETURN   DOUBLE PRECISION,

  MEMBER FUNCTION get_string_property ( property_name   IN      VARCHAR)
  RETURN   VARCHAR

);
/
show errors
create type aq$_jms_bytes_message 
oid '00000000000000000000000000021025' 
as object
(
  header     aq$_jms_header,
  bytes_len  int,
  bytes_raw  raw(2000),
  bytes_lob  blob,
  STATIC FUNCTION construct RETURN aq$_jms_bytes_message,

  --
  -- set_bytes sets payload in RAW into bytes_raw if the length of 
  -- payload is <= 2000, otherwise into bytes_lob.
  --
  -- @param payload (IN)
  --
  MEMBER PROCEDURE set_bytes ( payload IN RAW ),

  --
  -- set_bytes sets payload in blob in bytes_lob.
  --
  -- @param payload (IN)
  --
  MEMBER PROCEDURE set_bytes ( payload IN BLOB ),

  --
  -- get_bytes puts bytes_raw into payload if it is not null,
  -- or transfers bytes_lob in blob into payload in RAW if the
  -- length of bytes_lob is =< 32767 (2**16 -1).
  -- Maximum length of raw in PL/SQL is 32767.
  --
  -- @param payload (OUT)
  --
  -- @throws -24190 if bytes_raw is null and
  -- the length of bytes_lob is > 32767.
  --
  MEMBER PROCEDURE get_bytes ( payload OUT RAW ),

  --
  -- get_bytes puts bytes_lob into payload if it is not null,
  -- or transfers bytes_raw in RAW into payload in blob.
  --
  -- @param payload (OUT)
  --
  MEMBER PROCEDURE get_bytes ( payload OUT NOCOPY BLOB ),
 -- *******************************************
  -- The following are common procedures of aq$_jms_stream_message, 
  -- aq$_jms_bytes_message and aq$_jms_map_message types to synchronize 
  -- the data between JAVA stored procedure and PL/SQL.
  -- *******************************************

  --============================================
  -- Get the JAVA exception thrown during the previous failure.
  -- Only one JAVA exception is recorded for a session. If the 
  -- exception is not fetched in time, it might be overwritten 
  -- by the exception thrown in next failure.

  STATIC FUNCTION get_exception
  RETURN AQ$_JMS_EXCEPTION,


  --============================================
  -- Clean all the messages in the JVM session memory.
  -- 

  STATIC PROCEDURE clean_all,


  --============================================
  -- Populate the data at JAVA stored procedure with the data at PL/SQL side.
  --
  -- Underlying, it takes the RAW/BLOB stored in PL/SQL aq$_jms_bytes_message
  -- to construct a JAVA object (for aq$_jms_bytes_message is DataInputStream) 
  -- which is stored in ORACLE JVM session memeory. 
  -- 
  -- Parameter "id" is called operation id that is used to identify the slot 
  -- where the JAVA object is stored in the ORACLE JVM session memeory. 
  -- If "id" is NULL, a new slot is created for this PL/SQL object. 
  -- Later JMS operations on the payload need to provide this operation id.
  --
  -- Parameters:
  --  id  - the operation id for this ADT instance. 
  --        if id is negative, the system will create a new operation id.
  --
  -- Returns:
  --  the operation id.
  --
  -- The prepare procedure for aq$_jms_bytes_message sets the message access mode
  -- to MESSAGE_ACCESS_READONLY. Later calls of write_XXX procedure raise ORA-24196 error.
  -- User can call clear_body procedure to set the message access mode to 
  -- MESSAGE_ACCESS_WRITEONLY.
  --
  -- Raise ORA-24197: JAVA stored procedure throws Exception during execution.
  -- Raise ORA-24198: Invalid operation id.
  -- Raise ORA-24199: JAVA store procedure message store overflow.

  MEMBER FUNCTION prepare (id IN PLS_INTEGER)
 RETURN PLS_INTEGER,


  --============================================
  -- Set the data at JAVA stored procedure as empty payload.
  --
  -- Underlying, it initializes a new DataOutputStream object and set it to 
  -- the static varaible in ORACLE JVM session memeory.
  --
  -- Parameter "id" is called operation id that is used to identify the slot 
  -- where the JAVA object is stored in the ORACLE JVM session memeory. 
  -- If "id" is NULL, a new slot is created for this PL/SQL object. 
  -- Later JMS operations on the payload need to provide this operation id.
  --
  -- Parameters:
  --  id  - the operation id for this ADT instance. 
  --        if id is negative, the system will create a new operation id.
  --
  -- Returns:
  --  the operation id.
  --
  -- The clear_body procedure for aq$_jms_bytes_message sets the message access mode
  -- to MESSAGE_ACCESS_WRITEONLY. Later calls of read_XXX procedure raise ORA-24196 error. 
  -- User can call reset procedure or prepare procedure to set the message access mode
  -- to MESSAGE_ACCESS_READONLY. Note the difference between prepare procedure and
  -- reset procedure.
  --
  -- Raise ORA-24197: JAVA stored procedure throws Exception during execution.
  -- Raise ORA-24198: Invalid operation id.
  -- Raise ORA-24199: JAVA store procedure message store overflow.

  MEMBER FUNCTION clear_body (id IN PLS_INTEGER)
  RETURN PLS_INTEGER,


  --============================================
  -- Get the current message access mode of this message
  -- The result will be either dbms_aqjms.MESSAGE_ACCESS_WRITEONLY or 
  -- dbms_aqjms.MESSAGE_ACCESS_READONLY.
  --
  -- Parameters:
  --  id  - the operation id for this ADT instance. 
  --
  -- Raise ORA-24197: JAVA stored procedure throws Exception during execution.
  -- Raise ORA-24198: Invalid operation id.

  MEMBER FUNCTION get_mode (id IN PLS_INTEGER)
  RETURN PLS_INTEGER,
--============================================
  -- Reset reposition the bytes to the begining for reading.
  --
  -- Parameters:
  --  id  - the operation id for this ADT instance. 
  --
  -- The reset procedure for aq$_jms_bytes_message sets the message access mode
  -- to MESSAGE_ACCESS_READONLY. Later calls of write_XXX procedure raise ORA-24196 error.
  -- User can call clear_body procedure to set the message access mode to 
  -- MESSAGE_ACCESS_WRITEONLY.
  --
  -- Raise ORA-24197: JAVA stored procedure throws Exception during execution.
  -- Raise ORA-24198: Invalid operation id.

  MEMBER PROCEDURE reset (id IN PLS_INTEGER),


  --============================================
  -- Flush the data at JAVA stored procedure side to PL/SQL side.
  --
  -- Underlying, it update the data at PL/SQL side to the payload stored at 
  -- the JAVA stored procedure side. 
  --
  -- The flush procedure for aq$_jms_bytes_message does not affect current message access 
  -- mode. User can continue to call procedures appropriate to the current mode.
  --
  -- Parameters:
  --  id  - the operation id for this ADT instance. 
  --
  -- Raise ORA-24197: JAVA stored procedure throws Exception during execution.
  -- Raise ORA-24198: Invalid operation id.

  MEMBER PROCEDURE flush (id IN PLS_INTEGER),


  --============================================
  -- clean the data at JAVA stored procedure side to PL/SQL side.
  --
  -- Underlying, it close and clean upthe DataInputStream or DataOutputStream 
  -- at the JAVA stored procedure side corresponding to the operation id. 
  -- It is very import to call this procedure to avoid memeory leak!
  --
  -- Parameters:
  --  id  - the operation id for this ADT instance. 
  --
  -- Raise ORA-24197: JAVA stored procedure throws Exception during execution.
  -- Raise ORA-24198: Invalid operation id.

  MEMBER PROCEDURE clean (id IN PLS_INTEGER),
--*******************************************
  -- JMS operations member functions and procedures
  --*******************************************

  --============================================
  -- Read a boolean value from the bytes message.
  --
  -- The function returns NULL if the end of the message stream has been reached.
  --
  -- Parameters:
  --  id  - the operation id for this ADT instance. 
  -- 
  -- Raise ORA-24196: The bytes message is in write-only mode.
  -- Raise ORA-24197: JAVA stored procedure throws Exception during execution.
  -- Raise ORA-24198: Invalid operation id.

  MEMBER FUNCTION read_boolean (id IN PLS_INTEGER)
  RETURN BOOLEAN,


  --============================================
  -- Read a byte from the bytes message. 
  --
  -- The function guarantees that the returned value is in the JAVA byte value range. 
  -- This also means if this value is issued with a write_byte function, 
  -- there wont be an out of range error raised.
  -- 
  -- The function returns NULL if the end of the message stream has been reached. 
  --
  -- Parameters:
  --  id  - the operation id for this ADT instance. 
  --
  -- Raise ORA-24196: The bytes message is in write-only mode.
  -- Raise ORA-24197: JAVA stored procedure throws Exception during execution.
  -- Raise ORA-24198: Invalid operation id.

  MEMBER FUNCTION read_byte (id IN PLS_INTEGER)
  RETURN PLS_INTEGER,


  --============================================
  -- Read a byte array from the bytes message. 
  --
  -- The function read length of the bytes from bytes message stream into value.
  -- It returns the total number of bytes read or -1 when there is no more data
  -- to be read from the bytes stream.
  --
  -- Parameters:
  --  id     - the operation id for this ADT instance.
  --  value  - the bytes read.
  --  length - the length of bytes to read.
-- Raise ORA-24196: The bytes message is in write-only mode.
  -- Raise ORA-24197: JAVA stored procedure throws Exception during execution.
  -- Raise ORA-24198: Invalid operation id.

  MEMBER FUNCTION read_bytes (id IN PLS_INTEGER, value OUT NOCOPY BLOB, length IN PLS_INTEGER)
  RETURN PLS_INTEGER,


  --============================================
  -- Read a char from the bytes message. 
  --
  -- The function returns NULL if the end of the message stream has been reached. 
  --
  -- Parameters:
  --  id  - the operation id for this ADT instance. 
  --
  -- Raise ORA-24196: The bytes message is in write-only mode.
  -- Raise ORA-24197: JAVA stored procedure throws Exception during execution.
  -- Raise ORA-24198: Invalid operation id.

  MEMBER FUNCTION read_char (id IN PLS_INTEGER)
  RETURN CHAR,


  --============================================
  -- Read a double from the bytes message. 
  --
  -- The function returns NULL if the end of the message stream has been reached. 
  --
  -- Parameters:
  --  id  - the operation id for this ADT instance. 
  --
  -- Raise ORA-24196: The bytes message is in write-only mode.
  -- Raise ORA-24197: JAVA stored procedure throws Exception during execution.
  -- Raise ORA-24198: Invalid operation id.

  MEMBER FUNCTION read_double (id IN PLS_INTEGER)
  RETURN DOUBLE PRECISION,

  --============================================
  -- Read a float from the bytes message. 
  --
  -- The function returns NULL if the end of the message stream has been reached. 
  --
  -- Parameters:
  --  id  - the operation id for this ADT instance. 
  --
  -- Raise ORA-24196: The bytes message is in write-only mode.
  -- Raise ORA-24197: JAVA stored procedure throws Exception during execution.
  -- Raise ORA-24198: Invalid operation id.

  MEMBER FUNCTION read_float (id IN PLS_INTEGER)
RETURN FLOAT,


  --============================================
  -- Read a int from the bytes message. 
  --
  -- The function guarantees that the returned value is in the JAVA int value range. 
  -- This also means if this value is issued with a write_int function, 
  -- there wont be an out of range error raised.
  --
  -- The function returns NULL if the end of the message stream has been reached. 
  --
  -- Parameters:
  --  id  - the operation id for this ADT instance. 
  --
  -- Raise ORA-24196: The bytes message is in write-only mode.
  -- Raise ORA-24197: JAVA stored procedure throws Exception during execution.
  -- Raise ORA-24198: Invalid operation id.

  MEMBER FUNCTION read_int (id IN PLS_INTEGER)
  RETURN PLS_INTEGER,


  --============================================
  -- Read a long from the bytes message. 
  --
  -- The function guarantees that the returned value is in the JAVA long value range. 
  -- This also means if this value is issued with a write_long function, 
  -- there wont be an out of range error raised.
  --
  -- The function returns NULL if the end of the message stream has been reached. 
  --
  -- Parameters:
  --  id  - the operation id for this ADT instance. 
  --
  -- Raise ORA-24196: The bytes message is in write-only mode.
  -- Raise ORA-24197: JAVA stored procedure throws Exception during execution.
  -- Raise ORA-24198: Invalid operation id.

  MEMBER FUNCTION read_long (id IN PLS_INTEGER)
  RETURN NUMBER,


  --============================================
  -- Read a short from the bytes message. 
  --
  -- The function guarantees that the returned value is in the JAVA short value range. 
  -- This also means if this value is issued with a write_short function, 
  -- there wont be an out of range error raised.
  --
  -- The function returns NULL if the end of the message stream has been reached. 
  --
  -- Parameters:
--  id  - the operation id for this ADT instance. 
  --
  -- Raise ORA-24196: The bytes message is in write-only mode.
  -- Raise ORA-24197: JAVA stored procedure throws Exception during execution.
  -- Raise ORA-24198: Invalid operation id.

  MEMBER FUNCTION read_short (id IN PLS_INTEGER)
  RETURN PLS_INTEGER,


  --============================================
  -- Read a unsigned byte from the bytes message. 
  --
  -- The function returns NULL if the end of the message stream has been reached. 
  --
  -- Parameters:
  --  id  - the operation id for this ADT instance. 
  --
  -- Raise ORA-24196: The bytes message is in write-only mode.
  -- Raise ORA-24197: JAVA stored procedure throws Exception during execution.
  -- Raise ORA-24198: Invalid operation id.

  MEMBER FUNCTION read_unsigned_byte (id IN PLS_INTEGER)
  RETURN PLS_INTEGER,


  --============================================
  -- Read a unsigned short from the bytes message. 
  --
  -- The function returns NULL if the end of the message stream has been reached. 
  --
  -- Parameters:
  --  id  - the operation id for this ADT instance. 
  --
  -- Raise ORA-24196: The bytes message is in write-only mode.
  -- Raise ORA-24197: JAVA stored procedure throws Exception during execution.
  -- Raise ORA-24198: Invalid operation id.

  MEMBER FUNCTION read_unsigned_short (id IN PLS_INTEGER)
  RETURN PLS_INTEGER,


  --============================================
  -- Read a String from the bytes message. 
  --
 -- The function reads a string that has been encoded using UTF-8 fromat within the bytes messaeg. 
  -- It returns NULL if the end of the message stream has been reached. 
  --
  -- Parameters:
  --  id    - the operation id for this ADT instance. 
  --  value - the UTF string that is read.
  --
  -- Raise ORA-24196: The bytes message is in write-only mode.
  -- Raise ORA-24197: JAVA stored procedure throws Exception during execution.
  -- Raise ORA-24198: Invalid operation id.

  MEMBER PROCEDURE read_utf (id IN PLS_INTEGER, value OUT NOCOPY CLOB),


  --============================================
  -- Write a boolean to the bytes message.
  --
  -- Parameters:
  --  id     - the operation id for this ADT instance. 
  --  value  - the boolean value to be written. The value is copied into the bytes message.
  --
  -- Raise ORA-24196: The bytes message is in read-only mode.
  -- Raise ORA-24197: JAVA stored procedure throws Exception during execution.
  -- Raise ORA-24198: Invalid operation id.

  MEMBER PROCEDURE write_boolean (id IN PLS_INTEGER, value IN BOOLEAN),


  --============================================
  -- Write a byte to the bytes message.
  --
  -- Parameters:
  --  id     - the operation id for this ADT instance. 
  --  value  - the byte value to be written. The value is copied into the bytes message.
  --
  -- Raise ORA-24196: The bytes message is in read-only mode.
  -- Raise ORA-24198: Invalid operation id.

  MEMBER PROCEDURE write_byte (id IN PLS_INTEGER, value IN PLS_INTEGER),


  --============================================
  -- Write a byte array to the bytes message.
  --
  -- This procedure takes a RAW type.
  --
  -- Parameters:
  --  id     - the operation id for this ADT instance. 
  --  value  - the byte array value to be written. The value is copied into the bytes message.
  -- 
  -- Raise ORA-24196: The bytes message is in read-only mode.
 -- Raise ORA-24197: JAVA stored procedure throws Exception during execution.
  -- Raise ORA-24198: Invalid operation id.

  MEMBER PROCEDURE write_bytes (id IN PLS_INTEGER, value IN RAW),


  --============================================
  -- Write a byte array to the bytes message.
  --
  -- This procedure takes a BLOB type.
  --
  -- Parameters:
  --  id     - the operation id for this ADT instance. 
  --  value  - the byte array value to be written. The value is copied into the bytes message.
  -- 
  -- Raise ORA-24196: The bytes message is in read-only mode.
  -- Raise ORA-24197: JAVA stored procedure throws Exception during execution.
  -- Raise ORA-24198: Invalid operation id.

  MEMBER PROCEDURE write_bytes (id IN PLS_INTEGER, value IN BLOB),


  --============================================
  -- Write a portion of byte array to the bytes message.
  --
  -- This procedure takes a RAW type.
  -- If the range [offset, offset+length] exceeds the boundary of the byte array value, 
  -- a JAVA IndexOutOfBoundsException is thrown at the JAVA stored procedure and ORA-24197
  -- ora error is raised at the PL/SQL side. The index starts from 0.
  --
  -- Parameters:
  --  id     - the operation id for this ADT instance. 
  --  value  - the byte array value to be written. The value is copied into the bytes message.
  --  offset - the initial offset within the byte array.
  --  length - the number of bytes to use
  --
  -- Raise ORA-24196: The bytes message is in read-only mode.
  -- Raise ORA-24197: JAVA stored procedure throws Exception during execution.
  -- Raise ORA-24198: Invalid operation id.

  MEMBER PROCEDURE write_bytes (
         id        IN      PLS_INTEGER,
         value     IN      RAW,
         offset    IN      PLS_INTEGER,
         length    IN      PLS_INTEGER
  ),


  --============================================
  -- Write a portion of byte array to the bytes message.
  --
-- This procedure takes a BLOB type.
  -- If the range [offset, offset+length] exceeds the boundary of the byte array value, 
  -- a JAVA IndexOutOfBoundsException is thrown at the JAVA stored procedure and ORA-24197
  -- ora error is raised at the PL/SQL side. The index starts from 0.
  --
  -- Parameters:
  --  id     - the operation id for this ADT instance. 
  --  value  - the byte array value to be written. The value is copied into the bytes message.
  --  offset - the initial offset within the byte array.
  --  length - the number of bytes to use
  --
  -- Raise ORA-24196: The bytes message is in read-only mode.
  -- Raise ORA-24197: JAVA stored procedure throws Exception during execution.
  -- Raise ORA-24198: Invalid operation id.

  MEMBER PROCEDURE write_bytes (
         id        IN      PLS_INTEGER,
         value     IN      BLOB,
         offset    IN      PLS_INTEGER,
         length    IN      PLS_INTEGER
  ),

  --============================================
  -- Write a char to the bytes message.
  --
  -- Parameters:
  --  id     - the operation id for this ADT instance. 
  --  value  - the char value to be written. The value is copied into the bytes message.
  --
  -- Raise ORA-24196: The bytes message is in read-only mode.
  -- Raise ORA-24197: JAVA stored procedure throws Exception during execution.
  -- Raise ORA-24198: Invalid operation id.

  MEMBER PROCEDURE write_char (id IN PLS_INTEGER, value IN CHAR),


  --============================================
  -- Write a double to the bytes message.
  --
  -- Parameters:
  --  id     - the operation id for this ADT instance. 
  --  value  - the double value to be written. The value is copied into the bytes message.
  --
  -- Raise ORA-24196: The bytes message is in read-only mode.
  -- Raise ORA-24197: JAVA stored procedure throws Exception during execution.
  -- Raise ORA-24198: Invalid operation id.

  MEMBER PROCEDURE write_double (id IN PLS_INTEGER, value IN DOUBLE PRECISION),


  --============================================
  -- Write a float to the bytes message.
  --
 -- Parameters:
  --  id     - the operation id for this ADT instance. 
  --  value  - the float value to be written. The value is copied into the bytes message.
  --
  -- Raise ORA-24196: The bytes message is in read-only mode.
  -- Raise ORA-24197: JAVA stored procedure throws Exception during execution.
  -- Raise ORA-24198: Invalid operation id.

  MEMBER PROCEDURE write_float (id IN PLS_INTEGER, value IN FLOAT),


  --============================================
  -- Write a int to the bytes message.
  --
  -- Parameters:
  --  id     - the operation id for this ADT instance. 
  --  value  - the int value to be written. The value is copied into the bytes message.
  --
  -- Raise ORA-24196: The bytes message is in read-only mode.
  -- Raise ORA-24197: JAVA stored procedure throws Exception during execution.
  -- Raise ORA-24198: Invalid operation id.

  MEMBER PROCEDURE write_int (id IN PLS_INTEGER, value IN PLS_INTEGER),


  --============================================
  -- Write a long to the bytes message.
  --
  -- Parameters:
  --  id     - the operation id for this ADT instance. 
  --  value  - the long value to be written. The value is copied into the bytes message.
  --
  -- Raise ORA-24196: The bytes message is in read-only mode.
  -- Raise ORA-24197: JAVA stored procedure throws Exception during execution.
  -- Raise ORA-24198: Invalid operation id.

  MEMBER PROCEDURE write_long (id IN PLS_INTEGER, value IN NUMBER),


  --============================================
  -- Write a short to the bytes message.
  --
  -- Parameters:
  --  id     - the operation id for this ADT instance. 
  --  value  - the short value to be written. The value is copied into the bytes message.
  --
  -- Raise ORA-24196: The bytes message is in read-only mode.
  -- Raise ORA-24197: JAVA stored procedure throws Exception during execution.
  -- Raise ORA-24198: Invalid operation id.
MEMBER PROCEDURE write_short (id IN PLS_INTEGER, value IN PLS_INTEGER),


  --============================================
  -- Write a String to the bytes message.
  --
  -- This procedure writes a VARCHAR2 to the bytes message using UTF-8 encoding.
  --
  -- Parameters:
  --  id     - the operation id for this ADT instance. 
  --  value  - the string value to be written. The value is copied into the bytes message.
  --
  -- Raise ORA-24196: The bytes message is in read-only mode.
  -- Raise ORA-24197: JAVA stored procedure throws Exception during execution.
  -- Raise ORA-24198: Invalid operation id.

  MEMBER PROCEDURE write_utf (id IN PLS_INTEGER, value IN VARCHAR2),


  --============================================
  -- Write a String to the bytes message.
  --
  -- This procedure writes a CLOB to the bytes message using UTF-8 encoding.
  --
  -- Parameters:
  --  id     - the operation id for this ADT instance. 
  --  value  - the string value to be written. The value is copied into the bytes message.
  --
  -- Raise ORA-24196: The bytes message is in read-only mode.
  -- Raise ORA-24197: JAVA stored procedure throws Exception during execution.
  -- Raise ORA-24198: Invalid operation id.

  MEMBER PROCEDURE write_utf (id IN PLS_INTEGER, value IN CLOB),


  --*******************************************
  -- The following are JMS header related procedures
  --*******************************************

  MEMBER PROCEDURE set_replyto (replyto IN      sys.aq$_agent),

  MEMBER PROCEDURE set_type (type       IN      VARCHAR ),

  MEMBER PROCEDURE set_userid (userid   IN      VARCHAR ),

  MEMBER PROCEDURE set_appid (appid     IN      VARCHAR ),

  MEMBER PROCEDURE set_groupid (groupid IN      VARCHAR ),

  MEMBER PROCEDURE set_groupseq (groupseq       IN      int ),
MEMBER PROCEDURE clear_properties ,

  MEMBER PROCEDURE set_boolean_property (
                property_name   IN      VARCHAR,
                property_value  IN      BOOLEAN ),

  MEMBER PROCEDURE set_byte_property (
                property_name   IN      VARCHAR,
                property_value  IN      int ),

  MEMBER PROCEDURE set_short_property (
                property_name   IN      VARCHAR,
                property_value  IN      int ),

  MEMBER PROCEDURE set_int_property (
                property_name   IN      VARCHAR,
                property_value  IN      int ),

  MEMBER PROCEDURE set_long_property (
                property_name   IN      VARCHAR,
                property_value  IN      NUMBER ),

  MEMBER PROCEDURE set_float_property (
                property_name   IN      VARCHAR,
                property_value  IN      FLOAT ),

  MEMBER PROCEDURE set_double_property (
                property_name   IN      VARCHAR,
                property_value  IN      DOUBLE PRECISION ),

  MEMBER PROCEDURE set_string_property (
                property_name   IN      VARCHAR,
                property_value  IN      VARCHAR ),

  MEMBER FUNCTION get_replyto RETURN sys.aq$_agent,

  MEMBER FUNCTION get_type RETURN VARCHAR,

  MEMBER FUNCTION get_userid RETURN VARCHAR,

  MEMBER FUNCTION get_appid RETURN VARCHAR,

  MEMBER FUNCTION get_groupid RETURN VARCHAR,

  MEMBER FUNCTION get_groupseq RETURN int,

  MEMBER FUNCTION get_boolean_property ( property_name   IN      VARCHAR)
  RETURN   BOOLEAN,

  MEMBER FUNCTION get_byte_property ( property_name   IN      VARCHAR)
  RETURN   int,
  MEMBER FUNCTION get_short_property ( property_name   IN      VARCHAR)
  RETURN   int,

  MEMBER FUNCTION get_int_property ( property_name   IN      VARCHAR)
  RETURN   int,

  MEMBER FUNCTION get_long_property ( property_name   IN      VARCHAR)
  RETURN   NUMBER,

  MEMBER FUNCTION get_float_property ( property_name   IN      VARCHAR)
  RETURN   FLOAT,

  MEMBER FUNCTION get_double_property ( property_name   IN      VARCHAR)
  RETURN   DOUBLE PRECISION,

  MEMBER FUNCTION get_string_property ( property_name   IN      VARCHAR)
  RETURN   VARCHAR

);
/
show errors
create type aq$_jms_stream_message 
oid '00000000000000000000000000021026' authid current_user 
as object
(
  header     aq$_jms_header,
  bytes_len  int,
  bytes_raw  raw(2000),
  bytes_lob  blob,
  --============================================
  STATIC FUNCTION construct RETURN aq$_jms_stream_message,


  -- *******************************************
  -- The following are common procedures of aq$_jms_stream_message, 
  -- aq$_jms_bytes_message and aq$_jms_map_message types to synchronize 
  -- the data between JAVA stored procedure and PL/SQL.
  -- *******************************************

  --============================================
  -- Get the JAVA exception thrown during the previous failure.
  -- Only one JAVA exception is recorded for a session. If the 
  -- exception is not fetched in time, it might be overwritten 
  -- by the exception thrown in next failure.

  STATIC FUNCTION get_exception
  RETURN AQ$_JMS_EXCEPTION,


  --============================================
  -- Clean all the messages in the JVM session memory.
  -- 

  STATIC PROCEDURE clean_all,


  --============================================
  -- Populate the data at JAVA stored procedure with the data at PL/SQL side.
  --
  -- Underlying, it takes the RAW/BLOB stored in PL/SQL aq$_jms_stream_message
  -- to construct a JAVA object (for aq$_jms_stream_message is ObjectInputStream) 
  -- which is stored in ORACLE JVM session memeory. 
  -- 
  -- Parameter "id" is called operation id that is used to identify the slot 
  -- where the JAVA object is stored in the ORACLE JVM session memeory. 
  -- If "id" is NULL, a new slot is created for this PL/SQL object. 
  -- Later JMS operations on the payload need to provide this operation id.
  --
  -- Parameters:
  --  id  - the operation id for this ADT instance. 
  --        if id is negative, the system will create a new operation id.
  --
  -- Returns:
  --  the operation id.
  --
  -- The prepare procedure for aq$_jms_stream_message sets the message access mode
  -- to MESSAGE_ACCESS_READONLY. Later calls of write_XXX procedure raise ORA-24196 error.
  -- User can call clear_body procedure to set the message access mode to 
  -- MESSAGE_ACCESS_WRITEONLY.
  --
  -- Raise ORA-24197: JAVA stored procedure throws Exception during execution.
  -- Raise ORA-24198: Invalid operation id.
-- Raise ORA-24199: JAVA store procedure message store overflow.

  MEMBER FUNCTION prepare (id IN PLS_INTEGER)
  RETURN PLS_INTEGER,


  --============================================
  -- Set the data at JAVA stored procedure as empty payload.
  --
  -- Underlying, it initialize an new ObjectOutputStream object and set it to 
  -- the static varaible in ORACLE JVM session memeory.
  --
  -- Parameter "id" is called operation id that is used to identify the slot 
  -- where the JAVA object is stored in the ORACLE JVM session memeory. 
  -- If "id" is NULL, a new slot is created for this PL/SQL object. 
  -- Later JMS operations on the payload need to provide this operation id.
  --
  -- Parameters:
  --  id  - the operation id for this ADT instance. 
  --        if id is negative, the system will create a new operation id.
  --
  -- Returns:
  --  the operation id.
  --
  -- The clear_body procedure for aq$_jms_stream_message sets the message access mode
  -- to MESSAGE_ACCESS_WRITEONLY. Later calls of read_XXX procedure raise ORA-24196 error. 
  -- User can call reset procedure or prepare procedure to set the message access mode
  -- to MESSAGE_ACCESS_READONLY. Note the difference between prepare procedure and
  -- reset procedure.
  --
  -- Raise ORA-24197: JAVA stored procedure throws Exception during execution.
  -- Raise ORA-24198: Invalid operation id.
  -- Raise ORA-24199: JAVA store procedure message store overflow.

  MEMBER FUNCTION clear_body (id IN PLS_INTEGER)
  RETURN PLS_INTEGER,


  --============================================
  -- Get the current message access mode of this message
  -- The result will be either dbms_aqjms.MESSAGE_ACCESS_WRITEONLY or 
  -- dbms_aqjms.MESSAGE_ACCESS_READONLY.
  --
  -- Parameters:
  --  id  - the operation id for this ADT instance. 
  --
  -- Raise ORA-24197: JAVA stored procedure throws Exception during execution.
  -- Raise ORA-24198: Invalid operation id.

  MEMBER FUNCTION get_mode (id IN PLS_INTEGER)
  RETURN PLS_INTEGER,

  --============================================
  -- Reset reposition the stream to the begining for reading.
  --
  -- Parameters:
  --  id  - the operation id for this ADT instance. 
  --
  -- The reset procedure for aq$_jms_stream_message sets the message access mode
  -- to MESSAGE_ACCESS_READONLY. Later calls of write_XXX procedure raise ORA-24196 error.
  -- User can call clear_body procedure to set the message access mode to 
  -- MESSAGE_ACCESS_WRITEONLY.
  --
  -- Raise ORA-24197: JAVA stored procedure throws Exception during execution.
  -- Raise ORA-24198: Invalid operation id.

  MEMBER PROCEDURE reset (id IN PLS_INTEGER),


  --============================================
  -- Flush the data at JAVA stored procedure side to PL/SQL side.
  --
  -- Underlying, it update the data at PL/SQL side to the payload stored at 
  -- the JAVA stored procedure side. 
  --
  -- The flush procedure for aq$_jms_stream_message does not affect current message access 
  -- mode. User can continue to call procedures appropriate to the current mode.
  --
  -- Parameters:
  --  id  - the operation id for this ADT instance. 
  --
  -- Raise ORA-24197: JAVA stored procedure throws Exception during execution.
  -- Raise ORA-24198: Invalid operation id.

  MEMBER PROCEDURE flush (id IN PLS_INTEGER),


  --============================================
  -- clean the data at JAVA stored procedure side to PL/SQL side.
  --
  -- Underlying, it close and clean upthe ObjectInputStream or ObjectOutputStream 
  -- at the JAVA stored procedure side corresponding to the operation id. 
  -- It is very import to call this procedure to avoid memeory leak!
  --
  -- Parameters:
  --  id  - the operation id for this ADT instance. 
  --
  -- Raise ORA-24198: Invalid operation id.

  MEMBER PROCEDURE clean (id IN PLS_INTEGER),


  --*******************************************
 -- JMS operations member functions and procedures
  --*******************************************

  --============================================
  -- Read a object value from the stream message.
  --
  -- The function returns a general value ADT AQ$_JMS_VALUE. User can use the
  -- "type" attribute of this ADT to interpret the data. 
  -- The following is a map among type attribute, JAVA type and value attributes
  --
  -- -----------------------------------------------------------------
  --               type                 | JAVA type | value attributes
  -- -----------------------------------------------------------------                
  -- DBMS_JMS_PLSQL.DATA_TYPE_BYTE      |  byte     |    num_val 
  -- -----------------------------------------------------------------
  -- DBMS_JMS_PLSQL.DATA_TYPE_SHORT     |  short    |    num_val
  -- -----------------------------------------------------------------
  -- DBMS_JMS_PLSQL.DATA_TYPE_INTEGER   |  int      |    num_val
  -- -----------------------------------------------------------------
  -- DBMS_JMS_PLSQL.DATA_TYPE_LONG      |  long     |    num_val
  -- -----------------------------------------------------------------
  -- DBMS_JMS_PLSQL.DATA_TYPE_FLOAT     |  float    |    num_val
  -- -----------------------------------------------------------------
  -- DBMS_JMS_PLSQL.DATA_TYPE_DOUBLE    |  double   |    num_val
  -- -----------------------------------------------------------------
  -- DBMS_JMS_PLSQL.DATA_TYPE_BOOLEAN   |  boolean  |    num_val
  -- -----------------------------------------------------------------
  -- DBMS_JMS_PLSQL.DATA_TYPE_CHARACTER |  char     |    char_val
  -- -----------------------------------------------------------------
  -- DBMS_JMS_PLSQL.DATA_TYPE_STRING    |  String   |    text_val
  -- -----------------------------------------------------------------
  -- DBMS_JMS_PLSQL.DATA_TYPE_BYTES     |  byte[]   |    bytes_val
  -- -----------------------------------------------------------------
  --
  -- The function returns NULL if the end of the message stream has been reached.
  -- 
  -- Also note that this memeber procedure might bring additional overhead 
  -- comparing to other "read" memeber procedures. It is used only if the user 
  -- does not know the data type before hand, otherwise it is always a good idea
  -- to use a specific read member procedure.
  --
  -- Parameters:
  --  id    - the operation id for this ADT instance. 
  --  value - the object that is read.
  --
  -- Raise ORA-24194: The type conversion between the type of real value and the expected type is invalid.
  --                  In this particular case, an object with unsupported type is read from the stream.
  -- Raise ORA-24196: The stream message is in write-only mode.
  -- Raise ORA-24197: JAVA stored procedure throws Exception during execution.
-- Raise ORA-24198: Invalid operation id.

  MEMBER PROCEDURE read_object (id IN PLS_INTEGER, value OUT NOCOPY AQ$_JMS_VALUE),


  --============================================
  -- Read a boolean value from the stream message.
  --
  -- The function returns NULL if the end of the message stream has been reached.
  --
  -- Parameters:
  --  id  - the operation id for this ADT instance. 
  -- 
  -- Raise ORA-24194: The type conversion between the type of real value and the expected type is invalid.
  -- Raise ORA-24196: The stream message is in write-only mode.
  -- Raise ORA-24197: JAVA stored procedure throws Exception during execution.
  -- Raise ORA-24198: Invalid operation id.

  MEMBER FUNCTION read_boolean (id IN PLS_INTEGER)
  RETURN BOOLEAN,


  --============================================
  -- Read a byte from the stream message. 
  --
  -- The function guarantees that the returned value is in the JAVA byte value range. 
  -- This also means if this value is issued with a write_byte function, 
  -- there wont be an out of range error raised.
  -- 
  -- The function returns NULL if the end of the message stream has been reached. 
  --
  -- Parameters:
  --  id  - the operation id for this ADT instance. 
  --
  -- Raise ORA-24194: The type conversion between the type of real value and the expected type is invalid.
  -- Raise ORA-24196: The stream message is in write-only mode.
  -- Raise ORA-24197: JAVA stored procedure throws Exception during execution.
  -- Raise ORA-24198: Invalid operation id.

  MEMBER FUNCTION read_byte (id IN PLS_INTEGER)
  RETURN PLS_INTEGER,


  --============================================
  -- Read a byte array from the stream message. 
  --
  -- The function returns NULL if the end of the message stream has been reached. 
  --
  -- Parameters:
 --  id    - the operation id for this ADT instance. 
  --  value - the bytes that is read.
  --
  -- Raise ORA-24194: The type conversion between the type of real value and the expected type is invalid.
  -- Raise ORA-24196: The stream message is in write-only mode.
  -- Raise ORA-24197: JAVA stored procedure throws Exception during execution.
  -- Raise ORA-24198: Invalid operation id.

  MEMBER PROCEDURE read_bytes (id IN PLS_INTEGER, value OUT NOCOPY BLOB),


  --============================================
  -- Read a char from the stream message. 
  --
  -- The function returns NULL if the end of the message stream has been reached. 
  --
  -- Parameters:
  --  id  - the operation id for this ADT instance. 
  --
  -- Raise ORA-24194: The type conversion between the type of real value and the expected type is invalid.
  -- Raise ORA-24196: The stream message is in write-only mode.
  -- Raise ORA-24197: JAVA stored procedure throws Exception during execution.
  -- Raise ORA-24198: Invalid operation id.

  MEMBER FUNCTION read_char (id IN PLS_INTEGER)
  RETURN CHAR,


  --============================================
  -- Read a double from the stream message. 
  --
  -- The function returns NULL if the end of the message stream has been reached. 
  --
  -- Parameters:
  --  id  - the operation id for this ADT instance. 
  --
  -- Raise ORA-24194: The type conversion between the type of real value and the expected type is invalid.
  -- Raise ORA-24196: The stream message is in write-only mode.
  -- Raise ORA-24197: JAVA stored procedure throws Exception during execution.
  -- Raise ORA-24198: Invalid operation id.

  MEMBER FUNCTION read_double (id IN PLS_INTEGER)
  RETURN DOUBLE PRECISION,

  --============================================
  -- Read a float from the stream message. 
  --
  -- The function returns NULL if the end of the message stream has been reached. 
--
  -- Parameters:
  --  id  - the operation id for this ADT instance. 
  --
  -- Raise ORA-24194: The type conversion between the type of real value and the expected type is invalid.
  -- Raise ORA-24196: The stream message is in write-only mode.
  -- Raise ORA-24197: JAVA stored procedure throws Exception during execution.
  -- Raise ORA-24198: Invalid operation id.

  MEMBER FUNCTION read_float (id IN PLS_INTEGER)
  RETURN FLOAT,


  --============================================
  -- Read a int from the stream message. 
  --
  -- The function guarantees that the returned value is in the JAVA int value range. 
  -- This also means if this value is issued with a write_int function, 
  -- there wont be an out of range error raised.
  --
  -- The function returns NULL if the end of the message stream has been reached. 
  --
  -- Parameters:
  --  id  - the operation id for this ADT instance. 
  --
  -- Raise ORA-24194: The type conversion between the type of real value and the expected type is invalid.
  -- Raise ORA-24196: The stream message is in write-only mode.
  -- Raise ORA-24197: JAVA stored procedure throws Exception during execution.
  -- Raise ORA-24198: Invalid operation id.

  MEMBER FUNCTION read_int (id IN PLS_INTEGER)
  RETURN PLS_INTEGER,


  --============================================
  -- Read a long from the stream message. 
  --
  -- The function guarantees that the returned value is in the JAVA long value range. 
  -- This also means if this value is issued with a write_long function, 
  -- there wont be an out of range error raised.
  --
  -- The function returns NULL if the end of the message stream has been reached. 
  --
  -- Parameters:
  --  id  - the operation id for this ADT instance. 
  --
  -- Raise ORA-24194: The type conversion between the type of real value and the expected type is invalid.
  -- Raise ORA-24196: The stream message is in write-only mode.
  -- Raise ORA-24197: JAVA stored procedure throws Exception during execution.
-- Raise ORA-24198: Invalid operation id.

  MEMBER FUNCTION read_long (id IN PLS_INTEGER)
  RETURN NUMBER,


  --============================================
  -- Read a short from the stream message. 
  --
  -- The function guarantees that the returned value is in the JAVA short value range. 
  -- This also means if this value is issued with a write_short function, 
  -- there wont be an out of range error raised.
  --
  -- The function returns NULL if the end of the message stream has been reached. 
  --
  -- Parameters:
  --  id  - the operation id for this ADT instance. 
  --
  -- Raise ORA-24194: The type conversion between the type of real value and the expected type is invalid.
  -- Raise ORA-24196: The stream message is in write-only mode.
  -- Raise ORA-24197: JAVA stored procedure throws Exception during execution.
  -- Raise ORA-24198: Invalid operation id.

  MEMBER FUNCTION read_short (id IN PLS_INTEGER)
  RETURN PLS_INTEGER,

  --============================================
  -- Read a String from the stream message. 
  --
  -- The function returns NULL if the end of the message stream has been reached. 
  --
  -- Parameters:
  --  id    - the operation id for this ADT instance. 
  --  value - the string that is read.
  --
  -- Raise ORA-24194: The type conversion between the type of real value and the expected type is invalid.
  -- Raise ORA-24196: The stream message is in write-only mode.
  -- Raise ORA-24197: JAVA stored procedure throws Exception during execution.
  -- Raise ORA-24198: Invalid operation id.

  MEMBER PROCEDURE read_string (id IN PLS_INTEGER, value OUT NOCOPY CLOB),


  --============================================
  -- Write a boolean to the stream message.
  --
  -- Parameters:
  --  id     - the operation id for this ADT instance. 
  --  value  - the boolean value to be written. The value is copied into the stream message.
--
  -- Raise ORA-24196: The stream message is in read-only mode.
  -- Raise ORA-24197: JAVA stored procedure throws Exception during execution.
  -- Raise ORA-24198: Invalid operation id.

  MEMBER PROCEDURE write_boolean (id IN PLS_INTEGER, value IN BOOLEAN),


  --============================================
  -- Write a byte to the stream message.
  --
  -- Parameters:
  --  id     - the operation id for this ADT instance. 
  --  value  - the byte value to be written. The value is copied into the stream message.
  --
  -- Raise ORA-24193: The parameter value exceeds the valid JAVA type range.
  -- Raise ORA-24196: The stream message is in read-only mode.
  -- Raise ORA-24197: JAVA stored procedure throws Exception during execution.
  -- Raise ORA-24198: Invalid operation id.

  MEMBER PROCEDURE write_byte (id IN PLS_INTEGER, value IN PLS_INTEGER),


  --============================================
  -- Write a byte array to the stream message.
  --
  -- This procedure takes a RAW type.
  -- Note that two consecutively written byte arrays are read as two distinct fields.
  --
  -- Parameters:
  --  id     - the operation id for this ADT instance. 
  --  value  - the byte array value to be written. The value is copied into the stream message.
  -- 
  -- Raise ORA-24196: The stream message is in read-only mode.
  -- Raise ORA-24197: JAVA stored procedure throws Exception during execution.
  -- Raise ORA-24198: Invalid operation id.

  MEMBER PROCEDURE write_bytes (id IN PLS_INTEGER, value IN RAW),


  --============================================
  -- Write a byte array to the stream message.
  --
  -- This procedure takes a BLOB type.
  -- Note that two consecutively written byte arrays are read as two distinct fields.
  --
  -- Parameters:
  --  id     - the operation id for this ADT instance. 
 --  value  - the byte array value to be written. The value is copied into the stream message.
  -- 
  -- Raise ORA-24196: The stream message is in read-only mode.
  -- Raise ORA-24197: JAVA stored procedure throws Exception during execution.
  -- Raise ORA-24198: Invalid operation id.

  MEMBER PROCEDURE write_bytes (id IN PLS_INTEGER, value IN BLOB),


  --============================================
  -- Write a portion of byte array to the stream message.
  --
  -- This procedure takes a RAW type.
  -- Note that two consecutively written byte arrays are read as two distinct fields.
  -- If the range [offset, offset+length] exceeds the boundary of the byte array value, 
  -- a JAVA IndexOutOfBoundsException is thrown at the JAVA stored procedure and ORA-24197
  -- ora error is raised at the PL/SQL side. The index starts from 0.
  --
  -- Parameters:
  --  id     - the operation id for this ADT instance. 
  --  value  - the byte array value to be written. The value is copied into the stream message.
  --  offset - the initial offset within the byte array.
  --  length - the number of bytes to use
  --
  -- Raise ORA-24196: The stream message is in read-only mode.
  -- Raise ORA-24197: JAVA stored procedure throws Exception during execution.
  -- Raise ORA-24198: Invalid operation id.

  MEMBER PROCEDURE write_bytes (
         id        IN      PLS_INTEGER,
         value     IN      RAW,
         offset    IN      PLS_INTEGER,
         length    IN      PLS_INTEGER
  ),


  --============================================
  -- Write a portion of byte array to the stream message.
  --
  -- This procedure takes a BLOB type.
  -- Note that two consecutively written byte arrays are read as two distinct fields.
  -- If the range [offset, offset+length] exceeds the boundary of the byte array value, 
  -- a JAVA IndexOutOfBoundsException is thrown at the JAVA stored procedure and ORA-24197
  -- ora error is raised at the PL/SQL side. The index starts from 0.
  --
  -- Parameters:
  --  id     - the operation id for this ADT instance. 
  --  value  - the byte array value to be written. The value is copied into the stream message.
  --  offset - the initial offset within the byte array.
  --  length - the number of bytes to use
--
  -- Raise ORA-24196: The stream message is in read-only mode.
  -- Raise ORA-24197: JAVA stored procedure throws Exception during execution.
  -- Raise ORA-24198: Invalid operation id.

  MEMBER PROCEDURE write_bytes (
         id        IN      PLS_INTEGER,
         value     IN      BLOB,
         offset    IN      PLS_INTEGER,
         length    IN      PLS_INTEGER
  ),

  --============================================
  -- Write a char to the stream message.
  --
  -- Parameters:
  --  id     - the operation id for this ADT instance. 
  --  value  - the char value to be written. The value is copied into the stream message.
  --
  -- Raise ORA-24196: The stream message is in read-only mode.
  -- Raise ORA-24197: JAVA stored procedure throws Exception during execution.
  -- Raise ORA-24198: Invalid operation id.

  MEMBER PROCEDURE write_char (id IN PLS_INTEGER, value IN CHAR),


  --============================================
  -- Write a double to the stream message.
  --
  -- Parameters:
  --  id     - the operation id for this ADT instance. 
  --  value  - the double value to be written. The value is copied into the stream message.
  --
  -- Raise ORA-24196: The stream message is in read-only mode.
  -- Raise ORA-24197: JAVA stored procedure throws Exception during execution.
  -- Raise ORA-24198: Invalid operation id.

  MEMBER PROCEDURE write_double (id IN PLS_INTEGER, value IN DOUBLE PRECISION),


  --============================================
  -- Write a float to the stream message.
  --
  -- Parameters:
  --  id     - the operation id for this ADT instance. 
  --  value  - the float value to be written. The value is copied into the stream message.
  --
  -- Raise ORA-24196: The stream message is in read-only mode.
  -- Raise ORA-24197: JAVA stored procedure throws Exception during execution.
  -- Raise ORA-24198: Invalid operation id.
MEMBER PROCEDURE write_float (id IN PLS_INTEGER, value IN FLOAT),


  --============================================
  -- Write a int to the stream message.
  --
  -- Parameters:
  --  id     - the operation id for this ADT instance. 
  --  value  - the int value to be written. The value is copied into the stream message.
  --
  -- Raise ORA-24193: The parameter value exceeds the valid JAVA type range.
  -- Raise ORA-24196: The stream message is in read-only mode.
  -- Raise ORA-24197: JAVA stored procedure throws Exception during execution.
  -- Raise ORA-24198: Invalid operation id.

  MEMBER PROCEDURE write_int (id IN PLS_INTEGER, value IN PLS_INTEGER),


  --============================================
  -- Write a long to the stream message.
  --
  -- Parameters:
  --  id     - the operation id for this ADT instance. 
  --  value  - the long value to be written. The value is copied into the stream message.
  --
  -- Raise ORA-24193: The parameter value exceeds the valid JAVA type range.
  -- Raise ORA-24196: The stream message is in read-only mode.
  -- Raise ORA-24197: JAVA stored procedure throws Exception during execution.
  -- Raise ORA-24198: Invalid operation id.

  MEMBER PROCEDURE write_long (id IN PLS_INTEGER, value IN NUMBER),


  --============================================
  -- Write a short to the stream message.
  --
  -- Parameters:
  --  id     - the operation id for this ADT instance. 
  --  value  - the short value to be written. The value is copied into the stream message.
  --
  -- Raise ORA-24193: The parameter value exceeds the valid JAVA type range.
  -- Raise ORA-24196: The stream message is in read-only mode.
  -- Raise ORA-24197: JAVA stored procedure throws Exception during execution.
  -- Raise ORA-24198: Invalid operation id.

  MEMBER PROCEDURE write_short (id IN PLS_INTEGER, value IN PLS_INTEGER),


  --============================================
  -- Write a String to the stream message.
  --
  -- This procedure takes VARCHAR2 type.
--
  -- Parameters:
  --  id     - the operation id for this ADT instance. 
  --  value  - the string value to be written. The value is copied into the stream message.
  --
  -- Raise ORA-24196: The stream message is in read-only mode.
  -- Raise ORA-24197: JAVA stored procedure throws Exception during execution.
  -- Raise ORA-24198: Invalid operation id.

  MEMBER PROCEDURE write_string (id IN PLS_INTEGER, value IN VARCHAR2),


  --============================================
  -- Write a String to the stream message.
  --
  -- This procedure takes CLOB type.
  --
  -- Parameters:
  --  id     - the operation id for this ADT instance. 
  --  value  - the string value to be written. The value is copied into the stream message.
  --
  -- Raise ORA-24196: The stream message is in read-only mode.
  -- Raise ORA-24197: JAVA stored procedure throws Exception during execution.
  -- Raise ORA-24198: Invalid operation id.

  MEMBER PROCEDURE write_string (id IN PLS_INTEGER, value IN CLOB),


  --*******************************************
  -- The following are JMS header related procedures
  --*******************************************

  MEMBER PROCEDURE set_replyto (replyto IN      sys.aq$_agent),

  MEMBER PROCEDURE set_type (type       IN      VARCHAR ),

  MEMBER PROCEDURE set_userid (userid   IN      VARCHAR ),

  MEMBER PROCEDURE set_appid (appid     IN      VARCHAR ),

  MEMBER PROCEDURE set_groupid (groupid IN      VARCHAR ),

  MEMBER PROCEDURE set_groupseq (groupseq       IN      int ),

  MEMBER PROCEDURE clear_properties ,

  MEMBER PROCEDURE set_boolean_property (
                property_name   IN      VARCHAR,
                property_value  IN      BOOLEAN ),

  MEMBER PROCEDURE set_byte_property (
                property_name   IN      VARCHAR,
                property_value  IN      int ),
  MEMBER PROCEDURE set_short_property (
                property_name   IN      VARCHAR,
                property_value  IN      int ),

  MEMBER PROCEDURE set_int_property (
                property_name   IN      VARCHAR,
                property_value  IN      int ),

  MEMBER PROCEDURE set_long_property (
                property_name   IN      VARCHAR,
                property_value  IN      NUMBER ),

  MEMBER PROCEDURE set_float_property (
                property_name   IN      VARCHAR,
                property_value  IN      FLOAT ),

  MEMBER PROCEDURE set_double_property (
                property_name   IN      VARCHAR,
                property_value  IN      DOUBLE PRECISION ),

  MEMBER PROCEDURE set_string_property (
                property_name   IN      VARCHAR,
                property_value  IN      VARCHAR ),

  MEMBER FUNCTION get_replyto RETURN sys.aq$_agent,

  MEMBER FUNCTION get_type RETURN VARCHAR,

  MEMBER FUNCTION get_userid RETURN VARCHAR,

  MEMBER FUNCTION get_appid RETURN VARCHAR,

  MEMBER FUNCTION get_groupid RETURN VARCHAR,

  MEMBER FUNCTION get_groupseq RETURN int,

  MEMBER FUNCTION get_boolean_property ( property_name   IN      VARCHAR)
  RETURN   BOOLEAN,

  MEMBER FUNCTION get_byte_property ( property_name   IN      VARCHAR)
  RETURN   int,

  MEMBER FUNCTION get_short_property ( property_name   IN      VARCHAR)
  RETURN   int,

  MEMBER FUNCTION get_int_property ( property_name   IN      VARCHAR)
  RETURN   int,

  MEMBER FUNCTION get_long_property ( property_name   IN      VARCHAR)
  RETURN   NUMBER,

  MEMBER FUNCTION get_float_property ( property_name   IN      VARCHAR)
RETURN   FLOAT,

  MEMBER FUNCTION get_double_property ( property_name   IN      VARCHAR)
  RETURN   DOUBLE PRECISION,

  MEMBER FUNCTION get_string_property ( property_name   IN      VARCHAR)
  RETURN   VARCHAR

);
/
show errors

create type aq$_jms_map_message 
oid '00000000000000000000000000021027' authid current_user
as object
(
  header     aq$_jms_header,
  bytes_len  int,
  bytes_raw  raw(2000),
  bytes_lob  blob,
  STATIC FUNCTION construct RETURN aq$_jms_map_message,


  -- ******************************************* 
  -- The following are common procedures of aq$_jms_stream_message, 
  -- aq$_jms_bytes_message and aq$_jms_map_message types to synchronize 
  -- the data between JAVA stored procedure and PL/SQL.
  -- *******************************************

  --============================================
  -- Get the JAVA exception thrown during the previous failure.
  -- Only one JAVA exception is recorded for a session. If the 
  -- exception is not fetched in time, it might be overwritten 
  -- by the exception thrown in next failure.

  STATIC FUNCTION get_exception
  RETURN AQ$_JMS_EXCEPTION,


  --============================================
  -- Clean all the messages in the JVM session memory.
  -- 

  STATIC PROCEDURE clean_all,


  --============================================
  -- Populate the data at JAVA stored procedure with the data at PL/SQL side.
  --
  -- Underlying, it takes the RAW/BLOB stored in PL/SQL aq$_jms_map_message
  -- to construct a JAVA object (for aq$_jms_map_message is Hashtable) 
  -- which is stored in ORACLE JVM session memeory. 
  -- 
  -- Parameter "id" is called operation id that is used to identify the slot 
  -- where the JAVA object is stored in the ORACLE JVM session memeory. 
  -- If "id" is NULL, a new slot is created for this PL/SQL object. 
  -- Later JMS operations on the payload need to provide this operation id.
  --
  -- Parameters:
  --  id  - the operation id for this ADT instance. 
  --        if id is negative, the system will create a new operation id.
  --
  -- Returns:
  --  the operation id.
  --
  -- There is no message access mode concept in aq$_jms_map_message. 
  -- The map message can be both written and read at any time and change is reflect immediately.
  --
  -- Raise ORA-24197: JAVA stored procedure throws Exception during execution.
  -- Raise ORA-24198: Invalid operation id.
  -- Raise ORA-24199: JAVA store procedure message store overflow.
 MEMBER FUNCTION prepare (id IN PLS_INTEGER)
  RETURN PLS_INTEGER,


  --============================================
  -- Set the data at JAVA stored procedure as empty payload.
  --
  -- Underlying, it initialize an new Hashtable object and set it to 
  -- the static varaible in ORACLE JVM session memeory.
  --
  -- Parameter "id" is called operation id that is used to identify the slot 
  -- where the JAVA object is stored in the ORACLE JVM session memeory. 
  -- If "id" is NULL, a new slot is created for this PL/SQL object. 
  -- Later JMS operations on the payload need to provide this operation id.
  --
  -- Parameters:
  --  id  - the operation id for this ADT instance. 
  --        if id is negative, the system will create a new operation id.
  --
  -- Returns:
  --  the operation id.
  --
  -- There is no message access mode concept in aq$_jms_map_message. 
  -- The map message can be both written and read at any time and change is reflect immediately.
  --
  -- Raise ORA-24197: JAVA stored procedure throws Exception during execution.
  -- Raise ORA-24198: Invalid operation id.
  -- Raise ORA-24199: JAVA store procedure message store overflow.

  MEMBER FUNCTION clear_body (id IN PLS_INTEGER)
  RETURN PLS_INTEGER,

  --============================================
  -- Flush the data at JAVA stored procedure side to PL/SQL side.
  --
  -- Underlying, it update the data at PL/SQL side to the payload stored at 
  -- the JAVA stored procedure side. 
  --
  -- Parameters:
  --  id  - the operation id for this ADT instance. 
  --
  -- Raise ORA-24197: JAVA stored procedure throws Exception during execution.
  -- Raise ORA-24198: Invalid operation id.

  MEMBER PROCEDURE flush (id IN PLS_INTEGER),

--============================================
  -- clean the data at JAVA stored procedure side to PL/SQL side.
  --
  -- Underlying, it set the static variable of Hashtable to null 
  -- at the JAVA stored procedure side corresponding to the operation id. 
  -- It is very import to call this procedure to avoid memeory leak!
  --
  -- Parameters:
  --  id  - the operation id for this ADT instance. 
  --
  -- Raise ORA-24198: Invalid operation id.

  MEMBER PROCEDURE clean (id IN PLS_INTEGER),


  --*******************************************
  -- JMS operations member functions and procedures
  --*******************************************

  --============================================
  -- Retrieve the size of the map message.
  --
  -- Parameters:
  --  id   - the operation id for this ADT instance. 
  --
  -- Raise ORA-24197: JAVA stored procedure throws Exception during execution.
  -- Raise ORA-24198: Invalid operation id.

  MEMBER FUNCTION get_size (id IN PLS_INTEGER)
  RETURN PLS_INTEGER,


  --============================================
  -- Retrieve all the names within the map message.
  -- Since aq$_jms_namearray has a size of 1024 and each element a varchar(200),
  -- this function raise error if either of sizes limit is exceeded.
  --
  -- Parameters:
  --  id   - the operation id for this ADT instance. 
  --
  -- Raise ORA-24195: size of the name array or the size of a name eceed the limit.
  -- Raise ORA-24197: JAVA stored procedure throws Exception during execution.
  -- Raise ORA-24198: Invalid operation id.

  MEMBER FUNCTION get_names (id IN PLS_INTEGER)
  RETURN AQ$_JMS_NAMEARRAY,

--============================================
  -- Retrieve a portion of the names within the map message.
  -- Since aq$_jms_namearray has a size of 1024 and each element a varchar(200),
  -- this function raise error if either of sizes limit is exceeded.
  -- The index of map message starts from 0.
  --
  -- The function returns the number of names that has been retrieved.
  -- The names retrieved is the intersection of the interval [offset, offset+length-1]
  -- and interval [0, size-1] where size is the size of this map message.
  -- If the intersection is empty set, names will be NULL and the function returns 0 
  -- as the number of names retrieved. These can be used as a test that there is
  -- no more name to read from the map message.
  --  
  -- Parameters:
  --  id      - the operation id for this ADT instance.
  --  names   - the names that has been retrieved.
  --  offset  - the offset from which to start retrieving.
  --  length  - the length of the names to be retrieved.
  --
  -- Raise ORA-24195: size of the name array or the size of a name eceed the limit.
  -- Raise ORA-24197: JAVA stored procedure throws Exception during execution.
  -- Raise ORA-24198: Invalid operation id.

  MEMBER FUNCTION get_names (
         id       IN        PLS_INTEGER,
         names    OUT       AQ$_JMS_NAMEARRAY,
         offset   IN        PLS_INTEGER,
         length   IN        PLS_INTEGER )
  RETURN PLS_INTEGER,


  --============================================
  -- Test whether an item exists in the map message.
  -- Return TRUE if the item exists.
  --
  -- Parameters:
  --  id   - the operation id for this ADT instance. 
  --  name - the specified name.
  --
  -- Raise ORA-24197: JAVA stored procedure throws Exception during execution.
  -- Raise ORA-24198: Invalid operation id.

  MEMBER FUNCTION item_exists (id IN PLS_INTEGER, name IN VARCHAR2)
  RETURN BOOLEAN,


  --============================================
  -- Read a object value from the map message.
  --
  -- The function returns a general value ADT AQ$_JMS_VALUE. User can use the
  -- "type" attribute of this ADT to interpret the data. 
-- The following is a map among type attribute, JAVA type and value attributes
  --
  -- -----------------------------------------------------------------
  --               type                 | JAVA type | value attributes
  -- -----------------------------------------------------------------                
  -- DBMS_JMS_PLSQL.DATA_TYPE_BYTE      |  byte     |    num_val 
  -- -----------------------------------------------------------------
  -- DBMS_JMS_PLSQL.DATA_TYPE_SHORT     |  short    |    num_val
  -- -----------------------------------------------------------------
  -- DBMS_JMS_PLSQL.DATA_TYPE_INTEGER   |  int      |    num_val
  -- -----------------------------------------------------------------
  -- DBMS_JMS_PLSQL.DATA_TYPE_LONG      |  long     |    num_val
  -- -----------------------------------------------------------------
  -- DBMS_JMS_PLSQL.DATA_TYPE_FLOAT     |  float    |    num_val
  -- -----------------------------------------------------------------
  -- DBMS_JMS_PLSQL.DATA_TYPE_DOUBLE    |  double   |    num_val
  -- -----------------------------------------------------------------
  -- DBMS_JMS_PLSQL.DATA_TYPE_BOOLEAN   |  boolean  |    num_val
  -- -----------------------------------------------------------------
  -- DBMS_JMS_PLSQL.DATA_TYPE_CHARACTER |  char     |    char_val
  -- -----------------------------------------------------------------
  -- DBMS_JMS_PLSQL.DATA_TYPE_STRING    |  String   |    text_val
  -- -----------------------------------------------------------------
  -- DBMS_JMS_PLSQL.DATA_TYPE_BYTES     |  byte[]   |    bytes_val
  -- -----------------------------------------------------------------
  --
  -- The function returns NULL if there is no such item with the specified name.
  -- 
  -- Also note that this memeber procedure might bring additional overhead 
  -- comparing to other "read" memeber procedures. It is used only if the user 
  -- does not know the data type before hand, otherwise it is always a good idea
  -- to use a specific read member procedure.
  --
  -- Parameters:
  --  id    - the operation id for this ADT instance. 
  --  name  - the specified name.
  --  value - the object that is read.
  -- 
  -- Raise ORA-24194: The type conversion between the type of real value and the expected type is invalid.
  --                  In this particular case, an object with unsupported type is read from the stream.
  -- Raise ORA-24197: JAVA stored procedure throws Exception during execution.
  -- Raise ORA-24198: Invalid operation id.

  MEMBER PROCEDURE get_object (id IN PLS_INTEGER, name IN VARCHAR2, value OUT NOCOPY AQ$_JMS_VALUE),
 --============================================
  -- Get a boolean value from the map message with the specified name.
  --
  -- The function returns NULL if there is no such item with the specified name.
  --
  -- Parameters:
  --  id   - the operation id for this ADT instance. 
  --  name - the specified name.
  -- 
  -- Raise ORA-24194: The type conversion between the type of real value and the expected type is invalid.
  -- Raise ORA-24197: JAVA stored procedure throws Exception during execution.
  -- Raise ORA-24198: Invalid operation id.

  MEMBER FUNCTION get_boolean (id IN PLS_INTEGER, name IN VARCHAR2)
  RETURN BOOLEAN,


  --============================================
  -- Get a byte from the map message with the specified name. 
  --
  -- The function guarantees that the returned value is in the JAVA byte value range. 
  -- This also means if this value is issued with a set_byte function, 
  -- there wont be an out of range error raised.
  -- 
  -- The function returns NULL if there is no such item with the specified name. 
  --
  -- Parameters:
  --  id   - the operation id for this ADT instance. 
  --  name - the specified name.
  --
  -- Raise ORA-24194: The type conversion between the type of real value and the expected type is invalid.
  -- Raise ORA-24197: JAVA stored procedure throws Exception during execution.
  -- Raise ORA-24198: Invalid operation id.

  MEMBER FUNCTION get_byte (id IN PLS_INTEGER, name IN VARCHAR2)
  RETURN PLS_INTEGER,


  --============================================
  -- Get a byte array from the map message with the specified name. 
  --
  -- The function returns NULL if there is no such item with the specified name. 
  --
  -- Parameters:
  --  id    - the operation id for this ADT instance. 
  --  name  - the specified name.
  --  value - the bytes that is read.
  --
  -- Raise ORA-24194: The type conversion between the type of real value and the expected type is invalid.
  -- Raise ORA-24197: JAVA stored procedure throws Exception during execution.
-- Raise ORA-24198: Invalid operation id.

  MEMBER PROCEDURE get_bytes (id IN PLS_INTEGER, name IN VARCHAR2, value OUT NOCOPY BLOB),

  --============================================
  -- Get a char from the map message with the specified name. 
  --
  -- The function returns NULL if there is no such item with the specified name. 
  --
  -- Parameters:
  --  id   - the operation id for this ADT instance. 
  --  name - the specified name.
  --
  -- Raise ORA-24194: The type conversion between the type of real value and the expected type is invalid.
  -- Raise ORA-24197: JAVA stored procedure throws Exception during execution.
  -- Raise ORA-24198: Invalid operation id.

  MEMBER FUNCTION get_char (id IN PLS_INTEGER, name IN VARCHAR2)
  RETURN CHAR,


  --============================================
  -- Get a double from the map message with the specified name. 
  --
  -- The function returns NULL if there is no such item with the specified name. 
  --
  -- Parameters:
  --  id   - the operation id for this ADT instance. 
  --  name - the specified name.
  --
  -- Raise ORA-24194: The type conversion between the type of real value and the expected type is invalid.
  -- Raise ORA-24197: JAVA stored procedure throws Exception during execution.
  -- Raise ORA-24198: Invalid operation id.

  MEMBER FUNCTION get_double (id IN PLS_INTEGER, name IN VARCHAR2)
  RETURN DOUBLE PRECISION,

  --============================================
  -- Get a float from the map message with the specified name. 
  --
  -- The function returns NULL if there is no such item with the specified name. 
  --
  -- Parameters:
  --  id   - the operation id for this ADT instance. 
  --  name - the specified name.
  --
  -- Raise ORA-24194: The type conversion between the type of real value and the expected type is invalid.
  -- Raise ORA-24197: JAVA stored procedure throws Exception during execution.
  -- Raise ORA-24198: Invalid operation id.
MEMBER FUNCTION get_float (id IN PLS_INTEGER, name IN VARCHAR2)
  RETURN FLOAT,


  --============================================
  -- Get a int from the map message with the specified name. 
  --
  -- The function guarantees that the returned value is in the JAVA int value range. 
  -- This also means if this value is issued with a set_int function, 
  -- there wont be an out of range error raised.
  --
  -- The function returns NULL if there is no such item with the specified name. 
  --
  -- Parameters:
  --  id   - the operation id for this ADT instance. 
  --  name - the specified name.
  --
  -- Raise ORA-24194: The type conversion between the type of real value and the expected type is invalid.
  -- Raise ORA-24197: JAVA stored procedure throws Exception during execution.
  -- Raise ORA-24198: Invalid operation id.

  MEMBER FUNCTION get_int (id IN PLS_INTEGER, name IN VARCHAR2)
  RETURN PLS_INTEGER,


  --============================================
  -- Get a long from the map message with the specified name. 
  --
  -- The function guarantees that the returned value is in the JAVA long value range. 
  -- This also means if this value is issued with a set_long function, 
  -- there wont be an out of range error raised.
  --
  -- The function returns NULL if there is no such item with the specified name. 
  --
  -- Parameters:
  --  id   - the operation id for this ADT instance. 
  --  name - the specified name.
  --
  -- Raise ORA-24194: The type conversion between the type of real value and the expected type is invalid.
  -- Raise ORA-24197: JAVA stored procedure throws Exception during execution.
  -- Raise ORA-24198: Invalid operation id.

  MEMBER FUNCTION get_long (id IN PLS_INTEGER, name IN VARCHAR2)
  RETURN NUMBER,


  --============================================
  -- Get a short from the map message with the specified name. 
  --
  -- The function guarantees that the returned value is in the JAVA short value range. 
  -- This also means if this value is issued with a set_short function, 
  -- there wont be an out of range error raised.
  --
  -- The function returns NULL if there is no such item with the specified name. 
  --
  -- Parameters:
  --  id   - the operation id for this ADT instance. 
  --  name - the specified name.
  --
  -- Raise ORA-24194: The type conversion between the type of real value and the expected type is invalid.
  -- Raise ORA-24197: JAVA stored procedure throws Exception during execution.
  -- Raise ORA-24198: Invalid operation id.

  MEMBER FUNCTION get_short (id IN PLS_INTEGER, name IN VARCHAR2)
  RETURN PLS_INTEGER,

  --============================================
  -- Get a String from the map message with the specified name. 
  --
  -- The function returns NULL if there is no such item with the specified name. 
  --
  -- Parameters:
  --  id    - the operation id for this ADT instance.
  --  name  - the specified name.
  --  value - the string that is read.
  --
  -- Raise ORA-24194: The type conversion between the type of real value and the expected type is invalid.
  -- Raise ORA-24197: JAVA stored procedure throws Exception during execution.
  -- Raise ORA-24198: Invalid operation id.

  MEMBER PROCEDURE get_string (id IN PLS_INTEGER, name IN VARCHAR2, value OUT NOCOPY CLOB),


  --============================================
  -- Set a boolean to the map message with the specified name.
  --
  -- Parameters:
  --  id     - the operation id for this ADT instance. 
  --  name   - the specified name.
  --  value  - the boolean value to be written. The value is copied into the map message.
  --
  -- Raise ORA-24197: JAVA stored procedure throws Exception during execution.
  -- Raise ORA-24198: Invalid operation id.

  MEMBER PROCEDURE set_boolean (id IN PLS_INTEGER, name IN VARCHAR2, value IN BOOLEAN),


  --============================================
  -- Set a byte to the map message with the specified name.
  --
  -- Parameters:
  --  id     - the operation id for this ADT instance. 
--  name   - the specified name.
  --  value  - the byte value to be written. The value is copied into the map message.
  --
  -- Raise ORA-24193: The parameter value exceeds the valid JAVA type range.
  -- Raise ORA-24197: JAVA stored procedure throws Exception during execution.
  -- Raise ORA-24198: Invalid operation id.

  MEMBER PROCEDURE set_byte (id IN PLS_INTEGER, name IN VARCHAR2, value IN PLS_INTEGER),


  --============================================
  -- Set a byte array to the map message with the specified name.
  --
  -- This procedure takes a RAW type.
  --
  -- Parameters:
  --  id     - the operation id for this ADT instance. 
  --  name   - the specified name.
  --  value  - the byte array value to be written. The value is copied into the map message.
  -- 
  -- Raise ORA-24197: JAVA stored procedure throws Exception during execution.
  -- Raise ORA-24198: Invalid operation id.

  MEMBER PROCEDURE set_bytes (id IN PLS_INTEGER, name IN VARCHAR2, value IN RAW),


  --============================================
  -- Set a byte array to the map message with the specified name.
  --
  -- This procedure takes a BLOB type.
  --
  -- Parameters:
  --  id     - the operation id for this ADT instance. 
  --  name   - the specified name.
  --  value  - the byte array value to be written. The value is copied into the map message.
  -- 
  -- Raise ORA-24197: JAVA stored procedure throws Exception during execution.
  -- Raise ORA-24198: Invalid operation id.

  MEMBER PROCEDURE set_bytes (id IN PLS_INTEGER, name IN VARCHAR2, value IN BLOB),


  --============================================
  -- Set a portion of byte array to the map message with the specified name.
  --
  -- This procedure takes a RAW type.
  -- If the range [offset, offset+length] exceeds the boundary of the byte array value, 
  -- a JAVA IndexOutOfBoundsException is thrown at the JAVA stored procedure and ORA-24197
  -- ora error is raised at the PL/SQL side. The index starts from 0.
  --
  -- Parameters:
  --  id     - the operation id for this ADT instance. 
 --  name   - the specified name.
  --  value  - the byte array value to be written. The value is copied into the map message.
  --  offset - the initial offset within the byte array.
  --  length - the number of bytes to use
  --
  -- Raise ORA-24197: JAVA stored procedure throws Exception during execution.
  -- Raise ORA-24198: Invalid operation id.

  MEMBER PROCEDURE set_bytes (
         id        IN      PLS_INTEGER,
         name      IN      VARCHAR2,
         value     IN      RAW,
         offset    IN      PLS_INTEGER,
         length    IN      PLS_INTEGER
  ),


  --============================================
  -- Set a portion of byte array to the map message with the specified name.
  --
  -- This procedure takes a BLOB type.
  -- If the range [offset, offset+length] exceeds the boundary of the byte array value, 
  -- a JAVA IndexOutOfBoundsException is thrown at the JAVA stored procedure and ORA-24197
  -- ora error is raised at the PL/SQL side. The index starts from 0.
  --
  -- Parameters:
  --  id     - the operation id for this ADT instance. 
  --  name   - the specified name.
  --  value  - the byte array value to be written. The value is copied into the map message.
  --  offset - the initial offset within the byte array.
  --  length - the number of bytes to use
  --
  -- Raise ORA-24197: JAVA stored procedure throws Exception during execution.
  -- Raise ORA-24198: Invalid operation id.

  MEMBER PROCEDURE set_bytes (
         id        IN      PLS_INTEGER,
         name      IN      VARCHAR2,
         value     IN      BLOB,
         offset    IN      PLS_INTEGER,
         length    IN      PLS_INTEGER
  ),

  --============================================
  -- Set a char to the map message with the specified name.
  --
  -- Parameters:
  --  id     - the operation id for this ADT instance. 
  --  name   - the specified name.
  --  value  - the char value to be written. The value is copied into the map message.
  --
  -- Raise ORA-24197: JAVA stored procedure throws Exception during execution.
  -- Raise ORA-24198: Invalid operation id.
  MEMBER PROCEDURE set_char (id IN PLS_INTEGER, name IN VARCHAR2, value IN CHAR),


  --============================================
  -- Set a double to the map message with the specified name.
  --
  -- Parameters:
  --  id     - the operation id for this ADT instance. 
  --  name   - the specified name.
  --  value  - the double value to be written. The value is copied into the map message.
  --
  -- Raise ORA-24197: JAVA stored procedure throws Exception during execution.
  -- Raise ORA-24198: Invalid operation id.

  MEMBER PROCEDURE set_double (id IN PLS_INTEGER, name IN VARCHAR2, value IN DOUBLE PRECISION),


  --============================================
  -- Set a float to the map message with the specified name.
  --
  -- Parameters:
  --  id     - the operation id for this ADT instance. 
  --  name   - the specified name.
  --  value  - the float value to be written. The value is copied into the map message.
  --
  -- Raise ORA-24197: JAVA stored procedure throws Exception during execution.
  -- Raise ORA-24198: Invalid operation id.

  MEMBER PROCEDURE set_float (id IN PLS_INTEGER, name IN VARCHAR2, value IN FLOAT),


  --============================================
  -- Set a int to the map message with the specified name.
  --
  -- Parameters:
  --  id     - the operation id for this ADT instance. 
  --  name   - the specified name.
  --  value  - the int value to be written. The value is copied into the map message.
  --
  -- Raise ORA-24193: The parameter value exceeds the valid JAVA type range.
  -- Raise ORA-24197: JAVA stored procedure throws Exception during execution.
  -- Raise ORA-24198: Invalid operation id.

  MEMBER PROCEDURE set_int (id IN PLS_INTEGER, name IN VARCHAR2, value IN PLS_INTEGER),


  --============================================
  -- Set a long to the map message with the specified name.
  --
  -- Parameters:
  --  id     - the operation id for this ADT instance. 
  --  name   - the specified name.
 --  value  - the long value to be written. The value is copied into the map message.
  --
  -- Raise ORA-24193: The parameter value exceeds the valid JAVA type range.
  -- Raise ORA-24197: JAVA stored procedure throws Exception during execution.
  -- Raise ORA-24198: Invalid operation id.

  MEMBER PROCEDURE set_long (id IN PLS_INTEGER, name IN VARCHAR2, value IN NUMBER),


  --============================================
  -- Set a short to the map message with the specified name.
  --
  -- Parameters:
  --  id     - the operation id for this ADT instance. 
  --  name   - the specified name.
  --  value  - the short value to be written. The value is copied into the map message.
  --
  -- Raise ORA-24193: The parameter value exceeds the valid JAVA type range.
  -- Raise ORA-24197: JAVA stored procedure throws Exception during execution.
  -- Raise ORA-24198: Invalid operation id.

  MEMBER PROCEDURE set_short (id IN PLS_INTEGER, name IN VARCHAR2, value IN PLS_INTEGER),


  --============================================
  -- Set a String to the map message with the specified name.
  --
  -- This procedure takes VARCHAR2 type.
  --
  -- Parameters:
  --  id     - the operation id for this ADT instance. 
  --  name   - the specified name.
  --  value  - the string value to be written. The value is copied into the map message.
  --
  -- Raise ORA-24197: JAVA stored procedure throws Exception during execution.
  -- Raise ORA-24198: Invalid operation id.

  MEMBER PROCEDURE set_string (id IN PLS_INTEGER, name IN VARCHAR2, value IN VARCHAR2),


  --============================================
  -- Set a String to the map message with the specified name.
  --
  -- This procedure takes CLOB type.
  --
  -- Parameters:
  --  id     - the operation id for this ADT instance. 
  --  name   - the specified name.
  --  value  - the string value to be written. The value is copied into the map message.
  --
  -- Raise ORA-24197: JAVA stored procedure throws Exception during execution.
  -- Raise ORA-24198: Invalid operation id.
MEMBER PROCEDURE set_string (id IN PLS_INTEGER, name IN VARCHAR2, value IN CLOB),


  --*******************************************
  -- The following are JMS header related procedures
  --*******************************************

  MEMBER PROCEDURE set_replyto (replyto IN      sys.aq$_agent),

  MEMBER PROCEDURE set_type (type       IN      VARCHAR ),

  MEMBER PROCEDURE set_userid (userid   IN      VARCHAR ),

  MEMBER PROCEDURE set_appid (appid     IN      VARCHAR ),

  MEMBER PROCEDURE set_groupid (groupid IN      VARCHAR ),

  MEMBER PROCEDURE set_groupseq (groupseq       IN      int ),

  MEMBER PROCEDURE clear_properties ,

  MEMBER PROCEDURE set_boolean_property (
                property_name   IN      VARCHAR,
                property_value  IN      BOOLEAN ),

  MEMBER PROCEDURE set_byte_property (
                property_name   IN      VARCHAR,
                property_value  IN      int ),

  MEMBER PROCEDURE set_short_property (
                property_name   IN      VARCHAR,
                property_value  IN      int ),

  MEMBER PROCEDURE set_int_property (
                property_name   IN      VARCHAR,
                property_value  IN      int ),

  MEMBER PROCEDURE set_long_property (
                property_name   IN      VARCHAR,
                property_value  IN      NUMBER ),

  MEMBER PROCEDURE set_float_property (
                property_name   IN      VARCHAR,
                property_value  IN      FLOAT ),

  MEMBER PROCEDURE set_double_property (
                property_name   IN      VARCHAR,
                property_value  IN      DOUBLE PRECISION ),

  MEMBER PROCEDURE set_string_property (
                property_name   IN      VARCHAR,
                property_value  IN      VARCHAR ),
MEMBER FUNCTION get_replyto RETURN sys.aq$_agent,

  MEMBER FUNCTION get_type RETURN VARCHAR,

  MEMBER FUNCTION get_userid RETURN VARCHAR,

  MEMBER FUNCTION get_appid RETURN VARCHAR,

  MEMBER FUNCTION get_groupid RETURN VARCHAR,

  MEMBER FUNCTION get_groupseq RETURN int,

  MEMBER FUNCTION get_boolean_property ( property_name   IN      VARCHAR)
  RETURN   BOOLEAN,

  MEMBER FUNCTION get_byte_property ( property_name   IN      VARCHAR)
  RETURN   int,

  MEMBER FUNCTION get_short_property ( property_name   IN      VARCHAR)
  RETURN   int,

  MEMBER FUNCTION get_int_property ( property_name   IN      VARCHAR)
  RETURN   int,

  MEMBER FUNCTION get_long_property ( property_name   IN      VARCHAR)
  RETURN   NUMBER,

  MEMBER FUNCTION get_float_property ( property_name   IN      VARCHAR)
  RETURN   FLOAT,

  MEMBER FUNCTION get_double_property ( property_name   IN      VARCHAR)
  RETURN   DOUBLE PRECISION,

  MEMBER FUNCTION get_string_property ( property_name   IN      VARCHAR)
  RETURN   VARCHAR

  
);
/
show errors
create type aq$_jms_message
oid '00000000000000000000000000021023'
as object
(
  header        aq$_jms_header,
  senderid      varchar2(100),
  message_type  int,
  text_len      int,
  bytes_len     int,
  text_vc       varchar2(4000),
  bytes_raw     raw(2000),
  text_lob      clob,
  bytes_lob     blob,
  STATIC FUNCTION construct ( mtype IN int ) RETURN aq$_jms_message,

  --*******************************************
  -- Pseudo upcast to aq$_jms_messaeg
  --*******************************************

  STATIC FUNCTION construct( text_msg IN  aq$_jms_text_message)
  RETURN aq$_jms_message,

  STATIC FUNCTION construct( bytes_msg IN  aq$_jms_bytes_message)
  RETURN aq$_jms_message,

  STATIC FUNCTION construct( stream_msg IN  aq$_jms_stream_message)
  RETURN aq$_jms_message,

  STATIC FUNCTION construct( map_msg IN  aq$_jms_map_message)
  RETURN aq$_jms_message,

  STATIC FUNCTION construct( object_msg IN  aq$_jms_object_message)
  RETURN aq$_jms_message,

  -- cast an aq$_jms_message to an aq$_jms_text_message
  -- 
  -- Return aq$_jms_text_message or NULL if message_type attribute of the aq$_jms_message 
  -- is not DBMS_AQ.JMS_TEXT_MESSAGE.

  MEMBER FUNCTION cast_to_text_msg RETURN aq$_jms_text_message,

  --
  -- cast an aq$_jms_message to an aq$_jms_bytes_message
  -- 
  -- Return aq$_jms_bytes_message or NULL if message_type attribute of the aq$_jms_message
  -- is not DBMS_AQ.JMS_BYTES_MESSAGE.

  MEMBER FUNCTION cast_to_bytes_msg RETURN aq$_jms_bytes_message,
--
  -- cast an aq$_jms_message to an aq$_jms_stream_message
  -- 
  -- Return aq$_jms_stream_message or NULL if message_type attribute of the aq$_jms_message
  -- is not DBMS_AQ.JMS_STREAM_MESSAGE.

  MEMBER FUNCTION cast_to_stream_msg RETURN aq$_jms_stream_message,

  --
  -- cast an aq$_jms_message to an aq$_jms_map_message
  -- 
  -- Return aq$_jms_map_message or NULL if message_type attribute of the aq$_jms_message
  -- is not DBMS_AQ.JMS_MAP_MESSAGE.
MEMBER FUNCTION cast_to_map_msg RETURN aq$_jms_map_message,

  --
  -- cast an aq$_jms_message to an aq$_jms_object_message
  -- 
  -- Return aq$_jms_object_message or NULL if message_type attribute of the aq$_jms_message
  -- is not DBMS_AQ.JMS_OBJECT_MESSAGE.

  MEMBER FUNCTION cast_to_object_msg RETURN aq$_jms_object_message,


  --
  -- set_text sets payload in varchar2 into text_vc if the length of
  -- payload is <= 4000, into text_lob if otherwise.
  --
  -- @param payload (IN)
  --
  MEMBER PROCEDURE set_text ( payload IN VARCHAR2 ),

  --
  -- set_text sets payload in clob in text_lob.
  --
  -- @param payload (IN)
  --
  MEMBER PROCEDURE set_text ( payload IN CLOB ),

  --
  -- get_text puts text_vc into payload if text_vc is not null,
  -- or transfers text_lob in clob into payload in varchar2 if the
  -- length of text_lob is =< 32767 (2**16 -1).
  -- Maximum length of varchar2 in PL/SQL is 32767.
  --
  -- @param payload (OUT)
  --
  -- @throws -24190 if the length of text_lob is > 32767.
  --
  MEMBER PROCEDURE get_text ( payload OUT VARCHAR2 ),

  --
  -- get_text puts text_lob into payload if text_lob is not null,
  -- or transfers text_vc in varchar2 into payload in clob.
--
  -- @param payload (OUT)
  --
  MEMBER PROCEDURE get_text ( payload OUT NOCOPY CLOB ),

  --
  -- set_bytes sets payload in RAW into bytes_raw if the length of
  -- payload is <= 2000, otherwise into bytes_lob.
  --
  -- @param payload (IN)
-- @param payload (IN)
  --
  MEMBER PROCEDURE set_bytes ( payload IN RAW ),

  --
  -- set_bytes sets payload in blob in bytes_lob.
  --
  -- @param payload (IN)
  --
  MEMBER PROCEDURE set_bytes ( payload IN BLOB ),

  --
  -- get_bytes puts bytes_raw into payload if it is not null,
  -- or transfers bytes_lob in blob into payload in RAW if the
  -- length of bytes_lob is =< 32767 (2**16 -1).
  -- Maximum length of raw in PL/SQL is 32767.
  --
  -- @param payload (OUT)
  --
  -- @throws -24190 if bytes_raw is null and
  -- the length of bytes_lob is > 32767.
  --
  MEMBER PROCEDURE get_bytes ( payload OUT RAW ),

  --
  -- get_bytes puts bytes_lob into payload if it is not null,
  -- or transfers bytes_raw in RAW into payload in blob.
  --
  -- @param payload (OUT)
  --
  MEMBER PROCEDURE get_bytes ( payload OUT NOCOPY BLOB ),


  MEMBER PROCEDURE set_replyto (replyto IN      sys.aq$_agent),

  MEMBER PROCEDURE set_type (type       IN      VARCHAR ),

  MEMBER PROCEDURE set_userid (userid   IN      VARCHAR ),

  MEMBER PROCEDURE set_appid (appid     IN      VARCHAR ),

  MEMBER PROCEDURE set_groupid (groupid IN      VARCHAR ),

  MEMBER PROCEDURE set_groupseq (groupseq       IN      int ),
  MEMBER PROCEDURE clear_properties ,

  MEMBER PROCEDURE set_boolean_property (
                property_name   IN      VARCHAR,
                property_value  IN      BOOLEAN ),
MEMBER PROCEDURE set_byte_property (
                property_name   IN      VARCHAR,
                property_value  IN      int ),

  MEMBER PROCEDURE set_short_property (
                property_name   IN      VARCHAR,
                property_value  IN      int ),

  MEMBER PROCEDURE set_int_property (
                property_name   IN      VARCHAR,
                property_value  IN      int ),

  MEMBER PROCEDURE set_long_property (
                property_name   IN      VARCHAR,
                property_value  IN      NUMBER ),

  MEMBER PROCEDURE set_float_property (
                property_name   IN      VARCHAR,
                property_value  IN      FLOAT ),

  MEMBER PROCEDURE set_double_property (
                property_name   IN      VARCHAR,
                property_value  IN      DOUBLE PRECISION ),

  MEMBER PROCEDURE set_string_property (
                property_name   IN      VARCHAR,
                property_value  IN      VARCHAR ),

  MEMBER FUNCTION get_replyto RETURN sys.aq$_agent,

  MEMBER FUNCTION get_type RETURN VARCHAR,

  MEMBER FUNCTION get_userid RETURN VARCHAR,

  MEMBER FUNCTION get_appid RETURN VARCHAR,

  MEMBER FUNCTION get_groupid RETURN VARCHAR,

  MEMBER FUNCTION get_groupseq RETURN int,

  MEMBER FUNCTION get_boolean_property ( property_name   IN      VARCHAR)
  RETURN   BOOLEAN,

  MEMBER FUNCTION get_byte_property ( property_name   IN      VARCHAR)
  RETURN   int,

  MEMBER FUNCTION get_short_property ( property_name   IN      VARCHAR)
RETURN   int,

  MEMBER FUNCTION get_int_property ( property_name   IN      VARCHAR)
  RETURN   int,
MEMBER FUNCTION get_long_property ( property_name   IN      VARCHAR)
  RETURN   NUMBER,

  MEMBER FUNCTION get_float_property ( property_name   IN      VARCHAR)
  RETURN   FLOAT,

  MEMBER FUNCTION get_double_property ( property_name   IN      VARCHAR)
  RETURN   DOUBLE PRECISION,

  MEMBER FUNCTION get_string_property ( property_name   IN      VARCHAR)
  RETURN   VARCHAR

);
/
show errors
grant execute on aq$_jms_message to public;

grant execute on aq$_jms_text_message to public;

grant execute on aq$_jms_bytes_message to public;

grant execute on aq$_jms_stream_message to public;

grant execute on aq$_jms_map_message to public;

grant execute on aq$_jms_object_message to public;

grant execute on aq$_jms_header to public;

grant execute on aq$_jms_userproparray to public;

grant execute on aq$_jms_userproperty to public;


create type aq$_jms_messages 
timestamp '2002-10-23:15:20:01' oid '00000000000000000000000000021000'
as varray(2147483647) of aq$_jms_message;
/

create type aq$_jms_text_messages 
timestamp '2002-10-23:15:20:02' oid '00000000000000000000000000021001'
as varray(2147483647) of aq$_jms_text_message;
/

create type aq$_jms_bytes_messages 
timestamp '2002-10-23:15:20:03' oid '00000000000000000000000000021002'
as varray(2147483647) of aq$_jms_bytes_message;
/

create type aq$_jms_map_messages 
timestamp '2002-10-23:15:20:04' oid '00000000000000000000000000021003'
as varray(2147483647) of aq$_jms_map_message;
/

create type aq$_jms_stream_messages 
timestamp '2002-10-23:15:20:05' oid '00000000000000000000000000021004'
as varray(2147483647) of aq$_jms_stream_message;
/

create type aq$_jms_object_messages 
timestamp '2002-10-23:15:20:05' oid '00000000000000000000000000021005'
as varray(2147483647) of aq$_jms_object_message;
/

create type aq$_jms_message_property 
timestamp '2002-10-23:15:30:00' oid '00000000000000000000000000021010'
as object
(
   priority          int,
   delay             int,
   expiration        int,
   correlation       varchar2(128),
   attempts          int,
   recipient_list    sys.aq$_recipients,
   exception_queue   varchar2(128),
   enqueue_time      date,
   state             int,
   sender_id         sys.aq$_agent,
   original_msgid    raw(16),
   signature         sys.aq$_sig_prop,
   transaction_group varchar2(30)
);
/

create  type aq$_jms_message_properties
timestamp '2002-10-23:15:31:00' oid '00000000000000000000000000021011'
as varray(2147483647) of aq$_jms_message_property;
/

create type aq$_jms_array_msgid_info
timestamp '2002-10-23:15:33:00' oid '00000000000000000000000000021012'
as object
(
   msgid    raw(16)
);
/

create type aq$_jms_array_msgids
timestamp '2002-10-23:15:34:00' oid '00000000000000000000000000021013'
as varray(2147483647) of raw(16);
/

create type aq$_jms_array_error_info
timestamp '2002-10-23:15:33:00' oid '00000000000000000000000000021014'
as object
(
   error_position    int,
   error_no          int,
   error_msg         varchar2(4000)
);
/

create type aq$_jms_array_errors
timestamp '2002-10-23:15:34:00' oid '00000000000000000000000000021016'
as varray(2147483647) of aq$_jms_array_error_info;
/
grant execute on aq$_jms_messages to public;

grant execute on aq$_jms_text_messages to public;

grant execute on aq$_jms_bytes_messages to public;

grant execute on aq$_jms_stream_messages to public;

grant execute on aq$_jms_map_messages to public;

grant execute on aq$_jms_object_messages to public;

grant execute on aq$_jms_message_property to public;

grant execute on aq$_jms_message_properties to public;

grant execute on aq$_jms_array_msgid_info to public;

grant execute on aq$_jms_array_msgids to public;

grant execute on aq$_jms_array_error_info to public;

grant execute on aq$_jms_array_errors to public;


@?/rdbms/admin/sqlsessend.sql
