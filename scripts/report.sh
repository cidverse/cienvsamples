#!/bin/bash

# log
echo "collect for: ${CI_SERVICE_NAME}"

# collect
printenv > ${CI_SERVICE_NAME}.env

# filter credentials
sed -i '/GH_GIST_TOKEN=/d' ${CI_SERVICE_NAME}.env

# filter ci service tokens
sed -i '/GITHUB_TOKEN=/c\GITHUB_TOKEN=secret' ${CI_SERVICE_NAME}.env
sed -i '/CI_JOB_TOKEN=/c\CI_JOB_TOKEN=secret' ${CI_SERVICE_NAME}.env

# log result
echo "environment:"
cat ${CI_SERVICE_NAME}.env

# install gh cli
GH_VERSION=2.9.0
curl -sSL https://github.com/cli/cli/releases/download/v${GH_VERSION}/gh_${GH_VERSION}_linux_amd64.tar.gz -o /tmp/gh_${GH_VERSION}_linux_amd64.tar.gz
tar xvf /tmp/gh_${GH_VERSION}_linux_amd64.tar.gz -C /tmp
cp /tmp/gh_${GH_VERSION}_linux_amd64/bin/gh /usr/local/bin/
chmod +x /usr/local/bin/gh

# store result
gh auth login --with-token <<<"$GH_GIST_TOKEN"
gh gist create --public ${CI_SERVICE_NAME}.env -d "${CI_SERVICE_NAME}"
