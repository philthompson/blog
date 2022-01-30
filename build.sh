#!/usr/local/bin/bash
#
# using bash installed with homebrew, which is at
#   version 5.x, as opposed to macOS built-in bash
#   which is at version 3.x
#

THIS_SCRIPT="`perl -MCwd -le 'print Cwd::abs_path shift' "${0}"`"
THIS_DIR="$(dirname "${THIS_SCRIPT}")"
OUT_DIR="${THIS_DIR}/out/$(date +%Y-%m-%d-%H%M%S)"
GEN_DIR="${THIS_DIR}/gen"
STATIC_DIR="${THIS_DIR}/gen/static"
MARKDOWN_PERL_SCRIPT="${THIS_DIR}/Markdown_1.0.1/Markdown.pl"

if [[ "${1}" == "in-place" ]]
then
	OUT_DIR="${THIS_DIR}/out/in-place"
fi

echo "${THIS_SCRIPT}"
echo "${THIS_DIR}"
echo "${OUT_DIR}"

# make new build output dir
mkdir -p "${OUT_DIR}"

mkdir -p "${OUT_DIR}/archive"

# put static files in place, except for markdown files
#   which are rendered to .html files later
# - using rsync with "a" (archive) options EXCEPT for
#     "t" option, which has been replaced with "c" to
#     only copy a file if the checksum has changed,
#     not just the timestamp
# - note trailing slash for source (current directory)
#     and no trailing slash for dest directory to 
#     populate with current dir’s contents
# - note no delete option -- use this script without
#     "in-place" argument for final full build without
#     deleted static files
rsync -vrlpcgoD --exclude="*.md" "${STATIC_DIR}"/ "${OUT_DIR}"
#cp -rp "${STATIC_DIR}"/* "${OUT_DIR}/"

STYLE_FILE="${OUT_DIR}/css/style.css"
TMP_FILE="`bash ${GEN_DIR}/style.sh`"
if [[ ! -f "${STYLE_FILE}" ]] || [[ "`echo "${TMP_FILE}" | shasum -a 256 | cut -d ' ' -f 1`" != "`shasum -a 256 "${STYLE_FILE}" | cut -d ' ' -f 1`" ]]
then
	echo "style file [${STYLE_FILE}] IS changed"
	echo "${TMP_FILE}" > "${STYLE_FILE}"
#else
#	echo "style file [${STYLE_FILE}] is unchanged"
fi

# put 5 articles on each "home page" calling the newest one index.html
# TODO: consider putting 10 articles on each page -- prefer smaller/faster-
#   loading pages so we're going with 5 per page now
HOME_PAGES="$(ls -1 "${GEN_DIR}/articles" | sort -r | paste - - - - - | awk '{if (NR=="1") {i=NR-1; print i" index.html "$0}else{ p=NR-1; print p" older"p".html "$0}}')"

# array
#HOME_PAGES_CONTENT=()
# associative array
declare -A HOME_PAGES_CONTENT

# to allow variables outside while loop to be modified from within the
#   loop, we will use a "here string" (at the "done <<< ..." line) to
#   provide input to the while loop
#   (see https://stackoverflow.com/a/16854326/259456)
while read HOME_PAGE_LINE
do
	HOME_PAGE_IDX="`echo "${HOME_PAGE_LINE}" | cut -d ' ' -f 1`"
	HOME_PAGE="`echo "${HOME_PAGE_LINE}" | cut -d ' ' -f 2`"
	HOME_PAGES_CONTENT[$HOME_PAGE_IDX]="`bash "${GEN_DIR}/header.sh" Home '.' "philthompson, phil, thompson, personal, blog" "Personal blog home — philthompson.me" 3`"
done <<< "${HOME_PAGES}"

# content for page /archive/index.html
ARCHIVE_INDEX_CONTENT=""

# associative array
# content by year for page /<year>/index.html
declare -A YEAR_PAGES_CONTENT

buildHomepageArticleSnippet() {
	ARTICLE_DATE_REFORMAT="${1}"
	ARTICLE_YEAR="${2}"
	ARTICLE_TITLE_URL="${3}"
	ARTICLE_TITLE="${4}"
	ARTICLE_MARKDOWN_FILE="${5}"
	MARKDOWN_PERL_SCRIPT="${6}"
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
}

