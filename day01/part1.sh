#!/bin/sh

prog=${0##*/}
MIN_POS=0
MAX_POS=99

if [ $# -ne 2 ]; then
	printf 'usage: %s input_file start\n' "$prog" >&2
	exit 2
fi

file=$1
start=$2

if [ ! -r "$file" ]; then
	printf '%s: error reading %s\n' "$prog" "$file" >&2
	exit 1
fi

case $start in
	*[!0-9]* | '')
		printf '%s: start must be an integer [0-99]\n' "$prog" >&2
		exit 1
		;;
esac

if [ "$start" -lt "$MIN_POS" ] || [ "$start" -gt "$MAX_POS" ]; then
	printf '%s: start must be an integer [0-99]\n' "$prog" >&2
	exit 1
fi

printf 'The dial starts by pointing at %s.\n' "$start"

pos=$start
count=0

while IFS= read -r line; do
	dist=${line#?}
	case "$line" in
		L[0-9]*)
			dir=-1
			;;
		R[0-9]*)
			dir=1
			;;
		*)
			printf '%s: invalid line: %s\n' "$prog" "$line" >&2
			exit 1
			;;
	esac

	pos=$((pos + dir * dist))
	pos=$((pos % (MAX_POS + 1)))
	if [ "$pos" -lt "$MIN_POS" ]; then
		pos=$((pos + (MAX_POS + 1)))
	fi
	if [ "$pos" -eq 0 ]; then
		: $((count += 1))
	fi

	printf 'The dial is rotated %s to point at %d.\n' "$line" "$pos"
done <"$file"

printf 'The password is: %d\n' "$count"
