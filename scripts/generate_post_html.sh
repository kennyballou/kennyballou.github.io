#!/usr/bin/env bash
# Generate HTML for blog post

ORGIN=${1}
PROJ_ROOT=$(git rev-parse --show-toplevel)
source ${PROJ_ROOT}/scripts/site-templates.sh
source ${PROJ_ROOT}/scripts/org-metadata.sh
DISPLAY_DATE=$(date -d ${DATE} +'%a %b %d, %Y')
SORT_DATE=$(date -d ${DATE} +'%Y	%m	%d	')

cat ${HTML_HEADER_FILE}
cat ${HTML_SUB_HEADER_FILE}
echo -n "<h1 class=\"title\">${TITLE}</h1>"
echo -n "<div class=\"post-meta\">"
echo -n '<ul class="tags"><li><i class="fa fa-tags"></i></li>'
echo -n "${TAGS}" | awk '{ printf "<li>%s</li>", $0}'
echo -n '</ul>'
echo -n "<h4>${DISPLAY_DATE}</h4></div>"
pandoc --from org \
       --to html \
       ${ORGIN}
cat ${HTML_FOOTER_FILE}
