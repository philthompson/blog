#!/bin/bash

PAGE_TITLE="${1}"
SITE_ROOT_REL="${2}"

cat << xxxxxEOFxxxxx
<!DOCTYPE html>
<html lang="en">
	<head>
		<title>${PAGE_TITLE} &mdash; philthompson.me</title>
		<meta http-equiv="content-type" content="text/html; charset=UTF-8">
		<meta charset="utf-8">
		<meta name="X-UA-Compatible" content="IE=edge">
		<meta name="viewport" content="width=device-width, initial-scale=1">
		<link rel="apple-touch-icon-precomposed" sizes="144×144" href="${SITE_ROOT_REL}/icon-ipad-144x144.png">
		<link rel="apple-touch-icon-precomposed" sizes="114×114" href="${SITE_ROOT_REL}/icon-iphone-114x144.png">
		<link rel="apple-touch-icon-precomposed" href="${SITE_ROOT_REL}/icon-default-57x57.png">
		<link rel="icon" type="image/png" href="${SITE_ROOT_REL}/favicon-16x16.png" sizes="16x16">
		<link rel="icon" type="image/png" href="${SITE_ROOT_REL}/favicon-192x192.png" sizes="192x192">
		<link rel="icon" type="image/png" href="${SITE_ROOT_REL}/favicon-96x96.png" sizes="96x96">
		<link rel="icon" type="image/png" href="${SITE_ROOT_REL}/favicon-64x64.png" sizes="64x64">
		<link rel="icon" type="image/png" href="${SITE_ROOT_REL}/favicon-32x32.png" sizes="32x32">
		<link rel="stylesheet" href="${SITE_ROOT_REL}/css/normalize-8.0.0.css">
		<link rel="stylesheet" href="${SITE_ROOT_REL}/css/style.css">
	</head>
	<body>
		<div class="wrap">
			<header>
				<a href="${SITE_ROOT_REL}/index.html" class="logo">
					<img src="${SITE_ROOT_REL}/img/logo.png">
				</a>
				<ul class="nav">
					<li class="nav-item">
						<a href="${SITE_ROOT_REL}/index.html" target="_self">BLOG</a>
					</li>
					<li class="nav-item">
						<a href="${SITE_ROOT_REL}/archive.html" target="_self">ARCHIVE</a>
					</li>
					<li class="nav-item">
						<a href="https://github.com/philthompson" target="_blank">GITHUB</a>
					</li>
				</ul>
			</header>
xxxxxEOFxxxxx