# to allow variables outside while loop to be modified from within the
#   loop, we will use a "here string" (at the "done <<< ..." line) to
#   provide input to the while loop
#   (see https://stackoverflow.com/a/16854326/259456)
while read ARTICLE_MARKDOWN_FILE
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

	# just do year for now -- create archive <a> tag later
	#ARCHIVE_INDEX_CONTENT="$(echo -e "${ARCHIVE_INDEX_CONTENT}\n<a href=\"../${ARTICLE_YEAR}/\">${ARTICLE_YEAR}</a>")"
	ARCHIVE_INDEX_CONTENT="$(echo -e "${ARCHIVE_INDEX_CONTENT}\n${ARTICLE_YEAR}")"

	mkdir -p "${OUT_DIR}/${ARTICLE_YEAR}"

	if [[ -z "${YEAR_PAGES_CONTENT[$ARTICLE_YEAR]}" ]]
	then
		YEAR_PAGES_CONTENT[$ARTICLE_YEAR]="`bash "${GEN_DIR}/header.sh" "Archive — ${ARTICLE_YEAR}" '..' "blog, archive, history, year, ${ARTICLE_YEAR}" "Personal blog archive for ${ARTICLE_YEAR} — philthompson.me" 7`"
	fi
	#if [[ ! -s "${OUT_DIR}/${ARTICLE_YEAR}/index.html" ]]
	#then
	#	"${GEN_DIR}/header.sh" "Archive — ${ARTICLE_YEAR}" '..' "blog, archive, history, year, ${ARTICLE_YEAR}" "Personal blog archive for ${ARTICLE_YEAR} — philthompson.me" 7 > "${OUT_DIR}/${ARTICLE_YEAR}/index.html"
	#fi

	YEAR_PAGES_CONTENT[$ARTICLE_YEAR]="$(echo -e "${YEAR_PAGES_CONTENT[$ARTICLE_YEAR]}\n<div class=\"article-title\">")"
	YEAR_PAGES_CONTENT[$ARTICLE_YEAR]="$(echo -e "${YEAR_PAGES_CONTENT[$ARTICLE_YEAR]}\n<small class=\"article-info\">${ARTICLE_DATE_REFORMAT}</small>")"
	YEAR_PAGES_CONTENT[$ARTICLE_YEAR]="$(echo -e "${YEAR_PAGES_CONTENT[$ARTICLE_YEAR]}\n<a href=\"${ARTICLE_TITLE_URL}.html\">${ARTICLE_TITLE}</a>")"
	YEAR_PAGES_CONTENT[$ARTICLE_YEAR]="$(echo -e "${YEAR_PAGES_CONTENT[$ARTICLE_YEAR]}\n</div>")"
	#echo "<div class=\"article-title\">" >> "${OUT_DIR}/${ARTICLE_YEAR}/index.html"
	#echo "<small class=\"article-info\">${ARTICLE_DATE_REFORMAT}</small>"  >> "${OUT_DIR}/${ARTICLE_YEAR}/index.html"
	#echo "<a href=\"${ARTICLE_TITLE_URL}.html\">${ARTICLE_TITLE}</a>" >> "${OUT_DIR}/${ARTICLE_YEAR}/index.html"
	#echo "</div>" >> "${OUT_DIR}/${ARTICLE_YEAR}/index.html"

	PREV_NEXT="$(ls -1 "${GEN_DIR}/articles" | sort | grep -B 1 -A 1 "${ARTICLE_DATE}.md")"

	PREV_MARKDOWN_FILE="$(echo "${PREV_NEXT}" | head -n 1)"
	NEXT_MARKDOWN_FILE="$(echo "${PREV_NEXT}" | tail -n 1)"

	PREV_MARKDOWN_FILE_YEAR="$(echo "${PREV_MARKDOWN_FILE}" | cut -d '-' -f 1)"
	NEXT_MARKDOWN_FILE_YEAR="$(echo "${NEXT_MARKDOWN_FILE}" | cut -d '-' -f 1)"

	PREV_TITLE_URL="$(grep -B 99 '^\[//\]: # (gen-meta-end)' "${GEN_DIR}/articles/${PREV_MARKDOWN_FILE}" | grep -m 1 gen-title-url: | cut -d ' ' -f 4- | sed 's/)$//')"
	NEXT_TITLE_URL="$(grep -B 99 '^\[//\]: # (gen-meta-end)' "${GEN_DIR}/articles/${NEXT_MARKDOWN_FILE}" | grep -m 1 gen-title-url: | cut -d ' ' -f 4- | sed 's/)$//')"

	TMP_FILE="$(bash "${GEN_DIR}/article.sh" \
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
		"..")"
	ARTICLE_FILE="${OUT_DIR}/${ARTICLE_YEAR}/${ARTICLE_TITLE_URL}.html"
	if [[ ! -f "${ARTICLE_FILE}" ]] || [[ "`echo "${TMP_FILE}" | shasum -a 256 | cut -d ' ' -f 1`" != "`shasum -a 256 "${ARTICLE_FILE}" | cut -d ' ' -f 1`" ]]
	then
		echo "article file [${ARTICLE_FILE}] IS changed"
		echo "${TMP_FILE}" > "${ARTICLE_FILE}"
	#else
	#	echo "article file [${ARTICLE_FILE}] is unchanged"
	fi

	HOME_PAGE_IDX="$(echo "${HOME_PAGES}" | grep -m 1 "${ARTICLE_DATE}" | awk '{print $1}')"
	# append article home page snippet to the appropriate home page
	# capture function stdout into a variable, thanks to:
	#   https://unix.stackexchange.com/a/591153/210174
	{ read -d '' ARTICLE_HOME_SNIPPET; }< <(buildHomepageArticleSnippet "${ARTICLE_DATE_REFORMAT}" "${ARTICLE_YEAR}" "${ARTICLE_TITLE_URL}" "${ARTICLE_TITLE}" "${ARTICLE_MARKDOWN_FILE}" "${MARKDOWN_PERL_SCRIPT}")
	HOME_PAGES_CONTENT[$HOME_PAGE_IDX]="$(echo -e "${HOME_PAGES_CONTENT[$HOME_PAGE_IDX]}\n       ${ARTICLE_HOME_SNIPPET}")"
