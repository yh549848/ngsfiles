#! /bin/bash

#
# Sub
#
function subsample () {
  input=$1
  seed=12345

  num_reads=(10000 100000 1000000)
  for n in ${num_reads[@]}
  do
    output_file=${input%%.*}.${n}.fastq.gz
    cmd="seqkit sample -n ${n} -s ${seed} -o ${output_file} ${input}"
    echo $cmd
    eval $cmd
  done
}


#
# Main
#
inputs=($@)

for input in ${inputs[@]}
do
  subsample $input
done
