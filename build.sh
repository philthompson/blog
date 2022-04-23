#!/usr/local/bin/bash
#
# using bash installed with homebrew, which is at
#   version 5.x, as opposed to macOS built-in bash
#   which is at version 3.x
#
# TODO: (for in-place mode) when a (.html) file is
#   changed or unchanged, add its full path to a list.
#   then, compare all (.html) files to that list to
#   find (.html) files that should be deleted (move
#   them to a out/in-place/trash-yyyymmddhhmmss dir).
#   then after doing this, we should be able to also
#   compare the gen/static dir to the out/in-place dir
#   to find static files that have been deleted.
#
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

SKIP_GALLERY="false"
if [[ "${2}" == "skip-gallery" ]]
then
	SKIP_GALLERY="true"
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
rsync -vrlpcgoD \
  --exclude="*.md" \
  --exclude="mandelbrot-gallery/*" \
  --exclude="gallery-img/**/*.db" \
  --exclude="gallery-img/**/*.supplement" \
  --exclude="gallery-img/**/*.txid" \
  "${STATIC_DIR}"/ "${OUT_DIR}"
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
	#ARCHIVE_INDEX_CONTENT="$(echo -e "${ARCHIVE_INDEX_CONTENT}\n${ARTICLE_YEAR}")"
	# embed newline directly into variable
	ARCHIVE_INDEX_CONTENT="${ARCHIVE_INDEX_CONTENT}
${ARTICLE_YEAR}"

	mkdir -p "${OUT_DIR}/${ARTICLE_YEAR}"

	if [[ -z "${YEAR_PAGES_CONTENT[$ARTICLE_YEAR]}" ]]
	then
		YEAR_PAGES_CONTENT[$ARTICLE_YEAR]="`bash "${GEN_DIR}/header.sh" "Archive — ${ARTICLE_YEAR}" '..' "blog, archive, history, year, ${ARTICLE_YEAR}" "Personal blog archive for ${ARTICLE_YEAR} — philthompson.me" 7`"
	fi

	# embed newlines directly into variables
	YEAR_PAGES_CONTENT[$ARTICLE_YEAR]="${YEAR_PAGES_CONTENT[$ARTICLE_YEAR]}
<div class=\"article-title\">
<small class=\"article-info\">${ARTICLE_DATE_REFORMAT}</small>
<a href=\"${ARTICLE_TITLE_URL}.html\">${ARTICLE_TITLE}</a>
</div>"

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
	# embed newline directly into variable
	HOME_PAGES_CONTENT[$HOME_PAGE_IDX]="${HOME_PAGES_CONTENT[$HOME_PAGE_IDX]}
       ${ARTICLE_HOME_SNIPPET}"

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

	# embed newlines directly into variables
	HOME_PAGES_CONTENT[$HOME_PAGE_IDX]="${HOME_PAGES_CONTENT[$HOME_PAGE_IDX]}
<footer>"
	HOME_PAGES_CONTENT[$HOME_PAGE_IDX]="${HOME_PAGES_CONTENT[$HOME_PAGE_IDX]}
	<div class=\"btns\">"

	PREV_NEXT="$(echo "${HOME_PAGES}" | cut -d ' ' -f 2 | grep -B 1 -A 1 "${HOME_PAGE}")"

	PREV_PAGE_FILE="$(echo "${PREV_NEXT}" | head -n 1)"
	NEXT_PAGE_FILE="$(echo "${PREV_NEXT}" | tail -n 1)"

	if [[ "${NEXT_PAGE_FILE}" != "${HOME_PAGE}" ]]
	then
		HOME_PAGES_CONTENT[$HOME_PAGE_IDX]="${HOME_PAGES_CONTENT[$HOME_PAGE_IDX]}
<a class=\"btn\" href=\"./${NEXT_PAGE_FILE}\">Older Articles</a>"
	fi

	if [[ "${PREV_PAGE_FILE}" != "${HOME_PAGE}" ]]
	then
		HOME_PAGES_CONTENT[$HOME_PAGE_IDX]="${HOME_PAGES_CONTENT[$HOME_PAGE_IDX]}
