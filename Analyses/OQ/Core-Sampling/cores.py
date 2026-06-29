import numpy as np
import os

os.chdir("/home/hootseer/Documents/Thesis/data/OQ/Core-Sampling/")

floats = np.logspace(0, 14, num=15, base=2)
cores = []

for i in range(len(floats)):
  cores.append(int(floats[i]))

for i in cores:
  with open('job_template.txt', 'r') as file:
    data = file.read()
    data = data.replace("{Samples}", str(i))
    with open('job_'+str(i)+'.ini', 'w') as output:
    	output.write(data)

