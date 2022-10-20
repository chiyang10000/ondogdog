#!/bin/bash
PKG_PATH="$( cd "$( dirname "${BASH_SOURCE[0]-$0}" )" && pwd )"

test -d ~/dev/ClickBench
test -f $PKG_PATH/result.json



# rm -rf ~/dev/ClickBench/*/results



for out_file in `ls *.out`; do
  ls $out_file
  db_name=$(sed -E 's/(hawq.*)-[0-9]+.x86.*/\1/' <<<$out_file)
  
  output_dir=~/dev/ClickBench/$db_name
  output_json=${output_dir}/results/result.json
  
  rm -rf ${output_dir}/results/*
  mkdir -p ${output_dir}/results
  
  sed '/result/q' $PKG_PATH/result.json >>${output_json}
  sed -i  "s/.*system.*/ \"system\":\"${db_name}\", /" ${output_json}
  
  cat $out_file | 
    # awk '{print $0; print $0; print $0 }' |
    grep -E 'Time: \d+\.\d+ ms' |
    sed -r -e 's/Time: ([0-9]+\.[0-9]+) ms/\1/' |
    awk '{ if (i % 3 == 0) { printf "[" }; printf $1 / 1000; if (i % 3 != 2) { printf "," } else { print "]," }; ++i; }' >>${output_json}
  
  # echo '[]' >>${output_json}
  sed -i  "$ s/],/]/g" ${output_json} # remove extra dummy result ending
  
  sed -e '1,/result/ d' $PKG_PATH/result.json >>${output_json}
done

cd ~/dev/ClickBench/ && ~/dev/ClickBench/generate-results.sh
if test -t 0; then
  open index.html
fi