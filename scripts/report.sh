#!/usr/bin/env bash

# auth
export GH_TOKEN=$GH_GIST_TOKEN

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
  GIST_ID=$($GH_CLI gist list --public -L 50 | grep $1 | awk '{ print $1 }')
  if [ -z "$GIST_ID" ]; then
    # create
    $GH_CLI gist create --public $2 -d "$1"
  else
    # update
    $GH_CLI gist edit ${GIST_ID} $2 -d "$1"
  fi
}

# install gh cli
GH_VERSION=2.62.0
export GH_CLI=/tmp/gh_${GH_VERSION}_linux_amd64/bin/gh
curl -sSL https://github.com/cli/cli/releases/download/v${GH_VERSION}/gh_${GH_VERSION}_linux_amd64.tar.gz -o /tmp/gh_${GH_VERSION}_linux_amd64.tar.gz
tar xvf /tmp/gh_${GH_VERSION}_linux_amd64.tar.gz -C /tmp

# log
echo "collect for: ${CI_SERVICE_NAME}"

# gather env and sort
env -0 | sort -z | tr '\0' '\n' > ${CI_SERVICE_NAME}.env

# filter: script secrets
sed -i '/GH_GIST_TOKEN=/d' ${CI_SERVICE_NAME}.env
sed -i '/GH_TOKEN=/d' ${CI_SERVICE_NAME}.env
sed -i '/GH_CLI=/d' ${CI_SERVICE_NAME}.env

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

# filter: circleci
sed -i '/CIRCLE_OIDC_TOKEN=/c\CIRCLE_OIDC_TOKEN=secret' ${CI_SERVICE_NAME}.env
sed -i '/CIRCLE_OIDC_TOKEN_V2=/c\CIRCLE_OIDC_TOKEN_V2=secret' ${CI_SERVICE_NAME}.env

# log result
echo "environment:"
cat ${CI_SERVICE_NAME}.env

# store git head log
if [ -f .git/logs/HEAD ]; then
  cat .git/logs/HEAD > ${CI_SERVICE_NAME}.gitlog
else
  echo "{file-missing}" > ${CI_SERVICE_NAME}.gitlog
fi

# update gist
update_gist "${CI_SERVICE_NAME}-env" "${CI_SERVICE_NAME}.env"
update_gist "${CI_SERVICE_NAME}-gitlog" "${CI_SERVICE_NAME}.gitlog"
