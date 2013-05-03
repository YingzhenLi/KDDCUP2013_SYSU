#!/usr/bin/python

# simple test of LDA on journals/conferences
# reuse data_io.py and onlinewikipedia.py functions

import numpy, sys, os
import onlineldavb as lda
import journal_conf_keyword_extraction as jcke
	
def main():
    # LDA: a documents contains all the keywords of some journal/conference
    # equivalent to cluster keywords over journals/conferences
    journal_or_conference = sys.argv[1]
    num = int(sys.argv[2])
    conn = jcke.get_db_conn()

    # default (num <=0 or > max number): figure out all the journals/conferences keywords
    if num <= 0 or (num >= 15151 and journal_or_conference == "journal") or (num >= 4545 and journal_or_conference == "conference"):
	query = """
		SELECT COUNT(*) FROM ##journal_or_conference##
		"""
	query = query.replace("##journal_or_conference##", journal_or_conference)
	conn.cursor.execute(query)
	num = conn.cursor.fetchall()	# number of journals/conferences to process

    # document parsing
    journal_conf_list = os.listdir("journal_conf_keyword")
    # check if txt files exist, then generate those docs
    if not num == len(journal_conf_list):
	jcke.journal_conf_keyword_generation(conn, num, journal_or_conference)
	journal_conf_list = os.listdir("journal_conf_keyword")
    
    # The number of journal/conference keyword sets in each batch
    batchsize = lambda num: num if num <= 100 else 100
    batch = batchsize(num)
    iteration_times = int(num/batch)
    # The total number of journals/conferences
    DocNum = lambda journal_or_conference: 15151 if journal_or_conference == "journal" else 4545
    D = DocNum(journal_or_conference)
    # The number of topics
    K = 100	# maybe some other numbers
    # Our vocabulary : we need some vocabulary set!
    vocab = dict()
    # Initialize the algorithm with alpha=1/K, eta=1/K, tau_0=1024, kappa=0.7
    online_LDA = lda.OnlineLDA(vocab, K, D, 1./K, 1./K, 1024., 0.7)

    # Run until we've seen D documents. (Feel free to interrupt *much* sooner than this.)
    for iteration in range(0, iteration_times):
	# getting documents (keyword sets)
	if iteration != iteration_times - 1:
    	    journal_conf_keyword_list = jcke.input_journal_conf_keywords(journal_conf_list[iteration * batch : (iteration + 1) * batch])
	else:
	    journal_conf_keyword_list = jcke.input_journal_conf_keywords(journal_conf_list[iteration * batch :])
        # online LDA for keyword sets
	# here we update the relative function in the package	(dangerous!)	
	online_LDA._vocab = jcke.vocabulary_generation(journal_conf_keyword_list, online_LDA._vocab)
	
        (gamma, bound) = online_LDA.update_lambda(journal_conf_keyword_list)
        # Compute an estimate of held-out perplexity
        (keywordids, keywordcts) = lda.parse_doc_list(journal_conf_keyword_list, online_LDA._vocab)
        perkeywordbound = bound * len(journal_conf_keyword_list) / (D * sum(map(sum, keywordcts)))
        print '%d:  rho_t = %f,  held-out perplexity estimate = %f' % \
            (iteration, online_LDA._rhot, numpy.exp(-perkeywordbound))

    # Save lambda, the parameters to the variational distributions over topics, and gamma, the parameters to the variational
    # distributions over topic weights for the articles analyzed in the last iteration.
    numpy.savetxt('lambda-%s.dat' % journal_or_conference, online_LDA._lambda)
    numpy.savetxt('gamma-%s.dat' % journal_or_conference, gamma)

if __name__ == '__main__':
    main()
