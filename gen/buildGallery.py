#
# sqlite3 module
# https://docs.python.org/3/library/sqlite3.html
#
# "hashes...supplement" file format
#   - line-based (multi-line single entries are not a thing)
#   - HTML is allowed
#   - all lines are optional
# <photo-name>:species:<species>
# <photo-name>:description:<description>
# <photo-name>:visible:<true|false>
# shoot:title:<title>
# shoot:description:<description>
# shoot:visible:<true|false>
# shoot:favorite:<photo-name>

#
# TODO
# - header should show Gallery
# - better gallery
#     - index page shows first/favorite image from each shoot, with title/date/desc 
#     - olderX.html is like index, but for prev pages
#     - shoot pages stay the same, except for "gallery home" button alongside prev/next
#

import base64
import re
import sqlite3
import subprocess

from datetime import datetime
from io import StringIO
from pathlib import Path

# string -> utf8 bytes -> b64 bytes -> utf8 string
def b64Encode(s):
	return base64.b64encode(s.encode("utf-8")).decode('utf-8')

def b64Decode(s):
	return base64.b64decode(s.encode('utf-8')).decode("utf-8")

def generateGalleryIndexPage(*, DEFAULT_GALLERY_URL):
	return f"""<!DOCTYPE html>
<html lang="en">
	<head>
		<meta http-equiv="refresh" content="0; url={DEFAULT_GALLERY_URL}">
	</head>
	<body></body>
</html>"""

def generateGalleryLatestInfo(*, GALLERY_PAGE_REL, SHOOT_FAVORITE, shoot_date_parsed):
	#SHOOT_DATE = SHOOT_ID.split('-', 1)[1]
	#shoot_date_parsed = datetime.strptime(SHOOT_DATE, '%Y-%m-%d-%H%M%S')
	SHOOT_DATE_FMT = shoot_date_parsed.strftime('%A %B %e, %Y').replace('  ', ' ')
	return f"{GALLERY_PAGE_REL.strip()}\n{SHOOT_FAVORITE.strip()}\n{SHOOT_DATE_FMT}\n"

def generateHashSigInfo(*, shoot_favorite_pattern, SHOOT_TITLE, SHOOT_FAVORITE, SHOOT_DESC, SHOOT_YEAR, HASHES_DIR_REL, HASHES_ID, SHOOT_ALGO_TXID, SITE_ROOT_REL, SHOOT_BCH_TXID, PREV_BUTTON, NEXT_BUTTON):

	if shoot_favorite_pattern.fullmatch(SHOOT_FAVORITE) is not None:
		SHOOT_FAVORITE = f'<a href="{SITE_ROOT_REL}/s/img/{SHOOT_FAVORITE}"><img style="float: left" class="width-resp-50-100" src="{SITE_ROOT_REL}/s/img/{SHOOT_FAVORITE}"/></a>'
	else:
		SHOOT_FAVORITE = ""

	# perhaps this is "better" than just assembling a long string with repeated += concatenation
	buffer = StringIO()

	# wow thanks to https://stackoverflow.com/a/15742338/259456 for pointing out that
	#   HTML now has <details> and <summary> tags with auto-collapse!
	buffer.write(f"""
<div class="btns" style="margin:0 0 2rem 0">
	{PREV_BUTTON}
	<a class="btn" href="{SITE_ROOT_REL}/photo-galleries.html">All Galleries</a>
	{NEXT_BUTTON}
</div>
<div class="">
	<span class="article-title">{SHOOT_TITLE}</span>
	{SHOOT_FAVORITE}
	{SHOOT_DESC}
	<p>These photos are © {SHOOT_YEAR} Phil Thompson, all rights reserved.</p>
	<p>My "birds in review" collages can be found <a href="{SITE_ROOT_REL}/birds/">here</a>.</p>
	<details>
		<summary>Signature</summary>
		<p><a target="_blank" href="{HASHES_DIR_REL}/{HASHES_ID}.txt">📄 {HASHES_ID}.txt</a></p>
		<p><a target="_blank" href="{HASHES_DIR_REL}/{HASHES_ID}.txt.sig">📄 {HASHES_ID}.txt.sig</a></p>""")

	if "SHOOT_ALGO_TXID" != "--":
		buffer.write(f"""
		<p>
			The above <code>hashes-&lt;date&gt;.txt</code> file contains SHA-256 hashes of all the photos
			from this shoot.  The <code>hashes-&lt;date&gt;.txt.sig</code> is a signature of that hashes
			file, created with <a href="{SITE_ROOT_REL}/about">my PGP key</a>.  The signature file
			itself was written to both the Bitcoin Cash and Algorand blockchains, in the
			<code>OP RETURN</code> and <code>Note</code> fields respectively, using the transactions below.
			In short, this proves that these photos and the signature both existed at the time the
			transactions were written to the Bitcoin Cash and Algorand blockchains.
			<a target="_blank" href="{SITE_ROOT_REL}/2021/Publishing-Permanent-Photo-Signatures-with-Blockchains.html">
			This blog post</a> has more details.
		</p>
		<p class="article-info"><a target="_blank" href="https://blockchair.com/bitcoin-cash/transaction/{SHOOT_BCH_TXID}">view the BCH tx on blockchair.com: {SHOOT_BCH_TXID}</a></p>
		<p class="article-info"><a target="_blank" href="https://explorer.perawallet.app/tx/{SHOOT_ALGO_TXID}/">view the ALGO tx on explorer.perawallet.app: {SHOOT_ALGO_TXID}</a></p>""")
	else:
		buffer.write(f"""
		<p>
			The above <code>hashes-&lt;date&gt;.txt</code> file contains SHA-256 hashes of all the photos
			from this shoot.  The <code>hashes-&lt;date&gt;.txt.sig</code> is a signature of that hashes
			file, created with <a href="{SITE_ROOT_REL}/about">my PGP key</a>.  The signature file
			itself was written to the Bitcoin Cash blockchain, in the <code>OP RETURN</code> field,
			using the transaction below. In short, this proves that these photos and the signature both
			existed at the time the transaction was written to the Bitcoin Cash blockchain.
			<a target="_blank" href="{SITE_ROOT_REL}/2021/Publishing-Permanent-Photo-Signatures-with-Blockchains.html">
			This blog post</a> has more details.
		</p>
		<p class="article-info"><a target="_blank" href="https://blockchair.com/bitcoin-cash/transaction/{SHOOT_BCH_TXID}">view the BCH tx on blockchair.com: {SHOOT_BCH_TXID}</a></p>""")

	buffer.write(f"""
	</details>
	<p style="clear:both;"></p>
</div>""")
	# <p class="article-info"><a target="_blank" href="https://www.blockchain.com/bch/tx/${SHOOT_TXID}">view on blockchain.com: ${SHOOT_TXID}</a></p>
	# <p class="article-info"><a target="_blank" href="https://explorer.bitcoin.com/bch/tx/${SHOOT_TXID}">view on bitcoin.com: ${SHOOT_TXID}</a></p>

	return buffer.getvalue()

