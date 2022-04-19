#!/bin/bash

THIS_SCRIPT="`perl -MCwd -le 'print Cwd::abs_path shift' "${0}"`"
THIS_DIR="$(dirname "${THIS_SCRIPT}")"

BIRDS_DB="${HOME}/Pictures/Birds/bird-photos-db.sqlite3"

BIRDS_STATIC_DIR="${THIS_DIR}/static/birds"

echo "generating all all ..." &&
python3 "${THIS_DIR}/generateBirdsPage.py" "${BIRDS_DB}" all all > "${BIRDS_STATIC_DIR}/index.md" &&
echo "generating 2021 all ..." &&
python3 "${THIS_DIR}/generateBirdsPage.py" "${BIRDS_DB}" 2021 all > "${BIRDS_STATIC_DIR}/2021.md" &&
echo "generating 2022 all ..." &&
python3 "${THIS_DIR}/generateBirdsPage.py" "${BIRDS_DB}" 2022 all > "${BIRDS_STATIC_DIR}/2022.md" &&
echo "generating all loc_home_1 ..." &&
python3 "${THIS_DIR}/generateBirdsPage.py" "${BIRDS_DB}" all loc_home_1 > "${BIRDS_STATIC_DIR}/home.md" &&
echo "generating 2021 loc_home_1 ..." &&
python3 "${THIS_DIR}/generateBirdsPage.py" "${BIRDS_DB}" 2021 loc_home_1 > "${BIRDS_STATIC_DIR}/home-2021.md" &&
echo "generating 2022 loc_home_1 ..." &&
python3 "${THIS_DIR}/generateBirdsPage.py" "${BIRDS_DB}" 2022 loc_home_1 > "${BIRDS_STATIC_DIR}/home-2022.md"

