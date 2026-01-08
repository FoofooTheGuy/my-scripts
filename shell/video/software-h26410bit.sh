#!/usr/bin/env bash
# usage: file.sh <video file>
# output: <path to video file>/transcoded/<video file> [x264].mkv
path="${1%/*}"
#echo "$path"
filename="${1##*/}"
#echo "$filename"
extensionless="${filename%.*}"
#echo "$extensionless"
mkdir "$path/transcoded"
ffmpeg -i "$1" -map 0 -c copy -c:v libx264 -crf 19 -tune film -maxrate 3M -bufsize 3M -pix_fmt yuv420p "$path/transcoded/$extensionless [x264].mkv" # hardware accelerated encode
