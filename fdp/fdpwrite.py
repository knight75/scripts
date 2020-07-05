#!/usr/bin/python3


import xlsxwriter
import fdpread

convar = str(fdpread.testf)

# Create an new Excel file and add a worksheet.
workbook = xlsxwriter.Workbook('fdp.xlsx')
worksheet = workbook.add_worksheet()

# Widen the first column to make the text clearer.
worksheet.set_column('A:A', 20)
worksheet.set_column('B:B', 40)

# Add a bold format to use to highlight cells.
bold = workbook.add_format({'bold': True})

# Write some simple text.
worksheet.write('A1', 'Categories', bold)
worksheet.write('B1', 'Donnees', bold)

# Text with formatting.
worksheet.write('A2', 'Contexte')
worksheet.write('B2', convar)

# Write some numbers, with row/column notation.
worksheet.write(2, 0, 123)
worksheet.write(3, 0, 123.456)


workbook.close()


