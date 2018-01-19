@sql_resources/common/wrap_start.sql

define v_schema = &1
define v_schema_path = &2
define v_temp_dir = &3
define v_obj_dir = &4
define v_sql_path = sql_resources/unload

spool &v_schema_path/&v_temp_dir/unload_packages_temp.sql

select '@&v_sql_path/unload_package.sql' || ' '
       ||t.owner || ' ' -- 1
       ||t.object_name || ' ' -- 2
       ||replace(t.object_type,' ','_')||' ' -- 3
       ||lower(t.object_name) || case t.object_type when 'PACKAGE' then '_s'
                                                    when 'PACKAGE BODY' then '_b'
                                 else null end || ' ' -- 4
       || '&v_schema_path/&v_obj_dir' -- 5
  from dba_objects t
 where t.object_type in ('PACKAGE', 'PACKAGE BODY')
   and t.owner=upper('&v_schema')
 order by t.object_name,object_type
/

spool off
@sql_resources/common/wrap_end.sql