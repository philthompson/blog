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

GALLERY_OUT="${OUT_DIR}/gallery"
mkdir -p "${GALLERY_OUT}"

GALLERY_IMG="${STATIC_DIR}/gallery-img"

# the first (most recent) hashes file generates the gallery/index.html page,
#   and older hashes files generate their own pages
find "${GALLERY_IMG}" -type f -name "hashes-*.txt" | sort -r | while read HASHES_FILE
do
	HASHES_DIR="`dirname "${HASHES_FILE}"`"
	HASHES_ID="`basename "${HASHES_FILE}" | cut -d '.' -f 1`"
	HASHES_DB="${HASHES_DIR}/${HASHES_ID}.db"
	HASHES_TXID="${HASHES_DIR}/${HASHES_ID}.txid"
	HASHES_DIR_REL="${SITE_ROOT_REL}/gallery-img/`basename "${HASHES_DIR}"`"
	HASHES_SUPP="${HASHES_DIR}/${HASHES_ID}.supplement"

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
	# - BCH TXID that contains the signature of the hashes file in OP RETURN
	#   - from hashes...txid
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
		sqlite3 "${HASHES_DB}" "CREATE TABLE shoot (title_b64 TEXT, description_b64 TEXT, bch_txid_b64 TEXT, favorite_path_rel TEXT, default_favorite_path_rel TEXT, visible TEXT)"

		SHOOT_DEFAULT_FAVORITE="`echo "--" | base64`"
		SHOOT_DEFAULT_FAVORITE_STARS=0

		grep "\-sm\." "${HASHES_FILE}" | while read LINE
		do
			PHOTO_FILENAME="`echo "${LINE}" | cut -d ':' -f 1`"
			PHOTO_PATH="${HASHES_DIR}/${PHOTO_FILENAME}"
			PHOTO_PATH_REL="${HASHES_DIR_REL}/${PHOTO_FILENAME}"
			PHOTO_DATETIME_LEX="`/usr/local/bin/exiftool -d '%Y-%m-%d-%H%M%S' -DateTimeOriginal -S -s "${PHOTO_PATH}"`"
			PHOTO_DATETIME_DISP="`/usr/local/bin/exiftool -d '%I:%M%p %A %B %d, %Y' -DateTimeOriginal -S -s "${PHOTO_PATH}"`"
			PHOTO_STARS="`/usr/local/bin/exiftool -d '%I:%M%p %A %B %d, %Y' -DateTimeOriginal -S -s "${PHOTO_PATH}"`"
			# i lowercased all species names, so now i have to re-capialize them here...
			# thanks to https://stackoverflow.com/a/1541178/259456 for the awk script that
			#   properly capitalizes things at word boundaries
			# NEVERMIND capitalization isn't apparently uniform for hyphenated words when
			#   it comes to bird species, so i'm going to leave capitalization of "species:"
			#   keywords unchanged -- i'll have to capitalize them properly when initially
			#   tagging them
			#PHOTO_SPECIES="`/usr/local/bin/exiftool "-MWG:Keywords" -S -s "${PHOTO_PATH}" | sed 's/, /@/g' | tr '@' '\n' | grep species | sed 's/species://g' | tr 'A-Z' 'a-z' | awk '{for(i=1;i<=NF;i++){ $i=toupper(substr($i,1,1)) substr($i,2) }}1' | tr '\n' ',' | sed -e 's/,/, /g' -e 's/, $//' | base64`"
			PHOTO_SPECIES="`/usr/local/bin/exiftool "-MWG:Keywords" -S -s "${PHOTO_PATH}" | sed 's/, /@/g' | tr '@' '\n' | grep species | sed 's/species://g' | tr '\n' ',' | sed -e 's/,/, /g' -e 's/, $//' | base64`"
			PHOTO_DESCRIPTION="`echo "--" | base64`"
			PHOTO_VISIBLE="true"
			PHOTO_STARS="`/usr/local/bin/exiftool "-MWG:Keywords" -S -s "${PHOTO_PATH}" | sed 's/, /@/g' | tr '@' '\n' | grep -m 1 "stars:[0-9]" | sed -E 's/.*stars:([0-9]).*/\1/'`"

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
			#else
			#	echo "supplement file [${HASHES_SUPP}] does NOT exist"
			fi

			#echo ""
			#echo "INSERT INTO photos(path_rel, local_datetime_lex, local_datetime_disp, species_b64, description_b64) VALUES ('${PHOTO_PATH_REL}', '${PHOTO_DATETIME_LEX}', '${PHOTO_DATETIME_DISP}', '${PHOTO_SPECIES}', '${PHOTO_DESCRIPTION}');"
			sqlite3 "${HASHES_DB}" "INSERT INTO photos(path_rel, local_datetime_lex, local_datetime_disp, species_b64, description_b64, visible) VALUES ('${PHOTO_PATH_REL}', '${PHOTO_DATETIME_LEX}', '${PHOTO_DATETIME_DISP}', '${PHOTO_SPECIES}', '${PHOTO_DESCRIPTION}', '${PHOTO_VISIBLE}');"
		done

		SHOOT_TITLE="`echo "${HASHES_ID}" | cut -d '-' -f 2-`"
		SHOOT_TITLE="`echo "Shoot ${SHOOT_TITLE}" | base64`"
		SHOOT_DESCRIPTION="`echo "--" | base64`"
		SHOOT_TXID="`echo "--" | base64`"
		SHOOT_VISIBLE="true"
		SHOOT_FAVORITE="`echo "--" | base64`"

		if [ -s "${HASHES_TXID}" ]
		then
			SHOOT_TXID="`head -n 1 "${HASHES_TXID}" | base64`"
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
				SHOOT_FAVORITE="`echo "${HASHES_DIR_REL}/${SUPP_FAVORITE}" | base64`"
			fi
		fi

		sqlite3 "${HASHES_DB}" "INSERT INTO shoot (title_b64, description_b64, bch_txid_b64, favorite_path_rel, default_favorite_path_rel, visible) VALUES ('${SHOOT_TITLE}', '${SHOOT_DESCRIPTION}', '${SHOOT_TXID}', '${SHOOT_FAVORITE}', '${SHOOT_DEFAULT_FAVORITE}', '${SHOOT_VISIBLE}');"
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
	GALLERY_PAGE="${GALLERY_OUT}/index.html"
	if [ -s "${GALLERY_PAGE}" ]
	then
		#GALLERY_PAGE_COUNT=`ls -1 "${GALLERY_OUT}" | wc -l | tr -d '[:blank:]'`
		#GALLERY_PAGE="${GALLERY_OUT}/older${GALLERY_PAGE_COUNT}.html"
		#GALLERY_PAGE_COUNT=$(($GALLERY_PAGE_COUNT + 1))
		#PAGE_TITLE="Gallery ${GALLERY_PAGE_COUNT}"
		GALLERY_PAGE="${GALLERY_OUT}/gallery-`echo "${HASHES_ID}" | cut -d '-' -f 2-`.html"
	fi

	SHOOT_DATA="`sqlite3 "${HASHES_DB}" "SELECT title_b64, description_b64, bch_txid_b64, favorite_path_rel, default_favorite_path_rel, visible FROM shoot LIMIT 1;"`"
	SHOOT_TITLE="`echo "${SHOOT_DATA}" | cut -d '|' -f 1 | base64 -d`"
	SHOOT_DESC="`echo "${SHOOT_DATA}" | cut -d '|' -f 2 | base64 -d`"
	SHOOT_TXID="`echo "${SHOOT_DATA}" | cut -d '|' -f 3 | base64 -d`"
	SHOOT_FAVORITE="`echo "${SHOOT_DATA}" | cut -d '|' -f 4 | base64 -d`"
	SHOOT_DEFAULT_FAVORITE="`echo "${SHOOT_DATA}" | cut -d '|' -f 5 | base64 -d`"
	SHOOT_VISIBLE="`echo "${SHOOT_DATA}" | cut -d '|' -f 6`"
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
	if [ ! -z "${SHOOT_FAVORITE}" ] && [ "${SHOOT_FAVORITE}" != "--" ]
	then
		SHOOT_FAVORITE="<a href=\"${SHOOT_FAVORITE}\"><img style=\"float: left\" class=\"width-resp-50-100\" src=\"${SHOOT_FAVORITE}\"/></a>"
	else
		SHOOT_FAVORITE=""
	fi
	SHOOT_YEAR="`echo "${HASHES_ID}" | cut -d '-' -f 2`"

	"${HEADER_SCRIPT}" "${SHOOT_TITLE}" "${SITE_ROOT_REL}" "bird photos gallery" "description here" 14 > "${GALLERY_PAGE}"

