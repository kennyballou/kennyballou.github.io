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
echo -n "<item>"
echo -n "<title>${TITLE}</title>"
echo -n "<link>https://kennyballou.com${SLUG}</link>"
echo -n "<guid>${SLUG}</guid>"
echo -n "<pubDate>${DISPLAY_DATE}</pubDate>"
echo -n "<description>${DESCRIPTION}</description>"
echo -n "</item>"
echo ""