# replace most plain spaces in pre-formatted dates with
#   '&nbsp;' (non-breaking spaces)
# the regex below matches dates written by exiftool in this format:
#   '8:43AM Tuesday May 03, 2022'
# "SELECT path_rel, local_datetime_lex, local_datetime_disp, species_b64, description_b64, visible FROM photos ORDER BY local_datetime_lex ASC;"
def generatePhotoDiv(*, photo_date_pattern, LINE, SITE_ROOT_REL):
	#echo "${HASHES_ID} photo: ${LINE}"
	#line_split = LINE.split('|')
	PHOTO_PATH = LINE[0]
	PHOTO_DATE = LINE[2].removeprefix('0')

	# replace most plain spaces in pre-formatted dates with
	#   '&nbsp;' (non-breaking spaces)
	# the regex below matches dates written by exiftool in this format:
	#   '8:43AM Tuesday May 03, 2022'
	if photo_date_pattern.fullmatch(PHOTO_DATE) is not None:
		# replace all spaces with &nbsp; then replace the 2nd &nbsp; with a space again
		# this makes the final result of
		#  '8:43AM&nbsp;Tuesday May&nbsp;03,&nbsp;2022'
		# (where the line break can only happen between the day of the
		# week and the month name, not anywhere else)
		photo_date_split = PHOTO_DATE.split(' ')
		photo_date_split[1] = photo_date_split[1] + ' ' + photo_date_split[2] # keep the 2nd space by merging items at index 1 and 2
		del photo_date_split[2]
		PHOTO_DATE = '&nbsp;'.join(photo_date_split)

	PHOTO_SPECIES = b64Decode(LINE[3])
	PHOTO_DESC = b64Decode(LINE[4]).strip()
	PHOTO_VISIBLE = LINE[5] # not base64 encoded in the db

	if PHOTO_VISIBLE != "true":
		#echo "photo ${PHOTO_PATH} of shoot ${HASHES_ID} is not visible, so skipping"
		return ""

	if PHOTO_DESC != "" and PHOTO_DESC != "--":
		PHOTO_DESC = f"\n	<p>{PHOTO_DESC}</p>"
	else:
		PHOTO_DESC = ""

	return "" +\
f"""<div class="wrap-wider-child container top-border">
	<p>
		<a href="{SITE_ROOT_REL}/s/img/{PHOTO_PATH}">
			<img style="float: left" class="width-resp-75-100" src="{SITE_ROOT_REL}/s/img/{PHOTO_PATH}"/>
		</a>
	</p>
	<p class="article-info">{PHOTO_DATE}</p>
	<b>{PHOTO_SPECIES}</b>{PHOTO_DESC}
	<p style="clear:both;"></p>
</div>"""


def buildGalleryRssItem(*, shoot_favorite_pattern, SHOOT_ID, GALLERY_PAGE_FILENAME, SHOOT_TITLE, SHOOT_DESC, SHOOT_FAVORITE, SITE_HOME_URL):

	# since the shoots have IDs like:
	#   hashes-YYYY-MM-DD-HHMMSS
	# we can format according to https://www.w3.org/Protocols/rfc822/#z28
	SHOOT_DATE = SHOOT_ID.split('-', 1)[1]
	shoot_date_parsed = datetime.strptime(SHOOT_DATE, '%Y-%m-%d-%H%M%S')
	SHOOT_DATE_RSS = shoot_date_parsed.astimezone().strftime('%a, %d %b %Y %H:%M:%S %z')

	ABSOLUTE_GALLERY_URL = f"{SITE_HOME_URL}/gallery/{GALLERY_PAGE_FILENAME}"

	SHOOT_DESC = f'{SHOOT_DESC}<br/><a href="{ABSOLUTE_GALLERY_URL}">See this gallery at philthompson.me</a>.'

	if shoot_favorite_pattern.fullmatch(SHOOT_FAVORITE) is not None:
		SHOOT_DESC = f'<a href="{ABSOLUTE_GALLERY_URL}"><img style="float: left" class="width-resp-75-100" src="{SITE_HOME_URL}/s/img/{SHOOT_FAVORITE}"/></a><br/>{SHOOT_DESC}'

	return f"""  <item>
    <title>{SHOOT_TITLE.strip()}</title>
    <link>{ABSOLUTE_GALLERY_URL.strip()}</link>
    <pubDate>{SHOOT_DATE_RSS}</pubDate>
    <description><![CDATA[{SHOOT_DESC}]]></description>
    <category>gallery</category>
    <guid>{ABSOLUTE_GALLERY_URL}</guid>
  </item>\n"""

