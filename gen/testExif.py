import sys
#import os
from pathlib import Path

import exiftool

#os.environ['EXIFTOOL_HOME'] = str(Path(__file__).parent)

exiftool_config_path = str(Path(__file__).parent.joinpath("ExifTool-config-md5"))

img_file = sys.argv[1]

with exiftool.ExifToolHelper(config_file=exiftool_config_path) as exif:
	#for d in exif.get_metadata(img_file):
	#  for k, v in d.items():
	#    print("{} => {}".format(k, v))
	#sys.exit(0)
	tags = exif.get_tags(img_file , [
		"Composite:SubSecDateTimeOriginal",
		"XMP:DateTimeOriginal",
		"EXIF:DateTimeOriginal",
		"XMP:Subject",
		"Composite:GPSLatitude",
		"Composite:GPSLongitude",
		"Composite:MD5"])[0]
	print(tags)
	print(tags['Composite:MD5'][0:4])
