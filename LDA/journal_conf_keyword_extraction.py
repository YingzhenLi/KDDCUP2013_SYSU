#!/usr/bin/python

# extracting keywords of some journal/conference

import re
import json
import os
import pickle
import psycopg2
from itertools import chain

# global variable
conn_string = None

# just copy from data_io.py
def get_paths():
    paths = json.loads(open("../PythonBenchmark/SETTINGS.json").read())
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
def print_keywords_to_file(conn, journal_conf_id):
    # print all the keywords of a journal/conference to a txt file "journal/conference_shortname.txt"   
    # query = open("journal_conf_keywords.sql").read().strip()
    query = """
	    SELECT keyword FROM paper WHERE journalid = ##journal_conf_id##
	    """
    query = query.replace("##journal_conf_id##", str(journal_conf_id[0]))
    cursor = conn.cursor()
    cursor.execute(query)
    res = map(list, cursor.fetchall())	# a list of paper keywords
    pickle.dump(res, open("journal_conf_keyword/" + str(journal_conf_id[0]) + ".pickle", "w"))
    check = 1	# to be modified
    return check

def get_journal_conf_id(conn, num, journal_or_conference = "journal"):
    query = """
	    SELECT id FROM ##journal_or_conference## LIMIT ##num##
	    """
    query = query.replace("##num##", str(num))
    query = query.replace("##journal_or_conference##", journal_or_conference)
    cursor = conn.cursor()
    cursor.execute(query)
    res = cursor.fetchall()
    return res

def journal_conf_keyword_generation(conn, num = 0, journal_or_conference = "journal"):
    # getting journal/conference's shortname and id list (journal_conf_name, journal_conf_id)
    journal_conf_list = get_journal_conf_id(conn, num, journal_or_conference)
    # print their keywords to files
    for journal_conf_id in journal_conf_list:
	print_keywords_to_file(conn, journal_conf_id)
    check = 1	# to be modified
    return check

def input_journal_conf_keywords(journal_conf_list):
    # input the keyword documents into a list for lda package
    journal_conf_keyword_list = []
    for journal_conf_pickle in journal_conf_list:
	# join to a string
	keywords = pickle.load(open("journal_conf_keyword/" + journal_conf_pickle))
	keywords = "".join(chain.from_iterable(keywords))
	keywords = re.sub('\n', ' ', keywords)
	journal_conf_keyword_list.append(keywords)
    return journal_conf_keyword_list

def vocabulary_generation(journal_conf_keyword_list, vocab):
    # just getting keywords from the phrases
    for keywords in journal_conf_keyword_list:
        keywords = keywords.lower()
        keywords = re.sub(r'[^a-z0-9]', ' ', keywords)	# to be modified!
	# print keywords
	keyword_set = keywords.split(' ')	# to be modified!
	for keyword in keyword_set:
	    # adding new keywords into the vocabulary
	    if keyword not in vocab:
		vocab[keyword] = len(vocab.keys()) + 1	# assigning new id 
    return vocab
