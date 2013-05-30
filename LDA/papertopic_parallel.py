#!/usr/bin/python

# modified Hoffman's code for parallel computing -- yingzhen

import cPickle, string, numpy, getopt, sys, random, time, re, pprint

import onlineldavb
import wikirandom
import linecache
from mpi4py import MPI

def main():
    """
    Downloads and analyzes a bunch of random Wikipedia articles using
    online VB for LDA.
    """
    comm = MPI.COMM_WORLD
    size = comm.Get_size()   
    rank = comm.Get_rank()
    # The number of documents to analyze each iteration
    batchsize = 100
    # The total number of documents in Wikipedia
    D = 1000	#D = 2129792 for the whole set
    # The number of topics
    K = 30

    # Our vocabulary
    vocab = file('./com_all_words.txt').readlines()
    W = len(vocab)

    # Initialize the algorithm with alpha=1/K, eta=1/K, tau_0=1024, kappa=0.7
    olda = onlineldavb.OnlineLDA(vocab, K, D, 1./K, 1./K, 1024., 0.7)
    # Run until we've seen D documents. (Feel free to interrupt *much*
    # sooner than this.)
    iteration = 0
    while iteration * batchsize * size <= D:	
        # Download some articles
        docset = []
	counts = []
	linecache.clearcache()
	startpoint = iteration * batchsize * size + batchsize * rank + 1
	if startpoint > D:	# search to the end
	    break	# stop
	# get the paper keywords in batches
	for i in range(batchsize):
	    f1 = open('com_all_key.txt','r')
	    f2 = open('com_all.txt', 'r')
	    docset.append(linecache.getline('com_all_key.txt', min(D, startpoint))[:-1])
	    counts.append(linecache.getline('com_all.txt', min(D, startpoint))[:-1])
	    startpoint = startpoint + 1
	# print type(docset), type(docset[0]), docset[0]
        # Give them to online LDA
        (gamma, bound) = olda.update_lambda(docset, counts)
        # Compute an estimate of held-out perplexity
        (wordids, wordcts) = onlineldavb.parse_doc_list(docset, olda._vocab, counts)
	# print wordcts[0:5]
        perwordbound = bound * len(docset) / (D * sum(map(sum, wordcts)))
        print '%d:  rho_t = %f,  held-out perplexity estimate = %f' % \
            (iteration, olda._rhot, numpy.exp(-perwordbound))
	iteration = iteration + 1
        # Save lambda, the parameters to the variational distributions
        # over topics, and gamma, the parameters to the variational
        # distributions over topic weights for the articles analyzed in
        # the last iteration.
	# print olda._lambda[0]
    gammas = comm.gather(gamma, root = 0)
    lambdas = comm.gather(olda._lambda, root = 0)
    if rank == 0:
	gamma_result = numpy.vstack((x for x in gammas))
	lambda_result = numpy.vstack((x for x in lambdas))
	numpy.savetxt('lambda_parallel.dat', olda._lambda)
        numpy.savetxt('gamma_parallel.dat', gamma)

if __name__ == '__main__':
    main()