# wow thanks to https://stackoverflow.com/a/15742338/259456 for pointing out that
#   HTML now has <details> and <summary> tags with auto-collapse!
cat << xxxxxEOFxxxxx >> "${GALLERY_PAGE}"
<div class="btns" style="margin:0 0 2rem 0">
	xxxxxPREVBUTTONxxxxx
	xxxxxNEXTBUTTONxxxxx
</div>
<div class="">
	<span class="article-title">${SHOOT_TITLE}</span>
	${SHOOT_FAVORITE}
	${SHOOT_DESC}
	<details>
		<summary>Copyright and Signature</summary>
		<p>These photos are © ${SHOOT_YEAR} Phil Thompson, all rights reserved.</p>
		<p><a target="_blank" href="${HASHES_DIR_REL}/${HASHES_ID}.txt">📄 ${HASHES_ID}.txt</a></p>
		<p><a target="_blank" href="${HASHES_DIR_REL}/${HASHES_ID}.txt.sig">📄 ${HASHES_ID}.txt.sig</a></p>
		<p>
			The above <code>hashes-&lt;date&gt;.txt</code> file contains SHA-256 hashes of all the photos
			from this shoot.  The <code>hashes-&lt;date&gt;.txt.sig</code> is a signature of that hashes
			file, created with <a href="${SITE_ROOT_REL}/about">my PGP key</a>.  The signature file
			itself was written to the BCH blockchain, in <code>OP RETURN</code> data for the transaction
			below.  In short, this proves that these photos and the signature both existed at the time
			the transaction was written to the blockchain.  A future blog post will have more details.
		</p>
		<p class="article-info"><a target="_blank" href="https://blockchair.com/bitcoin-cash/transaction/${SHOOT_TXID}">view on blockchair.com: ${SHOOT_TXID}</a></p>
	</details>
	<p style="clear:both;"></p>
