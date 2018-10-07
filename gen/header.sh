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
