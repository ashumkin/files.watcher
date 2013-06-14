#!/usr/bin/bash
# Script to cut video file with ffmpeg

FILE="$1"
shift
FILE_TIME="${FILE}.time"
if ! test -f "$FILE_TIME"
then
	FILE_TIME=".time"
fi
if ! test -f "$FILE_TIME"
then
	echo Warning: no file with a time to cut >&2
	exit
fi
FILE_EXT="${FILE##*.}"
OUTPUT="${FILE%.*}.OUT.${FILE_EXT}"
dir=$(dirname "$BASH_SOURCE")
ffmpeg_time_script="ffmpeg_time.py"
ffmpeg_time=$(cat "$FILE_TIME" | "$dir/$ffmpeg_time_script")
ffmpeg -y -i "$FILE" -acodec copy -vcodec copy $ffmpeg_time $@ "$OUTPUT"
