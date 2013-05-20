import data_io, data_io_parallel
from sklearn.ensemble import RandomForestClassifier
from mpi4py import MPI
import numpy as np

def main():
    comm = MPI.COMM_WORLD
    size = comm.Get_size()   
    rank = comm.Get_rank()
    conn = data_io.get_db_conn()
    feature_name = open("feature_list.txt").read().split()
    # if size < len(feature_name):	# to be done!
    for table_name in ["TrainDeleted", "TrainConfirmed"]:
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
	    if table_name == "TrainDeleted":
		features_deleted = map(list, np.array(temp).T)
	    else:
		features_conf = map(list, np.array(temp).T)

    if rank == 0:
	features = [x[2:] for x in features_deleted + features_conf]
	target = [0 for x in range(len(features_deleted))] + [1 for x in range(len(features_conf))]
    	print("Training the Classifier")
    	classifier = RandomForestClassifier(n_estimators=50, 
                                        verbose=2,
                                        n_jobs=1,
                                        min_samples_split=10,
                                        random_state=1)
    	classifier.fit(features, target)
    
    	print("Saving the classifier")
    	data_io.save_model(classifier)
        print "Training completed, exit..."
        comm.Abort()
    
if __name__=="__main__":
    main()

