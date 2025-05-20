#!/bin/bash

# Get current branch
CURRENT_BRANCH=$(git branch --show-current)
export GIT_BRANCH=$CURRENT_BRANCH

# Check if --target was provided
if [[ "$@" != *"--target"* ]]; then
  echo "No target specified - defaulting to dev"
  dbt "$@" --target dev
else
  dbt "$@"
fi