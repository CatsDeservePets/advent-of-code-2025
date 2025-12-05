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

i=0
paper=
while IFS= read -r line; do
	row=$(printf '%s\n' "$line" | sed 's/./& /g')
	j=0
	for col in $row; do
		case "$col" in
			"@")
				# simulate 2d array pos[i][j]
				eval "pos_${i}_${j}=@"
				# store locations to avoid re-reading the whole file
				paper="${paper} ${i}-${j}"
				;;
		esac
		: $((j += 1))
	done
	: $((i += 1))
done <"$file"

valid_rolls=0
for p in $paper; do
	count=0
	r=${p%-*}
	c=${p#*-}

	i=$((r - 1))
	while [ "$i" -le "$((r + 1))" ]; do
		j=$((c - 1))
		while [ "$j" -le "$((c + 1))" ]; do
			eval "tmp=\${pos_${i}_${j}:-}"
			case $tmp in
				"@")
					: $((count += 1))
					;;
			esac
			: $((j += 1))
		done
		: $((i += 1))
	done

	: $((count -= 1)) # don't count current roll
	if [ "$count" -lt 4 ]; then
		printf '%s-%s is valid\n' "$r" "$c"
		: $((valid_rolls += 1))
	fi
done

printf 'Amount accessible paper rolls: %d\n' "$valid_rolls"
