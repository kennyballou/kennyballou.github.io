#!/usr/bin/env bash

SLUG="${1}"
DATE=$(date --iso-8601)

cat << EOF > "./posts/${SLUG}.org"
#+TITLE:
#+DESCRIPTION:
#+TAGS:
#+DATE: ${DATE}
#+SLUG: ${SLUG}

#+BEGIN_PREVIEW
#+END_PREVIEW
EOF
