#!/usr/bin/python3

import pathlib
import os
import glob
import re
import fdpwriter
from odf import opendocument, text, teletype

def fdp(f1):
    doc = opendocument.load(f1)
    alltext = []
    for item in doc.getElementsByType(text.Span):
        alltext.append(teletype.extractText(item))
    return '\n'.join(alltext).strip()

odtfiles = pathlib.Path("./bbdocs/").glob("*.odt")
for f in odtfiles:
    try:
        fulltext = fdp(f)
        context = re.findall(r'Contexte.*Mis', fulltext, re.DOTALL)
        jobname = re.findall(r'du poste\s*:(?:.+_)?(.+?)N°Code', fulltext, re.DOTALL)
        fdpwriter.fdpwrite(context,jobname,f)
    except IOError:
        print('Error opening',f)
