# python 3

from datetime import datetime
from hashlib import sha256
from io import StringIO
from pathlib import Path
import sys

# for local dev, to fetch actual server images
#SITE_ROOT_REL='https://philthompson.me'
# for real just use this
SITE_ROOT_REL='..'

misc_static_dir_path = Path(__file__).parent.joinpath("static").joinpath("misc")

# the markdown file we will be generating
misc_static_index_markdown = misc_static_dir_path.joinpath("index.md")

misc_items_by_year = {
	2024: [
		{
			'root_rel_url': 'misc/noise-flow-field/',
			'title': 'Noise Flow Field',
			'photo': 'noise-flow-field-screenshot.png',
			'desc': 'An image generator that uses a Perlin noise flow field.'
		},{
			'root_rel_url': 'misc/cascading-bloom-filters/',
			'title': 'Cascading Bloom Filters',
			'photo': 'cascading-bloom-filters-screenshot.png',
			'desc': 'A JavaScript app for playing with cascading bloom filters.'
		},{
			'root_rel_url': 'misc/click-counter/',
			'title': 'Click Counter',
			'photo': 'click-counter-screenshot.jpg',
			'desc': 'A simple JavaScript app for counting things in photos.'
		},
	],
	2023: [
		{
			'root_rel_url': 'misc/6174/',
			'title': '6174',
			'photo': '6174-screenshot.jpg',
			'desc': '''
Little JavaScript pages for playing with the <a href="SITE_ROOT_REL/misc/6174/">4-digit</a> and <a href="SITE_ROOT_REL/misc/6174/k-digit.html">k-digit</a> Kaprekar Routines.'''
		},{
			'root_rel_url': 'nfl-elo/',
			'title': 'NFL Elo Power Rankings',
			'photo': 'nfl-elo-hero.jpg',
			'desc': '''
NFL power rankings based on Elo ratings.<br/><br/>
Written in Python, this project parses Wikipedia data, calculates Elo ratings, and outputs the above linked page.
The project includes a test harness for adjusting Elo rating model parameters, which backtests the model on thousands
of NFL games (more than 10 full seasons at the time of writing).<br/><br/>
For more background, see my blog post <a href="SITE_ROOT_REL/2023/NFL-Elo-Power-Rankings-for-2023.html">here</a>.'''
		},{
			'root_rel_url': 'misc/partial-string-match-for-birds/search.html',
			'title': 'Partial String Match for Birds',
			'photo': 'partial-string-match-for-birds-screenshot.jpg',
			'desc': '''
An app to demonstrate partial string match for bird species names.<br/>
I tested out algorithms for finding partial string matches of bird species names, and
found one that worked well enough, and ran fast enough, for use in smartphone apps
(this would fix a gripe I have with the otherwise perfect eBird app).<br/>
I implemented the algorithm in JavaScript, and published pages for testing and running the algorithms.
For more background, see my blog post <a href="SITE_ROOT_REL/2023/Partial-String-Match-for-Birds.html">here</a>.'''
		},{
			'root_rel_url': 'misc/smarter-than-a-chimp/',
			'title': '"Smarter Than a Chimp" game',
			'photo': 'smarter-than-a-chimp-screenshot.jpg',
			'desc': '''
A JavaScript game similar to one from this video: <a href="https://www.youtube.com/watch?v=zsXP8qeFF6A">https://www.youtube.com/watch?v=zsXP8qeFF6A</a>.<br/><br/>
The source code is availble in its <a href="https://github.com/philthompson/smarter-than-chimp">GitHub repository</a>.'''
		}
	],
	2021: [
		{
			'root_rel_url': 'jars/',
			'title': 'Water Jars game',
			'photo': 'water-jars-screenshot.jpg',
			'desc': '''
A small JavaScript implementation of the game where, given three containers, water must be evenly divided between the largest pair.
I also created a <a href="SITE_ROOT_REL/jars/solver.html">standalone solver page</a> for any set of three containers.<br/><br/>
The source code is availble in its <a href="https://github.com/philthompson/water-jars">GitHub repository</a>.'''
		},{
			'root_rel_url': 'very-plotter/',
			'title': 'Very Plotter',
			'photo': 'very-plotter-screenshot.jpg',
			'desc': '''
View the Mandelbrot set, and plots of a few mathematical sequences.
This app uses JavaScript worker threads, the number of which can be updated on the fly.<br/><br/>
The source code is availble in its <a href="https://github.com/philthompson/visualize-primes">GitHub repository</a>.'''
		}
	],
	2018: [
		{
			'root_rel_url': 'qrcode.html',
			'title': 'qrcodejs',
			'photo': 'qrcode-screenshot.jpg',
			'desc': '''
A JavaScript page for interactively generating QR codes.<br/><br/>
The source code is availble in its <a href="https://github.com/philthompson/qrcodejs">GitHub repository</a>.'''
		},{
			'root_rel_url': 'screensavejs/',
			'title': 'screensavejs',
			'photo': 'screensavejs-screenshot.jpg',
			'desc': 'A JavaScript page that paints a blurry rendition of any image file.'
		}
	],
	2015: [
		{
			'root_rel_url': 'misc/black-and-white/',
			'title': 'Black & White Box',
			'photo': 'black-and-white-screenshot.jpg',
			'desc': '''
JavaScript toy that finds a box (many are possible) describing the percentage of
black and white pixels where <i>the text itself</i> is counted.<br/><br/>
This was inspired by the xkcd #688 <a target="_blank" href="https://xkcd.com/688/">"Self-Description"</a>.<br/><br/>
The source code is availble in my original <a href="https://jsfiddle.net/b8w1coga/">jsfiddle</a>.'''
		}
	]
}

