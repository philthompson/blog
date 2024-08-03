#!/bin/bash

CURRENT_YEAR="$(date +%Y)"

PAGE_TITLE="${1}"
SITE_ROOT_REL="${2}"

cat << xxxxxEOFxxxxx
				<div class="copyright">
					<p>
						© ${CURRENT_YEAR} Phil Thompson
						&#x2027;
						All Rights Reserved
						&#x2027;
						<a href="${SITE_ROOT_REL}/terms">Terms</a>
						&#x2027;
						<a href="${SITE_ROOT_REL}/privacy">Privacy Policy</a>
						&#x2027;
						<a href="${SITE_ROOT_REL}/disclaimer">Disclaimer</a>
						<br/>
						<a href="${SITE_ROOT_REL}/about" target="_self">About</a>
						&#x2027;
						<a href="${SITE_ROOT_REL}/archive" target="_self">Archive</a>
						&#x2027;
						<a href="https://github.com/philthompson" target="_blank">GitHub</a>
						&#x2027;
						<a href="${SITE_ROOT_REL}/tip-jar">Tip Jar</a>
						&#x2027;
						<a href="${SITE_ROOT_REL}/feed.xml">
							<img style="height:1.2rem; position:relative; top:0.3rem; padding:inherit;" src="${SITE_ROOT_REL}/img/rss-github-gray.png">RSS
						</a>
					</p>
				</div>
			</footer>
		</div>
	</body>
</html>
xxxxxEOFxxxxx
