# python 3
#
# sqlite3 module
# https://docs.python.org/3/library/sqlite3.html

import sys
import os
import csv
import sqlite3
from datetime import date
from pathlib import Path
from pathlib import PurePosixPath
import inspect

# possible required arg: first/best/favorites/last
#   (each of these would output to a different static page)

if len(sys.argv) < 4 or sys.argv[1].lower() in ["h","-h","help","-help"]:
	print('usage: {} <db_path> <year|"all"> <location-column|"all">'.format(sys.argv[0]))
	print("where:")
	print("    db_path         - sqlite 3 database file path to write to (may or may not yet exist)")
	print('    year            - year to filter photos by, or "all"')
	print('    location-column - location to filter photos by, like "loc_home_1", or "all" (see gen/loc_names_locations.csv)')
	sys.exit(1)

# the full path to the locations csv file in this directory
loc_csv_path = str(Path(__file__).parent.joinpath("loc_names_locations.csv"))

location_aliases = {}

with open(loc_csv_path) as csvfile:
	reader = csv.DictReader(csvfile)
	for row in reader:
		col_name = row["photos column"]
		public_alias = row["public alias"]
		if len(col_name.strip()) == 0 or len(public_alias.strip()) == 0:
			print("locations CSV has an empty column -- all columns must be non-empty", file=sys.stderr)
			sys.exit(1)
		location_aliases[col_name] = public_alias

db_path = sys.argv[1]

first_by_species = {}
last_by_species = {}
best_by_species = {}
favorite_by_species = {}

where_clause = ''
where_clause_values = {}

plain_year = sys.argv[2]
title_year = ''
title_pronoun = "I've"
title_location = ''
# 2022-05-15: try sorting by date for all rollups
#title_sort = 'sorted by species'
#should_sort_by_date = False
title_sort = 'sorted by date'
should_sort_by_date = True

if plain_year != "all":
	title_year = ' in ' + plain_year
	title_sort = 'sorted by date'
	should_sort_by_date = True
	where_clause = "p.year = :filter_year"
	where_clause_values["filter_year"] = int(plain_year)
	if date.today().year > int(plain_year):
		title_pronoun = "I"

output_all_favs = False

if sys.argv[3] == "fav":
	output_all_favs = True
elif sys.argv[3] != "all":
	if not sys.argv[3] in location_aliases:
		print("given <location-column> value [{}] is not recognized".format(sys.argv[3]), file=sys.stderr)
		sys.exit(1)
	if plain_year != "all":
		where_clause += ' AND'
	title_location = ' at ' + location_aliases[sys.argv[3]]
	where_clause += ' l.location_name = :filter_location'
	where_clause_values['filter_location'] = sys.argv[3]

if len(where_clause) > 0:
	where_clause = 'WHERE ' + where_clause

# the photo_species_overrides table is always used first, to
#   correct/update photo species/sex/incidental metadata

#SELECT * FROM photo_species s LEFT OUTER JOIN photo_species_overrides o ON s.file_name = o.file_name AND s.name = o.orig_name AND s.sex = o.orig_sex AND s.incidental = o.orig_incidental

