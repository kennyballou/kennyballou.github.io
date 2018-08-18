#!/usr/bin/env bash
# Extract ORG metadata

ORGIN=${1}
LC_TIME="C"

STUB=$(awk -F': ' '/^#\+SLUG:/ { printf "%s", $2}' ${ORGIN})
DATE=$(awk -F': ' '/^#\+DATE:/ { printf "%s", $2}' ${ORGIN})
YEAR=$(echo ${DATE} | awk -F'-' '{ print $1 }')
MONTH=$(echo ${DATE} | awk -F'-' '{ print $2 }')
SLUG="/blog/${YEAR}/${MONTH}/${STUB}"
TITLE=$(awk -F': ' '/^#\+TITLE:/ { printf "%s", $2}' ${ORGIN})
PREVIEW=$(sed -n \
              '/^#+BEGIN_PREVIEW/,/^#+END_PREVIEW/p' \
              ${ORGIN} \
              | head -n-1 \
              | tail -n+2)
DESCRIPTION=$(awk -F': ' '/^#\+DESCRIPTION:/ { printf "%s", $2}' ${ORGIN})
TAGS=$(awk -F': ' '/^#\+TAGS:/ { $1 = ""; printf "%s\n", $0}' ${ORGIN})
LINKS=$(sed -n -e '/^#+LINK:/p' ${ORGIN})
