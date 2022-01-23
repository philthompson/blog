#!/bin/bash

CLR_PAGE_BG="#eff1f3"
CLR_LINK_LINE="#dee2e5"
CLR_LINK_LINE="#b4b9bd"
# initial text color seems too dark
CLR_TEXT_MAIN="#283044"
# darker and less saturated version of text color
CLR_TEXT_MAIN="#474e60"
CLR_TEXT_ALT="#949b96"
CLR_ONE_DARK="#443850"
CLR_ONE_LIGHT="#ada8be"
CLR_TWO_DARK="#627171"
CLR_TWO_LIGHT="#949b96"

cat << xxxxxEOFxxxxx
body {
	margin: 0;
	color: ${CLR_TEXT_MAIN};
	background-color: ${CLR_PAGE_BG};
	font-size: 1.0rem;
	line-height: 1.6;
	font-family: system-ui, "Segoe UI", Roboto, Oxygen-Sans, Ubuntu, Cantarell, "Helvetica Neue", Helvetica, Arial, sans-serif, "Apple Color Emoji", "Segoe UI Emoji", "Segoe UI Symbol"
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
	max-width: 42rem;
	min-height: 4rem;
	margin-left: auto;
	margin-right: auto;
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

.width-resp-75-100 {
	max-width: 100%;
}

@media screen and (min-width: 700px) {
	.width-resp-75-100 {
		padding-left: 2%;
		padding-right: 2%;
		max-width: 71%;
	}
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

.width-resp-25-40 {
	max-width: 40%;
}

@media screen and (min-width: 700px) {
	.width-resp-25-40 {
		padding-left: 2%;
		padding-right: 2%;
		max-width: 20%;
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

.center-block {
	margin-left: auto;
	margin-right: auto;
	display: block;
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

p code, ul code, ol code {
	background-color: ${CLR_ONE_DARK};
	color: ${CLR_ONE_LIGHT};
	margin: 0 0.1rem;
	padding: 0.2rem 0.5rem;
	border-radius: 0.3rem;
	white-space: inherit;
	word-break: break-word;
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
	min-width: 5.0rem;
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

.copyright {
	text-align: center;
	font-size: 0.95rem;
}

.top-border {
	border-top: 1px solid #949b96;
}

summary {
	cursor: pointer;
}

.im-i {
	letter-spacing: 0.2rem;
	font-family: serif;
	font-size: 1.2rem;
	font-style: italic;
	padding-left: 0.07rem;
}

xxxxxEOFxxxxx