# since some species have a " (subspecies)" at the end, we want to
#   create another row where the subspecies is removed
# this allows us to see, for example, the first Yellow-rumped Warbler
#   photo, as well as the first Yellow-rumped Warbler (Myrtle), as
#   well as the first Yellow-rumped Warbler (Audobon's)
# to remove the space-paren-text-paren from the end of the string,
#   we will use this inelegant sqlite:
# SUBSTR(name, INSTR(name, '(') - 1, -500) AS name
# (the substring function in sqlite does not trim from position to
#   position -- instead, if the last function parameter is negative,
#   it counts backwards from the position given by the 2nd parameter
#   that many characters.  so as long as a species name is less than
#   500 characters long, this will return all characters from the
#   beginning of the string until the space before the open paren)
def run_query(conn, curs, photos_p_where_clause):
	curs.execute('''
		WITH apply_species_sex_overrides AS (
			SELECT
				s.file_name,
				COALESCE(o.name, s.name) AS name,
				COALESCE(o.sex, s.sex) AS sex,
				COALESCE(o.incidental, s.incidental) AS incidental
			FROM
				photo_species s
			LEFT OUTER JOIN
				photo_species_overrides o
			ON
				s.file_name = o.file_name AND
				s.name = o.orig_name AND
				s.sex = o.orig_sex AND
				s.incidental = o.orig_incidental
			UNION
			SELECT
				o.file_name,
				o.name,
				o.sex,
				o.incidental
			FROM
				photo_species_overrides o
			WHERE
				o.orig_name LIKE 'absent-%'
		),
		apply_locations_overrides AS (
			SELECT
				l.file_name,
				COALESCE(o.location_name, l.location_name) AS location_name
			FROM
				photo_locations l
			LEFT OUTER JOIN
				photo_locations_overrides o
			ON
				l.file_name = o.file_name AND
				l.location_name = o.orig_location_name
			UNION
			SELECT
				o.file_name,
				o.location_name
			FROM
				photo_locations_overrides o
			WHERE
				o.orig_location_name LIKE 'absent-%'
		),
		photos_with_ratings AS (
			SELECT
				p.file_name,
				p.date_str,
				p.year,
				COALESCE(r.stars, p.stars) AS stars,
				COALESCE(r.favorite, p.favorite) AS favorite
			FROM
				photos p
			LEFT OUTER JOIN
				photo_ratings_overrides r
			ON
				p.file_name = r.file_name
		),
		photos_with_locations AS (
			SELECT
				p.*,
				COALESCE(l.location_name, 'x') AS location_name
			FROM
				photos_with_ratings p
			LEFT OUTER JOIN
				apply_locations_overrides l
			ON
				p.file_name = l.file_name
			{photos_p_where_clause}
		),
		species_and_subspecies AS (
			SELECT
				file_name,
				name,
				sex
			FROM
				apply_species_sex_overrides
			WHERE
				incidental = 0
			UNION
			SELECT
				file_name,
				SUBSTR(name, INSTR(name, '(') - 1, -500) AS name,
				sex
			FROM
				apply_species_sex_overrides
			WHERE
				incidental = 0 AND
				name LIKE '% (%)'
		),
		species_and_subspecies_and_sex AS (
			SELECT
				file_name,
				name
			FROM
				species_and_subspecies
			UNION
			SELECT
				file_name,
				name || ' (' || sex || ')' AS name
			FROM
				species_and_subspecies
			WHERE
				sex <> 'unk'	
		),
		/* this is used for the favorites pages, where we don't want
		   species names to be repeated once without (sex) and once
		   with (sex) -- instead, we append (sex) only if the sex
		   is not "unk" */
		species_and_sex_no_subspecies AS (
			SELECT
				file_name,
				name
			FROM
				apply_species_sex_overrides
			WHERE
				sex = 'unk' AND
				incidental = 0
			UNION
			SELECT
				file_name,
				name || ' (' || sex || ')' AS name
			FROM
				apply_species_sex_overrides
			WHERE
				sex <> 'unk' AND
				incidental = 0
		),
		first_per_species AS (
			SELECT
				file_name,
				name,
				RANK() OVER (
					PARTITION BY name
					ORDER BY file_name ASC
				) date_rank
			FROM (
				SELECT
					p.file_name,
					s.name
				FROM
					photos_with_locations p
				INNER JOIN
					species_and_subspecies_and_sex s
				ON
					p.file_name = s.file_name
			)
		),
		last_per_species AS (
			SELECT
				file_name,
				name,
				RANK() OVER (
					PARTITION BY name
					ORDER BY file_name DESC
				) date_rank
			FROM (
				SELECT
					p.file_name,
					s.name
				FROM
					photos_with_locations p
				INNER JOIN
					species_and_subspecies_and_sex s
				ON
					p.file_name = s.file_name
			)
		),
		best_per_species AS (
			SELECT
				file_name,
				name AS species,
				year,
				date_str,
				stars,
				favorite,
				RANK() OVER (
					PARTITION BY name
					ORDER BY score DESC, favorite DESC, file_name DESC
				) score_rank
			FROM (
				SELECT
					p.file_name,
					s.name,
					p.year,
					p.date_str,
					p.stars,
					p.favorite,
					(p.favorite * 2) + p.stars AS score
				FROM
					photos_with_locations p
				INNER JOIN
					species_and_subspecies_and_sex s
				ON
					p.file_name = s.file_name
			)
		),
		/* this is only used for favorites pages */
		all_favorites AS (
			SELECT
				p.file_name,
				s.name AS species,
				p.year,
				p.date_str,
				p.stars,
				p.favorite
			FROM
				photos_with_locations p
			INNER JOIN
				species_and_sex_no_subspecies s
			ON
				p.file_name = s.file_name
			WHERE
				p.favorite = 1
		)
		SELECT
			'first' AS rollup,
			p.file_name,
			f.name AS species,
			p.year,
			p.date_str,
			p.stars,
			p.favorite
		FROM
			first_per_species f
		INNER JOIN
			photos_with_locations p
		ON
			p.file_name = f.file_name
		WHERE
			f.date_rank = 1
		UNION ALL
		SELECT
			'last' AS rollup,
			p.file_name,
			l.name AS species,
			p.year,
			p.date_str,
			p.stars,
			p.favorite
		FROM
			last_per_species l
		INNER JOIN
			photos_with_locations p
		ON
			p.file_name = l.file_name
		WHERE
			l.date_rank = 1
		UNION ALL
		SELECT
			'best' AS rollup,
			file_name,
			species,
			year,
			date_str,
			stars,
			favorite
		FROM
			best_per_species
		WHERE
			score_rank = 1
		UNION ALL
		SELECT
			'fav' AS rollup,
			file_name,
			GROUP_CONCAT(species, ', ') AS species,
			year,
			date_str,
			stars,
			favorite
		FROM
			all_favorites
		GROUP BY
			file_name,
			year,
			date_str,
			stars,
			favorite
		ORDER BY
			file_name
		'''.format(photos_p_where_clause=photos_p_where_clause), where_clause_values)

