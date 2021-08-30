@sql_resources/common/wrap_start.sql

define v_schema = &1
define v_schema_path = &2
define v_temp_dir = &3
define v_obj_dir = &4

define v_sql_path = sql_resources/unload

spool &v_schema_path/&v_temp_dir/unload_sequences_temp.sql
                                     -- 1             2                    3                         4
select '@&v_sql_path/unload_sequence.sql '||t.sequence_owner||' '||t.sequence_name||' '||lower(t.sequence_name) ||' &v_schema_path/&v_obj_dir'
  from dba_sequences t
 where t.sequence_owner=upper('&v_schema')
 order by t.sequence_name
/



spool off
@sql_resources/common/wrap_end.sql