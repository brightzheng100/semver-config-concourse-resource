
# Semver Config Resource

A [Concourse](https://concourse-ci.org) resource for detecting desired semantic version changes and retrieving a set of semantic version-based configs, by one single YAML file.

Major features:

- One `yaml` file to maintain a set of sementic version-based config items
- Each config can have arbitrory structure where simply setting `version_path` to detect new versions and `config_path` to locate desired config elements
- Support some useful semantic [version detection patterns](#version-patterns). For example, `m.n.*` means `I care only Major or Minor version change`


## The Config File Example

The config file can be any sensibble yaml format.

The simlest one might be:

```yaml
# examples/version-only.yaml
product-1:
  version: "1.2.3"
product-2:
  version: "2.0.1"
```

So we have two products configured with different semantic versions, without any extra config items.

In real world, for example, while maintaining a PCF foundation with lots of products deployed, it can be something like this:

```yaml
# examples/version-with-product-config.yaml
elastic-runtime:
  product-version: "2.3.4"
  pivnet-product-slug: elastic-runtime
  pivnet-api-token: ((pivnet_token))
  pivnet-file-glob: "*.pivotal"
  stemcell-iaas: google

pivotal-container-service:
  product-version: "1.4.0"
  pivnet-product-slug: pivotal-container-service
  pivnet-api-token: ((pivnet_token))
  pivnet-file-glob: "*.pivotal"
  stemcell-iaas: google
```

Where you have not only the semver, but also a set of config items.


## Source Configuration

- **`driver`**: Required. Currently only supports `git`
- **`uri`**: Required. The location of the `git` repository
- `branch`: Optional. The branch to track. Defaults to `master` if not set
- `private_key`: Optional. The SSH private key that can be used for Git access authentication, if required.
- `username`: Optional. The username that can be used for Git access authentication, if required.
- `password`: Optional. The password that can be used for Git access authentication, together with `username`, if required.
- **`config_file`**: Required. The relative path of the config file
- **`config_path`**: Required. The [yq](https://github.com/mikefarah/yq)-style path, e.g. `x.y.z` to locate the root of config items
- `initial_version`: Optional. The initial version to start with. Defaults to `0.0.0` if not set
- **`version_path`**: Required. The [yq](https://github.com/mikefarah/yq)-style path, e.g. `root.version` to locate the root of semver item
- **`version_pattern`**: Required. The pattern to be used for how to detect new versions. Refer to [Version Patterns](#version_patterns) for the supported patterns


## Behavior / Interfaces

### `check`: Check for new versions based on desired Semver Pattern

The tracking `git` repository is cloned to temporary folder and check whether there is a desired newer version based on configured `config_file`, `initial_version`, `version_path`, `version_pattern`.

The extracted config elements will become resource's metadata.


### `in`: Get the config items of the desired version

The tracking `git` repository is cloned to temporary folder and extract the desired config elements based on `config_file`, `config_path`.

The extracted config elements will become resource's metadata and a file will be generated as the output which can be customized further by `in` parameters, as below. 

#### Parameters

- `filename`: Optional. The output file name, without file extension. Defaults to `semver-config`
- `format`: Optional. Supported formats are: `json` and `yaml`. Defaults to `yaml`.


### `out`: No-ops

No-ops for `out`.


## Usage & Examples

Some pipeline examples are provided in [/pipelines](pipelines/).

```yaml
# pipelines/product-config.yaml
resource_types:
  - name: semver-config
    type: docker-image
    source:
      repository: itstarting/semver-config-concourse-resource

resources:
- name: config
  type: semver-config
  source:
    driver: git
    uri: https://github.com/brightzheng100/semver-config-concourse-resource.git
    branch: master
    config_file: examples/version-with-product-config.yaml
    initial_version: 1.0.0                          # optional, defaults to 0.0.0 if not set
    config_path: "elastic-runtime"                  # [yq](https://github.com/mikefarah/yq)-style path
    version_path: "elastic-runtime.product-version" # [yq](https://github.com/mikefarah/yq)-style path
    version_pattern: "m.n.*"                        # refer to Version Patterns for how to detect new versions
```

```yaml
jobs:
- name: job1
  plan:
  - get: config
    params:
      format: yaml     # Optional. Supported formats: `yaml`, `json`. Defaults to `yaml`
    trigger: true
  ...
```


## Version Patterns

There are some version detection patterns supported:

- `m.*.*`: ONLY Major (m) version change should be detected as a change, e.g. `2.*.*` -> `3.*.*`
- `m.n.*`: BOTH Major (m) AND miNor (n) version change should be detected as a change, e.g. `2.*.*` -> `3.*.*`, `2.1.*` -> `2.2.*`
- `m.n.p`: Any Major (m), miNor (n), and Patch (p) version change should be detected as a change, e.g. `2.*.*` -> `3.*.*`, `2.1.*` -> `2.2.*`, `2.1.5` -> `2.1.9`
- `*.n.*`: ONLY miNor (m) version change should be detected as a change, e.g. `2.2.*` -> `2.3.*`
- `*.*.p`: ONLY Patch (p) version change should be detected as a change, e.g. `2.2.4` -> `2.2.9`


## Development

### Prerequisites

- [yq](https://github.com/mikefarah/yq): v2.3.0 is tested; other versions may also work
- [jq](https://stedolan.github.io/jq/): v1.5 is tested; other versions may also work
- [Bats](https://github.com/bats-core/bats-core)
- Git client
- Bash

### Testing

Some submodules have been used in this repo for testing purposes.

```
$ mkdir -p tests/libs

$ git submodule add https://github.com/bats-core/bats-core.git tests/libs/bats
$ git submodule add https://github.com/ztombol/bats-support tests/libs/bats-support
$ git submodule add https://github.com/ztombol/bats-assert tests/libs/bats-assert
```

So if you want to run the test cases by yourself, do this:

```
$ git submodule update --init

$ bats tests/check.bats
$ bats tests/in.bats
```

## Contributing

Please make all pull requests to the master branch and ensure tests are added to `/tests/check.bats` and/or `/tests/in.bats`.
