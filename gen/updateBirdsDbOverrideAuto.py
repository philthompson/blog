# python 3
#
# keeps the species the same, but changes the sex for every image in
#   the given folder
#

import sys
import sqlite3
from pathlib import Path

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

if len(sys.argv) < 4 or sys.argv[1].lower() in ["h","-h","help","-help"] or sys.argv[3] not in ['male', 'female']:
	print('usage: {} <db_path> <folder_path> <male|female>'.format(sys.argv[0]))
	sys.exit(1)

db_path = sys.argv[1]
folder_path = Path(sys.argv[2])
new_sex = sys.argv[3]

if not Path(db_path).is_file():
	print('given <db_path> does not exist or is not a regular file', file=sys.stderr)
	sys.exit(1)

if not folder_path.is_dir():
	print('given <folder_path> does not exist or is not a folder', file=sys.stderr)
	sys.exit(1)

# perform glob pattern match on the given path for each of
#   the given patterns
def multi_glob(from_path, glob_patterns):
	for p in glob_patterns:
		for x in from_path.glob(p):
			yield x

def is_image_in_db(curs, the_id):
	curs.execute("SELECT * FROM photo_species_overrides WHERE file_name = ? LIMIT 1", [the_id])
	return curs.fetchone() is not None

#def read_species_from_image(the_path):
#	species_sex_tags = {}
#
#	# since we are reading only 1 file, we know we can just grab
#	#   the first (0th) item in the returned list
#	tags = exif.get_tags(str(the_path), ["XMP:Subject"])[0]
#
#	# first read through tags to find "species-sex:" pairs
#	# then, read through tags again to find "species:" tags
#	#   without an associated "species-sex:" tag, and set
#	#   those to the default sex of "unk"
#	if "XMP:Subject" in tags:
#		for keyword in tags["XMP:Subject"]:
#			# for now... only allow "male" and "female" to
#			#   be specified... things like "unk" or "immature"
#			#   or whatever may have to be dealt with later
#			if keyword.startswith("species-sex:"):
#				if keyword[-7:] == ":female":
#					# "species-sex:Varied Thrush:female" -> "Varied Thrush" and "female"
#					species_sex_tags[keyword[12:-7]] = keyword[-6:]
#				elif keyword[-5:] == ":male":
#					# "species-sex:Varied Thrush:male" -> ":male"
#					species_sex_tags[keyword[12:-5]] = keyword[-4:]
#		for keyword in tags["XMP:Subject"]:
#			if keyword.startswith("species:"):
#				# "species:Varied Thrush" -> "Varied Thrush"
#				species = keyword[8:]
#				if not species in species_sex_tags :
#					species_sex_tags[species] = ':unk'
#
#	return species_sex_tags

def read_species_from_image(the_path):
	species_sex_tags = {}

	# since we are reading only 1 file, we know we can just grab
	#   the first (0th) item in the returned list
	tags = exif.get_tags(str(the_path), ["XMP:Subject"])[0]

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
				the_species = None
				the_sex = None
				if keyword[-7:] == ":female":
					# "species-sex:Varied Thrush:female" -> "Varied Thrush" and "female"
					the_species = keyword[12:-7]
					the_sex = keyword[-6:]
				elif keyword[-5:] == ":male":
					# "species-sex:Varied Thrush:male" -> ":male"
					the_species = keyword[12:-5]
					the_sex = keyword[-4:]
				if the_species is not None and the_sex is not None:
					if not the_species in species_sex_tags:
						species_sex_tags[the_species] = []
					species_sex_tags[the_species].append(the_sex)
		for keyword in tags["XMP:Subject"]:
			if keyword.startswith("species:"):
				# "species:Varied Thrush" -> "Varied Thrush"
				species = keyword[8:]
				if not species in species_sex_tags:
					species_sex_tags[species] = ['unk']

	return species_sex_tags

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

with sqlite3.connect(db_path) as conn, exiftool.ExifToolHelper() as exif:
	curs = conn.cursor()

	# match any .jpg, except for files named like -sm.jpg
	# thanks to https://stackoverflow.com/a/243902/259456
	for image_path in multi_glob(folder_path, ['**/*[!s][!m].jpg', '**/*[!s][!m].jpeg', '**/*[!s][!m].heif', '**/*[!s][!m].heic']):
		#print("===== handling photo {}".format(total_photos_count))
		image_id = image_path.name

		if is_image_in_db(curs, image_id):
			print('photo [{}] is already overridden, so it must be overridden with the interactive version of this script'.format(image_id), file=sys.stderr)
			continue

		species_sex_tags = read_species_from_image(image_path)

		orig_species = None
		orig_sex = None
		total_species_sex = 0

		for k,v in species_sex_tags.items():
			orig_species = k
			for x in v:
				total_species_sex += 1
				orig_sex = x

		if total_species_sex != 1:
			print('given [{}] does not have exactly one species-sex tagged, so it must be overridden with the interactive version of this script'.format(image_id), file=sys.stderr)
			continue
		if orig_species is None or orig_sex is None:
			print('given [{}] does not have exactly one species-sex tagged, so it must be overridden with the interactive version of this script'.format(image_id), file=sys.stderr)
			continue

		new_species = orig_species
		new_incidental = 'n'

		print('[{}] -> {} ({})'.format(image_id, new_species, new_sex))
		write_override_to_db(curs, image_id, orig_species, orig_sex, new_species, new_sex, new_incidental)

	conn.commit()
