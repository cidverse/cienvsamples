#!/bin/bash

#######################################
# updates the files in this repository using the gists
#
# ARGUMENTS:
#   identifier
#   file
# RETURN:
#   0 on success, non-zero on error.
#######################################
update_from_gist() {
  GIST_ID=$(gh gist list | grep $1 | awk '{ print $1 }')
  gh gist view $GIST_ID -f $2 > files/$2
}

# downloads all files from the gists
## github-actions
update_from_gist "github-actions-env" "github-actions.env"
update_from_gist "github-actions-gitlog" "github-actions.gitlog"
## gitlab-ci
update_from_gist "gitlab-ci-env" "gitlab-ci.env"
update_from_gist "gitlab-ci-gitlog" "gitlab-ci.gitlog"
## azure-devops
update_from_gist "azure-devops-env" "azure-devops.env"
update_from_gist "azure-devops-gitlog" "azure-devops.gitlog"
## appveyor
update_from_gist "appveyor-env" "appveyor.env"
update_from_gist "appveyor-gitlog" "appveyor.gitlog"
## circleci
update_from_gist "circleci-env" "circleci.env"
update_from_gist "circleci-gitlog" "circleci.gitlog"
