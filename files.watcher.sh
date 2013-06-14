#!/usr/bin/bash
#!/opt/bin/bash

VERSION=0.1
DIR=.
MASK="*"
MAX_DEPTH=1
suffix=".lock"
interrupted=0

function usage
{
	cat <<-TEXT
	Usage: $(basename $0) <OPTIONS>
	Options are:
	  -h, --help      Show this help
	  -d, --dir       Directory to watch files in
	  -D, --max-depth Max depth of searching files with \`find\`
	  -m, --mask      Mask to search files
	  -s, --script    Script to run for each file (and one as an argument)
	  -v, --version   Show version
TEXT
}
while test $# -ne 0
do
	arg="$1"
	shift
	case "${arg}" in
		-d|--dir)
			DIR="$1"
			shift
			;;
		-D|--max-depth)
			MAX_DEPTH="$1"
			shift
			;;
		-h|--help)
			SCRIPT=
			break
			;;
		-m|--mask)
			MASK="$1"
			shift
			;;
		-s|--script)
			SCRIPT="$1"
			shift
			;;
		-v|--version)
			echo $(basename $0) v$VERSION
			exit
			;;
		*)
			;;
	esac
done

if test -z "${SCRIPT}"
then
	usage
	exit 1
fi

function cleanup
{
	kill -HUP ${pid} 2>/dev/null
	if test -f "${marker}"
	then
		rm "${marker}"
	fi
}

function on_exit
{
	if test -f "$lockfile"
	then
		rm "$lockfile"
	fi
}

function inter
{
	cleanup
	interrupted=1
}

lockfile="$0.lock"
if test -f "$lockfile"
then
	if ps $(cat "$lockfile") 1>/dev/null
	then
		echo Process already run 1>&2
		exit 0
	fi
fi
trap on_exit EXIT
echo $$ > "$lockfile"

trap inter SIGINT SIGTERM

if test -d "${DIR}"
then
	cd "${DIR}"
else
	echo Directory \`${DIR}\` does not exist >&2
	exit 1
fi
find . -maxdepth ${MAX_DEPTH} \
	-type f -iname "${MASK}" \
	-and -not -iwholename '*/.*/' \
	-and -not -name '.*' \
| while read file
do
	marker="${file}${suffix}"
	if expr match "${file}" ".*\\${suffix}\$" 1>/dev/null
	then
		# skip files '<file>.lock'
		continue
	fi
	if expr match "${file}" ".*\\.done\$" 1>/dev/null
	then
		# skip files '<file>.done'
		continue
	fi
	if test -f "${marker}" -o -f "${file}.done"
	then
		# skip file that already done or is in progress
		continue
	fi
	${SCRIPT} "${file}" &
	pid=$!
	# create .lock-file with a PID of a run job
	echo ${pid} > "${marker}"
	wait ${pid}
	err=$?
	if test $interrupted -eq 1
	then
		echo Interrupted by signal 1>&2
		exit 1
	fi
	cleanup
	# mark file as done if it's finished successfully
	if test ${err} -eq 0
	then
		> "${file}.done"
	fi
done
trap - INT
cleanup
