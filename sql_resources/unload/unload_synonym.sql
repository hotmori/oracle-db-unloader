@sql_resources/common/wrap_start.sql

define v_schema=&1
define v_obj_name=&2
define v_obj_file_name=&3
define v_obj_path=&4

spool &v_obj_path\&v_obj_file_name..sql

select 'create or replace synonym '||s.synonym_name||' for '||s.table_owner||decode(s.table_owner,null,null,'.')||s.table_name||decode(s.db_link,null,null,'@')||s.db_link
from ( select owner, synonym_name, nvl2(db_link, table_owner, nullif(table_owner, owner)) as table_owner, table_name, db_link from dba_synonyms ) s
where s.owner=upper('&v_schema')
and s.synonym_name=upper('&v_obj_name');
prompt /

spool off

@sql_resources/common/wrap_end.sql