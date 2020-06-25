#!/usr/bin/python3

import docx
import pathlib
import glob

def fdp(f1):
    freader = docx.Document(f1)  # Read Docx files.
    rtext = ""
    alltext = []
    for para in freader.paragraphs:
        alltext.append(para.text)
        rtext = '\n'.join(alltext)

        print(rtext)

    return

import pathlib

docxfiles = pathlib.Path("./bbdocs/").glob("*.docx")
for f in docxfiles:
    try:
        print(f)
        fdp(f)
    except IOError:
        print('Error opening',f)
