IMAGE?=kameshsampath/kube-dev-tools
TAG?=latest
SHELL := bash
CURRENT_DIR = $(shell pwd)
ENV_FILE := $(CURRENT_DIR)/.envrc

build-tools: ## Build tools image locally
	@drone exec .drone

release:
	@drone exec --trusted --env-file=.env

help: ## Show this help
	@echo Please specify a build target. The choices are:
	@grep -E '^[0-9a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "$(INFO_COLOR)%-30s$(NO_COLOR) %s\n", $$1, $$2}'

.PHONY: bin build-plugin push-plugin help