def print_header():
	title="Birds {title_pronoun} Photographed{title_year}{title_location}".format(title_pronoun=title_pronoun, title_year=title_year, title_location=title_location)
	description="Bird species {title_pronoun} Photographed{title_year}{title_location}".format(title_pronoun=title_pronoun, title_year=title_year, title_location=title_location)
	if output_all_favs:
		title="My Favorite Bird Photos of {year}".format(year=plain_year)
		description="All my favorite bird photos of {year}, in date order".format(year=plain_year)


	# thanks to https://stackoverflow.com/a/48112903/259456	
	print(inspect.cleandoc("""

		<!-- this file is generated by generateBirdsPage.py to markdown, and build.sh to html -->
		
		[//]: # (gen-title: {title})
		
		[//]: # (gen-keywords: birds, birding, photography)
		
		[//]: # (gen-description: {description}.)
		
		[//]: # (gen-meta-end)
		
		<style>
			.img-container {{
				padding-top: 1.0rem;
				padding-bottom: 1.0rem;
				border-top: 1px solid #949b96;
			}}
			details, details summary {{
				display: inline;
			}}
			details summary img {{
				max-height: 25rem;
			}}
			details summary p {{
				margin-top: 0.1rem;
			}}
			details > summary::marker, details:not(.visible-collapse-marker) > summary::-webkit-details-marker {{
				display: none;
			}}
			details summary {{
				list-style: none;
			}}
			details[open] {{
				display: block;
				margin-left: auto;
				margin-right: auto;
				max-width: 100%;
				padding-top: 1.0rem;
				padding-bottom: 1.0rem;
				border-top: 1px solid #949b96;
				border-bottom: 1px solid #949b96;
			}}
			details[open] div.details-inner img {{
				max-width: 25rem;
				padding-right: 1.5rem;
			}}
			#loc {{
				word-wrap: break-word;
			}}
			@media screen and (min-width: 64rem) {{
				.width-resp-50-100 {{
					padding-left: 1.25%;
					padding-right: 1.25%;
					max-width: 30%;
				}}
			}}
			@media screen and (min-width: 104rem) {{
				.width-resp-50-100 {{
					padding-left: 1.2%;
					padding-right: 1.2%;
					max-width: 22%;
				}}
			}}
			.wide-override {{
				width: 100%
			}}
			@media screen and (min-width: 48rem) {{
				.wide-override {{
					width: 47rem;
					left: 50%;
					position: relative;
					transform: translateX(-50%);
				}}
			}}
			@media screen and (min-width: 54rem) {{
				.wide-override {{ width: 52rem; }}
			}}
			@media screen and (min-width: 64rem) {{
				.wide-override {{ width: 61rem; }}
			}}
			@media screen and (min-width: 74rem) {{
				.wide-override {{ width: 70rem; }}
			}}
			@media screen and (min-width: 84rem) {{
				.wide-override {{ width: 80rem; }}
			}}
			@media screen and (min-width: 94rem) {{
				.wide-override {{ width: 90rem; }}
			}}
			@media screen and (min-width: 104rem) {{
				.wide-override {{ width: 98rem; }}
			}}
			.btns {{
				margin: 1rem 0;
			}}
			.species-label {{
				padding-top: 1.0rem;
				margin-bottom: 0.25rem;
			}}
		</style>
		
		## {title}
		""".format(title=title, description=description, title_pronoun=title_pronoun, title_year=title_year, title_location=title_location, title_sort=title_sort)))

