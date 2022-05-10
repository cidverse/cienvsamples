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
update_from_gist "github-actions-env" "github-actions.env"
update_from_gist "github-actions-gitlog" "github-actions.gitlog"
update_from_gist "gitlab-ci-env" "gitlab-ci.env"
update_from_gist "gitlab-ci-gitlog" "gitlab-ci.gitlog"
