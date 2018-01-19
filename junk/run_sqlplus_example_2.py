from subprocess import Popen, PIPE
 
#function that takes the sqlCommand and connectString and returns the queryReslut and errorMessage (if any)
def runSqlQuery(sqlCommand, connectString):
   session = Popen(['sqlplus', '-silent', connectString], stdin=PIPE, stdout=PIPE, stderr=PIPE)
   session.stdin.write(sqlCommand)
   return session.communicate()

connectString = '/nolog'
sqlCommand = b'@test.sql'
queryResult, errorMessage = runSqlQuery(sqlCommand, connectString)

print (queryResult)
print (errorMessage)