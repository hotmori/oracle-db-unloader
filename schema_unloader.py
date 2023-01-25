import threading
import time
import sys

from os import listdir, makedirs
from os.path import isfile, join, isdir
from subprocess import Popen, PIPE, DEVNULL
from concurrent.futures import ThreadPoolExecutor, wait, as_completed
from random import randint


TEMP_DIR = 'ztemp'
SQL_RESOURCES_DIR = 'sql_resources'

g_results_path = None
g_db_tns = None
g_login = None
g_password = None
g_thread_data = None
g_thread_pool = None

#FUNCTIONS
def initialize(db_tns,
               login,
               password,
               results_path,
               db_scripts_dir,
               max_connections):

  global g_db_tns
  global g_login
  global g_password
  global g_results_path
  global g_db_scripts_dir

  global g_thread_data
  global g_thread_pool

  g_db_tns = db_tns
  g_login = login
  g_password = password
  g_results_path = results_path
  g_db_scripts_dir = db_scripts_dir

  g_thread_data = threading.local()
  g_thread_pool = ThreadPoolExecutor(max_connections)

def deinitialize():
  g_thread_pool.shutdown()

def create_session():
  session = Popen(['sqlplus', '-silent', g_login + '/' + g_password + '@' + g_db_tns], stdin=PIPE, stdout=PIPE, stderr=DEVNULL)
  session.id = randint(1000,2000)
  return session

def exec_sqlplus(session, script):
  #print(f'run: {script=}')
  session.stdin.write(bytes (script + '\n', 'utf-8') )
  # there is need to flush buffer to avoid deadlock
  #   between stdin writing and stdout reading
  session.stdin.flush()
  # also there is need to read line from stdout as
  #   it confirms of end of script execution
  session.stdout.readline()
  session.stdout.flush()

def exec_sqlplus_in_thread(script):
  if 'session' not in g_thread_data.__dict__:
    g_thread_data.session = create_session()
    print("created session: ", g_thread_data.session.id)
  else:
    None

  #print("going to execute: " + script)
  exec_sqlplus(g_thread_data.session, script)

def exec_batch_sqlplus(scripts, pool, desc):
  print('..' + desc)
  start = time.time()
  futures = []
  for script in scripts:
    future = pool.submit(exec_sqlplus_in_thread, script)
    future.script = script
    futures.append(future)

  total_batch_item_cnt = len(futures)
  for idx, x in enumerate(as_completed(futures)):
    print('..completed:', idx+1, 'out of:', total_batch_item_cnt, x.script)
  done = time.time()
  elapsed = round(done - start, 2)
  print('\n..done:', elapsed, 'seconds')

def make_dir(dir_path):
  if not isdir(dir_path):
    makedirs(dir_path)
    #print("Directory %s was created." %dir_path)

def generate_sqlplus_command(script, schema, schema_path, objects_dir):

  return '@' + join(SQL_RESOURCES_DIR,'generate',script) + ' ' + schema + ' ' + schema_path + ' ' + TEMP_DIR + ' ' + objects_dir

def unload(schema):

  schema_dir = schema
  schema_path = join(g_results_path,g_db_scripts_dir, schema_dir)
  #schema_path = g_results_path + '/' + g_db_scripts_dir + '/' + schema_dir
  temp_path =  join(schema_path,TEMP_DIR)
  #temp_path =  schema_path + '/' + TEMP_DIR
  print(schema_path)
  print(temp_path)
  # MAIN  ------------------------------------------------------------------------------
  print('==== ==== ==== ==== ==== ==== ==== ==== ==== ==== ')
  print ('unloading schema:', schema, 'to', schema_path)
  print('==== ==== ==== ==== ==== ==== ==== ==== ==== ==== ')

  make_dir(schema_path)
  make_dir(schema_path + '/functions')
  make_dir(schema_path + '/packages')
  make_dir(schema_path + '/procedures')
  make_dir(schema_path + '/sequences')
  make_dir(schema_path + '/synonyms')
  make_dir(schema_path + '/triggers')
  make_dir(schema_path + '/types')
  make_dir(schema_path + '/views')
  make_dir(schema_path + '/mviews')
  make_dir(schema_path + '/tables')
  #make_dir(schema_path + '/table_rows')
  make_dir(schema_path + '/table_row_counts')
  make_dir(temp_path)

  gen_scripts = [
                  generate_sqlplus_command('generate_synonyms_unload_scripts.sql',schema, schema_path,'synonyms'),
                  generate_sqlplus_command('generate_views_unload_scripts.sql',schema, schema_path,'views'),
                  generate_sqlplus_command('generate_mviews_unload_scripts.sql',schema, schema_path,'mviews'),
                  generate_sqlplus_command('generate_sequences_unload_scripts.sql',schema, schema_path,'sequences'),
                  generate_sqlplus_command('generate_packages_unload_scripts.sql',schema, schema_path,'packages'),
                  generate_sqlplus_command('generate_functions_unload_scripts.sql',schema, schema_path,'functions'),
                  generate_sqlplus_command('generate_procedures_unload_scripts.sql',schema, schema_path,'procedures'),
                  generate_sqlplus_command('generate_triggers_unload_scripts.sql',schema, schema_path,'triggers'),
                  generate_sqlplus_command('generate_types_unload_scripts.sql',schema, schema_path,'types'),
                  generate_sqlplus_command('generate_tables_unload_scripts.sql',schema, schema_path,'tables'),
                  generate_sqlplus_command('generate_table_row_counts_unload_scripts.sql',schema, schema_path,'table_row_counts'),
                 # generate_sqlplus_command('generate_table_rows_unload_scripts.sql',schema, schema_path,  TEMP_DIR, 'table_rows'),
                ]
  #print(gen_scripts)
  exec_batch_sqlplus(gen_scripts, g_thread_pool, 'generation temp scripts')

  for temp_file in listdir(temp_path):
    print(temp_file)

  unload_db_object_scripts = []
  for file in listdir(temp_path):
    f = open(join(temp_path,file),'r')
    for line in f:
      line = line.strip()
      if not line:
        continue
      unload_db_object_scripts.append(line)
    f.close

  #input("Total count objects: " + str(len(unload_db_object_scripts)) + " objects, press Enter to continue...")
  exec_batch_sqlplus(unload_db_object_scripts, g_thread_pool, 'unloading schema objects')
