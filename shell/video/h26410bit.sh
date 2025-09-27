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
ffmpeg -hwaccel vaapi -vaapi_device /dev/dri/renderD128 -i "$1" -map 0 -c copy -c:v h264_vaapi -crf 18 -maxrate 3M -bufsize 3M -pix_fmt yuv420p -vf 'format=nv12,hwupload' "$path/transcoded/$extensionless [x264].mkv" # hardware accelerated encode
