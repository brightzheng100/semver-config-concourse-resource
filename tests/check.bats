#!/usr/bin/env bats

#!./libs/bats/bin/bats

load 'libs/bats-support/load'
load 'libs/bats-assert/load'

function setup() {
  rm -f ~/.netrc
}

function teardown() {
  rm -f /tmp/semver-config-request.*
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

@test "check test: no source parameters are set" {
  run bash -c "
    cat <<- EOF | ./check
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
    cat <<- EOF | ./check
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
    cat <<- EOF | ./check
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
    cat <<- EOF | ./check
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
          \"version_pattern\": \"$VERSION_PATERN_MNP\"
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
    cat <<- EOF | ./check
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
          \"version_pattern\": \"$VERSION_PATERN_MNP\"
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
    cat <<- EOF | ./check
      {
        \"source\": {
          \"driver\": \"$DRIVER\",
          \"uri\": \"$URI\",
          \"branch\": \"$BRANCH\",
          \"username\": \"$USERNAME\",
          \"password\": \"$PASSWORD\",
          \"config_file\": \"$CONFIG_FILE\",
          \"config_path\": \"wrong.path\",
          \"initial_version\": \"$INITIAL_VERSION\",
          \"version_path\": \"$VERSION_PATH\",
          \"version_pattern\": \"$VERSION_PATERN_MNP\"
        },
        \"version\": {}
      }
EOF
  "
  assert_success
  assert_line --partial "result: []"
}

@test "check test: wrong version_pattern is set" {
  run bash -c "
    cat <<- EOF | ./check
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

@test "check test: NEW version is detected: version_pattern='m.n.p'; current=2.3.4; initial_version=1.2.3" {
  run bash -c "
    cat <<- EOF | ./check
      {
        \"source\": {
          \"driver\": \"$DRIVER\",
          \"uri\": \"$URI\",
          \"branch\": \"$BRANCH\",
          \"username\": \"$USERNAME\",
          \"password\": \"$PASSWORD\",
          \"config_file\": \"$CONFIG_FILE\",
          \"config_path\": \"$CONFIG_PATH\",
          \"initial_version\": \"1.2.3\",
          \"version_path\": \"$VERSION_PATH\",
          \"version_pattern\": \"m.n.p\"
        },
        \"version\": {}
      }
EOF
  "
  assert_success
  assert_line --partial 'new version detected:'
  assert_line --partial '"semver": "2.3.4"'
}

@test "check test: NEW version is detected: version_pattern='m.*.*'; current=2.3.4; initial_version=1.0.0" {
  run bash -c "
    cat <<- EOF | ./check
      {
        \"source\": {
          \"driver\": \"$DRIVER\",
          \"uri\": \"$URI\",
          \"branch\": \"$BRANCH\",
          \"username\": \"$USERNAME\",
          \"password\": \"$PASSWORD\",
          \"config_file\": \"$CONFIG_FILE\",
          \"config_path\": \"$CONFIG_PATH\",
          \"initial_version\": \"1.0.0\",
          \"version_path\": \"$VERSION_PATH\",
          \"version_pattern\": \"m.n.*\"
        },
        \"version\": {}
      }
EOF
  "
  assert_success
  assert_line --partial 'new version detected:'
  assert_line --partial '"semver": "2.3.4"'
}

@test "check test: NEW version is detected: version_pattern='m.n.*'; current=2.3.4; initial_version=2.0.0" {
  run bash -c "
    cat <<- EOF | ./check
      {
        \"source\": {
          \"driver\": \"$DRIVER\",
          \"uri\": \"$URI\",
          \"branch\": \"$BRANCH\",
          \"username\": \"$USERNAME\",
          \"password\": \"$PASSWORD\",
          \"config_file\": \"$CONFIG_FILE\",
          \"config_path\": \"$CONFIG_PATH\",
          \"initial_version\": \"2.0.0\",
          \"version_path\": \"$VERSION_PATH\",
          \"version_pattern\": \"m.n.*\"
        },
        \"version\": {}
      }
EOF
  "
  assert_success
  assert_line --partial 'new version detected:'
  assert_line --partial '"semver": "2.3.4"'
}

