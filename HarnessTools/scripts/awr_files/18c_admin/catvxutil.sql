Rem
Rem $Header: rdbms/admin/catvxutil.sql /main/8 2016/08/18 10:51:12 rafsanto Exp $
Rem
Rem catvxutil.sql
Rem
Rem Copyright (c) 2011, 2016, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catvxutil.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catvxutil.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catvxutil.sql
Rem SQL_PHASE: CATVXUTIL
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catxdbv.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    rafsanto    07/27/16 - Bug 23625174: Change user to current_user
Rem    skayoor     11/30/14 - Proj 58196: Change Select priv to Read Priv
Rem    raeburns    11/13/14 - add show errors, remove SET statements
Rem    mkandarp    08/07/14 - 19378040: xmltype columns and nested tables
Rem    surman      01/23/14 - 13922626: Update SQL metadata
Rem    bhammers    10/12/11 - fix sql injection bug 13083026 
Rem    bhammers    05/25/11 - Created
Rem

@@?/rdbms/admin/sqlsessstart.sql

--**************************************************
-- Create xml schema views first because some
-- pl/sql procedures need them
--**************************************************
/*
This view selects all the available namespaces
OWNER - user who owns the namespace
TARGET_NAMESPACE - the targetNamespace 
XML_SCHEMA_URL - the url of the schema
*/
create or replace view DBA_XML_SCHEMA_NAMESPACES
as
select s.xmldata.schema_owner OWNER,
       s.xmldata.target_namespace TARGET_NAMESPACE, 
       s.xmldata.schema_url SCHEMA_URL
  from xdb.xdb$schema s
/
grant select on DBA_XML_SCHEMA_NAMESPACES to select_catalog_role
/
create or replace public synonym DBA_XML_SCHEMA_NAMESPACES for DBA_XML_SCHEMA_NAMESPACES
/

execute CDBView.create_cdbview(false,'SYS','DBA_XML_SCHEMA_NAMESPACES','CDB_XML_SCHEMA_NAMESPACES');
grant select on SYS.CDB_XML_SCHEMA_NAMESPACES to select_catalog_role
/
create or replace public synonym CDB_XML_SCHEMA_NAMESPACES for SYS.CDB_XML_SCHEMA_NAMESPACES
/

/*
This view selects all the available namespaces for the user
OWNER - user who owns the namespace
TARGET_NAMESPACE - the targetNamespace 
XML_SCHEMA_URL - the url of the schema
*/
create or replace view ALL_XML_SCHEMA_NAMESPACES
as
select s.xmldata.schema_owner OWNER,
       s.xmldata.target_namespace TARGET_NAMESPACE, 
       s.xmldata.schema_url SCHEMA_URL
  from xdb.xdb$schema s, all_xml_schemas a
  where s.xmldata.schema_owner = a.owner
  and s.xmldata.schema_url = a.schema_url
/
grant read on ALL_XML_SCHEMA_NAMESPACES to public
/
create or replace public synonym ALL_XML_SCHEMA_NAMESPACES for ALL_XML_SCHEMA_NAMESPACES
/

/*
This view selects all the namaspaces for the current user
TARGET_NAMESPACE - the targetNamespace 
XML_SCHEMA_URL - the url of the schema
*/
create or replace view USER_XML_SCHEMA_NAMESPACES
as
select TARGET_NAMESPACE, SCHEMA_URL
  from DBA_XML_SCHEMA_NAMESPACES
 where NLSSORT(OWNER, 'NLS_SORT=BINARY') = NLSSORT(SYS_CONTEXT('USERENV','CURRENT_USER'), 'NLS_SORT=BINARY')
/
grant read on USER_XML_SCHEMA_NAMESPACES to public
/
create or replace public synonym USER_XML_SCHEMA_NAMESPACES for USER_XML_SCHEMA_NAMESPACES
/

CREATE OR REPLACE TYPE PARENTIDARRAY is VARRAY(20) OF RAW(20);
/

CREATE OR REPLACE PACKAGE PrvtParentChild
 IS
     TYPE refCursor is REF CURSOR;
     
     Function getParentID ( elementID IN varchar2 )
       RETURN PARENTIDARRAY;

     Function sizeArray ( elementID IN varchar2 )
       RETURN NUMBER;
 END;
/
 
CREATE OR REPLACE package body PrvtParentChild
IS

Function getParentIDFromModelID
       ( modelID IN varchar2 )
       RETURN PARENTIDARRAY
    IS
       parentElementID PARENTIDARRAY := PARENTIDARRAY();
       cur0 refCursor;
       pID RAW(200);
       sqlStmtBase varchar2(2000);
       sqlStmt varchar2(2000);
       counter number(38);
       complexID varchar2(200);
       BEGIN
    sqlStmtBase := 'from xdb.xdb$complex_type ct where ( sys_op_r2o(ct.xmldata.all_kid) =';
    sqlStmtBase := sqlStmtBase || Dbms_Assert.Enquote_Literal(modelID);
    sqlStmtBase := sqlStmtBase || ' OR sys_op_r2o(ct.xmldata.choice_kid) = ';
    sqlStmtBase := sqlStmtBase || Dbms_Assert.Enquote_Literal(modelID);
    sqlStmtBase := sqlStmtBase || ' OR sys_op_r2o(ct.xmldata.sequence_kid) = ';
    sqlStmtBase := sqlStmtBase || Dbms_Assert.Enquote_Literal(modelID);
    sqlStmtBase := sqlStmtBase || ' OR sys_op_r2o(ct.xmldata.group_kid) = ';
    sqlStmtBase := sqlStmtBase || Dbms_Assert.Enquote_Literal(modelID);
    sqlStmtBase := sqlStmtBase || ' OR sys_op_r2o(ct.xmldata.complexcontent.extension.sequence_kid) = ';
    sqlStmtBase := sqlStmtBase || Dbms_Assert.Enquote_Literal(modelID);
    sqlStmtBase := sqlStmtBase || ' OR sys_op_r2o(ct.xmldata.complexcontent.extension.choice_kid) = ';
    sqlStmtBase := sqlStmtBase || Dbms_Assert.Enquote_Literal(modelID);
    sqlStmtBase := sqlStmtBase || ' OR sys_op_r2o(ct.xmldata.complexcontent.extension.all_kid) = ';
    sqlStmtBase := sqlStmtBase || Dbms_Assert.Enquote_Literal(modelID);
    sqlStmtBase := sqlStmtBase || ' OR sys_op_r2o(ct.xmldata.complexcontent.extension.group_kid) = ';
    sqlStmtBase := sqlStmtBase || Dbms_Assert.Enquote_Literal(modelID);
    sqlStmtBase := sqlStmtBase || ' OR sys_op_r2o(ct.xmldata.complexcontent.restriction.sequence_kid) = ';
    sqlStmtBase := sqlStmtBase || Dbms_Assert.Enquote_Literal(modelID);
    sqlStmtBase := sqlStmtBase || ' OR sys_op_r2o(ct.xmldata.complexcontent.restriction.choice_kid) = ';
    sqlStmtBase := sqlStmtBase || Dbms_Assert.Enquote_Literal(modelID);
    sqlStmtBase := sqlStmtBase || ' OR sys_op_r2o(ct.xmldata.complexcontent.restriction.all_kid) = ';
    sqlStmtBase := sqlStmtBase || Dbms_Assert.Enquote_Literal(modelID);
    sqlStmtBase := sqlStmtBase || ' OR sys_op_r2o(ct.xmldata.complexcontent.restriction.group_kid) = ';
    sqlStmtBase := sqlStmtBase || Dbms_Assert.Enquote_Literal(modelID);
    sqlStmtBase := sqlStmtBase || ' )';

    sqlStmt := ' select count(*) ' || sqlStmtBase;
    EXECUTE IMMEDIATE sqlStmt INTO counter ;
    IF (counter <> 0) THEN
        sqlStmt := 'select ct.sys_nc_oid$ ' || sqlStmtBase;
        EXECUTE IMMEDIATE sqlStmt INTO complexID ;

        sqlStmt := ' select hextoraw(e.xmldata.property.prop_number) from xdb.xdb$element e where sys_op_r2o(e.xmldata.property.type_ref) = ';
        sqlStmt := sqlStmt || Dbms_Assert.Enquote_Literal(complexID);
        sqlStmt := sqlStmt ;
        counter := 1;
        OPEN cur0 FOR sqlStmt;
        LOOP
             FETCH cur0 INTO pID;
             EXIT WHEN cur0%NOTFOUND;
             parentElementID.extend;
             parentElementID(counter) := pID;
             counter := counter + 1;
        END LOOP;
        CLOSE cur0;
        RETURN parentElementID;
    ELSE
       RETURN NULL;
    END IF;

      
    RETURN parentElementID;
    EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
    END;  
    
