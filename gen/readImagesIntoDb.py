# python 3
#
# sqlite3 module
# https://docs.python.org/3/library/sqlite3.html

import sys
import os
import csv
from pathlib import Path
import sqlite3

# following instructions from this brilliant, thorough, very
#   useful stackoverflow answer:
#     https://stackoverflow.com/a/44788410/259456
#   PyExifTool is made available for import here
# - downloaded everything from the "exiftool" directory in
#     https://github.com/sylikc/pyexiftool into a folder
#     on my machine "~/dev/other-folks-repos/pyexiftool" to
#     create "~/dev/other-folks-repos/pyexiftool/exiftool"
# - i also already have exiftool installed and in the path
#   on my machine
# - create symlink in this directory pointing to the exiftool
#   folder "$ ln -s ~/dev/other-folks-repos/pyexiftool/exiftool exiftool"

#sys.path.append("{}/dev/other-folks-repos/pyexiftool".format(Path.home()))
import exiftool

# the full path to the exiftool config file in this directory
exiftool_config_path = str(Path(__file__).parent.joinpath("ExifTool-config-md5"))
# the full path to the locations csv file in this directory
loc_csv_path = str(Path(__file__).parent.joinpath("loc_names_locations.csv"))

if len(sys.argv) < 3 or sys.argv[1].lower() in ["h","-h","help","-help"]:
	print("usage: {} <db_path> <images_path> [<\"-force-hash-check\">]".format(sys.argv[0]))
	print("where:")
	print("    db_path     - sqlite 3 database file path to write to (may or may not yet exist)")
	print("    images_path - may be directory or a single .jpg image file")
	sys.exit(0)

db_path = sys.argv[1]
images_path = Path(sys.argv[2])
hash_check = False

for arg_value in sys.argv[3:]:
	if arg_value == "-force-hash-check":
		hash_check = True

if Path(db_path).is_dir():
	print("<db_path> is a directory, but must be a regular file", file=sys.stderr)
	sys.exit(1)

if not images_path.exists():
	print("<images_path> does not exist", file=sys.stderr)
	sys.exit(1)

gps_locations = {}
#loc_names_to_check_proximity = ["loc_home_1"]

with open(loc_csv_path) as csvfile:
	reader = csv.DictReader(csvfile)
	for row in reader:
		for k in row:
			if len(row[k].strip()) == 0:
				print("a row in the locations csv file is missing data for [{}]: no columns may be blank".format(k), file=sys.stderr)
				sys.exit(1)
		loc_name = row["photos column"]
		gps_locations[loc_name] = {}
		gps_locations[loc_name]["lat"] = float(row["lat"])
		gps_locations[loc_name]["lon"] = float(row["lon"])
		gps_locations[loc_name]["note"] = row["note"]
		# ~69 miles for every degree of latitude/longitude
		degree_lat_lon_radius = float(row["miles radius"]) / 69.0
		# using dumb pythogorean method, we can leave hypotenuse squared
		#   to compare distances
		degree_lat_lon_radius_sq = degree_lat_lon_radius * degree_lat_lon_radius
		gps_locations[loc_name]["dist_degrees_sq"] = degree_lat_lon_radius_sq

# allow single file to be specified
#if not images_path.is_dir():
#	print("images_path is not a directory", file=sys.stderr)


def create_tables_as_needed(conn, curs):
	curs.execute('''
		CREATE TABLE IF NOT EXISTS photos (
			file_name TEXT PRIMARY KEY,
			md5_first_4_hex TEXT NOT NULL,
			date_str TEXT NOT NULL,
			year INTEGER NOT NULL,
			stars INTEGER NOT NULL,
			favorite INTEGER NOT NULL,
			loc_lat REAL DEFAULT 0,
			loc_lon REAL DEFAULT 0
		)''')
	curs.execute('''
		CREATE TABLE IF NOT EXISTS photo_species (
			file_name TEXT NOT NULL,
			name TEXT NOT NULL,
			sex TEXT DEFAULT 'unk' NOT NULL,
			incidental INTEGER DEFAULT 0
		)''')
	curs.execute('''
		CREATE TABLE IF NOT EXISTS photo_species_overrides (
			file_name TEXT NOT NULL,
			name TEXT NOT NULL,
			orig_name TEXT NOT NULL,
			sex TEXT DEFAULT 'unk' NOT NULL,
			orig_sex TEXT NOT NULL,
			incidental INTEGER DEFAULT 0,
			orig_incidental INTEGER NOT NULL
		)''')
	curs.execute('''
		CREATE TABLE IF NOT EXISTS photo_locations (
			file_name TEXT NOT NULL,
			location_name TEXT NOT NULL
		)''')
	curs.execute('''
		CREATE TABLE IF NOT EXISTS photo_locations_overrides (
			file_name TEXT NOT NULL,
			location_name TEXT NOT NULL,
			orig_location_name TEXT NOT NULL
		)''')
	curs.execute('''
		CREATE TABLE IF NOT EXISTS photo_ratings_overrides (
			file_name TEXT NOT NULL,
			stars INTEGER NOT NULL,
			favorite INTEGER NOT NULL
		)''')
	conn.commit()

