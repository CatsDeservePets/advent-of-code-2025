#!/bin/sh

prog=${0##*/}
file=$1

if [ -z "$file" ]; then
	printf 'usage: %s file\n' "$prog" >&2
	exit 1
fi

if [ ! -r "$file" ]; then
	printf '%s: error reading %s\n' "$prog" "$file" >&2
	exit 1
fi

total=0
while IFS= read -r line; do
	nums=$(printf '%s\n' "$line" | sed 's/./& /g')
	bat_l=0
	bat_r=0
	i=0
	range=$((${#line} - 1))
	for n in $nums; do
		if [ "$n" -gt "$bat_l" ] && [ "$i" -lt "$range" ]; then
			bat_l=$n
			bat_r=0
		elif [ "$n" -gt "$bat_r" ]; then
			bat_r=$n
		fi
		: $((i += 1))
	done
	jolts=$bat_l$bat_r
	: $((total += jolts))
	printf 'In %s, the largest joltage you can produce is %d.\n' "$line" "$jolts"
done <"$file"

printf 'The total joltage is: %d\n' "$total"
