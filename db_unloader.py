import schema_unloader
import shutil
import datetime
import sys

now = datetime.datetime.now()

#print(now)

dt = now.strftime("%Y_%m_%d_%H%M%S")
print(dt)

g_results_path = 'd:/logs/db_unloader_results/' + dt


print('results_path: ' + g_results_path)

def unload_db(login,
              password,
              tns):

  l_login = login
  l_password = password
  l_db_tns = tns


  shutil.rmtree(g_results_path + '/' + l_db_tns, ignore_errors=True)

  schema_unloader.initialize( db_tns = l_db_tns,
                              login = l_login,
                              password = l_password,
                              results_path = g_results_path,
                              db_scripts_dir = l_db_tns,
                              db_alias = 'dwh', # not used
                              max_connections=15 )

# list of schemas
  for schema in g_schema_list:
    if schema != "":
      schema_unloader.unload(schema)

  schema_unloader.deinitialize()


g_schema_list = [
"scott"
             ]

             
unload_db(login='scott',password='scott',tns='mydb')
