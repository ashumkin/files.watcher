#!/usr/bin/bash

title_from_dir=0

if test $# -eq 1
then
	FILE="$1"
else
	while test $# -ne 0
	do
		arg="$1"
		shift
		case "$arg" in
			-T|--title-from-dir)
				title_from_dir=1
				;;
			*)
				FILE="$arg"
				;;
		esac
	done
fi

CATEGORY=Autos
USER=$YOUTUBE_USER
PASSWORD=$(echo $YOUTUBE_UPLOAD | openssl enc -d -a | openssl des -d -k $PASSPHRASE)
SCRIPT=$HOME/bin/youtube-upload
if ! test -x "$SCRIPT"
then
	echo "'$SCRIPT' is not found or it is not executable.
Please, place or symlink 'bin/youtube-upload'
from 'http://youtube-upload.googlecode.com/svn/trunk/' repository
to the '\$HOME/bin/' directory"
	exit 1
fi
SCREEN_NAME="youtube-upload"
SCREEN_CONFIG=$YOUTUBE_SCREEN_CONFIG

if test $title_from_dir -eq 1
then
	FILE_TITLE=$(basename "$(dirname "$FILE")")
	# if file is in current directory
	if test "$FILE_TITLE" == "."
	then
		# take current directory name
		FILE_TITLE=$(basename "$(pwd)")
	fi
fi

if test $title_from_dir -eq 0
then
	FILE_TITLE=$(basename "$FILE")
fi
echo $FILE_TITLE

screen -c "$SCREEN_CONFIG" -S $SCREEN_NAME -D -m $SCRIPT --email "$USER" --password "$PASSWORD" --title "$FILE_TITLE" --category "$CATEGORY" --unlisted "$FILE"
