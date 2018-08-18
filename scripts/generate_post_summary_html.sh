#!/usr/bin/env bash
# Generate HTML post summary tags

ORGIN=${1}
GENERATED_PREVIEW_FILE=${2}
PROJ_ROOT=$(git rev-parse --show-toplevel)

source ${PROJ_ROOT}/scripts/org-metadata.sh
DISPLAY_DATE=$(date -d ${DATE} +'%a %b %d, %Y')
SORT_DATE=$(date -d ${DATE} +'%Y	%m	%d	')
PREVIEW_CONTENT=$(cat ${GENERATED_PREVIEW_FILE} | pandoc -f org -t html)

echo -n "${SORT_DATE}"
echo -n '<article class="post"><header>'
echo -n "<h2><a href=\"${SLUG}\">${TITLE}</a></h2>"
echo -n "<div class=\"post-meta\">${DISPLAY_DATE}</div></header>"
echo -n "<blockquote>$(echo ${PREVIEW_CONTENT})</blockquote>"
echo -n '<ul class="tags"><li><i class="fa fa-tags"></i></li>'
echo -n "${TAGS}" | awk '{ printf "<li>%s</li>", $0}'
echo -n '</ul>'
echo -n '<footer>'
echo -n "<a href=\"${SLUG}\">Read More</a>"
echo -n "</footer>"
echo ""
