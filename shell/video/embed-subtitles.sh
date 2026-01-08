#!/usr/bin/env bash
# usage: file.sh <video file> <srt file>
# output: <video file [srt]>

path="${1%/*}"
#echo "$path"
filename="${1##*/}"
#echo "$filename"
extensionless="${filename%.*}"
#echo "$extensionless"
ffmpeg -i "$1" -sub_charenc 'UTF-8' -f srt -i "$2" -c:v copy -c:a copy -c:s srt "$path/$extensionless [srt].mkv"
