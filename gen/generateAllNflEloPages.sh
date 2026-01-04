#!/bin/bash

THIS_SCRIPT="`perl -MCwd -le 'print Cwd::abs_path shift' "${0}"`"
THIS_DIR="$(dirname "${THIS_SCRIPT}")"

NFL_ELO_DIR="${HOME}/projects/nfl-elo"
NFL_ELO_STATIC_DIR="${THIS_DIR}/static/nfl-elo"

mkdir -p "${NFL_ELO_STATIC_DIR}"

if [ -z "${1}" ]
then
	echo "usage: ${0} <week-number-to-stop-after> [<final-year>] [--freeze]" >&2
	exit 1
fi

STOP_AFTER_WEEK="${1}"

if [ $? -ne 0 ]
then
	exit
fi

FINAL_YEAR="${2}"

if [ -z "${FINAL_YEAR}" ]
then
	# 3 months ago, which means in the playoffs we'll still get the correct season year
	FINAL_YEAR="`date -j -v-3m +%Y`"
fi

FREEZE_ARG=""
FREEZE_FILE_SUFFIX=""
if [ "${3}" == "--freeze" ]
then
	FREEZE_ARG="--freeze"
	FREEZE_FILE_SUFFIX="-frozen-`date +%b-%Y`"
	FREEZE_FILE_SUFFIX="-frozen-Feb-2025"
fi

echo "running:"
seq 2020 ${FINAL_YEAR} | while read YEAR
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
	MODEL_NAME="v2.2024.07" # ALSO update this in ~/projects/nfl-elo/manualAutoFetch.sh
	echo "python3 \"${NFL_ELO_DIR}/outputYearMarkdown.py\" \"${MODEL_NAME}\" 1992 \"${YEAR}\" $STOP_ARG $FREEZE_ARG"
	python3 "${NFL_ELO_DIR}/outputYearMarkdown.py" "${MODEL_NAME}" 1992 "${YEAR}" $STOP_ARG $FREEZE_ARG > "${NFL_ELO_STATIC_DIR}/${YEAR}${FREEZE_FILE_SUFFIX}.md"
	if [ $? -ne 0 ]
	then
		echo "error detected in regular model run"
		exit
	fi

	# for 2025 season, moving the "v3.2025.06" model to separate pages
	MODEL_NAME="v3.2025.06" # ALSO update this in ~/projects/nfl-elo/manualAutoFetch.sh
	echo "python3 \"${NFL_ELO_DIR}/outputYearMarkdown.py\" \"${MODEL_NAME}\" 1992 \"${YEAR}\" $STOP_ARG $FREEZE_ARG"
	python3 "${NFL_ELO_DIR}/outputYearMarkdown.py" "${MODEL_NAME}" 1992 "${YEAR}" $STOP_ARG $FREEZE_ARG > "${NFL_ELO_STATIC_DIR}/${YEAR}-v3-2025-06${FREEZE_FILE_SUFFIX}.md"
	if [ $? -ne 0 ]
	then
		echo "error detected in regular model run"
		exit
	fi

	# for 2025 season, not doing "nomov"
	#MODEL_NAME="nomov-v1.2024.11"
	#echo "python3 \"${NFL_ELO_DIR}/outputYearMarkdown.py\" \"${MODEL_NAME}\" 2010 \"${YEAR}\" $STOP_ARG $FREEZE_ARG"
	#python3 "${NFL_ELO_DIR}/outputYearMarkdown.py" "${MODEL_NAME}" 2010 "${YEAR}" $STOP_ARG $FREEZE_ARG > "${NFL_ELO_STATIC_DIR}/${YEAR}-nomov${FREEZE_FILE_SUFFIX}.md"
	#if [ $? -ne 0 ]
	#then
	#	echo "error detected in nomov model run"
	#	exit
	#fi

	# for 2025 season, not doing "winpos"?
	#MODEL_NAME="winpos-v2.2025.05"
	#echo "python3 \"${NFL_ELO_DIR}/outputYearMarkdown.py\" \"${MODEL_NAME}\" 2010 \"${YEAR}\" $STOP_ARG $FREEZE_ARG"
	#python3 "${NFL_ELO_DIR}/outputYearMarkdown.py" "${MODEL_NAME}" 2010 "${YEAR}" $STOP_ARG $FREEZE_ARG > "${NFL_ELO_STATIC_DIR}/${YEAR}-winpos${FREEZE_FILE_SUFFIX}.md"
	#if [ $? -ne 0 ]
	#then
	#	echo "error detected in winpos model run"
	#	exit
	#fi

	# for summer 2025: re-enable this after find best new "blank slate" model
	## generate the 2023-only.html page
	MODEL_NAME="blank-slate-v2.2025.08" # ALSO update this in ~/projects/nfl-elo/manualAutoFetch.sh
	echo "python3 \"${NFL_ELO_DIR}/outputYearMarkdown.py\" \"${MODEL_NAME}\" \"${YEAR}\" \"${YEAR}\" $STOP_ARG $FREEZE_ARG"
	python3 "${NFL_ELO_DIR}/outputYearMarkdown.py" "${MODEL_NAME}" "${YEAR}" "${YEAR}" $STOP_ARG $FREEZE_ARG > "${NFL_ELO_STATIC_DIR}/${YEAR}-only${FREEZE_FILE_SUFFIX}.md"
	if [ $? -ne 0 ]
	then
		echo "error detected in blank slate model run"
		exit
	fi
done
echo "done"
