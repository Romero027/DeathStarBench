import re
import numpy as np

file_name = 'logs.txt'
target = 'userClient.CheckUser'

result = []
with open(file_name, 'r') as fin:
    lines = fin.readlines()
    for l in lines:
        if target in l:
            if re.findall(r"\d+\.\d+", l):
                result.append(float(re.findall(r"\d+\.\d+", l)[0]))

latency = np.array(result)
print(np.percentile(latency, 50))

