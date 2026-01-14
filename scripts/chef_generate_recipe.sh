#!/bin/bash

set -eu
set -x

SCRIPT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
REPO_PATH="${SCRIPT_PATH}/.."
GENERATOR_COOKBOOK="${REPO_PATH}/.cinc/boxcutter_generator"

if [[ $# -eq 0 ]]; then
  echo "Usage: $0 NAME"
fi

RECIPE_NAME=$1

cinc generate recipe "${RECIPE_NAME}" \
  --copyright 'Taylor.dev, LLC' \
  --email 'noreply@boxcutter.dev' \
  --license 'apachev2' \
  --generator-cookbook "${GENERATOR_COOKBOOK}"

