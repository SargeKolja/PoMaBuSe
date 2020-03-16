#!/bin/bash

# -- to understand the done < xxxx line ;-)
# echo "PWD=$PWD"
# echo "ARGV[0]=${0}"
# echo "here=${0%/*}"

# -- to understand the whitespace trimming: we 'abuse' xargs
#   echo "   lol  " | xargs

while read line; do
	line="${line%%#*}"
	[ -z "${line}" ] && continue
	trimmedline=$(echo "$line" | xargs)
	# --- echo "trimmedline='${trimmedline}'"
	name=$(  echo ${trimmedline%%=*} | xargs)
	value=$( echo ${trimmedline#*=} | xargs)
	# if 
	# --- echo "name='${name}', value='${value}'"
	compiler=${value%% *}
	if [ -z $(which ${compiler} 2>/dev/null) ]; then
		echo "CAN NOT FIND '${compiler}'"
	else
		echo "COMPILER '${compiler}' is okay"
	fi
done < "${0%/*}/../tools/compilers.bash_inc"