<a class=\"btn\" href=\"./${PREV_PAGE_FILE}\">Newer Articles</a>"
	fi

	HOME_PAGES_CONTENT[$HOME_PAGE_IDX]="${HOME_PAGES_CONTENT[$HOME_PAGE_IDX]}
	</div>"
	HOME_PAGES_CONTENT[$HOME_PAGE_IDX]="${HOME_PAGES_CONTENT[$HOME_PAGE_IDX]}
${COMMON_HOME_PAGE_FOOTER}"

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
	YEAR_PAGES_CONTENT[$YEAR_FILE_YEAR]="${YEAR_PAGES_CONTENT[$YEAR_FILE_YEAR]}
${COMMON_YEAR_PAGE_FOOTER}"
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
	ARCHIVE_INDEX_CONTENT="${ARCHIVE_INDEX_CONTENT}
<div class=\"article-title\"><a href=\"../${LINE}/\">${LINE}</a></div>"
done <<< "${ARCHIVE_INDEX_SORT_U}"


TMP_FILE="`bash "${GEN_DIR}/header.sh" 'Archive' '..' "blog, archive, history, contents" "Personal blog archive — philthompson.me" 30`"
# prepend header before existing archive file content
ARCHIVE_INDEX_CONTENT="${TMP_FILE}
${ARCHIVE_INDEX_CONTENT}"
TMP_FILE="`bash "${GEN_DIR}/footer.sh" 'Archive' '..'`"
# append footer after existing archive file content
ARCHIVE_INDEX_CONTENT="${ARCHIVE_INDEX_CONTENT}
${TMP_FILE}"

ARCHIVE_FILE="${OUT_DIR}/archive/index.html"
if [[ ! -f "${ARCHIVE_FILE}" ]] || [[ "`echo "${ARCHIVE_INDEX_CONTENT}" | shasum -a 256 | cut -d ' ' -f 1`" != "`shasum -a 256 "${ARCHIVE_FILE}" | cut -d ' ' -f 1`" ]]
then
	echo "archive file [${ARCHIVE_FILE}] IS changed"
	echo "${ARCHIVE_INDEX_CONTENT}" > "${ARCHIVE_FILE}"
#else
#	echo "archive file [${ARCHIVE_FILE}] is unchanged"
fi

# generate mandelbrot-gallery STATIC markdown pages
# these static pages are then output as html by the regular below static page stuff

generateMandelbrotGalleryIndexPage() {
cat << xxxxxEOFxxxxx
!DOCTYPE html>
<html lang="en">
	<head>
		<meta http-equiv="refresh" content="0; url=${1}">
	</head>
	<body></body>
</html>
xxxxxEOFxxxxx
}

#
# for nicer overall layout, the gallery pages' content will be wider
#   than a normal blog post using a "wide-override" CSS class
# to center the wider child <div> inside the narrower parent <div>,
#   "wide-override" uses this: https://stackoverflow.com/a/48608339/259456
#

