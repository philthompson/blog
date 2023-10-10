#!/bin/bash

THIS_SCRIPT="`perl -MCwd -le 'print Cwd::abs_path shift' "${0}"`"
THIS_DIR="$(dirname "${THIS_SCRIPT}")"

NFL_ELO_DIR="${HOME}/projects/nfl-elo"
NFL_ELO_STATIC_DIR="${THIS_DIR}/static/nfl-elo"

mkdir -p "${NFL_ELO_STATIC_DIR}"

if [ -z "${1}" ]
then
	echo "usage: ${0} <week-number-to-stop-after>" >&2
	exit 1
fi

STOP_AFTER_WEEK="${1}"

if [ $? -ne 0 ]
then
	exit
fi

FINAL_YEAR="`date +%Y`"

# output redirect page that points to current year page
cat > "${NFL_ELO_STATIC_DIR}/index.html" << xxxxxEOFxxxxx
<html lang="en">
	<head>
		<meta http-equiv="refresh" content="0; url=./${FINAL_YEAR}.html">
	</head>
	<body></body>
</html>
xxxxxEOFxxxxx

echo "running:"
seq 2022 ${FINAL_YEAR} | while read YEAR
do
	STOP_ARG=""
	if [ "${YEAR}" == "${FINAL_YEAR}" ]
	then
		STOP_ARG="${STOP_AFTER_WEEK}"
	fi

	# CALL python3 here with a year argument, and that
	#   python script will output the markdown page for the
	#   entire year
	# STOP_ARG is not quoted here, because it's only
	#   included for the final year
	echo "python3 \"${NFL_ELO_DIR}/outputYearMarkdown.py\" 2011 \"${YEAR}\" $STOP_ARG"
	python3 "${NFL_ELO_DIR}/outputYearMarkdown.py" 2011 "${YEAR}" $STOP_ARG > "${NFL_ELO_STATIC_DIR}/${YEAR}.md"

	if [ $? -ne 0 ]
	then
		exit
	fi
done
echo "done"
