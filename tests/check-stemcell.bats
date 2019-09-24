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

#####################################################################################################

DRIVER=git
URI=https://github.com/brightzheng100/semver-config-concourse-resource.git
BRANCH=master
USERNAME="$USERNAME"
PASSWORD="$PASSWORD"
PRIVATE_KEY="$PRIVATE_KEY"
CONFIG_FILE=examples/version-with-stemcell.yaml
CONFIG_PATH="xenial-stemcell"
CONFIG_PATH_UPDATED="xenial-stemcell-updated"
VERSION_PATH="xenial-stemcell.product-version"
VERSION_PATH_UPDATED="xenial-stemcell-updated.product-version"
VERSION_PATTERN____="-"
INITIAL_VERSION="170.120"

#####################################################################################################


#################### DISRUPTIVE TEST CASES START ####################

@test "check test: no source parameters are set" {
  run bash -c "
    cat <<- EOF | ./check "/tmp/semver-config-git-repo"
      {
        \"source\": {
        },
        \"version\": {}
      }
EOF
  "
  assert_failure
  assert_line --partial 'driver must be set'
  assert_line --partial 'uri must be set'
  assert_line --partial 'config_file must be set'
  assert_line --partial 'config_path must be set'
  assert_line --partial 'version_path must be set'
  assert_line --partial 'version_pattern must be set'
}

@test "check test: all source parameters are set as empty" {
  run bash -c "
    cat <<- EOF | ./check "/tmp/semver-config-git-repo"
      {
        \"source\": {
          \"driver\": \"\",
          \"uri\": \"\",
          \"branch\": \"\",
          \"private_key\": \"\",
          \"username\": \"\",
          \"password\": \"\",
          \"config_file\": \"\",
          \"config_path\": \"\",
          \"version_path\": \"\",
          \"version_pattern\": \"\"
        },
        \"version\": {}
      }
EOF
  "
  assert_failure
  assert_line --partial 'driver must be set'
  assert_line --partial 'uri must be set'
  assert_line --partial 'config_file must be set'
  assert_line --partial 'config_path must be set'
  assert_line --partial 'version_path must be set'
  assert_line --partial 'version_pattern must be set'
}

@test "check test: only driver is set" {
  run bash -c "
    cat <<- EOF | ./check "/tmp/semver-config-git-repo"
      {
        \"source\": {
          \"driver\": \"$DRIVER\"
        },
        \"version\": {}
      }
EOF
  "
  assert_failure
  assert_line --partial 'uri must be set'
  assert_line --partial 'config_file must be set'
  assert_line --partial 'config_path must be set'
  assert_line --partial 'version_path must be set'
  assert_line --partial 'version_pattern must be set'
}

@test "check test: wrong config_file is set" {
  run bash -c "
    cat <<- EOF | ./check "/tmp/semver-config-git-repo"
      {
        \"source\": {
          \"driver\": \"$DRIVER\",
          \"uri\": \"$URI\",
          \"branch\": \"$BRANCH\",
          \"username\": \"$USERNAME\",
          \"password\": \"$PASSWORD\",
          \"config_file\": \"wrong/file.yml\",
          \"config_path\": \"$CONFIG_PATH\",
          \"initial_version\": \"$INITIAL_VERSION\",
          \"version_path\": \"$VERSION_PATH\",
          \"version_pattern\": \"$VERSION_PATTERN____\"
        },
        \"version\": {}
      }
EOF
  "
  assert_failure
  assert_line --partial "config_file doesn't exist"
}

@test "check test: wrong version_path is set" {
  run bash -c "
    cat <<- EOF | ./check "/tmp/semver-config-git-repo"
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
          \"version_path\": \"wrong.version.path\",
          \"version_pattern\": \"$VERSION_PATTERN____\"
        },
        \"version\": {}
      }
EOF
  "
  assert_failure
  assert_line --partial "version is invalid or version_path is wrong"
}

@test "check test: wrong config_path is set, but it's okay in 'check'" {
  run bash -c "
    cat <<- EOF | ./check "/tmp/semver-config-git-repo"
      {
        \"source\": {
          \"driver\": \"$DRIVER\",
          \"uri\": \"$URI\",
          \"branch\": \"$BRANCH\",
          \"username\": \"$USERNAME\",
          \"password\": \"$PASSWORD\",
          \"config_file\": \"$CONFIG_FILE\",
          \"config_path\": \"wrong.path\",
          \"version_path\": \"$VERSION_PATH\",
          \"version_pattern\": \"$VERSION_PATTERN____\"
        },
        \"version\": {}
      }
EOF
  "
  assert_success
  assert_line --partial 'new version detected:'
  assert_line --partial '"semver": "170.124"'
}

@test "check test: wrong version_pattern is set" {
  run bash -c "
    cat <<- EOF | ./check "/tmp/semver-config-git-repo"
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
          \"version_path\": \"$VERSION_PATH\",
          \"version_pattern\": \"a.b.c\"
        },
        \"version\": {}
      }
EOF
  "
  assert_failure
  assert_line --partial "version_pattern is not valid"
}

#################### DISRUPTIVE TEST CASES END ####################

#################### FIRST_CHECK WITH NEW VERSION TEST CASES START ####################

