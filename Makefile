# Variables
UPLOAD_REGISTRY := $(shell cat .meta.yml | yq .registry)
NAME := $(shell cat .meta.yml | yq .name)
TAGGED_COMMIT := $(shell git describe --tags --exact-match HEAD 2>/dev/null)
COMMIT_HASH := $(shell git rev-parse --short HEAD)
LATEST_TAG := $(shell git describe --tags --abbrev=0 2>/dev/null)
ifdef TAGGED_COMMIT
    VERSION := $(TAGGED_COMMIT)
else
    VERSION := $(LATEST_TAG)-$(COMMIT_HASH)
endif
MAJOR := $(shell echo $(LATEST_TAG) | cut -d. -f1)
MINOR := $(shell echo $(LATEST_TAG) | cut -d. -f2)
PATCH := $(shell echo $(LATEST_TAG) | cut -d. -f3)
BUILD_PLATFORM := linux/amd64
FULL_NAME := $(UPLOAD_REGISTRY)/${NAME}:$(VERSION)

all:
	@echo "Default target..."

test:
	@echo $(UPLOAD_REGISTRY)

build:
	@echo "Building container image $(FULL_NAME)..."
	@docker build --platform $(BUILD_PLATFORM) -t $(FULL_NAME) .

push:
	@$(MAKE) build
	@docker push $(FULL_NAME)

define release_version
	@if [ "$(1)" = "patch" ]; then \
		NEW_PATCH=$$(($(PATCH) + 1)); \
		NEW_VERSION=$(MAJOR).$(MINOR).$$NEW_PATCH; \
	elif [ "$(1)" = "minor" ]; then \
		NEW_MINOR=$$(($(MINOR) + 1)); \
		NEW_VERSION=$(MAJOR).$$NEW_MINOR.0; \
	elif [ "$(1)" = "major" ]; then \
		NEW_MAJOR=$$(($(MAJOR) + 1)); \
		NEW_VERSION=$$NEW_MAJOR.0.0; \
	else \
		echo "Invalid release type: $(1)"; \
		exit 1; \
	fi; \
	echo "Releasing $(1) version $$NEW_VERSION"; \
	git tag $$NEW_VERSION; \
	make push VERSION=$$NEW_VERSION
	# git push origin $$NEW_VERSION
	# git push origin master
endef

release-patch:
	$(call release_version,patch)

release-minor:
	$(call release_version,minor)

release-major:
	$(call release_version,major)

# Clean target
clean:
	@echo "make clean: Cleaning up..."

.PHONY: all build push release-patch release-minor release-major clean
