@sql_resources/common/wrap_start.sql

define v_schema=&1
define v_obj_name=&2
define v_obj_file_name=&3
define v_obj_path=&4

spool &v_obj_path\&v_obj_file_name..sql


declare

  p_debug_mode   number := 0;

  procedure p(txt in varchar2) is
  begin
    dbms_output.put_line(txt);
  end;
  
  procedure p(txt in varchar2, txt2 in varchar2) is
  begin
    dbms_output.put_line(txt || ' ' || txt2);
  end;
  
  procedure pd(txt in varchar2) is
  begin
    if p_debug_mode <> 0 then
      dbms_output.put_line('-- debug:'  || txt);
    end if;  
  end;  

  function get_count(p_query in varchar2) return number is
    v_cnt number;
  begin
    pd('count records in table:' || p_query);
    execute immediate 'select count(*) from (' || p_query || ')' into v_cnt;
    
    return v_cnt;
  end get_count;

  procedure print_sql(p_owner    in varchar2,
                      p_tab_name in varchar2,
                      p_query    in varchar2,
                      p_sequence in number)
  is
    v_owner    varchar2(32) := upper(p_owner);
    v_tab_name varchar2(32) := upper(p_tab_name);
    v_query    varchar2(4096) := case when p_query is null then 'select w.* from ' || v_owner || '.' || v_tab_name || ' w where rownum <= 1000;' else p_query || ';' end;

    v_col_list     varchar2(32000);
    v_print_list   varchar2(32000);
    v_column       varchar2(32000);
    v_column_value varchar2(32000);

    v_gen      varchar2(32000);
    type x_col_rec is record (column_id number,
                              column_name varchar2(32),
                              data_type varchar2(256),
                              nullable varchar2(1),
                              pk_name varchar2(32),
                              repl_value varchar2(1024),
                              rn number);
    -- table type that can hold info about tab columns
    type x_col_tab is table of x_col_rec;
    v_col_tab x_col_tab;

    cursor c_col(c_table_name  in varchar2,
                 c_table_owner in varchar2)
    is
    with rr
    as (select 1 flg_enabled, 'ZPORTAL' r_owner, 'ADMINS_PRIMARY' pk_name, '6' repl_value from dual union all
        select 1 flg_enabled, 'ZPORTAL' r_owner, 'SERVERS_PRIMARY' pk_name, 'null' repl_value from dual),
    x  as (
     select distinct               
                  tc.COLUMN_ID,
                  tc.COLUMN_NAME,
                  tc.DATA_TYPE,
                  tc.NULLABLE,
                  rr.pk_name,
                  rr.repl_value,
                  row_number() over(partition by tc.column_id order by rr.pk_name nulls last) rn
        from dba_tab_columns tc
        left join dba_cons_columns dcc on 1=1
         and dcc.table_name = tc.TABLE_NAME
         and dcc.column_name = tc.COLUMN_NAME
         and dcc.owner = tc.OWNER
        left join dba_constraints dc
                      on 1=1--
                     and dc.constraint_type = 'R'
                     and dc.owner = tc.owner
                     and dc.table_name = tc.table_name
                     and dc.constraint_name = dcc.constraint_name
        left join rr on rr.r_owner = dc.r_owner
                    and rr.pk_name = dc.r_constraint_name
                    and rr.flg_enabled <> 0
                    and dcc.constraint_name is not null
       where tc.OWNER = c_table_owner
         and tc.TABLE_NAME = c_table_name
       order by tc.COLUMN_ID)
    select x.*      
      from x
     where x.rn = 1;

  begin
    open c_col(v_tab_name, v_owner);
    fetch c_col bulk collect into v_col_tab;
    close c_col;

    for i in v_col_tab.first .. v_col_tab.last loop
      v_column := null;

      v_column_value := nvl( v_col_tab(i).repl_value ,'xr.'|| v_col_tab(i).column_name);

      if v_col_tab(i).data_type not in ('NUMBER', 'LONG') then
        v_column := 'case when xr.'
        || v_col_tab(i).column_name || ' is not null then ' || ''''''''' || to_char(replace( '  || v_column_value
        ||', '''''''','''''''''''')) || '''''''' else ''null'' end';
      else
        v_column := 'case when xr.' || v_col_tab(i).column_name || ' is not null then to_char( ' || v_column_value || ') else ''null'' end';
      end if;
      v_col_list := v_col_list || 'w.' || v_col_tab(i).column_name || case when i <> v_col_tab.last then ',' end || ' ';
      v_print_list := v_print_list || '
      ' || v_column || case when i <> v_col_tab.last then ' || '','' || ' end || ' ';
    end loop;

    pd(v_col_list);
    pd('print list:' || v_print_list);

    v_gen := replace(replace(v_query, 'w.*', v_col_list),';');
    pd('length:' || length(v_gen));
    pd(v_gen);

    v_gen := 'declare
                v_row_cnt number := 0;
              begin
                for xr in (' || v_gen || ') loop
                  v_row_cnt := v_row_cnt + 1;
                  if v_row_cnt = 1 then
                    dbms_output.put_line( ''insert into ' || v_owner || '.' || v_tab_name || ' (' || replace(v_col_list, 'w.') || ')'' );
                  end if;
                  dbms_output.put_line( case when v_row_cnt = 1 then null else '' union all '' end || ''select ''|| ' || v_print_list ||  ' || '' from dual '' );
                end loop;
                 dbms_output.put_line( case when v_row_cnt = 0  then ''-- no records to export'' else '';'' end );
              end;
    ';

    pd('final:' || v_gen);
    begin
      execute immediate v_gen;
    exception when others then
      dbms_output.put_line('-- there are problems with the table (skipped): ' || v_owner || '.' || v_tab_name  || ' msg:
      /*' || sqlerrm || '*/ ');
    end;
  end print_sql;


begin
  print_sql('&v_schema', '&v_obj_name', null, null);
end;
/


spool off

@sql_resources/common/wrap_end.sql