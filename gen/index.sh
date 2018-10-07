#!/bin/bash

MARKDOWN_PERL_SCRIPT="${1}"
ARTICLE_MARKDOWN_FILE="${2}"

ARTICLE_TITLE="${3}"
ARTICLE_TITLE_URL="${4}"
ARTICLE_DATE="${5}"

PREV_ARTICLE_URL="${6}"
NEXT_ARTICLE_URL="${7}"

HEADER_SCRIPT="${8}"
FOOTER_SCRIPT="${9}"
SITE_ROOT_REL="${10}"


"${HEADER_SCRIPT}" "${ARTICLE_TITLE}" "${SITE_ROOT_REL}"

cat << xxxxxEOFxxxxx
			<section class="container">
				<h1 class="article-title">${ARTICLE_TITLE}</h1>
				<div class="article-info">${ARTICLE_DATE}</div>
xxxxxEOFxxxxx

perl "${MARKDOWN_PERL_SCRIPT}" --html4tags "${ARTICLE_MARKDOWN_FILE}" | grep -v 'more://'

cat << xxxxxEOFxxxxx
<!DOCTYPE html>
			</section>
			<footer>
				<div class="btns">
					<a class="btn" href="${PREV_ARTICLE_URL}">Previous</a>
					<a class="btn" href="${NEXT_ARTICLE_URL}">Next</a>
				</div>
xxxxxEOFxxxxx

"${FOOTER_SCRIPT}" "${ARTICLE_TITLE}" "${SITE_ROOT_REL}"
