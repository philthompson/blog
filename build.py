'''

To install python dependencies:

        $ python3 -m venv python-venv
        $ source python-venv/bin/activate
        $ python3 -m pip install -r python-requirements.txt
        $ deactivate

To install new dependencies:

        $ source python-venv/bin/activate
        $ python3 -m pip install ...
        $ python3 -m pip freeze > python-requirements.txt

To update python dependencies if the `python-requirements.txt` file is updated:

        $ source python-venv/bin/activate
        $ python3 -m pip install --ignore-installed -r python-requirements.txt


to replace build.sh

- assumes 'in-place' behavior if the target directory already exists
- TODO:
    - looks like rsync is copying static .md files?  they're not supposed to end up in the build dir
    - make python version of gallery.sh
    - figure out how to compare all files in out/in-place vs out/python-in-place, and only swap over to new one once they're identical

python3 build.py out/python-in-place --skip-gallery

'''

import base64
import hashlib
import re
import subprocess
import sys

from datetime import datetime
from io import StringIO
from itertools import batched
from pathlib import Path

from markdown_it import MarkdownIt

import gen.buildArticle as buildArticle
import gen.buildFooter as buildFooter
import gen.buildGallery as buildGallery
import gen.buildHeader as buildHeader
import gen.buildMandelbrotGallery as buildMandelbrotGallery
import gen.buildStyle as buildStyle
import gen.generatePhotoDirectory as generatePhotoDirectory

usage = f"usage: {sys.argv[0]} <output-dir> [--skip-gallery] [--verbose]"

if len(sys.argv) < 2:
	print(usage, file=sys.stderr)
	sys.exit(1)

skip_gallery = False
verbose = False

for option_arg in sys.argv[2:]:
	if option_arg == '--skip-gallery':
		skip_gallery = True
	elif option_arg == '--verbose':
		verbose = True
	else:
		print(usage, file=sys.stderr)
		sys.exit(1)

#out_dir = Path(__file__).parent.joinpath(sys.argv[1])
out_dir = Path(sys.argv[1])
if not out_dir.is_dir():
	out_dir.mkdir(parents=True, exist_ok=True)

this_dir = Path(__file__).parent
gen_dir = this_dir.joinpath("gen")
static_dir = gen_dir.joinpath("static")

style_generator_bash_script = gen_dir.joinpath("style.sh")
style_generator_out_file = out_dir.joinpath('css').joinpath('style.css')
style_generator_out_file.parent.mkdir(parents=True, exist_ok=True)

RSS_FINAL_FILENAME = "feed.xml"
RSS_FINAL = out_dir.joinpath(RSS_FINAL_FILENAME)
RSS_BIRDS_GALLERY_ITEMS_FILE = out_dir.joinpath('rss-birds-gallery-items.txt')
rss_items_by_timestamp = {}

articles_dir = gen_dir.joinpath("articles")

# by using a file to cache the latest gallery info,
#   we can --skip-gallery to do a quick build without
#   even looking at all the gallery files
GALLERY_LATEST_FILE = out_dir.joinpath("gallery-latest.txt")

# special case: don't allow this build.py to touch the output dir used by build.sh
if out_dir.samefile(this_dir.joinpath("out").joinpath("in-place")):
	print(f"cannot output to [{out_dir}] from python script (use out/python-in-place)", file=sys.stderr)
	sys.exit(1)

# the top-level URL
SITE_URL="https://philthompson.me"

def ts():
	return f"[{datetime.now().isoformat()}]"

# string -> utf8 bytes -> b64 bytes -> utf8 string
def b64Encode(s):
	return base64.b64encode(s.encode("utf-8")).decode('utf-8')

def b64Decode(s):
	return base64.b64decode(s.encode('utf-8')).decode("utf-8")

def writeFileOnlyIfChanged(content, path, name):
	content_hash = hashlib.sha256(content.encode("utf-8")).hexdigest()
	file_content = None
	if path.exists() and path.is_file():
		with open(path, encoding='utf-8') as f:
			file_content = f.read()
	if file_content is None or hashlib.sha256(file_content.encode("utf-8")).hexdigest() != content_hash:
		print(f"{ts()} {name} [{path}] IS changed")
		path.parent.mkdir(parents=True, exist_ok=True)
		# use 'x' mode to open for writing, failing if the file already exists
		# use 'w' mode to open for writing, truncating if file already exists
		with open(path, 'w', encoding='utf-8') as f:
			f.write(content)

# written with help from ChatGPT "5 Thinking" on 2025-11-08
def getLinesUntilLineContaining(content, thing_to_look_for):
	idx = content.find(thing_to_look_for)
	if idx == -1:
		return content
	# find start of the line containing thing_to_look_for
	line_start = content.rfind("\n", 0, idx)
	# if the thing_to_look_for is on the first line, return nothing
	return content[0:line_start+1] if line_start != -1 else ""

