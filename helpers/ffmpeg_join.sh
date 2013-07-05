#!/usr/bin/bash
# Script to cut video file with ffmpeg

steps=(0 0 0)
FILE_JOIN=".join"
OUTPUT="OUTPUT.MOV"
FORMAT="mpegts"
delete_temp=0
while test -n "$1"
do
	arg="$1"
	shift
	case "$arg" in
		-D|--delete-temp)
			delete_temp=1
			;;
		-f|--format)
			FORMAT="$1"
			shift
			;;
		-o|--output)
			OUTPUT="$1"
			shift
			;;
		-p1|--params-step-1)
			params1="$1"
			shift
			;;
		-p2|--params-step-2)
			params2="$1"
			shift
			;;
		-s|--step)
			steps[$1]=1
			shift
			;;
		*)
			FILE_JOIN="$arg"
			;;
	esac
done

if ! test -f "$FILE_JOIN"
then
	echo Error: no file \'$FILE_JOIN\' with a file list to join >&2
	exit
fi

declare -a TEMP_STREAMS
FILES=$(< $FILE_JOIN)

for file in ${FILES[@]}
do
	stream="${file}.ts"
	TEMP_STREAMS[${#TEMP_STREAMS[@]}]="$stream"
	if test ${steps[1]} -eq 1
	then
		ffmpeg -y -i "$file" -sameq -vcodec copy -acodec copy -vbsf h264_mp4toannexb -f $FORMAT $params1 "$stream"
	fi
done
param=
for file in ${TEMP_STREAMS[@]}
do
	param="$param$delimiter$file"
	delimiter="|"
done
if test ${steps[2]} -eq 1
then
	ffmpeg -y -f $FORMAT -i "concat:$param" -sameq -vcodec copy -acodec copy -absf aac_adtstoasc $params2 "$OUTPUT"
fi
if test $delete_temp -eq 1
then
	for file in ${TEMP_STREAMS[@]}
	do
		rm "$file"
	done
fi