# for now, just open the file a second time if a write is needed
def overwrite_file_if_changed(*, file_path, new_contents_bytes):
	if file_path.is_file():
		with open(file_path, mode="rb") as f:
			file_contents_hash = sha256(f.read()).hexdigest()

			# if the hash of the contents is different than what's already
			#   on disk, write to disk
			new_contents_hash = sha256(new_contents_bytes).hexdigest()

			if file_contents_hash == new_contents_hash:
				return False

	print(f'writing changed contents into file [{file_path}]')
	with open(file_path, mode="wb") as f:
		f.write(new_contents_bytes)
	return True

def write_header(*, buffer):
	global SITE_ROOT_REL

	buffer.write(f"""
<!-- this file is generated by generateMiscGallery.py -->

[//]: # (gen-title: Misc Pages)

[//]: # (gen-keywords: apps, tools, art, javascript, photography)

[//]: # (gen-description: Links to things on this website that are not blog posts or photo galleries.)

[//]: # (gen-meta-end)

## Apps, Tools, and Other Pages

Click the photos for a link and description.

For a more complete list of my projects, see my portfolio listing on this site's <a href="{SITE_ROOT_REL}/about/">About page</a>.

<style>
	.img-container {{
		padding-top: 1.0rem;
		padding-bottom: 1.0rem;
		border-top: 1px solid #949b96;
	}}
	details, details summary {{
		display: inline;
	}}
	details summary {{
		list-style: none;
	}}
	details img {{
		border-radius: 1.0rem;
		/* the site default padding-top for <image> makes the top rounded corners look wrong */
		/* to fix this, set padding to 0 and use margin-top instead */
		padding: 0;
		margin-top: 0.4rem;
	}}
	details > summary::-webkit-details-marker {{
		display: none;
	}}
	details[open] {{
		display: block;
		margin-left: auto;
		margin-right: auto;
		max-width: 100%;
		padding-top: 1.0rem;
		padding-bottom: 1.0rem;
		border-top: 1px solid #949b96;
		border-bottom: 1px solid #949b96;
	}}
	#loc {{
		word-wrap: break-word;
	}}
	.width-resp-50 {{
		padding-left: 1.25%;
		padding-right: 1.25%;
		max-width: 45%;
	}}
	@media screen and (min-width: 64rem) {{
		.width-resp-50 {{
			padding-left: 1.25%;
			padding-right: 1.25%;
			max-width: 30%;
		}}
	}}
	@media screen and (min-width: 104rem) {{
		.width-resp-50 {{
			padding-left: 1.2%;
			padding-right: 1.2%;
			max-width: 22%;
		}}
	}}
	.wide-override {{
		width: 100%
	}}
	@media screen and (min-width: 48rem) {{
		.wide-override {{
			width: 47rem;
			left: 50%;
			position: relative;
			transform: translateX(-50%);
		}}
	}}
	@media screen and (min-width: 54rem) {{
		.wide-override {{ width: 52rem; }}
	}}
	@media screen and (min-width: 64rem) {{
		.wide-override {{ width: 61rem; }}
	}}
	@media screen and (min-width: 74rem) {{
		.wide-override {{ width: 70rem; }}
	}}
	@media screen and (min-width: 84rem) {{
		.wide-override {{ width: 80rem; }}
	}}
	@media screen and (min-width: 94rem) {{
		.wide-override {{ width: 90rem; }}
	}}
	@media screen and (min-width: 104rem) {{
		.wide-override {{ width: 98rem; }}
	}}
	.btns {{
		margin: 1rem 0;
	}}
</style>
<div class="wide-override">
""")

def write_footer(*, buffer):
	buffer.write(f"""
</div>
""")
	pass

def write_item(*, item, year, buffer):
	global SITE_ROOT_REL

	# prepend site root rel path if url contains no slashes
	photo_url = item['photo']
	if '/' not in photo_url:
		photo_url = f'{SITE_ROOT_REL}/s/img/{year}/{photo_url}'

	title = item["title"]

	root_rel_url = f'{SITE_ROOT_REL}/{item["root_rel_url"]}'

	# include description if provided
	desc = ''
	if 'desc' in item:
		desc = f'<p>{item["desc"]}</p>'
		desc = desc.replace('SITE_ROOT_REL', SITE_ROOT_REL);

	buffer.write(f"""
<details class="width-resp-50">
	<summary>
		<img class="width-100" src="{photo_url}"/>
	</summary>
	<h2><a href="{root_rel_url}">{title}</a></h2>
	{desc}
	<p>First published in {year}.</p>
</details>""")

# string buffer into which to write the file contents
markdown_file = StringIO()

write_header(buffer=markdown_file)

for year,items in misc_items_by_year.items():
	for item in items:
		write_item(item=item, year=year, buffer=markdown_file)

write_footer(buffer=markdown_file)

# get the contents of the entire string buffer
markdown_contents = markdown_file.getvalue().encode('utf-8', 'ignore')

# read the markdown file already on disk for this year
if not overwrite_file_if_changed(
		file_path=misc_static_index_markdown,
		new_contents_bytes=markdown_contents):
	print(f'the misc gallery markdown page is unchanged')

# throw away the string buffer for this page
markdown_file.close()