Function getParentIDFromGroupID
       ( groupID IN varchar2 )
       RETURN PARENTIDARRAY
    IS
       modelID varchar2(200);
       complexID varchar2(200);
       counter number(38);
       sqlStmtBase varchar2(2000);
       sqlStmt varchar2(2000);
       seqKid boolean := FALSE;
       choiceKid boolean := FALSE;
       allKid boolean := FALSE;
       kidClause varchar2(100);
       elementID varchar2(200);
       parentElementID PARENTIDARRAY := PARENTIDARRAY();
       cur0 refCursor;
       pID RAW(200);
    BEGIN
    counter := 0;
       -- Get the reference ID from the def ID
       select count(*) INTO counter from xdb.xdb$group_ref rg, xdb.xdb$group_def dg where ref(dg) = rg.xmldata.groupref_ref and dg.sys_nc_oid$= groupID;
       IF (counter <> 0) THEN
          select rg.sys_nc_oid$ INTO elementID from xdb.xdb$group_ref rg, xdb.xdb$group_def dg where ref(dg) = rg.xmldata.groupref_ref and dg.sys_nc_oid$= groupID;
       ELSE
          RETURN NULL;
       END IF;
       -- choice
      sqlStmtBase := 'from xdb.xdb$choice_model sm, table(sm.xmldata.groups) t where sys_op_r2o(t.column_value) = ';
      sqlStmtBase := sqlStmtBase || Dbms_Assert.Enquote_Literal(elementID);
      sqlStmt := ' select count(*) ' || sqlStmtBase;
       EXECUTE IMMEDIATE sqlStmt INTO counter ;
       IF ( counter <> 0 ) THEN
           sqlStmt := ' select sm.sys_nc_oid$ ' || sqlStmtBase;
           EXECUTE IMMEDIATE sqlStmt INTO modelID ;
           choiceKid := TRUE;
       ELSE
      sqlStmtBase := 'from xdb.xdb$sequence_model sm, table(sm.xmldata.groups) t where sys_op_r2o(t.column_value) = ';
      sqlStmtBase := sqlStmtBase || Dbms_Assert.Enquote_Literal(elementID);
      sqlStmt := ' select count(*) ' || sqlStmtBase;
       EXECUTE IMMEDIATE sqlStmt INTO counter ;
          IF ( counter <> 0 ) THEN

           sqlStmt := ' select sm.sys_nc_oid$ ' || sqlStmtBase;
           EXECUTE IMMEDIATE sqlStmt INTO modelID ;
            seqKid := TRUE;
          ELSE
      sqlStmtBase := 'from xdb.xdb$all_model sm, table(sm.xmldata.groups) t where sys_op_r2o(t.column_value) = ';
      sqlStmtBase := sqlStmtBase || Dbms_Assert.Enquote_Literal(elementID);
      sqlStmt := ' select count(*) ' || sqlStmtBase;
            IF ( counter <> 0 ) THEN

           sqlStmt := ' select sm.sys_nc_oid$ ' || sqlStmtBase;
           EXECUTE IMMEDIATE sqlStmt INTO modelID ;
                allKid := TRUE;
            ELSE
               -- could be a direct child
    sqlStmtBase := 'from xdb.xdb$complex_type ct where ( ';
    sqlStmtBase := sqlStmtBase || '  sys_op_r2o(ct.xmldata.group_kid) = ';
    sqlStmtBase := sqlStmtBase || Dbms_Assert.Enquote_Literal(elementID);
    sqlStmtBase := sqlStmtBase || ' OR sys_op_r2o(ct.xmldata.complexcontent.extension.group_kid) = ';
    sqlStmtBase := sqlStmtBase || Dbms_Assert.Enquote_Literal(elementID);
    sqlStmtBase := sqlStmtBase || ' OR sys_op_r2o(ct.xmldata.complexcontent.restriction.group_kid) = ';
    sqlStmtBase := sqlStmtBase || Dbms_Assert.Enquote_Literal(elementID);
    sqlStmtBase := sqlStmtBase || ' )';

    sqlStmt := ' select count(*) ' || sqlStmtBase;
    DBMS_OUTPUT.PUT_LINE ( sqlStmt);         
    EXECUTE IMMEDIATE sqlStmt INTO counter ;
    IF (counter <> 0) THEN
        sqlStmt := 'select ct.sys_nc_oid$ ' || sqlStmtBase;
        EXECUTE IMMEDIATE sqlStmt INTO complexID ;

        sqlStmt := ' select hextoraw(e.xmldata.property.prop_number) from xdb.xdb$element e where sys_op_r2o(e.xmldata.property.type_ref) = ';
        sqlStmt := sqlStmt || Dbms_Assert.Enquote_Literal(complexID);
        sqlStmt := sqlStmt ;

        counter := 1;
        OPEN cur0 FOR sqlStmt;
        LOOP
             FETCH cur0 INTO pID;
             EXIT WHEN cur0%NOTFOUND;
             parentElementID.extend;
             parentElementID(counter) := pID;
             counter := counter + 1;
        END LOOP;
        CLOSE cur0;
        RETURN parentElementID;
    ELSE
       RETURN NULL;
    END IF;
            END IF;
        END IF;
       END IF;
       
       sqlStmtBase := '';
       WHILE TRUE
       LOOP

            IF (seqKid = TRUE) THEN kidClause := 'sequence_kids';
            ELSIF (choiceKid = TRUE) THEN kidClause := 'choice_kids';
            ELSE RETURN getParentIDFromModelID(modelID);
            END IF;
           
            counter := 0;
            sqlStmtBase := 'table(sm.xmldata.' || kidClause || ')t where sys_op_r2o(t.column_value) = ';
            sqlStmtBase := sqlStmtBase || Dbms_Assert.Enquote_Literal(modelID);
            sqlStmt := 'select count(*) from xdb.xdb$choice_model sm, ' || sqlStmtBase;
            EXECUTE IMMEDIATE sqlStmt INTO counter  ;
            IF (counter <> 0) THEN
              sqlStmt := 'select sm.sys_nc_oid$ from xdb.xdb$choice_model sm, ' || sqlStmtBase;
              EXECUTE IMMEDIATE sqlStmt INTO modelID ;
              choicekid := TRUE; seqKid := FALSE; allKid := FALSE;
            ELSE
              sqlStmt := 'select count(*)   from xdb.xdb$sequence_model sm, ' || sqlStmtBase;
              EXECUTE IMMEDIATE sqlStmt INTO counter;
              IF (counter <> 0) THEN
                 sqlStmt := 'select sm.sys_nc_oid$  from xdb.xdb$sequence_model sm, ' || sqlStmtBase;
                 EXECUTE IMMEDIATE sqlStmt INTO modelID ;
                 choicekid := FALSE; seqKid := TRUE; allKid := FALSE;
              ELSE
                 sqlStmt := 'select count(*)  from xdb.xdb$all_model sm, ' || sqlStmtBase;
                 EXECUTE IMMEDIATE sqlStmt INTO counter ;
                 IF (counter <> 0) THEN
                    sqlStmt := 'select sm.sys_nc_oid$   from xdb.xdb$all_model sm, ' || sqlStmtBase;
                    EXECUTE IMMEDIATE sqlStmt INTO modelID;
                    choicekid := FALSE; seqKid := FALSE; allKid := TRUE;
                 ELSE -- group
                       RETURN getParentIDFromModelID(modelID);
                 END IF;
              END IF;
           END IF;
       END LOOP;

    RETURN NULL;
    EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
END;

Function getParentID
       ( elementID IN varchar2 )
       RETURN PARENTIDARRAY
    IS
       modelID varchar2(200);
       complexID varchar2(200);
       counter number(38);
       sqlStmtBase varchar2(2000);
       sqlStmt varchar2(2000);

       seqKid boolean := FALSE;
       choiceKid boolean := FALSE;
       allKid boolean := FALSE;
       kidClause varchar2(100);
    BEGIN
    counter := 0;
       -- choice
       select count(*) INTO counter from xdb.xdb$element e, xdb.xdb$choice_model sm, 
       table(sm.xmldata.elements)t where ref(e) = t.column_value and e.xmldata.property.prop_number = elementID ;
       IF ( counter <> 0 ) THEN
           select sm.sys_nc_oid$ INTO modelID from xdb.xdb$element e, xdb.xdb$choice_model sm, table(sm.xmldata.elements)t where 
           ref(e) = t.column_value and e.xmldata.property.prop_number =  elementID ;
           choiceKid := TRUE;
       ELSE
          -- sequence
          select count(*) INTO counter from xdb.xdb$element e, xdb.xdb$sequence_model sm, 
          table(sm.xmldata.elements)t where ref(e) = t.column_value and e.xmldata.property.prop_number = elementID ;
          IF ( counter <> 0 ) THEN
            select sm.sys_nc_oid$ INTO modelID from xdb.xdb$element e, xdb.xdb$sequence_model sm, table(sm.xmldata.elements)t where 
            ref(e) = t.column_value and e.xmldata.property.prop_number =  elementID ;
            seqKid := TRUE;
          ELSE
            -- all
            select count(*) INTO counter from xdb.xdb$element e, xdb.xdb$all_model sm, 
            table(sm.xmldata.elements)t where ref(e) = t.column_value and e.xmldata.property.prop_number =  elementID ;
            IF ( counter <> 0 ) THEN
                select sm.sys_nc_oid$ INTO modelID from xdb.xdb$element e, xdb.xdb$all_model sm, table(sm.xmldata.elements)t where 
                ref(e) = t.column_value and e.xmldata.property.prop_number =  elementID ;
                allKid := TRUE;
            ELSE
               RETURN NULL;
            END IF;
        END IF;
       END IF;

       WHILE TRUE
       LOOP
            IF (seqKid = TRUE) THEN kidClause := 'sequence_kids';
            ELSIF (choiceKid = TRUE) THEN kidClause := 'choice_kids';
            ELSE RETURN getParentIDFromModelID(modelID);
            END IF;
           
            counter := 0;
            sqlStmtBase := 'table(sm.xmldata.' || kidClause || ')t where sys_op_r2o(t.column_value) = ';
            sqlStmtBase := sqlStmtBase ||  Dbms_Assert.Enquote_Literal(modelID);   
            sqlStmt := 'select count(*) from xdb.xdb$choice_model sm, ' || sqlStmtBase;
            EXECUTE IMMEDIATE sqlStmt INTO counter  ;
            IF (counter <> 0) THEN
              sqlStmt := 'select sm.sys_nc_oid$ from xdb.xdb$choice_model sm, ' || sqlStmtBase;
              EXECUTE IMMEDIATE sqlStmt INTO modelID ;
              choicekid := TRUE; seqKid := FALSE; allKid := FALSE;
            ELSE
              sqlStmt := 'select count(*)   from xdb.xdb$sequence_model sm, ' || sqlStmtBase;
              EXECUTE IMMEDIATE sqlStmt INTO counter;
              IF (counter <> 0) THEN
                 sqlStmt := 'select sm.sys_nc_oid$  from xdb.xdb$sequence_model sm, ' || sqlStmtBase;
                 EXECUTE IMMEDIATE sqlStmt INTO modelID ;
                 choicekid := FALSE; seqKid := TRUE; allKid := FALSE;
              ELSE
                 sqlStmt := 'select count(*)  from xdb.xdb$all_model sm, ' || sqlStmtBase;
                 EXECUTE IMMEDIATE sqlStmt INTO counter ;
                 IF (counter <> 0) THEN
                    sqlStmt := 'select sm.sys_nc_oid$   from xdb.xdb$all_model sm, ' || sqlStmtBase;
                    EXECUTE IMMEDIATE sqlStmt INTO modelID;
                    choicekid := FALSE; seqKid := FALSE; allKid := TRUE;
                 ELSE -- group
                    IF (seqKid = TRUE) THEN kidClause := 'sequence_kid';
                    ELSIF (choiceKid = TRUE) THEN kidClause := 'choice_kid';
                    ELSE kidClause := 'all_kid';
                    END IF;
                    sqlStmtBase := '  from xdb.xdb$group_def sm where sys_op_r2o(sm.xmldata. ' || kidClause || ') =';
                    sqlStmtBase := sqlStmtBase || Dbms_Assert.Enquote_Literal(modelID);
                    sqlStmt := 'select count(*) ' || sqlStmtBase;
                    EXECUTE IMMEDIATE sqlStmt INTO counter ;
                    IF (counter <> 0) THEN
                       sqlStmt := 'select sm.sys_nc_oid$ ' || sqlStmtBase;
                       EXECUTE IMMEDIATE sqlStmt INTO modelID;
                       RETURN getParentIDFromGroupID(modelID);
                    ELSE
                       RETURN getParentIDFromModelID(modelID);
                    END IF;
                 END IF;
              END IF;
           END IF;
       END LOOP;

    RETURN NULL;
    EXCEPTION
    WHEN OTHERS THEN
       RETURN NULL;
END;

  Function sizeArray ( elementID IN varchar2 )
       RETURN NUMBER
  IS
   p parentidarray;
  BEGIN
    p := PrvtParentChild.getparentID(elementID);
    IF (p IS NULL) THEN
       RETURN 0;
    ELSE
       RETURN p.count;
    END IF;
  END;
END;
/

show errors

