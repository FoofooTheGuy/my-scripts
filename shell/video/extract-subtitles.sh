#!/usr/bin/env bash
# usage: file.sh <path to mkv files>
# output: <path to mkv files>/file.<srt/ass/whatever>
cd "$1" || exit 1 # https://stackoverflow.com/a/64166747

# ported(?) from https://help.mkvtoolnix.download/t/can-mkvtoolnix-extract-movie-subtitle-to-srt-file/227/3
for FILE in *.mkv; do
	count=$(mkvmerge --identify "${FILE}" | grep 'Track ID' | wc -l)
	if [[ "$count" -le 0 ]]; then # https://stackoverflow.com/a/34807585
		echo "\$count <= 0 ($count)"
		continue
	fi
	echo Analyzing "'${FILE}'"
	for i in $(seq 0 $(expr ${count} - 1)); do
		mkvmerge --identify "${FILE}" | grep "Track ID $i: subtitles"
		ret="$?"
		if [[ "$ret" -ne 1 ]]; then
			echo "$ret" not equal 1
			mkvextract tracks "${FILE}" $i:"${FILE%.*}-ID${i}"
		fi
	done
done
