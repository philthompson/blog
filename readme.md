This is a set of scripts and Markdown documents for generating my personal site at [philthompson.me](https://philthompson.me).

The blog post discussing this repo is [here](https://philthompson.me/2018/New-Site.html).

#### Markdown

If specified in an article's markdown comments (`gen-markdown-flavor: CommonMark`), it will be parsed with a CommonMark-compatible parser. Otherwise, articles are parsed/generated with the original Markdown perl script.

#### Python

Uses python 3 for a few things now, and much more in the future.

To install python dependencies:

	$ python3 -m venv python-venv
	$ source python-venv/bin/activate
	$ python3 -m pip install -r python-requirements.txt
	$ deactivate

To update or to install new dependencies:

	$ source python-venv/bin/activate
	$ python3 -m pip ...

To update python dependencies file:

	$ source python-venv/bin/activate
	$ python3 -m pip freeze > python-requirements.txt

#### License

Article files (such as in `gen/articles/`) and images are distributed under traditional copyright with all rights reserved.  All other files, such as source code files and "wordlist" files, are distributed under the MIT license.
