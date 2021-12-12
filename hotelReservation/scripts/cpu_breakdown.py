import re
import subprocess
import statistics
from pathlib import Path

def get_virtual_cores():
    print("Running mpstat...")
    cpu_util = []
    for i in range(3):
        cmd = ['mpstat', '1', '15']
        # print("Running cmd: " + " ".join(cmd))
        output = {}
        result = subprocess.run(cmd, stdout=subprocess.PIPE)
        result_average = result.stdout.decode("utf-8").split('\n')[-2].split()
        overall = 100.00 - float(result_average[-1])
        cpu_util.append(overall)

    virtual_cores = statistics.mean(cpu_util)*0.64
    print("Virutal Cores Usage: " + str(virtual_cores))
    return virtual_cores   



def get_cpu_percentage(target):
    with open("./result/profile.svg", 'r') as fp:
        lines = fp.readlines()

    sum = 0.0
    for line in lines:
        if target in line:
            # print(line)
            l = re.findall(r"\d+\.\d+", line)
            # print(l)
            sum += float(l[0])

    return sum

def generate_flamegraph():
    print("Generating Flamegraph...")
    cmd1 = ['python3', './profile.py', '-F 99', '-f', '30']
    print("Running cmd: " + " ".join(cmd1))
    with open("./result/out.profile-folded", "wb") as outfile1:
        result = subprocess.run(cmd1, stdout=outfile1)
    
    cmd2 = ['./flamegraph.pl', './result/out.profile-folded']
    print("Running cmd: " + " ".join(cmd2))
    with open("./result/profile.svg", "wb") as outfile2:
        result = subprocess.run(cmd2, stdout=outfile2)

def get_cpu_breakdown(virtual_cores):
    print("Caculating CPU breakdown...")
    breakdown = {}
    breakdown['read'] = virtual_cores*get_cpu_percentage(">readv (")*0.01
    breakdown['write'] = virtual_cores*get_cpu_percentage(">writev (")*0.01
    breakdown['loopback'] = virtual_cores*get_cpu_percentage(">process_backlog (")*0.01
    breakdown['epoll'] = virtual_cores*get_cpu_percentage(">epoll_wait (")*0.01
    breakdown['envoy'] = virtual_cores*get_cpu_percentage(">wrk:worker_0 (")*0.01+virtual_cores*get_cpu_percentage(">wrk:worker_1 (")*0.01
    breakdown['envoy'] = breakdown['envoy']-(breakdown['read']+breakdown['write']+breakdown['loopback']+breakdown['epoll'])
    breakdown['app'] = virtual_cores*get_cpu_percentage(">frontend (")*0.01
    return breakdown

if __name__ == '__main__':
    Path("./result").mkdir(parents=True, exist_ok=True)
    virtual_cores = get_virtual_cores()
    generate_flamegraph()
    breakdown = get_cpu_breakdown(virtual_cores)
    print(breakdown)

{'read': 0.5137890133333334, 'write': 1.8791620266666664, 'loopback': 0.6585582933333334, 'epoll': 0.2668296533333333, 'envoy': 12.016424106666667, 'app': 9.20562304}