def buildHomepageArticleSnippet(*, ARTICLE_DATE_REFORMAT, ARTICLE_YEAR, ARTICLE_TITLE_URL, ARTICLE_TITLE, ARTICLE_MARKDOWN_FILE, article_md_content):
	lines = []
	lines.append(f"	<div class=\"container\">")
	lines.append(f"		<div class=\"article-info\">{ARTICLE_DATE_REFORMAT}</div>")
	lines.append(f"		<h1 class=\"article-title\"><a href=\"./{ARTICLE_YEAR}/{ARTICLE_TITLE_URL}.html\">{ARTICLE_TITLE}</a></h1>")

	# Markdown It uses commonmark by default, so we'll try that for all pages
	# https://pypi.org/project/markdown-it-py/
	md = MarkdownIt()

	if 'gen-markdown-flavor: CommonMark' in article_md_content:
		print(f"article [{ARTICLE_MARKDOWN_FILE}] specifies it should use CommonMark, but for now we are using CommonMark for all articles")

	snippet_md_content = getLinesUntilLineContaining(article_md_content, "more://")

	rendered_html = md.render(snippet_md_content).replace('${SITE_ROOT_REL}', '.').replace('${THIS_ARTICLE}', f"{ARTICLE_YEAR}/{ARTICLE_TITLE_URL}.html")
	lines.append(rendered_html)

	if "more://" in article_md_content:
		lines.append(f"<a href=\"./{ARTICLE_YEAR}/{ARTICLE_TITLE_URL}.html\">continue reading...</a>")

	lines.append("      <p style=\"clear:both;\"></p>")
	lines.append("	</div>")
	return "\n".join(lines)

def buildArticleRssItem(*, ARTICLE_DATE, ARTICLE_YEAR, ARTICLE_TITLE_URL, ARTICLE_TITLE, ARTICLE_MARKDOWN_FILE, SITE_HOME_URL):

	# since the articles are dated like:
	#   YYYY-MM-DD, or
	#   YYYY-MM-DD-N (where N is the Nth article for the day)
	# we can use midnight for the time, plus N hours
	# append "-0" to date if missing the 4th dash-delimited field
	article_date_with_suffix = ARTICLE_DATE	+ "-0"
	article_date_with_suffix = '-'.join(article_date_with_suffix.split('-')[0:4])
	artdate_parsed = datetime.strptime(article_date_with_suffix, "%Y-%m-%d-%H")
	# format according to https://www.w3.org/Protocols/rfc822/#z28
	ARTICLE_DATE_RSS = artdate_parsed.astimezone().strftime('%a, %d %b %Y %H:00:00 %z')
	ARTICLE_DATE_TS = int(artdate_parsed.strftime('+%s'))

	ABSOLUTE_ARTICLE_URL = f"{SITE_HOME_URL}/{ARTICLE_YEAR}/{ARTICLE_TITLE_URL}.html"

	lines = []
	lines.append(f"  <item>")
	lines.append(f"    <title>{ARTICLE_TITLE}</title>")
	lines.append(f"    <link>{ABSOLUTE_ARTICLE_URL}</link>")
	lines.append(f"    <pubDate>{ARTICLE_DATE_RSS}</pubDate>")

	# Markdown It uses commonmark by default, so we'll try that for all pages
	# https://pypi.org/project/markdown-it-py/
	md = MarkdownIt()

	if 'gen-markdown-flavor: CommonMark' in article_md_content:
		print(f"article [{ARTICLE_MARKDOWN_FILE}] specifies it should use CommonMark, but for now we are using CommonMark for all articles")

	snippet_md_content = getLinesUntilLineContaining(article_md_content, "more://")

	# important here, possibly, to replace relative links with absolute ones
	#   so that links work in RSS readers
	rendered_html = md.render(snippet_md_content).replace('${SITE_ROOT_REL}', SITE_HOME_URL).replace('${THIS_ARTICLE}', ABSOLUTE_ARTICLE_URL)

	if "more://" in article_md_content:
		rendered_html += f'<a href="{ABSOLUTE_ARTICLE_URL}">continue reading...</a>'

	rendered_html_lines = rendered_html.splitlines()
	# remove copyright html comment
	rendered_html_lines = [x for x in rendered_html_lines if not '!-- Copyright' in x]
	# it's probably not necessary, but remove leading/trailing whitespace
	#   from all html lines
	rendered_html_lines = [x.strip() for x in rendered_html_lines]
	lines.append("    <description><![CDATA[" + ''.join(rendered_html_lines) + "]]></description>")

	lines.append(f"    <category>articles</category>")
	lines.append(f"    <guid>{ABSOLUTE_ARTICLE_URL}</guid>")
	lines.append(f"  </item>\n")

	return (ARTICLE_DATE_TS, "\n".join(lines))

