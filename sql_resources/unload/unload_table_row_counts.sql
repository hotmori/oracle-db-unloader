@sql_resources/common/wrap_start.sql

define v_schema=&1
define v_obj_name=&2
define v_obj_file_name=&3
define v_obj_path=&4

spool &v_obj_path\&v_obj_file_name..sql

select count(*) from &v_schema..&v_obj_name
prompt /

spool off

@sql_resources/common/wrap_end.sql