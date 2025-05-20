#!/bin/bash

# Get current branch (handles both local and CI environments)
CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || 
                 echo ${GITHUB_REF#refs/heads/} || 
                 echo ${CI_COMMIT_REF_NAME} || 
                 echo "unknown")

export GIT_BRANCH=$CURRENT_BRANCH

# Run dbt with all arguments
dbt "$@"