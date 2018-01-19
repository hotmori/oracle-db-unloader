@sql_resources/common/wrap_start.sql

define v_schema=&1
define v_obj_name=&2
define v_obj_type=&3
define v_obj_file_name=&4
define v_obj_path=&5

spool &v_obj_path\&v_obj_file_name..sql

select decode (d.line, 1, 'create or replace '|| replace(d.text,'"'||d.owner||'".'), d.text)
from dba_source d
where d.type=replace('&v_obj_type','_',' ')
and d.owner=upper('&v_schema')
and upper(d.name)=upper('&v_obj_name')
order by d.owner,d.name,d.line;
prompt /

spool off

@sql_resources/common/wrap_end.sql