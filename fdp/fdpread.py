#!/usr/bin/python3

import docx
import pathlib
import glob
import re
import fdpwriter

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
        context = re.findall(r'Contexte\s*:(.*)\s*Missions', fulltext, re.DOTALL)
        jobname = re.findall(r'du poste\s*:(.*)\s\n*N° Visi', fulltext, re.DOTALL)
        fdpwriter.fdpwrite(context,jobname,f)
    except IOError:
        print('Error opening',f)
