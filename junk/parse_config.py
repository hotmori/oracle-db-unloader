from enum import Enum
import re

with open('my-file.ini') as fp:
  print(fp)
  #for i, line in enumerate(fp.readline()):
		  # Remove comments
    #line = re.sub('[#;].*', '', line).strip()
    


		# Skip blank lines
		#if line == '':
		#	continue
  #
		## Error out on lines without a =
		#if not '=' in line:
		#	raise Exception('No = on line {}'.format(i + 1))
  #
		## Everything before the first = is a key
		#line = line.split('=')
		#key = line[0].strip()
  #
		## Everything after that is the value
		#value = '='.join(line[1:]).strip()

 for file in listdir(temp_path):
    f = open(join(temp_path,file),'r')
    for line in f:
      line = line.strip()
      if not line:
        continue
      unload_db_object_scripts.append(line)
    f.close