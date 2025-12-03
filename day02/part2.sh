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
	# Numbers of length 0/1 can't be repetitions of a shorter block
	[ "${#s}" -lt 2 ] && return 1

	t=$s$s
	t=${t#?} # drop first char
	t=${t%?} # drop last char

	# $s is invalid if it occurs as a substring of $t
	case $t in
		*"$s"*)
			return 0
			;;
		*)
			return 1
			;;
	esac
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
