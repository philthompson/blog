#!/bin/bash

CURRENT_YEAR="$(date +%Y)"

PAGE_TITLE="${1}"
SITE_ROOT_REL="${2}"

cat << xxxxxEOFxxxxx
				<div class="copyright">
					<p>
						© ${CURRENT_YEAR} <a href="${SITE_ROOT_REL}/about">Phil Thompson</a>
						&#x2027;
						All Rights Reserved
						&#x2027;
						<a href="${SITE_ROOT_REL}/terms">Terms</a>
						&#x2027;
						<a href="${SITE_ROOT_REL}/privacy">Privacy Policy</a>
						&#x2027;
						<a href="${SITE_ROOT_REL}/disclaimer">Disclaimer</a>
						&#x2027;
						<a href="${SITE_ROOT_REL}/tip-jar">Tip Jar</a>
					</p>
				</div>
			</footer>
		</div>
	</body>
</html>
xxxxxEOFxxxxx
