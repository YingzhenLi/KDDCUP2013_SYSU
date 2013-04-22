from collections import defaultdict
import data_io

def main():
    # get the samples from ValidPaper table, reusable
    print("Getting features for valid papers from the database")
    data = data_io.get_features_db("ValidPaper")
    # print [x[0] for x in data] return strings like "2165425L": hearders?
    author_paper_ids = [x[:2] for x in data]	# note again: index to 2
    features = [x[2:] for x in data]

    print("Loading the classifier")
    # reusable, but note that it's the class returned from the random forest classifier
    # need to be adjusted
    classifier = data_io.load_model()

    print("Making predictions")
    # we may write a classifier class containing these functions
    predictions = classifier.predict_proba(features)[:,1]	# return predictions (0 or 1)
    predictions = list(predictions)

    author_predictions = defaultdict(list)
    paper_predictions = {}

    # generating predictions, reusable
    for (a_id, p_id), pred in zip(author_paper_ids, predictions):	# matching predictions
        author_predictions[a_id].append((pred, p_id))

    for author_id in sorted(author_predictions):
        paper_ids_sorted = sorted(author_predictions[author_id], reverse=False)	# prediction sort from confirmed (0) to deleted (1), notice that the paper is more likely to be confirmed if the grade is closer to 0.
        paper_predictions[author_id] = [x[1] for x in paper_ids_sorted]

    print("Writing predictions to file")
    data_io.write_submission(paper_predictions)

if __name__=="__main__":
    main()
