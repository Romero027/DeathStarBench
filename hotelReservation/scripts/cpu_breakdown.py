import re
import subprocess
from pathlib import Path




def get_percentage(target):
    with open("./result/profile.svg", 'r') as fp:
        lines = fp.readlines()

    sum = 0.0
    for line in lines:
        if target in line:
            print(line)
            l = re.findall(r"\d+\.\d+", line)
            print(l)
            sum += float(l[0])

    print(sum)

def generate_flamegraph():
    print("Generating Flamegraph...")
    cmd1 = ['python3', './profile.py', '-F 99', '-f 30']
    print("Running cmd: " + " ".join(cmd1))
    with open("./result/out.profile-folded", "wb") as outfile1:
        result = subprocess.run(cmd1, stdout=outfile1)
    
    cmd2 = ['./flamegraph.pl', 'out.profile-folded']
    print("Running cmd: " + " ".join(cmd2))
    with open("./result/profile.svg", "wb") as outfile2:
        result = subprocess.run(cmd2, stdout=outfile2)

if __name__ == '__main__':
    Path("./result").mkdir(parents=True, exist_ok=True)
    generate_flamegraph()
    get_percentage("kubelet (")