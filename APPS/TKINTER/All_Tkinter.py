#!/usr/bin/env python3

from subprocess import Popen


dbs = ['Oracle', 'SQLServer', 'DB2', 'Postgres', 'MySQL', 'SQLite']

for db in dbs:
   proc = Popen(['python3 {}_Tkinter.py'.format(db)], shell=True, cwd='/home/parfaitg/Documents/Meekness/APPS/TKINTER',
                stdin=None, stdout=None, stderr=None, close_fds=True)

