#!/bin/bash

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

THIS_SCRIPT="`perl -MCwd -le 'print Cwd::abs_path shift' "${0}"`"
THIS_DIR="$(dirname "${THIS_SCRIPT}")"

STATIC_DIR="${1}"
OUT_DIR="${2}"

HEADER_SCRIPT="${3}"
FOOTER_SCRIPT="${4}"
SITE_ROOT_REL="${5}"
RSS_ITEMS_FILE="${6}"
SITE_HOME_URL="${7}"
GALLERY_LATEST_FILE="${8}"

GALLERY_OUT="${OUT_DIR}/gallery"
mkdir -p "${GALLERY_OUT}"

GALLERY_REL="${SITE_ROOT_REL}/gallery"
GALLERY_REL_NOT_INTERPRETED="SITE_ROOT_REL/gallery"
STATIC_IMAGES_DIR_NOT_INTERPRETED="SITE_ROOT_REL/s/img"

GALLERY_IMG="${STATIC_DIR}/gallery-img"

generateGalleryIndexPage() {
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

generateGalleryLatestInfo() {
	GALLERY_PAGE_REL="${1}"
	SHOOT_FAVORITE="${2}"
	SHOOT_ID="${3}"
	SHOOT_DATE="$(echo "${SHOOT_ID}" | cut -d - -f 2-)"
	SHOOT_DATE_FMT="$(date -j -f '%Y-%m-%d-%H%M%S' "${SHOOT_DATE}" '+%A %B %e, %Y' | sed 's/  / /')"
cat << xxxxxEOFxxxxx
${GALLERY_PAGE_REL}
${SHOOT_FAVORITE}
${SHOOT_DATE_FMT}
xxxxxEOFxxxxx
}

generateHashSigInfo() {
	SHOOT_TITLE="${1}"
	SHOOT_FAVORITE="${2}"
	SHOOT_DESC="${3}"
	SHOOT_YEAR="${4}"
	HASHES_DIR_REL="${5}"
	HASHES_ID="${6}"
	SHOOT_ALGO_TXID="${7}"
	SITE_ROOT_REL="${8}"
	SHOOT_BCH_TXID="${9}"
	PREV_BUTTON="${10}"
	NEXT_BUTTON="${11}"

	if [[ "${SHOOT_FAVORITE}" =~ ^.*2[0-9]{3}-[0-9]{2}-[0-9]{2}-.*\.[jJ][pP][gG]$ ]]
	then
		SHOOT_FAVORITE="<a href=\"${SITE_ROOT_REL}/s/img/${SHOOT_FAVORITE}\"><img style=\"float: left\" class=\"width-resp-50-100\" src=\"${SITE_ROOT_REL}/s/img/${SHOOT_FAVORITE}\"/></a>"
	else
		SHOOT_FAVORITE=""
	fi

	# wow thanks to https://stackoverflow.com/a/15742338/259456 for pointing out that
	#   HTML now has <details> and <summary> tags with auto-collapse!
cat << xxxxxEOFxxxxx
<div class="btns" style="margin:0 0 2rem 0">
	${PREV_BUTTON}
	${NEXT_BUTTON}
</div>
<div class="">
	<span class="article-title">${SHOOT_TITLE}</span>
	${SHOOT_FAVORITE}
	${SHOOT_DESC}
	<p>These photos are © ${SHOOT_YEAR} Phil Thompson, all rights reserved.</p>
	<p>My "birds in review" collages can be found <a href="${SITE_ROOT_REL}/birds/">here</a>.</p>
	<details>
		<summary>Signature</summary>
		<p><a target="_blank" href="${HASHES_DIR_REL}/${HASHES_ID}.txt">📄 ${HASHES_ID}.txt</a></p>
		<p><a target="_blank" href="${HASHES_DIR_REL}/${HASHES_ID}.txt.sig">📄 ${HASHES_ID}.txt.sig</a></p>
xxxxxEOFxxxxx
if [ "${SHOOT_ALGO_TXID}" != "--" ]
then
cat << xxxxxEOFxxxxx
		<p>
			The above <code>hashes-&lt;date&gt;.txt</code> file contains SHA-256 hashes of all the photos
			from this shoot.  The <code>hashes-&lt;date&gt;.txt.sig</code> is a signature of that hashes
			file, created with <a href="${SITE_ROOT_REL}/about">my PGP key</a>.  The signature file
			itself was written to both the Bitcoin Cash and Algorand blockchains, in the
			<code>OP RETURN</code> and <code>Note</code> fields respectively, using the transactions below.
			In short, this proves that these photos and the signature both existed at the time the
			transactions were written to the Bitcoin Cash and Algorand blockchains.
			<a target="_blank" href="${SITE_ROOT_REL}/2021/Publishing-Permanent-Photo-Signatures-with-Blockchains.html">
			This blog post</a> has more details.
		</p>
		<p class="article-info"><a target="_blank" href="https://blockchair.com/bitcoin-cash/transaction/${SHOOT_BCH_TXID}">view the BCH tx on blockchair.com: ${SHOOT_BCH_TXID}</a></p>
		<p class="article-info"><a target="_blank" href="https://algoexplorer.io/tx/${SHOOT_ALGO_TXID}">view the ALGO tx on algoexplorer.io: ${SHOOT_ALGO_TXID}</a></p>
xxxxxEOFxxxxx
else
cat << xxxxxEOFxxxxx
		<p>
			The above <code>hashes-&lt;date&gt;.txt</code> file contains SHA-256 hashes of all the photos
			from this shoot.  The <code>hashes-&lt;date&gt;.txt.sig</code> is a signature of that hashes
			file, created with <a href="${SITE_ROOT_REL}/about">my PGP key</a>.  The signature file
			itself was written to the Bitcoin Cash blockchain, in the <code>OP RETURN</code> field,
			using the transaction below. In short, this proves that these photos and the signature both
			existed at the time the transaction was written to the Bitcoin Cash blockchain.
			<a target="_blank" href="${SITE_ROOT_REL}/2021/Publishing-Permanent-Photo-Signatures-with-Blockchains.html">
			This blog post</a> has more details.
		</p>
		<p class="article-info"><a target="_blank" href="https://blockchair.com/bitcoin-cash/transaction/${SHOOT_BCH_TXID}">view the BCH tx on blockchair.com: ${SHOOT_BCH_TXID}</a></p>
xxxxxEOFxxxxx
fi
cat << xxxxxEOFxxxxx
	</details>
	<p style="clear:both;"></p>
</div>
xxxxxEOFxxxxx
# <p class="article-info"><a target="_blank" href="https://www.blockchain.com/bch/tx/${SHOOT_TXID}">view on blockchain.com: ${SHOOT_TXID}</a></p>
# <p class="article-info"><a target="_blank" href="https://explorer.bitcoin.com/bch/tx/${SHOOT_TXID}">view on bitcoin.com: ${SHOOT_TXID}</a></p>
}

generatePhotoDiv() {
	LINE="${1}"
	SITE_ROOT_REL="${2}"
	#echo "${HASHES_ID} photo: ${LINE}"
	PHOTO_PATH="`echo "${LINE}" | cut -d '|' -f 1`"
	PHOTO_DATE="`echo "${LINE}" | cut -d '|' -f 3 | sed 's/^0//'`"
	# replace most plain spaces in pre-formatted dates with
	#   '&nbsp;' (non-breaking spaces)
	# the regex below matches dates written by exiftool in this format:
	#   '8:43AM Tuesday May 03, 2022'
	if [[ "${PHOTO_DATE}" =~ ^[0-9]{1,2}:[0-9]{2}[AP]M\ [A-Za-z]{6,9}\ [A-Za-z]{3,9}\ [0-9]{1,2},\ 2[0-9]{3}$ ]]
	then
		# replace all spaces with &nbsp; then replace the 2nd &nbsp; with a space again
		# this makes the final result of
		#  '8:43AM&nbsp;Tuesday May&nbsp;03,&nbsp;2022'
		# (where the line break can only happen between the day of the
		# week and the month name, not anywhere else)
		PHOTO_DATE="$(echo "${PHOTO_DATE}" | sed 's/ /\&nbsp;/g' | sed 's/\&nbsp;/ /2')"
	fi
	PHOTO_SPECIES="`echo "${LINE}" | cut -d '|' -f 4 | base64 -d`"
	PHOTO_DESC="`echo "${LINE}" | cut -d '|' -f 5 | base64 -d`"
	PHOTO_VISIBLE="`echo "${LINE}" | cut -d '|' -f 6`"
	if [ "${PHOTO_VISIBLE}" != "true" ]
	then
		#echo "photo ${PHOTO_PATH} of shoot ${HASHES_ID} is not visible, so skipping"
		return
	fi
	if [ ! -z "${PHOTO_DESC}" ] && [ "${PHOTO_DESC}" != "--" ]
	then
		PHOTO_DESC="<p>${PHOTO_DESC}</p>"
	else
		PHOTO_DESC=""
	fi

cat << xxxxxEOFxxxxx
<div class="wrap-wider-child container top-border">
	<p>
		<a href="${SITE_ROOT_REL}/s/img/${PHOTO_PATH}">
			<img style="float: left" class="width-resp-75-100" src="${SITE_ROOT_REL}/s/img/${PHOTO_PATH}"/>
		</a>
		<p class="article-info">${PHOTO_DATE}</p>
		<b>${PHOTO_SPECIES}</b>
		${PHOTO_DESC}
	</p>
	<p style="clear:both;"></p>
</div>
xxxxxEOFxxxxx
}

buildGalleryRssItem() {
	SHOOT_ID="${1}"
	GALLERY_PAGE_FILENAME="${2}"
	SHOOT_TITLE="${3}"
	SHOOT_DESC="${4}"
	SHOOT_FAVORITE="${5}"
	SITE_HOME_URL="${6}"
	# since the shoots have IDs like:
	#   hashes-YYYY-MM-DD-HHMMSS
	# we can format according to https://www.w3.org/Protocols/rfc822/#z28
	SHOOT_DATE="$(echo "${SHOOT_ID}" | cut -d - -f 2-)"
	SHOOT_DATE_RSS="$(date -j -f '%Y-%m-%d-%H%M%S' "${SHOOT_DATE}" '+%a, %d %b %Y %H:%M:%S %z')"

	ABSOLUTE_GALLERY_URL="${SITE_HOME_URL}/gallery/${GALLERY_PAGE_FILENAME}"

	SHOOT_DESC="${SHOOT_DESC}<br/><a href=\"${ABSOLUTE_GALLERY_URL}\">See this gallery at philthompson.me</a>."

	if [[ "${SHOOT_FAVORITE}" =~ ^.*2[0-9]{3}-[0-9]{2}-[0-9]{2}-.*\.[jJ][pP][gG]$ ]]
	then
		SHOOT_DESC="<a href=\"${ABSOLUTE_GALLERY_URL}\"><img style=\"float: left\" class=\"width-resp-75-100\" src=\"${SITE_HOME_URL}/s/img/${SHOOT_FAVORITE}\"/></a><br/>${SHOOT_DESC}"
	fi

	echo "  <item>"
	echo "    <title>${SHOOT_TITLE}</title>"
	echo "    <link>${ABSOLUTE_GALLERY_URL}</link>"
	echo "    <pubDate>${SHOOT_DATE_RSS}</pubDate>"
	echo "    <description><![CDATA[${SHOOT_DESC}]]></description>"
	echo "    <category>gallery</category>"
	echo "    <guid>${ABSOLUTE_GALLERY_URL}</guid>"
	echo "  </item>"
}

HASHES_FILES_SORTED="`find "${GALLERY_IMG}" -type f -name "hashes-*.txt" | sort`"

HASHES_FILES_LAST_TEN="$(echo "${HASHES_FILES_SORTED}" | tail -n 10)"
RSS_ITEMS_FILE_CONTENT=""

# the first (most recent) hashes file generates a redirect for the gallery/index.html page
# to allow variables outside while loop to be modified from within the
#   loop, we will use a "here string" (at the "done <<< ..." line) to
#   provide input to the while loop
#   (see https://stackoverflow.com/a/16854326/259456)
while read HASHES_FILE
do
	HASHES_DIR="`dirname "${HASHES_FILE}"`"
	HASHES_ID="`basename "${HASHES_FILE}" | cut -d '.' -f 1`"
	HASHES_DB="${HASHES_DIR}/${HASHES_ID}.db"
	HASHES_BCH_TXID_OLD="${HASHES_DIR}/${HASHES_ID}.txid"
	HASHES_BCH_TXID="${HASHES_DIR}/${HASHES_ID}-BCH.txid"
	HASHES_ALGO_TXID="${HASHES_DIR}/${HASHES_ID}-ALGO.txid"
	HASHES_DIR_REL="${SITE_ROOT_REL}/gallery-img/`basename "${HASHES_DIR}"`"
	HASHES_SUPP="${HASHES_DIR}/${HASHES_ID}.supplement"

	HASHES_YEAR="0123"

	if [[ "${HASHES_ID}" =~ ^hashes-2[0-9]{3}-[0-9]{2}-[0-9]{2}-[0-9]{6}$ ]]
	then
		HASHES_YEAR="`echo "${HASHES_ID}" | cut -d '-' -f 2`"
	else
		echo "invalid hashes file [${HASHES_ID}]: hashes filename format is expected to be \"hashes-YYYY-MM-DD-HHmmss\"" >&2
		continue
	fi

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
	if [ ! -s "${HASHES_DB}" ]
	then
		# photos table columns:
		# - local_datetime_lex (text) (ascii sortable)
		# - local_datetime_disp (text)
		# - species (text)
		# - description (text)
		# shoot table columns:
		# - title (text)
		# - description (text)
		# - bch_txid (text)
		sqlite3 "${HASHES_DB}" "CREATE TABLE photos (path_rel TEXT PRIMARY KEY, local_datetime_lex TEXT, local_datetime_disp TEXT, species_b64 TEXT, description_b64 TEXT, visible TEXT)"
		sqlite3 "${HASHES_DB}" "CREATE TABLE shoot (title_b64 TEXT, description_b64 TEXT, bch_txid_b64 TEXT, algo_txid_b64 TEXT, favorite_path_rel TEXT, default_favorite_path_rel TEXT, visible TEXT)"

		SHOOT_DEFAULT_FAVORITE="`echo "--" | base64`"
		SHOOT_DEFAULT_FAVORITE_STARS=0

		# to allow variables outside while loop to be modified from within the
		#   loop, we will use a "here string" (at the "done <<< ..." line) to
		#   provide input to the while loop
		#   (see https://stackoverflow.com/a/16854326/259456)
		while read LINE
		do
			PHOTO_FILENAME="`echo "${LINE}" | cut -d ':' -f 1`"
			PHOTO_YEAR="`echo "${PHOTO_FILENAME}" | cut -d - -f 1`"
			PHOTO_MONTH="`echo "${PHOTO_FILENAME}" | cut -d - -f 2`"
			# this requires a local (on the system this script is running on) copy
			#   of all bird gallery -sm.jpg pictures, which i of course have but
			#   this means the git repo is not self-contained with respect to
			#   these pictures anymore, which is kind of the point anyway of
			#   removing bird gallery pics from the git repo
			PHOTO_PATH="${HOME}/Pictures/Birds/${PHOTO_YEAR}/${PHOTO_MONTH}/${PHOTO_FILENAME}"
			# some photos are not of birds, but i'd like to publish their signature and
			#   thumbnail pics anyway, so look in "Other" photos folder
			if [ ! -s "${PHOTO_PATH}" ]
			then
				PHOTO_PATH="${HOME}/Pictures/Other/${PHOTO_YEAR}/${PHOTO_MONTH}/${PHOTO_FILENAME}"
			fi
			if [ ! -s "${PHOTO_PATH}" ]
			then
				PHOTO_PATH="${HOME}/Pictures/Astro/${PHOTO_YEAR}/${PHOTO_MONTH}/${PHOTO_FILENAME}"
			fi
			if [ ! -s "${PHOTO_PATH}" ]
			then
				PHOTO_PATH="`find "${HOME}/Pictures/Birds" -type f -name "${PHOTO_FILENAME}" | head -n 1`"
			fi
			if [ -z "${PHOTO_PATH}" ] || [ ! -s "${PHOTO_PATH}" ]
			then
				PHOTO_PATH="`find "${HOME}/Pictures/Other" -type f -name "${PHOTO_FILENAME}" | head -n 1`"
			fi
			if [ -z "${PHOTO_PATH}" ] || [ ! -s "${PHOTO_PATH}" ]
			then
				PHOTO_PATH="`find "${HOME}/Pictures/Astro" -type f -name "${PHOTO_FILENAME}" | head -n 1`"
			fi
			# this path is relative to the new on-webserver static images path
			PHOTO_PATH_REL="${HASHES_YEAR}/${PHOTO_FILENAME}"
			PHOTO_DATETIME_LEX="`/opt/homebrew/bin/exiftool -d '%Y-%m-%d-%H%M%S' -DateTimeOriginal -S -s "${PHOTO_PATH}"`"
			#PHOTO_DATETIME_DISP="`/opt/homebrew/bin/exiftool -d '%I:%M%p %A %B %d, %Y' -DateTimeOriginal -S -s "${PHOTO_PATH}"`"
			PHOTO_DATETIME_DISP="`/opt/homebrew/bin/exiftool -d '%I:%M%p&nbsp;%A %B&nbsp;%d,&nbsp;%Y' -DateTimeOriginal -S -s "${PHOTO_PATH}"`"
			#PHOTO_STARS="`/opt/homebrew/bin/exiftool -d '%I:%M%p %A %B %d, %Y' -DateTimeOriginal -S -s "${PHOTO_PATH}"`"
			# i lowercased all species names, so now i have to re-capialize them here...
			# thanks to https://stackoverflow.com/a/1541178/259456 for the awk script that
			#   properly capitalizes things at word boundaries
			# NEVERMIND capitalization isn't apparently uniform for hyphenated words when
			#   it comes to bird species, so i'm going to leave capitalization of "species:"
			#   keywords unchanged -- i'll have to capitalize them properly when initially
			#   tagging them
			#PHOTO_SPECIES="`/opt/homebrew/bin/exiftool "-MWG:Keywords" -S -s "${PHOTO_PATH}" | sed 's/, /@/g' | tr '@' '\n' | grep species | sed 's/species://g' | tr 'A-Z' 'a-z' | awk '{for(i=1;i<=NF;i++){ $i=toupper(substr($i,1,1)) substr($i,2) }}1' | tr '\n' ',' | sed -e 's/,/, /g' -e 's/, $//' | base64`"
			PHOTO_SPECIES="`/opt/homebrew/bin/exiftool "-MWG:Keywords" -S -s "${PHOTO_PATH}" | sed 's/, /@/g' | tr '@' '\n' | grep 'species:' | sed 's/species://g' | tr '\n' ',' | sed -e 's/,/, /g' -e 's/, $//' | base64`"
			PHOTO_DESCRIPTION="`echo "--" | base64`"
			PHOTO_VISIBLE="true"
			PHOTO_STARS="`/opt/homebrew/bin/exiftool "-MWG:Keywords" -S -s "${PHOTO_PATH}" | sed 's/, /@/g' | tr '@' '\n' | grep -m 1 "stars:[0-9]" | sed -E 's/.*stars:([0-9]).*/\1/'`"

			if [ ! -z "${PHOTO_STARS}" ] && [ $PHOTO_STARS -gt $SHOOT_DEFAULT_FAVORITE_STARS ]
			then
				SHOOT_DEFAULT_FAVORITE_STARS=$PHOTO_STARS
				SHOOT_DEFAULT_FAVORITE="`echo "${PHOTO_PATH_REL}" | base64`"
			fi

			# if the hashes file supplement exists, replace any photo data with anything
			#   found in that file
			# this allows the supplement file to override anything read from the photos
			#   themselves (like corrections, or additional description, etc)
			if [ -s "${HASHES_SUPP}" ]
			then
				SUPP_SPECIES="`grep -m 1 "${PHOTO_FILENAME}:species:" "${HASHES_SUPP}" | cut -d ':' -f 3-`"
				SUPP_DESCRIPTION="`grep -m 1 "${PHOTO_FILENAME}:description:" "${HASHES_SUPP}" | cut -d ':' -f 3-`"
				SUPP_VISIBLE="`grep -m 1 "${PHOTO_FILENAME}:visible:" "${HASHES_SUPP}" | cut -d ':' -f 3 | tr 'A-Z' 'a-z'`"
				SUPP_DATETIME_DISP="`grep -m 1 "${PHOTO_FILENAME}:datetimedisp:" "${HASHES_SUPP}" | cut -d ':' -f 3-`"
				if [ ! -z "${SUPP_SPECIES}" ]
				then
					PHOTO_SPECIES="`echo "${SUPP_SPECIES}" | base64`"
				fi
				if [ ! -z "${SUPP_DESCRIPTION}" ]
				then
					PHOTO_DESCRIPTION="`echo "${SUPP_DESCRIPTION}" | base64`"
				fi
				if [ "${SUPP_VISIBLE}" == "false" ]
				then
					PHOTO_VISIBLE="${SUPP_VISIBLE}"
				fi
				if [ ! -z "${SUPP_DATETIME_DISP}" ]
				then
					PHOTO_DATETIME_DISP="`echo "${SUPP_DATETIME_DISP}"`"
				fi
			#else
			#	echo "supplement file [${HASHES_SUPP}] does NOT exist"
			fi

			#echo ""
			#echo "INSERT INTO photos(path_rel, local_datetime_lex, local_datetime_disp, species_b64, description_b64) VALUES ('${PHOTO_PATH_REL}', '${PHOTO_DATETIME_LEX}', '${PHOTO_DATETIME_DISP}', '${PHOTO_SPECIES}', '${PHOTO_DESCRIPTION}');"
			sqlite3 "${HASHES_DB}" "INSERT INTO photos(path_rel, local_datetime_lex, local_datetime_disp, species_b64, description_b64, visible) VALUES ('${PHOTO_PATH_REL}', '${PHOTO_DATETIME_LEX}', '${PHOTO_DATETIME_DISP}', '${PHOTO_SPECIES}', '${PHOTO_DESCRIPTION}', '${PHOTO_VISIBLE}');"
		done <<< "$(grep "\-sm\." "${HASHES_FILE}")"

		SHOOT_TITLE="`echo "${HASHES_ID}" | cut -d '-' -f 2-`"
		SHOOT_TITLE="`echo "Shoot ${SHOOT_TITLE}" | base64`"
		SHOOT_DESCRIPTION="`echo "--" | base64`"
		SHOOT_BCH_TXID="`echo "--" | base64`"
		SHOOT_ALGO_TXID="`echo "--" | base64`"
		SHOOT_VISIBLE="true"
		SHOOT_FAVORITE="`echo "--" | base64`"

		# read and use BCH txid file, if present
		if [ -s "${HASHES_BCH_TXID_OLD}" ]
		then
			SHOOT_BCH_TXID="`head -n 1 "${HASHES_BCH_TXID_OLD}" | base64`"
		elif [ -s "${HASHES_BCH_TXID}" ]
		then
			SHOOT_BCH_TXID="`head -n 1 "${HASHES_BCH_TXID}" | base64`"
		fi
		# read and use ALGO txid file, if present
		if [ -s "${HASHES_ALGO_TXID}" ]
		then
			SHOOT_ALGO_TXID="`head -n 1 "${HASHES_ALGO_TXID}" | base64`"
		fi
		if [ -s "${HASHES_SUPP}" ]
		then
			SUPP_TITLE="`grep -m 1 "shoot:title:" "${HASHES_SUPP}" | cut -d ':' -f 3-`"
			SUPP_DESCRIPTION="`grep -m 1 "shoot:description:" "${HASHES_SUPP}" | cut -d ':' -f 3-`"
			SUPP_VISIBLE="`grep -m 1 "shoot:visible:" "${HASHES_SUPP}" | cut -d ':' -f 3 | tr 'A-Z' 'a-z'`"
			SUPP_FAVORITE="`grep -m 1 "shoot:favorite:" "${HASHES_SUPP}" | cut -d ':' -f 3`"
			if [ ! -z "${SUPP_TITLE}" ]
			then
				SHOOT_TITLE="`echo "${SUPP_TITLE}" | base64`"
			fi
			if [ ! -z "${SUPP_DESCRIPTION}" ]
			then
				SHOOT_DESCRIPTION="`echo "${SUPP_DESCRIPTION}" | base64`"
			fi
			if [ "${SUPP_VISIBLE}" == "false" ]
			then
				SHOOT_VISIBLE="${SUPP_VISIBLE}"
			fi
			if [ ! -z "${SUPP_FAVORITE}" ]
			then
				SHOOT_FAVORITE="`echo "${HASHES_YEAR}/${SUPP_FAVORITE}" | base64`"
			fi
		fi

		sqlite3 "${HASHES_DB}" "INSERT INTO shoot (title_b64, description_b64, bch_txid_b64, algo_txid_b64, favorite_path_rel, default_favorite_path_rel, visible) VALUES ('${SHOOT_TITLE}', '${SHOOT_DESCRIPTION}', '${SHOOT_BCH_TXID}', '${SHOOT_ALGO_TXID}', '${SHOOT_FAVORITE}', '${SHOOT_DEFAULT_FAVORITE}', '${SHOOT_VISIBLE}');"
	fi

	# find the previous/next pages
	# these are NOT in the database for this hashes file because we may
	#   add a new hashes file between two existing ones, so we have
	#   to always check all hashes files for prev/next
	PREV_NEXT="$(echo "${HASHES_FILES_SORTED}" | cut -d ' ' -f 2 | grep -B 1 -A 1 "${HASHES_ID}")"

	PREV_PAGE_FILE="$(basename "$(echo "${PREV_NEXT}" | head -n 1)" | cut -d '.' -f 1)"
	NEXT_PAGE_FILE="$(basename "$(echo "${PREV_NEXT}" | tail -n 1)" | cut -d '.' -f 1)"

	NEXT_BUTTON=""
	if [[ "${NEXT_PAGE_FILE}" != "${HASHES_ID}" ]]
	then
		NEXT_PAGE_FILE="gallery-`echo "${NEXT_PAGE_FILE}" | cut -d '-' -f 2-`.html"
		NEXT_BUTTON="<a class='btn' href='${SITE_ROOT_REL}/gallery/${NEXT_PAGE_FILE}'>Newer Gallery</a>"
	fi

	PREV_BUTTON=""
	if [[ "${PREV_PAGE_FILE}" != "${HASHES_ID}" ]]
	then
		PREV_PAGE_FILE="gallery-`echo "${PREV_PAGE_FILE}" | cut -d '-' -f 2-`.html"
		PREV_BUTTON="<a class='btn' href='${SITE_ROOT_REL}/gallery/${PREV_PAGE_FILE}'>Older Gallery</a>"
	fi

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
	GALLERY_PAGE_FILENAME="gallery-`echo "${HASHES_ID}" | cut -d '-' -f 2-`.html"
	GALLERY_INDEX_PAGE="${GALLERY_OUT}/index.html"

	#GALLERY_PAGE_COUNT=`ls -1 "${GALLERY_OUT}" | wc -l | tr -d '[:blank:]'`
	#GALLERY_PAGE="${GALLERY_OUT}/older${GALLERY_PAGE_COUNT}.html"
	#GALLERY_PAGE_COUNT=$(($GALLERY_PAGE_COUNT + 1))
	#PAGE_TITLE="Gallery ${GALLERY_PAGE_COUNT}"
	GALLERY_PAGE="${GALLERY_OUT}/${GALLERY_PAGE_FILENAME}"

	# capture function stdout into a variable, thanks to:
	#   https://unix.stackexchange.com/a/591153/210174
	{ read -d '' GALLERY_INDEX_CONTENT; }< <(generateGalleryIndexPage "${GALLERY_REL}/${GALLERY_PAGE_FILENAME}")

	if [[ ! -f "${GALLERY_INDEX_PAGE}" ]] || [[ "`echo "${GALLERY_INDEX_CONTENT}" | shasum -a 256 | cut -d ' ' -f 1`" != "`shasum -a 256 "${GALLERY_INDEX_PAGE}" | cut -d ' ' -f 1`" ]]
	then
		echo "${GALLERY_INDEX_CONTENT}" > "${GALLERY_INDEX_PAGE}"
	else
		echo "gallery index [${GALLERY_INDEX_PAGE}] is unchanged"
	fi

	SHOOT_DATA="`sqlite3 "${HASHES_DB}" "SELECT title_b64, description_b64, bch_txid_b64, algo_txid_b64, favorite_path_rel, default_favorite_path_rel, visible FROM shoot LIMIT 1;"`"
	SHOOT_TITLE="`echo "${SHOOT_DATA}" | cut -d '|' -f 1 | base64 -d`"
	SHOOT_DESC="`echo "${SHOOT_DATA}" | cut -d '|' -f 2 | base64 -d`"
	SHOOT_BCH_TXID="`echo "${SHOOT_DATA}" | cut -d '|' -f 3 | base64 -d`"
	SHOOT_ALGO_TXID="`echo "${SHOOT_DATA}" | cut -d '|' -f 4 | base64 -d`"
	SHOOT_FAVORITE="`echo "${SHOOT_DATA}" | cut -d '|' -f 5 | base64 -d`"
	SHOOT_DEFAULT_FAVORITE="`echo "${SHOOT_DATA}" | cut -d '|' -f 6 | base64 -d`"
	SHOOT_VISIBLE="`echo "${SHOOT_DATA}" | cut -d '|' -f 7`"
	if [ "${SHOOT_VISIBLE}" != "true" ]
	then
		echo "shoot ${HASHES_ID} is not visible (${SHOOT_VISIBLE}), so skipping"
		continue
	fi
	if [ ! -z "${SHOOT_DESC}" ] && [ "${SHOOT_DESC}" != "--" ]
	then
		SHOOT_DESC="<p>${SHOOT_DESC}</p>"
	else
		SHOOT_DESC=""
	fi
	if [ -z "${SHOOT_FAVORITE}" ] || [ "${SHOOT_FAVORITE}" == "--" ]
	then
		SHOOT_FAVORITE="${SHOOT_DEFAULT_FAVORITE}"
	fi
	SHOOT_YEAR="`echo "${HASHES_ID}" | cut -d '-' -f 2`"

	GALLERY_PAGE_CONTENT="`bash "${HEADER_SCRIPT}" "${SHOOT_TITLE}" "${SITE_ROOT_REL}" "bird photos gallery" "description here" 14`"


	# capture function stdout into a variable, thanks to:
	#   https://unix.stackexchange.com/a/591153/210174
	{ read -d '' GALLERY_PAGE_CONTENT_TMP; }< <(generateHashSigInfo \
		"${SHOOT_TITLE}" \
		"${SHOOT_FAVORITE}" \
		"${SHOOT_DESC}" \
		"${SHOOT_YEAR}" \
		"${HASHES_DIR_REL}" \
		"${HASHES_ID}" \
		"${SHOOT_ALGO_TXID}" \
		"${SITE_ROOT_REL}" \
		"${SHOOT_BCH_TXID}" \
		"${PREV_BUTTON}" \
		"${NEXT_BUTTON}")

	#GALLERY_PAGE_CONTENT="$(echo -e "${GALLERY_PAGE_CONTENT}\n${GALLERY_PAGE_CONTENT_TMP}")"
	# embed newline directly into variable
	GALLERY_PAGE_CONTENT="${GALLERY_PAGE_CONTENT}
${GALLERY_PAGE_CONTENT_TMP}"


	# thanks to https://stackoverflow.com/a/51863033/259456 for row_number
	#sqlite3 "${HASHES_DB}" "SELECT ROW_NUMBER() OVER(ORDER BY local_datetime_lex) AS rnum, path_rel, local_datetime_lex, local_datetime_disp, species_b64, description_b64 FROM photos ORDER BY local_datetime_lex DESC;" | while read LINE
	#sqlite3 "${HASHES_DB}" "SELECT path_rel, local_datetime_lex, local_datetime_disp, species_b64, description_b64, visible FROM photos ORDER BY local_datetime_lex ASC;" | while read LINE
	while read LINE
	do
		{ read -d '' GALLERY_PAGE_CONTENT_TMP; }< <(generatePhotoDiv \
			"${LINE}" \
			"${SITE_ROOT_REL}")
		#GALLERY_PAGE_CONTENT="$(echo -e "${GALLERY_PAGE_CONTENT}\n${GALLERY_PAGE_CONTENT_TMP}")"
		# embed newline directly into variable
		GALLERY_PAGE_CONTENT="${GALLERY_PAGE_CONTENT}
${GALLERY_PAGE_CONTENT_TMP}"
	done <<< $(sqlite3 "${HASHES_DB}" "SELECT path_rel, local_datetime_lex, local_datetime_disp, species_b64, description_b64, visible FROM photos ORDER BY local_datetime_lex ASC;")

	# embed newlines directly into variables
	GALLERY_PAGE_CONTENT_TMP="<div class=\"btns\" style=\"margin:0\">
    ${PREV_BUTTON}
    ${NEXT_BUTTON}
</div>"
	GALLERY_PAGE_CONTENT="${GALLERY_PAGE_CONTENT}
${GALLERY_PAGE_CONTENT_TMP}"

	GALLERY_PAGE_CONTENT_TMP="`bash "${FOOTER_SCRIPT}" "${ARTICLE_TITLE}" "${SITE_ROOT_REL}"`"
	GALLERY_PAGE_CONTENT="${GALLERY_PAGE_CONTENT}
${GALLERY_PAGE_CONTENT_TMP}"

	# since page path from root is eqivalent to the
	#   page path without the OUT_DIR prefix, we can
	#   get the length of OUT_DIR and ignore those
	#   first number of characters
	OUT_DIR_LEN=${#OUT_DIR}
	# do substring here ${VAR:start:count}, with no :count
	#   to include the rest of the string
	PAGE_PATH_FROM_ROOT="${GALLERY_PAGE:$OUT_DIR_LEN}"
	# replace page path into page content
	GALLERY_PAGE_CONTENT="$(echo "${GALLERY_PAGE_CONTENT}" | sed "s#REPLACE_PAGE_URL#${PAGE_PATH_FROM_ROOT}#")"

	if [[ ! -f "${GALLERY_PAGE}" ]] || [[ "`echo "${GALLERY_PAGE_CONTENT}" | shasum -a 256 | cut -d ' ' -f 1`" != "`shasum -a 256 "${GALLERY_PAGE}" | cut -d ' ' -f 1`" ]]
	then
		echo "gallery page [${GALLERY_PAGE}] IS changed"
		echo "${GALLERY_PAGE_CONTENT}" > "${GALLERY_PAGE}"
	#else
	#	echo "gallery page [${GALLERY_PAGE}] is unchanged"
	fi

	# output latest gallery info to a file so it can be included on the
	#   blog home page
	{ read -d '' GALLERY_LATEST_CONTENT; }< <(generateGalleryLatestInfo "${GALLERY_REL_NOT_INTERPRETED}/${GALLERY_PAGE_FILENAME}" "${STATIC_IMAGES_DIR_NOT_INTERPRETED}/${SHOOT_FAVORITE}" "${HASHES_ID}")

	if [[ ! -f "${GALLERY_LATEST_FILE}" ]] || [[ "`echo "${GALLERY_LATEST_CONTENT}" | shasum -a 256 | cut -d ' ' -f 1`" != "`shasum -a 256 "${GALLERY_LATEST_FILE}" | cut -d ' ' -f 1`" ]]
	then
		echo "${GALLERY_LATEST_CONTENT}" > "${GALLERY_LATEST_FILE}"
	#else
	#	echo "gallery index [${GALLERY_LATEST_FILE}] is unchanged"
	fi

	# append to RSS items content if one of the last 10 galleries
	if [ ! -z "$(echo "${HASHES_FILES_LAST_TEN}" | grep "${HASHES_ID}")" ]
	then

		# append article home page snippet to the appropriate home page
		# capture function stdout into a variable, thanks to:
		#   https://unix.stackexchange.com/a/591153/210174
		{ read -d '' RSS_ITEM; }< <(buildGalleryRssItem "${HASHES_ID}" "${GALLERY_PAGE_FILENAME}" "${SHOOT_TITLE}" "${SHOOT_DESC}" "${SHOOT_FAVORITE}" "${SITE_HOME_URL}")
		# embed newline directly into variable
		RSS_ITEMS_FILE_CONTENT="${RSS_ITEMS_FILE_CONTENT}
${RSS_ITEM}"
	fi

done <<< "${HASHES_FILES_SORTED}"

if [[ ! -f "${RSS_ITEMS_FILE}" ]] || [[ "`echo "${RSS_ITEMS_FILE_CONTENT}" | shasum -a 256 | cut -d ' ' -f 1`" != "`shasum -a 256 "${RSS_ITEMS_FILE}" | cut -d ' ' -f 1`" ]]
then
	echo "gallery RSS items file [${RSS_ITEMS_FILE}] IS changed"
	echo "${RSS_ITEMS_FILE_CONTENT}" > "${RSS_ITEMS_FILE}"
fi
