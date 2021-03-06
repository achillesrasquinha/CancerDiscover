#!/bin/bash

        #Helikar Lab, University of Nebraska, Lincoln  copyright 2016
        #Developed by Greyson Biegert and Akram Mohammed
        #GPL-3.0

#SBATCH --time=23:00:00         # Run time in hh:mm:ss
#SBATCH --mem=60000             # Minimum memory required per CPU (in megabytes)
#SBATCH --job-name=MasterScript3
#SBATCH --error=/home/general/data/CancerDiscover/Outputs/job.%J.err
#SBATCH --output=/home/general/data/CancerDiscover/Outputs/job.%J.out

start=$(date +%s)
#this script constitutes the third leg of the pipeline, from feature selection outputs to model training and testing.
cd /home/general/data/CancerDiscover/Scripts

#this records the memory usage
echo CPU: `top -b -n1 |grep "Cpu(s)" |awk '{print $2 + $4}' ` > ../Temp/memoryUsage1_ms3.temp
FREE_DATA=`free -m | grep Mem`
CURRENT=`echo $FREE_DATA | cut -f3 -d' '`
TOTAL=`echo $FREE_DATA | cut -f2 -d' '`
echo RAM: $(echo "scale = 2; $CURRENT/$TOTAL*100"| bc) > ../Temp/memoryUsage2_ms3.temp
cat ../Temp/memoryUsage1_ms3.temp ../Temp/memoryUsage2_ms3.temp > ../Logs/memoryUsage_ms3.txt

#making chunk files by parsing the output files from feature selection
perl chunkMaker.pl &
wait

#selecting thresholds of the ranked list of features
bash thresholdSelector_pc.bash &
wait

#removal of empty files
bash emptyFileRemover.bash &
wait

#Matching lists of ranked features with associated data (expressionSet matricies)
perl trainThresholdMaker.pl &
wait

#removal of empty files
bash emptyFileRemover.bash &
wait

#Splitting the data and head sections
perl processingBeforeTransposing2.pl &
wait

#Head section completion
perl preprocessingContinued2.pl &

#Data matrix transposition
perl transposer2.pl &
wait

#Addition of class variables
perl sampleNumberClassPaster2.pl &
wait

#each piece of the arrf is compiled into single file, with the correct orientation
perl concatenationTRAIN2.pl &
wait

#data partitioning
perl dataPartitioning2.pl Configuration.txt &
wait

#model training
#this will TRAIN the files for top 1% of features
perl trainModels_top1pc.pl Configuration.txt &
wait

#this will TRAIN the files for top 10% of features
perl trainModels_top10pc.pl Configuration.txt &
wait

#this will TRAIN the files for the top 33% of features
perl trainModels_top33pc.pl Configuration.txt &
wait

#this will TRAIN the files for the top 66% of features
perl trainModels_top66pc.pl Configuration.txt &
wait

#this will TRAIN the files for the top 100% of features
perl trainModels_top100pc.pl Configuration.txt &
wait

#this will TRAIN the files for the top 25 features
perl trainModels_top25features.pl Configuration.txt &
wait

#this will TRAIN the files for the top 50 features
perl trainModels_top50features.pl Configuration.txt &
wait

#this will TRAIN the files for the top 100 features
perl trainModels_top100features.pl Configuration.txt &
wait

#model testing
#this will TRAIN the files for top 1% of features
perl testModels_top1pc.pl Configuration.txt &
wait

#this will TRAIN the files for top 10% of features
perl testModels_top10pc.pl Configuration.txt &
wait

#this will TRAIN the files for the top 33% of features
perl testModels_top33pc.pl Configuration.txt &
wait

#this will TRAIN the files for the top 66% of features
perl testModels_top66pc.pl Configuration.txt &
wait

#this will TRAIN the files for the top 100% of features
perl testModels_top100pc.pl Configuration.txt &
wait

#this will TRAIN the files for the top 25 features
perl testModels_top25features.pl Configuration.txt &
wait

#this will TRAIN the files for the top 50 features
perl testModels_top50features.pl Configuration.txt &
wait

#this will TRAIN the files for the top 100 features
perl testModels_top100features.pl Configuration.txt &
wait

#This will make the summary results page
bash resultsSummaryMaker.bash &
wait

end=$(date +%s)
runTime=$((end-start))
echo $runTime>../Logs/runTime_ms3BASH.txt

#this script resets the DataFiles directory, placing data from the recently run experiment(s) in the CompletedExperiments directory followed by a timestamp and creating a new DataFiles directory
bash cleanSlate.bash

