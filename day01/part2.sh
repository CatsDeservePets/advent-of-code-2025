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

	hits=0
	if [ "$dir" -eq 1 ]; then
		first=$((((MAX_POS + 1) - pos) % (MAX_POS + 1)))
	else
		first=$((pos % (MAX_POS + 1)))
	fi
	if [ "$first" -eq 0 ]; then
		first=$((MAX_POS + 1))
	fi
	if [ "$dist" -ge "$first" ]; then
		hits=$((1 + (dist - first) / (MAX_POS + 1)))
		: $((count += hits))
	fi

	pos=$((pos + dir * dist))
	pos=$((pos % (MAX_POS + 1)))
	if [ "$pos" -lt "$MIN_POS" ]; then
		pos=$((pos + (MAX_POS + 1)))
	fi

	if [ "$hits" -gt 0 ]; then
		printf 'The dial is rotated %s to point at %d; during this rotation, it points at 0 %d time(s).\n' "$line" "$pos" "$hits"
	else
		printf 'The dial is rotated %s to point at %d.\n' "$line" "$pos"
	fi
done <"$file"

printf 'The password is: %d\n' "$count"