/*
This view selects all the elements.
The properties of the element are selected from the xmldata properties.
The prop number assigned to the element is used as the unique 
identifier for the element. 
This unique identifier helps us to traverse the xml document.
The query is written as union of 4 separate queries. 
The first three queries helps to select 
the children whose content model is sequence/choice/all respectively. 
The final query helps to select the root elements.
To select the parent element id, a self join is made with the 
xdb$element table. For a particular element its type can be determined by the
using the type_ref column. Every complex type stores the content model of its
children which in turn stores the references of the child element. 
For each element, its parent element id is determined by joining it 
with the content model of the parent elements.
OWNER - the user who owns the element
XML_SCHEMA_URL - the url of schema within which the element exists
TARGET_NAMESPACE - the namespace of the element
ELEMENT_NAME - name of the element
TYPE_NAME - name of the type of the element
GLOBAL - is 1 if the element is global else 0.
ELEMENT - the actual xml type of the element
SQL_INLINE - xdb annotation value for sqlInline
SQL_TYPE - xdb annotation value for sqlType
SQL_SCHEMA - xdb annotation value for sqlSchema
DEFAULT_TABLE - xdb annotation value for default table
SQL_NAME - xdb annotation value for sqlName
SQL_COL_TYPE - xdb annotation value for sqlColType
MAINTAIN_DOM - xdb annotation for maintain dom
MAINTAIN_ORDER - xdb annotation for maintain order
ELEMENT_ID - unique identifier for the element.
PARENT_ELEMENT_ID - identies the parent of the element
*/
create or replace view DBA_XML_SCHEMA_ELEMENTS
as
(select s.xmldata.schema_owner AS OWNER,
       s.xmldata.schema_url AS SCHEMA_URL,
       s.xmldata.target_namespace AS TARGET_NAMESPACE, 
       (case
          when e.xmldata.property.name IS NULL 
          then
             e.xmldata.property.propref_name.name 
          else
             e.xmldata.property.name 
          end
       )AS ELEMENT_NAME, 
       (case
          when e.xmldata.property.name IS NULL 
          then
              1
          else
             0
          end
       )AS IS_REF, 
       e.xmldata.property.typename.name AS TYPE_NAME,
       e.xmldata.property.global AS GLOBAL,
       value(e) AS ELEMENT,
       e.xmldata.sql_inline AS SQL_INLINE,
       e.xmldata.property.sqltype AS SQL_TYPE,
       e.xmldata.property.sqlschema AS SQL_SCHEMA,
       e.xmldata.default_table AS DEFAULT_TABLE,
       e.xmldata.property.sqlname AS SQL_NAME,
       e.xmldata.property.sqlcolltype AS SQL_COL_TYPE,
       e.xmldata.maintain_dom AS MAINTAIN_DOM,
       e.xmldata.maintain_order AS MAINTAIN_ORDER,
       hextoraw(e.xmldata.property.prop_number) AS ELEMENT_ID,
       t.column_value AS PARENT_ELEMENT_ID
  from xdb.xdb$schema s, xdb.xdb$element e,  table( PrvtParentChild.getParentID(e.xmldata.property.prop_number)) t
 where sys_op_r2o(e.xmldata.property.parent_schema) = s.sys_nc_oid$  and PrvtParentChild.sizeArray(e.xmldata.property.prop_number) <> 0
 UNION ALL
 select s.xmldata.schema_owner AS OWNER,
       s.xmldata.schema_url AS SCHEMA_URL,
       s.xmldata.target_namespace AS TARGET_NAMESPACE, 
       (case
          when e.xmldata.property.name IS NULL 
          then
             e.xmldata.property.propref_name.name 
          else
             e.xmldata.property.name 
          end
       )AS ELEMENT_NAME, 
       (case
          when e.xmldata.property.name IS NULL 
          then
              1
          else
             0
          end
       )AS IS_REF, 
       e.xmldata.property.typename.name AS TYPE_NAME,
       e.xmldata.property.global AS GLOBAL,
       value(e) AS ELEMENT,
       e.xmldata.sql_inline AS SQL_INLINE,
       e.xmldata.property.sqltype AS SQL_TYPE,
       e.xmldata.property.sqlschema AS SQL_SCHEMA,
       e.xmldata.default_table AS DEFAULT_TABLE,
       e.xmldata.property.sqlname AS SQL_NAME,
       e.xmldata.property.sqlcolltype AS SQL_COL_TYPE,
       e.xmldata.maintain_dom AS MAINTAIN_DOM,
       e.xmldata.maintain_order AS MAINTAIN_ORDER,
       hextoraw(e.xmldata.property.prop_number) AS ELEMENT_ID,
       NULL AS PARENT_ELEMENT_ID
  from xdb.xdb$schema s, xdb.xdb$element e
 where sys_op_r2o(e.xmldata.property.parent_schema) = s.sys_nc_oid$
 and PrvtParentChild.sizeArray(e.xmldata.property.prop_number) = 0
) 
/

grant select on DBA_XML_SCHEMA_ELEMENTS to select_catalog_role
/
create or replace public synonym DBA_XML_SCHEMA_ELEMENTS for DBA_XML_SCHEMA_ELEMENTS
/

execute CDBView.create_cdbview(false,'SYS','DBA_XML_SCHEMA_ELEMENTS','CDB_XML_SCHEMA_ELEMENTS');
grant select on SYS.CDB_XML_SCHEMA_ELEMENTS to select_catalog_role
/
create or replace public synonym CDB_XML_SCHEMA_ELEMENTS for SYS.CDB_XML_SCHEMA_ELEMENTS
/


/*
This view selects all the elements accessible to the current user.
The properties of the element are selected from the xmldata properties.
The prop number assigned to the element is used as the unique identifier 
for the element. 
This unique identifier helps us to traverse the xml document.
The query is written as union of 4 separate queries. 
The first three queries helps to select the children whose content model is 
sequence/choice/all respectively. 
The final query helps to select the root elements.
To select the parent element id, a self join is made with the 
xdb$element table.For a particular element its type can be determined by the
using the type_ref column. Every complex type stores the content model of its 
children which in turn stores the references of the child element. 
For each element, its parent element id is determined by joining it with 
the content model of the parent elements.
OWNER - the user who owns the element
XML_SCHEMA_URL - the url of schema within which the element exists
TARGET_NAMESPACE - the namespace of the element
ELEMENT_NAME - name of the element
TYPE_NAME - name of the type of the element
GLOBAL - is 1 if the element is global else 0.
ELEMENT - the actual xml type of the element
SQL_INLINE - xdb annotation value for sqlInline
SQL_TYPE - xdb annotation value for sqlType
SQL_SCHEMA - xdb annotation value for sqlSchema
DEFAULT_TABLE - xdb annotation value for default table
SQL_NAME - xdb annotation value for sqlName
SQL_COL_TYPE - xdb annotation value for sqlColType
MAINTAIN_DOM - xdb annotation for maintain dom
MAINTAIN_ORDER - xdb annotation for maintain order
ELEMENT_ID - unique identifier for the element.
PARENT_ELEMENT_ID - identies the parent of the element
*/
create or replace view ALL_XML_SCHEMA_ELEMENTS
as
(select s.xmldata.schema_owner AS OWNER,
       s.xmldata.schema_url AS SCHEMA_URL,
       s.xmldata.target_namespace AS TARGET_NAMESPACE, 
       (case
          when e.xmldata.property.name IS NULL 
          then
             e.xmldata.property.propref_name.name 
          else
             e.xmldata.property.name 
          end
       )AS ELEMENT_NAME, 
       (case
          when e.xmldata.property.name IS NULL 
          then
              1
          else
             0
          end
       )AS IS_REF, 
       e.xmldata.property.typename.name AS TYPE_NAME,
       e.xmldata.property.global AS GLOBAL,
       value(e) AS ELEMENT,
       e.xmldata.sql_inline AS SQL_INLINE,
       e.xmldata.property.sqltype AS SQL_TYPE,
       e.xmldata.property.sqlschema AS SQL_SCHEMA,
       e.xmldata.default_table AS DEFAULT_TABLE,
       e.xmldata.property.sqlname AS SQL_NAME,
       e.xmldata.property.sqlcolltype AS SQL_COL_TYPE,
       e.xmldata.maintain_dom AS MAINTAIN_DOM,
       e.xmldata.maintain_order AS MAINTAIN_ORDER,
       hextoraw(e.xmldata.property.prop_number) AS ELEMENT_ID,
       t.column_value AS PARENT_ELEMENT_ID
  from xdb.xdb$schema s, xdb.xdb$element e, all_xml_schemas a, 
       table( PrvtParentChild.getParentID(e.xmldata.property.prop_number)) t
 where sys_op_r2o(e.xmldata.property.parent_schema) = s.sys_nc_oid$ and
       s.xmldata.schema_owner = a.owner and 
       s.xmldata.schema_url = a.schema_url and
       PrvtParentChild.sizeArray(e.xmldata.property.prop_number) <> 0
UNION ALL
select s.xmldata.schema_owner AS OWNER,
       s.xmldata.schema_url AS SCHEMA_URL,
       s.xmldata.target_namespace AS TARGET_NAMESPACE, 
       (case
          when e.xmldata.property.name IS NULL 
          then
             e.xmldata.property.propref_name.name 
          else
             e.xmldata.property.name 
          end
       )AS ELEMENT_NAME, 
       (case
          when e.xmldata.property.name IS NULL 
          then
              1
          else
             0
          end
       )AS IS_REF, 
       e.xmldata.property.typename.name AS TYPE_NAME,
       e.xmldata.property.global AS GLOBAL,
       value(e) AS ELEMENT,
       e.xmldata.sql_inline AS SQL_INLINE,
       e.xmldata.property.sqltype AS SQL_TYPE,
       e.xmldata.property.sqlschema AS SQL_SCHEMA,
       e.xmldata.default_table AS DEFAULT_TABLE,
       e.xmldata.property.sqlname AS SQL_NAME,
       e.xmldata.property.sqlcolltype AS SQL_COL_TYPE,
       e.xmldata.maintain_dom AS MAINTAIN_DOM,
       e.xmldata.maintain_order AS MAINTAIN_ORDER,
       hextoraw(e.xmldata.property.prop_number) AS ELEMENT_ID,
       NULL AS PARENT_ELEMENT_ID
  from xdb.xdb$schema s, xdb.xdb$element e, all_xml_schemas a
 where sys_op_r2o(e.xmldata.property.parent_schema) = s.sys_nc_oid$ and
       s.xmldata.schema_owner = a.owner and 
       s.xmldata.schema_url = a.schema_url and
       PrvtParentChild.sizeArray(e.xmldata.property.prop_number) = 0
) 
/
grant read on ALL_XML_SCHEMA_ELEMENTS to public
/
create or replace public synonym ALL_XML_SCHEMA_ELEMENTS for ALL_XML_SCHEMA_ELEMENTS
/


/*
This view selects all the  elements for the current user
XML_SCHEMA_URL - the url of schema within which the element exists
TARGET_NAMESPACE - the namespace of the element
ELEMENT_NAME - name of the element
TYPE_NAME - name of the type of the element
GLOBAL - is 1 if the element is global else 0.
ELEMENT - the actual xml type of the element
SQL_INLINE - xdb annotation value for sqlInline
SQL_TYPE - xdb annotation value for sqlType
SQL_SCHEMA - xdb annotation value for sqlSchema
DEFAULT_TABLE - xdb annotation value for default table
SQL_NAME - xdb annotation value for sqlName
SQL_COL_TYPE - xdb annotation value for sqlColType
MAINTAIN_DOM - xdb annotation for maintain dom
MAINTAIN_ORDER - xdb annotation for maintain order
ELEMENT_ID - unique identifier for the element.
PARENT_ELEMENT_ID - identies the parent of the element
*/
create or replace view USER_XML_SCHEMA_ELEMENTS
as
select SCHEMA_URL, TARGET_NAMESPACE, ELEMENT_NAME,IS_REF, TYPE_NAME, GLOBAL, 
       ELEMENT, SQL_INLINE,SQL_TYPE, SQL_SCHEMA, DEFAULT_TABLE, SQL_NAME, 
SQL_COL_TYPE,MAINTAIN_DOM,MAINTAIN_ORDER,ELEMENT_ID,PARENT_ELEMENT_ID
  from DBA_XML_SCHEMA_ELEMENTS
 where NLSSORT(OWNER, 'NLS_SORT=BINARY') = NLSSORT(SYS_CONTEXT('USERENV','CURRENT_USER'), 'NLS_SORT=BINARY')
/
grant read on USER_XML_SCHEMA_ELEMENTS to public
/
create or replace public synonym USER_XML_SCHEMA_ELEMENTS for USER_XML_SCHEMA_ELEMENTS 
/


