
from markdown_it import MarkdownIt

from . import buildHeader
from . import buildFooter

def generate(*, article_md_content,
		ARTICLE_TITLE, ARTICLE_TITLE_URL, ARTICLE_KEYWORDS, ARTICLE_DESCRIPTION,
		ARTICLE_DATE, PREV_ARTICLE_REL_URL, NEXT_ARTICLE_REL_URL, SITE_ROOT_REL):
	
	htmlHeaderContent = buildHeader.generate(page_title=ARTICLE_TITLE, SITE_ROOT_REL=SITE_ROOT_REL, meta_keywords=ARTICLE_KEYWORDS, meta_description=ARTICLE_DESCRIPTION)
	
	htmlBodyContentLines = MarkdownIt().render(article_md_content) \
		.replace('${SITE_ROOT_REL}', SITE_ROOT_REL) \
		.replace('${THIS_ARTICLE}', f"./{ARTICLE_TITLE_URL}.html") \
		.splitlines()
	
	htmlBodyContentLines = [x for x in htmlBodyContentLines if not 'more://' in x]

	prev_article_link = "" if PREV_ARTICLE_REL_URL is None else f'<a class="btn" href="{SITE_ROOT_REL}/{PREV_ARTICLE_REL_URL}">Previous</a>'
	next_article_link = "" if NEXT_ARTICLE_REL_URL is None else f'<a class="btn" href="{SITE_ROOT_REL}/{NEXT_ARTICLE_REL_URL}">Next</a>'

	htmlFooterContent = buildFooter.generate(SITE_ROOT_REL=SITE_ROOT_REL)

	return f"""{htmlHeaderContent}
			<div class="container">
				<h1 class="article-title">{ARTICLE_TITLE}</h1>
				<div class="article-info">{ARTICLE_DATE}</div>
{'\n'.join(htmlBodyContentLines)}
			</div>
			<footer>
				<div class="btns">
					{prev_article_link}{next_article_link}
				</div>
{htmlFooterContent}\n"""