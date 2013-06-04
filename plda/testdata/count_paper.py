#!/usr/bin/python

# get the documents like <word1><wordcount1><word2><wordcount2>...

import linecache
from mpi4py import MPI
import re, sys

def main():
    comm = MPI.COMM_WORLD
    size = comm.Get_size()   
    rank = comm.Get_rank()
    
    path = "/parastor/users/mcsfgc/kdd_data/"
    f1name = path + "txt/" + str(sys.argv[1])
    f2name = path + "txt/" + str(sys.argv[2])
    f3name = path + "topics/" + str(sys.argv[1])[:-4] + "_words_count.txt" 
    D = int(sys.argv[3])
    iteration = 0
    batchsize = D/size
    f1 = open(f1name,'r')
    f2 = open(f2name, 'r')
    f3 = open(f3name, 'w+')
    vaguepaper = 0
    stat = 0

    linecache.clearcache()
    startpoint = batchsize * rank + 1
    outputs = ''
    # get the paper keywords in batches
    for i in range(batchsize):
	if startpoint > D:
	    break
	words = re.sub(" ", "+", linecache.getline(f1name, startpoint)[:-1])
	words = words.lower().split(';')
	counts = linecache.getline(f2name, startpoint)[:-1].split(';')
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
		words = words.lower().split('|||')
		counts = linecache.getline('com_all.txt', startpoint)[:-1].split(';')
		output = ''
		for j in range(len(words)):
		    output = output + words[j] + ' ' + counts[j] + ' '
		outputs = outputs + output[:-1] + '\n'
		startpoint = startpoint + 1
	    f3.write(outputs)

if __name__ == '__main__':
    main()