/*
This view selects all members of the substitution group
OWNER - the user who owns the element
XML_SCHEMA_URL - the url of schema within which the element exists
TARGET_NAMESPACE - the namespace of the element
ELEMENT_NAME - name of the element
ELEMENT - the actual xml type of the element
HEAD_OWNER - the user who owns the head element for the current element
HEAD_SCHEMA_URL - the url of schema within which the head element exists
HEAD_TARGET_NAMESPACE - the namespace of the head element
HEAD_ELEMENT_NAME - name of the head element
HEAD_ELEMENT - the actual xml type of the head element
*/
create or replace view DBA_XML_SCHEMA_SUBSTGRP_MBRS
as
select s.xmldata.schema_owner OWNER,
       s.xmldata.schema_url SCHEMA_URL,
       s.xmldata.target_namespace TARGET_NAMESPACE, 
       e.xmldata.property.name ELEMENT_NAME, 
       value(e) ELEMENT,
       hs.xmldata.schema_owner HEAD_OWNER,
       hs.xmldata.schema_url HEAD_SCHEMA_URL,
       hs.xmldata.target_namespace HEAD_TARGET_NAMESPACE, 
       he.xmldata.property.name HEAD_ELEMENT_NAME, 
       value(he) HEAD_ELEMENT
  from xdb.xdb$schema s, xdb.xdb$schema hs, xdb.xdb$element e, 
       xdb.xdb$element he
 where sys_op_r2o(e.xmldata.property.parent_schema) = s.sys_nc_oid$
   and e.xmldata.property.global = hexToRaw('01')
   and he.sys_nc_oid$ = sys_op_r2o(e.xmldata.HEAD_ELEM_REF)
   and sys_op_r2o(he.xmldata.property.parent_schema) = hs.sys_nc_oid$;
/
grant select on DBA_XML_SCHEMA_SUBSTGRP_MBRS to select_catalog_role
/
create or replace public synonym DBA_XML_SCHEMA_SUBSTGRP_MBRS 
    for DBA_XML_SCHEMA_SUBSTGRP_MBRS
/

execute CDBView.create_cdbview(false,'SYS','DBA_XML_SCHEMA_SUBSTGRP_MBRS','CDB_XML_SCHEMA_SUBSTGRP_MBRS');
grant select on SYS.CDB_XML_SCHEMA_SUBSTGRP_MBRS to select_catalog_role
/
create or replace public synonym CDB_XML_SCHEMA_SUBSTGRP_MBRS for SYS.CDB_XML_SCHEMA_SUBSTGRP_MBRS
/


/*
This view selects all members of the substitution group 
accessible to the current user
OWNER - the user who owns the element
XML_SCHEMA_URL - the url of schema within which the element exists
TARGET_NAMESPACE - the namespace of the element
ELEMENT_NAME - name of the element
ELEMENT - the actual xml type of the element
HEAD_OWNER - the user who owns the head element for the current element
HEAD_SCHEMA_URL - the url of schema within which the head element exists
HEAD_TARGET_NAMESPACE - the namespace of the head element
HEAD_ELEMENT_NAME - name of the head element
HEAD_ELEMENT - the actual xml type of the head element
*/
create or replace view ALL_XML_SCHEMA_SUBSTGRP_MBRS
as
select s.xmldata.schema_owner OWNER,
       s.xmldata.schema_url SCHEMA_URL,
       s.xmldata.target_namespace TARGET_NAMESPACE, 
       e.xmldata.property.name ELEMENT_NAME, 
       value(e) ELEMENT,
       hs.xmldata.schema_owner HEAD_OWNER,
       hs.xmldata.schema_url HEAD_SCHEMA_URL,
       hs.xmldata.target_namespace HEAD_TARGET_NAMESPACE, 
       he.xmldata.property.name HEAD_ELEMENT_NAME, 
       value(he) HEAD_ELEMENT
  from xdb.xdb$schema s, xdb.xdb$schema hs, xdb.xdb$element e, 
       xdb.xdb$element he, 
all_xml_schemas a
 where sys_op_r2o(e.xmldata.property.parent_schema) = s.sys_nc_oid$
   and s.xmldata.schema_owner = a.owner 
   and s.xmldata.schema_url = a.schema_url
   and e.xmldata.property.global = hexToRaw('01')
   and he.sys_nc_oid$ = sys_op_r2o(e.xmldata.HEAD_ELEM_REF)
   and sys_op_r2o(he.xmldata.property.parent_schema) = hs.sys_nc_oid$;
/
grant read on ALL_XML_SCHEMA_SUBSTGRP_MBRS to public
/
create or replace public synonym ALL_XML_SCHEMA_SUBSTGRP_MBRS 
    for ALL_XML_SCHEMA_SUBSTGRP_MBRS
/


/*
This view selects all members of the substitution group for the current user
XML_SCHEMA_URL - the url of schema within which the element exists
TARGET_NAMESPACE - the namespace of the element
ELEMENT_NAME - name of the element
ELEMENT - the actual xml type of the element
HEAD_OWNER - the user who owns the head element for the current element
HEAD_SCHEMA_URL - the url of schema within which the head element exists
HEAD_TARGET_NAMESPACE - the namespace of the head element
HEAD_ELEMENT_NAME - name of the head element
HEAD_ELEMENT - the actual xml type of the head element
*/
create or replace view USER_XML_SCHEMA_SUBSTGRP_MBRS
as
select SCHEMA_URL, TARGET_NAMESPACE, ELEMENT_NAME, ELEMENT, HEAD_OWNER, 
       HEAD_SCHEMA_URL, HEAD_TARGET_NAMESPACE, HEAD_ELEMENT_NAME, 
       HEAD_ELEMENT
  from DBA_XML_SCHEMA_SUBSTGRP_MBRS
  where NLSSORT(OWNER, 'NLS_SORT=BINARY') = NLSSORT(SYS_CONTEXT('USERENV','CURRENT_USER'), 'NLS_SORT=BINARY')  
/
grant read on USER_XML_SCHEMA_SUBSTGRP_MBRS to public
/
create or replace public synonym USER_XML_SCHEMA_SUBSTGRP_MBRS 
    for USER_XML_SCHEMA_SUBSTGRP_MBRS
/

/*
This view selects the heads of all the substitution groups
OWNER - the user who owns the element
XML_SCHEMA_URL - the url of schema within which the element exists
TARGET_NAMESPACE - the namespace of the element
ELEMENT_NAME - name of the element
ELEMENT - the actual xml type of the element
*/
create or replace view DBA_XML_SCHEMA_SUBSTGRP_HEAD
as
select s.xmldata.schema_owner OWNER,
       s.xmldata.schema_url SCHEMA_URL,
       s.xmldata.target_namespace TARGET_NAMESPACE, 
       e.xmldata.property.name ELEMENT_NAME, 
       value(e) ELEMENT
  from xdb.xdb$schema s, xdb.xdb$element e
 where sys_op_r2o(e.xmldata.property.parent_schema) = s.sys_nc_oid$
   and e.xmldata.property.global = hexToRaw('01')
   and ref(e) in ( select distinct se.xmldata.HEAD_ELEM_REF 
 from xdb.xdb$element se where 
se.xmldata.HEAD_ELEM_REF is not null)
/
grant select on DBA_XML_SCHEMA_SUBSTGRP_HEAD to select_catalog_role
/
create or replace public synonym DBA_XML_SCHEMA_SUBSTGRP_HEAD 
    for DBA_XML_SCHEMA_SUBSTGRP_HEAD
/

execute CDBView.create_cdbview(false,'SYS','DBA_XML_SCHEMA_SUBSTGRP_HEAD','CDB_XML_SCHEMA_SUBSTGRP_HEAD');
grant select on SYS.CDB_XML_SCHEMA_SUBSTGRP_HEAD to select_catalog_role
/
create or replace public synonym CDB_XML_SCHEMA_SUBSTGRP_HEAD for SYS.CDB_XML_SCHEMA_SUBSTGRP_HEAD
/


/*
This view selects the heads of all the substitution groups 
accessible to the current user
OWNER - the user who owns the element
XML_SCHEMA_URL - the url of schema within which the element exists
TARGET_NAMESPACE - the namespace of the element
ELEMENT_NAME - name of the element
ELEMENT - the actual xml type of the element
*/
create or replace view ALL_XML_SCHEMA_SUBSTGRP_HEAD
as
select s.xmldata.schema_owner OWNER,
       s.xmldata.schema_url SCHEMA_URL,
       s.xmldata.target_namespace TARGET_NAMESPACE, 
       e.xmldata.property.name ELEMENT_NAME, 
       value(e) ELEMENT
  from xdb.xdb$schema s, xdb.xdb$element e, all_xml_schemas a
 where sys_op_r2o(e.xmldata.property.parent_schema) = s.sys_nc_oid$
   and s.xmldata.schema_owner = a.owner 
   and s.xmldata.schema_url = a.schema_url
   and e.xmldata.property.global = hexToRaw('01')
   and e.sys_nc_oid$ in ( select distinct sys_op_r2o
                         (se.xmldata.HEAD_ELEM_REF)
                          from xdb.xdb$element se 
                          where  se.xmldata.HEAD_ELEM_REF is not null)
/
grant read on ALL_XML_SCHEMA_SUBSTGRP_HEAD to public
/
create or replace public synonym ALL_XML_SCHEMA_SUBSTGRP_HEAD 
    for ALL_XML_SCHEMA_SUBSTGRP_HEAD
/

/*
This view selects the heads of all the substitution groups 
for the current user
XML_SCHEMA_URL - the url of schema within which the element exists
TARGET_NAMESPACE - the namespace of the element
ELEMENT_NAME - name of the element
ELEMENT - the actual xml type of the element
*/
create or replace view USER_XML_SCHEMA_SUBSTGRP_HEAD
as
select SCHEMA_URL, TARGET_NAMESPACE, ELEMENT_NAME, ELEMENT
  from DBA_XML_SCHEMA_SUBSTGRP_HEAD
  where NLSSORT(OWNER, 'NLS_SORT=BINARY') = NLSSORT(SYS_CONTEXT('USERENV','CURRENT_USER'), 'NLS_SORT=BINARY')  
/
grant read on USER_XML_SCHEMA_SUBSTGRP_HEAD to public
/
create or replace public synonym USER_XML_SCHEMA_SUBSTGRP_HEAD 
    for USER_XML_SCHEMA_SUBSTGRP_HEAD
/

