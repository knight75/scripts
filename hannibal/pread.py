#!/usr/bin/python3

import tabula

file = "planning.pdf"

tabula.convert_into(file,"newplanning.csv",pages=1)

