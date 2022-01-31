import os
import time
import subprocess


def cpu():
    cmd = ['mpstat', '1', '5']
    output = {}
    result = subprocess.run(cmd, stdout=subprocess.PIPE)
    result_average = result.stdout.decode("utf-8").split('\n')[-2].split()

    output['usr'] = float(result_average[2])*0.64
    output['sys'] = float(result_average[4])*0.64
    output['soft'] = float(result_average[7])*0.64

    return output


if __name__ == '__main__':
    cpu_overheads = []

    for _ in range(5):
        cpu_overheads.append(cpu())
    
    print(cpu_overheads)
    overall = 0.0
    for c in cpu_overheads:
        overall = overall+c['usr']+c['sys']+c['soft']
    print("Overall CPU Usage is :"+str(overall/5))