generateMandelbrotGalleryPageHeader() {
	THE_YEAR="${1}"
	PREV_YEAR="${2}"
	NEXT_YEAR="${3}"
	PREV_BUTTON=""
	NEXT_BUTTON=""
	if [[ "${PREV_YEAR}" != "${THE_YEAR}" ]]
	then
		PREV_BUTTON="<a class=\"btn\" href=\"./${PREV_YEAR}.html\">${PREV_YEAR} Gallery</a>"
	fi
	if [[ "${NEXT_YEAR}" != "${THE_YEAR}" ]]
	then
		NEXT_BUTTON="<a class=\"btn\" href=\"./${NEXT_YEAR}.html\">${NEXT_YEAR} Gallery</a>"
	fi
cat << xxxxxEOFxxxxx

<!-- this file is generated by build.sh -->

[//]: # (gen-title: Mandelbrot set Gallery)

[//]: # (gen-keywords: Mandelbrot set, gallery, very plotter, fractal, art)

[//]: # (gen-description: Mandelbrot set Gallery for images generated with Very Plotter)

[//]: # (gen-meta-end)

<style>
	.img-container {
		padding-top: 1.0rem;
		padding-bottom: 1.0rem;
		border-top: 1px solid #949b96;
	}
	details, details summary {
		display: inline;
	}
	details summary {
		list-style: none;
	}
	details > summary::-webkit-details-marker {
		display: none;
	}
	details[open] {
		display: block;
		margin-left: auto;
		margin-right: auto;
		max-width: 100%;
		padding-top: 1.0rem;
		padding-bottom: 1.0rem;
		border-top: 1px solid #949b96;
		border-bottom: 1px solid #949b96;
	}
	#loc {
		word-wrap: break-word;
	}
	@media screen and (min-width: 64rem) {
		.width-resp-50-100 {
			padding-left: 1.25%;
			padding-right: 1.25%;
			max-width: 30%;
		}
	}
	@media screen and (min-width: 104rem) {
		.width-resp-50-100 {
			padding-left: 1.2%;
			padding-right: 1.2%;
			max-width: 22%;
		}
	}
	.wide-override {
		width: 100%
	}
	@media screen and (min-width: 48rem) {
		.wide-override {
			width: 47rem;
			left: 50%;
			position: relative;
			transform: translateX(-50%);
		}
	}
	@media screen and (min-width: 54rem) {
		.wide-override { width: 52rem; }
	}
	@media screen and (min-width: 64rem) {
		.wide-override { width: 61rem; }
	}
	@media screen and (min-width: 74rem) {
		.wide-override { width: 70rem; }
	}
	@media screen and (min-width: 84rem) {
		.wide-override { width: 80rem; }
	}
	@media screen and (min-width: 94rem) {
		.wide-override { width: 90rem; }
	}
	@media screen and (min-width: 104rem) {
		.wide-override { width: 98rem; }
	}
	.btns {
		margin: 1rem 0;
	}
</style>

## ${THE_YEAR} Mandelbrot set Gallery

These images were all generated with
<a href="\${SITE_ROOT_REL}/very-plotter" target="_self">Very Plotter</a>'s Mandelbrot set
explorer.  Click any image below to view details, a link to open that location in your
browser, and larger renders.

<div class="btns">${PREV_BUTTON}
${NEXT_BUTTON}</div>
xxxxxEOFxxxxx
}

generateMandelbrotImageHtml() {
	IMG_DATE="${1}"
	IMG_THUMB="${2}"
	IMG_TITLE="${3}"
	IMG_DESC="${4}"
	IMG_PARAMS="${5}"
	IMG_RENDERS="${6}"
	IMG_RE="${7}"
	IMG_IM="${8}"
	IMG_MAG="${9}"
	IMG_SCALE="${10}"
	IMG_ITER="${11}"
	RENDERS_HTML=""
	# create html list of renders
	if [[ ! -z "${IMG_RENDERS}" ]]
	then
		RENDERS_HTML="<p>Available renders:</p>
<ul>"
		while read RENDER_URL
		do
			RENDER_NAME="$(basename "${RENDER_URL}")"
			RENDERS_HTML="${RENDERS_HTML}
<li><a target=\"_blank\" href=\"${RENDER_URL}\">${RENDER_NAME}</a></li>"
		done <<< "${IMG_RENDERS}"
		RENDERS_HTML="${RENDERS_HTML}
</ul>"
	fi
cat <<- xxxxxEOFxxxxx
<details class="width-resp-50-100">
	<summary>
		<img class="width-100" src="${IMG_THUMB}"/>
	</summary>
	<p>${IMG_DATE}: ${IMG_TITLE}</p>
	<p>${IMG_DESC}</p>
	<p>Click
		<a target="_blank" href="\${SITE_ROOT_REL}/very-plotter/${IMG_PARAMS}">
		here</a> to view this location in Very Plotter.</p>
	${RENDERS_HTML}
	<p id="loc">Location:<br/>
	Re:&nbsp;${IMG_RE}<br/>
	Im:&nbsp;${IMG_IM}<br/>
	Magnification:&nbsp;${IMG_MAG} <small>(where 1.0 fits entire Mandelbrot set into the window)</small><br/>
	Scale:&nbsp;${IMG_SCALE} <small>(pixels/unit, for renders seen here)</small><br/>
	Iterations:&nbsp;${IMG_ITER}</p>
</details>
xxxxxEOFxxxxx
}

MANDELBROT_GALLERY_YEAR_DIRS="$(find "${STATIC_DIR}/mandelbrot-gallery" -type d -name "2*")"

MANDELBROT_GALLERY_INDEX_PAGE="${OUT_DIR}/mandelbrot-gallery/index.html"
LATEST_MANDELBROT_GALLERY_YEAR="$(echo "${MANDELBROT_GALLERY_YEAR_DIRS}" | sort -nr | head -n 1)"
LATEST_MANDELBROT_GALLERY_YEAR="$(basename "${LATEST_MANDELBROT_GALLERY_YEAR}")"

# capture function stdout into a variable, thanks to:
#   https://unix.stackexchange.com/a/591153/210174
{ read -d '' MANDELBROT_GALLERY_INDEX_CONTENT; }< <(generateMandelbrotGalleryIndexPage "./${LATEST_MANDELBROT_GALLERY_YEAR}.html")

if [[ ! -f "${MANDELBROT_GALLERY_INDEX_PAGE}" ]] || [[ "`echo "${MANDELBROT_GALLERY_INDEX_CONTENT}" | shasum -a 256 | cut -d ' ' -f 1`" != "`shasum -a 256 "${MANDELBROT_GALLERY_INDEX_PAGE}" | cut -d ' ' -f 1`" ]]
then
	echo "${MANDELBROT_GALLERY_INDEX_CONTENT}" > "${MANDELBROT_GALLERY_INDEX_PAGE}"
else
	echo "mandelbrot gallery index [${MANDELBROT_GALLERY_INDEX_PAGE}] is unchanged"
fi

while read MANDELBROT_GALLERY_YEAR_DIR
do
	MANDELBROT_GALLERY_YEAR="$(basename "${MANDELBROT_GALLERY_YEAR_DIR}")"
	MANDELBROT_MD_PAGE="${MANDELBROT_GALLERY_YEAR_DIR}.md"

	PREV_NEXT="$(echo "${MANDELBROT_GALLERY_YEAR_DIRS}" | sort -n | grep -B 1 -A 1 "${MANDELBROT_GALLERY_YEAR}")"

	PREV_YEAR="$(basename "$(echo "${PREV_NEXT}" | head -n 1)")"
	NEXT_YEAR="$(basename "$(echo "${PREV_NEXT}" | tail -n 1)")"

	{ read -d '' MANDELBROT_PAGE_CONTENT; }< <(generateMandelbrotGalleryPageHeader "${MANDELBROT_GALLERY_YEAR}" "${PREV_YEAR}" "${NEXT_YEAR}")

	# embed newlines directly into variable
	MANDELBROT_PAGE_CONTENT="${MANDELBROT_PAGE_CONTENT}
<div class=\"wide-override\">"

	while read MANDELBROT_IMG
	do
		IMG_BASENAME="$(basename "${MANDELBROT_IMG}")"

		if [[ "${IMG_BASENAME}" == "example.txt" ]]
		then
			continue
		fi

		# date -j -f %Y-%m-%d 2022-02-24 "+%B %-d, %Y"
		IMG_DATE="$(date -j -f %Y-%m-%d "${IMG_BASENAME:0:10}" "+%B %-d, %Y")"
		IMG_THUMB=""
		IMG_TITLE=""
		IMG_DESC=""
		IMG_PARAMS=""
		IMG_RENDER_LINES=""
		IMG_RE=""
		IMG_IM=""
		IMG_MAG=""
		IMG_SCALE=""
		IMG_ITER=""

		while read IMG_LINE
		do
			LINE_KEY="$(echo "${IMG_LINE}" | cut -d : -f 1)"
			LINE_VAL="$(echo "${IMG_LINE}" | cut -d : -f 2-)"
			if [[ "${LINE_KEY}" == "thumb" ]]
			then
				IMG_THUMB="${LINE_VAL}"
			elif [[ "${LINE_KEY}" == "title" ]]
			then
				IMG_TITLE="${LINE_VAL}"
			elif [[ "${LINE_KEY}" == "desc" ]]
			then
				IMG_DESC="${LINE_VAL}"
			elif [[ "${LINE_KEY}" == "params" ]]
			then
				IMG_PARAMS="${LINE_VAL}"
			elif [[ "${LINE_KEY}" == "re" ]]
			then
				IMG_RE="${LINE_VAL}"
			elif [[ "${LINE_KEY}" == "im" ]]
			then
				IMG_IM="${LINE_VAL}"
			elif [[ "${LINE_KEY}" == "mag" ]]
			then
				IMG_MAG="${LINE_VAL}"
			elif [[ "${LINE_KEY}" == "scale" ]]
			then
				IMG_SCALE="${LINE_VAL}"
			elif [[ "${LINE_KEY}" == "iterations" ]]
			then
				IMG_ITER="${LINE_VAL}"
			# render01, render02, etc keys are matched and re-assembled into
			#   one variable
			elif [[ "${LINE_KEY:0:6}" == "render" ]]
			then
				IMG_RENDER_LINES="${IMG_RENDER_LINES}
${LINE_KEY}:${LINE_VAL}"
			fi
		done <<< "$(grep -v "^#" "${MANDELBROT_IMG}" | grep -v "^$")"

		# sort render01, render02, etc lines then drop line keys
		IMG_RENDERS="$(echo "${IMG_RENDER_LINES}" | grep -v "^$" | sort -n | cut -d : -f 2-)"

		{ read -d '' MANDELBROT_IMG_HTML; }< <(generateMandelbrotImageHtml "${IMG_DATE}" "${IMG_THUMB}" "${IMG_TITLE}" "${IMG_DESC}" "${IMG_PARAMS}" "${IMG_RENDERS}" "${IMG_RE}" "${IMG_IM}" "${IMG_MAG}" "${IMG_SCALE}" "${IMG_ITER}" | grep -v "^$" | grep -v "<p></p>")

		# embed newlines directly into variable
		MANDELBROT_PAGE_CONTENT="${MANDELBROT_PAGE_CONTENT}
${MANDELBROT_IMG_HTML}"

	# image files are named with their date, so sorting will display them on
	#   the page in date order
	done <<< "$(find "${MANDELBROT_GALLERY_YEAR_DIR}" -type f | sort)"

	MANDELBROT_PAGE_CONTENT="${MANDELBROT_PAGE_CONTENT}
</div>"

	if [[ ! -f "${MANDELBROT_MD_PAGE}" ]] || [[ "`echo "${MANDELBROT_PAGE_CONTENT}" | shasum -a 256 | cut -d ' ' -f 1`" != "`shasum -a 256 "${MANDELBROT_MD_PAGE}" | cut -d ' ' -f 1`" ]]
	then
		echo "${MANDELBROT_PAGE_CONTENT}" > "${MANDELBROT_MD_PAGE}"
	else
		echo "mandelbrot gallery markdown file [${MANDELBROT_MD_PAGE}] is unchanged"
	fi

done <<< "${MANDELBROT_GALLERY_YEAR_DIRS}"

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

if [[ "${SKIP_GALLERY}" == "false" ]]
then
	# run script to generate gallery/ pages
	bash "${GEN_DIR}/gallery.sh" \
		"${STATIC_DIR}" \
		"${OUT_DIR}" \
		"${GEN_DIR}/header.sh" \
		"${GEN_DIR}/footer.sh" \
		".."
fi
