#!/usr/bin/env bats

#!./libs/bats/bin/bats

load 'libs/bats-support/load'
load 'libs/bats-assert/load'

function setup() {
  mkdir -p /tmp/semver-config-git-repo
  rm -f ~/.netrc
}

function teardown() {
  rm -rf /tmp/semver-config-git-repo
}


####################################

DRIVER=git
URI=https://github.com/brightzheng100/semver-config-concourse-resource.git
BRANCH=master
USERNAME="$USERNAME"
PASSWORD="$PASSWORD"
PRIVATE_KEY="$PRIVATE_KEY"
CONFIG_FILE=examples/version-with-stemcell.yaml
CONFIG_PATH="xenial-stemcell"
VERSION_PATH="xenial-stemcell.product-version"
INITIAL_VERSION="170.124"

####################################

@test "in test: desired version is requested: current=170.124; requesting=170.124; initial_version=170.120" {
  run bash -c "
    cat <<- EOF | ./in "/tmp/semver-config-git-repo"
      {
        \"source\": {
          \"driver\": \"$DRIVER\",
          \"uri\": \"$URI\",
          \"branch\": \"$BRANCH\",
          \"username\": \"$USERNAME\",
          \"password\": \"$PASSWORD\",
          \"config_file\": \"$CONFIG_FILE\",
          \"config_path\": \"$CONFIG_PATH\",
          \"initial_version\": \"$INITIAL_VERSION\",
          \"version_path\": \"$VERSION_PATH\"
        },
        \"version\": { \"semver\": \"170.124\" }
      }
EOF
  "
  assert_success
  assert_line --partial '"semvar": "170.124"'
  assert_line --partial '"name": "product-version"'
  assert_line --partial '"value": "170.124"'
  assert_line --partial '"name": "pivnet-product-slug"'
  assert_line --partial '"value": "stemcells-ubuntu-xenial"'
  assert_line --partial '"name": "pivnet-api-token"'
  assert_line --partial '"value": "((pivnet_token))"'
  assert_line --partial '"name": "pivnet-file-glob"'
  assert_line --partial '"value": "light-bosh-stemcell-*-google-kvm-ubuntu-xenial-go_agent.tgz"'
}

@test "in test: desired version is requested: current=170.124; requesting=170.124" {
  run bash -c "
    cat <<- EOF | ./in "/tmp/semver-config-git-repo"
      {
        \"source\": {
          \"driver\": \"$DRIVER\",
          \"uri\": \"$URI\",
          \"branch\": \"$BRANCH\",
          \"username\": \"$USERNAME\",
          \"password\": \"$PASSWORD\",
          \"config_file\": \"$CONFIG_FILE\",
          \"config_path\": \"$CONFIG_PATH\",
          \"version_path\": \"$VERSION_PATH\"
        },
        \"version\": { \"semver\": \"170.124\" }
      }
EOF
  "
  assert_success
  assert_line --partial '"semvar": "170.124"'
  assert_line --partial '"name": "product-version"'
  assert_line --partial '"value": "170.124"'
  assert_line --partial '"name": "pivnet-product-slug"'
  assert_line --partial '"value": "stemcells-ubuntu-xenial"'
  assert_line --partial '"name": "pivnet-api-token"'
  assert_line --partial '"value": "((pivnet_token))"'
  assert_line --partial '"name": "pivnet-file-glob"'
  assert_line --partial '"value": "light-bosh-stemcell-*-google-kvm-ubuntu-xenial-go_agent.tgz"'
}

@test "in test: wrong version is requested, then got empty metadata" {
  run bash -c "
    cat <<- EOF | ./in "/tmp/semver-config-git-repo"
      {
        \"source\": {
          \"driver\": \"$DRIVER\",
          \"uri\": \"$URI\",
          \"branch\": \"$BRANCH\",
          \"username\": \"$USERNAME\",
          \"password\": \"$PASSWORD\",
          \"config_file\": \"$CONFIG_FILE\",
          \"config_path\": \"$CONFIG_PATH\",
          \"initial_version\": \"$INITIAL_VERSION\",
          \"version_path\": \"$VERSION_PATH\"
        },
        \"version\": { \"semver\": \"1.2.3\" }
      }
EOF
  "
  assert_success
  assert_line --partial '"metadata": []'
}

@test "in test: wrong version is requested, then got empty metadata; initial_version shouldn't matter" {
  run bash -c "
    cat <<- EOF | ./in "/tmp/semver-config-git-repo"
      {
        \"source\": {
          \"driver\": \"$DRIVER\",
          \"uri\": \"$URI\",
          \"branch\": \"$BRANCH\",
          \"username\": \"$USERNAME\",
          \"password\": \"$PASSWORD\",
          \"config_file\": \"$CONFIG_FILE\",
          \"config_path\": \"$CONFIG_PATH\",
          \"version_path\": \"$VERSION_PATH\"
        },
        \"version\": { \"semver\": \"1.2.3\" }
      }
EOF
  "
  assert_success
  assert_line --partial '"metadata": []'
}
