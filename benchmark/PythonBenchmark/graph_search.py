#!/usr/bin/python

# graph search: searching connections and paths 
# define: connection (direct), path (indirect)
# see algorithm.tex (or pdf) for details
# object: author, paper, affiliation, journal, conference

import re
import data_io

table_dict = {'author': ['Author', 'PaperAuthor'], 'paper': ['Paper', 'PaperAuthor'], 'affiliation': ['Author', 'PaperAuthor'], 'journal': ['Paper'], 'conference': ['Paper']}

query_dict = {'Author': {'author': 'id', 'affiliation': 'affiliation'}, 'PaperAuthor': {'author': 'authorid', 'paper': 'paperid', 'affiliation': 'affiliation'}, 'Paper': {'paper': 'id', 'journal': 'journalid', 'conference': 'conferenceid'}}

def is_connected(conn, arg1_name, arg1_value, arg2_name, arg2_value):
    # get the searching table
    # arg1_value and arg2_value are expected to be list or int
    global table_dict	# any other improvement?
    global query_dict
    searching_table = list(set(table_dict[arg1_name]) & set(table_dict[arg2_name]))
    if len(searching_table) == 0:	# not directly connected
	return []
    # start searching:
    cursor = conn.cursor()
    if type(arg1_value) == int:
	arg1_value = [arg1_value]
    if type(arg2_value) == int:
	arg2_value = [arg2_value]
    for table_name in searching_table:
	query = """
	    	SELECT #arg1#, #arg2# FROM #DataTable#
	    	WHERE #arg1# in #arg1value# AND #arg2# in #arg2value# 
	    	"""
	query = query.replace('#arg1#', query_dict[table_name][arg1_name])
	query = query.replace('#arg2#', query_dict[table_name][arg2_name])
	query = query.replace('#arg1value#', re.sub(r'[[]', '(', re.sub(r'[]]', ')', str(arg1_value))))
	query = query.replace('#arg2value#', re.sub(r'[[]', '(', re.sub(r'[]]', ')', str(arg2_value))))
	query = query.replace('#DataTable#', table_name)
	cursor.execute(query)
	res = cursor.fetchall()
	if len(res[0]) != 0:	# get direct connection
	    return res	# [(arg1_value, arg2_value), ...]
    # no such direct connection
    return []

def get_connected_objects(conn, arg1_name, arg1_value, arg2_name):
    # get all arg2_name objects connected to arg1_name object arg1_value
    global table_dict	# any other improvement?
    global query_dict
    searching_table = list(set(table_dict[arg1_name]) & set(table_dict[arg2_name]))
    if len(searching_table) == 0:	# not directly connected
	return []
    cursor = conn.cursor()
    if type(arg1_value) == int:
	arg1_value = [arg1_value]
    res = []
    temp = []
    for table_name in searching_table:
	query = """
	        SELECT #arg1#, #arg2# FROM #DataTable#
	    	WHERE #arg1# in #arg1value#
	    	"""
	query = query.replace('#arg1#', query_dict[table_name][arg1_name])
	query = query.replace('#arg2#', query_dict[table_name][arg2_name])
	query = query.replace('#arg1value#', re.sub(r'[[]', '(', re.sub(r'[]]', ')', str(arg1_value))))
	query = query.replace('#DataTable#', table_name)
	print query
	cursor.execute(query)
	res.extend(map(list, cursor.fetchall()))
    if len(searching_table) > 1:
    	for obs in res:
	    temp = list(set(temp) & set(obs))	# no overlapping
    else:
	temp = res
    neighbors = {x: set() for x in arg1_value}
    print temp
    for neighbor in temp:
	neighbors[neighbor[0]].add(neighbor[1])
    return neighbors

def get_neighbors(conn, arg1_name, arg1_value):
    # search for all the neighbors (any arg2_name) of arg1_name object arg1_value
    global table_dict	# any other improvement?
    neighbors = dict()
    arg2_list = set()
    for table_name in table_dict[arg1_name]:
	arg2_list = arg2_list.union(set(query_dict[table_name].keys()))
    arg2_list = arg2_list - set([arg1_name])
    for arg2_name in arg2_list:
	# here we automatically categorized the neighbors
	neighbors[arg2_name] = get_connected_objects(conn, arg1_name, arg1_value, arg2_name)
    return neighbors

