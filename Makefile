all: build push

test:
	bats tests/check.bats && bats tests/in.bats

build:
	docker build -t itstarting/semver-config-concourse-resource:local .

push:
	docker tag itstarting/semver-config-concourse-resource:local itstarting/semver-config-concourse-resource:latest
	docker push itstarting/semver-config-concourse-resource:latest

fly:
	fly -t main set-pipeline -p product-config -c pipelines/product-config.yaml -n
	fly -t main up -p product-config

refly:
	fly -t main dp -p product-config -n
	fly -t main sp -p product-config -c pipelines/product-config.yaml -n
	fly -t main up -p product-config