#!/usr/bin/python3

import shutil
import os
import re

files = os.listdir("./test/") 

print(files)

reg = r"Interface01\s*:\s*adress\s+(.*)"

with open('filename') as f:
    m = re.search(reg, f.read())
    if m:
        print(m.group(1))

