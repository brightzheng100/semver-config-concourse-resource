all: test build push-release

test:
	bats tests/check.bats && bats tests/in.bats

build:
	docker build -t itstarting/semver-config-concourse-resource:test .

push-test:
	docker push itstarting/semver-config-concourse-resource:test

RELASE_VERSION = "1.0.0"
push-release:
	docker tag itstarting/semver-config-concourse-resource:test itstarting/semver-config-concourse-resource:$(RELASE_VERSION)
	docker push itstarting/semver-config-concourse-resource:$(RELASE_VERSION)

push-latest:
	docker tag itstarting/semver-config-concourse-resource:test itstarting/semver-config-concourse-resource:latest
	docker push itstarting/semver-config-concourse-resource:latest

fly:
	fly -t main set-pipeline -p product-config -c pipelines/product-config.yaml -n
	fly -t main up -p product-config

refly:
	fly -t main dp -p product-config -n
	fly -t main sp -p product-config -c pipelines/product-config.yaml -n
	fly -t main up -p product-config