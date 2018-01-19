@sql_resources/common/wrap_start.sql

define v_schema=&1
define v_obj_name=&2
define v_obj_file_name=&3
define v_obj_path=&4

spool &v_obj_path\&v_obj_file_name..sql

prompt create or replace view &v_obj_name
select case when rownum=1 then ' (' else ' ' end ||lower(column_name) || case when rownum=count(*) over() then ')' else ',' end from
(select c.column_name from dba_tab_columns c
where owner=upper('&v_schema')
and table_name='&v_obj_name'
order by column_id);

prompt as

select d.text from dba_views d
where owner=upper('&v_schema')
and d.view_name='&v_obj_name';

prompt /
/*
select '-- \triggers\'|| lower(trigger_name) ||'.sql -- '|| lower(trigger_type ||' '|| triggering_event) ||' trigger'
from dba_triggers
where table_owner=upper('&1') and table_name='&2' and trigger_type='INSTEAD OF'
order by trigger_name;
*/
spool off

@sql_resources/common/wrap_end.sql