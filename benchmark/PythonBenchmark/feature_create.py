#!/usr/bin/python

# create table to save the features

import data_io

def main():
    conn = data_io.get_db_conn()
    cursor = conn.cursor()
    if not data_io.table_view_existence_db('AP_features', conn):
	query = """
		CREATE TABLE AP_features (
		Result int, authorid bigint, paperid bigint, AP float, AP_PP float, AP_PJ_JP 			float, AP_PC_CP float, AP_PJ_JJ_JP float, AP_PC_CC_CP float)
		"""
	cursor.execute(query)
	conn.commit()
    query = """
	    COPY AP_features FROM '##path##sampleTrain.txt' DELIMITER ' '
	    """
    query = query.replace('##path##', '/home/yingzhen/Projects/KDDCUP2013/benchmark/PythonBenchmark/')
    cursor.execute(query)
    conn.commit()
    query = """
	    SELECT * FROM AP_features LIMIT 3
	    """
    cursor.execute(query)
    res = cursor.fetchall()
    return res

if __name__ == "__main__":
    main()