#	if [[ 1 ]]
#	then
#		echo "	<div class=\"container\">"
#		echo "		<div class=\"article-info\">${ARTICLE_DATE_REFORMAT}</div>"
#		echo "		<h1 class=\"article-title\"><a href=\"./${ARTICLE_YEAR}/${ARTICLE_TITLE_URL}.html\">${ARTICLE_TITLE}</a></h1>"
#
#		if [[ -z "$(grep -m 1 "more://" "${ARTICLE_MARKDOWN_FILE}")" ]]
#		then
#			perl "${MARKDOWN_PERL_SCRIPT}" --html4tags "${ARTICLE_MARKDOWN_FILE}" | sed 's/${SITE_ROOT_REL}/./g' | sed "s#\${THIS_ARTICLE}#./${ARTICLE_YEAR}/${ARTICLE_TITLE_URL}.html#g"
#		else
#			perl "${MARKDOWN_PERL_SCRIPT}" --html4tags "${ARTICLE_MARKDOWN_FILE}" | grep -B 999 'more://' | grep -v 'more://' | sed 's/${SITE_ROOT_REL}/./g' | sed "s#\${THIS_ARTICLE}#./${ARTICLE_YEAR}/${ARTICLE_TITLE_URL}.html#g"
#			echo "<a href=\"./${ARTICLE_YEAR}/${ARTICLE_TITLE_URL}.html\">continue reading...</a>"
#		fi
#
#		echo "      <p style=\"clear:both;\"></p>"
#		echo "	</div>"
#	fi >> "${OUT_DIR}/${HOME_PAGE}"
done <<< "$(find "${GEN_DIR}/articles" -type f | sort -r)"

