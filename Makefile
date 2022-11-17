IMAGE?=kameshsampath/kube-dev-tools
TAG?=latest
SHELL := bash
CURRENT_DIR = $(shell pwd)
ENV_FILE := $(CURRENT_DIR)/.envrc
BUILDER=buildx-multi-arch

prepare-buildx: ## Create buildx builder for multi-arch build, if not exists
	docker buildx inspect $(BUILDER) || docker buildx create --name=$(BUILDER) --driver=docker-container --driver-opt=network=host

build-tools:	prepare-buildx	## Build tools image locally
	docker buildx build --builder=$(BUILDER) --output="type=docker" -t $(IMAGE):$(TAG) .
	
release:
	@drone exec --trusted --env-file=.env

help: ## Show this help
	@echo Please specify a build target. The choices are:
	@grep -E '^[0-9a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "$(INFO_COLOR)%-30s$(NO_COLOR) %s\n", $$1, $$2}'

.PHONY: bin build-plugin push-plugin help