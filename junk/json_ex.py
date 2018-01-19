#from jsmin import jsmin
import json
from pprint import pprint

data = json.load(open('data.json'))

pprint(data)

print("1:",data["maps"][1]["id"])
print("2:",data["masks"]["id"])
print("3:",data["om_points"])