# do we need to check the photo_species table too?
def is_image_in_db(conn, curs, the_id):
	curs.execute("SELECT * FROM photos WHERE file_name = ? LIMIT 1", [the_id])
	return curs.fetchone() is not None

def is_image_hash_changed(conn, curs, the_id, tags):
	curs.execute("SELECT md5_first_4_hex FROM photos WHERE file_name = ? LIMIT 1", [the_id])
	return curs.fetchone()[0] != tags['Composite:MD5'][0:4]

def delete_image_from_db(conn, curs, the_id):
	curs.execute("DELETE FROM photos WHERE file_name = ?", [the_id])
	curs.execute("DELETE FROM photo_species WHERE file_name = ?", [the_id])
	curs.execute("DELETE FROM photo_locations WHERE file_name = ?", [the_id])
	# not doing commit here

def read_tags_from_image(the_path):
	# Composite:MD5 is a custom tag created with, and populated
	#   according to, the ExifTool config file
	# since we are reading only 1 file, we know we can just grab
	#   the first (0th) item in the returned list
	return exif.get_tags(str(the_path), [
		"Composite:SubSecDateTimeOriginal",
		"XMP:DateTimeOriginal",
		"EXIF:DateTimeOriginal",
		"XMP:Subject",
		"Composite:GPSLatitude",
		"Composite:GPSLongitude",
		"Composite:MD5"])[0]

def write_image_to_db(conn, curs, exif, the_id, tags):
	the_date = None
	for date_tag in ["Composite:SubSecDateTimeOriginal", "XMP:DateTimeOriginal", "EXIF:DateTimeOriginal"]:
		if date_tag in tags:
			the_date = tags[date_tag]
			break
	if the_date is None:
		print("none of the expected date tags for image [{}] were found, stopping now".format(the_id), file=sys.stderr)
		sys.exit(1)

	the_stars = 1
	is_favorite = 0
	if "XMP:Subject" in tags:
		for keyword in tags["XMP:Subject"]:
			if keyword.startswith("stars:"):
				the_stars = int(keyword[6:])
			elif keyword == "favorite":
				is_favorite = 1

	the_lat = 0.0
	the_lon = 0.0
	# do simple pythagorean distance check (won't work accurately for large radii)
	if "Composite:GPSLatitude" in tags and "Composite:GPSLongitude" in tags:
		the_lat = float(tags["Composite:GPSLatitude"])
		the_lon = float(tags["Composite:GPSLongitude"])
		for loc_name in gps_locations:
			loc_radius_sq = gps_locations[loc_name]["dist_degrees_sq"]
			distance_from_loc = \
				(the_lat - gps_locations[loc_name]["lat"])**2 + \
				(the_lon - gps_locations[loc_name]["lon"])**2
			if distance_from_loc <= loc_radius_sq:
				print("image [{}] is a match for [{}]({})".format(the_id, gps_locations[loc_name]["note"], loc_name))
				curs.execute('INSERT INTO photo_locations (file_name, location_name) VALUES (?, ?)', (the_id, loc_name))

	curs.execute('''INSERT INTO photos
		(file_name, md5_first_4_hex, date_str, year, stars, favorite, loc_lat, loc_lon) VALUES
		(?, ?, ?, ?, ?, ?, ?, ?)''',
		(the_id,
		tags['Composite:MD5'][0:4],
		the_date,
		int(the_date[0:4]),
		the_stars,
		is_favorite,
		the_lat,
		the_lon
		))

	# first read through tags to find "species-sex:" pairs
	# then, read through tags again to find "species:" tags
	#   without an associated "species-sex:" tag, and set
	#   those to the default sex of "unk"
	species_sex_tags = {}
	if "XMP:Subject" in tags:
		for keyword in tags["XMP:Subject"]:
			if keyword.startswith("species-sex:"):
				species = 'unk'
				sex = 'unk'

				# "species-sex:Varied Thrush:female" -> ":female"
				if keyword[-7:] == ":female":
					# "species-sex:Varied Thrush:female" -> "Varied Thrush"
					species = keyword[12:-7]
					sex = "female"
				# "species-sex:Varied Thrush:male" -> ":male"
				elif keyword[-5:] == ":male":
					# "species-sex:Varied Thrush:male" -> "Varied Thrush"
					species = keyword[12:-5]
					sex = "male"
				# "species-sex:Varied Thrush:unk" -> ":unk"
				elif keyword[-4:] == ":unk":
					# "species-sex:Varied Thrush:unk" -> "Varied Thrush"
					species = keyword[12:-4]
					sex = "unk"

				if species == 'unk':
					print("unknown sex for this keyword tag (expected male/female/unk): {}".format(keyword))
					continue

				if not species in species_sex_tags:
					species_sex_tags[species] = set()

				# if for some reason (by mistake?) the same sex is
				#   tagged with both :male and :unk, or both
				#   :female and :unk, then we won't track the :unk
				if sex == "female" or sex == "male":
					try:
						species_sex_tags[species].remove('unk')
					except KeyError:
						pass

				# if this new tag is ":unk" sex, and we've already
				#   seen a :female or :male or :unk, then we don't
				#   need to track this :unk
				if sex == "unk" and len(species_sex_tags[species]) > 0:
					continue

				species_sex_tags[species].add(sex)

		for keyword in tags["XMP:Subject"]:
			if keyword.startswith("species:"):
				species = keyword[8:]
				if not species in species_sex_tags or len(species_sex_tags[species]) == 0:
					species_sex_tags[species] = {'unk'}


	species_sex_params = []
	for species, sexes in species_sex_tags.items():
		for sex in sexes:
			species_sex_params.append((the_id, species, sex))

	curs.executemany('''INSERT INTO photo_species
		(file_name, name, sex, incidental) VALUES
		(?, ?, ?, 0)''',
		species_sex_params)

	# not doing commit here

