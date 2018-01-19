@sql_resources/common/wrap_start.sql

define v_schema = &1
define v_schema_path = &2
define v_temp_dir = &3
define v_obj_dir = &4

define v_sql_path = sql_resources/unload

spool &v_schema_path/&v_temp_dir/unload_synonyms_temp.sql
                                     -- 1             2                    3                         4
select '@&v_sql_path/unload_synonym.sql '||t.owner||' '||t.synonym_name||' '||lower(t.synonym_name) ||' &v_schema_path/&v_obj_dir'
  from dba_synonyms t
 where t.owner=upper('&v_schema')
 order by t.synonym_name
/

spool off
@sql_resources/common/wrap_end.sql