# for RSS file, concatenate:
# - header
# - latest birds gallery items file
# - latest blog items file
# - footer
def buildRssFile(*, SITE_URL, RSS_FINAL_FILENAME, ITEMS_BY_TIMESTAMP):
	# format date according to https://www.w3.org/Protocols/rfc822/#z28
	RSS_BUILD_DATE = datetime.now().astimezone().strftime('%a, %d %b %Y %H:%M:%S %z')
	# use the last <item> element's <pubDate> as the feed file's <pubDate>
	RSS_PUBLISH_DATE = RSS_BUILD_DATE

	content = ''
	# pull out <item> contents in order to create final xml
	for item_timestamp in sorted(ITEMS_BY_TIMESTAMP.keys()):
		content += ITEMS_BY_TIMESTAMP[item_timestamp]
		found_pub_dates = [x for x in ITEMS_BY_TIMESTAMP[item_timestamp].splitlines() if '<pubDate>' in x]
		if len(found_pub_dates) > 0:
			RSS_PUBLISH_DATE = found_pub_dates[-1]
			# '<pubDate>Thu, 10 Oct 2024 00:00:00 -0700</pubDate>' -> 'Thu, 10 Oct 2024 00:00:00 -0700'
			RSS_PUBLISH_DATE = RSS_PUBLISH_DATE.split('>', 1)[1].split('<')[0]

	# since <item> elements each have a trailing \n newline, notice below we follow {content} without a newline before '  </channel>'
	return f"""<rss version="2.0" xmlns:atom="http://www.w3.org/2005/Atom">
  <channel>
    <title>philthompson.me</title>
    <link>{SITE_URL}</link>
    <atom:link href=\"{SITE_URL}/{RSS_FINAL_FILENAME}\" rel=\"self\" type=\"application/rss+xml\" />
    <description>Phil Thompson's blog and photo galleries</description>
    <language>en-us</language>
    <copyright>Copyright $(date +%Y) Phil Thompson, All Rights Reserved</copyright>
    <pubDate>{RSS_PUBLISH_DATE}</pubDate>
    <lastBuildDate>{RSS_BUILD_DATE}</lastBuildDate>
{content}  </channel>
</rss>"""

def buildHomepageBirdsGalleryLink(*, GALLERY_LATEST_FILE, SITE_ROOT_REL):
	#gallery_latest_data = GALLERY_LATEST_FILE.read_text(encoding='utf-8').replace("SITE_ROOT_REL", SITE_ROOT_REL)
	gallery_latest_data = readFileContent(GALLERY_LATEST_FILE).replace("SITE_ROOT_REL", SITE_ROOT_REL)
	# use the first three lines of gallery-latest.txt as variable values here
	GALLERY_PAGE_REL, SHOOT_FAVORITE, SHOOT_DATE = gallery_latest_data.split("\n")[0:3]

	return f"""<!-- <a> element is temporary during NFL season, and next <a>'s <div> has margin-top:1.0rem -->
	<a href="{SITE_ROOT_REL}/nfl-elo/2025.html" style="text-decoration:none">
		<div class="container" style="margin-bottom: 0rem; text-align: center; background-color:rgba(150,150,150,0.1); padding:1rem; overflow:hidden; border-radius: 0.3rem;">
			🏈 2025 NFL Elo Power Rankings 🏈
		</div>
	</a>
	<a href="{GALLERY_PAGE_REL}" style="text-decoration:none">
		<!-- temporary during NFL season: margin-top:1.0rem -->
		<div class="container" style="margin-top:1.0rem; background-color:rgba(150,150,150,0.1); padding:1.0rem; overflow:hidden; border-radius: 0.3rem">
			<img class="width-40" style="float:right" src="{SHOOT_FAVORITE}" />
			Latest Bird Gallery:<br/>{SHOOT_DATE}
		</div>
	</a>
"""

def getGenMetaContentLines(*, article_md_content):
	return getLinesUntilLineContaining(article_md_content, "\n[//]: # (gen-meta-end)").splitlines()

# when 'gen-title' is keyword:
# '[//]: # (gen-title: Searching for a Magic: Square of (Squares))'  --> 'Searching for a Magic: Square of (Squares)'
def getGenMetaLineContent(*, gen_meta_lines, gen_meta_keyword):
	#print(f"looking for [{gen_meta_keyword}] among lines:\n{gen_meta_lines}")
	found = [x.split(': ',2)[-1].removesuffix(')') for x in gen_meta_lines if (gen_meta_keyword + ':') in x][0:1]
	#print(f"found: {found}")
	#sys.exit(0)
	if len(found) == 0:
		return None
	return found[0]

# first tries utf-8 encoding
file_content_cache = {}
file_content_cache_hits = 0
file_content_cache_misses = 0
def readFileContent(some_path):
	global file_content_cache
	global file_content_cache_hits
	global file_content_cache_misses
	some_path_s = str(some_path)
	if some_path_s in file_content_cache:
		file_content_cache_hits += 1
		return file_content_cache[some_path_s]
	file_content_cache_misses += 1
	try:
		file_content_cache[some_path_s] = some_path.read_text(encoding='utf-8')
		return file_content_cache[some_path_s]
	except UnicodeDecodeError:
		print(f"error trying to read [{some_path}] with utf-8 encoding, so trying us-ascii...", file=sys.stderr, flush=True)
		sys.exit(0)
		file_content_cache[some_path_s] = some_path.read_text(encoding='us-ascii')
		return file_content_cache[some_path_s]

