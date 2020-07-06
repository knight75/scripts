#!/usr/bin/python3


import xlsxwriter
import fdpread

convar = str(fdpread.context)
jobnvar = str(fdpread.jobname)

workbook = xlsxwriter.Workbook('fdp.xlsx')
worksheet = workbook.add_worksheet()

worksheet.set_column('A:A', 20)
worksheet.set_column('B:B', 40)

bold = workbook.add_format({'bold': True})

worksheet.write('A1', 'Categories', bold)
worksheet.write('B1', 'Donnees', bold)

worksheet.write('A2', 'Contexte')
worksheet.write('B2', convar)

worksheet.write('A3', 'intitule du poste')
worksheet.write('B3', jobnvar)

workbook.close()


