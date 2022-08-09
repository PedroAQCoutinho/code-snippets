"""
This is a prototype for concurrency based on multiprocessing
"""
from asyncio import as_completed
import concurrent.futures
import time

start = time.perf_counter()


def do_something(seconds):
    print(f'Sleeping {seconds} second(s)...')
    time.sleep(seconds)
    return f'Done Sleeping...{seconds}'


with concurrent.futures.ProcessPoolExecutor() as executor:
    secs = [5, 4, 3, 2, 1]
    results = [executor.submit(do_something, sec) for sec in secs]

    for r in concurrent.futures.as_completed(results):
        print(r.result())

finish = time.perf_counter()

print(f'Finished in {round(finish-start, 2)} second(s)')