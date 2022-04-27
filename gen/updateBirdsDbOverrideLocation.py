# python 3
#
# for overriding a dir of images all with the SAME given species
#

import sys
import sqlite3
from pathlib import Path
import uuid
import base64

if len(sys.argv) < 5 or sys.argv[1].lower() in ["h","-h","help","-help"]:
	print('usage: {} <db_path> <image_path> <orig_location|"absent"> <new_location>'.format(sys.argv[0]))
	sys.exit(1)

db_path = sys.argv[1]
image_path = Path(sys.argv[2])

if not Path(db_path).is_file():
	print('given <db_path> does not exist or is not a regular file', file=sys.stderr)
	sys.exit(1)

if not image_path.is_file():
	print('given <image_path> does not exist or is not a regular file', file=sys.stderr)
	sys.exit(1)

the_id = image_path.name
orig_location = sys.argv[3]
new_location = sys.argv[4]

def generate_b64_uuid():
	# use uuid.uuid4() which generates random UUID
	# then encode to base64
	# then convert to utf-8 string and drop padding '=' chars
	return base64.b64encode(uuid.uuid4().bytes).decode('utf-8').replace('=', '')

with sqlite3.connect(db_path) as conn:
	curs = conn.cursor()

	curs.execute("DELETE FROM photo_locations_overrides WHERE file_name = ? AND orig_location_name = ?", [the_id, orig_location])

	if orig_location == "absent":
		orig_location = 'absent-' + generate_b64_uuid()

	curs.execute("""
		INSERT INTO
			photo_locations_overrides
		(file_name, location_name, orig_location_name)
		VALUES
		(?, ?, ?)""", [the_id, new_location, orig_location])

	conn.commit()
