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

#if len(sys.argv) < 2:
#	print(f"usage: {sys.argv[0]} <SITE_ROOT_REL>", file=sys.stderr)
#	sys.exit(1)
#
#SITE_ROOT_REL=sys.argv[1]

photos_static_dir_path = Path(__file__).parent.joinpath("static").joinpath("photos")

# create the photos dir if absent
if not photos_static_dir_path.is_dir():
	photos_static_dir_path.mkdir(mode=0o755, parents=False, exist_ok=False)

# for each year, an ordered list of photos, where only the
#   "url" field below is required:
# url  - if no '/' character, assumed to be in 's/img/<year>/'
# date - displayed as-is if present, and inferred from image title if absent
# desc - displayed as-is (can include html)
photos_data = {
	2021: [
		{'url': '2021-09-03-070455-14-R6PT4168-biggerthumb-sm.jpg', 'desc': 'Depoe Bay, Oregon, USA' },
		{'url': '2021-09-03-071259-61-R6PT4238-biggerthumb-sm.jpg', 'desc': 'Depoe Bay, Oregon, USA' },
		{'url': '2021-09-03-071922-14-R6PT4280-biggerthumb-sm.jpg', 'desc': 'Depoe Bay, Oregon, USA' },
		{'url': '2021-09-04-195326-41-R6PT5310-v2-rotated-sm.jpg',  'desc': 'Lincoln City, Oregon, USA' },
		{'url': '2021-09-05-074101-00-R6PT5384-biggerthumb-sm.jpg', 'desc': 'Depoe Bay, Oregon, USA' },
		{'url': '2021-09-12-082830-14-R6PT5850-biggerthumb-sm.jpg', 'desc': 'Oregon, USA' },
	],
	2022: [
		{'url': '2022-04-14_landscape15x_all_wavelet-sm.jpg',          'desc': 'Oregon, USA', 'date': '2022-04-14' },
		{'url': '2022-05-15-154712-51-R6PT1291-sm.jpg',                'desc': 'Oregon, USA' },
		{'url': '2022-06-16-Odell-Lake-sm.jpg',                        'desc': 'Odell Lake<br/>Oregon, USA' },
		{'url': '2022-08-14-060656-37-R6PT7222-v2-biggerthumb-sm.jpg', 'desc': 'Sutton Lake<br/>Oregon, USA' },
		{'url': '2022-08-14-061926-50-R6PT7228-v2-biggerthumb-sm.jpg', 'desc': 'Heceta Head Lighthouse<br/>Oregon, USA' },
		{'url': '2022-08-18-194107-01-R6PT9248-sm.jpg',                'desc': 'Oregon, USA' },
		{'url': '2022-08-18-194135-02-R6PT9259-biggerthumb-sm.jpg',    'desc': 'Oregon, USA' },
		{'url': '2022-08-18-200142-27-R6PT9322-HDR-biggerthumb-sm.jpg','desc': 'Oregon, USA' },
		{'url': '2022-08-18-202600-34-R6PT9443-biggerthumb-sm.jpg',    'desc': 'Oregon, USA' },
		{'url': '2022-08-19-081028-97-R6PT9739-biggerthumb-sm.jpg',    'desc': 'Oregon, USA' },
		{'url': '2022-09-01-193511-19-R6PT0790-photoshop-biggerthumb-sm.jpg','desc': 'Bandon, Oregon, USA' },
		{'url': '2022-09-01-193748-67-R6PT0794-biggerthumb-sm.jpg',    'desc': 'Bandon, Oregon, USA' },
		{'url': '2022-09-01-194524-11-R6PT0796-HDR-biggerthumb-sm.jpg','desc': 'Bandon, Oregon, USA' },
		{'url': '2022-09-01-195003-67-R6PT0812-HDR-biggerthumb-sm.jpg','desc': 'Bandon, Oregon, USA' },
		{'url': '2022-11-08-095647-40-R6PT7654-sm.jpg',                'desc': 'Oregon, USA' },
		{'url': '2022-12-15-114021-17-R6PT1341-sm.jpg',                'desc': 'Oregon, USA' },
		{'url': '2022-12-15-114023-02-R6PT1342-sm.jpg',                'desc': 'Oregon, USA' },
	],
	2023: [
		{'url': '2023-03-22-191710-54-R6PT7797-Pano-crop-sm.jpg','desc': 'Seattle, Washington, USA' },
		{'url': '2023-03-22-191828-00-R6PT7808-2-sm.jpg',        'desc': 'Seattle, Washington, USA' },
		{'url': '2023-03-22-191957-27-R6PT7836-sm.jpg',          'desc': 'Seattle, Washington, USA' },
		{'url': '2023-03-22-192003-21-R6PT7838-Pano-sm.jpg',     'desc': 'Seattle, Washington, USA' },
		{'url': '2023-04-22-164653-06-R6PT1724-sm.jpg',          'desc': 'Oregon, USA' },
		{'url': '2023-05-10-172503-73-R6PT6650-sm.jpg',          'desc': 'Oregon, USA' },
		{'url': '2023-06-12-094707-06-R6PT0315-sm.jpg',          'desc': 'Oregon, USA' },
		{'url': '2023-06-12-094711-56-R6PT0319-sm.jpg',          'desc': 'Oregon, USA' },
		{'url': '2023-07-05-091332-36-R6PT3049-sm.jpg',          'desc': 'Oregon, USA' },
		{'url': '2023-07-30-193100-10-R6PT6136-sm.jpg',          'desc': 'Salt Creek Falls<br/>Oregon, USA' },
		{'url': '2023-07-30-200638-83-R6PT6140-sm.jpg',          'desc': 'Salt Creek Falls<br/>Oregon, USA' },
		{'url': '2023-08-13-075337-00-R6PT9523-sm.jpg',          'desc': 'Oregon, USA' },
		{'url': '2023-09-02-195351-71-R6PT0901-sm.jpg',          'desc': 'Port Orford, Oregon, USA' },
		{'url': '2023-09-02-195453-36-R6PT0936-sm.jpg',          'desc': 'Port Orford, Oregon, USA' },
		{'url': '2023-09-20-103049-33-R6PT1902-Photoshop-sm.jpg','desc': 'Oregon, USA' },
		{'url': '2023-11-08-095057-23-R6PT5181-sm.jpg',          'desc': 'Oregon, USA' },
		{'url': '2023-11-08-095111-76-R6PT5203-Pano-sm.jpg',     'desc': 'Oregon, USA' },
		{'url': '2023-11-13-085734-01-R6PT5484-sm.jpg',          'desc': 'Oregon, USA' },
		{'url': '2023-12-16-135607-02-R6PT7245-Photoshop-sm.jpg','desc': 'Oregon, USA' },
		{'url': '2023-12-22-123840-22-R6PT7677-Pano-sm.jpg',     'desc': 'Oregon, USA' }
	],
	2024: [
		{'url': '2024-01-29-143254-00-R6PT0436-Enhanced-NR-16x9-sm.jpg', 'desc': 'Oregon, USA' },
		{'url': '2024-02-18-173517-42-R6PT1363-Photoshop-sm.jpg',        'desc': 'Oregon, USA' },
		{'url': '2024-02-18-173456-60-R6PT1358-sm.jpg',                  'desc': 'Oregon, USA' },
		{'url': '2024-02-18-105324-56-R6PT1255-sm.jpg',                  'desc': 'Steller sea lion<br/>Oregon, USA' },
		{'url': '2024-02-18-105333-33-R6PT1264-sm.jpg',                  'desc': 'Steller sea lion<br/>Oregon, USA' },
		{'url': '2024-02-18-105333-84-R6PT1268-sm.jpg',                  'desc': 'Steller sea lion<br/>Oregon, USA' },
		{'url': '2024-03-15-Moon-Stacked-Blended.jpg',                   'desc': 'shot from Oregon, USA' },
		{'url': '2024-04-08-eclipse-stacked-topaz-composite-sm.jpg',     'desc': 'Total Solar Eclipse<br/>shot from New York, USA' },
		{'url': '2024-04-15-133443-21-R6PT4768-sm.jpg',                  'desc': 'Suksdorf’s Large Camas<br/>Oregon, USA' },
		{'url': '2024-05-28-092701-05-R6PT9324-Photoshop-16x9-sm.jpg',   'desc': 'Lazuli Bunting<br/>Oregon, USA' },
		{'url': '2024-05-29-094600-34-R6PT9716-sm.jpg',                  'desc': 'Townsend’s Chipmunk<br/>Oregon, USA' },
		{'url': '2024-05-21-102959-27-R6PT9030-sm.jpg',                  'desc': 'Southern Alligator Lizard<br/>Oregon, USA' },
		{'url': '2024-07-21-101135-21-R6PT3960-sm.jpg',                  'desc': 'White-winged Scoter<br/>Oregon, USA' },
		{'url': '2024-07-21-101155-47-R6PT3983-sm.jpg',                  'desc': 'White-winged Scoter<br/>Oregon, USA' },
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

# output redirect page that points to current year page, if it needs to be changed
last_year = max(list(photos_data.keys()))
print(f"{last_year=}")
index_html_redirect_contents = f"""
<html lang="en">
	<head>
		<meta http-equiv="refresh" content="0; url=./{last_year}.html">
	</head>
	<body></body>
</html>
"""
index_html_redirect_path = photos_static_dir_path.joinpath("index.html")

overwrite_file_if_changed(
	file_path=index_html_redirect_path,
	new_contents_bytes=index_html_redirect_contents.encode('utf-8', 'ignore'))

def write_header(*, year, prev_year, next_year, buffer):
	global SITE_ROOT_REL

	prev_btn = ''
	if prev_year is not None:
		prev_btn = f'<a class="btn" href="./{prev_year}.html">← {prev_year} Gallery</a>'

	next_btn = ''
	if next_year is not None:
		next_btn = f'<a class="btn" href="./{next_year}.html">{next_year} Gallery →</a>'

	galleries_btn = f'<a class="btn" href="{SITE_ROOT_REL}/photo-galleries.html">All Galleries</a>'

	buffer.write(f"""
<!-- this file is generated by generatePhotosGalleries.py -->

[//]: # (gen-title: {year} Photo Gallery)

[//]: # (gen-keywords: photography, gallery, landscape, art)

[//]: # (gen-description: Some of my favorite (non-bird) photos of {year})

[//]: # (gen-meta-end)

<div class="btns" style="margin:0 0 2rem 0">
{prev_btn}{galleries_btn}{next_btn}
</div>

## My Favorite (non-bird) Photos of {year}

Click the photos for a date and description.

All my photos, including these and my bird photos, are regularly published to my
gallery pages.  See the <a href="{SITE_ROOT_REL}/gallery/">latest gallery page</a>.

These photos are © {year} Phil Thompson, all rights reserved.

<style>
	details {{
		margin-bottom: 2.0rem;
	}}
	details summary {{
		list-style: none;
	}}
	details > summary::-webkit-details-marker {{
		display: none;
	}}
	details.wrap-wider-child {{
		text-align: center;
	}}
	details[open] {{
		background-color: rgba(0,0,0,0.1);
		padding: 0.7rem 0 0.7rem 0;
	}}
	details summary img {{
		border: 0.2rem solid white;
		padding: 0;
		margin: 0 0 0 -0.2rem;
	}}
	@media screen and (min-width: 32rem) {{
		details summary img {{
			border: 0.4rem solid white;
			padding: 0;
			margin: 0 0 0 -0.4rem;
		}}
	}}
	@media screen and (min-width: 63rem) {{
		details summary img {{
			border: 0.7rem solid white;
			padding: 0;
			margin: 0;
		}}
	}}
	<!-- thanks to https://stackoverflow.com/a/38215801/259456 for the animation idea -->
	details[open] {{
		animation: details-outer-sweep 1.5s ease-in-out;
	}}
	details[open] summary ~ * {{
		animation: details-inner-sweep 1.5s ease-in-out;
	}}
	@keyframes details-outer-sweep {{
		0% {{
			background-color: rgba(0,0,0,0.0);
			padding: inherit;
		}}
		100% {{
			background-color: rgba(0,0,0,0.1);
			padding: 1.0rem 0 1.0rem 0;
		}}
	}}
	@keyframes details-inner-sweep {{
		0% {{
			opacity: 0;
		}}
		100% {{
			opacity: 1;
		}}
	}}
</style>

""")

def write_footer(*, year, buffer):
	#buffer.write(f"<p>... thus was the year {year}</p>\n")
	pass

def write_photo(*, photo, year, buffer):
	global SITE_ROOT_REL

	# prepend site root rel path if url contains no slashes
	url = photo['url']
	if '/' not in url:
		url = f'{SITE_ROOT_REL}/s/img/{year}/{url}'

	# parse date from filename if not provided
	date = ''
	if 'date' in photo:
		date = photo['date']
	else:
		date_parts = photo['url'].split('-', maxsplit=3)
		if len(date_parts) < 4:
			print(f"photo for {year} with url [{photo['url']}] does not have the expected date format")
			date = 'date unknown'
		else:
			date = '-'.join(date_parts[0:3])
			# '2023-12-02' -> 'December 2, 2023'
	date = datetime.strptime(date, '%Y-%m-%d').strftime('%B %d, %Y').replace(' 0', ' ')

	# include description if provided
	desc = ''
	if 'desc' in photo:
		desc = f'<p>{photo["desc"]}</p>'

	buffer.write(f"""
<details class="wrap-wider-child">
	<summary>
		<img class="width-100" src="{url}"/>
	</summary>
	<p>{date}</p>
	{desc}
</details>""")

# populate prev/next years (create new list to iterate over)
prev_next = {}
adj_prev = None
for year in list(photos_data.keys()):
	prev_next[year] = {
		'next': None,
		'prev': adj_prev
	}
	if adj_prev is not None:
		prev_next[adj_prev]['next'] = year
	adj_prev = year

for year,photos in photos_data.items():
	year_file = StringIO()

	write_header(year=year, prev_year=prev_next[year]['prev'], next_year=prev_next[year]['next'], buffer=year_file)

	for photo in photos:
		write_photo(photo=photo, year=year, buffer=year_file)

	write_footer(year=year, buffer=year_file)

	# get the contents of the entire string buffer
	year_contents = year_file.getvalue().encode('utf-8', 'ignore')

	# read the markdown file already on disk for this year
	year_markdown_path = photos_static_dir_path.joinpath(f"{year}.md")

	if not overwrite_file_if_changed(
			file_path=year_markdown_path,
			new_contents_bytes=year_contents):
		print(f'the photos gallery markdown page for the year [{year}] is unchanged')

	# throw away the string buffer for this year page
	year_file.close()

