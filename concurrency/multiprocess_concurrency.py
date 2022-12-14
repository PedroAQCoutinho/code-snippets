"""
This is a prototype for concurrency based on multiprocessing
First part ir using the multiprocessing module and the second is using the concurrent.futures
"""

def do_something(seconds):
    print(f'Sleeping {seconds} second(s)...')
    time.sleep(seconds)
    return f'Done Sleeping...{seconds}'



import multiprocessing
import time


start = time.perf_counter()

#this creates several processes
processes = []
for i in range(5, 0, -1):
    p = multiprocessing.Process(target = do_something, args = [i])
    p.start()
    processes.append(p)

#This is used to prevent the code to keep foing further before the processes end up the tasks
for p in processes:
    p.join()


finish = time.perf_counter()
print(f'First part finished in {round(finish-start, 2)} second(s)')

from asyncio import as_completed
import concurrent.futures
import time

start = time.perf_counter()


with concurrent.futures.ProcessPoolExecutor() as executor:
    secs = [5, 4, 3, 2, 1]
    results = [executor.submit(do_something, sec) for sec in secs]

    for r in concurrent.futures.as_completed(results):
        print(r.result())

finish = time.perf_counter()

print(f'Second part finished in {round(finish-start, 2)} second(s)')