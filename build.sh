#!/bin/bash

THIS_SCRIPT="`perl -MCwd -le 'print Cwd::abs_path shift' "${0}"`"
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

# put 5 articles on each "home page" calling the newest one index.html
# TODO: consider putting 10 articles on each page -- prefer smaller/faster-
#   loading pages so we're going with 5 per page now
HOME_PAGES="$(ls -1 "${GEN_DIR}/articles" | sort -r | paste - - - - - | awk '{if (NR=="1") {print "index.html "$0}else{ p=NR-1; print "older"p".html "$0}}')"

echo "${HOME_PAGES}" | cut -d ' ' -f 1 | while read HOME_PAGE
do
	"${GEN_DIR}/header.sh" Home '.' "philthompson, phil, thompson, personal, blog" "Personal blog home — philthompson.me" 3 > "${OUT_DIR}/${HOME_PAGE}"
done

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

	HOME_PAGE="$(echo "${HOME_PAGES}" | grep -m 1 "${ARTICLE_DATE}" | awk '{print $1}')"
	if [[ 1 ]]
	then
		echo "	<div class=\"container\">"
		echo "		<div class=\"article-info\">${ARTICLE_DATE_REFORMAT}</div>"
		echo "		<h1 class=\"article-title\"><a href=\"./${ARTICLE_YEAR}/${ARTICLE_TITLE_URL}.html\">${ARTICLE_TITLE}</a></h1>"

		if [[ -z "$(grep -m 1 "more://" "${ARTICLE_MARKDOWN_FILE}")" ]]
		then
			perl "${MARKDOWN_PERL_SCRIPT}" --html4tags "${ARTICLE_MARKDOWN_FILE}" | sed 's/${SITE_ROOT_REL}/./g' | sed "s#\${THIS_ARTICLE}#./${ARTICLE_YEAR}/${ARTICLE_TITLE_URL}.html#g"
		else
			perl "${MARKDOWN_PERL_SCRIPT}" --html4tags "${ARTICLE_MARKDOWN_FILE}" | grep -B 999 'more://' | grep -v 'more://' | sed 's/${SITE_ROOT_REL}/./g' | sed "s#\${THIS_ARTICLE}#./${ARTICLE_YEAR}/${ARTICLE_TITLE_URL}.html#g"
			echo "<a href=\"./${ARTICLE_YEAR}/${ARTICLE_TITLE_URL}.html\">continue reading...</a>"
		fi

		echo "      <p style=\"clear:both;\"></p>"
		echo "	</div>"
	fi >> "${OUT_DIR}/${HOME_PAGE}"
done

echo "${HOME_PAGES}" | cut -d ' ' -f 1 | while read HOME_PAGE
do
	echo "<footer>" >> "${OUT_DIR}/${HOME_PAGE}"
	echo "	<div class=\"btns\">"  >> "${OUT_DIR}/${HOME_PAGE}"

	PREV_NEXT="$(echo "${HOME_PAGES}" | cut -d ' ' -f 1 | grep -B 1 -A 1 "${HOME_PAGE}")"

	PREV_PAGE_FILE="$(echo "${PREV_NEXT}" | head -n 1)"
	NEXT_PAGE_FILE="$(echo "${PREV_NEXT}" | tail -n 1)"

	if [[ "${NEXT_PAGE_FILE}" != "${HOME_PAGE}" ]]
	then
		echo "<a class="btn" href="./${NEXT_PAGE_FILE}">Older Articles</a>" >> "${OUT_DIR}/${HOME_PAGE}"
	fi

	if [[ "${PREV_PAGE_FILE}" != "${HOME_PAGE}" ]]
	then
		echo "<a class="btn" href="./${PREV_PAGE_FILE}">Newer Articles</a>" >> "${OUT_DIR}/${HOME_PAGE}"
	fi

	echo "	</div>" >> "${OUT_DIR}/${HOME_PAGE}"

	"${GEN_DIR}/footer.sh" Home . >> "${OUT_DIR}/${HOME_PAGE}"
done

ls -1 "${OUT_DIR}"/20*/index.html | while read YEAR_FILE
do
	"${GEN_DIR}/footer.sh" "ignoreme" .. >> "${YEAR_FILE}"
done

# TODO: make archive pages with below general-purpose markdown page building loop
sort -u "${OUT_DIR}/archive/index.html" | while read LINE
do
	echo "<div class=\"article-title\">${LINE}</div>"
done >> "${OUT_DIR}/archive/tmp.html"

"${GEN_DIR}/header.sh" 'Archive' '..' "blog, archive, history, contents" "Personal blog archive — philthompson.me" 30 > "${OUT_DIR}/archive/index.html"
cat "${OUT_DIR}/archive/tmp.html" >> "${OUT_DIR}/archive/index.html"
"${GEN_DIR}/footer.sh" 'Archive' '..' >> "${OUT_DIR}/archive/index.html"
rm "${OUT_DIR}/archive/tmp.html"

# render markdown files in their static locations, and add their headers and footers
find "${GEN_DIR}/static" -type f -name "*.md" | sort -r | while read PAGE_MARKDOWN_FILE
do
	PAGE_DIR="$(dirname "${PAGE_MARKDOWN_FILE}" | sed 's#^.*static/*##')"
	mkdir -p "${OUT_DIR}/${PAGE_DIR}"
	PAGE_DIR_REL_ROOT="$(echo "${PAGE_DIR}" | sed 's#[^/][^/]*#..#g')"
	if [[ -z "${PAGE_DIR_REL_ROOT}" ]]
	then
		PAGE_DIR_REL_ROOT="."
	fi

	PAGE_HTML_FILE="$(echo "${PAGE_MARKDOWN_FILE}" | sed 's#^.*static/*##' | sed 's/\.md$/.html/')"

	PAGE_METADATA="$(grep -B 99 '^\[//\]: # (gen-meta-end)' "${PAGE_MARKDOWN_FILE}")"

	PAGE_TITLE="$(echo "${PAGE_METADATA}" | grep -m 1 gen-title: | cut -d ' ' -f 4- | sed 's/)$//')"
	PAGE_KEYWORDS="$(echo "${PAGE_METADATA}" | grep -m 1 gen-keywords: | cut -d ' ' -f 4- | sed 's/)$//')"
	PAGE_DESCRIPTION="$(echo "${PAGE_METADATA}" | grep -m 1 gen-description: | cut -d ' ' -f 4- | sed 's/)$//')"

	"${GEN_DIR}/header.sh" "${PAGE_TITLE}" "${PAGE_DIR_REL_ROOT}" "${PAGE_KEYWORDS}" "${PAGE_DESCRIPTION}" 30 > "${OUT_DIR}/${PAGE_HTML_FILE}"
	perl "${MARKDOWN_PERL_SCRIPT}" --html4tags "${PAGE_MARKDOWN_FILE}" | sed 's/${SITE_ROOT_REL}/../g' >> "${OUT_DIR}/${PAGE_HTML_FILE}"
	"${GEN_DIR}/footer.sh" "${PAGE_TITLE}" "${PAGE_DIR_REL_ROOT}" >> "${OUT_DIR}/${PAGE_HTML_FILE}"

	rm "${OUT_DIR}/${PAGE_DIR}/$(basename "${PAGE_MARKDOWN_FILE}")"
done

# run script to generate gallery/ pages
"${GEN_DIR}/gallery.sh" \
	"${STATIC_DIR}" \
	"${OUT_DIR}" \
	"${GEN_DIR}/header.sh" \
	"${GEN_DIR}/footer.sh" \
	".."