COMMON_HOME_PAGE_FOOTER="`bash "${GEN_DIR}/footer.sh" Home .`"
# to allow variables outside while loop to be modified from within the
#   loop, we will use a "here string" (at the "done <<< ..." line) to
#   provide input to the while loop
#   (see https://stackoverflow.com/a/16854326/259456)
while read HOME_PAGE_LINE
do
	HOME_PAGE_IDX="`echo "${HOME_PAGE_LINE}" | cut -d ' ' -f 1`"
	HOME_PAGE="`echo "${HOME_PAGE_LINE}" | cut -d ' ' -f 2`"

	HOME_PAGES_CONTENT[$HOME_PAGE_IDX]="$(echo -e "${HOME_PAGES_CONTENT[$HOME_PAGE_IDX]}\n<footer>")"
	HOME_PAGES_CONTENT[$HOME_PAGE_IDX]="$(echo -e "${HOME_PAGES_CONTENT[$HOME_PAGE_IDX]}\n	<div class=\"btns\">")"

	PREV_NEXT="$(echo "${HOME_PAGES}" | cut -d ' ' -f 2 | grep -B 1 -A 1 "${HOME_PAGE}")"

	PREV_PAGE_FILE="$(echo "${PREV_NEXT}" | head -n 1)"
	NEXT_PAGE_FILE="$(echo "${PREV_NEXT}" | tail -n 1)"

	if [[ "${NEXT_PAGE_FILE}" != "${HOME_PAGE}" ]]
	then
		HOME_PAGES_CONTENT[$HOME_PAGE_IDX]="$(echo -e "${HOME_PAGES_CONTENT[$HOME_PAGE_IDX]}\n<a class=\"btn\" href=\"./${NEXT_PAGE_FILE}\">Older Articles</a>")"
	fi

	if [[ "${PREV_PAGE_FILE}" != "${HOME_PAGE}" ]]
	then
		HOME_PAGES_CONTENT[$HOME_PAGE_IDX]="$(echo -e "${HOME_PAGES_CONTENT[$HOME_PAGE_IDX]}\n<a class=\"btn\" href=\"./${PREV_PAGE_FILE}\">Newer Articles</a>")"
	fi

	HOME_PAGES_CONTENT[$HOME_PAGE_IDX]="$(echo -e "${HOME_PAGES_CONTENT[$HOME_PAGE_IDX]}\n	</div>")"
	HOME_PAGES_CONTENT[$HOME_PAGE_IDX]="$(echo -e "${HOME_PAGES_CONTENT[$HOME_PAGE_IDX]}\n${COMMON_HOME_PAGE_FOOTER}")"

	OUT_HOME_PAGE="${OUT_DIR}/${HOME_PAGE}"
	if [[ ! -f "${OUT_HOME_PAGE}" ]] || [[ "`echo "${HOME_PAGES_CONTENT[$HOME_PAGE_IDX]}" | shasum -a 256 | cut -d ' ' -f 1`" != "`shasum -a 256 "${OUT_HOME_PAGE}" | cut -d ' ' -f 1`" ]]
	then
		echo "home page [${OUT_HOME_PAGE}] IS changed"
		echo "${HOME_PAGES_CONTENT[$HOME_PAGE_IDX]}" > "${OUT_HOME_PAGE}"
	#else
	#	echo "home page [${OUT_HOME_PAGE}] is unchanged"
	fi
done <<< "${HOME_PAGES}"

COMMON_YEAR_PAGE_FOOTER="`bash "${GEN_DIR}/footer.sh" "ignoreme" ..`"
for YEAR_FILE_YEAR in "${!YEAR_PAGES_CONTENT[@]}"
do
	YEAR_PAGES_CONTENT[$YEAR_FILE_YEAR]="$(echo -e "${YEAR_PAGES_CONTENT[$YEAR_FILE_YEAR]}\n${COMMON_YEAR_PAGE_FOOTER}")"
	YEAR_PAGE="${OUT_DIR}/${YEAR_FILE_YEAR}/index.html"
	if [[ ! -f "${YEAR_PAGE}" ]] || [[ "`echo "${YEAR_PAGES_CONTENT[$YEAR_FILE_YEAR]}" | shasum -a 256 | cut -d ' ' -f 1`" != "`shasum -a 256 "${YEAR_PAGE}" | cut -d ' ' -f 1`" ]]
	then
		echo "year page [${YEAR_PAGE}] IS changed"
		echo "${YEAR_PAGES_CONTENT[$YEAR_FILE_YEAR]}" > "${YEAR_PAGE}"
	#else
	#	echo "year page [${YEAR_PAGE}] is unchanged"
	fi
