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
CONFIG_FILE=examples/version-with-config.yaml
CONFIG_PATH="elastic-runtime"
VERSION_PATH="elastic-runtime.version"
INITIAL_VERSION="2.3.4"

####################################

@test "in test: desired version is requested" {
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
        \"version\": { \"semver\": \"2.3.4\" }
      }
EOF
  "
  assert_success
  assert_line --partial '"semvar": "2.3.4"'
  assert_line --partial '"name": "globs",'
  assert_line --partial '"value": "*.pivotal"'
  assert_line --partial '"name": "name",'
  assert_line --partial '"value": "cf"'
  assert_line --partial '"name": "slug",'
  assert_line --partial '"value": "elastic-runtime"'
}

@test "in test: desired version is requested; initial_version shouldn't matter" {
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
        \"version\": { \"semver\": \"2.3.4\" }
      }
EOF
  "
  assert_success
  assert_line --partial '"semvar": "2.3.4"'
  assert_line --partial '"name": "globs",'
  assert_line --partial '"value": "*.pivotal"'
  assert_line --partial '"name": "name",'
  assert_line --partial '"value": "cf"'
  assert_line --partial '"name": "slug",'
  assert_line --partial '"value": "elastic-runtime"'
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
