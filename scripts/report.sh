#!/bin/bash

#######################################
# creates or updates a github gist
#
# ARGUMENTS:
#   display name
#   file
# RETURN:
#   0 on success, non-zero on error.
#######################################
update_gist() {
  GIST_ID=$(/usr/local/bin/gh gist list --public -L 50 | grep $1 | awk '{ print $1 }')
  if [ -z "$GIST_ID" ]; then
    # create
    /usr/local/bin/gh gist create --public $2 -d "$1"
  else
    # update
    /usr/local/bin/gh gist edit ${GIST_ID} $2 -d "$1"
  fi
}

# install gh cli
GH_VERSION=2.22.1
curl -sSL https://github.com/cli/cli/releases/download/v${GH_VERSION}/gh_${GH_VERSION}_linux_amd64.tar.gz -o /tmp/gh_${GH_VERSION}_linux_amd64.tar.gz
tar xvf /tmp/gh_${GH_VERSION}_linux_amd64.tar.gz -C /tmp
cp /tmp/gh_${GH_VERSION}_linux_amd64/bin/gh /usr/local/bin/
chmod +x /usr/local/bin/gh

# log
echo "collect for: ${CI_SERVICE_NAME}"

# gather env and sort
env -0 | sort -z | tr '\0' '\n' > ${CI_SERVICE_NAME}.env

# filter: script secrets
sed -i '/GH_GIST_TOKEN=/d' ${CI_SERVICE_NAME}.env

# filter: github
sed -i '/GITHUB_TOKEN=/c\GITHUB_TOKEN=secret' ${CI_SERVICE_NAME}.env

# filter: gitlab
sed -i '/CI_JOB_TOKEN=/c\CI_JOB_TOKEN=secret' ${CI_SERVICE_NAME}.env
sed -i '/CI_BUILD_TOKEN=/c\CI_BUILD_TOKEN=secret' ${CI_SERVICE_NAME}.env
sed -i '/CI_DEPENDENCY_PROXY_PASSWORD=/c\CI_DEPENDENCY_PROXY_PASSWORD=secret' ${CI_SERVICE_NAME}.env
sed -i '/CI_JOB_JWT=/c\CI_JOB_JWT=secret' ${CI_SERVICE_NAME}.env
sed -i '/CI_JOB_JWT_V1=/c\CI_JOB_JWT_V1=secret' ${CI_SERVICE_NAME}.env
sed -i '/CI_JOB_JWT_V2=/c\CI_JOB_JWT_V2=secret' ${CI_SERVICE_NAME}.env
sed -i '/CI_REGISTRY_PASSWORD=/c\CI_REGISTRY_PASSWORD=secret' ${CI_SERVICE_NAME}.env
sed -i '/CI_REPOSITORY_URL=/c\CI_REPOSITORY_URL=https://gitlab-ci-token:secret@gitlab.com/cidverse/cienvsamples.git' ${CI_SERVICE_NAME}.env

# log result
echo "environment:"
cat ${CI_SERVICE_NAME}.env

# store git head log
cat .git/logs/HEAD > ${CI_SERVICE_NAME}.gitlog

# auth
gh auth login --with-token <<<"$GH_GIST_TOKEN"

# update gist
update_gist "${CI_SERVICE_NAME}-env" "${CI_SERVICE_NAME}.env"
update_gist "${CI_SERVICE_NAME}-gitlog" "${CI_SERVICE_NAME}.gitlog"
