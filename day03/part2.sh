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

SLOTS=12
joltage=0

while IFS= read -r bank; do
	cells=$(printf '%s\n' "$bank" | sed 's/./& /g')
	len=${#bank}

	slot=0
	start=0
	jolts=

	while [ "$slot" -lt "$SLOTS" ]; do
		left=$((SLOTS - slot))
		last=$((len - left))

		bat=0
		bat_pos=$start
		i=0

		for cell in $cells; do
			if [ "$i" -ge "$start" ] && [ "$i" -le "$last" ]; then
				if [ "$cell" -gt "$bat" ]; then
					bat=$cell
					bat_pos=$i
				fi
			fi
			: $((i += 1))
		done

		jolts=$jolts$bat
		start=$((bat_pos + 1))
		: $((slot += 1))
	done

	: $((joltage += jolts))
	printf 'In %s, the largest joltage you can produce is %d.\n' "$bank" "$jolts"
done <"$file"

printf 'The total joltage is: %d\n' "$joltage"
