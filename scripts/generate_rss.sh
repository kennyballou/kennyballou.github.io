#!/usr/bin/env bash
# Generate index.html page

INPUT_FILES=${@}
PROJ_ROOT=$(git rev-parse --show-toplevel)
source ${PROJ_ROOT}/scripts/site-templates.sh

echo "<?xml version=\"1.0\" encoding=\"utf-8\"?>"
echo "<rss version=\"2.0\" xmlns:atom=\"http://www.w3.org/2005/Atom\">"
echo "<channel>"
echo "<title>~kballou/blog</title>"
echo "<link>https://kennyballou.com</link>"
echo "<language>en-us</language>"
echo "<author>Kenny Ballou</author>"
echo "<copyright>Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License</copyright>"
echo "<updated>$(date --utc --rfc-3339='date')</updated>"
cat ${INPUT_FILES} | sort -r -n -k1 -k2 -k3 | awk -F'	' '{print $4}'
echo "</channel>"
echo "</rss>"
