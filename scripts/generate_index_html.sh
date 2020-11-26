#!/usr/bin/env bash
# Generate index.html page

INPUT_FILES=${@}
PROJ_ROOT=$(git rev-parse --show-toplevel)
source ${PROJ_ROOT}/scripts/site-templates.sh

cat "${HTML_HEADER_FILE}"
echo "<body>"
cat "${HTML_SUB_HEADER_FILE}"
echo "<div id=\"content\">"
cat ${INPUT_FILES} | sort -r -n -k1 -k2 -k3 | awk -F'	' '{print $4}'
echo "</div>"
echo "</body>"
cat "${HTML_FOOTER_FILE}"
