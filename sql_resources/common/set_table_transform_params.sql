begin
dbms_metadata.set_transform_param(dbms_metadata.session_transform,'DEFAULT',true);
dbms_metadata.set_transform_param(dbms_metadata.session_transform,'PRETTY',true);
dbms_metadata.set_transform_param(dbms_metadata.session_transform,'SQLTERMINATOR',true);
dbms_metadata.set_transform_param(dbms_metadata.session_transform,'STORAGE',false);
dbms_metadata.set_transform_param(dbms_metadata.session_transform,'SEGMENT_ATTRIBUTES',false);
dbms_metadata.set_transform_param(dbms_metadata.session_transform,'CONSTRAINTS',true);
dbms_metadata.set_transform_param(dbms_metadata.session_transform,'REF_CONSTRAINTS',true);
dbms_metadata.set_transform_param(dbms_metadata.session_transform,'TABLESPACE',false);
end;
/