</div>
xxxxxEOFxxxxx
# <p class="article-info"><a target="_blank" href="https://www.blockchain.com/bch/tx/${SHOOT_TXID}">view on blockchain.com: ${SHOOT_TXID}</a></p>
# <p class="article-info"><a target="_blank" href="https://explorer.bitcoin.com/bch/tx/${SHOOT_TXID}">view on bitcoin.com: ${SHOOT_TXID}</a></p>

	# thanks to https://stackoverflow.com/a/51863033/259456 for row_number
	#sqlite3 "${HASHES_DB}" "SELECT ROW_NUMBER() OVER(ORDER BY local_datetime_lex) AS rnum, path_rel, local_datetime_lex, local_datetime_disp, species_b64, description_b64 FROM photos ORDER BY local_datetime_lex DESC;" | while read LINE
	sqlite3 "${HASHES_DB}" "SELECT path_rel, local_datetime_lex, local_datetime_disp, species_b64, description_b64, visible FROM photos ORDER BY local_datetime_lex ASC;" | while read LINE
	do
		#echo "${HASHES_ID} photo: ${LINE}"
		PHOTO_PATH="`echo "${LINE}" | cut -d '|' -f 1`"
		PHOTO_DATE="`echo "${LINE}" | cut -d '|' -f 3`"
		PHOTO_SPECIES="`echo "${LINE}" | cut -d '|' -f 4 | base64 -d`"
		PHOTO_DESC="`echo "${LINE}" | cut -d '|' -f 5 | base64 -d`"
		PHOTO_VISIBLE="`echo "${LINE}" | cut -d '|' -f 6`"
		if [ "${PHOTO_VISIBLE}" != "true" ]
		then
			#echo "photo ${PHOTO_PATH} of shoot ${HASHES_ID} is not visible, so skipping"
			continue
		fi
		if [ ! -z "${PHOTO_DESC}" ] && [ "${PHOTO_DESC}" != "--" ]
		then
			PHOTO_DESC="<p>${PHOTO_DESC}</p>"
		else
			PHOTO_DESC=""
		fi

