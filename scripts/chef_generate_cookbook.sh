#!/bin/bash

set -eu
set -x

SCRIPT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
REPO_PATH="${SCRIPT_PATH}/.."
GENERATOR_COOKBOOK="${REPO_PATH}/.cinc/boxcutter_generator"

if [[ $# -eq 0 ]]; then
  echo "Usage: $0 NAME"
  exit 1
fi

COOKBOOK_NAME=$1

# make sure we're in the cookbooks subdir
pushd "${REPO_PATH}/cookbooks"

cinc generate cookbook "${COOKBOOK_NAME}" \
  --copyright 'Boxcutter' \
  --email 'noreply@boxcutter.dev' \
  --license 'apachev2' \
  --kitchen dokken \
  --generator-cookbook "${GENERATOR_COOKBOOK}"

popd

