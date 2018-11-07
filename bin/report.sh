#!/bin/bash
# $@ filename
for filename in $@
do
	# filename=`echo $1`
	skip=1
	num=0 # Number of query
	while read -r line
	do
		if [[ -n "$buffer" && "$line" =~ "Time:" ]]; then
			#echo # Placeholder
			# echo "$buffer" # Query
			# echo "=d$((4+3*num))/c$((4+3*num))" # Excel function
			sed 's/Time: //; s/ ms//;' <<< $line # Execution time
			#echo # Blank line
			buffer=''
			num=$((num+1))
		fi
		if [[ "$line" =~ "select" || "$line" =~ "SELECT" ]]; then
			unset skip
		fi
		if [ -z "$skip" ]; then
			buffer="$buffer $line"
		fi
		if [[ "$line" =~ ";" ]]; then
			skip=1
		fi
	done < $filename
done
