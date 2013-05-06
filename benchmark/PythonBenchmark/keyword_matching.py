#!/usr/bin/python

# just matching the paper's keywords with the author's confirmed/deleted keywords
# usage: python keyword_matching.py (table_name) (test_table)

import re, json, os, pickle, psycopg2, sys, data_io

# global variable
conn_string = None

# just copy from data_io.py
def get_paths():
    paths = json.loads(open("SETTINGS.json").read())
    for key in paths:
        paths[key] = os.path.expandvars(paths[key])
    return paths

def get_db_conn():
    # Horrible coding practice. Don't use global variables. Don't follow this example.
    # Wanted to ask for a password, didn't have time to refactor to be OO.
    global conn_string
    if conn_string is None:
        conn_string = get_paths()["postgres_conn_string"]
    if "##AskForPassword##" in conn_string:
        password = raw_input("PostgreSQL Password: ")
        conn_string = conn_string.replace("##AskForPassword##", password)
    conn = psycopg2.connect(conn_string)
    return conn

# my work -- yingzhen
def keyword_extraction(conn, paperid):
    # creating a keyword list of some
    query = """
	    SELECT keyword FROM paper WHERE id = ##paperid##
	    """
    query = query.replace("##paperid##", str(paperid))
    cursor = conn.cursor()
    cursor.execute(query)
    keywords_raw = cursor.fetchall()	# a list of paper keywords
    # NOTE: a problem should be solved if there are several returned results with differenct keywords!
    #if len(keywords_raw) > 1:	# more than 1 returned results
	#keywords_raw = keywords_raw[0]	# to be modified!
    # from the redundancy of the paper table we need to filter out the '' keywords.
    keywords = ''	# a string (temporal)
    for words in keywords_raw:
	if not words[0] == '':
	    keywords = keywords + words[0] + ' '	# convenient to split
    # creating the keyword list
    keywords = re.sub(r'[^a-z0-9^-]', ' ', keywords)	# to be modified!
    keyword_list = keywords.split(' ')
    # make the keywords be unique (work out the redundancy)
    keyword_list = sorted(set(keyword_list),key=keyword_list.index)
    keyword_list.remove('')
    return keyword_list

def get_confirmed_or_deleted_keywords(conn, authorid, table_name):
    # getting confirmed/deleted keywords of some author as well as its frequency
    # normalization optional
    # NOTE: if the redundancy is worked out the query should be
    #query = """
	#    SELECT paperid, p.keyword FROM ##table_name##
	#    LEFT OUTER JOIN (SELECT id, keyword FROM paper) p
	#    ON p.id = paperid
	#    WHERE authorid = ##authorid##
	#    """
    # then we do not call the keyword_extraction() function
    query = """
	    SELECT paperid FROM ##table_name## WHERE authorid = ##authorid##
	    """
    query = query.replace("##table_name##", table_name)
    query = query.replace("##authorid##", str(authorid))
    cursor = conn.cursor()
    cursor.execute(query)
    #id_keyword_list = cursor.fetchall()	# a list of paperids and keywords [(id, keywords),...]
    paperid_list = cursor.fetchall()
    # creating a list of confirmed/deleted keywords
    keyword_list = []
    #for id_keywords in id_keyword_list:
    for paperid in paperid_list:
	#paper_keyword_list = re.sub(r'[^a-z0-9^-]', ' ', id_keywords[1]).split(' ')	# to be modified!
	paper_keyword_list = keyword_extraction(conn, paperid[0])	# temp test
	keyword_list.extend(paper_keyword_list)
    return keyword_list

def keyword_matching(conn, authorid, paperid, table_name):
    # see if the paper written by the author contains the keywords confirmed/deleted by the author
    coauthor_list = find_coauthor(conn, authorid, table_name)
    # we extract the keywords of coauthors as the author's keywords
    keyword_coauthor = []
    for coauthor in coauthor_list:
	keyword_coauthor.extend(get_confirmed_or_deleted_keywords(conn, coauthor[0], table_name))
    # calculate the frequency of appearence and normalize (optional)
    size = float(len(keyword_coauthor))	# numbers of keywords appeared
    keyword_frequency = dict()
    for keyword in keyword_coauthor:
	if keyword not in keyword_frequency:
	    keyword_frequency[keyword] = keyword_list.count(keyword)/size	# implying the prior
    # getting the paper's keywords
    keyword_list = keyword_extraction(conn, paperid)
    keyword_matched = dict()
    for keyword in keyword_list:
	if keyword in keyword_frequency:
	    keyword_matched[keyword] = keyword_frequency[keyword]
    return keyword_matched

def find_coauthor(conn, authorid, table_name):
    # finding coauthors confirmed/deleted by some other authors
    # to be modified: matching
    if table_name == 'trainconfirmed':
	table_name = 'TrainConfirmed'
    if table_name == 'traindeleted':
	table_name = 'TrainDeleted'
    feature_view_name = table_name + 'CoAuthors'
    if not data_io.table_view_existence_db(feature_view_name, conn):	# feature view/table not exist
	    data_io.create_view(feature_view_name, conn)	# create feature view
    query = """
	    SELECT Author2 FROM ##table_name##CoAuthors WHERE Author1 = ##authorid##
	    """
    query = query.replace("##table_name##", table_name)
    query = query.replace("##authorid##", str(authorid))
    cursor = conn.cursor()
    cursor.execute(query)
    res = cursor.fetchall()	# list of tuples
    return res

def main(table_name, test_table):
    # generating the authors' confirmed/deleted keywords
    conn = get_db_conn()
    query = """
	    SELECT paperid, authorid FROM ##table_name##
	    """
    query = query.replace("##table_name##", test_table)
    cursor = conn.cursor()
    cursor.execute(query)
    author_paper_list = cursor.fetchall()	# we get the authorids and paperids to test here
    keyword_matched_list = []
    for author_paper in author_paper_list:
	keyword_matched_list = keyword_matching(conn, author_paper[0], author_paper[1], table_name)
    return keyword_matched_list

if __name__ == '__main__':
    table_name = str(sys.argv[1])
    test_table = str(sys.argv[2])
    res = main(table_name, test_table)
    # optional: saving the results
    pickle.dump(res, open("matched_" + str(table_name) + "_" + str(test_table) + ".pickle", "w"))