def image_sm_version(image_filename):
	p = PurePosixPath(image_filename)
	# evidently, my oldest .jpeg files, when scaled down
	#   for the -sm thumbnails, were named -sm.jpg not
	#   -sm.jpeg
	#return p.stem + '-sm' + p.suffix
	return p.stem + '-sm.jpg'

def format_stars(stars, is_favorite):
	num_stars = int(stars)
	# thanks to https://stackoverflow.com/a/3391106/259456
	stars_formatted = ('★' * min(5, num_stars)) + ('☆' * min(5, (5 - num_stars)))
	if bool(is_favorite):
		stars_formatted += ' (favorite)'
	return stars_formatted

# date_str expected to be like: '2022:03:14 14:13:50.15'
# thanks to https://stackoverflow.com/a/2073189/259456 for
#   showing how to remove zero padding from day of month
def format_date_day(date_str):
	return date.fromisoformat(date_str[0:10].replace(':', '-')).strftime('%B %-d, %Y')

# date_str expected to be like: '2022:03:14 14:13:50.15'
def format_date_day_no_year(date_str):
	return date.fromisoformat(date_str[0:10].replace(':', '-')).strftime('%B %-d')

top_level_species = set()

def print_favorite_photo(photo):
	year = photo['year']
	img = image_sm_version(photo['file_name'])
	date = format_date_day_no_year(photo['date_str'])
	species = photo['species']
	stars = format_stars(photo['stars'], 0)
	print(inspect.cleandoc("""
	<details class="width-resp-50-100">
		<summary>
			<img class="width-100" src="https://philthompson.me/s/img/{year}/{img}"/>
			<p><span class="alt-text">{date}:</span> {species}</p>
		</summary>
		<p class="article-info">(Click above image to re-collapse.)</p>
		<!--<div class="details-inner">
			<p>{date}</p>
			<p>{stars}</p>
		</div>-->
	</details>
	""".format(year=year, img=img, species=species, date=date, stars=stars)))

def print_collapsable_item(species):
	# if this is not a "top level" species name (it
	#   has a subspecies or sex in parens, or both)
	#   then this function does nothing and just returns
	top_level_name = species.split('(')[0].strip()
	if top_level_name in top_level_species:
		return
	else:
		top_level_species.add(top_level_name)

	# find all related species:
	# for any top-level species, related species
	#   will have a space then open paren following
	#   the species name

	found_related_species = [top_level_name]

	related_prefix = top_level_name + ' ('
	for some_species in first_by_species:
		if some_species.startswith(related_prefix):
			found_related_species.append(some_species)

	for related_species in sorted(found_related_species):
		print_collapsed_content(related_species, top_level_name)

	print(inspect.cleandoc("""
			</div>
		</details>
		"""))

