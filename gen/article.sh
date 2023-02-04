#!/bin/bash

MARKDOWN_PERL_SCRIPT="${1}"
ARTICLE_MARKDOWN_FILE="${2}"

ARTICLE_TITLE="${3}"
ARTICLE_TITLE_URL="${4}"
ARTICLE_KEYWORDS="${5}"
ARTICLE_DESCRIPTION="${6}"
ARTICLE_DATE="${7}"

PREV_ARTICLE_URL="${8}"
NEXT_ARTICLE_URL="${9}"

HEADER_SCRIPT="${10}"
FOOTER_SCRIPT="${11}"
SITE_ROOT_REL="${12}"

COMMONMARK_SCRIPT="${13}"

# thanks to https://stackoverflow.com/a/44055875/259456
#   for showing how to keep quoted command arguments in
#   a bash variable and execute them later without eval
MARKDOWN_CMD=("perl" "${MARKDOWN_PERL_SCRIPT}" "--html4tags")
if [[ ! -z "$(grep -m 1 '(gen-markdown-flavor: CommonMark)' "${ARTICLE_MARKDOWN_FILE}")" ]]
then
	echo "article [${ARTICLE_MARKDOWN_FILE}] specifies it should use CommonMark" >&2
	MARKDOWN_CMD=("${COMMONMARK_SCRIPT}")
fi

"${HEADER_SCRIPT}" "${ARTICLE_TITLE}" "${SITE_ROOT_REL}" "${ARTICLE_KEYWORDS}" "${ARTICLE_DESCRIPTION}" 14

cat << xxxxxEOFxxxxx
			<div class="container">
				<h1 class="article-title">${ARTICLE_TITLE}</h1>
				<div class="article-info">${ARTICLE_DATE}</div>
xxxxxEOFxxxxx

"${MARKDOWN_CMD[@]}" "${ARTICLE_MARKDOWN_FILE}" | grep -v 'more://' | sed "s/\${SITE_ROOT_REL}/${SITE_ROOT_REL}/g" | sed "s#\${THIS_ARTICLE}#./${ARTICLE_TITLE_URL}.html#g"

cat << xxxxxEOFxxxxx
			</div>
			<footer>
				<div class="btns">
xxxxxEOFxxxxx


ARTICLE_YEAR="$(basename "${ARTICLE_MARKDOWN_FILE}" | cut -c 1-4)"

if [[ "${ARTICLE_YEAR}/${ARTICLE_TITLE_URL}.html" != "${PREV_ARTICLE_URL}" ]]
then
cat << xxxxxEOFxxxxx
					<a class="btn" href="${SITE_ROOT_REL}/${PREV_ARTICLE_URL}">Previous</a>
xxxxxEOFxxxxx
fi

if [[ "${ARTICLE_YEAR}/${ARTICLE_TITLE_URL}.html" != "${NEXT_ARTICLE_URL}" ]]
then
cat << xxxxxEOFxxxxx
					<a class="btn" href="${SITE_ROOT_REL}/${NEXT_ARTICLE_URL}">Next</a>
xxxxxEOFxxxxx
fi

cat << xxxxxEOFxxxxx
				</div>
xxxxxEOFxxxxx

"${FOOTER_SCRIPT}" "${ARTICLE_TITLE}" "${SITE_ROOT_REL}"