def findGalleryHashesFiles(*, GALLERY_IMG_DIR):
	#HASHES_FILES_SORTED="`find "${GALLERY_IMG}" -type f -name "hashes-*.txt" | sort`"
	for walk_dirname, _, walk_filenames in GALLERY_IMG_DIR.walk():
		for walk_filename in walk_filenames:
			# temporary restrict to only 2025 galleries
			#if not walk_filename.startswith("hashes-2025-") or not walk_filename.endswith(".txt"):
			if not walk_filename.startswith("hashes-") or not walk_filename.endswith(".txt"):
				continue
			yield walk_dirname.joinpath(walk_filename)

# recursion is not needed!
#def findFile(*, start_dir, filename):
#	for walk_dirname, walk_dirnames, walk_filenames in start_dir.walk():
#		for walk_filename in walk_filenames:
#			if walk_filename == filename:
#				return walk_dirname.joinpath(walk_filename)
#		for walk_inner_dir in walk_dirnames:
#			inner_result = findFile(start_dir=walk_inner_dir, filename=filename)
#			if inner_result is not None:
#				return inner_result
#	return None
def findFile(*, start_dir, filename):
	for walk_dirname, _, walk_filenames in start_dir.walk():
		for walk_filename in walk_filenames:
			if walk_filename == filename:
				return walk_dirname.joinpath(walk_filename)
	return None

def executeCmd(cmd_and_args):
	try:
		result = subprocess.run(cmd_and_args, capture_output=True, text=True, check=True)
		return result.stdout
	except subprocess.CalledProcessError as e:
		print(f"got returncode [{e.returncode}] for [{e.cmd}]:\nstdout:\n{e.stdout}\nstderr:\n{e.stderr}")
		return None
#print(result.returncode)