def serializeRssItemsFileContent(items_by_int_timestamp):
	buffer = StringIO()
	for ts in sorted(items_by_int_timestamp.keys()):
		# the default base64 alphabet doesn't use colon (:) so we'll use that as a separator
		buffer.write(str(ts)) # where ts is unix style "seconds from epoch" integer timestamp
		buffer.write(':')
		buffer.write(b64Encode(items_by_int_timestamp[ts]))
		buffer.write('\n')
	return buffer.getvalue()

def deserializeRssItemsFileContent(serialized):
	items_by_int_timestamp = {}
	for line in serialized.splitlines():
		ts, content_b64 = line.strip().split(':', 1)
		items_by_int_timestamp[int(ts)] = b64Decode(content_b64)
	return items_by_int_timestamp

# ====-====-====-====-====-====-====-====-====-====
# ====-====-====-====-====-====-====-====-====-====
# ====-====-====-====-====-====-====-====-====-====


############################
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
print(f"{ts()} running rsync...")
result = subprocess.run(
	["rsync", "-vrlpcgoD",
	#"--dry-run",
	"--exclude=.DS_Store",
	"--exclude=*.md",
	"--exclude=mandelbrot-gallery/*",
	"--exclude=gallery-img/**/*.db",
	"--exclude=gallery-img/**/*.supplement",
	"--exclude=gallery-img/**/*.txid",
	str(static_dir) + '/', # note trailing slash for source dir
	str(out_dir)], # note absence of trailing slash for dest dir
	capture_output=True, text=True, check=True
)
print(result.stdout)
#print(result.returncode)
#sys.exit(0)

############################
# generate style.css (executing .sh replaced with gen/buildStyle.py)
#cli_process_and_args = ["/bin/bash", str(style_generator_bash_script)]
#print(f"{ts()} running {cli_process_and_args}...")
#result = subprocess.run(cli_process_and_args, capture_output=True, text=True)
#if result.returncode != 0:
#	print(f"subprocess returned code [{result.returncode}]", file=sys.stderr)
#	print(f"stdout:\n{result.stdout}")
#	print(f"stderr:\n{result.stderr}")
#	sys.exit(1)
#writeFileOnlyIfChanged(result.stdout, style_generator_out_file, 'style.css')
writeFileOnlyIfChanged(buildStyle.generate(), style_generator_out_file, 'style.css')


############################
# 5 articles per page, where each destination filename has a set() of its article files
home_pages = []
home_page_content = {}
home_page_article_set_by_filename = {}
for page_articles in batched(sorted([x.name for x in articles_dir.iterdir() if x.is_file()], reverse=True), 5):
	article_set = set(page_articles)
	home_page_file = "index.html"
	if len(home_pages) > 0:
		home_page_file = f"older{len(home_pages)}.html"
	home_page_article_set_by_filename[home_page_file] = article_set
	home_pages.append(home_page_file)
	home_page_content[home_page_file] = buildHeader.generate(page_title="Home", SITE_ROOT_REL='.', meta_keywords="philthompson, phil, thompson, personal, blog", meta_description="Personal blog home — philthompson.me")



# after the header, but before the article snippets,
#   insert the latest birds gallery picture+link
#   (this requires building the birds gallery pages
#   here, before the articles)
############################
# run the script to generate all gallery files
if not skip_gallery:

	birds_rss_items_by_timestamp = buildGallery.buildGalleryPages(\
		STATIC_DIR=static_dir, OUT_DIR=out_dir, \
		header_fn=buildHeader.generate, footer_fn=buildFooter.generate, \
		SITE_ROOT_REL='..', SITE_HOME_URL=SITE_URL, GALLERY_LATEST_FILE=GALLERY_LATEST_FILE, \
		readFileFn=readFileContent, writeIfChangedFn=writeFileOnlyIfChanged)

	birds_rss_items_file_content = serializeRssItemsFileContent(birds_rss_items_by_timestamp)
	writeFileOnlyIfChanged(birds_rss_items_file_content, RSS_BIRDS_GALLERY_ITEMS_FILE, "gallery RSS items file")


############################
# put links at top of first home page (index.html)
home_page_content["index.html"] += "\n" + buildHomepageBirdsGalleryLink(GALLERY_LATEST_FILE=GALLERY_LATEST_FILE, SITE_ROOT_REL=".")

year_pages_content_by_int_year = {}

############################
# loop over all article files
article_filename_date_pattern = re.compile(r"^20[0-9]{2}-[0-9]{2}-[0-9]{2}[^/]*\.md$")
sorted_article_files = sorted([x for x in articles_dir.iterdir() if x.is_file()], reverse=True)
unfiltered_article_files_len = len(sorted_article_files)
sorted_article_files = [x for x in sorted_article_files if article_filename_date_pattern.fullmatch(x.name) is not None]
if unfiltered_article_files_len > len(sorted_article_files):
	print(f"{ts()} skipping [{unfiltered_article_files_len-len(sorted_article_files)}] files not named like an article")