done

# TODO: make archive pages with below general-purpose markdown page building loop
# since a line with the year is added for each article, we need to keep
#   only the unique years
ARCHIVE_INDEX_SORT_U="`echo "${ARCHIVE_INDEX_CONTENT}" | sort -u | sed '/^$/d'`"
ARCHIVE_INDEX_CONTENT=""
while read LINE
do
	ARCHIVE_INDEX_CONTENT="$(echo -e "${ARCHIVE_INDEX_CONTENT}\n<div class=\"article-title\"><a href=\"../${LINE}/\">${LINE}</a></div>")"
done <<< "${ARCHIVE_INDEX_SORT_U}"


TMP_FILE="`bash "${GEN_DIR}/header.sh" 'Archive' '..' "blog, archive, history, contents" "Personal blog archive — philthompson.me" 30`"
# prepend header before existing archive file content
ARCHIVE_INDEX_CONTENT="$(echo -e "${TMP_FILE}\n${ARCHIVE_INDEX_CONTENT}")"
TMP_FILE="`bash "${GEN_DIR}/footer.sh" 'Archive' '..'`"
# append footer after existing archive file content
ARCHIVE_INDEX_CONTENT="$(echo -e "${ARCHIVE_INDEX_CONTENT}\n${TMP_FILE}")"

ARCHIVE_FILE="${OUT_DIR}/archive/index.html"
if [[ ! -f "${ARCHIVE_FILE}" ]] || [[ "`echo "${ARCHIVE_INDEX_CONTENT}" | shasum -a 256 | cut -d ' ' -f 1`" != "`shasum -a 256 "${ARCHIVE_FILE}" | cut -d ' ' -f 1`" ]]
then
	echo "${ARCHIVE_INDEX_CONTENT}" > "${ARCHIVE_FILE}"
else
	echo "archive file [${ARCHIVE_FILE}] is unchanged"
fi

#tmp comment out to find double quote syntax error
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

	TMP_HEADER="`bash "${GEN_DIR}/header.sh" "${PAGE_TITLE}" "${PAGE_DIR_REL_ROOT}" "${PAGE_KEYWORDS}" "${PAGE_DESCRIPTION}" 30`"
	TMP_CONTENT="`perl "${MARKDOWN_PERL_SCRIPT}" --html4tags "${PAGE_MARKDOWN_FILE}" | sed 's/${SITE_ROOT_REL}/../g'`"
	TMP_FOOTER="`bash "${GEN_DIR}/footer.sh" "${PAGE_TITLE}" "${PAGE_DIR_REL_ROOT}"`"

	# embed newline chars directly in the code here, in order to
	#   avoid having to use "echo -e" and mess up newlines embedded
	#   in the variable contents
	TMP_CONTENT="${TMP_HEADER}
${TMP_CONTENT}
${TMP_FOOTER}"

	STATIC_HTML_FILE="${OUT_DIR}/${PAGE_HTML_FILE}"
	if [[ ! -f "${STATIC_HTML_FILE}" ]] || [[ "`echo "${TMP_CONTENT}" | shasum -a 256 | cut -d ' ' -f 1`" != "`shasum -a 256 "${STATIC_HTML_FILE}" | cut -d ' ' -f 1`" ]]
	then
		echo "static file [${STATIC_HTML_FILE}] IS changed"
		echo "${TMP_CONTENT}" > "${STATIC_HTML_FILE}"
	#else
	#	echo "static file [${STATIC_HTML_FILE}] is unchanged"
	fi

	# static/**/*.md files are excluded from rsync and thus are
	#   not copied to the out dir in the first place
	#rm "${OUT_DIR}/${PAGE_DIR}/$(basename "${PAGE_MARKDOWN_FILE}")"
done

# run script to generate gallery/ pages
bash "${GEN_DIR}/gallery.sh" \
	"${STATIC_DIR}" \
	"${OUT_DIR}" \
	"${GEN_DIR}/header.sh" \
	"${GEN_DIR}/footer.sh" \
	".."