@test "check test: NEW version is detected: version_pattern='-'; current=170.124; no initial_version; semver=null (first time)" {
  run bash -c "
    cat <<- EOF | ./check "/tmp/semver-config-git-repo"
      {
        \"source\": {
          \"driver\": \"$DRIVER\",
          \"uri\": \"$URI\",
          \"branch\": \"$BRANCH\",
          \"username\": \"$USERNAME\",
          \"password\": \"$PASSWORD\",
          \"config_file\": \"$CONFIG_FILE\",
          \"config_path\": \"$CONFIG_PATH\",
          \"version_path\": \"$VERSION_PATH\",
          \"version_pattern\": \"$VERSION_PATTERN____\"
        },
        \"version\": {\"semver\": null}
      }
EOF
  "
  assert_success
  assert_line --partial 'new version detected:'
  assert_line --partial '"semver": "170.124"'
}

@test "check test: NEW version is detected: version_pattern='-'; current=170.124; initial_version=1.2; semver=null (first time)" {
  run bash -c "
    cat <<- EOF | ./check "/tmp/semver-config-git-repo"
      {
        \"source\": {
          \"driver\": \"$DRIVER\",
          \"uri\": \"$URI\",
          \"branch\": \"$BRANCH\",
          \"username\": \"$USERNAME\",
          \"password\": \"$PASSWORD\",
          \"config_file\": \"$CONFIG_FILE\",
          \"config_path\": \"$CONFIG_PATH\",
          \"version_path\": \"$VERSION_PATH\",
          \"initial_version\": \"1.2\",
          \"version_pattern\": \"$VERSION_PATTERN____\"
        },
        \"version\": {\"semver\": null}
      }
EOF
  "
  assert_success
  assert_line --partial 'new version detected:'
  assert_line --partial '"semver": "170.124"'
}

@test "check test: NEW version is detected: version_pattern='-'; current=170.124; initial_version=1.2; semver='' (first time)" {
  run bash -c "
    cat <<- EOF | ./check "/tmp/semver-config-git-repo"
      {
        \"source\": {
          \"driver\": \"$DRIVER\",
          \"uri\": \"$URI\",
          \"branch\": \"$BRANCH\",
          \"username\": \"$USERNAME\",
          \"password\": \"$PASSWORD\",
          \"config_file\": \"$CONFIG_FILE\",
          \"config_path\": \"$CONFIG_PATH\",
          \"version_path\": \"$VERSION_PATH\",
          \"initial_version\": \"1.2\",
          \"version_pattern\": \"$VERSION_PATTERN____\"
        },
        \"version\": {\"semver\": \"\"}
      }
EOF
  "
  assert_success
  assert_line --partial 'new version detected:'
  assert_line --partial '"semver": "170.124"'
}

#################### FIRST_CHECK WITH NEW VERSION TEST CASES END ####################


#################### CONTINUOUS_CHECK WITH NO VERSION TEST CASES START ####################

@test "check test: NO version is detected: version_pattern='-'; current=170.124; semver=170.124" {
  run bash -c "
    cat <<- EOF | ./check "/tmp/semver-config-git-repo"
      {
        \"source\": {
          \"driver\": \"$DRIVER\",
          \"uri\": \"$URI\",
          \"branch\": \"$BRANCH\",
          \"username\": \"$USERNAME\",
          \"password\": \"$PASSWORD\",
          \"config_file\": \"$CONFIG_FILE\",
          \"config_path\": \"$CONFIG_PATH\",
          \"version_path\": \"$VERSION_PATH\",
          \"version_pattern\": \"$VERSION_PATTERN____\"
        },
        \"version\": {\"semver\": \"170.124\"}
      }
EOF
  "
  assert_success
  assert_line --partial 'no new version detected'
  assert_line --partial 'result: []'
}

#################### CONTINUOUS_CHECK WITH NO VERSION TEST CASES END ####################


#################### CONTINUOUS_CHECK WITH NEW VERSION TEST CASES START ####################

@test "check test: NEW version is detected: version_pattern='-'; current=170.124; semver=170.120" {
  run bash -c "
    cat <<- EOF | ./check "/tmp/semver-config-git-repo"
      {
        \"source\": {
          \"driver\": \"$DRIVER\",
          \"uri\": \"$URI\",
          \"branch\": \"$BRANCH\",
          \"username\": \"$USERNAME\",
          \"password\": \"$PASSWORD\",
          \"config_file\": \"$CONFIG_FILE\",
          \"config_path\": \"$CONFIG_PATH\",
          \"version_path\": \"$VERSION_PATH\",
          \"version_pattern\": \"$VERSION_PATTERN____\"
        },
        \"version\": {\"semver\": \"170.120\"}
      }
EOF
  "
  assert_success
  assert_line --partial 'new version detected:'
  assert_line --partial '"semver": "170.124"'
}

@test "check test: NEW version is detected: version_pattern='-'; current=170.124; semver=170.124; config changed" {
  run bash -c "
    cat <<- EOF | ./check "/tmp/semver-config-git-repo"
      {
        \"source\": {
          \"driver\": \"$DRIVER\",
          \"uri\": \"$URI\",
          \"branch\": \"$BRANCH\",
          \"username\": \"$USERNAME\",
          \"password\": \"$PASSWORD\",
          \"config_file\": \"$CONFIG_FILE\",
          \"config_path\": \"$CONFIG_PATH_UPDATED\",
          \"version_path\": \"$VERSION_PATH_UPDATED\",
          \"version_pattern\": \"$VERSION_PATTERN____\"
        },
        \"version\": {\"semver\": \"170.124\"}
      }
EOF
  "
  assert_success
  assert_line --partial 'new version detected:'
  assert_line --partial '"semver": "170.124"'
}

#################### CONTINUOUS_CHECK WITH NEW VERSION TEST CASES END ####################
