#!/usr/bin/python3

import docx
import pathlib
import glob
import re

def fdp(f1):
    freader = docx.Document(f1)  # Read Docx files.
    alltext = []
    for p in freader.paragraphs:
        alltext.append(p.text)
    return '\n'.join(alltext)




docxfiles = pathlib.Path("./bbdocs/").glob("*.docx")
for f in docxfiles:
    try:
        fulltext = fdp(f)
        testf = re.findall(r'Contexte\s*:(.*)\s*Missions', fulltext, re.DOTALL)
        print(testf)
    except IOError:
        print('Error opening',f)
