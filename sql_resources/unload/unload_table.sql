@sql_resources/common/wrap_start.sql

define v_schema=&1
define v_obj_name=&2
define v_obj_file_name=&3
define v_obj_path=&4

spool &v_obj_path\&v_obj_file_name..sql

@sql_resources/common/set_table_transform_params.sql

select replace(dbms_metadata.get_ddl('TABLE',upper('&v_obj_name'),upper('&v_schema')),'"','') from dual
/

-- PK ddl except IOT tables which PK ddl included in table ddl
select replace(dbms_metadata.get_ddl('CONSTRAINT', c.constraint_name, c.owner),'"','') ddl
  from dba_constraints c,
       dba_tables t
 where c.table_name = upper('&v_obj_name')
   and c.owner = upper('&v_schema')
   and c.constraint_type = 'P'
   and c.table_name = t.table_name
   and c.owner = t.owner
   and t.iot_type is null
/

-- all FK
select replace(dbms_metadata.get_ddl('REF_CONSTRAINT', c.constraint_name, c.owner),'"','') ddl
  from dba_constraints c
 where c.table_name = upper('&v_obj_name')
   and c.owner = upper('&v_schema')
   and c.constraint_type = 'R'
 order by c.constraint_name
/

-- all indexes except PK related
select replace(dbms_metadata.get_ddl('INDEX',i.index_name,i.owner),'"','')
  from dba_indexes i
 where i.table_name = upper('&v_obj_name')
   and i.owner = upper('&v_schema')
   and i.generated <> 'Y'
   and i.index_name not in
                   (select constraint_name
                      from dba_constraints
                     where table_name = i.table_name
					   and owner = i.owner
                       and constraint_type = 'P')
 order by i.index_name
/

-- all constraints except PK related
   select replace(dbms_metadata.get_ddl('CONSTRAINT', c.constraint_name, c.owner),'"','') ddl
  from dba_constraints c,
       dba_cons_columns col
 where c.table_name = upper('&v_obj_name')
   and col.owner = c.owner
   and c.constraint_name = col.constraint_name
   and col.column_name not in (select col2.column_name
                                 from dba_constraints c2,
                                      dba_cons_columns col2
                                 where c2.constraint_type = 'P'
                                   and c2.constraint_name = col2.constraint_name
                                   and c2.table_name = c.table_name
                                   and c2.owner      = c.owner)
   and c.owner = upper('&v_schema')
   and c.constraint_type = 'C'
 order by col.column_name
/

-- supplemental logs only for ALL and USER LOG GROUP
select 'ALTER TABLE ' || owner || '.' || table_name ||
       ' ADD SUPPLEMENTAL LOG ' || case
         when log_group_type = 'USER LOG GROUP' then 'GROUP ' ||
          (select c.log_group_name || ' (' || listagg(column_name, ', ') within group(order by position)
             from dba_log_group_columns
            where c.log_group_name = log_group_name) || ')' || decode(always, 'ALWAYS', ' ALWAYS')
         else
          'DATA (ALL) COLUMNS'
       end ||  ';'
  from dba_log_groups c
 where c.owner = upper('&v_schema')
   and c.table_name = upper('&v_obj_name')
   and c.log_group_type in ('ALL COLUMN LOGGING', 'USER LOG GROUP')
 order by c.log_group_type, c.always, c.generated, c.log_group_name
/

@sql_resources/common/unset_transform_params.sql

spool off

@sql_resources/common/wrap_end.sql