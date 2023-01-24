import argparse
from os.path import join

def ini_arg_parser():
    parser = argparse.ArgumentParser(description='Oracle db objects unloader command line tool.',
                                     add_help=True)

    parser.add_argument('-db-login',
                        action='store',
                        dest='db_login',
                        help='Provide Oracle user (schema) name with the access to Oracle dictionaries and system packages (dbms_metadata)',
                        required=True,
                        default='system')

    parser.add_argument('-db-pass',
                        action='store',
                        dest='db_pass',
                        help='Provide password for the Oracle user',
                        required=True)

    parser.add_argument('-db-tns',
                        action='store',
                        dest='db_tns',
                        help='Provide tns for the Oracle db',
                        required=True)

    parser.add_argument('-db-max-connections',
                        action='store',
                        dest='db_max_connections',
                        help='Provide the number of connections (sessions) to unload objects in parallel',
                        required=False,
                        default=5)

    parser.add_argument('-schemas',
                        action='store',
                        dest='schemas',
                        help='Provide schema list for unload separated by comma',
                        required=True)

    parser.add_argument('-result-dir',
                        action='store',
                        dest='result_dir',
                        help='Provide result directory path for the output result',
                        required=False,
                        default=join("c:/", "db_unloader_results"))
    options = parser.parse_args()
    return options
#DEFAULT_MAX_CONNECTIONS = 5