def print_collapsed_content(species, top_level_name):

	first_year = first_by_species[species]["year"]
	first_img = image_sm_version(first_by_species[species]['file_name'])
	first_date = format_date_day(first_by_species[species]["date_str"])
	first_stars = format_stars(first_by_species[species]['stars'], first_by_species[species]['favorite'])

	last_year = last_by_species[species]['year']
	last_img = image_sm_version(last_by_species[species]['file_name'])
	last_date = format_date_day(last_by_species[species]["date_str"])
	last_stars = format_stars(last_by_species[species]['stars'], last_by_species[species]['favorite'])

	best_year = best_by_species[species]['year']
	best_img = image_sm_version(best_by_species[species]['file_name'])
	best_date = format_date_day(best_by_species[species]["date_str"])
	best_stars = format_stars(best_by_species[species]['stars'], best_by_species[species]['favorite'])

	if species == top_level_name:
		print(inspect.cleandoc("""
			<details class="width-resp-50-100">
				<summary>
					<img class="width-100" src="https://philthompson.me/s/img/{best_year}/{best_img}"/>
					<p><span class="alt-text">{species_count}</span>&nbsp;{species}</p>
				</summary>
				<p class="article-info">(Click above image to re-collapse.)</p>
				<p>Below you'll first see my overall first, last, and best images of {species}, then
				the first, last, and best images for each subspecies and sex photographed,
				if any.</p>
				<div class="details-inner">""".format(best_year=best_year, species_count=len(top_level_species), species=species, best_img=best_img)))

	print("<h4 class=\"species-label\">{}</h4>".format(species))

	first_label = "First"
	if first_img == last_img and first_img == best_img:
		first_label = "First/Last/Best"
	# if the first is also the last, then it must also be the best, right?
	#   oh well, for now just leave it like this
	elif first_img == last_img:
		first_label = "First/Last"
	elif first_img == best_img:
		first_label = "First/Best"
	print(inspect.cleandoc("""
				<img style="float:left" src="https://philthompson.me/s/img/{first_year}/{first_img}"/>
				<p><br/>{species}</p>
				<p>{first_label}: {first_date}</p>
				<p>{first_stars}</p>
				<p style="clear:both"></p>
		""".format(species=species, first_year=first_year, first_img=first_img, first_label=first_label, first_date=first_date, first_stars=first_stars)))
	
	if first_img != last_img:
		last_label = "Last"
		if last_img == best_img:
			last_label = "Last/Best"
		print(inspect.cleandoc("""
				<img style="float:left" src="https://philthompson.me/s/img/{last_year}/{last_img}"/>
				<p><br/>{species}</p>
				<p>{last_label}: {last_date}</p>
				<p>{last_stars}</p>
				<p style="clear:both"></p>
			""".format(species=species, last_year=last_year, last_img=last_img, last_label=last_label, last_date=last_date, last_stars=last_stars)))
	
	if first_img != best_img and last_img != best_img:
		print(inspect.cleandoc("""
				<img style="float:left" src="https://philthompson.me/s/img/{best_year}/{best_img}"/>
				<p><br/>{species}</p>
				<p>Best: {best_date}</p>
				<p>{best_stars}</p>
				<p style="clear:both"></p>
			""".format(species=species, best_year=best_year, best_img=best_img, best_date=best_date, best_stars=best_stars)))