# perform glob pattern match on the given path for each of
#   the given patterns
def multi_glob(from_path, glob_patterns):
	for p in glob_patterns:
		for x in from_path.glob(p):
			yield x

with sqlite3.connect(db_path) as conn, exiftool.ExifToolHelper(config_file=exiftool_config_path) as exif:
	curs = conn.cursor()
	create_tables_as_needed(conn, curs)
	total_photos_count = 0
	if not images_path.is_dir():
		total_photos_count = 1
		if not images_path.suffix == ".jpg":
			print("<images_path> does not end with .jpg, so stopping")
			sys.exit(1)
		print("===== handling photo {}".format(total_photos_count))
		image_id = str(images_path.name)
		tags = read_tags_from_image(images_path)
		if is_image_in_db(conn, curs, image_id):
			if not hash_check:
				print("<images_path> is already in the db, and -force-hash-check is not active, so stopping")
				sys.exit(0)
			if is_image_hash_changed(conn, curs, image_id, tags):
				delete_image_from_db(conn, curs, image_id)
			else:
				print("<images_path> is already in the db and its hash has not changed")
				sys.exit(0)
		print("writing data to db from image [{}]".format(images_path))
		write_image_to_db(conn, curs, exif, image_id, tags)
	else:
		# match any .jpg, except for files named like -sm.jpg
		# thanks to https://stackoverflow.com/a/243902/259456
		for image_path in multi_glob(images_path, ['**/*[!s][!m].jpg', '**/*[!s][!m].jpeg', '**/*[!s][!m].heif', '**/*[!s][!m].heic']):
			total_photos_count += 1
			print("===== handling photo {}".format(total_photos_count))
			image_id = image_path.name
			tags = read_tags_from_image(image_path)
			if is_image_in_db(conn, curs, image_id):
				if not hash_check:
					print("[{}] is already in the db, and -force-hash-check is not active, so skipping".format(image_path))
					continue
				if is_image_hash_changed(conn, curs, image_id, tags):
					delete_image_from_db(conn, curs, image_id)
				else:
					print("[{}] is already in the db and its hash has not changed".format(image_path))
					continue
			print("writing data to db from image [{}]".format(image_path))
			write_image_to_db(conn, curs, exif, image_id, tags)
			conn.commit()


# do directory traversal on images_path
# any .jpg .jpeg .JPG .JPEG file (not -sm.jpg) will be checked
#   - use first 4 chars of file hash to see if db row needs to be updated
#   - by default, don't check hash for files already in db -- only do that when a special flag is set as CLI arg

# use simple distance calculated from lat/long to see if it's a "home" image

# for geographic location, all i care about, for now, is:
#   - home

# "photo" table columns
# - file_name (file name) (text, unique)
# - md5_first_4_hex (text)
# - date_str (ugh what timezone? maybe local, since i'm never able to travel faster than the earth spins)
# - year (int)
# - stars (int)
# - favorite (boolean)
# - loc_lat
# - loc_lon

# "species" table columns
# - file_name (text, same as photo.name, not unique)
# - name (text)
# - sex (default to "unk")
# - incidental (boolean, default to false)

# - photo.favorite
#   - maybe favorite can count as 2 additional stars
#   - so when sorting images for a species by rating, use stars plus 2 if favorite
#     - also sort by date, so newer "best" images are displayed
# - species.incidental
#   - to query for photos featuring species X, make sure to use query for "species==X" and "incidental==false"
#   - manually (with separate script?) entered, for individual photos since so few contain several species