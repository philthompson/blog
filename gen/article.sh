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


"${HEADER_SCRIPT}" "${ARTICLE_TITLE}" "${SITE_ROOT_REL}" "${ARTICLE_KEYWORDS}" "${ARTICLE_DESCRIPTION}" 14

cat << xxxxxEOFxxxxx
			<div class="container">
				<h1 class="article-title">${ARTICLE_TITLE}</h1>
				<div class="article-info">${ARTICLE_DATE}</div>
xxxxxEOFxxxxx

perl "${MARKDOWN_PERL_SCRIPT}" --html4tags "${ARTICLE_MARKDOWN_FILE}" | grep -v 'more://'

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
