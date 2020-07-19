#!/usr/bin/python3

import pandas as pd

csvfile = "newplanning.csv"
xlsfile = "newplanning.xlsx"

readfile = pd.read_csv(r"newplanning.csv")
readfile.to_excel (r"newplanning.xlsx", index = None, header = True)

