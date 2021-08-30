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
and table_name=upper('&v_obj_name')
order by column_id);

prompt as

select d.text from dba_views d
where owner=upper('&v_schema')
and d.view_name=upper('&v_obj_name');

prompt /

select 'comment on table ' || lower(dtc.table_name) || ' is '
        || '''' || replace(dtc.comments,'''','''''') || '''' || ';' cm
from dba_tab_comments dtc
where dtc.owner = upper('&v_schema')
and dtc.table_name = upper('&v_obj_name');

select 'comment on column ' || lower(dcc.table_name) || '.' || lower(dcc.column_name) || ' is '
        || '''' || replace(dcc.comments,'''','''''') || '''' || ';' col_comment_txt
  from dba_col_comments dcc
  join dba_tab_columns col
    on col.owner = dcc.owner
   and col.table_name = dcc.table_name
   and col.column_name = dcc.column_name
 where dcc.owner = upper('&v_schema')
   and dcc.table_name = upper('&v_obj_name')
   and dcc.comments is not null
order by col.column_id;

/*
select '-- \triggers\'|| lower(trigger_name) ||'.sql -- '|| lower(trigger_type ||' '|| triggering_event) ||' trigger'
from dba_triggers
where table_owner=upper('&1') and table_name='&2' and trigger_type='INSTEAD OF'
order by trigger_name;
*/
spool off

@sql_resources/common/wrap_end.sql
