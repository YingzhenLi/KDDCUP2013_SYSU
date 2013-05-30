#!/usr/bin/python

# onlinewikipedia.py: Demonstrates the use of online VB for LDA to
# analyze a bunch of random Wikipedia articles.
#
# Copyright (C) 2010  Matthew D. Hoffman
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

import cPickle, string, numpy, getopt, sys, random, time, re, pprint
import linecache
import onlineldavb
import wikirandom

def main():
    """
    Downloads and analyzes a bunch of random Wikipedia articles using
    online VB for LDA.
    """

    # The number of documents to analyze each iteration
    batchsize = 100
    # The total number of documents in Wikipedia
    D = 1000
    # The number of topics
    K = 100

    # How many documents to look at
    documentstoanalyze = int(D/batchsize)

    # Our vocabulary
    vocab = file('./com_all_words.txt').readlines()
    W = len(vocab)

    # Initialize the algorithm with alpha=1/K, eta=1/K, tau_0=1024, kappa=0.7
    olda = onlineldavb.OnlineLDA(vocab, K, D, 1./K, 1./K, 1024., 0.7)
    # Run until we've seen D documents. (Feel free to interrupt *much*
    # sooner than this.)
    for iteration in range(0, documentstoanalyze):
        # Download some articles
        docset = []
	counts = []
	linecache.clearcache()
	startpoint = iteration * batchsize + 1
	# get the paper keywords in batches
	for i in range(batchsize):
	    f1 = open('com_all_key.txt','r')
	    f2 = open('com_all.txt', 'r')
	    docset.append(linecache.getline('com_all_key.txt', min(D, startpoint + i))[:-1])
	    counts.append(linecache.getline('com_all.txt', min(D, startpoint + i))[:-1])
        # Give them to online LDA
	# print docset[0]
        (gamma, bound) = olda.update_lambda(docset, counts)
        # Compute an estimate of held-out perplexity
        (wordids, wordcts) = onlineldavb.parse_doc_list(docset, olda._vocab, counts)
	# print [olda._vocab[x] for x in docset[0].split(';')], wordids[0], wordcts[0]
        perwordbound = bound * len(docset) / (D * sum(map(sum, wordcts)))
        print '%d:  rho_t = %f,  held-out perplexity estimate = %f' % \
            (iteration, olda._rhot, numpy.exp(-perwordbound))

        # Save lambda, the parameters to the variational distributions
        # over topics, and gamma, the parameters to the variational
        # distributions over topic weights for the articles analyzed in
        # the last iteration.
        if (iteration % 10 == 0):
            numpy.savetxt('lambda_paper-%d.dat' % iteration, olda._lambda)
            numpy.savetxt('gamma_paper-%d.dat' % iteration, gamma)

if __name__ == '__main__':
    main()