cat << xxxxxEOFxxxxx >> "${GALLERY_PAGE}"
<div class="container top-border">
	<p>
		<a href="${PHOTO_PATH}">
			<img style="float: left" class="width-resp-50-100" src="${PHOTO_PATH}"/>
		</a>
		<p class="article-info">${PHOTO_DATE}</p>
		<b>${PHOTO_SPECIES}</b>
		${PHOTO_DESC}
	</p>
	<p style="clear:both;"></p>
</div>
xxxxxEOFxxxxx

	done

cat << xxxxxEOFxxxxx >> "${GALLERY_PAGE}"
<div class="btns" style="margin:0">
	xxxxxPREVBUTTONxxxxx
	xxxxxNEXTBUTTONxxxxx
</div>
xxxxxEOFxxxxx

	"${FOOTER_SCRIPT}" "${ARTICLE_TITLE}" "${SITE_ROOT_REL}" >> "${GALLERY_PAGE}"
done

# go back through all the gallery pages and add prev/next buttons,
#   both to the top and the bottom of each page

#<div class="btns">
#	<a class="btn" href="../2020/Apple-Notes-Shapes.html">Previous</a>
#	<a class="btn" href="../2020/Fundamentally-Broken-US-Government.html">Next</a>
#</div>

GALLERY_PAGE_COUNT=`ls -1 "${GALLERY_OUT}" | wc -l | tr -d '[:blank:]'`
FIRST_PAGE="${SITE_ROOT_REL}/gallery/"
LAST_PAGE="${SITE_ROOT_REL}/gallery/"
PREV_PAGE=""
NEXT_PAGE="older1.html"
GALLERY_PAGES="`find "${GALLERY_OUT}" -type f -name "gallery-*.html" | sort -r`"
if [ $GALLERY_PAGE_COUNT -gt 1 ]
then
	sed -e 's@xxxxxPREVBUTTONxxxxx@@g' -i '' "${GALLERY_OUT}/index.html"
	NEXT_PAGE="`echo "${GALLERY_PAGES}" | head -n 1`"
	NEXT_PAGE="`basename "${NEXT_PAGE}"`"
	sed -e "s@xxxxxNEXTBUTTONxxxxx@<a class='btn' href='${SITE_ROOT_REL}/gallery/${NEXT_PAGE}'>Next Gallery</a>@g" -i '' "${GALLERY_OUT}/index.html"
	
	echo "${GALLERY_PAGES}" | while read PAGE_PATH
	do
		PAGE_BASENAME="`basename "${PAGE_PATH}"`"
		PREV_NEXT="`echo "${GALLERY_PAGES}" | grep -B 1 -A 1 "${PAGE_BASENAME}"`"
		PREV_PAGE="`echo "${PREV_NEXT}" | head -n 1`"
		NEXT_PAGE="`echo "${PREV_NEXT}" | tail -n 1`"
		if [ "${PREV_PAGE}" == "${PAGE_PATH}" ]
		then
			PREV_PAGE="${SITE_ROOT_REL}/gallery/"
		else
			PREV_PAGE="${SITE_ROOT_REL}/gallery/`basename "${PREV_PAGE}"`"
		fi
		sed -e "s@xxxxxPREVBUTTONxxxxx@<a class='btn' href='${PREV_PAGE}'>Previous Gallery</a>@g" -i '' "${PAGE_PATH}"
		if [ "${NEXT_PAGE}" == "${PAGE_PATH}" ]
		then
			sed -e "s@xxxxxNEXTBUTTONxxxxx@@g" -i '' "${PAGE_PATH}"
		else
			NEXT_PAGE="${SITE_ROOT_REL}/gallery/`basename "${NEXT_PAGE}"`"
			sed -e "s@xxxxxNEXTBUTTONxxxxx@<a class='btn' href='${NEXT_PAGE}'>Next Gallery</a>@g" -i '' "${PAGE_PATH}"
		fi
		
	done
fi
