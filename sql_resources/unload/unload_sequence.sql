@sql_resources/common/wrap_start.sql

define v_schema=&1
define v_obj_name=&2
define v_obj_file_name=&3
define v_obj_path=&4

spool &v_obj_path\&v_obj_file_name..sql

select -- ds.*,
       'create sequence '|| lower(ds.sequence_name) --  chr(10)
    --   || 'minvalue ' || ds.min_value || chr(10)
     --  || 'maxvalue ' || ds.max_value || chr(10)
       ddl_seq
  from dba_sequences ds
where ds.sequence_owner = upper('&v_schema')
 and ds.sequence_name = upper('&v_obj_name')
/
prompt /

spool off

@sql_resources/common/wrap_end.sql