for i in range(0, len(sorted_article_files)):
	article_file = sorted_article_files[i]
	if verbose: print(f"{ts()} handling article file [{article_file}]")

	article_md_content = readFileContent(article_file)
	gen_meta_content_lines = getGenMetaContentLines(article_md_content=article_md_content)

	# '[//]: # (gen-title: Searching for a Magic: Square of (Squares))'  --> 'Searching for a Magic: Square of (Squares)'
	#ARTICLE_TITLE = [x.split(': ',2)[-1].removesuffix(')') for x in gen_meta_content_lines if 'gen-title:' in x][0:1]
	#ARTICLE_TITLE_URL = [x.split(': ',2)[-1].removesuffix(')') for x in gen_meta_content_lines if 'gen-title-url:' in x][0:1]
	#ARTICLE_KEYWORDS = [x.split(': ',2)[-1].removesuffix(')') for x in gen_meta_content_lines if 'gen-keywords:' in x][0:1]
	#ARTICLE_DESCRIPTION = [x.split(': ',2)[-1].removesuffix(')') for x in gen_meta_content_lines if 'gen-description:' in x][0:1]
	ARTICLE_TITLE       = getGenMetaLineContent(gen_meta_lines=gen_meta_content_lines, gen_meta_keyword='gen-title')
	ARTICLE_TITLE_URL   = getGenMetaLineContent(gen_meta_lines=gen_meta_content_lines, gen_meta_keyword='gen-title-url')
	ARTICLE_KEYWORDS    = getGenMetaLineContent(gen_meta_lines=gen_meta_content_lines, gen_meta_keyword='gen-keywords')
	ARTICLE_DESCRIPTION = getGenMetaLineContent(gen_meta_lines=gen_meta_content_lines, gen_meta_keyword='gen-description')
	
	ARTICLE_DATE = article_file.stem

	artdate_parsed = datetime.strptime('-'.join(ARTICLE_DATE.split('-')[0:3]), "%Y-%m-%d")
	ARTICLE_DATE_REFORMAT = f"{artdate_parsed:%B} {artdate_parsed.day}, {artdate_parsed:%Y}" # no leading zero for day of month
	ARTICLE_YEAR = int(ARTICLE_DATE.split('-')[0])

	year_out_dir = out_dir.joinpath(str(ARTICLE_YEAR))
	if not ARTICLE_YEAR in year_pages_content_by_int_year:
		year_out_dir.mkdir(exist_ok=True)
		year_pages_content_by_int_year[ARTICLE_YEAR] = buildHeader.generate(page_title=f"Archive — {ARTICLE_YEAR}", SITE_ROOT_REL='..', meta_keywords=f"blog, archive, history, year, {ARTICLE_YEAR}", meta_description=f"Personal blog archive for {ARTICLE_YEAR} — philthompson.me", meta_revisit_after_days=7)
		year_pages_content_by_int_year[ARTICLE_YEAR] += "\n" + '<p></p>'

	year_pages_content_by_int_year[ARTICLE_YEAR] += f"""<div class=\"article-title\">
<small class=\"article-info\">{ARTICLE_DATE_REFORMAT}</small>
<a href=\"{ARTICLE_TITLE_URL}.html\">{ARTICLE_TITLE}</a>
</div>"""

	# find prev and next articles without re-reading the entire articles dir
	prev_article_file = None if i == len(sorted_article_files)-1 else sorted_article_files[i+1]
	next_article_file = None if i == 0 else sorted_article_files[i-1]

	prev_article_file_year = None if prev_article_file is None else prev_article_file.name.split('-')[0]
	next_article_file_year = None if next_article_file is None else next_article_file.name.split('-')[0]

	prev_article_file_title_url = None if prev_article_file is None else getGenMetaLineContent(gen_meta_lines=getGenMetaContentLines(article_md_content=readFileContent(prev_article_file)), gen_meta_keyword='gen-title-url')
	next_article_file_title_url = None if next_article_file is None else getGenMetaLineContent(gen_meta_lines=getGenMetaContentLines(article_md_content=readFileContent(next_article_file)), gen_meta_keyword='gen-title-url')

	prev_article_rel_url = None if prev_article_file is None else prev_article_file_year + '/' + prev_article_file_title_url + '.html'
	next_article_rel_url = None if next_article_file is None else next_article_file_year + '/' + next_article_file_title_url + '.html'

	article_html_content = buildArticle.generate(article_md_content=article_md_content,
		ARTICLE_TITLE=ARTICLE_TITLE, ARTICLE_TITLE_URL=ARTICLE_TITLE_URL, ARTICLE_KEYWORDS=ARTICLE_KEYWORDS, ARTICLE_DESCRIPTION=ARTICLE_DESCRIPTION,
		ARTICLE_DATE=ARTICLE_DATE_REFORMAT, PREV_ARTICLE_REL_URL=prev_article_rel_url, NEXT_ARTICLE_REL_URL=next_article_rel_url, SITE_ROOT_REL='..')

	# replace page path into page content
	article_html_content = article_html_content.replace('REPLACE_PAGE_URL', f"/{ARTICLE_YEAR}/{ARTICLE_TITLE_URL}.html")

	out_article_file = out_dir.joinpath(str(ARTICLE_YEAR)).joinpath(ARTICLE_TITLE_URL + '.html')
	writeFileOnlyIfChanged(article_html_content, out_article_file, "article file")
	
	home_page_snippet = buildHomepageArticleSnippet(ARTICLE_DATE_REFORMAT=ARTICLE_DATE_REFORMAT, ARTICLE_YEAR=ARTICLE_YEAR, \
		ARTICLE_TITLE_URL=ARTICLE_TITLE_URL, ARTICLE_TITLE=ARTICLE_TITLE, ARTICLE_MARKDOWN_FILE=article_file, article_md_content=article_md_content)
	for home_page_file,article_set in home_page_article_set_by_filename.items():
		if not article_file.name in article_set:
			continue
		home_page_content[home_page_file] += '\n' + home_page_snippet

	# put the latest 10 articles into the RSS feed
	if i < 10:
		rss_article_ts,rss_article_item = buildArticleRssItem(ARTICLE_DATE=ARTICLE_DATE, ARTICLE_YEAR=ARTICLE_YEAR, \
			ARTICLE_TITLE_URL=ARTICLE_TITLE_URL, ARTICLE_TITLE=ARTICLE_TITLE, ARTICLE_MARKDOWN_FILE=article_file, SITE_HOME_URL=SITE_URL)
		rss_items_by_timestamp[rss_article_ts] = rss_article_item


