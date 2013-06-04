import csv
import json
import os
import pickle
import psycopg2
import gc	# collect memory

def paper_ids_to_string(ids):
    return " ".join([str(x) for x in ids])

conn_string = None

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

def get_paths():
    paths = json.loads(open("SETTINGS.json").read())
    for key in paths:
        paths[key] = os.path.expandvars(paths[key])
    return paths

def save_model(model):
    out_path = get_paths()["model_path"]
    pickle.dump(model, open(out_path, "w"))

def load_model():
    in_path = get_paths()["model_path"]
    return pickle.load(open(in_path))

def write_submission(predictions):
    submission_path = get_paths()["submission_path"]
    rows = [(author_id, paper_ids_to_string(predictions[author_id])) for author_id in predictions]
    writer = csv.writer(open(submission_path, "w"), lineterminator="\n")
    writer.writerow(("AuthorId", "PaperIds"))
    writer.writerows(rows)

def get_features_db(table_name):
    conn = get_db_conn()
    feature_table_list = open("feature_list.txt").read().split()	# load the feautures
    for feature_table_name in feature_table_list:
	feature_table_name = feature_table_name.replace("##DataTable##", table_name)
    	if not table_view_existence_db(feature_table_name, conn):	# feature view/table not exist
	    create_table(feature_table_name, conn)	# create feature view
    query = get_features_query(table_name)
    cursor = conn.cursor()
    cursor.execute(query)
    res = cursor.fetchall()
    return res

def table_view_existence_db(feature_view_name, conn):
    query = """
	select count(*) from pg_class where relname = '##DataTable##'
    """
    query = query.replace("##DataTable##", feature_view_name.lower())
    cursor = conn.cursor()
    cursor.execute(query)
    res = cursor.fetchall()
    return res[0][0] == 1

def create_view(feature_view_name, conn):
    query = open("feature_view/" + feature_view_name + ".sql").read().strip()
    cursor = conn.cursor()
    cursor.execute(query)
    conn.commit()
    # if running in the supercomputer, we keep the data in the memory
    del cursor
    gc.collect()
    res = True	# no check
    #res = table_view_existence_db(feature_view_name, conn)	# check if successfully created
    return res

def create_table(feature_table_name, conn):
    query = open("feature_table/" + feature_table_name + ".sql").read().strip()
    cursor = conn.cursor()
    cursor.execute(query)
    conn.commit()
    # if running in the supercomputer, we keep the data in the memory
    del cursor
    gc.collect()
    res = True	# no check
    #res = table_view_existence_db(feature_view_name, conn)	# check if successfully created
    return res

def drop_view(feature_view_name, conn):
    # no use
    if view_existence_db(feature_view_name, conn):
	query = """
		drop view ##DataTable##
	"""
	query = query.replace("##DataTable##", feature_view_name.lower())
	conn.cursor.execute(query)
	conn.commit()
    res = True	# no check
    #res = not table_view_existence_db(feature_view_name, conn)	# check if successfully dropped
    return res

def drop_table(feature_table_name, conn):
    # no use
    if view_existence_db(feature_table_name, conn):
	query = """
		drop view ##DataTable##
	"""
	query = query.replace("##DataTable##", feature_table_name.lower())
	conn.cursor.execute(query)
	conn.commit()
    res = True	# no check
    #res = not table_view_existence_db(feature_view_name, conn)	# check if successfully dropped
    return res

def get_features_query(table_name):
    query = open("feature_query.sql").read().strip()
    return query.replace("##DataTable##", table_name)
