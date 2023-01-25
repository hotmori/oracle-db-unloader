@sql_resources/common/wrap_start.sql

define v_schema = &1
define v_schema_path = &2
define v_temp_dir = &3
define v_obj_dir = &4
define v_sql_path = sql_resources/unload

spool &v_schema_path/&v_temp_dir/unload_tables_temp.sql

select '@&v_sql_path/unload_table.sql'|| ' '
                                  ||t.owner ||' ' -- 1
                                  ||t.table_name||' ' -- 2
                                  ||lower(t.table_name) || ' ' -- 3
                                  ||'&v_schema_path/&v_obj_dir' -- 4
  from dba_tables t
 where t.owner=upper('&v_schema')
   and not t.table_name like 'RB$%' -- todo
   and not exists (select null
                     from dba_mviews t2
                    where t2.owner = t.owner
                      and t2.mview_name =t.table_name)
 order by t.table_name
/

spool off
@sql_resources/common/wrap_end.sql
