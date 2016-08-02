#!/bin/bash

view_size_x=`tput cols`
view_size_y=`tput lines`

resize -s $view_size_y $view_size_x
my_x=$(($view_size_x / 2))
my_y=$(($view_size_y / 2 - 1))
my_state=0
jump_power=0
score=0

map=()

counter=0
while [[ "$counter" -le "$view_size_x" ]]; do
	map+=($((view_size_y / 2)))
	counter=$(($counter + 1))
done

gameover () {
	sleep 1
	clear
	draw_letter 5 $((view_size_y / 2)) "\nscore: $score"
	#echo "\nscore: $score"
	exit 0
}

draw_letter () {
	#$1:x, $2:y, $3:char
	tput sc;tput cm $2 $1;tput al;echo $3;tput rc
}

draw () {
	#$1:x, $2:y, $3:char
	#tput sc;tput cm $2 $1;tput al;echo $3;tput rc
	if [[ "$2" -eq "0" ]]; then
		echo $3 > tmpmap; else
		echo $3 >> tmpmap
	fi
}

jump () {
	if [[ "$my_wate" -eq "0" ]]; then
		if [[ "$my_state" -eq "0" ]]; then
			jump_power=3
			my_state=1
		fi
	fi
}

viewupdate () {
	map_vert=()
	y=0
	while [[ "$y" -lt "$view_size_y" ]]; do
		x=0
		while [[ "$x" -lt "$view_size_x" ]]; do
			if [[ "${map[$x]}" -eq "$y" ]]; then
				map_vert[$y]+="~"; else
				if [[ "$x" -eq "$my_x" ]]; then
					if [[ "my_y" -eq "$y" ]]; then
						map_vert[$y]+="@"
					else
						map_vert[$y]+="'"
					fi
				else
					map_vert[$y]+="'"
				fi
			fi
			x=$(($x + 1))
		done
		y=$(($y + 1))
	done

	y=0
	while [[ "$y" -lt "$view_size_y" ]]; do
		draw 0 $y ${map_vert[$y]}
		y=$(($y + 1))
	done
	clear
	cat < tmpmap
}

dataupdate () {
	score=$(($score + 1))

	if [[ "$jump_power" -eq "0" ]]; then
		#if [[ "$my_state" -eq "1" ]]; then
			if [[ "$my_y" -eq "$((${map[$my_x]} - 1))" ]]; then
				my_state=0; else
				my_y=$(($my_y + 1))
				if [[ "$my_y" -eq "$((${map[$my_x]} - 1))" ]]; then
					my_state=0;else
					my_state=1
				fi
			fi
		#fi
	fi

	if [[ "$jump_power" -gt "0" ]]; then
		my_y=$(($my_y - 1))
		jump_power=$(($jump_power - 1))
	fi

	if [[ "$my_state" -eq "0" ]]; then
		if [[ "${map[$((my_x + 1))]}" -eq "${map[$my_x]} + 1" ]]; then
			my_y=$(($my_y + 1))
		fi
		if [[ "${map[$((my_x + 1))]}" -eq "${map[$my_x]} - 1" ]]; then
			my_y=$(($my_y - 1))
		fi
	fi

	change=$(($RANDOM % 9 - 4))
	change=$(($change / 2))
	map[$view_size_x]=$((${map[$view_size_x]} + $change))
	if [[ "${map[$view_size_x]}" -gt "$(($view_size_y - 2))" ]]; then
		map[$view_size_x]=$(($view_size_y - 2))
	fi
	if [[ "${map[$view_size_x]}" -lt "2" ]]; then
		map[$view_size_x]=2
	fi
	counter=0
	nextcounter=1
	while [[ "$counter" -lt "$view_size_x" ]]; do
		map[$counter]=${map[$nextcounter]}
		counter=$(($counter + 1))
		nextcounter=$(($counter + 1))
	done

	if [[ "$my_y" -gt "$view_size_y" ]]; then
		gameover
	fi
	if [[ "$my_state" -gt "0" ]]; then
		if [[ "$my_y" -gt "${map[$my_x]}" ]]; then
			gameover
		fi
	fi
}

while :
do
	viewupdate

	#sleep 0.1
	read key < tmpkeyyyy
	#echo $key >> save
	case "$key" in
		"detect" ) jump
			;;
	esac

	dataupdate
done