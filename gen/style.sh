#!/bin/bash

CLR_PAGE_BG="#eff1f3"
CLR_LINK_LINE="#dee2e5"
CLR_LINK_LINE="#d4d9dd"
# initial text color seems too dark
CLR_TEXT_MAIN="#283044"
# darker and less saturated version of text color
CLR_TEXT_MAIN="#474e60"
CLR_TEXT_ALT="#949b96"
CLR_ONE_DARK="#443850"
CLR_ONE_LIGHT="#ada8be"
CLR_TWO_DARK="#829191"
CLR_TWO_LIGHT="#949b96"

cat << xxxxxEOFxxxxx
body {
	margin: 0;
	color: ${CLR_TEXT_MAIN};
	background-color: ${CLR_PAGE_BG};
	font-size: 1.0rem;
	line-height: 1.6;
	font-family: 'Helvetica Neue', Arial, sans-serif;
}

h1, h2, h3, .article-title {
	line-height: 1.3;
}

.wrap {
    max-width: 42rem;
    margin: 0 auto;
    padding: 0 1rem;
}

header {
    padding: 1.5rem 0;
}

header {
	min-height: 4rem;
}

header .logo {
	float: left;
}

header .logo img {
	height: 4rem;
}

header .nav {
	float: right;
	margin: 0;
	padding-left: 0;
}

ul .nav {
	margin: 0;
	padding: 0;
	list-style-type: none;
}

header .nav .nav-item {
	display: inline-block;
	padding: 1.5rem 0.5rem;
}

.container {
	margin: 3rem 0;
}

.article-title {
	font-size: 1.5rem;
	padding-bottom: 0.25rem;
}

.article-title small {
	padding-right: 0.5rem;
}

.article-info {
	color: ${CLR_TEXT_ALT};
	margin: 1.2rem 0;
}

img {
	padding-top: 0.4rem;
}

.width-resp-50-100 {
	max-width: 100%;
}

@media screen and (min-width: 700px) {
	.width-resp-50-100 {
		padding-left: 2%;
		padding-right: 2%;
		max-width: 45%;
	}
}

.width-100 {
	max-width: 100%;
}

.width-50 {
	padding-left: 2%;
	padding-right: 2%;
	max-width: 45%;
}

.width-25 {
	padding-left: 2%;
	padding-right: 2%;
	max-width: 20%;
}

code, pre {
	font-size: 0.9rem;
}

pre {
	overflow-x: auto;
	background-color: ${CLR_LINK_LINE};
	padding: 1.0rem;
	line-height: 1.3;
}

p code {
	background-color: ${CLR_ONE_DARK};
	color: ${CLR_ONE_LIGHT};
	margin: 0 0.1rem;
	padding: 0.2rem 0.5rem;
	border-radius: 0.3rem;
	white-space: inherit;
}

blockquote {
	margin: 2rem 0;
	padding-left: 1.5rem;
	border-left: 4px solid ${CLR_ONE_LIGHT};
}

.btns .btn {
	background-color: ${CLR_ONE_LIGHT};
	color: ${CLR_ONE_DARK};
	border-radius: 0.3rem;
	padding: 0.3rem;
	width: 5.0rem;
	display: inline-block;
	border-color: ${CLR_ONE_DARK};
	border-width: 2px;
	border-style: solid;
	text-decoration: none;
}

.btns {
	margin: 4rem 0;
	text-align: center;
}

a, a:active {
	color: ${CLR_TWO_DARK};
	text-decoration-color: ${CLR_LINK_LINE};
}

a:hover {
	color: ${CLR_TWO_LIGHT};
}

.article-title a, .article-title a:hover {
	color: ${CLR_TEXT_MAIN};
}

xxxxxEOFxxxxx
