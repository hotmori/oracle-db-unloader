import schema_unloader
import shutil
import datetime
import sys
from os.path import join
from arg_parsing import ini_arg_parser


def unload_db(login,
              password,
              tns,
              schemas,
              max_connetions):
    l_login = login
    l_password = password
    l_db_tns = tns
    l_max_connections = max_connetions

    shutil.rmtree(g_results_path + '/' + l_db_tns, ignore_errors=True)

    schema_unloader.initialize(db_tns=l_db_tns,
                               login=l_login,
                               password=l_password,
                               results_path=g_results_path,
                               db_scripts_dir=l_db_tns,
                               max_connections=l_max_connections)

    # list of schemas
    for schema in schemas:
        if schema != "":
            schema_unloader.unload(schema)

    schema_unloader.deinitialize()






if __name__ == '__main__':
    input_options = ini_arg_parser()
    now = datetime.datetime.now()

    # print(now)

    dt = now.strftime("%Y_%m_%d_%H%M%S")
    print(dt)

    g_results_path = join(input_options.result_dir, dt)

    print('results_path: ' + g_results_path)

    schemas_list = input_options.schemas.split(",")
    unload_db(login=input_options.db_login,
              password=input_options.db_pass,
              tns=input_options.db_tns,
              schemas=schemas_list,
              max_connetions=input_options.db_max_connections
              )
