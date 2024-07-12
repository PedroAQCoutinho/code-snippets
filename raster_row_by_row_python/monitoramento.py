import psutil
import time
import sys

def monitor_memory(pid, interval=1):
    try:
        process = psutil.Process(pid)
        while True:
            with open("memory_usage.log", "a") as f:
                mem_info = process.memory_info()
                f.write(f"Memory usage: {mem_info.rss / (1024 * 1024):.2f} MB\n")
            time.sleep(interval)
    except psutil.NoSuchProcess:
        print(f"Process {pid} not found.")
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python monitoramento.py <PID>")
        sys.exit(1)
    
    pid = int(sys.argv[1])
    monitor_memory(pid)
