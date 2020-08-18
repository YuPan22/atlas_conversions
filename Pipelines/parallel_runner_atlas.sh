#! /bin/bash
# https://stackoverflow.com/questions/6593531/running-a-limited-number-of-child-processes-in-parallel-in-bash
# for p in `ps aux | grep wc | grep -v grep | awk '{print $2}'`; do kill -9 $p; done

ls -1 /opt/genomics/azureatlasqccontainer/AtlasQC_WESTUS/iScan\ Scans/204236570048/*.gtc > /home2/yup1/list
num_of_lines=$(< list wc -l)
echo $num_of_lines

index=1
max_jobs=2 # the total number of jobs should NOT be less than max_jobs-1, if you have a single job, max_jobs=2, otherwise, the run will hang forever.


start=`date +%s`

function add_next_job {
echo "index: ${index}"
   # if still jobs to do then add one
   if [[ $index -le ${num_of_lines} ]]
   # apparently stackoverflow doesn't like bash syntax
   # the hash in the if is not a comment - rather it's bash awkward way of getting its length
   then
       echo adding job $(sed -n ${index}p /home2/yup1/list)
       do_job "$(sed -n ${index}p /home2/yup1/list)" &
       # replace the line above with the command you want
       index=$(($index+1))
   fi
}

set -o monitor
# means: run background processes in a separate processes...
trap add_next_job CHLD
# execute add_next_job when we receive a child complete signal

function do_job {
    echo "starting job $1"

    cd /home2/yup1

    ./run.sh "$1"

    sleep 2
}

# add initial set of jobs
while [[ $index -lt $max_jobs ]]
do
   add_next_job
done

# wait for all jobs to complete
wait

end=`date +%s`
runtime=$((end-start))
echo "total_done with runtime: ${runtime} seconds"