@test "check test: NEW version is detected: version_pattern='m.n.p'; current=2.3.4; initial_version=2.3.0" {
  run bash -c "
    cat <<- EOF | ./check
      {
        \"source\": {
          \"driver\": \"$DRIVER\",
          \"uri\": \"$URI\",
          \"branch\": \"$BRANCH\",
          \"username\": \"$USERNAME\",
          \"password\": \"$PASSWORD\",
          \"config_file\": \"$CONFIG_FILE\",
          \"config_path\": \"$CONFIG_PATH\",
          \"initial_version\": \"2.3.0\",
          \"version_path\": \"$VERSION_PATH\",
          \"version_pattern\": \"m.n.p\"
        },
        \"version\": {}
      }
EOF
  "
  assert_success
  assert_line --partial 'new version detected:'
  assert_line --partial '"semver": "2.3.4"'
}

@test "check test: NO version is detected: version_pattern='m.*.*'; current=2.3.4; initial_version=2.0.0" {
  run bash -c "
    cat <<- EOF | ./check
      {
        \"source\": {
          \"driver\": \"$DRIVER\",
          \"uri\": \"$URI\",
          \"branch\": \"$BRANCH\",
          \"username\": \"$USERNAME\",
          \"password\": \"$PASSWORD\",
          \"config_file\": \"$CONFIG_FILE\",
          \"config_path\": \"$CONFIG_PATH\",
          \"initial_version\": \"2.0.0\",
          \"version_path\": \"$VERSION_PATH\",
          \"version_pattern\": \"m.*.*\"
        },
        \"version\": {}
      }
EOF
  "
  assert_success
  assert_line --partial 'no new version detected'
  assert_line --partial 'result: []'
}

@test "check test: NO version is detected: version_pattern='m.n.*'; current=2.3.4; initial_version=2.3.0" {
  run bash -c "
    cat <<- EOF | ./check
      {
        \"source\": {
          \"driver\": \"$DRIVER\",
          \"uri\": \"$URI\",
          \"branch\": \"$BRANCH\",
          \"username\": \"$USERNAME\",
          \"password\": \"$PASSWORD\",
          \"config_file\": \"$CONFIG_FILE\",
          \"config_path\": \"$CONFIG_PATH\",
          \"initial_version\": \"2.3.0\",
          \"version_path\": \"$VERSION_PATH\",
          \"version_pattern\": \"m.n.*\"
        },
        \"version\": {}
      }
EOF
  "
  assert_success
  assert_line --partial 'no new version detected'
  assert_line --partial 'result: []'
}

@test "check test: NO version is detected: version_pattern='*.n.*'; current=2.3.4; initial_version=1.3.0" {
  run bash -c "
    cat <<- EOF | ./check
      {
        \"source\": {
          \"driver\": \"$DRIVER\",
          \"uri\": \"$URI\",
          \"branch\": \"$BRANCH\",
          \"username\": \"$USERNAME\",
          \"password\": \"$PASSWORD\",
          \"config_file\": \"$CONFIG_FILE\",
          \"config_path\": \"$CONFIG_PATH\",
          \"initial_version\": \"1.3.0\",
          \"version_path\": \"$VERSION_PATH\",
          \"version_pattern\": \"*.n.*\"
        },
        \"version\": {}
      }
EOF
  "
  assert_success
  assert_line --partial 'no new version detected'
  assert_line --partial 'result: []'
}

@test "check test: NO version is detected: version_pattern='*.*.p'; current=2.3.4; initial_version=2.2.2" {
  run bash -c "
    cat <<- EOF | ./check
      {
        \"source\": {
          \"driver\": \"$DRIVER\",
          \"uri\": \"$URI\",
          \"branch\": \"$BRANCH\",
          \"username\": \"$USERNAME\",
          \"password\": \"$PASSWORD\",
          \"config_file\": \"$CONFIG_FILE\",
          \"config_path\": \"$CONFIG_PATH\",
          \"initial_version\": \"2.2.2\",
          \"version_path\": \"$VERSION_PATH\",
          \"version_pattern\": \"*.*.p\"
        },
        \"version\": {}
      }
EOF
  "
  assert_success
  assert_line --partial 'no new version detected'
  assert_line --partial 'result: []'
}
