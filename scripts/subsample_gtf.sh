#! /bin/bash

#
# Sub
#
function subsample () {
  input=$1

  chrs=(chr11 chr21)
  for c in ${chrs[@]}
  do
    output_file=${input%.*}.${c}.gtf
    cmd="cat ${input} | grep \"^${c}[[:space:]]\" > ${output_file}"
    echo $cmd
    eval $cmd
  done
}


#
# Main
#
input=$1
subsample $input