def main_stuff(conn):
	curs = conn.cursor()
	run_query(conn, curs, where_clause)
	print_header()

	# favorites pages are simpler -- just print photos in order
	if output_all_favs:
		print(inspect.cleandoc('''
			<p>These are my favorite photos of {year}.  The photos are
			arranged here in date order.  Click the photo to enlarge.</p>
			<p>Available birds pages:
				<a href="${{SITE_ROOT_REL}}/birds/">All Birds</a>,
				<a href="${{SITE_ROOT_REL}}/birds/home.html">All Yard Birds</a>,
				<a href="${{SITE_ROOT_REL}}/birds/2021.html">2021 Birds</a>,
				<a href="${{SITE_ROOT_REL}}/birds/2022.html">2022 Birds</a>,
				<a href="${{SITE_ROOT_REL}}/birds/2023.html">2023 Birds</a>,
				<a href="${{SITE_ROOT_REL}}/birds/favorites-2021.html">2021 Favorites</a>,
				<a href="${{SITE_ROOT_REL}}/birds/favorites-2022.html">2022 Favorites</a>,
				<a href="${{SITE_ROOT_REL}}/birds/favorites-2023.html">2023 Favorites</a>,
				<a href="${{SITE_ROOT_REL}}/birds/home-2021.html">2021 Yard Birds</a>,
				<a href="${{SITE_ROOT_REL}}/birds/home-2022.html">2022 Yard Birds</a>,
				<a href="${{SITE_ROOT_REL}}/birds/home-2023.html">2023 Yard Birds</a>
			</p>
			<p>All these and other bird photos are published to my gallery pages.  See the <a href="${{SITE_ROOT_REL}}/gallery/">latest gallery page</a>.</p>
			<p>These photos are © {year} Phil Thompson, all rights reserved.</p>
			'''.format(year=plain_year)))
		print('<div class="wide-override">')
		for row in curs.fetchall():
			row_dict = {
				'rollup': row[0],
				'file_name': row[1],
				'species': row[2],
				'year': row[3],
				'date_str': row[4],
				'stars': row[5],
				'favorite': row[6]}
			if row_dict['rollup'] != "fav":
				continue
			print_favorite_photo(row_dict)
		print('</div>')
		print('')
		print('<p style="text-align:center">This page was last updated on {}</p>'.format(date.today().strftime('%B %d, %Y')))
		return

	min_year = 9999
	max_year = 0
	for row in curs.fetchall():
		row_dict = {
			'rollup': row[0],
			'file_name': row[1],
			'species': row[2],
			'year': row[3],
			'date_str': row[4],
			'stars': row[5],
			'favorite': row[6]}
		if row_dict['rollup'] == "first":
			first_by_species[row_dict["species"]] = row_dict
		elif row_dict['rollup'] == "last":
			last_by_species[row_dict["species"]] = row_dict
		elif row_dict['rollup'] == "best":
			best_by_species[row_dict["species"]] = row_dict
		if row_dict['year'] < min_year:
			min_year = row_dict['year']
		if row_dict['year'] > max_year:
			max_year = row_dict['year']
	year_range = 'from {}-{}'.format(min_year, max_year)
	if min_year == max_year:
		year_range = 'in {}'.format(min_year)
	print(inspect.cleandoc('''
		<p>Click images to see my first, last, and best photos of each species.  The birds are
		arranged here in order of when I first photographed them.</p>
		<p>These are my "keeper" and first images of these species photographed {year_range}.</p>
		<p>Available birds pages:
			<a href="${{SITE_ROOT_REL}}/birds/">All Birds</a>,
			<a href="${{SITE_ROOT_REL}}/birds/home.html">All Yard Birds</a>,
			<a href="${{SITE_ROOT_REL}}/birds/2021.html">2021 Birds</a>,
			<a href="${{SITE_ROOT_REL}}/birds/2022.html">2022 Birds</a>,
			<a href="${{SITE_ROOT_REL}}/birds/2023.html">2023 Birds</a>,
			<a href="${{SITE_ROOT_REL}}/birds/favorites-2021.html">2021 Favorites</a>,
			<a href="${{SITE_ROOT_REL}}/birds/favorites-2022.html">2022 Favorites</a>,
			<a href="${{SITE_ROOT_REL}}/birds/favorites-2023.html">2023 Favorites</a>,
			<a href="${{SITE_ROOT_REL}}/birds/home-2021.html">2021 Yard Birds</a>,
			<a href="${{SITE_ROOT_REL}}/birds/home-2022.html">2022 Yard Birds</a>,
			<a href="${{SITE_ROOT_REL}}/birds/home-2023.html">2023 Yard Birds</a>
		</p>
		<p>All these and other bird photos are published to my gallery pages.  See the <a href="${{SITE_ROOT_REL}}/gallery/">latest gallery page</a>.</p>
		<p>These photos are © {year_range_num} Phil Thompson, all rights reserved.</p>
		'''.format(year_range=year_range, year_range_num=year_range.split(' ')[1])))
	print('<div class="wide-override">')

	if should_sort_by_date:
		for species in first_by_species:
			print_collapsable_item(species)
	else:
		for species in sorted(first_by_species):
			print_collapsable_item(species)
	print('</div>')
	print('')
	print('<p style="text-align:center">This page was last updated on {}</p>'.format(date.today().strftime('%B %d, %Y')))

with sqlite3.connect(db_path) as conn:
	main_stuff(conn)