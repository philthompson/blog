#!/bin/bash

CURRENT_YEAR="$(date +%Y)"

PAGE_TITLE="${1}"
SITE_ROOT_REL="${2}"

cat << xxxxxEOFxxxxx
				<div class="copyright">
					<p>© 2018-${CURRENT_YEAR} <a href="${SITE_ROOT_REL}/">Phil Thompson</a></p>
				</div>
			</footer>
		</div>
	</body>
</html>
xxxxxEOFxxxxx
