import schema_unloader
import shutil

g_results_path = 'd:/temp/results'
g_db_scripts_dir = ''
g_login = ''
g_password = ''

shutil.rmtree(g_results_path + '/' + g_db_scripts_dir, ignore_errors=True)

schema_unloader.initialize( db_tns = 'xdb',
                            login = g_login,
                            password = g_password,
                            results_path = g_results_path,
                            db_scripts_dir = g_db_scripts_dir,
                            db_alias = 'adb',
                            max_connections=10 )

schema_unloader.unload("scott")
schema_unloader.deinitialize()