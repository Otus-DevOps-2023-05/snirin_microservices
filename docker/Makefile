default: help

.PHONY: help
help: # Show help for each of the Makefile recipes.
	@grep -E '^[a-zA-Z0-9 -]+:.*#'  Makefile | sort | while read -r l; do printf "\033[1;32m$$(echo $$l | cut -f 1 -d':')\033[00m:$$(echo $$l | cut -f 2- -d'#')\n"; done

.PHONY: build
build: # Build docker $image, where $image is in the list: ui, post, comment, prometheus, all. Example `make build image=all`
ifeq ($(image),$(filter $(image),ui all))
	docker build -t snirinnn/ui ../src/ui
endif

ifeq ($(image),$(filter $(image),post all))
	docker build -t snirinnn/post ../src/post-py
endif

ifeq ($(image),$(filter $(image),comment all))
	docker build -t snirinnn/comment ../src/comment
endif

ifeq ($(image),$(filter $(image),prometheus all))
	docker build -t snirinnn/prometheus ../monitoring/prometheus
endif

.PHONY: push
push: # Push docker $image into repository, where $image is in the list: ui, post, comment, prometheus, all. Example `make push image=all`
ifeq ($(image),$(filter $(image),ui all))
	docker push snirinnn/ui:latest
endif

ifeq ($(image),$(filter $(image),post all))
	docker push snirinnn/post:latest
endif

ifeq ($(image),$(filter $(image),comment all))
	docker push snirinnn/comment:latest
endif

ifeq ($(image),$(filter $(image),prometheus all))
	docker push snirinnn/prometheus:latest
endif

.PHONY: up
up: # Launch docker-compose
	docker-compose -f docker-compose.yml up -d