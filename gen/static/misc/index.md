
<!-- this file is generated by generateMiscGallery.py -->

[//]: # (gen-title: Misc Pages)

[//]: # (gen-keywords: apps, tools, art, javascript, photography)

[//]: # (gen-description: Links to things on this website that are not blog posts or photo galleries.)

[//]: # (gen-meta-end)

## Apps, Tools, and Other Pages

Click the photos for a link and description.

For a more complete list of my projects, see my portfolio listing on this site's <a href="../about/">About page</a>.

<style>
	.img-container {
		padding-top: 1.0rem;
		padding-bottom: 1.0rem;
		border-top: 1px solid #949b96;
	}
	details, details summary {
		display: inline;
	}
	details summary {
		list-style: none;
	}
	details img {
		border-radius: 1.0rem;
		/* the site default padding-top for <image> makes the top rounded corners look wrong */
		/* to fix this, set padding to 0 and use margin-top instead */
		padding: 0;
		margin-top: 0.4rem;
	}
	details > summary::-webkit-details-marker {
		display: none;
	}
	details[open] {
		display: block;
		margin-left: auto;
		margin-right: auto;
		max-width: 100%;
		padding-top: 1.0rem;
		padding-bottom: 1.0rem;
		border-top: 1px solid #949b96;
		border-bottom: 1px solid #949b96;
	}
	#loc {
		word-wrap: break-word;
	}
	.width-resp-50 {
		padding-left: 1.25%;
		padding-right: 1.25%;
		max-width: 45%;
	}
	@media screen and (min-width: 64rem) {
		.width-resp-50 {
			padding-left: 1.25%;
			padding-right: 1.25%;
			max-width: 30%;
		}
	}
	@media screen and (min-width: 104rem) {
		.width-resp-50 {
			padding-left: 1.2%;
			padding-right: 1.2%;
			max-width: 22%;
		}
	}
	.wide-override {
		width: 100%
	}
	@media screen and (min-width: 48rem) {
		.wide-override {
			width: 47rem;
			left: 50%;
			position: relative;
			transform: translateX(-50%);
		}
	}
	@media screen and (min-width: 54rem) {
		.wide-override { width: 52rem; }
	}
	@media screen and (min-width: 64rem) {
		.wide-override { width: 61rem; }
	}
	@media screen and (min-width: 74rem) {
		.wide-override { width: 70rem; }
	}
	@media screen and (min-width: 84rem) {
		.wide-override { width: 80rem; }
	}
	@media screen and (min-width: 94rem) {
		.wide-override { width: 90rem; }
	}
	@media screen and (min-width: 104rem) {
		.wide-override { width: 98rem; }
	}
	.btns {
		margin: 1rem 0;
	}
</style>
<div class="wide-override">

<details class="width-resp-50">
	<summary>
		<img class="width-100" src="../s/img/2024/click-counter-screenshot.jpg"/>
	</summary>
	<p><a href="../misc/click-counter/">Click Counter</a></p>
	<p>A simple JavaScript app for counting things in photos.</p>
	<p>First published in 2024.</p>
</details>
<details class="width-resp-50">
	<summary>
		<img class="width-100" src="../s/img/2023/nfl-elo-hero.jpg"/>
	</summary>
	<p><a href="../nfl-elo/">NFL Elo Power Rankings</a></p>
	<p>
NFL power rankings based on Elo ratings.<br/><br/>
Written in Python, this project parses Wikipedia data, calculates Elo ratings, and outputs the above linked page.
The project includes a test harness for adjusting Elo rating model parameters, which backtests the model on thousands
of NFL games (more than 10 full seasons at the time of writing).<br/><br/>
For more background, see my blog post <a href="../2023/NFL-Elo-Power-Rankings-for-2023.html">here</a>.</p>
	<p>First published in 2023.</p>
</details>
<details class="width-resp-50">
	<summary>
		<img class="width-100" src="../s/img/2023/partial-string-match-for-birds-screenshot.jpg"/>
	</summary>
	<p><a href="../misc/partial-string-match-for-birds/search.html">Partial String Match for Birds</a></p>
	<p>
An app to demonstrate partial string match for bird species names.<br/>
I tested out algorithms for finding partial string matches of bird species names, and
found one that worked well enough, and ran fast enough, for use in smartphone apps
(this would fix a gripe I have with the otherwise perfect eBird app).<br/>
I implemented the algorithm in JavaScript, and published pages for testing and running the algorithms.
For more background, see my blog post <a href="../2023/Partial-String-Match-for-Birds.html">here</a>.</p>
	<p>First published in 2023.</p>
</details>
<details class="width-resp-50">
	<summary>
		<img class="width-100" src="../s/img/2023/smarter-than-a-chimp-screenshot.jpg"/>
	</summary>
	<p><a href="../misc/smarter-than-a-chimp/">"Smarter Than a Chimp" game</a></p>
	<p>
A JavaScript game similar to one from this video: <a href="https://www.youtube.com/watch?v=zsXP8qeFF6A">https://www.youtube.com/watch?v=zsXP8qeFF6A</a>.<br/><br/>
The source code is availble in its <a href="https://github.com/philthompson/smarter-than-chimp">GitHub repository</a>.</p>
	<p>First published in 2023.</p>
</details>
<details class="width-resp-50">
	<summary>
		<img class="width-100" src="../s/img/2021/water-jars-screenshot.jpg"/>
	</summary>
	<p><a href="../jars/">Water Jars game</a></p>
	<p>
A small JavaScript implementation of the game where, given three containers, water must be evenly divided between the largest pair.
I also created a <a href="../jars/solver.html">standalone solver page</a> for any set of three containers.<br/><br/>
The source code is availble in its <a href="https://github.com/philthompson/water-jars">GitHub repository</a>.</p>
	<p>First published in 2021.</p>
</details>
<details class="width-resp-50">
	<summary>
		<img class="width-100" src="../s/img/2021/very-plotter-screenshot.jpg"/>
	</summary>
	<p><a href="../very-plotter/">Very Plotter</a></p>
	<p>
View the Mandelbrot set, and plots of a few mathematical sequences.
This app uses JavaScript worker threads, the number of which can be updated on the fly.<br/><br/>
The source code is availble in its <a href="https://github.com/philthompson/visualize-primes">GitHub repository</a>.</p>
	<p>First published in 2021.</p>
</details>
<details class="width-resp-50">
	<summary>
		<img class="width-100" src="../s/img/2018/qrcode-screenshot.jpg"/>
	</summary>
	<p><a href="../qrcode.html">qrcodejs</a></p>
	<p>
A JavaScript page for interactively generating QR codes.<br/><br/>
The source code is availble in its <a href="https://github.com/philthompson/qrcodejs">GitHub repository</a>.</p>
	<p>First published in 2018.</p>
</details>
<details class="width-resp-50">
	<summary>
		<img class="width-100" src="../s/img/2018/screensavejs-screenshot.jpg"/>
	</summary>
	<p><a href="../screensavejs/">screensavejs</a></p>
	<p>A JavaScript page that paints a blurry rendition of any image file.</p>
	<p>First published in 2018.</p>
</details>
<details class="width-resp-50">
	<summary>
		<img class="width-100" src="../s/img/2015/black-and-white-screenshot.jpg"/>
	</summary>
	<p><a href="../misc/black-and-white/">Black & White Box</a></p>
	<p>
JavaScript toy that finds a box (many are possible) describing the percentage of
black and white pixels where <i>the text itself</i> is counted.<br/><br/>
This was inspired by the xkcd #688 <a target="_blank" href="https://xkcd.com/688/">"Self-Description"</a>.<br/><br/>
The source code is availble in my original <a href="https://jsfiddle.net/b8w1coga/">jsfiddle</a>.</p>
	<p>First published in 2015.</p>
</details>
</div>