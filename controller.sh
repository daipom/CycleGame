#!/bin/bash

counter=0
while :
do
	echo none > tmpkeyyyy
	if read -t 1 key; then
		echo detect > tmpkeyyyy
		#break
		sleep 1
	fi

	counter=$(($counter + 1))
	if [[ "$counter" -eq "10000" ]]; then
		break
	fi
done

echo finished