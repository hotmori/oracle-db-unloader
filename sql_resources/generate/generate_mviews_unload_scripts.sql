@sql_resources/common/wrap_start.sql

define v_schema = &1
define v_schema_path = &2
define v_temp_dir = &3
define v_obj_dir = &4
define v_sql_path = sql_resources/unload

spool &v_schema_path/&v_temp_dir/unload_mviews_temp.sql

select '@&v_sql_path/unload_mview.sql'|| ' '
                                  ||t.owner ||' ' -- 1
                                  ||t.mview_name||' ' -- 2
                                  ||lower(t.mview_name) || ' ' -- 3
                                  ||'&v_schema_path/&v_obj_dir' -- 4
  from dba_mviews t
 where t.owner=upper('&v_schema')
 order by t.mview_name
/

spool off
@sql_resources/common/wrap_end.sql