/*
This view selects all complex type.
The properties are derived from xmldata properties. 
The xdb annotations for the complex type are derived from the
complex type using xpath. The base type for the element can be 
either NULL/Complex Type/Simple Type. The case 
expression is used to select the appropriate value for the same.
OWNER - the user who owns the type
XML_SCHEMA_URL - the url of schema within which the type exists
TARGET_NAMESPACE - the namespace of the type
COMPLEX_TYPE_NAME - name of the complex type
COMPLEX_TYPE - the actual xmltype of the type
BASE_NAME - Name of the base type to which the complex type refers
MAINTAIN_DOM - xdb annotation for maintainDOM
MAINTAIN_ORDER - xdb annotation for maintainOrder
SQL_TYPE - xdb annotation for sqlType
SQL_SCHEMA - xdb annotation for sqlSchema
DEFAULT_TABLE - xdb annotation for defaultTable
SQL_NAME - xdb annotation for sqlName
SQL_COL_TYPE - xdb annotation for sqlColType
STORE_VARRAY_AS_TABLE - xdb annotation for storeVarrayAsTable
*/
create or replace view DBA_XML_SCHEMA_COMPLEX_TYPES
as
select s.xmldata.schema_owner OWNER,
       s.xmldata.schema_url SCHEMA_URL,
       s.xmldata.target_namespace TARGET_NAMESPACE, 
       ct.xmldata.name COMPLEX_TYPE_NAME, 
       value(ct) COMPLEX_TYPE,
        (case 
        when 
                ct.xmldata.BASE_TYPE IS NULL then NULL 
        when 
                ( select count(1) 
                  from xdb.xdb$simple_type st 
                  where ct.xmldata.BASE_TYPE = ref(st) ) != 0
        then
                ( select st.xmldata.name 
                  from  xdb.xdb$simple_type st 
                  where ct.xmldata.BASE_TYPE = ref(st)  ) 
        else
                ( select ctb.xmldata.name 
                  from xdb.xdb$complex_type ctm, 
                       xdb.xdb$complex_type ctb 
                  where ref(ct)  = ref(ctm) 
                        and ctm.xmldata.BASE_TYPE = ref(ctb)  )   
        end ) BASE_NAME,
        (case 
        when 
                ct.xmldata.BASE_TYPE IS NULL then NULL 
        when 
                ( select count(1) 
                  from xdb.xdb$simple_type st 
                  where ct.xmldata.BASE_TYPE = ref(st) ) != 0
        then
                ( select s.xmldata.schema_url 
                  from  xdb.xdb$simple_type st, xdb.xdb$schema s 
                  where ct.xmldata.BASE_TYPE = ref(st)  
                  and sys_op_r2o(st.xmldata.parent_schema)  = s.sys_nc_oid$) 
        else
                ( select s.xmldata.schema_url 
                  from xdb.xdb$complex_type ctm, 
                       xdb.xdb$complex_type ctb,
                       xdb.xdb$schema s 
                  where ref(ct)  = ref(ctm) 
                        and ctm.xmldata.BASE_TYPE = ref(ctb) and
                        sys_op_r2o(ctb.xmldata.parent_schema)  = s.sys_nc_oid$ )   
        end ) BASE_SCHEMA_URL,
        (case 
        when 
                ct.xmldata.BASE_TYPE IS NULL then NULL 
        when 
                ( select count(1) 
                  from xdb.xdb$simple_type st 
                  where ct.xmldata.BASE_TYPE = ref(st) ) != 0
        then
                ( select s.xmldata.target_namespace 
                  from  xdb.xdb$simple_type st, xdb.xdb$schema s 
                  where ct.xmldata.BASE_TYPE = ref(st)  
                  and sys_op_r2o(st.xmldata.parent_schema)  = s.sys_nc_oid$) 
        else
                ( select s.xmldata.target_namespace 
                  from xdb.xdb$complex_type ctm, 
                       xdb.xdb$complex_type ctb,
                       xdb.xdb$schema s 
                  where ref(ct)  = ref(ctm) 
                        and ctm.xmldata.BASE_TYPE = ref(ctb) and
                        sys_op_r2o(ctb.xmldata.parent_schema)  = s.sys_nc_oid$ )   
        end ) BASE_TARGET_NAMESPACE,
       ct.xmldata.maintain_dom MAINTAIN_DOM,
       ct.xmldata.sqltype SQL_TYPE,
       ct.xmldata.SQLSCHEMA SQL_SCHEMA
  from xdb.xdb$schema s, xdb.xdb$complex_type ct
 where sys_op_r2o(ct.xmldata.parent_schema)  = s.sys_nc_oid$
/
grant select on DBA_XML_SCHEMA_COMPLEX_TYPES to select_catalog_role
/
create or replace public synonym DBA_XML_SCHEMA_COMPLEX_TYPES 
    for DBA_XML_SCHEMA_COMPLEX_TYPES
/

execute CDBView.create_cdbview(false,'SYS','DBA_XML_SCHEMA_COMPLEX_TYPES','CDB_XML_SCHEMA_COMPLEX_TYPES');
grant select on SYS.CDB_XML_SCHEMA_COMPLEX_TYPES to select_catalog_role
/
create or replace public synonym CDB_XML_SCHEMA_COMPLEX_TYPES for SYS.CDB_XML_SCHEMA_COMPLEX_TYPES
/


/*
This view selects all complex type accessible to the current user.
The properties are derived from xmldata properties. 
The xdb annotations for the complex type 
are derived from the complex type using xpath.
The base type for the element can be either NULL/Complex Type/Simple Type.
The case expression is used to select the appropriate value for the same.
OWNER - the user who owns the type
XML_SCHEMA_URL - the url of schema within which the type exists
TARGET_NAMESPACE - the namespace of the type
COMPLEX_TYPE_NAME - name of the complex type
COMPLEX_TYPE - the actual xmltype of the type
BASE_NAME - Name of the base type to which the complex type refers
MAINTAIN_DOM - xdb annotation for maintainDOM
MAINTAIN_ORDER - xdb annotation for maintainOrder
SQL_TYPE - xdb annotation for sqlType
SQL_SCHEMA - xdb annotation for sqlSchema
DEFAULT_TABLE - xdb annotation for defaultTable
SQL_NAME - xdb annotation for sqlName
SQL_COL_TYPE - xdb annotation for sqlColType
STORE_VARRAY_AS_TABLE - xdb annotation for storeVarrayAsTable
*/
create or replace view ALL_XML_SCHEMA_COMPLEX_TYPES
as
select s.xmldata.schema_owner OWNER,
       s.xmldata.schema_url SCHEMA_URL,
       s.xmldata.target_namespace TARGET_NAMESPACE, 
       ct.xmldata.name COMPLEX_TYPE_NAME, 
       value(ct) COMPLEX_TYPE,
        (case 
        when 
                ct.xmldata.BASE_TYPE IS NULL then NULL 
        when 
                ( select count(1) 
                  from xdb.xdb$simple_type st 
                  where ct.xmldata.BASE_TYPE = ref(st) ) != 0
        then
                ( select st.xmldata.name 
                  from  xdb.xdb$simple_type st 
                  where ct.xmldata.BASE_TYPE = ref(st)  ) 
        else
                ( select ctb.xmldata.name 
                  from xdb.xdb$complex_type ctm, 
                       xdb.xdb$complex_type ctb 
                  where ref(ct)  = ref(ctm) 
                        and ctm.xmldata.BASE_TYPE = ref(ctb)  )   
        end ) BASE_NAME,
        (case 
        when 
                ct.xmldata.BASE_TYPE IS NULL then NULL 
        when 
                ( select count(1) 
                  from xdb.xdb$simple_type st 
                  where ct.xmldata.BASE_TYPE = ref(st) ) != 0
        then
                ( select s.xmldata.schema_url 
                  from  xdb.xdb$simple_type st, xdb.xdb$schema s 
                  where ct.xmldata.BASE_TYPE = ref(st)  
                  and sys_op_r2o(st.xmldata.parent_schema)  = s.sys_nc_oid$) 
        else
                ( select s.xmldata.schema_url 
                  from xdb.xdb$complex_type ctm, 
                       xdb.xdb$complex_type ctb,
                       xdb.xdb$schema s 
                  where ref(ct)  = ref(ctm) 
                        and ctm.xmldata.BASE_TYPE = ref(ctb) and
                        sys_op_r2o(ctb.xmldata.parent_schema)  = s.sys_nc_oid$ )   
        end ) BASE_SCHEMA_URL,
        (case 
        when 
                ct.xmldata.BASE_TYPE IS NULL then NULL 
        when 
                ( select count(1) 
                  from xdb.xdb$simple_type st 
                  where ct.xmldata.BASE_TYPE = ref(st) ) != 0
        then
                ( select s.xmldata.target_namespace 
                  from  xdb.xdb$simple_type st, xdb.xdb$schema s 
                  where ct.xmldata.BASE_TYPE = ref(st)  
                  and sys_op_r2o(st.xmldata.parent_schema)  = s.sys_nc_oid$) 
        else
                ( select s.xmldata.target_namespace 
                  from xdb.xdb$complex_type ctm, 
                       xdb.xdb$complex_type ctb,
                       xdb.xdb$schema s 
                  where ref(ct)  = ref(ctm) 
                        and ctm.xmldata.BASE_TYPE = ref(ctb) and
                        sys_op_r2o(ctb.xmldata.parent_schema)  = s.sys_nc_oid$ )   
        end ) BASE_TARGET_NAMESPACE,
       ct.xmldata.maintain_dom MAINTAIN_DOM,
       ct.xmldata.sqltype SQL_TYPE,
       ct.xmldata.SQLSCHEMA SQL_SCHEMA
  from xdb.xdb$schema s, xdb.xdb$complex_type ct,all_xml_schemas a
 where sys_op_r2o(ct.xmldata.parent_schema)  = s.sys_nc_oid$ and
       s.xmldata.schema_owner = a.owner and
       s.xmldata.schema_url = a.schema_url
/
grant read on ALL_XML_SCHEMA_COMPLEX_TYPES to public
/
create or replace public synonym ALL_XML_SCHEMA_COMPLEX_TYPES 
    for ALL_XML_SCHEMA_COMPLEX_TYPES
/

/*
This view selects all complex type for the current user
XML_SCHEMA_URL - the url of schema within which the type exists
TARGET_NAMESPACE - the namespace of the type
COMPLEX_TYPE_NAME - name of the complex type
COMPLEX_TYPE - the actual xmltype of the type
BASE_NAME - Name of the base type to which the complex type refers
MAINTAIN_DOM - xdb annotation for maintainDOM
MAINTAIN_ORDER - xdb annotation for maintainOrder
SQL_TYPE - xdb annotation for sqlType
SQL_SCHEMA - xdb annotation for sqlSchema
DEFAULT_TABLE - xdb annotation for defaultTable
SQL_NAME - xdb annotation for sqlName
SQL_COL_TYPE - xdb annotation for sqlColType
STORE_VARRAY_AS_TABLE - xdb annotation for storeVarrayAsTable
*/
create or replace view USER_XML_SCHEMA_COMPLEX_TYPES
as
select SCHEMA_URL, TARGET_NAMESPACE, COMPLEX_TYPE_NAME, COMPLEX_TYPE,
       BASE_NAME, BASE_SCHEMA_URL, BASE_TARGET_NAMESPACE, MAINTAIN_DOM, SQL_TYPE, SQL_SCHEMA
  from DBA_XML_SCHEMA_COMPLEX_TYPES
  where NLSSORT(OWNER, 'NLS_SORT=BINARY') = NLSSORT(SYS_CONTEXT('USERENV','CURRENT_USER'), 'NLS_SORT=BINARY') 
/
grant read on USER_XML_SCHEMA_COMPLEX_TYPES to public
/
create or replace public synonym USER_XML_SCHEMA_COMPLEX_TYPES 
    for USER_XML_SCHEMA_COMPLEX_TYPES
/

/*
This view selects all simple type.
The properties of the simple element are derived from xmldata properties.
The xdb annotations are derived from the simple type using xpath.
OWNER - the user who owns the type
XML_SCHEMA_URL - the url of schema within which the type exists
TARGET_NAMESPACE - the namespace of the type
SIMPLE_TYPE_NAME - name of the simple type
SIMPLE_TYPE - the actual xmltype of the type
MAINTAIN_DOM - xdb annotation for maintainDOM
SQL_TYPE - xdb annotation for sqlType (not available on 10.2)
SQL_SCHEMA - xdb annotation for sqlSchema
DEFAULT_TABLE - xdb annotation for defaultTable
SQL_NAME - xdb annotation for sqlName
SQL_COL_TYPE - xdb annotation for sqlColType
STORE_VARRAY_AS_TABLE - xdb annotation for storeVarrayAsTable
*/

/* NOTE, For 10.2: View does not contain the column SQLTYPE.*/
DECLARE 
  stmt VARCHAR2(4000);
BEGIN
 
  stmt := '
  create or replace view DBA_XML_SCHEMA_SIMPLE_TYPES
  as
  select s.xmldata.schema_owner OWNER,
       s.xmldata.schema_url SCHEMA_URL,
       s.xmldata.target_namespace TARGET_NAMESPACE, 
       st.xmldata.name SIMPLE_TYPE_NAME, 
       value(st) SIMPLE_TYPE
    from xdb.xdb$schema s, xdb.xdb$simple_type st
   where sys_op_r2o(st.xmldata.parent_schema)  = s.sys_nc_oid$';
   
   execute immediate (stmt);
   exception when others then raise;


END;
/

