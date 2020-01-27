REM creates a stored function boil_raw()
REM that converts high and low values from
REM a raw value into readable format
REM ======================================

CREATE OR REPLACE FUNCTION boil_raw
( p_raw_value  in  raw
, p_datatype   in  varchar2        /* in ('VARCHAR2','CHAR','NUMBER','DATE') */
)
RETURN varchar2
IS
  v_dump_expr        varchar2(6000);
  v_converted_value  varchar2(6000);
  v_pos_comma        number(4);
  v_help_num         number(3);
  v_exponent         number(3);
BEGIN
  if    upper(p_datatype) in ('VARCHAR','VARCHAR2','CHAR') then
    select ltrim(substr(dump(p_raw_value,17)                    -- alphanumeric
                       ,instr(dump(p_raw_value),':')+1)
                ,' ')
    into   v_dump_expr
    from   sys.dual;
    if v_dump_expr = 'NULL' then
      v_converted_value := null;
    else
      v_converted_value := replace(v_dump_expr,',');
    end if;
  elsif upper(p_datatype) = 'NUMBER' then
    select ltrim(substr(dump(p_raw_value, 10)                   -- numeric
                       ,instr(dump(p_raw_value),':')+1)
                ,' ')
    into   v_dump_expr
    from   sys.dual;
    if v_dump_expr = 'NULL' then
      v_converted_value := null;
    elsif v_dump_expr = '0' then
      v_converted_value := '-infinite';
    elsif v_dump_expr = '128' then
      v_converted_value := '0';
    else
      v_pos_comma := instr (v_dump_expr,',');
      v_help_num  := substr(v_dump_expr,1,v_pos_comma-1);
      v_dump_expr := substr(v_dump_expr,v_pos_comma+1);
      v_converted_value := '0.';
      v_pos_comma := instr (v_dump_expr,',');
      if v_help_num >= 128 then                                -- positive number
        v_exponent := 2 * (v_help_num-192);                    -- (128+64)
        while v_pos_comma > 0 loop
          v_help_num := substr(v_dump_expr,1,v_pos_comma-1);
          v_dump_expr := substr(v_dump_expr, v_pos_comma+1);
          v_converted_value := v_converted_value
                               || lpad(to_char(v_help_num-1 ),2,'0');
          v_pos_comma := instr(v_dump_expr,',');
        end loop;
        v_help_num := v_dump_expr;
        v_converted_value := v_converted_value 
                             || lpad(to_char(v_help_num-1),2,'0');
        v_converted_value := to_number(v_converted_value)
                             * power(10, v_exponent);
      else                                                     -- negative number
        v_exponent := 2 * (63-v_help_num);                     -- (127-64)
        while v_pos_comma > 0 loop
          v_help_num := substr(v_dump_expr,1,v_pos_comma-1);
          v_dump_expr := substr(v_dump_expr, v_pos_comma+1);
          v_converted_value := v_converted_value
                               || lpad(to_char(101-v_help_num),2,'0');
          v_pos_comma := instr(v_dump_expr,',');
        end loop;
        v_help_num := v_dump_expr;
        if v_help_num <> 102 /* is dummy byte for negative numbers */ then
          v_converted_value := v_converted_value
                               || lpad(to_char(101-v_help_num),2,'0');
        end if;
        v_converted_value := -1 * to_number(v_converted_value)
                                * power(10, v_exponent);
      end if;
    end if;
  elsif upper(p_datatype) = 'DATE' then
    select ltrim(substr(dump(p_raw_value,10)                   -- date
                       ,instr(dump(p_raw_value),':')+1)
                ,' ')
    into   v_dump_expr
    from   sys.dual;
    if v_dump_expr = 'NULL' then
      v_converted_value := null;
    else                                                       -- get century
      v_pos_comma := instr(v_dump_expr,',');
      v_help_num := substr(v_dump_expr,1,v_pos_comma-1);
      if v_help_num >= 100 then
        v_converted_value := 'AD '
                             || lpad(to_char(v_help_num-100),2,'0');
      else
        v_converted_value := 'BC '
                             || lpad(to_char(100-v_help_num),2,'0');
      end if;
      v_dump_expr := substr(v_dump_expr,v_pos_comma+1);        -- get year
      v_pos_comma := instr(v_dump_expr,',');
      v_help_num  := substr(v_dump_expr,1,v_pos_comma-1);
      if v_help_num >= 100 then
        v_converted_value := v_converted_value
                             || lpad(to_char(v_help_num-100),2,'0');
      else
        v_converted_value := v_converted_value
                             || lpad(to_char(100-v_help_num),2,'0');
      end if;
      v_dump_expr := substr(v_dump_expr,v_pos_comma+1);        -- get month
      v_pos_comma := instr(v_dump_expr,',');
      v_help_num  := substr(v_dump_expr,1,v_pos_comma-1);
      v_converted_value := v_converted_value || '-'
                           || lpad(to_char(v_help_num),2,'0');
      v_dump_expr := substr(v_dump_expr,v_pos_comma+1);        -- get day
      v_pos_comma := instr(v_dump_expr, ',' );
      v_help_num  := substr(v_dump_expr,1,v_pos_comma-1);
      v_converted_value := v_converted_value || '-'
                           || lpad(to_char(v_help_num),2,'0');
      v_dump_expr := substr(v_dump_expr,v_pos_comma+1);        -- get hour
      v_pos_comma := instr(v_dump_expr,',');
      v_help_num  := substr(v_dump_expr,1,v_pos_comma-1);
      v_converted_value := v_converted_value || ' '
                           || lpad(to_char(v_help_num-1),2,'0');
      v_dump_expr := substr(v_dump_expr,v_pos_comma+1);        -- get minutes
      v_pos_comma := instr(v_dump_expr,',');
      v_help_num  := substr(v_dump_expr,1,v_pos_comma-1);
      v_converted_value := v_converted_value || ':'
                           || lpad(to_char(v_help_num-1),2,'0');
      v_dump_expr := substr(v_dump_expr,v_pos_comma+1);        -- get seconds
      v_converted_value := v_converted_value || ':'
                           || lpad(to_char(v_dump_expr-1),2,'0');
    end if;
  else
    v_converted_value := p_raw_value;
  end if;
  RETURN(v_converted_value);
END boil_raw;
/
