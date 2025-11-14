
def generate(*, page_title, SITE_ROOT_REL, meta_keywords, meta_description, meta_revisit_after_days=3):
	return f"""<!DOCTYPE html>
<html lang="en">
	<head>
		<title>{page_title} &mdash; philthompson.me</title>
		<meta http-equiv="content-type" content="text/html; charset=UTF-8">
		<meta http-equiv="content-language" content="en">
		<meta name="description" content="{meta_description}">
		<meta charset="utf-8">
		<meta name="X-UA-Compatible" content="IE=edge">
		<meta name="viewport" content="width=device-width, initial-scale=1">
		<meta name="keywords" content="{meta_keywords}">
		<meta name="robots" content="all">
		<meta name="revisit-after" content="{meta_revisit_after_days} days">
		<link rel="apple-touch-icon-precomposed" sizes="144×144" href="{SITE_ROOT_REL}/icon-ipad-144x144.png">
		<link rel="apple-touch-icon-precomposed" sizes="114×114" href="{SITE_ROOT_REL}/icon-iphone-114x114.png">
		<link rel="apple-touch-icon-precomposed" href="{SITE_ROOT_REL}/icon-default-57x57.png">
		<link rel="icon" type="image/png" href="{SITE_ROOT_REL}/favicon-16x16.png" sizes="16x16">
		<link rel="icon" type="image/png" href="{SITE_ROOT_REL}/favicon-192x192.png" sizes="192x192">
		<link rel="icon" type="image/png" href="{SITE_ROOT_REL}/favicon-96x96.png" sizes="96x96">
		<link rel="icon" type="image/png" href="{SITE_ROOT_REL}/favicon-64x64.png" sizes="64x64">
		<link rel="icon" type="image/png" href="{SITE_ROOT_REL}/favicon-32x32.png" sizes="32x32">
		<link rel="stylesheet" href="{SITE_ROOT_REL}/css/normalize-8.0.0.css">
		<link rel="stylesheet" href="{SITE_ROOT_REL}/css/style.css">
	</head>
	<body>
		<div class="wrap">
			<header>
				<!-- this is unused, but may be useful later -->
				<!-- page URL: REPLACE_PAGE_URL -->
				<a href="{SITE_ROOT_REL}/" class="logo">
					<img src="{SITE_ROOT_REL}/img/logo.png">
				</a>
				<ul class="nav">
					<li class="nav-item">
						<a href="{SITE_ROOT_REL}/birds" target="_self" title="Bird Photos Overview Gallery">Birds</a>
					</li>
					<li class="nav-item">
						<a href="{SITE_ROOT_REL}/mandelbrot-gallery" target="_self" title="Mandelbrot Set Gallery">Mandel</a>
					</li>
					<li class="nav-item" style="padding-right: 0;">
						<a href="{SITE_ROOT_REL}/very-plotter/" class="icon" title="Very Plotter">
							<img src="{SITE_ROOT_REL}/img/mandel-icon-github-gray.png">
						</a>
					</li>
					<li class="nav-item" style="padding-right: 0;">
						<a href="{SITE_ROOT_REL}/misc/" class="icon" title="Projects, Apps, and Tools">
							<img src="{SITE_ROOT_REL}/img/apps-gray.png">
						</a>
					</li>
					<li class="nav-item" style="padding-right: 0;">
						<a href="{SITE_ROOT_REL}/tip-jar/" target="_self" class="icon" title="Tip Jar">
							<img src="{SITE_ROOT_REL}/img/donate-gray.png">
						</a>
					</li>
					<li class="nav-item" style="padding-right: 0;">
						<a href="{SITE_ROOT_REL}/2024/My-Electronic-Chill-Album-Break-Away.html" target="_self" class="icon" title='My Electronic/Chill Album "Break | Away"'>
							<img src="{SITE_ROOT_REL}/s/img/2024/break-away-album-art-sm.jpg">
						</a>
					</li>
				</ul>
			</header>
"""