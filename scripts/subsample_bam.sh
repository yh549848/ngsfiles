#! /bin/bash

#
# Sub
#
function subsample () {
  input=$1

  chrs=(chr11 chr21)
  for c in ${chrs[@]}
  do
    output_file=${input%.*}.${c}.bam
    cmd="samtools view -b ${input} ${c} > ${output_file}"
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
