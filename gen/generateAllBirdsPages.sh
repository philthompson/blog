#!/bin/bash

THIS_SCRIPT="`perl -MCwd -le 'print Cwd::abs_path shift' "${0}"`"
THIS_DIR="$(dirname "${THIS_SCRIPT}")"

BIRDS_DB="${HOME}/Pictures/Birds/bird-photos-db.sqlite3"

BIRDS_STATIC_DIR="${THIS_DIR}/static/birds"

echo "generating all all ..." &&
python3 "${THIS_DIR}/generateBirdsPage.py" "${BIRDS_DB}" all all > "${BIRDS_STATIC_DIR}/index.md" &&
echo "generating all loc_home_1 ..." &&
python3 "${THIS_DIR}/generateBirdsPage.py" "${BIRDS_DB}" all loc_home_1 > "${BIRDS_STATIC_DIR}/home.md"

if [ $? -ne 0 ]
then
	exit
fi

seq 2021 `date +%Y` | while read YEAR
do
	echo "generating ${YEAR} all ..." &&
	python3 "${THIS_DIR}/generateBirdsPage.py" "${BIRDS_DB}" "${YEAR}" all > "${BIRDS_STATIC_DIR}/${YEAR}.md" &&
	echo "generating ${YEAR} loc_home_1 ..." &&
	python3 "${THIS_DIR}/generateBirdsPage.py" "${BIRDS_DB}" "${YEAR}" loc_home_1 > "${BIRDS_STATIC_DIR}/home-${YEAR}.md" &&
	echo "generating ${YEAR} fav ..." &&
	python3 "${THIS_DIR}/generateBirdsPage.py" "${BIRDS_DB}" "${YEAR}" fav > "${BIRDS_STATIC_DIR}/favorites-${YEAR}.md"
	if [ $? -ne 0 ]
	then
		exit
	fi
done

