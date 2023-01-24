# Oracle DB unloader

Python command line tool for unloading Oracle db objects into folders/files. Sqlplus is required.

## Deployment instructions
### Requirements
1. Python3
2. Oracle Instant Client 11.2.0.4 and above with sqlplus
3. Configured *tnsnames.ora* file on the host

### Usage
1. To check list of available options run:
```bash
python db_unloader.py -h
# or
python db_unloader.py --help
```

### Example
```bash
db_unloader.py -db-login=system -db-pass=qwerty -db-tns=orclpdb -db-max-connections=5 -schemas=scott,scott2
```
The output result will be saved in folder (C:\db_unloader_results by default) as following:
```bash
2023_01_24_134601
  - scott
  -- functions
  ---- func1.sql
  ---- func2.sql
  ---- ....
  -- packages
  -- ...
  -- views
  - scott2
  -- functions
  ---- func1.sql
  ---- func2.sql
  ---- ....
  -- packages
  -- ...
  -- views
```