##########################
# loop over home pages
for i in range(0, len(home_pages)):
	home_page_file = home_pages[i]

	older_btn = f'<a class="btn" href="./{home_pages[i+1]}">Older Articles</a>' if i < len(home_pages) - 1 else ''
	newer_btn = f'<a class="btn" href="./{home_pages[i-1]}">Newer Articles</a>' if i > 0 else ''

	home_page_content[home_page_file] += f"""<footer>
	<div class="btns">
		{older_btn}{newer_btn}
	</div>"""

	home_page_content[home_page_file] += buildFooter.generate(SITE_ROOT_REL='.')

	# replace page path into page content
	PAGE_PATH_FROM_ROOT = f"/{home_page_file}"
	home_page_content[home_page_file].replace("REPLACE_PAGE_URL", PAGE_PATH_FROM_ROOT)

	OUT_HOME_PAGE_FILE = out_dir.joinpath(home_page_file)
	writeFileOnlyIfChanged(home_page_content[home_page_file], OUT_HOME_PAGE_FILE, "home page")


##########################
# loop over archive year pages
for YEAR_FILE_YEAR in year_pages_content_by_int_year:

	year_pages_content_by_int_year[YEAR_FILE_YEAR] += buildFooter.generate(SITE_ROOT_REL='..')

	# replace page path into page content
	PAGE_PATH_FROM_ROOT = f"/{YEAR_FILE_YEAR}/index.html"
	year_pages_content_by_int_year[YEAR_FILE_YEAR].replace("REPLACE_PAGE_URL", PAGE_PATH_FROM_ROOT)

	YEAR_PAGE_FILE = out_dir.joinpath(str(YEAR_FILE_YEAR)).joinpath("index.html")
	writeFileOnlyIfChanged(year_pages_content_by_int_year[YEAR_FILE_YEAR], YEAR_PAGE_FILE, "year page")


##########################
# make archive page
if True: # i don't want to pollute the global scope with variables, so using if block... could move to function...
	archive_page_content = buildHeader.generate(page_title="Archive", SITE_ROOT_REL='..', meta_keywords="blog, archive, history, contents", meta_description="Personal blog archive — philthompson.me", meta_revisit_after_days=30)
	archive_page_content += "\n<p></p>\n"
	for YEAR in sorted(year_pages_content_by_int_year.keys()):
		archive_page_content += f'<div class="article-title"><a href="../{YEAR}/">{YEAR}</a></div>\n'
	archive_page_content += buildFooter.generate(SITE_ROOT_REL='..')
	
	# replace page path into page content
	PAGE_PATH_FROM_ROOT = "/archive/index.html"
	archive_page_content.replace("REPLACE_PAGE_URL", PAGE_PATH_FROM_ROOT)
	
	ARCHIVE_FILE = out_dir.joinpath("archive").joinpath("index.html")
	writeFileOnlyIfChanged(archive_page_content, ARCHIVE_FILE, "archive file")


