from collections import defaultdict
import data_io, data_io_parallel
from mpi4py import MPI
import numpy as np

def main():
    comm = MPI.COMM_WORLD
    size = comm.Get_size()   
    rank = comm.Get_rank()
    conn = data_io.get_db_conn()
    feature_name = open("feature_list.txt").read().split()
    # if size < len(feature_name):	# to be done!
    for table_name in ["ValidPaper"]:
	if rank > 0:
            # getting features by parallel computing
	    print "getting features at node " + str(rank)
            feature = data_io_parallel.get_features_db_parallel(conn, rank, table_name, feature_name[rank - 1])
	else:
	    feature = data_io_parallel.get_trained_validation_data(conn, table_name)
	    
	# sending features to rank 0
	print "sending features to node " + str(rank)
	features = comm.gather(feature, root = 0)
        #print features
	if rank == 0:	  
	    temp = []
	    for f in features:
		temp.extend(f)  	    
	    print "Successfully got the features from " + table_name
	    data = map(list, np.array(temp).T)
    
    if rank == 0:
	author_paper_ids = [x[:2] for x in data]
	features = [x[2:] for x in data]

	print("Loading the classifier")
	classifier = data_io.load_model()
	#print classifier.feature_importances_

	print("Making predictions")
	predictions = classifier.predict_proba(features)[:,1]
	predictions = list(predictions)

	author_predictions = defaultdict(list)
	paper_predictions = {}

	for (a_id, p_id), pred in zip(author_paper_ids, predictions):
	    author_predictions[a_id].append((pred, p_id))

	for author_id in sorted(author_predictions):
            paper_ids_sorted = sorted(author_predictions[author_id], reverse=True)
            paper_predictions[author_id] = [x[1] for x in paper_ids_sorted]

	print("Writing predictions to file")
	data_io.write_submission(paper_predictions)
	print "Prediction completed, exit..."
        comm.Abort()

if __name__=="__main__":
    main()