def populateHashesDb(*, curs, HASHES_FILE, HASHES_SUPP, HASHES_ID, HASHES_YEAR, \
		HASHES_BCH_TXID_OLD, HASHES_BCH_TXID, HASHES_ALGO_TXID, readFileFn):
	#global BIRD_PHOTOS_DIR
	#global OTHER_PHOTOS_DIR
	#global ASTRO_PHOTOS_DIR
	BIRD_PHOTOS_DIR = Path.home().joinpath('Pictures').joinpath('Birds')
	OTHER_PHOTOS_DIR = Path.home().joinpath('Pictures').joinpath('Other')
	ASTRO_PHOTOS_DIR = Path.home().joinpath('Pictures').joinpath('Astro')

	# photos table columns:
	# - local_datetime_lex (text) (ascii sortable)
	# - local_datetime_disp (text)
	# - species (text)
	# - description (text)
	# shoot table columns:
	# - title (text)
	# - description (text)
	# - bch_txid (text)
	curs.execute("CREATE TABLE photos (path_rel TEXT PRIMARY KEY, local_datetime_lex TEXT, local_datetime_disp TEXT, species_b64 TEXT, description_b64 TEXT, visible TEXT)")
	curs.execute("CREATE TABLE shoot (title_b64 TEXT, description_b64 TEXT, bch_txid_b64 TEXT, algo_txid_b64 TEXT, favorite_path_rel TEXT, default_favorite_path_rel TEXT, visible TEXT)")

	SHOOT_DEFAULT_FAVORITE = b64Encode("--")
	SHOOT_DEFAULT_FAVORITE_STARS = 0

	# find "-sm." images listed in the file
	for LINE in [x for x in readFileFn(HASHES_FILE).splitlines() if '-sm.' in x]:

		PHOTO_FILENAME = LINE.split(':')[0]
		PHOTO_YEAR = PHOTO_FILENAME.split('-')[0]
		PHOTO_MONTH = PHOTO_FILENAME.split('-')[1]
		# this requires a local (on the system this script is running on) copy
		#   of all bird gallery -sm.jpg pictures, which i of course have but
		#   this means the git repo is not self-contained with respect to
		#   these pictures anymore, which is kind of the point anyway of
		#   removing bird gallery pics from the git repo
		PHOTO_PATH = BIRD_PHOTOS_DIR.joinpath(PHOTO_YEAR).joinpath(PHOTO_MONTH).joinpath(PHOTO_FILENAME)
		# some photos are not of birds, but i'd like to publish their signature and
		#   thumbnail pics anyway, so look in "Other" photos folder
		if not PHOTO_PATH.exists():
			PHOTO_PATH = OTHER_PHOTOS_DIR.joinpath(PHOTO_YEAR).joinpath(PHOTO_MONTH).joinpath(PHOTO_FILENAME)
			if not PHOTO_PATH.exists():
				PHOTO_PATH = ASTRO_PHOTOS_DIR.joinpath(PHOTO_YEAR).joinpath(PHOTO_MONTH).joinpath(PHOTO_FILENAME)
				if not PHOTO_PATH.exists():
					PHOTO_PATH = findFile(start_dir=BIRD_PHOTOS_DIR, filename=PHOTO_FILENAME)
					if PHOTO_PATH is None:
						PHOTO_PATH = findFile(start_dir=OTHER_PHOTOS_DIR, filename=PHOTO_FILENAME)
						if PHOTO_PATH is None:
							PHOTO_PATH = findFile(start_dir=ASTRO_PHOTOS_DIR, filename=PHOTO_FILENAME)
		
		if PHOTO_PATH is None or not PHOTO_PATH.exists():
			print(f"could not find photo [{PHOTO_FILENAME}] in [{HASHES_FILE}]")
			continue

		# this path is relative to the new on-webserver static images path
		PHOTO_PATH_REL = f"{HASHES_YEAR}/{PHOTO_FILENAME}"
		PHOTO_DATETIME_LEX = executeCmd(['/opt/homebrew/bin/exiftool', '-d', '%Y-%m-%d-%H%M%S', '-DateTimeOriginal', '-S', '-s', PHOTO_PATH])
		if PHOTO_DATETIME_LEX is None:
			continue
		PHOTO_DATETIME_LEX = PHOTO_DATETIME_LEX.strip()
		photo_datetime_parsed = datetime.strptime(PHOTO_DATETIME_LEX, '%Y-%m-%d-%H%M%S')
		#PHOTO_DATETIME_DISP="`/opt/homebrew/bin/exiftool -d '%I:%M%p %A %B %d, %Y' -DateTimeOriginal -S -s "${PHOTO_PATH}"`"
		#PHOTO_DATETIME_DISP = executeCmd(['/opt/homebrew/bin/exiftool', '-d', '%I:%M%p&nbsp;%A %B&nbsp;%d,&nbsp;%Y',  '-DateTimeOriginal', '-S', '-s', PHOTO_PATH])
		#if PHOTO_DATETIME_DISP is None:
		#	continue
		#PHOTO_DATETIME_DISP = PHOTO_DATETIME_DISP.strip()
		PHOTO_DATETIME_DISP = photo_datetime_parsed.strftime('%I:%M%p&nbsp;%A %B&nbsp;%d,&nbsp;%Y')

		# i lowercased all species names, so now i have to re-capialize them here...
		# thanks to https://stackoverflow.com/a/1541178/259456 for the awk script that
		#   properly capitalizes things at word boundaries
		# NEVERMIND capitalization isn't apparently uniform for hyphenated words when
		#   it comes to bird species, so i'm going to leave capitalization of "species:"
		#   keywords unchanged -- i'll have to capitalize them properly when initially
		#   tagging them
		#PHOTO_SPECIES="`/opt/homebrew/bin/exiftool "-MWG:Keywords" -S -s "${PHOTO_PATH}" | sed 's/, /@/g' | tr '@' '\n' | grep species | sed 's/species://g' | tr 'A-Z' 'a-z' | awk '{for(i=1;i<=NF;i++){ $i=toupper(substr($i,1,1)) substr($i,2) }}1' | tr '\n' ',' | sed -e 's/,/, /g' -e 's/, $//' | base64`"
		#PHOTO_SPECIES="`/opt/homebrew/bin/exiftool "-MWG:Keywords" -S -s "${PHOTO_PATH}" | sed 's/, /@/g' | tr '@' '\n' | grep 'species:' | sed 's/species://g' | tr '\n' ',' | sed -e 's/,/, /g' -e 's/, $//' | base64`"
		PHOTO_KEYWORDS = executeCmd(['/opt/homebrew/bin/exiftool', "-MWG:Keywords", '-S', '-s', PHOTO_PATH])
		if PHOTO_KEYWORDS is None:
			continue
		photo_species_split = [x[8:] for x in PHOTO_KEYWORDS.strip().split(', ') if x.startswith('species:')]
		PHOTO_SPECIES = b64Encode(', '.join(photo_species_split))

		PHOTO_DESCRIPTION = b64Encode("--")
		PHOTO_VISIBLE = "true"
		#PHOTO_STARS="`/opt/homebrew/bin/exiftool "-MWG:Keywords" -S -s "${PHOTO_PATH}" | sed 's/, /@/g' | tr '@' '\n' | grep -m 1 "stars:[0-9]" | sed -E 's/.*stars:([0-9]).*/\1/'`"
		PHOTO_STARS = [x[6:] for x in PHOTO_KEYWORDS.strip().split(', ') if x.startswith('stars:')]
		PHOTO_STARS = '1' if len(PHOTO_STARS) == 0 else PHOTO_STARS[0]

		if int(PHOTO_STARS) > SHOOT_DEFAULT_FAVORITE_STARS:
			SHOOT_DEFAULT_FAVORITE_STARS = int(PHOTO_STARS)
			SHOOT_DEFAULT_FAVORITE = b64Encode(PHOTO_PATH_REL)

		# if the hashes file supplement exists, replace any photo data with anything
		#   found in that file
		# this allows the supplement file to override anything read from the photos
		#   themselves (like corrections, or additional description, etc)
		if HASHES_SUPP.is_file():
			supp_lines = readFileFn(HASHES_SUPP).splitlines()
			SUPP_SPECIES       = [x for x in supp_lines if x.startswith(f"{PHOTO_FILENAME}:species:")]
			SUPP_DESCRIPTION   = [x for x in supp_lines if x.startswith(f"{PHOTO_FILENAME}:description:")]
			SUPP_VISIBLE       = [x for x in supp_lines if x.startswith(f"{PHOTO_FILENAME}:visible:")]
			SUPP_DATETIME_DISP = [x for x in supp_lines if x.startswith(f"{PHOTO_FILENAME}:datetimedisp:")]
			if len(SUPP_SPECIES) > 0:
				PHOTO_SPECIES = b64Encode(SUPP_SPECIES[0].split(':', 2)[-1])
			if len(SUPP_DESCRIPTION) > 0:
				PHOTO_DESCRIPTION = b64Encode(SUPP_DESCRIPTION[0].split(':', 2)[-1])
			if len(SUPP_VISIBLE) > 0:
				PHOTO_VISIBLE = SUPP_VISIBLE[0].split(':', 2)[-1].lower()
				if PHOTO_VISIBLE not in ['true', 'false']:
					print(f"supplement file :visible: item for photo [{PHOTO_FILENAME}] in [{HASHES_SUPP}] is not an expected value of 'true' or 'false'")
					PHOTO_VISIBLE = 'true'
			if len(SUPP_DATETIME_DISP) > 0:
				PHOTO_DATETIME_DISP = SUPP_DATETIME_DISP[0].split(':', 2)[-1]

		else:
			print(f"supplement file [{HASHES_SUPP}] does NOT exist")

		#echo ""
		#echo "INSERT INTO photos(path_rel, local_datetime_lex, local_datetime_disp, species_b64, description_b64) VALUES ('${PHOTO_PATH_REL}', '${PHOTO_DATETIME_LEX}', '${PHOTO_DATETIME_DISP}', '${PHOTO_SPECIES}', '${PHOTO_DESCRIPTION}');"
		#sqlite3 "${HASHES_DB}" "INSERT INTO photos(path_rel, local_datetime_lex, local_datetime_disp, species_b64, description_b64, visible) VALUES ('${PHOTO_PATH_REL}', '${PHOTO_DATETIME_LEX}', '${PHOTO_DATETIME_DISP}', '${PHOTO_SPECIES}', '${PHOTO_DESCRIPTION}', '${PHOTO_VISIBLE}');"
		curs.execute("""
			INSERT INTO
				photos(path_rel, local_datetime_lex, local_datetime_disp, species_b64, description_b64, visible)
			VALUES
				(?, ?, ?, ?, ?, ?)
		""", [PHOTO_PATH_REL, PHOTO_DATETIME_LEX, PHOTO_DATETIME_DISP, PHOTO_SPECIES, PHOTO_DESCRIPTION, PHOTO_VISIBLE])

	SHOOT_TITLE = b64Encode("Shoot " + HASHES_ID.split('-', 1)[1])
	SHOOT_DESCRIPTION = b64Encode('--')
	SHOOT_BCH_TXID = b64Encode('--')
	SHOOT_ALGO_TXID = b64Encode('--')
	SHOOT_VISIBLE = "true"
	SHOOT_FAVORITE = b64Encode('--')

	# read and use BCH txid file, if present
	if HASHES_BCH_TXID.is_file():
		SHOOT_BCH_TXID = b64Encode(readFileFn(HASHES_BCH_TXID).splitlines()[0])
	elif HASHES_BCH_TXID_OLD.is_file():
		SHOOT_BCH_TXID = b64Encode(readFileFn(HASHES_BCH_TXID_OLD).splitlines()[0])
	# read and use ALGO txid file, if present
	if HASHES_ALGO_TXID.is_file():
		SHOOT_ALGO_TXID = b64Encode(readFileFn(HASHES_ALGO_TXID).splitlines()[0])

	if HASHES_SUPP.is_file():
		supp_lines = readFileFn(HASHES_SUPP).splitlines()
		SUPP_TITLE       = [x for x in supp_lines if x.startswith("shoot:title:")]
		SUPP_DESCRIPTION = [x for x in supp_lines if x.startswith("shoot:description:")]
		SUPP_VISIBLE     = [x for x in supp_lines if x.startswith("shoot:visible:")]
		SUPP_FAVORITE    = [x for x in supp_lines if x.startswith("shoot:favorite:")]
		if len(SUPP_TITLE) > 0:
			SHOOT_TITLE = b64Encode(SUPP_TITLE[0].split(':', 2)[-1])
		if len(SUPP_DESCRIPTION) > 0:
			SHOOT_DESCRIPTION = b64Encode(SUPP_DESCRIPTION[0].split(':', 2)[-1])
		if len(SUPP_VISIBLE) > 0:
			SHOOT_VISIBLE = SUPP_VISIBLE[0].split(':', 2)[-1].lower()
			if SHOOT_VISIBLE not in ['true', 'false']:
				print(f"supplement file shoot:visible: item in [{HASHES_SUPP}] is not an expected value of 'true' or 'false'")
				SHOOT_VISIBLE = 'true'
		if len(SUPP_FAVORITE) > 0:
			SHOOT_FAVORITE = b64Encode(SUPP_FAVORITE[0].split(':', 2)[-1])

	#sqlite3 "${HASHES_DB}" "INSERT INTO shoot (title_b64, description_b64, bch_txid_b64, algo_txid_b64, favorite_path_rel, default_favorite_path_rel, visible) VALUES ('${SHOOT_TITLE}', '${SHOOT_DESCRIPTION}', '${SHOOT_BCH_TXID}', '${SHOOT_ALGO_TXID}', '${SHOOT_FAVORITE}', '${SHOOT_DEFAULT_FAVORITE}', '${SHOOT_VISIBLE}');"
	curs.execute("""
		INSERT INTO
			shoot (title_b64, description_b64, bch_txid_b64, algo_txid_b64, favorite_path_rel, default_favorite_path_rel, visible)
		VALUES
			(?, ?, ?, ?, ?, ?, ?)
	""", [SHOOT_TITLE, SHOOT_DESCRIPTION, SHOOT_BCH_TXID, SHOOT_ALGO_TXID, SHOOT_FAVORITE, SHOOT_DEFAULT_FAVORITE, SHOOT_VISIBLE])


