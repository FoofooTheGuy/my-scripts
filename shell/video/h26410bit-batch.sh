#!/usr/bin/env bash
# usage: file.sh <path to dir>
# output: <path to dir>/transcoded
cd "$1" || exit 1 # https://stackoverflow.com/a/64166747
mkdir transcoded
for ep in *; do # iterate episodes in curdir
	echo "$ep"
	ffmpeg -hwaccel vaapi -vaapi_device /dev/dri/renderD128 -i "$ep" -map 0 -c copy -c:v h264_vaapi -crf 18 -maxrate 3M -bufsize 3M -pix_fmt yuv420p -vf 'format=nv12,hwupload' "transcoded/$ep [x264].mkv" #hardware accelerated encode
done
