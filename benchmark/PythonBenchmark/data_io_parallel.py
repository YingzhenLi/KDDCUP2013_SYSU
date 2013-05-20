#!/usr/bin/python
# data io for parallel computing

import data_io
import numpy as np

# new: for parallel computing
def get_features_db_parallel(conn, rank, table_name, feature_name):
    if "##DataTable##" in feature_name:
	feature_name = feature_name.replace("##DataTable##", table_name)
    if not data_io.table_view_existence_db(feature_name, conn):	# feature view/table not exist
	print "view " + feature_name + " not exist, creating..."
	data_io.create_table(feature_name, conn)	# create feature view
    if table_name in feature_name:
	feature_name = feature_name.replace(table_name, "_")
    print "getting " + feature_name + " ..."
    query = open("feature_parallel/" + feature_name + ".sql").read().strip()
    query = query.replace("##DataTable##", table_name)
    cursor = conn.cursor()
    cursor.execute(query)
    # NOTE: get the column vector, for better adjunction of matrix we use the numpy package
    res = map(list, cursor.fetchall())
    # return row vector for adjunction
    res = map(list, np.array(res).T)
    return res

# for rank 0 node we only get the paperid and authorid
def get_trained_validation_data(conn, table_name):
    print "getting AuthorId and PaperId ..."
    query = """
	    SELECT AuthorId, PaperId from ##DataTable## t
	    LEFT OUTER JOIN Paper p ON t.PaperId=p.Id
    	    """
    query = query.replace("##DataTable##", table_name)
    cursor = conn.cursor()
    cursor.execute(query)
    res = map(list, cursor.fetchall())
    res = map(list, np.array(res).T)
    return res


