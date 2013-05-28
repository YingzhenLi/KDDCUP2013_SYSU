#!/usr/bin/python

# graph search: searching connections and paths 
# define: connection (direct), path (indirect)
# see algorithm.tex (or pdf) for details
# object: author, paper, affiliation, journal, conference

import re

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
	query = query.replace('#arg1value#', re.sub(r'[[]', '(', re.sub(r'[]]', ')', arg1_value)))
	query = query.replace('#arg2value#', re.sub(r'[[]', '(', re.sub(r'[]]', ')', arg1_value)))
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
    if type(arg2_value) == int:
	arg2_value = [arg2_value]
    res = []
    for table_name in searching_table:
	query = """
	        SELECT #arg1#, #arg2# FROM #DataTable#
	    	WHERE #arg1# in #arg1value#
	    	"""
	query = query.replace('#arg1#', query_dict[table_name][arg1_name])
	query = query.replace('#arg2#', query_dict[table_name][arg2_name])
	query = query.replace('#arg1value#', re.sub(r'[[]', '(', re.sub(r'[]]', ')', arg1_value)))
	query = query.replace('#DataTable#', table_name)
	cursor.execute(query)
	res.extend(map(list, cursor.fetchall()))
    objects = []
    for obs in res:
	objects = list(set(objects) & set(obs))	# no overlapping
    return objects

def get_neighbors(conn, arg1_name, arg1_value):
    # search for all the neighbors (any arg2_name) of arg1_name object arg1_value
    global table_dict	# any other improvement?
    neighbors = dict{}
    for arg2_name in table_dict[arg1_name]:
	# here we automatically categorized the neighbors
	neighbors[arg2_name] = get_connected_objects(conn, arg1_name, arg1_value, arg2_name)
    return neighbors

def get_path_length(conn, arg1_name, arg1_value, arg2_name, arg2_value, stop, path_length = 0):
    # get 0 if the two objects are without path connection
    # full searching? horrible! so we defined the upbound of path length 'stop'
    # if defining connection weights we can instead search the shortest path
    if len(is_connected(conn, arg1_name, arg1_value, arg2_name, arg2_value))!= 0:
	return path_length + 1
    neighbors_arg1 = get_neighbors(conn, arg1_name, arg1_value)
    path_length = path_length + 1
    for arg_name in neighbors_arg1:
	path_length = get_path_length(conn, arg_name, neighbors_arg1[arg_name], arg2_name, arg2_value, stop - 1, path_length)	# horrible computation!
    	if path_length <= stop:
	    return path_length
    return stop + 1	# we use stop + 1 to represent infinity

		
