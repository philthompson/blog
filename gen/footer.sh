#!/bin/bash

CURRENT_YEAR="$(date +%Y)"

PAGE_TITLE="${1}"
SITE_ROOT_REL="${2}"

cat << xxxxxEOFxxxxx
				<div class="copyright">
					<p>
						© 2018-${CURRENT_YEAR} <a href="${SITE_ROOT_REL}/about">Phil Thompson</a>
						&#x2027;
						<a href="${SITE_ROOT_REL}/terms">Terms and Conditions</a>
						&#x2027;
						<a href="${SITE_ROOT_REL}/privacy">Privacy Policy</a>
						&#x2027;
						<a href="${SITE_ROOT_REL}/disclaimer">Disclaimer</a>
					</p>
				</div>
			</footer>
		</div>
	</body>
</html>
xxxxxEOFxxxxx
