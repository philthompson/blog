# python 3
#
# use this script when a species is renamed by the
#   scientific community.  the first example of this
#   is "Pacific-slope Flycatcher" being renamed
#   "Western Flycatcher (Pacific-slope)" in 2023ish.
#
# this runs two queries:
# - one to update any existing overrides that set
#     the <current-species-name>, and
# - one that creates new overrides for photos tagged
#   with <current-species-name>
#
# this should work in the case where a species,
#   originally named "A," is first renamed to "B" and
#   later renamed to "C"
#
# if multiple subspecies for a single renamed species need to
#   be changed, they will probably need to be done individually
#
# this will first ask whether a --dry-run was done
#
# a --dry-run will print out everything to be done
#

import sys
import sqlite3
from pathlib import Path

DRY_RUN_FLAG = "--dry-run"

if len(sys.argv) < 4 or sys.argv[1].lower() in ["h","-h","help","-help"]:
	print(f'usage: {sys.argv[0]} [{DRY_RUN_FLAG}] <db_path> <current-species-name> <new-species-name>')
	sys.exit(1)

do_dry_run = False
if DRY_RUN_FLAG in sys.argv:
	do_dry_run = True
	del sys.argv[sys.argv.index(DRY_RUN_FLAG)]

db_path = sys.argv[1]
cur_species = sys.argv[2]
new_species = sys.argv[3]

if not Path(db_path).is_file():
	print('given <db_path> does not exist or is not a regular file', file=sys.stderr)
	sys.exit(1)

def find_overrides_that_set_current(curs, current_species):
	curs.execute('''
		SELECT
			o.file_name,
			o.orig_name
		FROM
			photo_species_overrides o
		WHERE
			o.name = :current_species_name
		''', {'current_species_name': current_species})

def change_overrides_that_set_current(curs, current_species, new_species):
	curs.execute('''
		UPDATE
			photo_species_overrides
		SET
			name = :new_species_name
		WHERE
			name = :current_species_name
		''', {'current_species_name': current_species, 'new_species_name': new_species})

def find_tags_that_set_current(curs, current_species, new_species):
	curs.execute("""
		SELECT
			s.file_name,
			:new_species_name AS name,
			s.name AS orig_name,
			s.sex,
			s.sex AS orig_sex,
			0 AS incidental,
			0 AS orig_incidental
		FROM
			photo_species s
		WHERE
			s.name = :current_species_name
		""", {'current_species_name': current_species, 'new_species_name': new_species})

def add_overrides_that_set_current(curs, current_species, new_species):
	curs.execute("""
		INSERT INTO
			photo_species_overrides
		SELECT
			s.file_name,
			:new_species_name AS name,
			s.name AS orig_name,
			s.sex,
			s.sex AS orig_sex,
			0 AS incidental,
			0 AS orig_incidental
		FROM
			photo_species s
		WHERE
			s.name = :current_species_name
		""", {'current_species_name': current_species, 'new_species_name': new_species})
	# not committing here

print(f'changing all photos and overrides for [{cur_species}] to [{new_species}]')

with sqlite3.connect(db_path) as conn:
	curs = conn.cursor()

	if do_dry_run:
		print('====-====-====-====-====-====-====-====-====-====-====')
		print(f'querying for existing overrides, that set species to [{cur_species}], to update:')
		find_overrides_that_set_current(curs, cur_species)
		any_found = False
		for row in curs.fetchall():
			any_found = True
			print(f'would update override for file [{row[0]}] for original species [{row[1]}]')
		if not any_found:
			print('(none found)')
		print('====-====-====-====-====-====-====-====-====-====-====')
		print(f'querying for files, with a species tag for [{cur_species}], to add overrides for:')
		find_tags_that_set_current(curs, cur_species, new_species)
		any_found = False
		for row in curs.fetchall():
			any_found = True
			print(f'would add override for file [{row[0]}] for original species [{row[2]}] sex [{row[3]}] incidental [{row[6]}] to\n new species [{row[1]}] new sex [{row[3]}] new incidental [{row[5]}]')
		if not any_found:
			print('(none found)')
	else:
		# first ensure no overrides exist that set the new name -- if so,
		#   refuse to proceed until those are deleted
		find_overrides_that_set_current(curs, new_species)
		any_found = False
		for row in curs.fetchall():
			any_found = True
			print(f'FATAL ERROR: please remove existing override for file [{row[0]}] that already sets new species [{row[1]}]')
			print('(note which orig_species was overridden, and after deleting the existing override row, run this script to create a new override for that orig_species)')
		if any_found:
			sys.exit(0)

		repeat_confirm = ''
		print('')
		while repeat_confirm != 'y' and repeat_confirm != 'n':
			repeat_confirm = input(f"WARNING do a {DRY_RUN_FLAG} first!  Has a {DRY_RUN_FLAG} been done?  proceed? [y/n]... >").strip()
		if repeat_confirm == 'n':
			sys.exit(0)
		repeat_confirm = ''
		print('')
		while repeat_confirm != 'y' and repeat_confirm != 'n':
			repeat_confirm = input(f"WARNING do backup of the database file first!  Has a backup of {Path(db_path).name} been made?  proceed? [y/n]... >").strip()
		if repeat_confirm == 'n':
			sys.exit(0)
		print('====-====-====-====-====-====-====-====-====-====-====')
		print(f'updating existing overrides that set species to [{cur_species}] to [{new_species}] instead')
		change_overrides_that_set_current(curs, cur_species, new_species)
		conn.commit()
		print('====-====-====-====-====-====-====-====-====-====-====')
		print(f'adding new overrides for photos tagged for [{cur_species}] to [{new_species}]')
		add_overrides_that_set_current(curs, cur_species, new_species)
		print('done')
		conn.commit()
