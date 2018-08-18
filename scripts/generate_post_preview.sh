#!/usr/bin/env bash
# Generate HTML post summary tags

ORGIN=${1}
PROJ_ROOT=$(git rev-parse --show-toplevel)

source ${PROJ_ROOT}/scripts/org-metadata.sh

echo "${LINKS}"
echo "${PREVIEW}"
