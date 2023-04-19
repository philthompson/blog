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

# dark theme
CLR_DARK_PAGE_BG="#2c2f36"
CLR_DARK_PRE_BG="#251d2c"
CLR_DARK_TEXT_MAIN="#b4b9bd"
CLR_DARK_TEXT_ALT="#949b96"
CLR_DARK_ONE_DARK="#251d2c"
CLR_DARK_ONE_LIGHT="#ada8be"
CLR_DARK_TWO_DARK="#808386"
CLR_DARK_TWO_LIGHT="#949b96"
CLR_DARK_LINK_LINE="#515663"

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

.wrap-wider-child {
	width: 100%
}
@media screen and (min-width: 46rem) {
	.wrap-wider-child {
		width: 44rem;
		left: 50%;
		position: relative;
		transform: translateX(-50%);
	}
}
@media screen and (min-width: 48rem) {
	.wrap-wider-child { width: 46rem; }
}
@media screen and (min-width: 50rem) {
	.wrap-wider-child { width: 48rem; }
}
@media screen and (min-width: 52rem) {
	.wrap-wider-child { width: 50rem; }
}
@media screen and (min-width: 54rem) {
	.wrap-wider-child { width: 52rem; }
}
@media screen and (min-width: 56rem) {
	.wrap-wider-child { width: 54rem; }
}
@media screen and (min-width: 58rem) {
	.wrap-wider-child { width: 56rem; }
}
@media screen and (min-width: 60rem) {
	.wrap-wider-child { width: 58rem; }
}
@media screen and (min-width: 62rem) {
	.wrap-wider-child { width: 60rem; }
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
	height: 3rem;
}

header .icon img {
	height: 2rem;
	vertical-align: middle;
	position: relative;
	top: -0.2rem;
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
	padding: 1.0rem 0.25rem;
	vertical-align: middle;
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

.alt-text {
	color: ${CLR_TEXT_ALT};
}

img {
	padding-top: 0.4rem;
}

.width-resp-75-100 {
	max-width: 100%;
}

@media screen and (min-width: 43rem) {
	.width-resp-75-100 {
		padding-left: 2%;
		padding-right: 2%;
		max-width: 71%;
	}
}

.width-resp-50-100 {
	max-width: 100%;
}

@media screen and (min-width: 43rem) {
	.width-resp-50-100 {
		padding-left: 2%;
		padding-right: 2%;
		max-width: 45%;
	}
}

.width-resp-25-40 {
	max-width: 40%;
}

@media screen and (min-width: 43rem) {
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

.width-40 {
	padding-left: 2%;
	padding-right: 2%;
	max-width: 36%;
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

math.inline-math {
	font-size: 1.15rem;
}

@media (prefers-color-scheme: dark) {
	body {
		color: ${CLR_DARK_TEXT_MAIN};
		background-color: ${CLR_DARK_PAGE_BG};
	}

	.article-info {
		color: ${CLR_DARK_TEXT_ALT};
	}

	.alt-text {
		color: ${CLR_DARK_TEXT_ALT};
	}

	pre {
		overflow-x: auto;
		background-color: ${CLR_DARK_PRE_BG};
	}

	p code, ul code, ol code {
		background-color: ${CLR_DARK_ONE_DARK};
		color: ${CLR_DARK_ONE_LIGHT};
	}

	blockquote {
		border-left: 4px solid ${CLR_DARK_ONE_LIGHT};
	}

	.btns .btn {
		background-color: ${CLR_DARK_ONE_LIGHT};
		color: ${CLR_DARK_ONE_DARK};
		border-color: ${CLR_DARK_ONE_DARK};
	}

	a, a:active {
		color: ${CLR_DARK_TWO_DARK};
		text-decoration-color: ${CLR_DARK_LINK_LINE};
	}

	a:hover {
		color: ${CLR_DARK_TWO_LIGHT};
	}

	.article-title a, .article-title a:hover {
		color: ${CLR_DARK_TEXT_MAIN};
	}
}

xxxxxEOFxxxxx
