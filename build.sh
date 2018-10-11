#!/bin/bash

THIS_SCRIPT="${0}"
THIS_DIR="$(dirname "${THIS_SCRIPT}")"
OUT_DIR="${THIS_DIR}/out/$(date +%Y-%m-%d-%H%M%S)"
GEN_DIR="${THIS_DIR}/gen"
STATIC_DIR="${THIS_DIR}/gen/static"
MARKDOWN_PERL_SCRIPT="${THIS_DIR}/Markdown_1.0.1/Markdown.pl"

echo "${THIS_SCRIPT}"
echo "${THIS_DIR}"
echo "${OUT_DIR}"

# make new build output dir
mkdir -p "${OUT_DIR}"

mkdir -p "${OUT_DIR}/archive"

# put static files in place
cp -rp "${STATIC_DIR}"/* "${OUT_DIR}/"

"${GEN_DIR}/style.sh" > "${OUT_DIR}/css/style.css"

RECENT_ARTICLES="$(ls -1 "${GEN_DIR}/articles" | sort -r | head -n 5)"

"${GEN_DIR}/header.sh" Home '.' "philthompson, phil, thompson, personal, blog" "Personal blog home — philthompson.me" 3 > "${OUT_DIR}/index.html"

find "${GEN_DIR}/articles" -type f | sort -r | while read ARTICLE_MARKDOWN_FILE
do
	ARTICLE_METADATA="$(grep -B 99 '^\[//\]: # (gen-meta-end)' "${ARTICLE_MARKDOWN_FILE}")"

	ARTICLE_TITLE="$(echo "${ARTICLE_METADATA}" | grep -m 1 gen-title: | cut -d ' ' -f 4- | sed 's/)$//')"
	ARTICLE_TITLE_URL="$(echo "${ARTICLE_METADATA}" | grep -m 1 gen-title-url: | cut -d ' ' -f 4- | sed 's/)$//')"
	ARTICLE_KEYWORDS="$(echo "${ARTICLE_METADATA}" | grep -m 1 gen-keywords: | cut -d ' ' -f 4- | sed 's/)$//')"
	ARTICLE_DESCRIPTION="$(echo "${ARTICLE_METADATA}" | grep -m 1 gen-description: | cut -d ' ' -f 4- | sed 's/)$//')"
	ARTICLE_DATE="$(basename "${ARTICLE_MARKDOWN_FILE}" | cut -d . -f 1)"

	ARTICLE_DATE_REFORMAT="$(echo "${ARTICLE_DATE}" | cut -d '-' -f 1-3 | \
	sed 's/-01-/-January-/' | \
	sed 's/-02-/-February-/' | \
	sed 's/-03-/-March-/' | \
	sed 's/-04-/-April-/' |  \
	sed 's/-05-/-May-/' | \
	sed 's/-06-/-June-/' | \
	sed 's/-07-/-July-/' | \
	sed 's/-08-/-August-/' | \
	sed 's/-09-/-September-/' | \
	sed 's/-10-/-October-/' | \
	sed 's/-11-/-November-/' | \
	sed 's/-12-/-December-/' | sed 's/-0/-/' | sed 's/-/ /g' | awk '{print $2" "$3", "$1}')"

	ARTICLE_YEAR="$(echo "${ARTICLE_DATE}" | cut -d '-' -f 1)"

	echo "<a href=\"../${ARTICLE_YEAR}/\">${ARTICLE_YEAR}</a>" >> "${OUT_DIR}/archive/index.html"

	mkdir -p "${OUT_DIR}/${ARTICLE_YEAR}"

	if [[ ! -s "${OUT_DIR}/${ARTICLE_YEAR}/index.html" ]]
	then
		"${GEN_DIR}/header.sh" "Archive — ${ARTICLE_YEAR}" '..' "blog, archive, history, year, ${ARTICLE_YEAR}" "Personal blog archive for ${ARTICLE_YEAR} — philthompson.me" 7 > "${OUT_DIR}/${ARTICLE_YEAR}/index.html"
	fi

	echo "<div class=\"article-title\">" >> "${OUT_DIR}/${ARTICLE_YEAR}/index.html"
	echo "<small class=\"article-info\">${ARTICLE_DATE_REFORMAT}</small>"  >> "${OUT_DIR}/${ARTICLE_YEAR}/index.html"
	echo "<a href=\"${ARTICLE_TITLE_URL}.html\">${ARTICLE_TITLE}</a>" >> "${OUT_DIR}/${ARTICLE_YEAR}/index.html"
	echo "</div>" >> "${OUT_DIR}/${ARTICLE_YEAR}/index.html"

	PREV_NEXT="$(ls -1 "${GEN_DIR}/articles" | sort | grep -B 1 -A 1 "${ARTICLE_DATE}.md")"

	PREV_MARKDOWN_FILE="$(echo "${PREV_NEXT}" | head -n 1)"
	NEXT_MARKDOWN_FILE="$(echo "${PREV_NEXT}" | tail -n 1)"

	PREV_MARKDOWN_FILE_YEAR="$(echo "${PREV_MARKDOWN_FILE}" | cut -d '-' -f 1)"
	NEXT_MARKDOWN_FILE_YEAR="$(echo "${NEXT_MARKDOWN_FILE}" | cut -d '-' -f 1)"

	PREV_TITLE_URL="$(grep -B 99 '^\[//\]: # (gen-meta-end)' "${GEN_DIR}/articles/${PREV_MARKDOWN_FILE}" | grep -m 1 gen-title-url: | cut -d ' ' -f 4- | sed 's/)$//')"
	NEXT_TITLE_URL="$(grep -B 99 '^\[//\]: # (gen-meta-end)' "${GEN_DIR}/articles/${NEXT_MARKDOWN_FILE}" | grep -m 1 gen-title-url: | cut -d ' ' -f 4- | sed 's/)$//')"

	"${GEN_DIR}/article.sh" \
		"${MARKDOWN_PERL_SCRIPT}" \
		"${ARTICLE_MARKDOWN_FILE}" \
		"${ARTICLE_TITLE}" \
		"${ARTICLE_TITLE_URL}" \
		"${ARTICLE_KEYWORDS}" \
		"${ARTICLE_DESCRIPTION}" \
		"${ARTICLE_DATE_REFORMAT}" \
		"${PREV_MARKDOWN_FILE_YEAR}/${PREV_TITLE_URL}.html" \
		"${NEXT_MARKDOWN_FILE_YEAR}/${NEXT_TITLE_URL}.html" \
		"${GEN_DIR}/header.sh" \
		"${GEN_DIR}/footer.sh" \
		".." > "${OUT_DIR}/${ARTICLE_YEAR}/${ARTICLE_TITLE_URL}.html"

	if [[ ! -z "$(echo "${RECENT_ARTICLES}" | grep "${ARTICLE_DATE}")" ]]
	then
		echo "	<div class=\"container\">"
		echo "		<div class=\"article-info\">${ARTICLE_DATE_REFORMAT}</div>"
		echo "		<h1 class=\"article-title\"><a href=\"./${ARTICLE_YEAR}/${ARTICLE_TITLE_URL}.html\">${ARTICLE_TITLE}</a></h1>"

		if [[ -z "$(grep -m 1 "more://" "${ARTICLE_MARKDOWN_FILE}")" ]]
		then
			perl "${MARKDOWN_PERL_SCRIPT}" --html4tags "${ARTICLE_MARKDOWN_FILE}" | sed 's#src="../#src="./#g' | sed 's#href="../#href="./#g'
		else
			perl "${MARKDOWN_PERL_SCRIPT}" --html4tags "${ARTICLE_MARKDOWN_FILE}" | grep -B 999 'more://' | grep -v 'more://' | sed 's#src="../#src="./#g' | sed 's#href="../#href="./#g'
			echo "<a href=\"./${ARTICLE_YEAR}/${ARTICLE_TITLE_URL}.html\">continue reading...</a>"
		fi

		echo "      <hr />"
		echo "	</div>"
	fi >> "${OUT_DIR}/index.html"
done

LAST_YEAR="$(find "${GEN_DIR}/articles" -type f | sort -r | head -n 1)"
LAST_YEAR="$(basename "${LAST_YEAR}" | cut -c 1-4)"
echo "	<div class=\"container\">"  >> "${OUT_DIR}/index.html"
echo "		<h1 class=\"article-title\"><a href=\"./${LAST_YEAR}/\">All ${LAST_YEAR} posts</a></h1>" >> "${OUT_DIR}/index.html"
echo "	</div>" >> "${OUT_DIR}/index.html"

"${GEN_DIR}/footer.sh" Home . >> "${OUT_DIR}/index.html"

ls -1 "${OUT_DIR}"/20*/index.html | while read YEAR_FILE
do
	"${GEN_DIR}/footer.sh" "ignoreme" .. >> "${YEAR_FILE}"
done

sort -u "${OUT_DIR}/archive/index.html" | while read LINE
do
	echo "<div class=\"article-title\">${LINE}</div>"
done >> "${OUT_DIR}/archive/tmp.html"

"${GEN_DIR}/header.sh" Archive '..' "blog, archive, history, contents" "Personal blog archive — philthompson.me" 30 > "${OUT_DIR}/archive/index.html"
cat "${OUT_DIR}/archive/tmp.html" >> "${OUT_DIR}/archive/index.html"
"${GEN_DIR}/footer.sh" Archive '..' >> "${OUT_DIR}/archive/index.html"
rm "${OUT_DIR}/archive/tmp.html"

mkdir -p "${OUT_DIR}/about"
"${GEN_DIR}/header.sh" About '..' "blog, archive, about, author" "About — philthompson.me" 30 > "${OUT_DIR}/about/index.html"
perl "${MARKDOWN_PERL_SCRIPT}" --html4tags "${GEN_DIR}/about.md" >> "${OUT_DIR}/about/index.html"
"${GEN_DIR}/footer.sh" Arbout '..' >> "${OUT_DIR}/about/index.html"
