# python 3
#
# i think this overrides the sex only for a single photo file
#

import sys
import sqlite3
from pathlib import Path
import uuid
import base64

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

if len(sys.argv) < 4 or sys.argv[1].lower() in ["h","-h","help","-help"] or sys.argv[3] not in ['male', 'female', 'unk']:
	print('usage: {} <db_path> <photo_path> <male|female|unk>'.format(sys.argv[0]))
	print("where:")
	print("    db_path    - sqlite 3 database file path to write to (must exist)")
	print("    photo_path - (usually a .jpg file) the photo to set/update an override for")
	sys.exit(1)

db_path = sys.argv[1]
image_path = Path(sys.argv[2])
new_sex = sys.argv[3]

if not Path(db_path).is_file():
	print('given <db_path> does not exist or is not a regular file', file=sys.stderr)
	sys.exit(1)

if not image_path.is_file():
	print('given <photo_path> does not exist or is not a regular file', file=sys.stderr)
	sys.exit(1)

image_name = image_path.name

if image_path.stem.endswith('-sm'):
	print('given <photo_path> is a thumbnail (-sm) -- the full-size image is required', file=sys.stderr)
	sys.exit(1)

species_sex_tags = []

with exiftool.ExifToolHelper() as exif:
	# since we are reading only 1 file, we know we can just grab
	#   the first (0th) item in the returned list
	tags = exif.get_tags(str(image_path), ["XMP:Subject"])[0]

	# first read through tags to find "species-sex:" pairs
	# then, read through tags again to find "species:" tags
	#   without an associated "species-sex:" tag, and set
	#   those to the default sex of "unk"
	if "XMP:Subject" in tags:
		for keyword in tags["XMP:Subject"]:
			# for now... only allow "male" and "female" to
			#   be specified... things like "unk" or "immature"
			#   or whatever may have to be dealt with later
			if keyword.startswith("species-sex:"):
				# "species-sex:Varied Thrush:female" -> ":female"
				# "species-sex:Varied Thrush:male" -> ":male"
				if keyword[-7:] == ":female" or keyword[-5:] == ":male":
					# "species-sex:Varied Thrush:female" -> "Varied Thrush:female"
					species_sex_tags.append(keyword[12:])
		for keyword in tags["XMP:Subject"]:
			if keyword.startswith("species:"):
				# "species:Varied Thrush" -> "Varied Thrush"
				species = keyword[8:]
				if not (species + ':female') in species_sex_tags and not (species + ':male') in species_sex_tags:
					species_sex_tags.append(species + ':unk')

if len(species_sex_tags) != 1:
	print('given <photo_path> does not have exactly one species-sex already, so it must be overridden with the interactive version of this script', file=sys.stderr)
	sys.exit(1)

# for reference, the table is defined as:
#	curs.execute('''
#		CREATE TABLE IF NOT EXISTS photo_species_overrides (
#			file_name TEXT NOT NULL,
#			name TEXT NOT NULL,
#			orig_name TEXT NOT NULL,
#			sex TEXT DEFAULT 'unk' NOT NULL,
#			orig_sex TEXT NOT NULL,
#			incidental INTEGER DEFAULT 0,
#			orig_incidental INTEGER NOT NULL
#		)''')
def read_overrides_from_db(curs, the_id):
	curs.execute("""
		SELECT
			file_name,
			name,
			orig_name,
			sex,
			orig_sex,
			incidental,
			orig_incidental
		FROM photo_species_overrides WHERE file_name = ?""", [the_id])
	overrides = {}
	for row in curs.fetchall():
		row_dict = {
			'file_name': row[0],
			'name': row[1],
			'orig_name': row[2],
			'sex': row[3],
			'orig_sex': row[4],
			'incidental': row[5],
			'orig_incidental': row[6]}
		overrides[row_dict['orig_name'] + ':' + row_dict['orig_sex']] = row_dict
	return overrides

def delete_override_from_db(curs, the_id, orig_species, orig_sex):
	curs.execute("""
		DELETE FROM
			photo_species_overrides
		WHERE
			file_name = ? AND
			orig_name = ? AND
			orig_sex = ?""", [the_id, orig_species, orig_sex])
	# not committing here

def write_override_to_db(curs, the_id, orig_species, orig_sex, new_species, new_sex, new_incidental):
	new_incidental_int = 0
	if new_incidental == 'y':
		new_incidental_int = 1
	curs.execute("""
		INSERT INTO
			photo_species_overrides
		(file_name, name, orig_name, sex, orig_sex, incidental, orig_incidental)
		VALUES
		(?, ?, ?, ?, ?, ?, 0)""", [the_id, new_species, orig_species, new_sex, orig_sex, new_incidental_int])
	# not committing here

def generate_b64_uuid():
	# use uuid.uuid4() which generates random UUID
	# then encode to base64
	# then convert to utf-8 string and drop padding '=' chars
	return base64.b64encode(uuid.uuid4().bytes).decode('utf-8').replace('=', '')

with sqlite3.connect(db_path) as conn:
	curs = conn.cursor()

	overrides = read_overrides_from_db(curs, image_name)

	numbered_options = []

	for species_sex in species_sex_tags:
		overridden_with = '(not overridden)'
		if species_sex in overrides:
			overridden_with = overrides[species_sex]['name'] + ':' + overrides[species_sex]['sex']
			if overrides[species_sex]['incidental'] == '1':
				overridden_with += ' (incidental)'
		numbered_options.append('{} -> {}'.format(species_sex, overridden_with))

	orig_species = numbered_options[0].split(':')[0]
	new_species = orig_species
	orig_sex = 'unk'
	new_incidental = 'n'

	# review final things to write/overwrite:
	print('')
	print('review:')
	print('overriding {}'.format(numbered_options[0]))
	print("new species [{}]".format(new_species))
	print("new sex [{}]".format(new_sex))
	print("new incidental [{}]".format(new_incidental))

	final_confirm = ''
	while final_confirm != 'y' and final_confirm != 'n':
		final_confirm = input("is the above all correct? [y/n]... >").strip()

	if final_confirm == 'y':
		# DELETE from sqlite if an override row exists for the photo
		delete_override_from_db(curs, image_name, orig_species, orig_sex)

		if new_species == orig_species and new_sex == orig_sex and new_incidental == 'n':
			print("since overrides effectively eliminate the override, we just DELETEd the row and will not INSERT the override")
		else:
			# INSERT new override row
			write_override_to_db(curs, image_name, orig_species, orig_sex, new_species, new_sex, new_incidental)

		conn.commit()