def buildGalleryPages(*, STATIC_DIR, OUT_DIR, header_fn, footer_fn, SITE_ROOT_REL, SITE_HOME_URL, GALLERY_LATEST_FILE, readFileFn, writeIfChangedFn):

	GALLERY_OUT = OUT_DIR.joinpath('gallery')
	GALLERY_OUT.mkdir(parents=True, exist_ok=True)

	GALLERY_REL = SITE_ROOT_REL + '/gallery'
	GALLERY_REL_NOT_INTERPRETED = "SITE_ROOT_REL/gallery"
	STATIC_IMAGES_DIR_NOT_INTERPRETED = "SITE_ROOT_REL/s/img"

	GALLERY_IMG = STATIC_DIR.joinpath("gallery-img")

	HASHES_FILES_SORTED = sorted(findGalleryHashesFiles(GALLERY_IMG_DIR=GALLERY_IMG))
	HASHES_FILES_LAST_TEN = HASHES_FILES_SORTED[-10:]

	GALLERY_INDEX_PAGE = GALLERY_OUT.joinpath("index.html")
	GALLERY_INDEX_CONTENT = "unknown"
	GALLERY_LATEST_CONTENT = "unknown"
	RSS_ITEMS_BY_TIMESTAMP = {}

	hashes_filename_pattern = re.compile(r"^hashes-2[0-9]{3}-[0-9]{2}-[0-9]{2}-[0-9]{6}$")
	photo_date_pattern = re.compile(r"^[0-9]{1,2}:[0-9]{2}[AP]M\ [A-Za-z]{6,9}\ [A-Za-z]{3,9}\ [0-9]{1,2},\ 2[0-9]{3}$")

	# the first (most recent) hashes file generates a redirect for the gallery/index.html page
	for i in range(0, len(HASHES_FILES_SORTED)):
		HASHES_FILE = HASHES_FILES_SORTED[i]

		HASHES_DIR = HASHES_FILE.parent
		HASHES_ID = HASHES_FILE.stem
		HASHES_DB = HASHES_FILE.with_suffix(".db")
		HASHES_BCH_TXID_OLD = HASHES_FILE.with_suffix(".txid")
		HASHES_BCH_TXID = HASHES_FILE.with_name(HASHES_FILE.stem + "-BCH").with_suffix(".txid")
		HASHES_ALGO_TXID = HASHES_FILE.with_name(HASHES_FILE.stem + "-ALGO").with_suffix(".txid")
		HASHES_DIR_REL = f"{SITE_ROOT_REL}/gallery-img/{HASHES_DIR.name}"
		HASHES_SUPP = HASHES_FILE.with_suffix(".supplement")

		HASHES_YEAR="0123"

		if hashes_filename_pattern.fullmatch(HASHES_FILE.stem) is None:
			print(f"invalid hashes file [${HASHES_FILE}]: hashes filename format is expected to be \"hashes-YYYY-MM-DD-HHmmss\"")
			continue
		else:
			HASHES_YEAR = HASHES_FILE.name.split('-')[1]

		# build the db file for this file of photo hashes
		# (if db schema changes, simply delete all .db files and they will be
		#   rebuilt on the next run of build.sh)
		#
		# things DB can contain:
		# - dateoriginal of each photo
		#   - UTC epoch seconds (can webpage convert UTC to local time?)
		#   - maybe it would be better to use String date, in local timezone where
		#       photo was taken...
		# - species of each photo
		# - description for each photo
		#   - parsed from hand-written, optional, file
		# - overall description for this set of photos
		#   - parsed from hand-written, optional, file
		# - title for this set of photos
		#   - parsed from hand-written, optional, file
		# - BCH TXID that contains the signature of the hashes file in "OP RETURN" tx field
		#   - from hashes...-BCH.txid or hashes...txid (old)
		# - ALGO TXID that contains the signature of the hashes file in "Note" tx field
		#   - from hashes...-ALGO.txid
		if not HASHES_DB.exists():
			with sqlite3.connect(HASHES_DB) as conn:
				curs = conn.cursor()
				populateHashesDb(curs=curs, HASHES_FILE=HASHES_FILE, HASHES_SUPP=HASHES_SUPP, \
					HASHES_ID=HASHES_ID, HASHES_YEAR=HASHES_YEAR, \
					HASHES_BCH_TXID_OLD=HASHES_BCH_TXID_OLD, HASHES_BCH_TXID=HASHES_BCH_TXID, HASHES_ALGO_TXID=HASHES_ALGO_TXID, \
					readFileFn=readFileFn)
				conn.commit() # commit any outstanding INSERT statements

		# find the previous/next pages
		# these are NOT in the database for this hashes file because we may
		#   add a new hashes file between two existing ones, so we have
		#   to always check all hashes files for prev/next
		NEXT_BUTTON=""
		if i < len(HASHES_FILES_SORTED) - 1:
			# 'hashes-2025-10-31-114604.txt' -> 'gallery-2025-10-31-114604.html'
			NEXT_HASHES_TS = HASHES_FILES_SORTED[i+1].stem.split('-', 1)[-1]
			NEXT_BUTTON = f"<a class='btn' href='{SITE_ROOT_REL}/gallery/gallery-{NEXT_HASHES_TS}.html'>Newer Gallery</a>"

		PREV_BUTTON=""
		if i > 0:
			PREV_HASHES_TS = HASHES_FILES_SORTED[i-1].stem.split('-', 1)[-1]
			PREV_BUTTON = f"<a class='btn' href='{SITE_ROOT_REL}/gallery/gallery-{PREV_HASHES_TS}.html'>Older Gallery</a>"

		# build the page for this hashes file
		# - put page title/description/date at the top
		# - put txid at the top
		# - put links at top to previous gallery page and next page
		# - put links to download/view the hashes...txt and hashes...txt.sig files
		# - put helper text with link to about? page saying the .txt file was
		#     signed by me with such-and-such gpg key
		# - put little link to blog post (TBD) explaining the txid thing
		# - output photos in date order, earlier-to-later
		# - put links at bottom, too, for previous gallery page and next page
		#
		GALLERY_PAGE_FILENAME = f"gallery-{HASHES_ID.split('-', 1)[-1]}.html"

		#GALLERY_PAGE_COUNT=`ls -1 "${GALLERY_OUT}" | wc -l | tr -d '[:blank:]'`
		#GALLERY_PAGE="${GALLERY_OUT}/older${GALLERY_PAGE_COUNT}.html"
		#GALLERY_PAGE_COUNT=$(($GALLERY_PAGE_COUNT + 1))
		#PAGE_TITLE="Gallery ${GALLERY_PAGE_COUNT}"
		GALLERY_PAGE = GALLERY_OUT.joinpath(GALLERY_PAGE_FILENAME)

		GALLERY_INDEX_CONTENT = generateGalleryIndexPage(DEFAULT_GALLERY_URL=f"{GALLERY_REL}/{GALLERY_PAGE_FILENAME}")

		SHOOT_DATA = None
		PHOTOS_ROWS = None
		with sqlite3.connect(HASHES_DB) as conn:
			curs = conn.cursor()
			for row in curs.execute("SELECT title_b64, description_b64, bch_txid_b64, algo_txid_b64, favorite_path_rel, default_favorite_path_rel, visible FROM shoot LIMIT 1;"):
				SHOOT_DATA = row
				break # did a LIMIT 1, but might as well break here too

			# hopefully it works to just use list() to grab all rows
			PHOTOS_ROWS = list(curs.execute("SELECT path_rel, local_datetime_lex, local_datetime_disp, species_b64, description_b64, visible FROM photos ORDER BY local_datetime_lex ASC;"))

		SHOOT_TITLE = b64Decode(SHOOT_DATA[0]).strip()
		SHOOT_DESC = b64Decode(SHOOT_DATA[1]).strip()
		SHOOT_BCH_TXID = b64Decode(SHOOT_DATA[2]).strip()
		SHOOT_ALGO_TXID = b64Decode(SHOOT_DATA[3]).strip()
		SHOOT_FAVORITE = b64Decode(SHOOT_DATA[4]).strip()
		SHOOT_DEFAULT_FAVORITE = b64Decode(SHOOT_DATA[5]).strip()
		SHOOT_VISIBLE = SHOOT_DATA[6].strip()

		if SHOOT_VISIBLE != "true":
			print(f"shoot {HASHES_ID} is not visible ({SHOOT_VISIBLE}), so skipping")
			continue

		if len(SHOOT_DESC.strip()) > 0 and SHOOT_DESC != "--":
			SHOOT_DESC = f"<p>{SHOOT_DESC.strip()}</p>"
		else:
			SHOOT_DESC = ""

		if len(SHOOT_FAVORITE.strip()) == 0 or SHOOT_FAVORITE == "--":
			SHOOT_FAVORITE = SHOOT_DEFAULT_FAVORITE

		SHOOT_YEAR = HASHES_ID.split('-')[1]
		SHOOT_DATE = HASHES_ID.split('-', 1)[1]
		shoot_date_parsed = datetime.strptime(SHOOT_DATE, '%Y-%m-%d-%H%M%S')
		SHOOT_DATE_FMT_MONTH_YEAR = shoot_date_parsed.strftime('%B %Y')

		GALLERY_PAGE_CONTENT_BUF = StringIO()

		GALLERY_PAGE_CONTENT_BUF.write(header_fn(page_title=SHOOT_TITLE, SITE_ROOT_REL=SITE_ROOT_REL, meta_keywords="bird, photo, gallery, photography", meta_description=f"Photo gallery published in {SHOOT_DATE_FMT_MONTH_YEAR} — philthompson.me", meta_revisit_after_days=14))

		shoot_favorite_pattern = re.compile(r"^.*2[0-9]{3}-[0-9]{2}-[0-9]{2}-.*\.[jJ][pP][gG]$")

		GALLERY_PAGE_CONTENT_BUF.write("\n")
		GALLERY_PAGE_CONTENT_BUF.write(generateHashSigInfo( \
			shoot_favorite_pattern=shoot_favorite_pattern, \
			SHOOT_TITLE=SHOOT_TITLE, \
			SHOOT_FAVORITE=SHOOT_FAVORITE, \
			SHOOT_DESC=SHOOT_DESC, \
			SHOOT_YEAR=SHOOT_YEAR, \
			HASHES_DIR_REL=HASHES_DIR_REL, \
			HASHES_ID=HASHES_ID, \
			SHOOT_ALGO_TXID=SHOOT_ALGO_TXID, \
			SITE_ROOT_REL=SITE_ROOT_REL, \
			SHOOT_BCH_TXID=SHOOT_BCH_TXID, \
			PREV_BUTTON=PREV_BUTTON, \
			NEXT_BUTTON=NEXT_BUTTON))

		# thanks to https://stackoverflow.com/a/51863033/259456 for row_number
		#sqlite3 "${HASHES_DB}" "SELECT ROW_NUMBER() OVER(ORDER BY local_datetime_lex) AS rnum, path_rel, local_datetime_lex, local_datetime_disp, species_b64, description_b64 FROM photos ORDER BY local_datetime_lex DESC;" | while read LINE
		#sqlite3 "${HASHES_DB}" "SELECT path_rel, local_datetime_lex, local_datetime_disp, species_b64, description_b64, visible FROM photos ORDER BY local_datetime_lex ASC;" | while read LINE
		for PHOTO_ROW in PHOTOS_ROWS:
			GALLERY_PAGE_CONTENT_BUF.write("\n")
			GALLERY_PAGE_CONTENT_BUF.write(generatePhotoDiv(photo_date_pattern=photo_date_pattern, LINE=PHOTO_ROW, SITE_ROOT_REL=SITE_ROOT_REL))

		# embed newlines directly into variables
		GALLERY_PAGE_CONTENT_BUF.write(f"""
			<footer>
				<div class="btns" style="margin:0">
					{PREV_BUTTON}
					<a class="btn" href="{SITE_ROOT_REL}/photo-galleries.html">All Galleries</a>
					{NEXT_BUTTON}
				</div>""")

		GALLERY_PAGE_CONTENT_BUF.write(footer_fn(SITE_ROOT_REL=SITE_ROOT_REL))

		# replace page path into page content
		PAGE_PATH_FROM_ROOT = GALLERY_PAGE.relative_to(OUT_DIR)
		GALLERY_PAGE_CONTENT = GALLERY_PAGE_CONTENT_BUF.getvalue().replace("REPLACE_PAGE_URL", str(PAGE_PATH_FROM_ROOT))

		writeIfChangedFn(GALLERY_PAGE_CONTENT, GALLERY_PAGE, "gallery page")

		GALLERY_LATEST_CONTENT = generateGalleryLatestInfo(\
			GALLERY_PAGE_REL=f"{GALLERY_REL_NOT_INTERPRETED}/{GALLERY_PAGE_FILENAME}", \
			SHOOT_FAVORITE=f"{STATIC_IMAGES_DIR_NOT_INTERPRETED}/{SHOOT_FAVORITE}", shoot_date_parsed=shoot_date_parsed)

		# append to RSS items content if one of the last 10 galleries
		if HASHES_FILE.name in [x.name for x in HASHES_FILES_LAST_TEN]:
			RSS_ITEM_CONTENT = buildGalleryRssItem(\
				shoot_favorite_pattern=shoot_favorite_pattern, SHOOT_ID=HASHES_ID, \
				GALLERY_PAGE_FILENAME=GALLERY_PAGE_FILENAME, SHOOT_TITLE=SHOOT_TITLE, \
				SHOOT_DESC=SHOOT_DESC, SHOOT_FAVORITE=SHOOT_FAVORITE, SITE_HOME_URL=SITE_HOME_URL)

			# convert shoot date to unix style "seconds since epoch" integer timestamp
			RSS_ITEMS_BY_TIMESTAMP[int(shoot_date_parsed.strftime('%s'))] = RSS_ITEM_CONTENT

	# after all files have been handled, write the last one to the "latest file"
	writeIfChangedFn(GALLERY_LATEST_CONTENT, GALLERY_LATEST_FILE, "gallery latest")
	# after all files have been handled, write the last one to the index.html redirect file
	writeIfChangedFn(GALLERY_INDEX_CONTENT, GALLERY_INDEX_PAGE, "gallery index")

	# the RSS items file stuff is now handled by the calling build.py script
	# sort rss items by timestamp, then assemble into file contents
	#RSS_ITEMS_FILE_CONTENT_BUF = StringIO()
	#for SHOOT_DATE in sorted(RSS_ITEMS_BY_TIMESTAMP.keys()):
	#	RSS_ITEMS_FILE_CONTENT_BUF.write(RSS_ITEMS_BY_TIMESTAMP[SHOOT_DATE])
	#
	#RSS_ITEMS_FILE_CONTENT = RSS_ITEMS_FILE_CONTENT_BUF.getvalue()
	#writeIfChangedFn(RSS_ITEMS_FILE_CONTENT, RSS_ITEMS_FILE, "gallery RSS items file")
	return RSS_ITEMS_BY_TIMESTAMP