grant select on DBA_XML_SCHEMA_SIMPLE_TYPES to select_catalog_role
/
create or replace public synonym DBA_XML_SCHEMA_SIMPLE_TYPES 
    for DBA_XML_SCHEMA_SIMPLE_TYPES
/

execute CDBView.create_cdbview(false,'SYS','DBA_XML_SCHEMA_SIMPLE_TYPES','CDB_XML_SCHEMA_SIMPLE_TYPES');
grant select on SYS.CDB_XML_SCHEMA_SIMPLE_TYPES to select_catalog_role
/
create or replace public synonym CDB_XML_SCHEMA_SIMPLE_TYPES for SYS.CDB_XML_SCHEMA_SIMPLE_TYPES
/


/*
This view selects all simple type accessible to the current user.
The properties of the simple element are derived from xmldata properties.
The xdb annotations are derived from the simple type using xpath.
OWNER - the user who owns the type
XML_SCHEMA_URL - the url of schema within which the type exists
TARGET_NAMESPACE - the namespace of the type
SIMPLE_TYPE_NAME - name of the simple type
SIMPLE_TYPE - the actual xmltype of the type
MAINTAIN_DOM - xdb annotation for maintainDOM
SQL_TYPE - xdb annotation for sqlType
SQL_SCHEMA - xdb annotation for sqlSchema
DEFAULT_TABLE - xdb annotation for defaultTable
SQL_NAME - xdb annotation for sqlName
SQL_COL_TYPE - xdb annotation for sqlColType
STORE_VARRAY_AS_TABLE - xdb annotation for storeVarrayAsTable
*/

/* NOTE, For 10.2: View does not contain the column SQLTYPE.*/
DECLARE 
  stmt VARCHAR2(4000);
BEGIN
  
   stmt := '
  create or replace view ALL_XML_SCHEMA_SIMPLE_TYPES
  as
   select s.xmldata.schema_owner OWNER,
       s.xmldata.schema_url SCHEMA_URL,
       s.xmldata.target_namespace TARGET_NAMESPACE, 
       st.xmldata.name SIMPLE_TYPE_NAME, 
       value(st) SIMPLE_TYPE
    from xdb.xdb$schema s, xdb.xdb$simple_type st, all_xml_schemas a
   where sys_op_r2o(st.xmldata.parent_schema)  = s.sys_nc_oid$ and
       s.xmldata.schema_owner = a.owner and
       s.xmldata.schema_url = a.schema_url';

   execute immediate (stmt);
   exception when others then raise;


END;
/


grant read on ALL_XML_SCHEMA_SIMPLE_TYPES to public
/
create or replace public synonym ALL_XML_SCHEMA_SIMPLE_TYPES 
    for ALL_XML_SCHEMA_SIMPLE_TYPES
/



/*
This view selects all simple type for current user
XML_SCHEMA_URL - the url of schema within which the type exists
TARGET_NAMESPACE - the namespace of the type
SIMPLE_TYPE_NAME - name of the simple type
SIMPLE_TYPE - the actual xmltype of the type
MAINTAIN_DOM - xdb annotation for maintainDOM
SQL_TYPE - xdb annotation for sqlType
SQL_SCHEMA - xdb annotation for sqlSchema
DEFAULT_TABLE - xdb annotation for defaultTable
SQL_NAME - xdb annotation for sqlName
SQL_COL_TYPE - xdb annotation for sqlColType
STORE_VARRAY_AS_TABLE - xdb annotation for storeVarrayAsTable
*/

/* NOTE, For 10.2: View does not contain the column SQLTYPE.*/

DECLARE 
  stmt VARCHAR2(4000);
BEGIN
 
    stmt := '
     create or replace view USER_XML_SCHEMA_SIMPLE_TYPES
     as
     select SCHEMA_URL, TARGET_NAMESPACE, SIMPLE_TYPE_NAME, SIMPLE_TYPE
     from DBA_XML_SCHEMA_SIMPLE_TYPES
     where NLSSORT(OWNER, ''NLS_SORT=BINARY'') = NLSSORT(SYS_CONTEXT(''USERENV'',''CURRENT_USER''), ''NLS_SORT=BINARY'')';

  execute immediate (stmt);
  exception when others then raise;


END;
/

grant read on USER_XML_SCHEMA_SIMPLE_TYPES to public
/
create or replace public synonym USER_XML_SCHEMA_SIMPLE_TYPES 
    for USER_XML_SCHEMA_SIMPLE_TYPES
/


/*
This view selects all the  attributes. 
The properties are derived from xmldata properties. 
The element id is the unique identifier used to identify 
the element to which the attribute belongs. The element id relates to the 
dba_user_elements. This helps in traversing the xml document.
OWNER - the user who owns the attribute
XML_SCHEMA_URL - the url of schema within which the attribute exists
TARGET_NAMESPACE - the namespace of the attribute
ATTRIBUTE_NAME - name of the attribute
TYPE_NAME - name of type of the attribute
GLOBAL - is 1 if attribute is global else 0.
ATTRIBUTE - actual xmltype for the attribute
ELEMENT_ID - element id of the element to which the attribute belongs
*/
create or replace view DBA_XML_SCHEMA_ATTRIBUTES
as
select s.xmldata.schema_owner OWNER,
       s.xmldata.schema_url SCHEMA_URL,
       s.xmldata.target_namespace TARGET_NAMESPACE, 
       (case
          when a.xmldata.name IS NULL 
          then
             a.xmldata.propref_name.name 
          else
             a.xmldata.name 
          end
       )AS ATTRIBUTE_NAME, 
       (case
          when a.xmldata.name IS NULL 
          then
             1
          else
             0
          end
       )AS IS_REF, 
       (case
          when a.xmldata.typename.name IS NULL 
          then
              (select a1.xmldata.typename.name from xdb.xdb$attribute a1 where ref(a1)=a.xmldata.propref_ref)
          else
             a.xmldata.typename.name 
          end
       )AS TYPE_NAME,
       a.xmldata.global GLOBAL,
       value(a) ATTRIBUTE,
       hextoraw(e.xmldata.property.prop_number) AS ELEMENT_ID,
       a.xmldata.sqltype AS SQL_TYPE, 
       a.xmldata.sqlname AS SQL_NAME
  from xdb.xdb$schema s, xdb.xdb$attribute a, 
       xdb.xdb$element e, xdb.xdb$complex_type ct, 
       table(ct.xmldata.attributes) att
 where  sys_op_r2o(a.xmldata.parent_schema) = s.sys_nc_oid$ and 
       ref(ct) = e.xmldata.property.type_ref and
       att.column_value = ref(a)
UNION ALL
select s.xmldata.schema_owner OWNER,
       s.xmldata.schema_url SCHEMA_URL,
       s.xmldata.target_namespace TARGET_NAMESPACE, 
       (case
          when a.xmldata.name IS NULL 
          then
             a.xmldata.propref_name.name 
          else
             a.xmldata.name 
          end
       )AS ATTRIBUTE_NAME, 
       (case
          when a.xmldata.name IS NULL 
          then
             1
          else
             0
          end
       )AS IS_REF, 
       (case
          when a.xmldata.typename.name IS NULL 
          then
              (select a1.xmldata.typename.name from xdb.xdb$attribute a1 where ref(a1)=a.xmldata.propref_ref)
          else
             a.xmldata.typename.name 
          end
       )AS TYPE_NAME,
       a.xmldata.global GLOBAL,
       value(a) ATTRIBUTE,
       hextoraw(e.xmldata.property.prop_number) AS ELEMENT_ID,
       a.xmldata.sqltype AS SQL_TYPE, 
       a.xmldata.sqlname AS SQL_NAME
  from xdb.xdb$schema s, xdb.xdb$attribute a, 
       xdb.xdb$element e, xdb.xdb$complex_type ct, 
       table(ct.xmldata.simplecont.restriction.attributes) att
 where  sys_op_r2o(a.xmldata.parent_schema) = s.sys_nc_oid$ and 
       ref(ct) = e.xmldata.property.type_ref and
       att.column_value = ref(a)
UNION ALL
select s.xmldata.schema_owner OWNER,
       s.xmldata.schema_url SCHEMA_URL,
       s.xmldata.target_namespace TARGET_NAMESPACE, 
       (case
          when a.xmldata.name IS NULL 
          then
             a.xmldata.propref_name.name 
          else
             a.xmldata.name 
          end
       )AS ATTRIBUTE_NAME, 
       (case
          when a.xmldata.name IS NULL 
          then
             1
          else
             0
          end
       )AS IS_REF, 
       (case
          when a.xmldata.typename.name IS NULL 
          then
              (select a1.xmldata.typename.name from xdb.xdb$attribute a1 where ref(a1)=a.xmldata.propref_ref)
          else
             a.xmldata.typename.name 
          end
       )AS TYPE_NAME,
       a.xmldata.global GLOBAL,
       value(a) ATTRIBUTE,
       hextoraw(e.xmldata.property.prop_number) AS ELEMENT_ID,
       a.xmldata.sqltype AS SQL_TYPE, 
       a.xmldata.sqlname AS SQL_NAME
  from xdb.xdb$schema s, xdb.xdb$attribute a, 
       xdb.xdb$element e, xdb.xdb$complex_type ct, 
       table(ct.xmldata.simplecont.extension.attributes) att
 where  sys_op_r2o(a.xmldata.parent_schema) = s.sys_nc_oid$ and 
       ref(ct) = e.xmldata.property.type_ref and
       att.column_value = ref(a)
UNION ALL
select s.xmldata.schema_owner OWNER,
       s.xmldata.schema_url SCHEMA_URL,
       s.xmldata.target_namespace TARGET_NAMESPACE, 
       (case
          when a.xmldata.name IS NULL 
          then
             a.xmldata.propref_name.name 
          else
             a.xmldata.name 
          end
       )AS ATTRIBUTE_NAME, 
       (case
          when a.xmldata.name IS NULL 
          then
             1
          else
             0
          end
       )AS IS_REF, 
       (case
          when a.xmldata.typename.name IS NULL 
          then
             ( select a1.xmldata.typename.name from xdb.xdb$attribute a1 where ref(a1)=a.xmldata.propref_ref)
          else
             a.xmldata.typename.name 
          end
       )AS TYPE_NAME,
       a.xmldata.global GLOBAL,
       value(a) ATTRIBUTE,
       NULL AS ELEMENT_ID,
       a.xmldata.sqltype AS SQL_TYPE, 
       a.xmldata.sqlname AS SQL_NAME
   from xdb.xdb$schema s, xdb.xdb$attribute a 
 where  sys_op_r2o(a.xmldata.parent_schema) = s.sys_nc_oid$ and 
       ( 
         (
	   ref(a) NOT IN (select t.column_value from xdb.xdb$complex_type ct,table(ct.xmldata.attributes)t)
           AND
           ref(a) NOT IN (select t.column_value from xdb.xdb$complex_type ct,table(ct.xmldata.simplecont.extension.attributes)t)
           AND
           ref(a) NOT IN (select t.column_value from xdb.xdb$complex_type ct,table(ct.xmldata.simplecont.restriction.attributes)t)
	 )
         OR
         (
           (
             ref(a)  IN (select t.column_value from xdb.xdb$complex_type ct,table(ct.xmldata.attributes)t)
             OR
             ref(a) IN (select t.column_value from xdb.xdb$complex_type ct,table(ct.xmldata.simplecont.extension.attributes)t)
             OR
             ref(a) IN (select t.column_value from xdb.xdb$complex_type ct,table(ct.xmldata.simplecont.restriction.attributes)t)
           )
           and (select ref(ct) from xdb.xdb$complex_type ct,table(ct.xmldata.attributes)t,table(ct.xmldata.simplecont.extension.attributes)t1,table(ct.xmldata.simplecont.restriction.attributes)t2 where
	     ref(a)  = t.column_value
             OR
             ref(a) = t1.column_value
             OR
             ref(a) = t2.column_value
	   ) NOT IN ( select e.xmldata.property.type_ref from xdb.xdb$element e)
         )
       )
