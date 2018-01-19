import subprocess

"""

Example of running a sqlplus script from python 2.6.6.

"""

def run_sqlplus(sqlplus_script):

    """

    Run a sql command or group of commands against
    a database using sqlplus.

    """

    p = subprocess.Popen(['sqlplus','/nolog'],stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,stderr=subprocess.PIPE)
    (stdout,stderr) = p.communicate(sqlplus_script)
    stdout_lines = stdout.split("\n")

    return stdout_lines

sqlplus_script="""
connect test/test
select * from dual;
exit

"""

sqlplus_output = run_sqlplus(sqlplus_script)

#for line in sqlplus_output:
#    print line