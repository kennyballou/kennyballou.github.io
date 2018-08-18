#!/usr/bin/env bash
# Generate blog directory structure

ORGIN=${1}
PROJ_ROOT=$(git rev-parse --show-toplevel)
source ${PROJ_ROOT}/scripts/org-metadata.sh

echo -n ${SLUG}