###########################
# make mandelbrot gallery pages
if True: # i don't want to pollute the global scope with variables, so using if block... could move to function...

	MANDELBROT_GALLERY_YEAR_DIRS = sorted([x for x in static_dir.joinpath("mandelbrot-gallery").iterdir() if x.is_dir() and x.name.startswith('2') and x.name.isdigit()])

	PAGE_PATH_FROM_ROOT = "/mandelbrot-gallery/index.html"
	MANDELBROT_GALLERY_INDEX_PAGE = out_dir.joinpath("mandelbrot-gallery").joinpath("index.html")

	LATEST_MANDELBROT_GALLERY_YEAR = MANDELBROT_GALLERY_YEAR_DIRS[-1].name

	MANDELBROT_GALLERY_INDEX_CONTENT = buildMandelbrotGallery.generateMandelbrotGalleryIndexPage(DEFAULT_URL=f"./{LATEST_MANDELBROT_GALLERY_YEAR}.html")
	# replace page path into page content
	MANDELBROT_GALLERY_INDEX_CONTENT.replace("REPLACE_PAGE_URL", PAGE_PATH_FROM_ROOT)
	writeFileOnlyIfChanged(MANDELBROT_GALLERY_INDEX_CONTENT, MANDELBROT_GALLERY_INDEX_PAGE, "mandelbrot gallery index")

	for i in range(0, len(MANDELBROT_GALLERY_YEAR_DIRS)):
		MANDELBROT_GALLERY_YEAR_DIR = MANDELBROT_GALLERY_YEAR_DIRS[i]

		MANDELBROT_GALLERY_YEAR = MANDELBROT_GALLERY_YEAR_DIR.name
		MANDELBROT_MD_FILE = MANDELBROT_GALLERY_YEAR_DIR.parent.joinpath(f"{MANDELBROT_GALLERY_YEAR}.md")

		PREV_YEAR = MANDELBROT_GALLERY_YEAR_DIRS[i-1].name if i > 0 else None
		NEXT_YEAR = MANDELBROT_GALLERY_YEAR_DIRS[i+1].name if i < len(MANDELBROT_GALLERY_YEAR_DIRS) - 1 else None

		MANDELBROT_PAGE_CONTENT = buildMandelbrotGallery.generateMandelbrotGalleryPageHeader(SITE_ROOT_REL='..', \
			THE_YEAR=MANDELBROT_GALLERY_YEAR, PREV_YEAR=PREV_YEAR, NEXT_YEAR=NEXT_YEAR)

		MANDELBROT_PAGE_CONTENT += '\n<div class="wide-override">'

		# image files are named with their date, so sorting will display them on
		#   the page in date order
		for MANDELBROT_IMG in sorted([x for x in MANDELBROT_GALLERY_YEAR_DIR.iterdir() if x.is_file()]):

			IMG_BASENAME = MANDELBROT_IMG.name

			if IMG_BASENAME == "example.txt":
				continue

			IMG_DATE_PARSED = datetime.strptime(IMG_BASENAME[0:10], "%Y-%m-%d")

			# date -j -f %Y-%m-%d 2022-02-24 "+%B %-d, %Y"
			IMG_DATE = IMG_DATE_PARSED.strftime("%B %-d, %Y")
			IMG_THUMB = ""
			IMG_TITLE = ""
			IMG_DESC = ""
			IMG_PARAMS = ""
			IMG_RENDER_URLS_BY_KEY = {}
			IMG_RE = ""
			IMG_IM = ""
			IMG_MAG = ""
			IMG_SCALE = ""
			IMG_ITER = ""

			for IMG_LINE in readFileContent(MANDELBROT_IMG).splitlines():
				if not ':' in IMG_LINE or IMG_LINE.strip().startswith('#'):
					continue
				LINE_KEY, LINE_VAL = IMG_LINE.strip().split(':', 1)
				if LINE_KEY == "thumb":
					IMG_THUMB = LINE_VAL
				elif LINE_KEY == "title":
					IMG_TITLE = LINE_VAL
				elif LINE_KEY == "desc":
					IMG_DESC = LINE_VAL
				elif LINE_KEY == "params":
					IMG_PARAMS = LINE_VAL
				elif LINE_KEY == "re":
					IMG_RE = LINE_VAL
				elif LINE_KEY == "im":
					IMG_IM = LINE_VAL
				elif LINE_KEY == "mag":
					IMG_MAG = LINE_VAL
				elif LINE_KEY == "scale":
					IMG_SCALE = LINE_VAL
				elif LINE_KEY == "iterations":
					IMG_ITER = LINE_VAL
				# render01, render02, etc, are placed in dict for displaying in order
				elif LINE_KEY[0:6] == "render":
					IMG_RENDER_URLS_BY_KEY[LINE_KEY] = LINE_VAL

			MANDELBROT_IMG_HTML_LINES = buildMandelbrotGallery.generateMandelbrotImageHtml(SITE_ROOT_REL='..',\
				 IMG_DATE=IMG_DATE, IMG_THUMB=IMG_THUMB, IMG_TITLE=IMG_TITLE, IMG_DESC=IMG_DESC, \
				 IMG_PARAMS=IMG_PARAMS, IMG_RENDER_URLS_BY_KEY=IMG_RENDER_URLS_BY_KEY, \
				 IMG_RE=IMG_RE, IMG_IM=IMG_IM, IMG_MAG=IMG_MAG, IMG_SCALE=IMG_SCALE, IMG_ITER=IMG_ITER).splitlines()
			MANDELBROT_IMG_HTML_LINES = [x for x in MANDELBROT_IMG_HTML_LINES if len(x.strip()) > 0 and '<p></p>' not in x]

			MANDELBROT_PAGE_CONTENT += '\n' + '\n'.join(MANDELBROT_IMG_HTML_LINES)

		MANDELBROT_PAGE_CONTENT += "\n</div>"

		# see if the generated markdown has changed
		writeFileOnlyIfChanged(MANDELBROT_PAGE_CONTENT, MANDELBROT_MD_FILE, "mandelbrot gallery markdown file")


