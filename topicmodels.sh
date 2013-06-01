#!/bin/bash
# bash file for topic models
# need to make infer mpi_lda inadvance in plda
cd ~/KDDCUP2013_SYSU/plda/testdata
nohup otherun --host c1,c2,c3,c4,c5,c6,c7,c8,c9,c10 -n 100 python count_paper.py &
echo running count_paper on pid $!
wait
echo end running
let num_topics=10
# set alpha = 0.2/num_topics
# training
cd ~/KDDCUP2013_SYSU/plda/
nohup otherun --host c1,c2,c3,c4,c5,c6,c7,c8,c9,c10 -n 10 ./mpi_lda --num_topics $num_topics --alpha 0.02 --beta 0.01 --training_data_file ~/kdd_data/topics/words_count.txt --model_file ~/kdd_data/topics/lda_model.txt --burn_in_iterations 100 --total_iterations 150 &
echo running mpi_lda on pid $!
wait
echo end running
# inference
nohup ./infer --alpha 0.02 --beta 0.01 --inference_data_file ~/kdd_data/topics/words_count.txt --inference_result_file ~/kdd_data/topics/inference_result.txt --model_file ~/kdd_data/topics/lda_model.txt --total_iterations 15 --burn_in_iterations 10 &
echo running infer on $!
wait
echo end running 
# cd /path/to/PythonBenchmark
# nohup python PaperTopic.py &> PaperTopic_log &
# echo $!
