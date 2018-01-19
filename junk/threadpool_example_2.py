from concurrent.futures import ThreadPoolExecutor, wait, as_completed
from time import sleep
from random import randint
 
def return_after_5_secs(num):
    time_to_sleep = randint(1, 5)
    sleep(time_to_sleep)
    return "Return of {}".format(num) + ", was sleeping: " + str(time_to_sleep)
 
pool = ThreadPoolExecutor(5)
futures = []
for x in range(5):
    futures.append(pool.submit(return_after_5_secs, x))
 
for x in as_completed(futures):
    print(x.result())