###########################
# generate photo galleries directory page
generatePhotoDirectory.build(SITE_ROOT_REL='.', static_gen_path=static_dir)


###########################
# render markdown files in their static locations, and add their headers and footers
for static_walk_dirname, _, static_walk_filenames in static_dir.walk():
	for static_walk_filename in static_walk_filenames:
		if not static_walk_filename.endswith(".md"):
			continue
		PAGE_MARKDOWN_FILE = static_walk_dirname.joinpath(static_walk_filename)
		if verbose: print(f"{ts()} handling static markdown file [{PAGE_MARKDOWN_FILE}]")

		PAGE_DIR = static_walk_dirname.relative_to(static_dir)

		PAGE_DIR.mkdir(parents=True, exist_ok=True)

		PAGE_DIR_REL_ROOT = ['..'] # start with one ".." since we don't have a do...while loop here
		PAGE_DIR_PARENT = PAGE_DIR.parent
		loops = 0
		while str(PAGE_DIR_PARENT) != '.':
			#print(f"{PAGE_MARKDOWN_FILE=}, {PAGE_DIR=}, {PAGE_DIR_PARENT=}", flush=True)
			loops += 1
			if loops > 10:
				print(f"too many .parent.parent... loops", flush=True)
				sys.exit(0)
			PAGE_DIR_REL_ROOT.append('..')
			PAGE_DIR_PARENT = PAGE_DIR_PARENT.parent
		#if len(PAGE_DIR_REL_ROOT) == 0:
		#	PAGE_DIR_REL_ROOT.append('.')
		MD_PAGE_SITE_ROOT_REL = '/'.join(PAGE_DIR_REL_ROOT)

		PAGE_HTML_FILE = PAGE_MARKDOWN_FILE.relative_to(static_dir).with_suffix('.html')

		PAGE_METADATA = getGenMetaContentLines(article_md_content=readFileContent(PAGE_MARKDOWN_FILE))

		PAGE_TITLE       = getGenMetaLineContent(gen_meta_lines=PAGE_METADATA, gen_meta_keyword='gen-title')
		PAGE_KEYWORDS    = getGenMetaLineContent(gen_meta_lines=PAGE_METADATA, gen_meta_keyword='gen-keywords')
		PAGE_DESCRIPTION = getGenMetaLineContent(gen_meta_lines=PAGE_METADATA, gen_meta_keyword='gen-description')

		TMP_HEADER = buildHeader.generate(page_title=PAGE_TITLE, SITE_ROOT_REL=MD_PAGE_SITE_ROOT_REL, meta_keywords=PAGE_KEYWORDS, meta_description=PAGE_DESCRIPTION, meta_revisit_after_days=30)
		TMP_CONTENT = MarkdownIt().render(readFileContent(PAGE_MARKDOWN_FILE)).replace('${SITE_ROOT_REL}', MD_PAGE_SITE_ROOT_REL)
		TMP_FOOTER = buildFooter.generate(SITE_ROOT_REL=MD_PAGE_SITE_ROOT_REL)

		TMP_CONTENT = f"{TMP_HEADER}\n{TMP_CONTENT}\n{TMP_FOOTER}"

		# replace page path into page content
		PAGE_PATH_FROM_ROOT = f"/{PAGE_HTML_FILE}"
		TMP_CONTENT = TMP_CONTENT.replace("REPLACE_PAGE_URL", PAGE_PATH_FROM_ROOT)

		STATIC_HTML_FILE = out_dir.joinpath(PAGE_HTML_FILE)
		writeFileOnlyIfChanged(TMP_CONTENT, STATIC_HTML_FILE, "static file")


###########################
# RSS feed file
if True: # i don't want to pollute the global scope with variables, so using if block... could move to function...

	# read birds RSS items previously serialized to file
	if RSS_BIRDS_GALLERY_ITEMS_FILE.is_file():
		birds_rss_items = deserializeRssItemsFileContent(readFileContent(RSS_BIRDS_GALLERY_ITEMS_FILE))
		# merge articles and birds RSS items
		rss_items_by_timestamp.update(birds_rss_items)
	rss_file_content = buildRssFile(SITE_URL=SITE_URL, RSS_FINAL_FILENAME=RSS_FINAL_FILENAME, ITEMS_BY_TIMESTAMP=rss_items_by_timestamp)

	writeFileOnlyIfChanged(rss_file_content, RSS_FINAL, "RSS file")


print(f"{ts()} done with build")
subprocess.run("/usr/bin/say done with build".split(" "))

if verbose:
	print(f"{ts()} file_content_cache has the contents of [{len(file_content_cache)}] files")
	print(f"{ts()} {file_content_cache_hits=}")
	print(f"{ts()} {file_content_cache_misses=}")

