/
grant select on DBA_XML_SCHEMA_ATTRIBUTES to select_catalog_role
/
create or replace public synonym DBA_XML_SCHEMA_ATTRIBUTES for DBA_XML_SCHEMA_ATTRIBUTES
/

execute CDBView.create_cdbview(false,'SYS','DBA_XML_SCHEMA_ATTRIBUTES','CDB_XML_SCHEMA_ATTRIBUTES');
grant select on SYS.CDB_XML_SCHEMA_ATTRIBUTES to select_catalog_role
/
create or replace public synonym CDB_XML_SCHEMA_ATTRIBUTES for SYS.CDB_XML_SCHEMA_ATTRIBUTES
/

/*
This view selects all the  attributes accessible to the current user. 
The properties are derived from xmldata properties. 
The element id is the unique identifier used to identify the element 
to which the attribute belongs. The element id relates to the 
dba_user_elements. This helps in traversing the xml document.
OWNER - the user who owns the attribute
XML_SCHEMA_URL - the url of schema within which the attribute exists
TARGET_NAMESPACE - the namespace of the attribute
ATTRIBUTE_NAME - name of the attribute
TYPE_NAME - name of type of the attribute
GLOBAL - is 1 if attribute is global else 0.
ATTRIBUTE - actual xmltype for the attribute
ELEMENT_ID - element id of the element to which the attribute belongs
*/
create or replace view ALL_XML_SCHEMA_ATTRIBUTES
as
select s.xmldata.schema_owner OWNER,
       s.xmldata.schema_url SCHEMA_URL,
       s.xmldata.target_namespace TARGET_NAMESPACE, 
       (case
          when a.xmldata.name IS NULL 
          then
             a.xmldata.propref_name.name 
          else
             a.xmldata.name 
          end
       )AS ATTRIBUTE_NAME, 
       (case
          when a.xmldata.name IS NULL 
          then
             1
          else
             0
          end
       )AS IS_REF, 
       (case
          when a.xmldata.typename.name IS NULL 
          then
              (select a1.xmldata.typename.name from xdb.xdb$attribute a1 where ref(a1)=a.xmldata.propref_ref)
          else
             a.xmldata.typename.name 
          end
       )AS TYPE_NAME,
       a.xmldata.global GLOBAL,
       value(a) ATTRIBUTE,
       hextoraw(e.xmldata.property.prop_number) AS ELEMENT_ID,
       a.xmldata.sqltype AS SQL_TYPE, 
       a.xmldata.sqlname AS SQL_NAME
  from xdb.xdb$schema s, xdb.xdb$attribute a,  all_xml_schemas al, 
       xdb.xdb$element e, xdb.xdb$complex_type ct, 
       table(ct.xmldata.attributes) att
 where  sys_op_r2o(a.xmldata.parent_schema) = s.sys_nc_oid$ and 
       s.xmldata.schema_owner = al.owner and
       s.xmldata.schema_url = al.schema_url and
       ref(ct) = e.xmldata.property.type_ref and
       att.column_value = ref(a)
UNION ALL
select s.xmldata.schema_owner OWNER,
       s.xmldata.schema_url SCHEMA_URL,
       s.xmldata.target_namespace TARGET_NAMESPACE, 
       (case
          when a.xmldata.name IS NULL 
          then
             a.xmldata.propref_name.name 
          else
             a.xmldata.name 
          end
       )AS ATTRIBUTE_NAME, 
       (case
          when a.xmldata.name IS NULL 
          then
             1
          else
             0
          end
       )AS IS_REF, 
       (case
          when a.xmldata.typename.name IS NULL 
          then
              (select a1.xmldata.typename.name from xdb.xdb$attribute a1 where ref(a1)=a.xmldata.propref_ref)
          else
             a.xmldata.typename.name 
          end
       )AS TYPE_NAME,
       a.xmldata.global GLOBAL,
       value(a) ATTRIBUTE,
       hextoraw(e.xmldata.property.prop_number) AS ELEMENT_ID,
       a.xmldata.sqltype AS SQL_TYPE, 
       a.xmldata.sqlname AS SQL_NAME
  from xdb.xdb$schema s, xdb.xdb$attribute a,  all_xml_schemas al, 
       xdb.xdb$element e, xdb.xdb$complex_type ct, 
       table(ct.xmldata.simplecont.restriction.attributes) att
 where  sys_op_r2o(a.xmldata.parent_schema) = s.sys_nc_oid$ and 
       s.xmldata.schema_owner = al.owner and
       s.xmldata.schema_url = al.schema_url and
       ref(ct) = e.xmldata.property.type_ref and
       att.column_value = ref(a)
UNION ALL
select s.xmldata.schema_owner OWNER,
       s.xmldata.schema_url SCHEMA_URL,
       s.xmldata.target_namespace TARGET_NAMESPACE, 
       (case
          when a.xmldata.name IS NULL 
          then
             a.xmldata.propref_name.name 
          else
             a.xmldata.name 
          end
       )AS ATTRIBUTE_NAME, 
       (case
          when a.xmldata.name IS NULL 
          then
             1
          else
             0
          end
       )AS IS_REF, 
       (case
          when a.xmldata.typename.name IS NULL 
          then
              (select a1.xmldata.typename.name from xdb.xdb$attribute a1 where ref(a1)=a.xmldata.propref_ref)
          else
             a.xmldata.typename.name 
          end
       )AS TYPE_NAME,
       a.xmldata.global GLOBAL,
       value(a) ATTRIBUTE,
       hextoraw(e.xmldata.property.prop_number) AS ELEMENT_ID,
       a.xmldata.sqltype AS SQL_TYPE, 
       a.xmldata.sqlname AS SQL_NAME
  from xdb.xdb$schema s, xdb.xdb$attribute a,  all_xml_schemas al, 
       xdb.xdb$element e, xdb.xdb$complex_type ct, 
       table(ct.xmldata.simplecont.extension.attributes) att
 where  sys_op_r2o(a.xmldata.parent_schema) = s.sys_nc_oid$ and 
       s.xmldata.schema_owner = al.owner and
       s.xmldata.schema_url = al.schema_url and
       ref(ct) = e.xmldata.property.type_ref and
       att.column_value = ref(a)
UNION ALL
select s.xmldata.schema_owner OWNER,
       s.xmldata.schema_url SCHEMA_URL,
       s.xmldata.target_namespace TARGET_NAMESPACE, 
       (case
          when a.xmldata.name IS NULL 
          then
             a.xmldata.propref_name.name 
          else
             a.xmldata.name 
          end
       )AS ATTRIBUTE_NAME, 
       (case
          when a.xmldata.name IS NULL 
          then
             1
          else
             0
          end
       )AS IS_REF, 
       (case
          when a.xmldata.typename.name IS NULL 
          then
              (select a1.xmldata.typename.name from xdb.xdb$attribute a1 where ref(a1)=a.xmldata.propref_ref)
          else
             a.xmldata.typename.name 
          end
       )AS TYPE_NAME,
       a.xmldata.global GLOBAL,
       value(a) ATTRIBUTE,
       NULL AS ELEMENT_ID,
       a.xmldata.sqltype AS SQL_TYPE, 
       a.xmldata.sqlname AS SQL_NAME
   from xdb.xdb$schema s, xdb.xdb$attribute a,  all_xml_schemas al 
 where  sys_op_r2o(a.xmldata.parent_schema) = s.sys_nc_oid$ and 
       s.xmldata.schema_owner = al.owner and
       s.xmldata.schema_url = al.schema_url and
       ( 
         (
	   ref(a) NOT IN (select t.column_value from xdb.xdb$complex_type ct,table(ct.xmldata.attributes)t)
           AND
           ref(a) NOT IN (select t.column_value from xdb.xdb$complex_type ct,table(ct.xmldata.simplecont.extension.attributes)t)
           AND
           ref(a) NOT IN (select t.column_value from xdb.xdb$complex_type ct,table(ct.xmldata.simplecont.restriction.attributes)t)
	 )
         OR
         (
           (
             ref(a)  IN (select t.column_value from xdb.xdb$complex_type ct,table(ct.xmldata.attributes)t)
             OR
             ref(a) IN (select t.column_value from xdb.xdb$complex_type ct,table(ct.xmldata.simplecont.extension.attributes)t)
             OR
             ref(a) IN (select t.column_value from xdb.xdb$complex_type ct,table(ct.xmldata.simplecont.restriction.attributes)t)
           )
           and (select ref(ct) from xdb.xdb$complex_type ct,table(ct.xmldata.attributes)t,table(ct.xmldata.simplecont.extension.attributes)t1,table(ct.xmldata.simplecont.restriction.attributes)t2 where
	     ref(a)  = t.column_value
             OR
             ref(a) = t1.column_value
             OR
             ref(a) = t2.column_value
	   ) NOT IN ( select e.xmldata.property.type_ref from xdb.xdb$element e)
         )
       )
/
grant read on ALL_XML_SCHEMA_ATTRIBUTES to public
/
create or replace public synonym ALL_XML_SCHEMA_ATTRIBUTES for ALL_XML_SCHEMA_ATTRIBUTES
/

/*
This view selects all the attributes for the current user
XML_SCHEMA_URL - the url of schema within which the attribute exists
TARGET_NAMESPACE - the namespace of the attribute
ATTRIBUTE_NAME - name of the attribute
TYPE_NAME - name of type of the attribute
GLOBAL - is 1 if attribute is global else 0.
ATTRIBUTE - actual xmltype for the attribute
ELEMENT_ID - element id of the element to which the attribute belongs
*/
create or replace view USER_XML_SCHEMA_ATTRIBUTES
as
select SCHEMA_URL, TARGET_NAMESPACE, ATTRIBUTE_NAME, IS_REF,TYPE_NAME, 
       GLOBAL,ATTRIBUTE, ELEMENT_ID, SQL_TYPE, SQL_NAME
from DBA_XML_SCHEMA_ATTRIBUTES
 where NLSSORT(OWNER, 'NLS_SORT=BINARY') = NLSSORT(SYS_CONTEXT('USERENV','CURRENT_USER'), 'NLS_SORT=BINARY')
/
grant read on USER_XML_SCHEMA_ATTRIBUTES to public
/
create or replace public synonym USER_XML_SCHEMA_ATTRIBUTES for USER_XML_SCHEMA_ATTRIBUTES
/

/*
This view gives all the out of line tables connected to a 
given root table for the same schema.
--Note, this will give the root_table also as a part of table_name.
ROOT_TABLE_NAME  Name of the root table
ROOT_TABLE_OWNER  Owner of the root table.
TABLE_NAME  Name of out of line table.
TABLE_OWNER  Owner of the out of line table.
*/

create or replace view DBA_XML_OUT_OF_LINE_TABLES
as
select d.xmlschema as SCHEMA_URL, --schema URL  
       d.schema_owner as SCHEMA_OWNER,  --schema owner 
       d.table_name as TABLE_NAME, --out of line table name 
       d.owner as TABLE_OWNER --out of line table owner
from   DBA_XML_TABLES d, sys.obj$ o, sys.opqtype$ op, sys.user$ u
where
o.owner# = u.user# and
d.table_name = o.name and
d.owner = u.name and
o.obj# = op.obj# and
bitand(op.flags,32) = 32
/
grant select on DBA_XML_OUT_OF_LINE_TABLES  to select_catalog_role
/
create or replace public synonym DBA_XML_OUT_OF_LINE_TABLES 
    for DBA_XML_OUT_OF_LINE_TABLES
/

