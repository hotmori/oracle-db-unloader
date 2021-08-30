@sql_resources/common/wrap_start.sql

define v_schema=&1
define v_obj_name=&2
define v_obj_file_name=&3
define v_obj_path=&4

spool &v_obj_path\&v_obj_file_name..sql

select  table_name y,
        0 x,
        'CREATE TABLE ' ||
        rtrim(table_name) ||
        '('
from    dba_tables
where   owner = upper('&v_schema')
  and   table_name = upper('&v_obj_name')
union
select  tc.table_name y,
        column_id x,
        decode(column_id,1,'    ','   ,')||
        rtrim(column_name)|| chr(9) || chr(9) ||
        rtrim(data_type) ||
        rtrim(decode(data_type,'DATE',null,'LONG',null,
               'NUMBER',decode(to_char(data_precision),null,null,'('),
               '(')) ||
        rtrim(decode(data_type,
               'DATE',null,
               'CHAR',data_length,
               'VARCHAR2',data_length,
               'NUMBER',decode(to_char(data_precision),null,null,
                 to_char(data_precision) || ',' || to_char(data_scale)),
               'LONG',null,
               '******ERROR')) ||
        rtrim(decode(data_type,'DATE',null,'LONG',null,
               'NUMBER',decode(to_char(data_precision),null,null,')'),
               ')')) || chr(9) || chr(9) ||
        rtrim(decode(nullable,'N','NOT NULL',null))
from    dba_tab_columns tc,
        dba_objects o
where   o.owner = tc.owner
and     o.object_name = tc.table_name
and     o.object_type = 'TABLE'
and     o.owner = upper('&v_schema')
and   o.object_name = upper('&v_obj_name')
union
select  table_name y,
        999999 x,
        ')'  || chr(10)
        ||'  STORAGE('                                   || chr(10)
        ||'  INITIAL '    || initial_extent              || chr(10)
        ||'  NEXT '       || next_extent                 || chr(10)
        ||'  MINEXTENTS ' || min_extents                 || chr(10)
        ||'  MAXEXTENTS ' || max_extents                 || chr(10)
        ||'  PCTINCREASE '|| pct_increase                || ')' ||chr(10)
        ||'  INITRANS '   || ini_trans                   || chr(10)
        ||'  MAXTRANS '   || max_trans                   || chr(10)
        ||'  PCTFREE '    || pct_free                    || chr(10)
        ||'  PCTUSED '    || pct_used                    || chr(10)
        ||'  PARALLEL (DEGREE ' || rtrim(DEGREE) || ') ' || chr(10)
        ||'  TABLESPACE ' || rtrim(tablespace_name)      ||chr(10)
        ||'/'||chr(10)||chr(10)
from    dba_tables
where   owner = upper('&v_schema')
and     table_name = upper('&v_obj_name')
order by 1,2;

spool off

@sql_resources/common/wrap_end.sql