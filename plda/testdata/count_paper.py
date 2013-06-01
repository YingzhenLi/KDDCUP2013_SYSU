#!/usr/bin/python

# get the documents like <word1><wordcount1><word2><wordcount2>...

import linecache
from mpi4py import MPI
import re

comm = MPI.COMM_WORLD
size = comm.Get_size()   
rank = comm.Get_rank()

D = 1000
iteration = 0
batchsize = D/size
f1 = open('~/kdd_data/rda/com_all_key.txt','r')
f2 = open('~/kdd_data/rda/com_all.txt', 'r')
f3 = open('~/kdd_data/topics/words_count.txt', 'w+')
vaguepaper = 0
stat = 0

linecache.clearcache()
startpoint = batchsize * rank + 1
outputs = ''
# get the paper keywords in batches
for i in range(batchsize):
    if startpoint > D:
	break
    words = re.sub(" ", "+", linecache.getline('com_all_key.txt', startpoint)[:-1])
    words = words.lower().split(';')
    counts = linecache.getline('com_all.txt', startpoint)[:-1].split(';')
    output = ''
    for j in range(len(words)):
	output = output + words[j] + ' ' + counts[j] + ' '
    outputs = outputs + output[:-1] + '\n'
    startpoint = startpoint + 1

lines = comm.gather(outputs)
if rank == 0:
    for line in lines:
	f3.write(line)

    if size * batchsize < D:
	outputs = ''
	startpoint = size * batchsize + 1
	while startpoint <= D:
	    words = re.sub(" ", "+", linecache.getline('com_all_key.txt', startpoint)[:-1])
	    words = words.lower().split(';')
	    counts = linecache.getline('com_all.txt', startpoint)[:-1].split(';')
	    output = ''
	    for j in range(len(words)):
		output = output + words[j] + ' ' + counts[j] + ' '
	    outputs = outputs + output[:-1] + '\n'
	    startpoint = startpoint + 1
	f3.write(outputs)