execute CDBView.create_cdbview(false,'SYS','DBA_XML_OUT_OF_LINE_TABLES','CDB_XML_OUT_OF_LINE_TABLES');
grant select on SYS.CDB_XML_OUT_OF_LINE_TABLES to select_catalog_role
/
create or replace public synonym CDB_XML_OUT_OF_LINE_TABLES for SYS.CDB_XML_OUT_OF_LINE_TABLES
/


/*
This view gives all the out of line tables connected to a 
given root table for the same schema.
--Note, this will give the root_table also as a part of table_name.
ROOT_TABLE_NAME  Name of the root table
ROOT_TABLE_OWNER  Owner of the root table.
TABLE_NAME  Name of out of line table.
TABLE_OWNER  Owner of the out of line table.
*/
create or replace view ALL_XML_OUT_OF_LINE_TABLES
as
select d.xmlschema as SCHEMA_URL, --schema URL  
       d.schema_owner as SCHEMA_OWNER,  --schema owner 
       d.table_name as TABLE_NAME, --out of line table name 
       d.owner as TABLE_OWNER --out of line table owner
from   ALL_XML_TABLES d, sys.obj$ o, sys.opqtype$ op, sys.user$ u
where
o.owner# = u.user# and
d.table_name = o.name and
d.owner = u.name and
o.obj# = op.obj# and
bitand(op.flags,32) = 32
/

grant read on ALL_XML_OUT_OF_LINE_TABLES  to public
/
create or replace public synonym ALL_XML_OUT_OF_LINE_TABLES 
    for ALL_XML_OUT_OF_LINE_TABLES
/ 

/*
This view gives all the out of line tables connected to a given 
root table for the same schema where table owner is the current user.
ROOT_TABLE_NAME  Name of the root table
ROOT_TABLE_OWNER  Owner of the root table.
TABLE_NAME  Name of out of line table.
*/
create or replace view USER_XML_OUT_OF_LINE_TABLES
as
select SCHEMA_URL, --schema URL  
       SCHEMA_OWNER,  --schema owner 
       TABLE_NAME --out of line table name 
from DBA_XML_OUT_OF_LINE_TABLES
where
NLSSORT(TABLE_OWNER, 'NLS_SORT=BINARY') = NLSSORT(SYS_CONTEXT('USERENV','CURRENT_USER'), 'NLS_SORT=BINARY')
/
grant read on USER_XML_OUT_OF_LINE_TABLES  to public
/
create or replace public synonym USER_XML_OUT_OF_LINE_TABLES 
    for USER_XML_OUT_OF_LINE_TABLES
/



-- this view gets all the xmltype columns for all the relational tables

--we only allow users owning the schema & tables to enable/disable
--indexes in them. So, the definition for ALL_XMLTYPE_COLS below holds good.
create or replace view DBA_XMLTYPE_COLS
as
(select s.sys_nc_oid$ as SCHEMA_ID,
       s.xmldata.schema_url as SCHEMA_URL, --schema URL for the column
       c.name as COL_NAME,  --name of the relational column
       (select c1.name from sys.col$ c1 where c1.intcol# = op.objcol and
        c1.obj# = op.obj#) QUALIFIED_COL_NAME,
       o.name as TABLE_NAME, --name of the parent table
       u.name as TABLE_OWNER --parent table owner
from xdb.xdb$schema s, sys.opqtype$ op, sys.col$ c, sys.obj$ o, sys.user$ u, dba_tables a
where o.type# = 2 and
o.obj# = op.obj# and
o.obj# = c.obj# and
op.schemaoid = s.sys_nc_oid$ and
o.owner# = u.user# and
c.intcol# = op.intcol# and
o.name = a.table_name and
u.name = a.owner
UNION
  select NULL as SCHEMA_ID,
       NULL as SCHEMA_URL, --schema URL for the column
       c.name as COL_NAME,  --name of the relational column
       (select c1.name from sys.col$ c1 where c1.intcol# = op.objcol and
        c1.obj# = op.obj#) QUALIFIED_COL_NAME,
       o.name as TABLE_NAME, --name of the parent table
       u.name as TABLE_OWNER --parent table owner
from  sys.opqtype$ op, sys.col$ c, sys.obj$ o, sys.user$ u, dba_tables a
where o.type# = 2 and
o.obj# = op.obj# and
o.obj# = c.obj# and
c.intcol# = op.intcol# and
o.owner# = u.user# and
o.name = a.table_name and
u.name = a.owner and
op.schemaoid IS NULL);
/

grant select on  DBA_XMLTYPE_COLS to select_catalog_role
/
create or replace public synonym  DBA_XMLTYPE_COLS for  DBA_XMLTYPE_COLS
/


execute CDBView.create_cdbview(false,'SYS','DBA_XMLTYPE_COLS','CDB_XMLTYPE_COLS');
grant select on SYS.CDB_XMLTYPE_COLS to select_catalog_role
/
create or replace public synonym CDB_XMLTYPE_COLS for SYS.CDB_XMLTYPE_COLS
/


create or replace view ALL_XMLTYPE_COLS
as
((select s.sys_nc_oid$ as SCHEMA_ID,
       s.xmldata.schema_url as SCHEMA_URL, --schema URL for the column
       c.name as COL_NAME,  --name of the relational column
       (select c1.name from sys.col$ c1 where c1.intcol# = op.objcol and
        c1.obj# = op.obj#) QUALIFIED_COL_NAME,
       o.name as TABLE_NAME, --name of the parent table
       u.name as TABLE_OWNER --parent table owner
from xdb.xdb$schema s, sys.opqtype$ op, sys.col$ c, sys.obj$ o, sys.user$ u,
     all_tables a
where o.type# = 2 and
o.obj# = op.obj# and
o.obj# = c.obj# and
op.schemaoid = s.sys_nc_oid$ and
o.owner# = u.user# and
c.intcol# = op.intcol# and
o.name = a.table_name and
u.name = a.owner)
UNION
(select NULL as SCHEMA_ID,
       NULL as SCHEMA_URL, --schema URL for the column
       c.name as COL_NAME,  --name of the relational column
       (select c1.name from sys.col$ c1 where c1.intcol# = op.objcol and
        c1.obj# = op.obj#) QUALIFIED_COL_NAME,
       o.name as TABLE_NAME, --name of the parent table
       u.name as TABLE_OWNER --parent table owner
from sys.opqtype$ op, sys.col$ c, sys.obj$ o, sys.user$ u,
     all_tables a
where o.type# = 2 and
o.obj# = op.obj# and
o.obj# = c.obj# and
o.owner# = u.user# and
c.intcol# = op.intcol# and
o.name = a.table_name and
u.name = a.owner and op.schemaoid IS NULL));
/
grant read on ALL_XMLTYPE_COLS to public
/
create or replace public synonym ALL_XMLTYPE_COLS for ALL_XMLTYPE_COLS
/

create or replace view USER_XMLTYPE_COLS
as
select  SCHEMA_ID, SCHEMA_URL, COL_NAME, QUALIFIED_COL_NAME, TABLE_NAME
from DBA_XMLTYPE_COLS
where NLSSORT(TABLE_OWNER, 'NLS_SORT=BINARY') = NLSSORT(SYS_CONTEXT('USERENV','CURRENT_USER'), 'NLS_SORT=BINARY');
grant read on USER_XMLTYPE_COLS to public
/
create or replace public synonym USER_XMLTYPE_COLS for USER_XMLTYPE_COLS
/


/*
This view selects all the tables and their corresponding nested tables.
OWNER  owner of the table
TABLE_NAME  Name of the table
NESTED_TABLE_NAME  Name of the nested table
PARENT_COLUMN_NAME Name of the parent XML column
*/
create or replace view DBA_XML_NESTED_TABLES
as
select x.OWNER,
       x.TABLE_NAME,
       NESTED_TABLE_NAME,
       'OBJECT_VALUE' PARENT_COLUMN_NAME
  from DBA_XML_TABLES x,
       (
         select TABLE_NAME NESTED_TABLE_NAME, 
                connect_by_root PARENT_TABLE_NAME PARENT_TABLE_NAME, OWNER
           from DBA_NESTED_TABLES nt
                connect by prior TABLE_NAME = PARENT_TABLE_NAME
                       and OWNER = OWNER
       ) nt
 where x.TABLE_NAME = nt.PARENT_TABLE_NAME
   and x.OWNER = nt.OWNER
UNION ALL
select x.OWNER,
       x.TABLE_NAME,
       NESTED_TABLE_NAME,
       x.COLUMN_NAME PARENT_COLUMN_NAME
 from DBA_XML_TAB_COLS x,
(
select TABLE_NAME NESTED_TABLE_NAME,
                connect_by_root PARENT_TABLE_NAME PARENT_TABLE_NAME, OWNER
           from DBA_NESTED_TABLES nt
                connect by prior TABLE_NAME = PARENT_TABLE_NAME
                       and OWNER = OWNER
       ) nt
where x.TABLE_NAME = nt.PARENT_TABLE_NAME and
x.owner = nt.OWNER
/

grant select on DBA_XML_NESTED_TABLES to select_catalog_role
/
create or replace public synonym DBA_XML_NESTED_TABLES for 
        DBA_XML_NESTED_TABLES
/

execute CDBView.create_cdbview(false,'SYS','DBA_XML_NESTED_TABLES','CDB_XML_NESTED_TABLES');
grant select on SYS.CDB_XML_NESTED_TABLES to select_catalog_role
/
create or replace public synonym CDB_XML_NESTED_TABLES for SYS.CDB_XML_NESTED_TABLES
/


create or replace view ALL_XML_NESTED_TABLES
as
select x.OWNER,
       x.TABLE_NAME,
       NESTED_TABLE_NAME,
       'OBJECT_VALUE' PARENT_COLUMN_NAME
  from ALL_XML_TABLES x,
       (
         select TABLE_NAME NESTED_TABLE_NAME, 
                connect_by_root PARENT_TABLE_NAME PARENT_TABLE_NAME, OWNER
           from ALL_NESTED_TABLES nt
                connect by prior TABLE_NAME = PARENT_TABLE_NAME
                       and OWNER = OWNER
       ) nt
 where x.TABLE_NAME = nt.PARENT_TABLE_NAME
   and x.OWNER = nt.OWNER
UNION ALL
select x.OWNER,
       x.TABLE_NAME,
       NESTED_TABLE_NAME,
       x.COLUMN_NAME PARENT_COLUMN_NAME
 from ALL_XML_TAB_COLS x,
(
select TABLE_NAME NESTED_TABLE_NAME,
                connect_by_root PARENT_TABLE_NAME PARENT_TABLE_NAME, OWNER
           from ALL_NESTED_TABLES nt
                connect by prior TABLE_NAME = PARENT_TABLE_NAME
                       and OWNER = OWNER
       ) nt
where x.TABLE_NAME = nt.PARENT_TABLE_NAME and
x.owner = nt.OWNER
/

grant read on ALL_XML_NESTED_TABLES to public
/
create or replace public synonym ALL_XML_NESTED_TABLES for 
        ALL_XML_NESTED_TABLES
/

create or replace view USER_XML_NESTED_TABLES
as
select TABLE_NAME,
       NESTED_TABLE_NAME,
       PARENT_COLUMN_NAME
  from DBA_XML_NESTED_TABLES
 where NLSSORT(OWNER, 'NLS_SORT=BINARY') = NLSSORT(SYS_CONTEXT('USERENV','CURRENT_USER'), 'NLS_SORT=BINARY')
/
grant read on USER_XML_NESTED_TABLES to public
/
create or replace public synonym USER_XML_NESTED_TABLES
    for USER_XML_NESTED_TABLES
/
--*********************************************************
-- end of view definitions
--*********************************************************


@?/rdbms/admin/sqlsessend.sql
