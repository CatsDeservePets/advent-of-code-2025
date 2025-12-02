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

invalid() {
	s=$1
	len=${#s}
	# Numbers of uneven length can't consist of repeated sequences only
	[ $((len % 2)) -ne 0 ] && return 1

	left=
	right=$s
	j=0
	while [ "$j" -lt "$((len / 2))" ]; do
		# Move first char from $right to the end of $left
		left=$left${right%"${right#?}"}
		right=${right#?}
		: $((j += 1))
	done

	[ "$left" = "$right" ]
}

IFS=,
total=0

read -r line <"$file"
for v in $line; do
	printf 'line %s\n' "$v"

	first=${v%-*}
	last=${v#*-}
	i=$first
	while [ "$i" -le "$last" ]; do
		if invalid "$i"; then
			: $((total += i))
		fi
		: $((i += 1))
	done
done

printf 'Sum of invalid IDs: %d\n' "$total"
